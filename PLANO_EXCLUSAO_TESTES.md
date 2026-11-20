# Exclusão segura dos usuários de teste

**Status: ainda não implementado. Nenhuma conta, grupo, demanda ou entrega foi apagada.**

O professor quer poder excluir os dois usuários de teste e tudo relacionado a eles; informou que eles só interagiram entre si. Antes de executar, é preciso confirmar isso no próprio banco e identificar exatamente as contas, pois grupos e atividades podem envolver outras pessoas.

## Proposta para implementação futura

1. Selecionar explicitamente os usuários de teste. Apresentar uma **prévia** com contas, perfis, grupos, demandas, entregas, tarefas, convites e medalhas afetados, sem excluir nada.
2. Bloquear a operação se um grupo ou outro dado a ser removido estiver relacionado a um aluno não selecionado ou houver vínculos que não possam ser identificados com segurança. Manter atividades gerais e medalhas do professor que também possam ser usadas por outros grupos.
3. Exigir backup e confirmação explícita de uma operação irreversível. Permitir que somente o professor responsável a inicie.
4. Coordenar a remoção dos dados do aplicativo e das contas do Supabase Auth por função de servidor autorizada, sem expor chaves administrativas ao navegador. Prever interrupções, falhas parciais, recuperação e repetição segura; não declarar sucesso até verificar o resultado.
5. Considerar registros históricos, e-mails, convites, entregas, dados da integração Drive (quando existir) e restrições legais/privacidade. Registrar o mínimo necessário para recuperação e definir sua retenção.
6. Testar primeiro em projeto e contas descartáveis, inclusive casos com usuários externos, concorrência e falhas.

Não tente apagar linhas ou contas isoladamente enquanto esse fluxo não estiver pronto: isso pode deixar dados órfãos ou remover informações compartilhadas. Se precisar fazer a limpeza antes, peça orientação para analisar o estado real e planejar uma operação específica com backup.
