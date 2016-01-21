create or replace view web_itnoivas as
select a.numero_da_lista lista
,      a.coditprod
,      nvl(a.qtde_sugerida,0) qtde_sugerida
,      nvl(a.qtde_comprada,0) qtde_comprada
,      nvl(a.qtde_reservada,0) qtde_reservada
from   produtos_da_lista a
where  not exists ( select p.numero_da_lista, p.coditprod
                    from   produtos_da_lista  p
                    where  p.numero_da_lista  = a.numero_da_lista
                    and    p.coditprod        = a.coditprod
                    having count(p.coditprod) > 1
                    group  by p.numero_da_lista, p.coditprod
                  ) ;