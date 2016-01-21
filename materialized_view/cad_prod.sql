CREATE MATERIALIZED VIEW cad_prod
REFRESH FAST ON DEMAND
AS
SELECT codprod, codfam, codforne, codlinha, codgrupo, codsubgp, codcapac, digprod, descresum, qtpallets, flvendcomp
,      altura, largura, comp, codgercomp, pmargsup, pmarginf, pmargrent, cubagmax, unidade, especial, comissao
,      codicms, codicmred, codicmsub, aliqipi, vlipi, clasfisc, origem, ctf, difer, pesounit, pesoliq, foto, status
,      qtunestoque, codsupinf, qtdvolume, descricao, coduser, tsultalt, col_web_descricao, col_web_flcatalogo
,      col_web_flsite, col_web_nrofotos, col_web_dtalter, col_web_useralter, col_web_grupo, col_web_dtnovo, cubagem_incremental
FROM   colombo.cad_prod;
