# Atualização alpha.9 — entregas, visão da professora e medalhas

## Importante: seu SQL da alpha.8 já foi executado

Você informou que executou o SQL da alpha.8, mas não conseguiu baixar os arquivos. Este pacote traz **os arquivos de interface da alpha.8 junto com a alpha.9**. Não execute novamente `202611130005_activities_and_badges.sql`; ele está incluído como referência e para testes locais. A alpha.9 tem **um novo SQL**, explicado abaixo.

A exclusão dos usuários de teste e o upload ao Drive **ainda não estão implementados**. Não apagamos dados nem contas. Veja os planos e o backlog no pacote.

## O que foi preparado

- **Atividades e tarefas da alpha.8:** somente a professora cria/edita atividades; alunos criam tarefas dentro delas e atribuem responsáveis do próprio grupo. O aluno vê suas atividades e tarefas do grupo, sem a seção separada de tarefas para todos.
- **Quem entrega:** ao criar ou editar a atividade, a professora escolhe entre uma pessoa registrar a entrega pelo grupo ou cada integrante registrar a sua. No modo individual, a atividade do grupo só fica entregue quando todos os **integrantes atuais** tiverem registrado. Cada aluno só marca sua própria entrega.
- **Acompanhamento:** em **Atividades e prazos**, a professora pode abrir a situação dos integrantes de cada grupo e ver links e observações. No modo por grupo, o status dos alunos é identificado como “entregue pelo grupo”, não como uma entrega individual.
- **Perfil do aluno:** em **Alunos**, o botão **Ver perfil** mostra nome, e-mail, apelido, avatar, grupo, demanda, medalhas e atividades/entregas atuais para a professora responsável. Não mostra senhas.
- **Medalhas:** tela da professora para criar/editar medalhas, atribuir ao aluno, aprovar ou recusar solicitações e escolher concessão automática ou mediante aprovação por atividade. As imagens enviadas foram aplicadas às medalhas Primeiro Acesso, Primeiro Grupo, Demanda Cadastrada e Demanda Aprovada. As medalhas personalizadas usam símbolos provisórios.

## Regras importantes

- Nos três marcos de grupo/demanda, membros atuais recebem a conquista quando entram em grupo, quando a demanda é cadastrada ou quando é aprovada. Quem entra depois recebe também os marcos da demanda atual já cadastrada/aprovada. Na instalação, a recuperação considera apenas o grupo e a demanda **atuais** e aprovação atual; não prova participações antigas.
- Ao trocar a regra de entrega de uma atividade existente, suas confirmações são reiniciadas para evitar interpretar uma entrega do grupo como entregas individuais. Medalhas já recebidas não são retiradas automaticamente. Alterar a medalha ou o modo cancela solicitações pendentes da configuração anterior.
- Quando alguém entra ou sai do grupo, a situação de atividades individuais é recalculada com os integrantes atuais; solicitações pendentes podem ser canceladas ou recriadas. Medalhas já concedidas não são revogadas automaticamente.
- A medalha por atividade é processada quando a atividade do grupo fica entregue; concluir uma tarefa isolada não conclui a atividade automaticamente.
- O upload ao Google Drive continua pendente. As entregas ainda usam links. A exclusão segura das contas e dos dados de teste também está pendente.

## Antes de instalar

Este pacote é incremental sobre o commit `3ec26ea` (alpha.7) e inclui os arquivos da alpha.8 que você não conseguiu baixar. Verifique se o repositório recebeu alterações posteriores e preserve-as. Faça backup do banco e dos arquivos. Interrompa temporariamente o uso do site enquanto executa o novo SQL e atualiza os arquivos; o código e o banco precisam estar na mesma versão. Não execute `supabase/schema.sql` novamente.

## Conferir e aplicar o SQL da alpha.9

No SQL Editor do projeto correto, execute a consulta **somente de leitura**:

```sql
select
  to_regprocedure('public.impulso_learning(text,jsonb)') is not null as alpha8_instalada,
  to_regprocedure('public.impulso_learning_v8(text,jsonb)') is not null as funcao_renomeada_alpha9,
  to_regprocedure('public.impulso_student_report(uuid)') is not null as painel_alpha9,
  to_regclass('impulso_private.learning_individual_deliveries') is not null as entregas_alpha9;
```

- Se retornar **true, false, false, false**, faça backup e aplique **uma vez** `database-updates/202611130006_individual_delivery.sql`.
- Se retornar **true, true, true, true**, a alpha.9 parece já aplicada: não execute novamente.
- Qualquer outra combinação: pare e peça ajuda. Não reexecute a alpha.8 ou o schema inicial.

Depois, copie os arquivos do pacote para os mesmos caminhos do projeto, inclusive `public/medalhas/`. Preserve `src/config.js` e configurações próprias. Arquivos não executam SQL automaticamente. Nunca coloque senha, chave `service_role` ou outro segredo no navegador.

## Testes reais antes de usar com a turma

1. Confirme as duas contas, login, logout e primeiro acesso. Crie um grupo, aceite o convite e cadastre a demanda. Verifique se cada imagem de medalha aparece após o evento correspondente e no perfil.
2. Crie uma atividade **por grupo**: uma pessoa marca a entrega, e você verifica o grupo e os alunos com o rótulo “entregue pelo grupo”.
3. Crie outra em que **cada integrante entrega**. Depois de só um aluno entregar, confirme que o outro e o grupo estão pendentes. Após os dois, o grupo fica entregue. Inclua/remova um aluno de teste e confira o recálculo com os integrantes atuais.
4. Crie uma tarefa dentro da atividade e atribua ao colega. Teste medalha automática e medalha que precisa de aprovação. Confirme que nenhum aluno consegue criar atividade ou ver outro grupo.
5. Em **Alunos**, abra o perfil do aluno e confira grupo, medalhas, demanda, entregas, links e observações. Verifique isolamento no projeto real e faça backup.

Testes de banco e navegador foram locais; o navegador usou rede simulada. A alpha.9 não foi aplicada nem testada pelo assistente no Supabase ou site reais.
