# Atualização alpha.8 — atividades, tarefas do grupo e medalhas

## Importante: Drive ainda não está pronto

A alpha.8 **não envia arquivos ao Google Drive**. Ela aceita links nas entregas. O professor escolheu uma pasta por atividade e nomes com grupo, atividade e data; a integração real, a autorização do site e os controles de acesso estão planejados em `PLANO_GOOGLE_DRIVE.md`. A conexão do Drive nesta conversa não conecta automaticamente o site dos alunos.

## O que foi preparado

- **Atividade:** somente o professor cria e edita. Ao criar, escolhe todos os grupos ou uma demanda específica. O destinatário não pode ser alterado depois da criação; prazo, descrição e medalha podem ser alterados.
- **Tarefa:** integrantes podem criar tarefas dentro de uma atividade e atribuir a um integrante do próprio grupo. Elas podem ser marcadas como concluídas. O aluno vê somente as atividades e tarefas do seu grupo.
- **Medalhas:** o professor acessa **Medalhas**, cria ou edita uma medalha, atribui diretamente a um aluno ou aprova/recusa solicitações. Ao criar ou editar a atividade, pode vinculá-la a uma medalha e escolher automática ou com aprovação.
- Ao marcar uma atividade como entregue, a medalha escolhida é concedida automaticamente ou vai para aprovação para os **integrantes atuais** do grupo. A conclusão de uma tarefa isolada não conclui automaticamente a atividade. Não se concede a mesma medalha duas vezes à mesma pessoa.
- Alterar a medalha ou o modo cancela solicitações pendentes da configuração anterior. Uma mudança **não aplica medalhas retroativamente**; se desejado, registre novamente a entrega para aplicar a nova regra. Medalhas já dadas não são revogadas automaticamente ao reabrir a entrega.
- As atividades anteriores são copiadas para o novo modelo com status, links e observações; os registros antigos permanecem no banco para preservação. As operações antigas de edição são desativadas para evitar divergência. Atividades anteriormente vinculadas a demanda mantêm sua regra de pontuação; tarefas gerais e atividades novas não recebem pontos automaticamente.
- A medalha de primeiro acesso continua separada; novas medalhas usam símbolos provisórios, não as imagens finais.

## Antes de instalar

O professor informou que aplicou o SQL e os arquivos da alpha.7. Esta atualização foi preparada sobre o commit `3ec26ea` do repositório. Verifique novas alterações e preserve-as. Faça backup **do banco e dos arquivos**. A atualização altera os caminhos de escrita: interrompa temporariamente o uso do site por alunos, aplique o SQL e atualize o site na mesma janela. Com código antigo, alterações de atividades serão bloqueadas depois do SQL. Não reexecute o schema inicial, nem scripts já aplicados.

## SQL no Supabase

No projeto correto, execute esta consulta somente de leitura:

```sql
select
  to_regprocedure('public.impulso_extras(text,jsonb)') is not null as extras_atual,
  to_regprocedure('public.impulso_v7(text,jsonb)') is not null as acesso_anterior_renomeado,
  to_regprocedure('public.impulso_extras_v7(text,jsonb)') is not null as extras_anteriores_renomeados,
  to_regprocedure('public.impulso_learning(text,jsonb)') is not null as atividades_alpha8;
```

- Se o resultado for `true, false, false, false`, faça backup e execute **uma única vez** `database-updates/202611130005_activities_and_badges.sql`.
- Se for `true, true, true, true`, a atualização parece instalada: não execute novamente.
- Se houver outra combinação ou erro, pare e peça ajuda. Não tente reexecutar scripts anteriores.

O SQL usa uma transação: se falhar, confira o erro e o estado antes de tentar qualquer coisa. A cópia inclui atividades gerais e vinculadas a demandas; o SQL não apaga registros antigos. O acesso ao antigo método de alteração de atividades é bloqueado para impedir versões divergentes. Após aplicar, copie os arquivos da alpha.8 para os mesmos caminhos, preservando `src/config.js`, segredos e alterações próprias. Enviar arquivos não executa o SQL.

## Teste controlado antes de liberar aos alunos

1. Refaça o login da segunda conta que mostrou erro `.slice`; confirme logout, troca de senha, perfil e medalha. Informe a mensagem se ainda falhar, sem enviar senha.
2. Com duas contas de aluno, crie grupo, aceite convite, cadastre nome/link da demanda e avalie acesso do professor e isolamento. A alpha.7 está instalada, mas esses testes reais ainda precisam de confirmação.
3. Como professor, crie uma medalha e uma atividade para todos, escolhendo aprovação. Como aluno, crie uma tarefa e atribua ao colega; confirme que o outro grupo não a vê. Marque a atividade como entregue e aprove uma medalha no perfil do professor; confirme a medalha no perfil do aluno.
4. Teste uma medalha automática, atribuição manual e alteração do vínculo em uma atividade. Crie também uma atividade vinculada a uma demanda específica.
5. Verifique se atividades e entregas anteriores continuam visíveis, com status, links e observações. Teste regras de acesso diretamente na API e em contas de teste antes de dados reais.

Os testes de banco e interface foram locais; a interface usou respostas simuladas de rede. Não atualizamos nem testamos esta versão no seu Supabase ou site reais. Recomenda-se piloto controlado, backup e revisão de segurança antes de liberar para a turma.
