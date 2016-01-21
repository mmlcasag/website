CREATE MATERIALIZED VIEW cad_forne
REFRESH FAST ON DEMAND
AS
SELECT codforne, digforne, codforneint, razsoc, fantasia, tpforne, tipoforne, natjur, cgccpf, inscricao, tpinsc, endereco, numero, bairro, cidade, estado, cep, praca, status, fl_venda_ec_bloqueada
FROM   colombo.cad_forne;
