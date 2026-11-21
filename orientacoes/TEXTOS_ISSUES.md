# Issues acumuladas do Impulso — atualização alpha.12

Copie cada título e descrição para uma issue. Os status são sugeridos: **feche como concluída apenas se o resultado estiver confirmado no ambiente que você usa**. “Preparado” significa que há código e testes locais, não que já foi publicado ou validado no Supabase real. As issues antigas mencionadas abaixo são uma proposta de registro; não consultamos as issues existentes nem alteramos nenhuma delas.

## 1. Acesso do professor ao Impulso
**Status sugerido:** fechada — confirmado pelo professor.

**Descrição:** Configurar o Supabase e vincular a conta do professor para acessar a plataforma.

**Resultado:** O professor confirmou que conseguiu acessar. Manter procedimentos de backup e segurança em acompanhamento.

## 2. Cadastro de alunos pelo professor
**Status sugerido:** fechada para o problema relatado; demais testes de ponta a ponta continuam pendentes.

**Descrição:** Permitir que o professor cadastre alunos com uma senha inicial, sem expor credenciais administrativas no navegador.

**Resultado:** A função `create-student` foi recriada com o endpoint correto e o professor informou que o cadastro funcionou.

## 3. Problema no endpoint da função de cadastro
**Status sugerido:** fechada — problema relatado resolvido.

**Descrição:** Investigar erro genérico ao cadastrar aluno. A função aparecia com o nome `create-student`, mas a URL correspondia a outro identificador.

**Resultado:** Após recriar a função com a URL terminando em `/create-student`, o professor informou que funcionou. Verificar a URL correta caso o problema reapareça.

## 4. Solicitações de acesso e troca de senha inicial
**Status sugerido:** em validação.

**Descrição:** Registrar solicitações de acesso para aprovação ou recusa pelo professor, sem criar a conta antes da aprovação. Exigir troca da senha inicial antes do uso da plataforma.

**Já preparado:** código e testes locais da alpha.2.

**Para concluir:** testar solicitação, aprovação, recusa, primeiro acesso e troca de senha no ambiente real. Avaliar proteção contra spam. A senha inicial compartilhada traz risco de acesso indevido antes de o aluno legítimo entrar; senhas individuais são mais seguras.

## 5. Editar nome e e-mail de alunos
**Status sugerido:** em validação.

**Descrição:** Permitir que o professor corrija o nome e o e-mail de login do aluno, preservando senha e vínculos.

**Já preparado:** alpha.3 e testes locais; arquivos identificados no repositório.

**Para concluir:** confirmar SQL e publicação da função `edit-student` no Supabase e testar no ambiente real. O professor deve verificar o novo endereço por outro meio.

## 6. Mostrar e ocultar senha
**Status sugerido:** em validação.

**Descrição:** Adicionar botão Mostrar/Ocultar aos campos de senha, sem enviar o formulário.

**Já preparado:** alpha.4; arquivos identificados no repositório e testes locais executados.

**Para concluir:** confirmar publicação e verificar os campos no site real.

## 7. Criar grupos e convidar colegas
**Status sugerido:** em validação.

**Descrição:** Permitir que alunos criem grupos, pesquisem colegas cadastrados e enviem convites. O colega deve aceitar ou recusar antes de entrar; o aluno não vê e-mails de colegas nem outros grupos.

**Já preparado:** fluxo aprimorado na alpha.5, com testes locais; arquivos identificados no repositório.

**Para concluir:** confirmar a publicação da versão e testar a criação, busca, convites, aceite, recusa e privacidade com contas reais de teste.

## 8. Cadastrar e complementar demanda
**Status sugerido:** em validação.

**Descrição:** O integrante informa nome e link da demanda; o professor complementa descrição, benefícios, detalhamento, restrições, empresa, área e vigência.

**Já preparado:** fluxo manual na alpha.5; não há integração automática com SAGA nem campo de etapa.

**Para concluir:** testar cadastramento, visualização e permissões no Supabase e site reais.

## 9. Medalha Primeiro Acesso
**Status sugerido:** SQL aplicado e medalha corrigida segundo relato; continuar validação de casos anteriores.

**Descrição:** Conceder medalha individual ao aluno depois de confirmar a troca da senha inicial; exibi-la na visão geral, sem alterar os pontos.

**Já preparado:** alpha.6 com teste local e script de banco. A retroatividade automática é limitada aos casos com evidências recuperáveis; outros casos precisam de conferência.

**Para concluir:** o professor relatou que aplicou o SQL e corrigiu a medalha; conferir os casos anteriores cuja troca não pôde ser comprovada automaticamente.

## 10. Melhorar criação e acompanhamento de tarefas
**Status sugerido:** em validação — criação e atribuição preparadas na alpha.9; a visualização foi melhorada na alpha.11. Testar em ambiente real.

**Descrição:** Atividades são criadas pelo responsável; o grupo desmembra tarefas e atribui integrantes. A alpha.11 melhora o acompanhamento de entregas; validar no ambiente real.

## 11. Evoluir regras de pontuação
**Status sugerido:** em validação — pontos configuráveis implementados na alpha.10; testar regras no ambiente real.

**Descrição:** Definir critérios, valores e visualização de pontos. Desde a alpha.10 o valor é configurável e o cálculo considera entregas e integrantes atuais; atividades legadas elegíveis mantêm 100 pontos.

## 12. Criar novas medalhas
**Status sugerido:** em validação — marcos e medalhas por atividade preparados na alpha.9; upload de imagens permanece pendente.

**Descrição:** Definir outras medalhas além da Primeiro Acesso, seus critérios, quando serão concedidas e como serão exibidas.

## 13. Importar usuários
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir formato de importação, validação de dados, identificação de duplicidades, tratamento de erros e criação segura de contas. Não expor senhas ou chaves administrativas.

## 14. Evoluir o sistema de entregas
**Status sugerido:** parcialmente preparado — registro individual e por grupo na alpha.9; upload e avaliação de entrega pendentes.

**Descrição:** Definir como alunos entregarão atividades e se o professor avaliará ou aprovará. Existe registro básico de situação, link e observações; fluxo de aprovação ainda não existe.

## 15. Pesquisar alunos e grupos
**Status sugerido:** em validação — pesquisa de alunos e equipes preparada na alpha.12; validar no site real.

**Descrição:** Pesquisa do responsável por nome, e-mail ou equipe na lista de alunos e por nome da equipe ou integrante na tela de equipes. O filtro de alunos sem grupo combina com a pesquisa. Alunos continuam sem acesso à lista administrativa.

## 16. Identificar alunos sem grupo
**Status sugerido:** em validação — filtro e alocação direta preparados na alpha.12; testar com contas reais.

**Descrição:** Permitir que o professor identifique alunos que ainda não participam de um grupo, por exemplo com lista ou filtro. Definir como distinguir convites pendentes.

## 17. Modo noturno
**Status sugerido:** aberta — planejamento.

**Descrição:** Criar opção de interface escura com contraste acessível. Definir se a preferência acompanha o dispositivo ou a conta.

## 18. Analisar recursos extras
**Status sugerido:** aberta — levantamento.

**Descrição:** Levantar possíveis recursos adicionais, avaliar utilidade e prioridade com o professor e só depois definir sua implementação.

## 19. Revisão de segurança, privacidade e operação
**Status sugerido:** aberta — prioridade alta.

**Descrição:** Testar isolamento de grupos e permissões diretamente no Supabase real; revisar segurança e LGPD; estabelecer backup e recuperação; validar e-mail de recuperação e proteção contra spam. Usar contas de teste antes de dados reais.

# Novas issues a partir dos testes e solicitações

Os títulos e descrições abaixo estão prontos para copiar. As funcionalidades antigas estão instaladas até a alpha.10 segundo relato, mas ainda exigem testes reais; mantenha as funcionalidades preparadas em validação até concluir os testes. Não criamos ou fechamos issues automaticamente.

## 20. Validar login, logout e troca de senha
**Status sugerido:** fechada para o teste relatado, mantendo testes em outras contas.

**Descrição:** Verificar a troca obrigatória da senha inicial e o acesso posterior.

**Resultado:** O professor informou que uma conta de teste solicitou a troca de senha e conseguiu sair e entrar novamente com a nova senha.

## 21. Medalha de primeiro acesso não aparecia
**Status sugerido:** resolvida conforme teste relatado; manter verificação de casos anteriores.

**Descrição:** A medalha não apareceu inicialmente porque o SQL da alpha.6 ainda não havia sido executado.

**Resultado:** O professor executou o SQL e informou que conseguiu corrigir a medalha. Conferir retroatividade em casos nos quais o histórico não é comprovável.

## 22. Erro ao abrir a segunda conta de aluno
**Status sugerido:** resolvida para o acesso relatado; causa não confirmada, monitorar se reaparecer.

**Descrição:** A segunda conta mostrou `Cannot read properties of undefined (reading 'slice')` após o login. O professor confirmou que a conta estava cadastrada.

**Já preparado:** tratamento defensivo de campos de nome ausentes na alpha.7.

**Para concluir:** repetir o teste no site após atualizar, verificar a resposta do banco e o ponto exato do erro. A causa real e a correção definitiva ainda não foram confirmadas. Não solicitar senha nem chave secreta para diagnóstico.

## 23. Perfil do aluno e visualização de medalhas
**Status sugerido:** em validação.

**Descrição:** Exibir nome, apelido de exibição, avatar pronto, grupo, opção de trocar senha e medalhas conquistadas.

**Já preparado:** alpha.7; apelido não altera o e-mail de login. Não há envio de fotos.

**Para concluir:** instalar o SQL e a interface, testar persistência, privacidade, troca de senha e a medalha em contas reais de teste.

## 24. Validar links de demandas industriais da Saga
**Status sugerido:** em validação.

**Descrição:** Aceitar no cadastro/edição o formato `https://plataforma.gpinovacao.senai.br/plataforma/demandas-da-industria/interna/` seguido apenas pelo número da demanda. Preservar links já cadastrados.

**Já preparado:** validação no servidor alpha.7 e indicação no formulário. Não há verificação da existência do link na plataforma externa.

**Para concluir:** testar formatos válidos e inválidos, além de links antigos, no ambiente real. O cadastro de demandas do tipo desafio é uma issue separada.

## 25. Corrigir texto para “Abrir demanda na Saga”
**Status sugerido:** em validação.

**Descrição:** Ajustar a expressão para o feminino.

**Já preparado:** alpha.7. Validar a apresentação no site publicado.

## 26. Avaliar demandas e registrar feedback
**Status sugerido:** em validação.

**Descrição:** Permitir que o professor aprove ou não aprove uma demanda. Ao não aprovar, exigir o motivo, apresentá-lo ao grupo e manter histórico. Quando o aluno mudar nome ou link, a demanda retorna para avaliação.

**Já preparado:** alpha.7; demandas existentes iniciam aguardando avaliação.

**Para concluir:** testar permissões, histórico, reprovação, reenvio e aprovação em contas reais de teste.

## 27. Criar tarefas para todos os grupos
**Status sugerido:** em validação.

**Descrição:** Permitir que o professor crie uma tarefa geral, com situação e entrega separadas por grupo, inclusive para grupos criados após a tarefa; manter tarefas vinculadas a uma demanda específica.

**Já preparado:** alpha.7. Na alpha.10 atividades gerais podem gerar pontos e medalhas e ser editadas; o cancelamento permanece pendente.

**Para concluir:** testar criação, grupos futuros, isolamento e registro das entregas no ambiente real.

## 28. Medalhas por grupo e demanda
**Status sugerido:** em validação — recursos principais preparados na alpha.9; testar regras no ambiente real.

**Descrição:** Criar medalhas para entrar em grupo, cadastrar demanda e ter demanda aprovada. Definir se cada integrante atual ou futuro recebe cada conquista, a retroatividade e o que acontece se houver troca de grupo ou demanda.

## 29. Concessão automática e liberação de medalhas
**Status sugerido:** em validação — recursos principais preparados na alpha.9; testar regras no ambiente real.

**Descrição:** Criar opção para medalhas concedidas automaticamente por critério ou liberadas/aprovadas pelo professor; definir regras, histórico, revogação e permissão.

## 30. Medalhas por tarefas
**Status sugerido:** em validação — recursos principais preparados na alpha.9; testar regras no ambiente real.

**Descrição:** Permitir associar determinadas atividades a medalhas, considerando se a concessão é automática ou depende da avaliação do professor. Definir o que conta como conclusão e como lidar com grupos futuros.

## 31. Cadastros de demandas do tipo desafio
**Status sugerido:** aberta — levantamento.

**Descrição:** Levantar exemplos de links e regras de demandas do tipo desafio e permitir cadastro seguro sem quebrar demandas industriais já existentes. Atualmente somente o formato industrial especificado é aceito em novos cadastros/edições.

## 32. Novidades no acesso
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir uma área ou aviso de novidades por versão, apresentado ao aluno no acesso, com opção de marcar como lido e consultar depois. Planejar armazenamento mínimo e permissões.

## 33. Artes de medalhas
**Status sugerido:** em validação — quatro imagens recebidas e integradas na alpha.9.

**Descrição:** Produzir e aplicar imagens individuais e consistentes para Primeiro Acesso, Demanda Cadastrada, Demanda Aprovada e Primeiro Grupo. Usar os prompts em `PROMPTS_MEDALHAS.md` como ponto de partida. As quatro artes recebidas foram incorporadas na alpha.9; conferir no site real.

## 34. Modo noturno ativável
**Status sugerido:** aberta — planejamento.

**Descrição:** Criar opção para ativar/desativar modo escuro com contraste acessível e definir a persistência da preferência. Relacionar à issue anterior de modo noturno para evitar duplicação.


# Registro complementar das issues da A9 — algumas detalham itens anteriores

Copie cada título e descrição para sua ferramenta de issues. “Preparado” significa testado localmente, não validado no site real. Nenhuma issue foi criada ou fechada automaticamente.

## A9-1. Segunda conta de aluno não conseguia acessar
**Status sugerido:** resolvida para o teste relatado; monitorar.

A segunda conta apresentou o erro `Cannot read properties of undefined (reading 'slice')`. O professor informou depois que conseguiu acessá-la. A causa exata não foi confirmada; registrar se o problema reaparecer, sem coletar senhas.

## A9-2. Instalar interface da alpha.8 e atualização alpha.9
**Status sugerido:** instalação confirmada até alpha.10; validação real funcional pendente.

O professor executou o SQL da alpha.8, mas não conseguiu baixar os arquivos. A alpha.9 traz os arquivos cumulativos e um novo SQL. Não executar novamente o SQL da alpha.8. Conferir backup, pré-requisitos, instalação e testes reais.

## A9-3. Atividades do professor e tarefas do grupo
**Status sugerido:** em validação.

Somente o professor cria e edita atividades. Alunos desmembram uma atividade em tarefas e designam integrantes do próprio grupo. O aluno vê suas atividades e as tarefas do grupo, sem uma seção separada de tarefas para todos.

**Já preparado:** interface e regras da alpha.8/9, testes locais de permissões.

**Critérios de aceite:** testar conta de professor e dois grupos no site real; confirmar que aluno não consegue criar atividade ou atribuir a pessoa de outro grupo.

## A9-4. Escolher entrega por grupo ou por aluno
**Status sugerido:** em validação.

Ao criar/editar a atividade, o professor escolhe se uma pessoa entrega pelo grupo ou se cada integrante atual precisa marcar a sua entrega. A situação é recalculada quando alguém entra ou sai.

**Já preparado:** alpha.9, testes locais de membros atuais e isolamento.

**Critérios de aceite:** testar ambos os modos, aluno pendente, entrada/saída e reinício das confirmações ao alterar a regra no ambiente real.

## A9-5. Acompanhar alunos e grupos que entregaram
**Status sugerido:** em validação.

O professor deve visualizar grupos e seus integrantes, com situação, link e observações. No modo por grupo, o rótulo deve informar que a entrega é do grupo e não fingir confirmação individual.

**Já preparado:** alpha.9; testar no site real com mais de um grupo.

## A9-6. Painel dos dados do aluno
**Status sugerido:** em validação.

O professor responsável pode consultar nome, e-mail, avatar, apelido, grupo, demanda, medalhas e atividades/entregas atuais pelo botão Ver perfil. O painel nunca apresenta senhas.

**Critérios de aceite:** validar dados e isolamento entre professores no Supabase real.

## A9-7. Medalhas e tela de aprovações
**Status sugerido:** em validação.

Permitir criar/editar medalhas, vincular uma medalha à atividade, escolher concessão automática ou mediante aprovação e atribuir uma medalha diretamente a um aluno. Conclusão de uma tarefa isolada não conclui a atividade.

**Já preparado:** alpha.8/9. Verificar aprovação, recusa, mudança de vínculo, entrega e concessão manual no ambiente real.

## A9-8. Artes e marcos das quatro medalhas
**Status sugerido:** em validação.

Usar as imagens recebidas para Primeiro Acesso, Primeiro Grupo, Demanda Cadastrada e Demanda Aprovada. Conceder as conquistas nos eventos correspondentes; recuperar apenas situações atuais comprováveis na atualização.

**Critérios de aceite:** testar visualização no perfil, eventos e retroatividade com contas de teste. Casos históricos sem vínculo atual precisam de análise separada.

## A9-9. Excluir os usuários de teste e seus dados
**Status sugerido:** aberta — prioridade alta; não implementada.

O professor quer excluir os dois usuários de teste e tudo relacionado a eles, inclusive perfis, grupos e demandas. Ela informou que eles só interagiram entre si.

**Critérios de aceite:** prévia de impacto, confirmação explícita e backup; bloquear quando houver dados de outra pessoa; coordenar Auth e banco com recuperação de falhas; preservar dados compartilhados fora da seleção e verificar no ambiente de teste. Nenhuma exclusão foi executada. Consulte `PLANO_EXCLUSAO_TESTES.md`.

## A9-10. Envio de arquivos ao Google Drive
**Status sugerido:** aberta — implementação pendente.

Criar envio de arquivos/fotos para uma pasta por atividade, com nome grupo + atividade + data, preservando a extensão. Conteúdo no Drive, não no banco; metadados mínimos no banco. Não permitir que a pasta compartilhada revele entregas de outros grupos. A conexão nesta conversa não conecta automaticamente o site. Consulte `PLANO_GOOGLE_DRIVE.md`.

## A9-11. Validação de uso com a turma
**Status sugerido:** aberta — prioridade alta.

Antes do anúncio geral, testar login, troca de senha, privacidade, grupos, convites, demanda e as novas regras com contas de teste. A senha inicial compartilhada ainda pode permitir que alguém acesse uma conta antes do titular; avaliar forma mais segura de acesso inicial.


# Registro complementar das issues da A10 — algumas detalham itens anteriores

Copie os títulos e descrições para suas issues. Os itens marcados como “em validação” foram preparados e testados localmente, mas ainda não foram confirmados no site real. Nenhuma issue foi criada ou fechada automaticamente.

## A10-1. Pontuação configurável por atividade
**Status sugerido:** em validação.

O professor deve informar e editar o valor de pontos de cada atividade, inclusive escolhendo zero. Preservar em 100 as atividades que já usavam a regra anterior.

**Critérios:** somente o professor pode definir os pontos; valores inteiros entre 0 e 1.000.000; o valor aparece na atividade e as regras são testadas no Supabase real.

## A10-2. Pontuação individual e do grupo
**Status sugerido:** em validação.

Na entrega individual, cada aluno pontua ao entregar e o grupo quando todos os integrantes atuais entregam. Na entrega por grupo, uma entrega dá o valor uma vez ao grupo e a cada integrante atual. A pontuação do grupo não é a soma dos saldos pessoais.

**Critérios:** testar as duas modalidades, situação pendente, múltiplos grupos e proteção contra acesso indevido. Pontos não dependem da aprovação da medalha nesta versão.

## A10-3. Recalcular pontos e considerar grupo atual
**Status sugerido:** em validação.

Ao alterar o valor de uma atividade ou reabrir uma entrega, recalcular os pontos anteriores. O saldo do aluno considera apenas seu grupo atual, conforme decisão do professor.

**Critérios:** testar mudança de valor, reabertura, entrada/saída e troca de grupo, incluindo valores antigos de 100 pontos.

## A10-4. Exibir pontos para professor e alunos
**Status sugerido:** em validação.

Mostrar pontuação individual na visão geral e perfil do aluno e para o professor na lista/perfil. Mostrar pontuação do grupo na tela de equipes ou Meu grupo.

**Critérios:** conferir os números e o isolamento entre alunos e professores no ambiente real.

## A10-5. Excluir usuários de teste e seus dados
**Status sugerido:** aberta — prioridade alta; não implementada.

Preparar exclusão segura dos dois usuários e dos dados exclusivos associados, com prévia, bloqueio de vínculos com terceiros, backup, confirmação e recuperação de falhas entre Auth e banco. Nenhuma exclusão foi realizada. Ver `PLANO_EXCLUSAO_TESTES.md` no projeto.

## A10-6. Upload de arquivos ao Drive
**Status sugerido:** aberta — não implementada.

Preparar envio para uma pasta por atividade, arquivos renomeados e controle para que um grupo não acesse a entrega de outro. O Drive conectado à conversa não conecta o site. Ver `PLANO_GOOGLE_DRIVE.md` no projeto.


# Solicitações registradas na alpha.11

## A11-1. Arquivar equipe e liberar integrantes
**Status sugerido:** aberta — prioridade alta; não implementada.

Permitir arquivar grupo sem apagar histórico, liberando os alunos para outro grupo. Definir restauração sem reingressar automaticamente pessoas que já estejam em outro grupo; preservar pontos, vínculos, entregas, convites e privacidade. Exigir prévia e confirmação; testar segurança e concorrência. Não confundir com a exclusão definitiva de usuários de teste.

## A11-2. Arquivar demanda e permitir nova demanda
**Status sugerido:** aberta — prioridade alta; não implementada.

Arquivar somente a demanda preservando histórico e mantendo a equipe ativa para cadastrar outra. Definir o destino de atividades, entregas e pontuação vinculadas e impedir exposição indevida. Prévia, confirmação e teste real.

## A11-3. Reenviar convite de grupo
**Status sugerido:** em validação — lembrete na plataforma implementado na alpha.12; não envia e-mail.

Lembrete marca o convite pendente para o aluno dentro da plataforma, sem duplicar convite, enviar e-mail ou efetuar entrada automática. Validar no site real.

## A11-4. Reenviar convite de acesso
**Status sugerido:** em validação — mensagem copiável implementada na alpha.12, enviada manualmente.

O responsável pode copiar uma mensagem sem senha e enviá-la individualmente. O site não envia e-mail e não comprova se o aluno já acessou.

## A11-5. Filtro de demandas
**Status sugerido:** em validação — botões arredondados preparados na alpha.12.

Filtros para aprovadas, reprovadas, aguardando avaliação e dados complementados; preenchimento é independente do estado de aprovação. Validar dados reais.

## A11-6. Indicador de composição da equipe
**Status sugerido:** em validação — interface preparada na alpha.11.

Verde para 5, vermelho abaixo de 3, amarelo para 3 ou 4, com texto e contagem. Confirmar com grupos reais.

## A11-7. Catálogo e imagens de medalhas
**Status sugerido:** em validação — ícones e upload de imagens pelo Storage preparados na alpha.12; exclusão pendente.

Criação, edição e concessão de medalhas com ícones ou imagens; bucket público no Supabase Storage e limite de 2 MiB. Revisar políticas existentes e testar isolamento real. Definir remoção de medalhas concedidas e gestão segura de arquivos órfãos. Sem binários no banco.

## A11-8. Visualização das entregas
**Status sugerido:** em validação — interface preparada na alpha.11.

Agrupar cards por atividade, com status por grupo e integrantes em texto e cor. Conferir links, reabertura, celulares e acessibilidade no site real.

## A11-9. Versão e autoria no site
**Status sugerido:** em validação — texto centralizado e versão atualizados na alpha.12.

Mostrar versão e autoria “Letícia Rosa Camargo” na interface. Confirmar após atualização.

## A11-10. Erro vite/client no VS Code
**Status sugerido:** aberta — orientação fornecida; confirmar na máquina local.

Executar `npm ci` na pasta do projeto com dependências de desenvolvimento instaladas e reiniciar o servidor TypeScript do VS Code. Diagnosticar Node/npm e instalação se persistir; não mudar configuração ou instalar tipos externos por suposição.

## A11-11. Issues acumuladas e linguagem genérica
**Status sugerido:** em validação.

Consolidar sugestões anteriores em um único arquivo, preservar referências históricas, sinalizar duplicadas e manter status atualizado a cada entrega. Não houve consulta nem alteração das issues do GitHub. Usar linguagem genérica nos documentos.

## A12-1. Exibir medalhas fixas no catálogo
**Status sugerido:** em validação — preparado na alpha.12.

Mostrar Primeiro Acesso, Primeiro Grupo, Demanda Cadastrada e Demanda Aprovada com arte e critérios. Não tratá-las como medalhas criadas editáveis.

## A12-2. Impor limite de cinco integrantes
**Status sugerido:** em validação — preparado na alpha.12.

Proteger aceite e alocação no servidor. Não remover automaticamente equipes preexistentes acima do limite. Testar concorrência real e comunicação ao aluno com convite pendente.

## A12-3. Arquivamento e pontuação
**Status sugerido:** aberta — não implementada.

Arquivar demanda preservando histórico e desconsiderando pontos de atividades vinculadas enquanto arquivada; permitir nova demanda na equipe ativa. Arquivar equipes preservando histórico e liberando alunos, sem reingresso automático ao restaurar. Planejar isolamento, reversão, concorrência, convites, tarefas, pontuação e medalhas. Relacionar às issues A11-1 e A11-2; não duplicar.

## Referência aos números do GitHub

A revisão das issues reais, com números e critérios, está em `ISSUES_GITHUB_ALPHA12.md`. Esses números não são necessariamente os mesmos da numeração histórica deste arquivo. Nenhuma alteração foi feita no GitHub.
