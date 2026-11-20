# Atualização alpha.7 — perfil, tarefas gerais e demandas

## Antes de tudo

Esta atualização foi preparada sobre o commit `41b8dc9` do seu repositório (alpha.6). Confira se houve alterações depois dele e preserve-as. Faça backup dos arquivos e dos dados. **Não execute `supabase/schema.sql` novamente** em um banco já instalado. A alpha.7 não foi aplicada nem testada no seu Supabase ou site reais.

Você informou que aplicou o SQL da alpha.6 e que a medalha funcionou. O novo SQL exige que as atualizações de banco anteriores estejam instaladas.

## O que foi preparado

- **Perfil do aluno:** nome cadastrado, apelido de exibição (não altera o e-mail de login), avatar pronto de bichinho, grupo, botão de troca de senha e área de medalhas. A primeira medalha usa uma ilustração provisória; as imagens finais podem ser substituídas depois.
- **Tarefas para todos:** o professor cria uma tarefa geral, e cada grupo registra sua própria situação, link e observações. Também vale para grupos criados depois. A criação de atividades para uma demanda específica continua disponível. Tarefas gerais ainda não dão pontos nem medalhas; edição/cancelamento da definição fica para evolução futura.
- **Avaliação de demanda:** o professor pode aprovar ou não aprovar; para não aprovar, precisa escrever o motivo. O grupo vê o feedback, edita nome/link para reenviar e consulta as avaliações anteriores. Uma mudança posterior de nome ou link volta a aguardar avaliação. Demandas já existentes passam a aguardar avaliação, sem apagar seu conteúdo. Complementar os dados não é o mesmo que aprovar.
- **Link:** novos cadastros e alterações aceitam exclusivamente `https://plataforma.gpinovacao.senai.br/plataforma/demandas-da-industria/interna/` seguido de números, sem parâmetros ou barra final. Links antigos não são apagados, mas para editar uma demanda será necessário adequar o link. Não há verificação se a demanda existe ou está acessível; isso exige acessar a Saga.
- **Acesso:** tratamento defensivo de dados incompletos para evitar o erro de `.slice` em campos de nome. A causa exata do erro da segunda conta ainda não foi confirmada; é necessário testar novamente.
- Ajuste para **“Abrir demanda na Saga”**. A mensagem de erro da medalha não aparece mais na visão geral; se houver erro de consulta, a área de medalhas no perfil informa que não foi possível carregar.

As novas medalhas de demanda e grupo, concessão automática/manual, medalhas por tarefas, modo noturno e avisos de novidades permanecem no backlog. Não são ativados por esta atualização.

## Instalação no Supabase

1. Abra o SQL Editor no projeto correto e execute esta consulta **somente de leitura**:

```sql
select
  to_regprocedure('public.impulso(text,jsonb)') is not null as acesso_atual,
  to_regprocedure('public.impulso_first_access_medal()') is not null as medalha_alpha6,
  to_regprocedure('public.impulso_alpha2_gate(text,jsonb)') is not null as acesso_alpha7,
  to_regprocedure('public.impulso_extras(text,jsonb)') is not null as extras_alpha7;
```

2. Se retornar `true, true, false, false`, depois do backup execute **uma vez** `database-updates/202611130004_profile_general_tasks.sql` no SQL Editor. O script preserva dados existentes, mas cria tabelas e registra demandas existentes como aguardando avaliação.
3. Se retornar `true, true, true, true`, a alpha.7 parece instalada: **não execute novamente**. Se houver outra combinação, pare e peça ajuda antes de alterar o banco.
4. Copie os arquivos do pacote para os mesmos caminhos do projeto, preservando `src/config.js` e outros arquivos de configuração. Enviar arquivos não executa o SQL automaticamente. Não coloque senha, chave `service_role` ou segredo no navegador.

## Testes antes de usar com a turma

1. Entre na segunda conta que mostrou o erro e também na conta que já funcionou. Teste login, logout, troca de senha e recarregamento. Se houver falha, informe a mensagem e em que etapa apareceu, sem enviar senha.
2. Como aluno, acesse **Meu perfil**, escolha apelido e avatar, salve e recarregue; confira grupo, botão de trocar senha e medalha.
3. Como professor, crie uma tarefa para todos. Verifique que cada grupo tem sua própria linha; registre a entrega de um grupo e confirme que o outro continua pendente. Crie depois outro grupo e confira que a tarefa aparece para ele. Verifique isolamento usando duas contas de aluno.
4. Cadastre uma demanda com o formato de link indicado. Teste um link inválido e confirme que é recusado. Como professor, não aprove com um motivo; como aluno, confira o motivo, troque nome ou link e reenvie. O professor aprova e ambos conferem o histórico.
5. Teste uma atividade vinculada à demanda, isolamento de dados, acesso direto à API, e as funções anteriores. A avaliação e tarefas gerais ainda não concedem novas medalhas.

Se o teste real falhar, registre a mensagem e o passo, sem enviar senhas ou chaves secretas. Não publique o aviso do Classroom antes de terminar os testes.
