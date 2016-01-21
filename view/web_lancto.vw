drop synonym web_lancto;

create or replace view web_lancto as
select codfil, numped pedido, numprc parcela, dtvcto vencimento, vallan valor
from   website.cxa_lancto
order  by numprc;
