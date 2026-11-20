# Atualização alpha.10 — pontos por atividade

## O que muda

O professor pode definir **Pontos da atividade** ao criar ou editar uma atividade. O valor pode ser de 0 a 1.000.000 pontos inteiros; zero significa que ela não concede pontos. O valor aparece na atividade. Pontuação individual aparece na visão geral e no perfil; a pontuação do grupo aparece em Meu grupo. O professor também vê os pontos na lista e no perfil dos alunos e na tela de equipes.

## Regras escolhidas

- **Entrega por grupo:** ao registrar a entrega, o grupo recebe o valor da atividade **uma vez**, e cada integrante atual recebe o mesmo valor em seu saldo individual. A pontuação do grupo não é a soma das pontuações dos integrantes.
- **Entrega individual:** cada aluno recebe o valor assim que registra sua entrega. O grupo recebe o valor uma vez quando **todos os integrantes atuais** tiverem entregado.
- **Mudança de grupo:** o saldo de um aluno considera apenas o grupo atual. Ao sair do grupo, ele deixa de pontuar por suas atividades anteriores; sem grupo, o saldo é zero. Entrar em outro grupo faz o saldo refletir as entregas desse grupo e suas próprias entregas individuais nele.
- **Recálculo:** alterar o valor de uma atividade recalcula também as entregas anteriores. Reabrir uma entrega como pendente retira os pontos enquanto ela estiver pendente. Alterar a regra de entrega reinicia as confirmações, conforme a alpha.9; pontos são recalculados.
- **Medalhas:** pontos são contabilizados ao registrar entrega, independentemente da aprovação da medalha. As regras de medalhas não mudam. Uma tarefa desmembrada não pontua separadamente nesta versão.
- **Atividades anteriores:** as atividades que já tinham a antiga regra de 100 pontos mantêm o valor 100. Outras começam com 0 e podem ser editadas pelo professor. O saldo individual pode passar a ser exibido pela primeira vez para entregas anteriores elegíveis do grupo atual.

## Antes de instalar

Você informou que executou o SQL da alpha.9. Esta atualização foi preparada sobre o commit `232d186` do repositório. Verifique se houve mudanças posteriores e preserve-as. Faça backup dos arquivos e do banco e interrompa temporariamente o uso do site enquanto atualiza banco e arquivos. **Não reexecute o schema inicial nem SQL de versões anteriores.**

## Conferir e aplicar o SQL da alpha.10

No SQL Editor do projeto correto, execute a consulta **somente de leitura**:

```sql
select
  to_regprocedure('public.impulso_learning(text,jsonb)') is not null as atividades,
  to_regprocedure('public.impulso_learning_v8(text,jsonb)') is not null as alpha9_instalada,
  to_regclass('impulso_private.learning_individual_deliveries') is not null as entregas_individuais,
  to_regprocedure('public.impulso_learning_v9(text,jsonb)') is not null as acesso_alpha10,
  to_regprocedure('public.impulso_student_report_v9(uuid)') is not null as relatorio_alpha10,
  exists(select 1 from information_schema.columns where table_schema='impulso_private' and table_name='learning_activities' and column_name='point_value') as coluna_pontos;
```

- **true, true, true, false, false, false:** após backup, execute uma única vez `database-updates/202611130007_activity_points.sql`.
- **true, true, true, true, true, true:** a alpha.10 parece aplicada; não execute novamente.
- Qualquer outra combinação ou erro: pare e peça orientação. Não execute novamente SQL anterior.

Depois, copie os arquivos do pacote aos mesmos caminhos, preservando `src/config.js` e suas configurações. A atualização dos arquivos não executa o SQL. Não coloque senhas ou chaves secretas no navegador ou repositório.

## Teste controlado no ambiente real

1. Crie uma atividade de 30 pontos em modo **cada integrante entrega**. Um aluno entrega: ele deve ter 30 pontos pela atividade e o grupo, zero. O segundo entrega: ele também recebe 30 e o grupo soma 30 uma única vez.
2. Crie outra atividade de 50 pontos **por grupo**. Uma pessoa entrega: o grupo soma 50 e cada integrante atual soma 50.
3. Mude os 30 para 40; confirme que saldos anteriores são recalculados. Reabra uma entrega e verifique a retirada dos pontos correspondentes.
4. Retire ou transfira um aluno de teste; confira que seu saldo passa a refletir somente o grupo atual. Teste também uma atividade antiga que já valia 100 pontos.
5. Confira os pontos no perfil do aluno, em Meu grupo, na lista de alunos do professor e nas equipes. Teste que alunos e professores não consultam dados de outras turmas via API.

Os testes de banco e navegador foram locais; no navegador, a rede foi simulada. A alpha.10 não foi aplicada nem testada pelo assistente no Supabase ou site reais. A exclusão segura dos usuários de teste e o upload ao Drive continuam pendentes.
