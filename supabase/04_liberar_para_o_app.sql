-- Libera as tabelas para usuários logados (as regras de 01_estrutura.sql continuam valendo:
-- só quem está na tabela entregadores enxerga ou grava alguma coisa) e recarrega a API.
grant usage on schema public to authenticated;
grant select on public.entregadores, public.pessoas to authenticated;
grant select, insert, update, delete on public.entregas, public.bairros to authenticated;
grant execute on function public.eh_entregador() to authenticated;
notify pgrst, 'reload schema';

-- Conferência: deve mostrar 1955 pessoas e 2 entregadores
select (select count(*) from public.pessoas) as pessoas,
       (select count(*) from public.entregadores) as entregadores,
       (select count(*) from auth.users where email like '%@curriculos.local') as usuarios_criados;
