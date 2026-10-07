# Karate — contratos de catálogo

[English version](README.en.md) · [Execuções e artifacts](https://github.com/brunobaccari/karate-api-catalog/actions)

Testes de API em **Karate 2.1.3 e Java 21** contra [DummyJSON](https://dummyjson.com/docs/products). O risco é entregar ao consumidor páginas duplicadas, produtos fora do filtro ou preços em ordem incorreta. As verificações comparam respostas relacionadas, além de status e tipos.

## Executar

Java 21 e Maven 3.9 ou superior:

```bash
cp .env.example .env
mvn -B -ntp clean verify
```

No PowerShell, use `Copy-Item .env.example .env`. O runner lê `API_BASE_URL` do processo ou, na ausência dela, do `.env` em UTF-8 via `java.util.Properties`. Use `CHAVE=valor`, sem aspas ou expansão de shell. Não há chave de API nem serviço local. Um alvo diferente precisa oferecer o mesmo contrato e dados.

## Cenários

| Risco | Verificação |
| --- | --- |
| Limites de paginação | Tamanhos 1, 5 e 10, contrato dos itens, `limit`, `skip` e total |
| Itens duplicados | Páginas adjacentes com dez IDs distintos e total estável |
| Fim do catálogo | Último item e página seguinte vazia, usando o total retornado |
| Ordenação incorreta | Preços ascendentes e descendentes, comparados à ordenação numérica |
| Vazamento de categoria | Todos os itens filtrados pertencem à categoria solicitada |
| Projeção de campos | Apenas os campos pedidos e o ID, comparados à consulta completa |
| Produto inexistente | HTTP 404 e erro estruturado |
| Escrita simulada confundida com persistência | PATCH/DELETE confirmam a resposta e consultam novamente o produto original |

São **12 cenários**, executados em série. Os exemplos de paginação e ordenação usam tabelas; os limites usam o total da própria API, sem fixar o tamanho do catálogo. Não há retry automático, carga nem alterações persistentes no serviço.

## Relatórios e bloqueio

Abra `target/karate-reports/karate-summary.html` após a execução. O relatório mostra passos, requisições, respostas e expectativas. JUnit fica em `target/karate-reports/junit-xml/`; o Surefire registra o runner Java separadamente.

No **Actions → Karate API tests**, o Summary lista cada cenário, resultado e contagens. O artifact **karate-results** inclui HTML, JUnit e resumo por 14 dias, também em falhas. Esses outputs e `.env` não entram no Git.

O gate exige Maven aprovado e os 12 cenários aprovados, sem skips. Relatório ausente, inválido, vazio, incompleto ou com falha bloqueia. O parser tem uma verificação executável: `python scripts/summary.py --self-test` (Python 3, biblioteca padrão).

## Limites e triagem

DummyJSON é um serviço público de demonstração. PATCH e DELETE **não persistem**: os testes demonstram exatamente essa limitação, não um CRUD real. A suíte não valida autorização, pagamento, estoque concorrente ou SLAs. O contrato e a implementação de produção de uma empresa não foram analisados.

Em falhas, confira o passo e a resposta no HTML antes de classificar: 429, timeout e indisponibilidade são falhas de ambiente; uma diferença de contrato precisa ser investigada. Nenhuma dessas condições é convertida em aprovação.

Referências: [documentação de produtos](https://dummyjson.com/docs/products), [Karate com Maven/Java](https://docs.karatelabs.io/getting-started/install-dependencies/), [relatórios nativos](https://docs.karatelabs.io/running-tests/test-reports/).

Husky: com Node 24 e as dependências da stack instalados, rode `npm ci` para ativar o pre-commit. `npm run check:local` verifica o diff, o gate dos relatórios e os checks de tipos/lint existentes. O hook também bloqueia arquivos ignorados no índice. Testes que usam navegador, emulador ou API continuam no CI.
