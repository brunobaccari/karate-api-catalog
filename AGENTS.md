# Regras para alterações

- Leia os cenários e a documentação do alvo antes de alterar expectativas.
- Preserve Java 21, Karate e o runner pequeno; não crie uma aplicação local para substituir a API hospedada.
- DummyJSON simula escritas. Não descreva PATCH/DELETE como persistência real.
- Mantenha execução serial e sem retries automáticos; uma falha externa não é aprovação.
- Rode `mvn -B -ntp clean verify`. Ao mudar a quantidade de cenários, ajuste o gate e ambos os READMEs.
- Relatórios, logs, screenshots e `.env` ficam ignorados. Publique resultados apenas nos artifacts do Actions.
- Ao alterar o parser, rode `python scripts/summary.py --self-test` e preserve a recusa de relatórios incompletos.
- Preserve datas reais nos commits e equivalência factual entre PT-BR e inglês.
