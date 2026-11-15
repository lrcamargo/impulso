# Backlog — Impulso

Registro inicial do que já foi feito e do que falta verificar, organizado para atualizarmos a cada conversa. Prioridades e sugestões podem ser alteradas pela professora.

## Como ler os status

- **Confirmado em uso:** a professora relatou que funcionou no ambiente real.
- **Preparado:** está no código entregue e passou por testes locais, mas não há confirmação de instalação ou teste real.
- **A verificar:** depende de conferência no ambiente real.
- **Sugestão:** ideia para decidir, não é uma funcionalidade já combinada nem implementada.

## Já fizemos

| Item | Status | Observação |
|---|---|---|
| Planejamento e protótipo navegável | Concluído | Protótipo inicial separado da aplicação real. |
| Supabase e acesso da professora | Confirmado em uso | A professora confirmou que conseguiu acessar como professora. |
| Cadastro de aluno pela professora | Confirmado em uso | Após a correção da função de servidor, a professora informou que deu certo. |
| Solicitação de acesso com aprovação ou recusa | Preparado na alpha.2; teste real a confirmar | A solicitação não cria a conta automaticamente. |
| Troca obrigatória da senha inicial | Confirmado em teste real pela professora | A mesma senha inicial para todos foi escolhida, mas traz risco antes do primeiro acesso. |
| Edição de nome e e-mail do aluno | Arquivos alpha.3 no repositório; SQL e função a confirmar | Alterar o e-mail também altera o login. Depende de SQL e da função `edit-student`. |
| Mostrar e ocultar senha | Arquivos alpha.4 no repositório; publicação a confirmar | Botões nos campos de senha. |
| Grupos criados por alunos e convites | Arquivos alpha.5 no repositório; publicação a confirmar | Busca e seleção de colegas, com aceite ou recusa na plataforma. |
| Demanda por nome e link, complementada pela professora | Preparado na alpha.5; teste real a confirmar | Cadastro manual; sem integração automática com SAGA e sem campo de etapa. |
| Visão da professora de equipes e demandas | Preparado; teste real a confirmar | Menu **Equipes** e menu **Demandas**. A professora complementa as informações da demanda. |
| Atividades, prazos e registro de entregas | Preparado; teste real a confirmar | É possível registrar links e observações. |
| Mural e pontuação | Preparado; teste real a confirmar | Pontos são dados ao marcar entrega, sem aprovação da professora nesta versão. |
| Testes locais | Concluído para as versões preparadas | Testes de banco e navegador simulado não substituem testes no Supabase e site reais. |
| Medalha de primeiro acesso | SQL alpha.6 aplicado e medalha corrigida, segundo relato | Retroatividade automática limitada aos registros com evidências recuperáveis. |

## A fazer — prioridade alta

- [ ] **Confirmar quais versões estão instaladas.** A alpha.2 foi usada. O repositório contém alpha.3 e alpha.4; ainda é preciso confirmar publicação e componentes do Supabase. A alpha.6 está no repositório; a professora informou ter aplicado seu SQL e corrigido a medalha.
- [ ] **Instalar e testar a alpha.7**, preservando as configurações e seguindo o guia e o SQL novos. Para edição de alunos, seguir os passos de SQL e da função da alpha.3, se ainda não feitos. Não executar novamente o schema inicial no banco existente.
- [ ] **Testar grupos com contas de teste:** criar grupo, pesquisar e convidar colegas, aceitar e recusar, conferir integrantes e pendências.
- [ ] **Testar demandas com contas de teste:** aluno cadastra nome e link; professora visualiza e complementa todos os campos; integrante visualiza o resultado.
- [ ] **Conferir privacidade e permissões no projeto real:** aluno fora do grupo não deve ver grupo nem demanda; aluno não deve ver e-mail dos colegas ou editar campos exclusivos da professora. Verificar também acesso direto à API.
- [ ] **Validar acesso de alunos:** solicitação, aprovação/recusa, login, primeira troca de senha, recuperação e, se instalada, edição de nome/e-mail.
- [ ] **Testar atividades, prazos, mural e pontuação** com professora e alunos de teste.
- [ ] **Combinar e testar um procedimento de backup e recuperação**, além de revisar privacidade/LGPD e segurança antes de usar dados de alunos.
- [ ] **Avaliar o risco da senha inicial compartilhada:** uma pessoa que a conheça pode acessar a conta de um colega antes do primeiro acesso. A troca obrigatória não elimina esse risco; senhas individuais seriam mais seguras.


## Resultados do teste real e atualização alpha.7

- [x] A professora confirmou login, logout e troca de senha de uma conta de teste.
- [x] A professora executou o SQL da alpha.6 e informou que a medalha passou a funcionar.
- [ ] Investigar e testar novamente a segunda conta que mostrou `Cannot read properties of undefined (reading 'slice')`. A alpha.7 evita falhas de exibição em alguns campos ausentes, mas a causa real ainda não foi confirmada.
- [ ] Instalar e validar em ambiente real a alpha.7: perfil com apelido/avatar, medalhas no perfil, tarefas gerais, avaliação com feedback/histórico e link de demanda.
- [ ] Criar medalhas para cadastrar demanda, ter demanda aprovada e entrar em grupo, com imagens finais fornecidas pela professora.
- [ ] Definir e implementar concessão de medalhas automática ou sujeita à aprovação/liberação da professora, inclusive para determinadas atividades.
- [ ] Suportar demanda do tipo desafio: obter exemplos e definir regras; por enquanto o cadastro aceita o formato de demanda industrial informado.
- [ ] Planejar novidades ao acessar: registro de versões publicadas, aviso por usuário e opção “já vi”; preservar privacidade e prever volta para consultar novidades anteriores.
- [ ] Avaliar melhorias de perfil como foto opcional, acessibilidade dos avatares e preferências de privacidade; avaliar limites do plano antes de armazenar imagens de alunos.
- [ ] Evoluir tarefas gerais: edição, cancelamento, avaliação/aprovação e eventual concessão de pontos/medalhas. A alpha.7 registra entregas independentes, mas ainda não cria medalhas para tarefas.

## A fazer — operação e melhorias a decidir

- [ ] Verificar se recuperação e envio de e-mails funcionam para os destinatários esperados; avaliar SMTP adequado quando necessário.
- [ ] Definir proteção contra spam nas solicitações públicas, como CAPTCHA ou outra medida apropriada.
- [ ] Testar o uso em celulares e acessibilidade com pessoas usuárias.
- [ ] Definir como acompanhar erros e oferecer suporte às contas.

## Novos itens solicitados pela professora — a fazer

Os itens abaixo serão detalhados antes da implementação. Algumas funções básicas já existem na versão preparada, conforme indicado; o alcance das melhorias ainda será combinado.

- [ ] **Criação de tarefas:** definir como as tarefas deverão ser criadas e acompanhadas. Já existe um cadastro básico de atividades e prazos; verificar o que precisa ser ampliado.
- [ ] **Criação de pontuação:** definir as regras desejadas. Já existe uma pontuação básica de 100 pontos ao marcar uma atividade como entregue, sem aprovação da professora; avaliar como deve evoluir.
- [ ] **Criação de medalhas:** além da primeira medalha preparada na alpha.6, definir os próximos tipos, critérios para conquista e visualização.
- [ ] **Criação de importação de usuários:** definir formato dos dados, validações e como será feito o cadastro seguro dos alunos.
- [ ] **Criação de sistema de entregas de atividades:** definir o fluxo desejado, inclusive formatos e necessidade de avaliação. Atualmente há registro básico de situação, link e observações, mas não um fluxo de aprovação de entregas.
- [ ] **Análise de recursos extras:** levantar possibilidades e decidir com a professora quais fazem sentido para a plataforma.

## Novos itens solicitados — a fazer

- [ ] **Pesquisar aluno/grupo:** definir como a professora poderá localizar alunos e grupos. Já existe busca de colegas para convite; esta nova busca será planejada para o acompanhamento.
- [ ] **Identificar alunos sem grupo para a professora:** criar uma forma de visualizar ou filtrar alunos que ainda não participam de grupo.
- [ ] **Modo noturno:** permitir ativar/desativar uma opção de visualização escura.
- [ ] **Conferir medalhas retroativas:** verificar alunos antigos cuja troca não pôde ser comprovada automaticamente e, se apropriado, seguir o procedimento do guia alpha.6.

## Ideias futuras — ainda não aprovadas

- [ ] Avaliar se a professora deve aprovar entregas antes de gerar pontos.
- [ ] Avaliar notificações por e-mail ou outros canais para convites e prazos; atualmente convites aparecem dentro da plataforma.
- [ ] Avaliar anexos, se links não forem suficientes.

## Fora do escopo atual

- Integração automática com SAGA: a demanda é cadastrada manualmente por nome e link.
- Campo de etapa no cadastro da demanda: a professora pediu que não fosse incluído.

## Histórico de versões entregues

- **alpha.1:** base da aplicação e guia de configuração.
- **alpha.2:** cadastro de alunos com senha inicial, troca obrigatória e solicitações de acesso.
- **alpha.3:** edição de nome e e-mail do aluno.
- **alpha.4:** mostrar/ocultar senhas.
- **alpha.5:** fluxo facilitado para grupos, convites e cadastro da demanda.
- **alpha.6:** primeira medalha; professora informou ter executado o SQL e corrigido a medalha.
- **alpha.7:** perfil, avaliação de demanda, validação do link e tarefas gerais preparados; instalação e teste real pendentes.

Este backlog é um documento de trabalho; nenhum item pendente foi implantado ou aprovado apenas por estar listado aqui.
