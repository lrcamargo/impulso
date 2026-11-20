# Issues sugeridas — alpha.10

Copie os títulos e descrições para suas issues. Os itens marcados como “em validação” foram preparados e testados localmente, mas ainda não foram confirmados no site real. Nenhuma issue foi criada ou fechada automaticamente.

## Pontuação configurável por atividade
**Status sugerido:** em validação.

A professora deve informar e editar o valor de pontos de cada atividade, inclusive escolhendo zero. Preservar em 100 as atividades que já usavam a regra anterior.

**Critérios:** somente a professora pode definir os pontos; valores inteiros entre 0 e 1.000.000; o valor aparece na atividade e as regras são testadas no Supabase real.

## Pontuação individual e do grupo
**Status sugerido:** em validação.

Na entrega individual, cada aluno pontua ao entregar e o grupo quando todos os integrantes atuais entregam. Na entrega por grupo, uma entrega dá o valor uma vez ao grupo e a cada integrante atual. A pontuação do grupo não é a soma dos saldos pessoais.

**Critérios:** testar as duas modalidades, situação pendente, múltiplos grupos e proteção contra acesso indevido. Pontos não dependem da aprovação da medalha nesta versão.

## Recalcular pontos e considerar grupo atual
**Status sugerido:** em validação.

Ao alterar o valor de uma atividade ou reabrir uma entrega, recalcular os pontos anteriores. O saldo do aluno considera apenas seu grupo atual, conforme decisão da professora.

**Critérios:** testar mudança de valor, reabertura, entrada/saída e troca de grupo, incluindo valores antigos de 100 pontos.

## Exibir pontos para professor e alunos
**Status sugerido:** em validação.

Mostrar pontuação individual na visão geral e perfil do aluno e para a professora na lista/perfil. Mostrar pontuação do grupo na tela de equipes ou Meu grupo.

**Critérios:** conferir os números e o isolamento entre alunos e professoras no ambiente real.

## Excluir usuários de teste e seus dados
**Status sugerido:** aberta — prioridade alta; não implementada.

Preparar exclusão segura dos dois usuários e dos dados exclusivos associados, com prévia, bloqueio de vínculos com terceiros, backup, confirmação e recuperação de falhas entre Auth e banco. Nenhuma exclusão foi realizada. Ver `PLANO_EXCLUSAO_TESTES.md` no projeto.

## Upload de arquivos ao Drive
**Status sugerido:** aberta — não implementada.

Preparar envio para uma pasta por atividade, arquivos renomeados e controle para que um grupo não acesse a entrega de outro. O Drive conectado à conversa não conecta o site. Ver `PLANO_GOOGLE_DRIVE.md` no projeto.
