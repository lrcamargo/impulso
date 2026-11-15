# Guia de configuração do Supabase — Impulso

Este projeto foi feito para um Supabase próprio. Sem configurar o banco e as informações públicas abaixo, ele mostra apenas a tela de configuração. Não envie senhas ou chaves secretas em conversas ou no código.

## 1. Criar conta e projeto
1. Acesse https://supabase.com e crie sua conta.
2. Crie uma organização e um novo projeto no plano Free. Defina uma senha forte para o banco e guarde-a fora do repositório. Escolha uma região adequada à sua instituição e política de dados.
3. Aguarde a criação do projeto. No painel, encontre **Project URL** e a chave **Publishable** (ou a chave pública legada **anon**) em Connect / Project Settings → API / API Keys, conforme a interface vigente. Os rótulos podem mudar.
4. No arquivo `src/config.js`, preencha apenas esses dados públicos:

```js
export const SUPABASE_URL = 'https://SEU-PROJETO.supabase.co';
export const SUPABASE_PUBLISHABLE_KEY = 'SUA_CHAVE_PUBLICAVEL_OU_ANON';
```

Essa chave será visível no navegador; é normal. Ela depende das restrições de acesso do banco. **Nunca coloque chave secret, `service_role`, senha do banco, SMTP ou outro segredo no código, em `VITE_` ou no GitHub.** Uma alternativa local é copiar `.env.example` para `.env` e definir as duas variáveis ali.

## 2. Instalar a estrutura do banco
1. No projeto Supabase, abra **SQL Editor → New query**.
2. Copie todo o conteúdo de `supabase/schema.sql` e execute uma vez em um projeto novo e vazio. O script cria o schema privado, tabelas e a função `public.impulso`, bem como as restrições de acesso. Não execute novamente sobre dados existentes sem preparar uma migração.
3. Confirme que o editor concluiu sem erros. Se ocorrer erro, pare: não publique o sistema e preserve a mensagem para diagnóstico. As alterações ocorrem dentro de uma transação.
4. Não exponha `impulso_private` em **API → Exposed schemas** e não conceda acesso direto às suas tabelas. O frontend usa somente a função `public.impulso`, que verifica a sessão e os vínculos.

## 3. Configurar o login e as URLs
1. Em **Authentication → Providers / Sign In → Email**, mantenha login com e-mail e senha e **Confirm email** ativado. Não desative a confirmação: a identidade do aluno depende da posse do e-mail cadastrado pelo professor.
2. Em **Authentication → URL Configuration**, configure **Site URL** com o endereço final da aplicação e adicione esse endereço aos **Redirect URLs**. Para testes locais, adicione também `http://localhost:5173/` e, caso aplicável, a URL exata usada pelo navegador. Atualize ao mudar o domínio. A aplicação usa a URL da página como destino de confirmação e recuperação de senha.
3. O SMTP padrão do Supabase serve para testes limitados: envia apenas para endereços autorizados da equipe do projeto e tem limites baixos. Para alunos de verdade, configure **Authentication → Emails → SMTP Settings** com um serviço próprio de e-mail transacional; normalmente será necessário verificar um domínio e seguir as instruções do provedor. Confira custos, limites e política institucional. Exemplo: Resend tem plano gratuito sujeito a limites e requisitos de domínio; outras opções podem ser usadas.
4. Para teste inicial, é possível cadastrar manualmente no painel do Supabase um usuário de teste que você controla e marcar o e-mail como confirmado apenas se você verificou sua posse. Para uso real, use envio e confirmação de e-mail apropriados. Não desative a confirmação global para contornar o SMTP.

## 4. Habilitar sua conta de professor
O professor não pode ser criado pela interface comum: isso evita que qualquer aluno escolha o papel de professor.

1. Crie sua conta com seu e-mail no aplicativo após configurá-lo, confirme o e-mail e escolha uma senha. Se a aplicação informar que seu e-mail não foi cadastrado pelo professor, isso é esperado antes do próximo passo. Alternativamente, crie um usuário de teste que você controla em **Authentication → Users**, com e-mail confirmado somente após verificar sua posse.
2. No **SQL Editor**, execute a consulta abaixo, trocando o e-mail e nome pelos seus. Use exatamente o e-mail da conta já confirmada. Não inclua senhas na consulta.

```sql
insert into impulso_private.teachers (user_id, name)
select id, 'Nome do professor'
from auth.users
where lower(email) = lower('seu-email@exemplo.com')
  and email_confirmed_at is not null
on conflict (user_id) do update set name = excluded.name
returning user_id, name;
```

3. A consulta deve retornar exatamente uma linha. Se retornar zero, confira o e-mail em **Authentication → Users** e sua confirmação. Saia e entre novamente no aplicativo.
4. Em **Alunos**, cadastre cada nome e e-mail. Os alunos criam suas próprias contas com o mesmo e-mail e confirmam a posse; o vínculo ocorre no primeiro acesso. Um e-mail só pode estar cadastrado para um professor neste MVP.

## 5. Verificar antes de usar com a turma
- Use contas de teste reais sob seu controle e duas sessões ou navegadores separados.
- Professor cadastra Alice e Bruno. Alice cria o grupo e convida Bruno. Antes do aceite, Bruno não vê demanda, tarefas nem mural. Após aceitar, ambos veem o grupo. Teste recusa com um terceiro aluno.
- Crie um segundo grupo e confirme que um aluno do primeiro não lê registros do segundo. Faça testes também com chamadas diretas à API, não só pela interface; verifique que papéis, convites de outras pessoas e dados privados não podem ser alterados.
- Teste a confirmação de e-mail, recuperação de senha, link da demanda, detalhes preenchidos pelo professor, tarefas, mural e acesso novamente após sair.
- Revise independentemente a função `public.impulso`, as permissões e as políticas, configure proteção contra abuso e limite de pesquisas antes de produção, especialmente com alunos menores de idade. Garanta aprovação institucional, privacidade, LGPD e autorização para dados de empresas.
- O plano Free não inclui backups automáticos e projetos inativos podem ser pausados. Planeje backup/teste de restauração e acompanhe o uso e os termos atuais.

## Limitações da primeira versão
- Um aluno cadastrado está associado a um único professor e pode participar de apenas um grupo. Para mudar de grupo, o professor precisa remover sua associação atual.
- Convites aparecem dentro do site; não há envio de e-mail para convite de grupo.
- Professores podem cadastrar alunos, renomear grupos, remover integrantes, cancelar convites, complementar demandas e gerenciar atividades. Não há edição/exclusão de alunos, exclusão de projetos, anexos, comentários em tarefas, aprovação prévia de entregas ou notificações de prazo.
- As tarefas podem ser marcadas como entregues pelos membros e valem 100 pontos sem aprovação. Não há importação automática do SAGA SENAI.
- O formulário aceita criação de conta por e-mail, mas apenas endereços previamente cadastrados e confirmados acessam dados. Para operação pública, avalie CAPTCHA e limites de taxa no Supabase para evitar abuso do cadastro e da pesquisa.
- O código passou por testes locais de banco simulado e build; não foi conectado ou testado em um projeto Supabase real, nem na sua hospedagem. Faça revisão e testes reais antes de uso com dados pessoais.

## Fontes oficiais
- Preços e limites: https://supabase.com/pricing
- SMTP: https://supabase.com/docs/guides/auth/auth-smtp
- Segurança: https://supabase.com/docs/guides/database/postgres/row-level-security
- Configuração de URLs: https://supabase.com/docs/guides/auth/redirect-urls
- Preço Resend: https://resend.com/pricing
