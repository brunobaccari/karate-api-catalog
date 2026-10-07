import html
import os
from pathlib import Path
import sys
import tempfile
import xml.etree.ElementTree as ET


def read_results(folder):
    reports = sorted(folder.glob('*.xml'))
    if not reports:
        raise ValueError('Karate JUnit reports are missing')
    cases = [case for report in reports for case in ET.parse(report).iter('testcase')]
    if not cases:
        raise ValueError('Karate JUnit reports are empty')
    return [(case.get('name', 'unnamed'),
             'failed' if case.find('failure') is not None or case.find('error') is not None
             else 'skipped' if case.find('skipped') is not None else 'passed') for case in cases]


def approved(cases, outcome, expected=12):
    return outcome == 'success' and len(cases) == expected and all(status == 'passed' for _, status in cases)


def self_test():
    with tempfile.TemporaryDirectory() as directory:
        folder = Path(directory)
        report = folder / 'catalog.xml'
        for content in (None, 'invalid', '<testsuite/>'):
            if content is not None:
                report.write_text(content, encoding='utf-8')
            try:
                read_results(folder)
            except (ValueError, ET.ParseError):
                pass
            else:
                raise AssertionError('Missing, invalid or empty report was accepted')
        report.write_text('<testsuite><testcase name="ok"/><testcase name="bad"><failure/></testcase><testcase name="error"><error/></testcase><testcase name="skip"><skipped/></testcase></testsuite>', encoding='utf-8')
        cases = read_results(folder)
        assert [status for _, status in cases] == ['passed', 'failed', 'failed', 'skipped']
        assert not approved(cases, 'success', 4)
        valid = [('ok', 'passed')] * 12
        assert approved(valid, 'success')
        assert not approved(valid[:-1], 'success')
        assert not approved(valid, 'failure')
        assert not approved(valid, 'skipped')
    print('Summary checks passed')


if __name__ == '__main__':
    if '--self-test' in sys.argv:
        self_test()
        raise SystemExit(0)
    cases, problem = [], ''
    try:
        cases = read_results(Path('target/karate-reports/junit-xml'))
    except (OSError, ValueError, ET.ParseError) as error:
        problem = str(error)
    outcome = os.environ.get('TEST_OUTCOME', 'unknown')
    passed = not problem and approved(cases, outcome)
    lines = ['## Karate — catalog API', '', f"Maven: **{outcome}**. Gate: **{'passed' if passed else 'blocked'}**.",
             f'Cases: **{len(cases)}/12**; passed: **{sum(status == "passed" for _, status in cases)}**; failed: **{sum(status == "failed" for _, status in cases)}**; skipped: **{sum(status == "skipped" for _, status in cases)}**.',
             '', html.escape(problem), '', '| Scenario | Result |', '| --- | --- |']
    lines += [f"| {html.escape(name).replace('|', '&#124;')} | {status} |" for name, status in cases]
    lines += ['', 'Target: https://dummyjson.com. Java 21, Karate 2.1.3. Serial HTTP checks; no automatic retries.',
              'Scope: pagination, ordering, projection, category isolation, missing product and simulated writes. DummyJSON does not persist updates/deletes.',
              'A failed or incomplete run blocks this gate. An unavailable public API is an environment failure, not a pass.',
              '', 'Download **karate-results** in this run for HTML, JUnit and this summary. Retention: 14 days.']
    content = '\n'.join(lines) + '\n'
    Path('target').mkdir(exist_ok=True)
    Path('target/summary.md').write_text(content, encoding='utf-8')
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as output:
            output.write(content)
    print(content)
    raise SystemExit(0 if passed else 1)
