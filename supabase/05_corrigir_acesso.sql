-- Corrige o acesso dos entregadores e mostra um diagnóstico.
-- 1) Cadastra como entregador cada conta criada em Authentication → Users (só existem as duas).
insert into public.entregadores (email, nome)
select lower(email), initcap(split_part(split_part(email, '@', 1), '_', 1))
from auth.users
where email is not null
on conflict (email) do nothing;
delete from public.entregadores where email like '%@exemplo.com';

-- 2) Garante as permissões de usuário logado (as regras de acesso continuam valendo).
grant usage on schema public to authenticated;
grant select on public.entregadores, public.pessoas to authenticated;
grant select, insert, update, delete on public.entregas, public.bairros to authenticated;
grant execute on function public.eh_entregador() to authenticated;
notify pgrst, 'reload schema';

-- 3) Diagnóstico: cada conta deve aparecer com eh_entregador = true, e pessoas = 1955.
select u.email,
       u.email_confirmed_at is not null as confirmada,
       exists (select 1 from public.entregadores e where e.email = u.email) as eh_entregador,
       (select count(*) from public.pessoas) as pessoas
from auth.users u;
