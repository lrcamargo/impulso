# Histórico de versões

Este arquivo registra alterações relevantes para cada versão. A convenção é baseada em versionamento semântico (SemVer), com pré-lançamentos identificados por `alpha` ou `beta`.

## 0.1.0-alpha.1 — versão inicial para configuração

### Incluído
- Interface web para professor e alunos, com autenticação por e-mail no Supabase.
- Cadastro de alunos pelo professor e formação de grupos com convites que precisam ser aceitos ou recusados.
- Cadastro manual do nome e link da demanda pelo grupo e complementação das informações pelo professor.
- Atividades, prazos, mural e pontuação por entregas.
- Esquema de banco, guia de configuração e testes locais de regras de acesso.

### Situação e limitações
- Pré-lançamento: compilado e testado localmente, mas ainda não validado no projeto Supabase real ou na hospedagem.
- Necessita configurar Supabase, confirmação de e-mail e SMTP; não utilizar com alunos reais até concluir testes de acesso e revisão de segurança.
- Não há importação automática do SAGA, envio de convites por e-mail, aprovação de entregas, anexos ou backup automático configurado.
