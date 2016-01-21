DROP SYNONYM fretes_transportadora;

CREATE MATERIALIZED VIEW fretes_transportadora
REFRESH FAST ON DEMAND
AS
SELECT codigo, descricao, codtransp, cubagem, ordem, razsoc, cgccpf, praca
,      flg_esales, ref_esales, dir_esales_exp, dir_esales_imp, url_rastreio
FROM   lvirtual.fretes_transportadora;
