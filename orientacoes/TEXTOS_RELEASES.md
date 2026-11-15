# Textos sugeridos para releases — Impulso

Copie o título e o texto da versão correspondente. Os textos descrevem o que cada pacote oferece; ajuste o status se alguma publicação ainda não tiver sido feita. A alpha.7 precisa de atualização de banco e teste real antes de ser anunciada como disponível.

## 0.1.0-alpha.4 — Mostrar e ocultar senhas

Adicionamos a opção de mostrar ou ocultar a senha durante a digitação, para facilitar o acesso e a criação ou alteração de senhas. Cada campo pode ser controlado separadamente e começa oculto.

Esta versão também inclui a edição de nome e e-mail dos alunos, apresentada na alpha.3. Se ela ainda não tiver sido instalada, consulte as instruções para atualização do Supabase e da função de edição.

## 0.1.0-alpha.5 — Grupos e demandas

Os alunos podem criar grupos, pesquisar e selecionar colegas cadastrados e enviar convites. Cada colega decide se aceita ou recusa antes de entrar no grupo.

Um integrante informa o nome e o link da demanda escolhida, e a professora complementa os demais dados. Os convites são exibidos na própria plataforma e o aluno vê apenas seu grupo. O cadastro da demanda é manual.

## 0.1.0-alpha.6 — Medalha Primeiro Acesso

Chegou a primeira conquista do Impulso! Após concluir a troca obrigatória da senha inicial, o aluno recebe a medalha Primeiro Acesso.

A atualização exige aplicação do SQL da alpha.6 no Supabase. A recuperação automática para alunos anteriores depende dos registros disponíveis; alguns casos precisam de conferência manual.

## 0.1.0-alpha.7 — Perfil, tarefas e avaliação de demandas

**Rascunho: publique depois da instalação e validação real.**

- Novo perfil do aluno com apelido de exibição, avatar de bichinho, grupo, troca de senha e espaço de medalhas.
- Tarefas para todos os grupos, com registro de entrega separado para cada equipe, inclusive grupos futuros.
- Avaliação de demandas pela professora, com motivo quando não aprovadas, reenvio pelo grupo e histórico de avaliações.
- Validação de novos links no formato de demanda industrial da Saga e ajuste da expressão “na Saga”.
- Tratamento defensivo de dados incompletos no acesso, ainda sujeito à validação da conta que apresentou erro.

A versão exige o SQL alpha.7. Medalhas adicionais, concessão manual/automática, modo noturno e avisos de novidades seguem planejados; tarefas gerais ainda não geram pontos ou medalhas.
