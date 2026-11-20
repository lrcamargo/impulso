# Atualização 0.1.0-alpha.2 — cadastro aprovado e troca de senha

## Antes de começar
Esta atualização foi preparada a partir do commit público `a107009` do repositório, que inclui a correção de compilação. Ela não foi aplicada ao seu banco, ao GitHub ou à hospedagem. Nunca coloque `service_role`, chave secreta, senha do banco ou SMTP no código ou neste repositório.

**Leia todo o roteiro antes de alterar o sistema.** A atualização tem três partes: uma alteração do banco, uma função no servidor do Supabase e os arquivos da interface. Publicar somente o site não instala as outras partes. Use um projeto de teste/backup e uma janela de manutenção; não inicie com dados reais. O script é para um banco que já tenha o `schema.sql` da alpha.1, não para um banco vazio.

**Segurança:** a mesma senha para todos permite que alguém acesse a conta de outra pessoa antes que o verdadeiro aluno entre e altere a senha. A troca obrigatória NÃO resolve essa corrida. Recomendam-se senhas únicas, entregues individualmente; caso use uma senha comum, aceite e reduza esse risco, disponibilize por canal individual e não registre dados de alunos antes da revisão de segurança. Confira a identidade de cada solicitante antes de criar a conta. Ativar um e-mail administrativamente não comprova que a pessoa possui esse e-mail.

## 1. Preparação e segurança de inscrição
1. Confirme que está no projeto Supabase certo. Faça backup e conheça o procedimento de restauração; no plano gratuito não há backup automático incluído.
2. Em **Authentication → Sign In / Providers**, desative **Allow new users to sign up** (cadastro público direto no Supabase Auth). Mantenha **Confirm email** ativado: não confunda os dois controles. Logins existentes continuam; a função administrativa criará os novos usuários após aprovação, sem enviar e-mail. Se a interface do Supabase estiver diferente ou esse controle não estiver disponível, pare e peça orientação antes de continuar.
3. A tela de solicitação envia um pedido ao professor, mas não cria conta. No momento ela é destinada a um projeto com **um professor**; se houver mais de um, retorna um aviso e precisa ser configurada antes do uso.
4. O formulário público não tem CAPTCHA. Há apenas limites simples para duplicações e volume; eles não impedem spam ou ataques e podem bloquear pedidos legítimos. Para abrir a aplicação ao público ou usar dados reais, implemente proteção contra abuso/CAPTCHA e faça revisão de segurança.

## 2. Aplicar a atualização do banco
1. Abra **SQL Editor → New query** no projeto Supabase correto.
2. Copie o conteúdo de `database-updates/202611130001_access_requests.sql` e execute **uma única vez**. É uma alteração do banco existente; não execute novamente `supabase/schema.sql` e não apague tabelas.
3. Confirme que terminou sem erro. Se falhar, pare e guarde a mensagem do erro. O script usa transação; não continue até investigar.
4. O SQL renomeia a função anterior, bloqueia seu acesso direto e adiciona uma verificação de senha inicial no servidor. Até a interface e a função da etapa seguinte estarem instaladas, o cadastro antigo não funcionará. Contas antigas não são obrigadas a trocar a senha automaticamente.

## 3. Instalar a função de cadastro no Supabase
1. No mesmo projeto, abra **Edge Functions → Deploy a new function → Via Editor**.
2. Nomeie a função exatamente **`create-student`**.
3. Substitua o código do editor pelo conteúdo de `supabase/functions/create-student/index.ts` e publique a função. Mantenha a exigência de JWT/verificação de autenticação ligada; não desative a autenticação para contornar erros.
4. A função verifica no servidor se o usuário é professor antes de criar a conta, usa o cliente administrativo somente no servidor e não precisa de chave administrativa no navegador. Não cole chave secreta no código. A publicação da função não acontece só porque o arquivo está no GitHub.
5. Se um e-mail já existir em Authentication, a criação pode falhar. Verifique o cadastro existente no painel; não apague nem recrie contas de pessoas reais sem conferir as consequências.

O editor do Supabase oferece implantação pelo painel: https://supabase.com/docs/guides/functions/quickstart-dashboard

## 4. Atualizar o site versionado
Atualize apenas os arquivos entregues neste pacote na branch/repositório do projeto, preservando `src/config.js`, `.lovable/`, configurações do projeto e quaisquer correções posteriores. Não é necessário reescrever o histórico ou usar force push. Confirme que a última alteração do repositório ainda é compatível com a base indicada. Faça commit como `feat: aprovar acessos e exigir troca da senha inicial`; após testes, marque o pré-lançamento `v0.1.0-alpha.2`. A tag não foi criada automaticamente.

## 5. Testar sem usar dados reais
- Deslogue e envie uma solicitação com nome e e-mail de teste. Ela não deve criar conta nem enviar e-mail.
- Entre como professor e abra **Solicitações**. Aprove o pedido informando uma senha inicial de teste. Confira que só um professor autenticado pode chamar a função `create-student`.
- Em outro navegador, entre como aluno. Deve ser exigida uma nova senha diferente da inicial antes de ver qualquer dado. Teste continuar usando a senha inicial e tentar chamar a API diretamente: o acesso deve ser recusado. Troque a senha e confira que o acesso passa a funcionar.
- Teste o cadastro direto pelo professor, uma solicitação recusada, requisição duplicada, conta existente, dois grupos e acessos cruzados. Use apenas credenciais de teste sob seu controle e não as compartilhe aqui.
- Verifique que o cadastro direto no Supabase Auth está bloqueado; o aluno não pode escolher professor, criar conta sem aprovação, ler pedidos alheios ou contornar a tela de troca chamando `impulso_v1`.
- Monitore a função e possíveis falhas. Se a conexão cair durante o provisionamento, pode restar uma conta incompleta que requer análise manual em Authentication e no banco; não tente apagar usuários de produção sem conferir.

## Limitações
- O professor precisa digitar a senha inicial a cada cadastro e entregá-la ao aluno; o sistema não a envia. A mesma senha pode ser reutilizada, mas não é recomendável.
- A alteração obrigatória se aplica a contas criadas pela nova função, não a alunos já existentes.
- A tela de recuperação por e-mail continua dependendo de SMTP configurado. Sem SMTP, será necessário um processo administrativo de recuperação de conta; ele ainda não está implementado na aplicação.
- Com confirmação automática administrativa, a instituição deve verificar a identidade e o e-mail por outro processo. Não há prova de posse do endereço por e-mail.
- Os testes locais usam PostgreSQL simulado e respostas de rede simuladas. A função não foi implantada nem testada no seu projeto Supabase real. Faça revisão independente de segurança e privacidade antes de dados reais, especialmente se houver menores.
