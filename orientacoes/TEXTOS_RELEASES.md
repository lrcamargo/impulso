# Textos sugeridos para releases — Impulso

Copie o título e o texto da versão correspondente. Os textos descrevem o que cada pacote oferece; ajuste o status se alguma publicação ainda não tiver sido feita. A alpha.7 precisa de atualização de banco e teste real antes de ser anunciada como disponível.

## 0.1.0-alpha.4 — Mostrar e ocultar senhas

Adicionamos a opção de mostrar ou ocultar a senha durante a digitação, para facilitar o acesso e a criação ou alteração de senhas. Cada campo pode ser controlado separadamente e começa oculto.

Esta versão também inclui a edição de nome e e-mail dos alunos, apresentada na alpha.3. Se ela ainda não tiver sido instalada, consulte as instruções para atualização do Supabase e da função de edição.

## 0.1.0-alpha.5 — Grupos e demandas

Os alunos podem criar grupos, pesquisar e selecionar colegas cadastrados e enviar convites. Cada colega decide se aceita ou recusa antes de entrar no grupo.

Um integrante informa o nome e o link da demanda escolhida, e o professor complementa os demais dados. Os convites são exibidos na própria plataforma e o aluno vê apenas seu grupo. O cadastro da demanda é manual.

## 0.1.0-alpha.6 — Medalha Primeiro Acesso

Chegou a primeira conquista do Impulso! Após concluir a troca obrigatória da senha inicial, o aluno recebe a medalha Primeiro Acesso.

A atualização exige aplicação do SQL da alpha.6 no Supabase. A recuperação automática para alunos anteriores depende dos registros disponíveis; alguns casos precisam de conferência manual.

## 0.1.0-alpha.7 — Perfil, tarefas e avaliação de demandas

**Rascunho: publique depois da instalação e validação real.**

- Novo perfil do aluno com apelido de exibição, avatar de bichinho, grupo, troca de senha e espaço de medalhas.
- Tarefas para todos os grupos, com registro de entrega separado para cada equipe, inclusive grupos futuros.
- Avaliação de demandas pelo professor, com motivo quando não aprovadas, reenvio pelo grupo e histórico de avaliações.
- Validação de novos links no formato de demanda industrial da Saga e ajuste da expressão “na Saga”.
- Tratamento defensivo de dados incompletos no acesso, ainda sujeito à validação da conta que apresentou erro.

A versão exige o SQL alpha.7. Medalhas adicionais, concessão manual/automática, modo noturno e avisos de novidades seguem planejados; tarefas gerais ainda não geram pontos ou medalhas.

## 0.1.0-alpha.8 — Atividades, tarefas e medalhas

**Incluída nos arquivos da alpha.9.** O professor cria atividades; os grupos podem desmembrá-las em tarefas e atribuir integrantes. O professor cria e edita medalhas, vincula à atividade, escolhe concessão automática ou por aprovação e pode atribuí-las diretamente. O SQL da alpha.8 já foi executado segundo relato do professor; não o reaplique.

## 0.1.0-alpha.9 — Entregas por aluno ou grupo

**Rascunho: publique após instalar e validar no ambiente real.**

- Na criação ou edição de uma atividade, o professor pode escolher uma entrega pelo grupo ou uma entrega de cada integrante atual.
- O professor acompanha a situação de cada grupo e aluno e consulta perfil, demanda, medalhas e entregas dos estudantes.
- As imagens enviadas foram aplicadas às medalhas Primeiro Acesso, Primeiro Grupo, Demanda Cadastrada e Demanda Aprovada.
- A versão inclui a interface da alpha.8 e exige somente o novo SQL alpha.9, desde que a alpha.8 esteja aplicada.

**Ainda em desenvolvimento:** exclusão segura dos usuários de teste e seus dados; upload de arquivos ao Google Drive. Não foram implantados por esta versão.

## 0.1.0-alpha.10 — Pontos por atividade

**Rascunho: publique após instalar e validar no ambiente real.**

- O professor pode definir e editar a quantidade de pontos de cada atividade.
- Nas entregas individuais, cada aluno pontua ao entregar e o grupo pontua quando todos os integrantes atuais concluem. Nas entregas por grupo, o grupo pontua uma vez e cada integrante atual recebe o mesmo valor.
- O saldo individual considera o grupo atual. Alterações no valor e reabertura de entregas recalculam os pontos, inclusive de entregas anteriores.
- A regra anterior de 100 pontos é preservada para as atividades que já a utilizavam.

A atualização exige o SQL da alpha.10. Exclusão segura dos usuários de teste e upload ao Drive continuam pendentes.

## 0.1.0-alpha.11 — Filtros e acompanhamento visual

**Rascunho: publicar após instalar e testar.**

- Filtros de demandas por avaliação e dados complementados.
- Indicadores de tamanho de equipe com cores e texto.
- Entregas organizadas em cards por atividade, com situação por grupo e por integrante.
- Número da versão e autoria na interface.
- Issues anteriores reunidas e atualizadas em `orientacoes/TEXTOS_ISSUES.md`.

Arquivamento de equipes e demandas, reenvio de convites e upload de imagens para medalhas ainda não estão implementados. Não anunciaremos esses recursos como disponíveis antes de concluí-los e testá-los.

## 0.1.0-alpha.12 — Equipes, convites e medalhas

**Rascunho: publicar após instalar e validar no ambiente real.**

- Filtros de demanda em botões e equipes com contagem mais simples.
- Filtro de alunos sem grupo, alocação direta e limite de cinco integrantes no servidor.
- Lembretes de convites de equipe na plataforma e mensagem de acesso copiável.
- Catálogo das quatro medalhas de marco; medalhas criadas com ícone ou imagem pública no Storage.
- Versão e autoria centralizadas na interface.

Não inclui arquivamento de equipe/demanda, exclusão de medalhas, exclusão de usuários teste nem upload de entregas ao Drive. Requer dois SQLs novos e testes reais, especialmente das políticas do Storage.

Complemento da alpha.12: pesquisa administrativa de alunos e equipes, com indicação de convites pendentes para alunos sem grupo. Revisão das issues reais em `ISSUES_GITHUB_ALPHA12.md`.
