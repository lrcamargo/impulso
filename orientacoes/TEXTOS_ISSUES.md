# Textos para organizar as issues do Impulso

Copie cada título e descrição para uma issue. Os status são sugeridos: **feche como concluída apenas se o resultado estiver confirmado no ambiente que você usa**. “Preparado” significa que há código e testes locais, não que já foi publicado ou validado no Supabase real. As issues antigas mencionadas abaixo são uma proposta de registro; não consultamos as issues existentes nem alteramos nenhuma delas.

## 1. Acesso da professora ao Impulso
**Status sugerido:** fechada — confirmado pela professora.

**Descrição:** Configurar o Supabase e vincular a conta da professora para acessar a plataforma.

**Resultado:** A professora confirmou que conseguiu acessar. Manter procedimentos de backup e segurança em acompanhamento.

## 2. Cadastro de alunos pela professora
**Status sugerido:** fechada para o problema relatado; demais testes de ponta a ponta continuam pendentes.

**Descrição:** Permitir que a professora cadastre alunos com uma senha inicial, sem expor credenciais administrativas no navegador.

**Resultado:** A função `create-student` foi recriada com o endpoint correto e a professora informou que o cadastro funcionou.

## 3. Problema no endpoint da função de cadastro
**Status sugerido:** fechada — problema relatado resolvido.

**Descrição:** Investigar erro genérico ao cadastrar aluno. A função aparecia com o nome `create-student`, mas a URL correspondia a outro identificador.

**Resultado:** Após recriar a função com a URL terminando em `/create-student`, a professora informou que funcionou. Verificar a URL correta caso o problema reapareça.

## 4. Solicitações de acesso e troca de senha inicial
**Status sugerido:** em validação.

**Descrição:** Registrar solicitações de acesso para aprovação ou recusa pela professora, sem criar a conta antes da aprovação. Exigir troca da senha inicial antes do uso da plataforma.

**Já preparado:** código e testes locais da alpha.2.

**Para concluir:** testar solicitação, aprovação, recusa, primeiro acesso e troca de senha no ambiente real. Avaliar proteção contra spam. A senha inicial compartilhada traz risco de acesso indevido antes de o aluno legítimo entrar; senhas individuais são mais seguras.

## 5. Editar nome e e-mail de alunos
**Status sugerido:** em validação.

**Descrição:** Permitir que a professora corrija o nome e o e-mail de login do aluno, preservando senha e vínculos.

**Já preparado:** alpha.3 e testes locais; arquivos identificados no repositório.

**Para concluir:** confirmar SQL e publicação da função `edit-student` no Supabase e testar no ambiente real. A professora deve verificar o novo endereço por outro meio.

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

**Descrição:** O integrante informa nome e link da demanda; a professora complementa descrição, benefícios, detalhamento, restrições, empresa, área e vigência.

**Já preparado:** fluxo manual na alpha.5; não há integração automática com SAGA nem campo de etapa.

**Para concluir:** testar cadastramento, visualização e permissões no Supabase e site reais.

## 9. Medalha Primeiro Acesso
**Status sugerido:** SQL aplicado e medalha corrigida segundo relato; continuar validação de casos anteriores.

**Descrição:** Conceder medalha individual ao aluno depois de confirmar a troca da senha inicial; exibi-la na visão geral, sem alterar os pontos.

**Já preparado:** alpha.6 com teste local e script de banco. A retroatividade automática é limitada aos casos com evidências recuperáveis; outros casos precisam de conferência.

**Para concluir:** a professora relatou que aplicou o SQL e corrigiu a medalha; conferir os casos anteriores cuja troca não pôde ser comprovada automaticamente.

## 10. Melhorar criação e acompanhamento de tarefas
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir as necessidades de criação, atribuição e acompanhamento de tarefas. Existe cadastro básico de atividades e prazos; identificar quais melhorias são necessárias antes de implementar.

## 11. Evoluir regras de pontuação
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir critérios, valores e visualização de pontos. Atualmente, marcar uma atividade como entregue gera 100 pontos para o grupo sem aprovação prévia.

## 12. Criar novas medalhas
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir outras medalhas além da Primeiro Acesso, seus critérios, quando serão concedidas e como serão exibidas.

## 13. Importar usuários
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir formato de importação, validação de dados, identificação de duplicidades, tratamento de erros e criação segura de contas. Não expor senhas ou chaves administrativas.

## 14. Evoluir o sistema de entregas
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir como alunos entregarão atividades e se a professora avaliará ou aprovará. Existe registro básico de situação, link e observações; fluxo de aprovação ainda não existe.

## 15. Pesquisar alunos e grupos
**Status sugerido:** aberta — planejamento.

**Descrição:** Criar uma forma de a professora pesquisar e localizar alunos e grupos. Definir filtros e informações exibidas, mantendo as regras de privacidade.

## 16. Identificar alunos sem grupo
**Status sugerido:** aberta — planejamento.

**Descrição:** Permitir que a professora identifique alunos que ainda não participam de um grupo, por exemplo com lista ou filtro. Definir como distinguir convites pendentes.

## 17. Modo noturno
**Status sugerido:** aberta — planejamento.

**Descrição:** Criar opção de interface escura com contraste acessível. Definir se a preferência acompanha o dispositivo ou a conta.

## 18. Analisar recursos extras
**Status sugerido:** aberta — levantamento.

**Descrição:** Levantar possíveis recursos adicionais, avaliar utilidade e prioridade com a professora e só depois definir sua implementação.

## 19. Revisão de segurança, privacidade e operação
**Status sugerido:** aberta — prioridade alta.

**Descrição:** Testar isolamento de grupos e permissões diretamente no Supabase real; revisar segurança e LGPD; estabelecer backup e recuperação; validar e-mail de recuperação e proteção contra spam. Usar contas de teste antes de dados reais.

# Novas issues a partir dos testes e solicitações

Os títulos e descrições abaixo estão prontos para copiar. O código da alpha.7 foi testado localmente, mas **não está confirmado no site real**; mantenha as funcionalidades preparadas em validação até concluir os testes. Não criamos ou fechamos issues automaticamente.

## 20. Validar login, logout e troca de senha
**Status sugerido:** fechada para o teste relatado, mantendo testes em outras contas.

**Descrição:** Verificar a troca obrigatória da senha inicial e o acesso posterior.

**Resultado:** A professora informou que uma conta de teste solicitou a troca de senha e conseguiu sair e entrar novamente com a nova senha.

## 21. Medalha de primeiro acesso não aparecia
**Status sugerido:** resolvida conforme teste relatado; manter verificação de casos anteriores.

**Descrição:** A medalha não apareceu inicialmente porque o SQL da alpha.6 ainda não havia sido executado.

**Resultado:** A professora executou o SQL e informou que conseguiu corrigir a medalha. Conferir retroatividade em casos nos quais o histórico não é comprovável.

## 22. Erro ao abrir a segunda conta de aluno
**Status sugerido:** aberta — em investigação e validação.

**Descrição:** A segunda conta mostrou `Cannot read properties of undefined (reading 'slice')` após o login. A professora confirmou que a conta estava cadastrada.

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

**Descrição:** Permitir que a professora aprove ou não aprove uma demanda. Ao não aprovar, exigir o motivo, apresentá-lo ao grupo e manter histórico. Quando o aluno mudar nome ou link, a demanda retorna para avaliação.

**Já preparado:** alpha.7; demandas existentes iniciam aguardando avaliação.

**Para concluir:** testar permissões, histórico, reprovação, reenvio e aprovação em contas reais de teste.

## 27. Criar tarefas para todos os grupos
**Status sugerido:** em validação.

**Descrição:** Permitir que a professora crie uma tarefa geral, com situação e entrega separadas por grupo, inclusive para grupos criados após a tarefa; manter tarefas vinculadas a uma demanda específica.

**Já preparado:** alpha.7. Entregas gerais ainda não geram pontos ou medalhas, e a edição/cancelamento da definição é uma evolução futura.

**Para concluir:** testar criação, grupos futuros, isolamento e registro das entregas no ambiente real.

## 28. Medalhas por grupo e demanda
**Status sugerido:** aberta — implementação pendente.

**Descrição:** Criar medalhas para entrar em grupo, cadastrar demanda e ter demanda aprovada. Definir se cada integrante atual ou futuro recebe cada conquista, a retroatividade e o que acontece se houver troca de grupo ou demanda.

## 29. Concessão automática e liberação de medalhas
**Status sugerido:** aberta — planejamento e implementação pendentes.

**Descrição:** Criar opção para medalhas concedidas automaticamente por critério ou liberadas/aprovadas pela professora; definir regras, histórico, revogação e permissão.

## 30. Medalhas por tarefas
**Status sugerido:** aberta — planejamento e implementação pendentes.

**Descrição:** Permitir associar determinadas atividades a medalhas, considerando se a concessão é automática ou depende da avaliação da professora. Definir o que conta como conclusão e como lidar com grupos futuros.

## 31. Cadastros de demandas do tipo desafio
**Status sugerido:** aberta — levantamento.

**Descrição:** Levantar exemplos de links e regras de demandas do tipo desafio e permitir cadastro seguro sem quebrar demandas industriais já existentes. Atualmente somente o formato industrial especificado é aceito em novos cadastros/edições.

## 32. Novidades no acesso
**Status sugerido:** aberta — planejamento.

**Descrição:** Definir uma área ou aviso de novidades por versão, apresentado ao aluno no acesso, com opção de marcar como lido e consultar depois. Planejar armazenamento mínimo e permissões.

## 33. Artes de medalhas
**Status sugerido:** aberta — aguardando imagens e integração.

**Descrição:** Produzir e aplicar imagens individuais e consistentes para Primeiro Acesso, Demanda Cadastrada, Demanda Aprovada e Primeiro Grupo. Usar os prompts em `PROMPTS_MEDALHAS.md` como ponto de partida. A alpha.7 usa ilustração provisória para a primeira medalha.

## 34. Modo noturno ativável
**Status sugerido:** aberta — planejamento.

**Descrição:** Criar opção para ativar/desativar modo escuro com contraste acessível e definir a persistência da preferência. Relacionar à issue anterior de modo noturno para evitar duplicação.
