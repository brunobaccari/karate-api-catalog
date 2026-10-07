# Karate — catalog contracts

[Versão em português](README.md) · [Runs and artifacts](https://github.com/brunobaccari/karate-api-catalog/actions)

API tests using **Karate 2.1.3 and Java 21** against [DummyJSON](https://dummyjson.com/docs/products). The risk is returning duplicate pages, products outside the requested filter or incorrectly ordered prices. Checks compare related responses as well as status codes and types.

## Run

Java 21 and Maven 3.9 or later:

```bash
cp .env.example .env
mvn -B -ntp clean verify
```

On PowerShell, use `Copy-Item .env.example .env`. The runner reads `API_BASE_URL` from the process, falling back to the UTF-8 `.env` file through `java.util.Properties`. Use `KEY=value`, without quotes or shell expansion. No API key or local service is needed. A different target must provide the same contract and data.

## Scenarios

| Risk | Check |
| --- | --- |
| Pagination boundaries | Sizes 1, 5 and 10, item contract, `limit`, `skip` and total |
| Duplicate items | Adjacent pages with ten distinct IDs and a stable total |
| End of catalog | Last item and subsequent empty page, using the returned total |
| Incorrect ordering | Ascending and descending prices compared with numeric sorting |
| Category leakage | Every filtered product belongs to the requested category |
| Field projection | Only requested fields and the ID, compared with the full product |
| Missing product | HTTP 404 and a structured error |
| Simulated writes mistaken for persistence | PATCH/DELETE check the response and read the original product again |

There are **12 scenarios**, run serially. Pagination and ordering use example tables; boundary checks use the API's total rather than a fixed catalog size. There are no automatic retries, load tests or persistent service changes.

## Reports and gate

Open `target/karate-reports/karate-summary.html` after execution. The report includes steps, requests, responses and expectations. JUnit reports are in `target/karate-reports/junit-xml/`; Surefire records the Java runner separately.

Under **Actions → Karate API tests**, the Summary lists each scenario, outcome and counts. The **karate-results** artifact contains HTML, JUnit and the summary for 14 days, including failed runs. Outputs and `.env` stay out of Git.

The gate requires a successful Maven run and all 12 scenarios passing, with no skips. Missing, invalid, empty, incomplete or failing reports block it. The parser has a runnable check: `python scripts/summary.py --self-test` (Python 3, standard library).

## Limits and triage

DummyJSON is a public demonstration service. PATCH and DELETE **do not persist**: these tests demonstrate that behavior, not real CRUD persistence. The suite does not validate authorization, payments, concurrent stock changes or SLAs. No company's production contract or implementation was reviewed.

When a test fails, inspect the step and response in the HTML before classifying it: 429, timeouts and unavailability are environment failures; a contract difference requires investigation. None of these conditions is converted into a pass.

References: [product documentation](https://dummyjson.com/docs/products), [Karate with Maven/Java](https://docs.karatelabs.io/getting-started/install-dependencies/), [native reports](https://docs.karatelabs.io/running-tests/test-reports/).
