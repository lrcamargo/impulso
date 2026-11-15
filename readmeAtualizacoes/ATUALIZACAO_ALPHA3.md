# Atualização 0.1.0-alpha.3 — editar alunos

Esta atualização parte do repositório público no commit `98a1611`, versão `0.1.0-alpha.2`. Confirme se o repositório não mudou desde então e não sobrescreva alterações posteriores. Ela não foi aplicada ao seu Supabase, GitHub ou Lovable automaticamente. Faça backup e use uma janela de manutenção; teste com dados fictícios.

## O que muda
A professora vê um botão **Editar** em **Alunos**, podendo corrigir nome e e-mail. Mudar o e-mail atualiza também o login por uma função de servidor. A conta, senha, exigência pendente de trocar senha e vínculos de grupo são mantidos; o aluno entrará com o novo e-mail. Algumas sessões existentes podem precisar sair e entrar novamente. A alteração de nome não muda nomes já registrados em mensagens antigas.

**Segurança:** não há confirmação enviada ao novo endereço. Antes de alterá-lo, a professora deve verificar por outro meio a identidade do aluno e a posse do novo e-mail; a caixa de confirmação na interface registra essa decisão operacional, mas não verifica a posse automaticamente. Continuam válidos os riscos de usar uma senha inicial comum para toda a turma. Nunca use chaves administrativas ou senhas no navegador, GitHub ou em conversas.

## 1. Preparar banco e aplicar SQL
1. Confirme que este é o mesmo projeto onde as versões alpha.1 e alpha.2 foram instaladas. Faça backup e confira como restaurá-lo. O plano gratuito não inclui backup automático.
2. Abra **SQL Editor → New query**. Copie todo o conteúdo de `database-updates/202611130002_edit_students.sql` e execute uma única vez. Não reexecute `supabase/schema.sql` nem a atualização alpha.2.
3. Se surgir erro, pare e guarde a mensagem. O script executa em transação e não altera dados de alunos por si só.

Verificação somente leitura:
```sql
select
  to_regprocedure('public.impulso_prepare_edit(uuid,text,text)') is not null as preparacao_instalada,
  to_regprocedure('public.impulso_finish_edit(uuid)') is not null as conclusao_instalada,
  to_regprocedure('public.impulso_cancel_edit(uuid)') is not null as cancelamento_instalado;
```
Os três resultados devem ser `true`. Se o SQL já tiver sido instalado, não o execute novamente.

## 2. Publicar a função no Supabase
1. Em **Edge Functions**, clique em **Deploy a new function → Via Editor**.
2. Crie uma função com o endereço/slug exato **`edit-student`**. Depois da publicação, confira se a URL termina em `/functions/v1/edit-student`. O nome exibido sozinho não garante que o endereço esteja correto.
3. Cole o conteúdo integral de `supabase/functions/edit-student/index.ts` no editor e publique. Mantenha a verificação de JWT ligada. Não exclua nem substitua a função existente `create-student`.
4. O código valida a sessão e verifica se o aluno pertence à professora antes de usar o cliente administrativo do servidor. Não cole uma chave secreta nele. A função não é implantada automaticamente quando os arquivos entram no GitHub.

## 3. Atualizar o site
A atualização é incremental: preserve `src/config.js`, `.lovable/`, configurações da hospedagem e outros arquivos existentes. Copie apenas os arquivos do pacote para os mesmos caminhos no repositório, sem reescrever histórico. Revise as mudanças e crie um commit como `feat: permitir corrigir cadastro de alunos`. Depois de testar, você pode criar a tag `v0.1.0-alpha.3`; ela não foi criada automaticamente.

## 4. Testar antes de dados reais
1. Entre com uma professora de teste; confirme que aparece **Alunos → Editar**. Corrija apenas o nome e veja se foi salvo.
2. Corrija também o e-mail de um aluno de teste, marcando a confirmação. Saia e confira que ele entra com o novo e-mail e a mesma senha e continua no mesmo grupo. Se ainda não tiver trocado a senha inicial, confirme que a troca continua obrigatória.
3. Verifique que sem marcar a confirmação o e-mail não muda e que outro professor ou aluno não consegue executar a operação pela API. Teste um e-mail que já pertence a outra conta: a alteração deve ser recusada.
4. Teste a interrupção de rede. Se receber a mensagem de alteração incompleta, repita com **exatamente o mesmo nome e e-mail**, pois o sistema tenta concluir a alteração pendente. Se persistir, pare e solicite suporte; o login pode ficar indisponível até reconciliar os dados. Não altere tabelas Auth manualmente nem apague contas sem investigação.
5. Após testar, faça revisão de segurança e privacidade antes de usar dados reais. A aplicação do SQL e a função não foram verificadas neste projeto Supabase real.

O banco mantém um registro privado das alterações de e-mail, incluindo endereço anterior e novo, para recuperar operações interrompidas. Avalie a retenção desses dados de acordo com a política da instituição e a LGPD.
