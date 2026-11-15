# Histórico de versões

Este arquivo registra alterações relevantes para cada versão. A convenção é baseada em versionamento semântico (SemVer), com pré-lançamentos identificados por `alpha` ou `beta`.

## 0.1.0-alpha.5 — grupos e demandas pelos alunos

### Incluído
- Ao criar o grupo, o aluno pode pesquisar e selecionar vários colegas, inclusive em buscas diferentes; os colegas recebem convites e só entram ao aceitar.
- A seleção trata falhas parciais e permite convidar mais tarde. Na página do grupo, o aluno pode cadastrar a demanda por nome e link; a professora complementa os dados.
- Testes de banco locais para convite, resposta, isolamento entre grupos e permissão de complementar demanda.

### Atenção
- O fluxo de grupos e demandas usa o backend existente; esta melhoria não exige SQL novo. O pacote é cumulativo e a edição de alunos da alpha.3 requer SQL e Edge Function quando ainda não instalados.
- Os testes foram locais e de navegador com rede simulada, não no Supabase ou site reais.

## 0.1.0-alpha.4 — mostrar e ocultar senhas

### Incluído
- Botão acessível para mostrar ou ocultar cada senha durante a digitação no login, cadastro de alunos, primeiro acesso, recuperação e alteração de senha.
- Cada campo começa oculto e pode ser alternado independentemente, sem enviar o formulário.

### Atenção
- Esta versão contém a funcionalidade de edição da alpha.3. Se ela ainda não estiver instalada, siga a migração e a implantação da função descritas no guia.
- Mostrar a senha não altera autenticação ou armazenamento: tenha cuidado com pessoas próximas ou compartilhamento de tela.

## 0.1.0-alpha.3 — correção de alunos cadastrados

### Incluído
- Edição do nome e do e-mail do aluno pelo professor responsável, com validação e preservação do grupo e da senha.
- Ao alterar o e-mail, a conta de autenticação também é atualizada pela função de servidor; o professor deve verificar o endereço por outro meio.
- Script de atualização do banco, função de servidor e testes locais para autorização, sincronização e recuperação de alteração interrompida.

### Atenção
- A atualização exige aplicar o SQL uma vez no banco existente e publicar a função `edit-student`; enviar arquivos ao GitHub não implanta esses componentes.
- Não há confirmação automática por e-mail: o professor deve verificar a identidade e o novo endereço. Em caso de falha parcial, repetir com os mesmos dados para concluir.
- Alterações foram testadas localmente e ainda precisam ser testadas no Supabase real antes de uso com alunos.

## 0.1.0-alpha.2 — solicitações de acesso e troca de senha inicial

### Incluído
- Solicitações de acesso sem criação automática de conta; o professor aprova ou recusa.
- Cadastro de aluno pelo professor com senha inicial, por uma função de servidor autenticada.
- Exigência de troca da senha inicial, diferente da senha anterior, antes de acessar as funções do grupo.
- Script de atualização do banco existente e novos testes locais de acesso e autenticação.

### Atenção
- A atualização depende da aplicação manual do SQL, da publicação da função no Supabase e do bloqueio de inscrições públicas diretas no Auth. Não altera o banco automaticamente.
- O fluxo de solicitação pública foi projetado para um único professor e ainda não tem CAPTCHA. Avalie proteção contra spam antes de abrir para uso amplo.
- Uma senha inicial igual para a turma permite tomada de conta antes do primeiro acesso, mesmo com troca obrigatória. Prefira senhas individuais.
- Testado localmente; implantação real e revisão de segurança ainda são necessárias.

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
