# Issues do GitHub — revisão para alpha.12

Consulta às 53 issues públicas do repositório e seus 17 comentários, antes desta revisão da alpha.12. São **status sugeridos**, não uma alteração do GitHub. No momento da consulta, 48 estavam abertas e as #1, #2, #3, #19 e #21 estavam fechadas. A alpha.12 ainda não tinha sido instalada segundo relato. “Preparada” quer dizer código e testes locais; **não significa validada no site real**.

A issue #15 ganhou pesquisa por nome/e-mail/equipe na lista de alunos e pesquisa por nome da equipe/integrante na tela de equipes. O filtro de alunos sem grupo mostra também convites pendentes quando a nova função do banco está disponível. Somente o responsável vê essas pesquisas; a pesquisa de convite dos alunos continua com suas regras próprias de privacidade.

## Preparadas; validar antes de sugerir fechamento

| GitHub | Issue | Verificação para fechar |
|---|---|---|
| #4 | Solicitações e troca de senha | Validar pedido, aprovação, recusa, primeiro acesso e bloqueio real. A troca de senha funcionou numa conta; não prova o fluxo inteiro. |
| #5 | Editar nome e e-mail | Confirmar função e SQL instalados, alterar e-mail de teste e entrar com novo e-mail sem alterar senha e vínculos. |
| #6 | Mostrar/ocultar senha | Testar campos de login, cadastro e troca no site real. |
| #7 | Grupos e convites | Testar pesquisa, convites, aceite/recusa e isolamento entre grupos no Supabase real. |
| #8 | Cadastro e complemento da demanda | Testar aluno e responsável, campos e isolamento. Não existe importação automática da Saga. |
| #9 | Medalha Primeiro Acesso | Correção relatada como funcionando; conferir exibição e casos retroativos com evidência, sem presumir histórico desconhecido. |
| #10 | Criação e acompanhamento de tarefas | Testar criação/atribuição pelo grupo e tela de acompanhamento, com permissões reais. |
| #11 | Regras de pontuação | Testar valores, entregas e recálculo reais; a descrição antiga de 100 pontos fixos deve ser atualizada. |
| #15 | Pesquisar alunos e grupos | Testar pesquisa por nome/e-mail/equipe e por equipe/integrante; verificar que aluno não acessa a busca administrativa. |
| #16 | Identificar alunos sem grupo | Testar filtro, indicação de convite pendente e alocação direta; conferir isolamento. |
| #22 | Perfil e medalhas | Testar apelido, avatar, grupo, medalhas e troca de senha com aluno real. |
| #23 | Links de demandas industriais | Testar formatos válidos, inválidos e links antigos. A existência do link não é verificada automaticamente. |
| #24 | Texto “Abrir demanda na Saga” | Conferir o texto no site publicado. |
| #25 | Avaliação de demandas | Testar aprovação, reprovação com motivo, reenvio e histórico. |
| #26 | Tarefas para todos os grupos | Testar atividades gerais e situação independente em grupos atuais e futuros. |
| #27 | Medalhas por grupo e demanda | Testar os marcos, entrada, cadastro, aprovação e retroatividade recuperável. Histórico incerto não é inferido automaticamente. |
| #29 | Medalhas por tarefas/atividades | Testar vínculo de medalha à atividade e concessão conforme modo; uma subtarefa isolada não conclui a atividade. |
| #32 | Artes de medalhas | Confirmar as quatro artes e suas conquistas no site real. |
| #34 | Atividades e tarefas | Testar permissões de criação e atribuição de integrante do próprio grupo. |
| #35 | Entrega por grupo ou aluno | Testar os dois modos, mudança de integrantes e alteração da regra. |
| #36 | Acompanhar entregas | Conferir grupo, integrantes, links, observações e rótulo correto da entrega coletiva. |
| #37 | Painel do aluno | Conferir perfil, grupo, demanda, medalhas e entregas; testar acesso por outro responsável. |
| #38 | Medalhas e aprovações | Testar criar/editar, vincular, aprovação/recusa e atribuição individual. |
| #40 | Pontos configuráveis | Testar valor permitido, zero, valores inválidos e 100 pontos legados. |
| #41 | Pontuação individual e do grupo | Testar as duas modalidades e integrantes atuais em mais de um grupo. |
| #42 | Recálculo e grupo atual | Testar mudança de valor, reabertura e troca de grupo. |
| #43 | Exibir pontos | Comparar saldos em perfil, lista e equipes, verificando isolamento. |
| #46 | Reenviar convite de grupo | Testar lembrete dentro da plataforma, sem e-mail nem ingresso automático. |
| #48 | Filtro de demandas | Testar todos os botões; dados complementados são independentes da avaliação. |
| #49 | Indicador de equipe | Testar grupos com 1–2, 3–4 e 5 integrantes; aceite/alocação não podem exceder 5. |
| #51 | Visualização das entregas | Conferir cards, cores e textos, links, reabertura e celular. |
| #52 | Versão e autoria | Conferir versão alpha.12 e nome centralizados após instalar. |

## Parciais, divergentes ou ainda pendentes

| GitHub | Situação sugerida |
|---|---|
| #12 — Novas medalhas | Marcos e medalhas de atividade preparados; outras medalhas e critérios adicionais dependem de decisão. Não fechar como conclusão de todas as ideias. |
| #13 — Importar usuários | Não implementado; requer definição do formato, validação, duplicidades e criação segura. |
| #14 — Sistema de entregas | Registro por grupo/aluno preparado; envio ao Drive e avaliação da entrega seguem pendentes. |
| #17 e #33 — Modo noturno | Não implementado; parecem duplicadas, decidir qual manter. |
| #18 — Segurança, privacidade e operação | Aberta: faltam testes reais, backup/recuperação, e-mail e revisão de segurança/LGPD. |
| #20 — Medalha não aparece | Issue aberta sem descrição; a correção do caso relatado foi confirmada. Verificar se é duplicata da #9 antes de fechar. |
| #28 — Concessão automática e liberação | Automática e aprovação preparadas; revogação e regras históricas amplas ainda precisam de definição. |
| #30 — Demandas tipo desafio | Não implementado; faltam exemplos e regras. |
| #31 — Novidades no acesso | Não implementado. |
| #39 — Envio ao Drive | Não implementado; conexão da conversa não conecta o site. |
| #44 — Arquivar equipe | Não implementado; preservar histórico e liberar integrantes de forma segura. |
| #45 — Arquivar demanda | Não implementado; preservar histórico e não contar pontos enquanto arquivada. |
| #47 — Reenviar convite de acesso | A issue menciona e-mail; a escolha posterior foi mensagem copiável, sem envio automático. Atualizar descrição e validar antes de fechar. |
| #50 — Catálogo e imagens de medalhas | Upload público, edição e concessão preparados; exclusão de medalhas e limpeza segura de imagens órfãs continuam pendentes. |
| #53 — Erro vite/client | Orientação fornecida, mas falta confirmação na máquina local. |

## Também registrar ou vincular

- Não foi encontrada issue específica para a exclusão segura dos dois usuários de teste. Ela continua no backlog e nenhuma exclusão foi feita.
- A decisão de manter issues acumuladas e genéricas consta em `orientacoes/TEXTOS_ISSUES.md`; não identificamos issue específica no GitHub.
- Na #10 há comentário de pontuação que parece pertencer à #11; na #5 há comentário de mostrar/ocultar que parece pertencer à #6. Revisar manualmente se desejar.
- Os números acima são os números reais encontrados na consulta. Nenhuma issue foi aberta, modificada ou encerrada automaticamente.
