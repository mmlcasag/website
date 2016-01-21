-- conn as website
drop synonym web_rastreamento;

create or replace view web_rastreamento as
select b.codfil, a.numpedven pedido, a.reg_expedicao rastreamento, a.tipo
from   website.mov_pedido b, website.mov_entregas_terc a
where  a.numpedven = b.numpedven;

create public synonym web_rastreamento for website.web_rastreamento;
grant select on web_rastreamento to lvirtual;

-- conn as lvirtual
drop view lvirtual.web_rastreamento;


