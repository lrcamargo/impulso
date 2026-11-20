# Issues sugeridas — alpha.9

Copie cada título e descrição para sua ferramenta de issues. “Preparado” significa testado localmente, não validado no site real. Nenhuma issue foi criada ou fechada automaticamente.

## 1. Segunda conta de aluno não conseguia acessar
**Status sugerido:** resolvida para o teste relatado; monitorar.

A segunda conta apresentou o erro `Cannot read properties of undefined (reading 'slice')`. O professor informou depois que conseguiu acessá-la. A causa exata não foi confirmada; registrar se o problema reaparecer, sem coletar senhas.

## 2. Instalar interface da alpha.8 e atualização alpha.9
**Status sugerido:** em validação.

O professor executou o SQL da alpha.8, mas não conseguiu baixar os arquivos. A alpha.9 traz os arquivos cumulativos e um novo SQL. Não executar novamente o SQL da alpha.8. Conferir backup, pré-requisitos, instalação e testes reais.

## 3. Atividades do professor e tarefas do grupo
**Status sugerido:** em validação.

Somente o professor cria e edita atividades. Alunos desmembram uma atividade em tarefas e designam integrantes do próprio grupo. O aluno vê suas atividades e as tarefas do grupo, sem uma seção separada de tarefas para todos.

**Já preparado:** interface e regras da alpha.8/9, testes locais de permissões.

**Critérios de aceite:** testar conta de professor e dois grupos no site real; confirmar que aluno não consegue criar atividade ou atribuir a pessoa de outro grupo.

## 4. Escolher entrega por grupo ou por aluno
**Status sugerido:** em validação.

Ao criar/editar a atividade, o professor escolhe se uma pessoa entrega pelo grupo ou se cada integrante atual precisa marcar a sua entrega. A situação é recalculada quando alguém entra ou sai.

**Já preparado:** alpha.9, testes locais de membros atuais e isolamento.

**Critérios de aceite:** testar ambos os modos, aluno pendente, entrada/saída e reinício das confirmações ao alterar a regra no ambiente real.

## 5. Acompanhar alunos e grupos que entregaram
**Status sugerido:** em validação.

O professor deve visualizar grupos e seus integrantes, com situação, link e observações. No modo por grupo, o rótulo deve informar que a entrega é do grupo e não fingir confirmação individual.

**Já preparado:** alpha.9; testar no site real com mais de um grupo.

## 6. Painel dos dados do aluno
**Status sugerido:** em validação.

O professor responsável pode consultar nome, e-mail, avatar, apelido, grupo, demanda, medalhas e atividades/entregas atuais pelo botão Ver perfil. O painel nunca apresenta senhas.

**Critérios de aceite:** validar dados e isolamento entre professores no Supabase real.

## 7. Medalhas e tela de aprovações
**Status sugerido:** em validação.

Permitir criar/editar medalhas, vincular uma medalha à atividade, escolher concessão automática ou mediante aprovação e atribuir uma medalha diretamente a um aluno. Conclusão de uma tarefa isolada não conclui a atividade.

**Já preparado:** alpha.8/9. Verificar aprovação, recusa, mudança de vínculo, entrega e concessão manual no ambiente real.

## 8. Artes e marcos das quatro medalhas
**Status sugerido:** em validação.

Usar as imagens recebidas para Primeiro Acesso, Primeiro Grupo, Demanda Cadastrada e Demanda Aprovada. Conceder as conquistas nos eventos correspondentes; recuperar apenas situações atuais comprováveis na atualização.

**Critérios de aceite:** testar visualização no perfil, eventos e retroatividade com contas de teste. Casos históricos sem vínculo atual precisam de análise separada.

## 9. Excluir os usuários de teste e seus dados
**Status sugerido:** aberta — prioridade alta; não implementada.

O professor quer excluir os dois usuários de teste e tudo relacionado a eles, inclusive perfis, grupos e demandas. Ela informou que eles só interagiram entre si.

**Critérios de aceite:** prévia de impacto, confirmação explícita e backup; bloquear quando houver dados de outra pessoa; coordenar Auth e banco com recuperação de falhas; preservar dados compartilhados fora da seleção e verificar no ambiente de teste. Nenhuma exclusão foi executada. Consulte `PLANO_EXCLUSAO_TESTES.md`.

## 10. Envio de arquivos ao Google Drive
**Status sugerido:** aberta — implementação pendente.

Criar envio de arquivos/fotos para uma pasta por atividade, com nome grupo + atividade + data, preservando a extensão. Conteúdo no Drive, não no banco; metadados mínimos no banco. Não permitir que a pasta compartilhada revele entregas de outros grupos. A conexão nesta conversa não conecta automaticamente o site. Consulte `PLANO_GOOGLE_DRIVE.md`.

## 11. Validação de uso com a turma
**Status sugerido:** aberta — prioridade alta.

Antes do anúncio geral, testar login, troca de senha, privacidade, grupos, convites, demanda e as novas regras com contas de teste. A senha inicial compartilhada ainda pode permitir que alguém acesse uma conta antes do titular; avaliar forma mais segura de acesso inicial.
