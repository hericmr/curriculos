# Entrega de currículos

App de celular para Heric e Giovanna dividirem bairros e marcarem a entrega dos currículos, com mapa do OpenStreetMap.

- A página (este repositório) não contém nenhum dado pessoal: pode ficar em hospedagem pública (GitHub Pages).
- A lista de pessoas e as marcações ficam no Supabase. Só abre para quem fizer login **e** tiver o e-mail na tabela `entregadores` (ver `supabase/01_estrutura.sql`).
- A pasta `dados-privados/` (lista com nomes e endereços) está no `.gitignore` e **nunca** deve ir para o GitHub.

## Configurar o Supabase (uma vez)

1. Crie um projeto em <https://supabase.com> (plano gratuito).
2. **SQL Editor** → cole e rode `supabase/01_estrutura.sql`.
3. Edite `dados-privados/02_entregadores.sql` com os e-mails reais dos dois e rode no SQL Editor.
4. Rode, um de cada vez, `dados-privados/03_pessoas_parte1.sql` a `parte4.sql`.
5. **Authentication → Sign In / Providers**: desligue **Allow new users to sign up**.
6. **Authentication → Users → Add user → Create new user**: crie Heric e Giovanna com os mesmos e-mails do passo 3 e uma senha para cada (marque *Auto Confirm User*).
7. **Project Settings → API**: copie a *Project URL* e a chave *anon public* para `config.js`.

## Publicar no GitHub Pages

```bash
git push origin main
```

No repositório: **Settings → Pages → Deploy from a branch → main / (root)**.

No celular: abra o link, entre com e-mail e senha e use **Adicionar à tela inicial** para abrir como app.
