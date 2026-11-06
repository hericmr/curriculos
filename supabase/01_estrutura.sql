-- Estrutura do app de entregas. Rode uma vez no SQL Editor do Supabase.
-- Ninguém lê nem grava nada sem estar logado E ter o e-mail na tabela entregadores.

create table if not exists public.entregadores (
  email text primary key,
  nome  text not null
);

create table if not exists public.pessoas (
  id      text primary key,
  nome    text not null,
  ende    text not null,
  bairro  text not null,
  cidade  text not null,
  cep     text,
  obs     text,
  lat     double precision,
  lng     double precision,
  prec    text,
  ordem   int,
  bid     text not null
);

create table if not exists public.entregas (
  pessoa_id text primary key references public.pessoas(id) on delete cascade,
  status    text not null check (status in ('entregue', 'voltar', 'nao')),
  por       text not null default (auth.jwt() ->> 'email'),
  em        timestamptz not null default now()
);

create table if not exists public.bairros (
  bid         text primary key,
  responsavel text not null default (auth.jwt() ->> 'email')
);

create or replace function public.eh_entregador() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.entregadores where email = auth.jwt() ->> 'email');
$$;
revoke all on function public.eh_entregador() from public, anon;
grant execute on function public.eh_entregador() to authenticated;

alter table public.entregadores enable row level security;
alter table public.pessoas      enable row level security;
alter table public.entregas     enable row level security;
alter table public.bairros      enable row level security;

-- só leitura para a lista de pessoas e de entregadores
drop policy if exists ler on public.entregadores;
create policy ler on public.entregadores for select to authenticated using (public.eh_entregador());
drop policy if exists ler on public.pessoas;
create policy ler on public.pessoas for select to authenticated using (public.eh_entregador());

-- entregas e bairros: os dois leem e gravam; cada marcação fica assinada com o e-mail de quem marcou
drop policy if exists ler on public.entregas;
create policy ler on public.entregas for select to authenticated using (public.eh_entregador());
drop policy if exists gravar on public.entregas;
create policy gravar on public.entregas for insert to authenticated
  with check (public.eh_entregador() and por = auth.jwt() ->> 'email');
drop policy if exists alterar on public.entregas;
create policy alterar on public.entregas for update to authenticated
  using (public.eh_entregador()) with check (por = auth.jwt() ->> 'email');
drop policy if exists apagar on public.entregas;
create policy apagar on public.entregas for delete to authenticated using (public.eh_entregador());

drop policy if exists ler on public.bairros;
create policy ler on public.bairros for select to authenticated using (public.eh_entregador());
drop policy if exists gravar on public.bairros;
create policy gravar on public.bairros for insert to authenticated
  with check (public.eh_entregador() and responsavel = auth.jwt() ->> 'email');
drop policy if exists alterar on public.bairros;
create policy alterar on public.bairros for update to authenticated
  using (public.eh_entregador()) with check (responsavel = auth.jwt() ->> 'email');
drop policy if exists apagar on public.bairros;
create policy apagar on public.bairros for delete to authenticated using (public.eh_entregador());

-- o papel anônimo (a chave pública da página) não enxerga nada
revoke all on public.entregadores, public.pessoas, public.entregas, public.bairros from anon;

-- marcações aparecem ao vivo no celular do outro
do $$ begin
  alter publication supabase_realtime add table public.entregas, public.bairros;
exception when duplicate_object then null; end $$;
