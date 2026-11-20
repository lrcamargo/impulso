# Impulso — aplicação web

**Versão atual:** `0.1.0-alpha.10` (pré-lançamento). Consulte [CHANGELOG.md](CHANGELOG.md) e [VERSIONAMENTO.md](VERSIONAMENTO.md).

Aplicação web para equipes de alunos, demandas SAGA cadastradas manualmente, convites, tarefas, mural e pontuação. A interface usa Vite e JavaScript; o backend usa um projeto próprio Supabase com Auth e PostgreSQL.

## Primeiro passo
Siga **[GUIA_SUPABASE.md](GUIA_SUPABASE.md)**. Sem a configuração do banco e da chave pública, o aplicativo apresenta uma tela de configuração; não há modo demonstrativo com dados reais neste pacote.

## Arquivos principais
- `src/main.js`, `src/style.css`: interface e integração com Supabase.
- `src/config.js`: URL e chave publicável, preenchidas pelo responsável. Não inserir segredos.
- `supabase/schema.sql`: tabelas privadas, regras e função de acesso ao banco.
- `tests/db.test.mjs`: testes de banco executados localmente com PostgreSQL emulado PGlite.
- `GUIA_SUPABASE.md`: contas, SQL, professor, SMTP e testes antes da utilização.

## Executar localmente
Com Node.js 20 ou superior:

```bash
npm ci
npm run dev
```

Defina as credenciais públicas em `src/config.js` conforme o guia ou em um arquivo `.env` local a partir de `.env.example`. Para compilar, `npm run build`; para executar os testes locais, `npm test`. O resultado da compilação fica em `dist/`.

## Atenção
A aplicação precisa de um Supabase real configurado. O pacote não contém dados ou usuários do protótipo local anterior. Não contém senha, chave service_role ou SMTP. Testes locais não substituem revisão independente, testes reais de permissões e validação institucional antes de dados de alunos. A compatibilidade com o seu projeto e a hospedagem não foi testada.

## Atualização alpha.2
Leia [ATUALIZACAO_ALPHA2.md](ATUALIZACAO_ALPHA2.md) antes de atualizar o banco ou publicar o site. A migração é manual e a função de servidor também deve ser implantada.

## Atualização alpha.3
Leia [ATUALIZACAO_ALPHA3.md](ATUALIZACAO_ALPHA3.md) para instalar a edição de alunos no banco e na função de servidor.

## Atualização alpha.4
Veja [ATUALIZACAO_ALPHA4.md](ATUALIZACAO_ALPHA4.md) para instalar o botão de mostrar senha e, se necessário, a edição de alunos da versão anterior.

## Atualização alpha.5
Veja [ATUALIZACAO_ALPHA5.md](ATUALIZACAO_ALPHA5.md) para o novo fluxo de grupos e demandas e os passos para versões anteriores.

## Atualização alpha.6
Leia [ATUALIZACAO_ALPHA6.md](ATUALIZACAO_ALPHA6.md) para instalar a medalha de primeiro acesso e consultar as orientações.

## Atualização alpha.7
Leia [ATUALIZACAO_ALPHA7.md](ATUALIZACAO_ALPHA7.md) para instalar e testar perfil, tarefas gerais, avaliação e validação de demandas.

## Atualização alpha.8
Leia [ATUALIZACAO_ALPHA8.md](ATUALIZACAO_ALPHA8.md) para atualizar atividades, tarefas e medalhas. O envio de arquivos ao Google Drive ainda não está implementado.

## Atualização alpha.9
Leia [ATUALIZACAO_ALPHA9.md](ATUALIZACAO_ALPHA9.md) antes de instalar. Inclui a interface da alpha.8, entregas individuais ou por grupo e painel de alunos. Exclusão de usuários e upload ao Drive ainda não foram implementados.

## Atualização alpha.10
Leia [ATUALIZACAO_ALPHA10.md](ATUALIZACAO_ALPHA10.md) antes de instalar a pontuação configurável.
