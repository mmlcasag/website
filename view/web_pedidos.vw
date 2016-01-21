-- conn as website
CREATE OR REPLACE VIEW WEB_PEDIDOS AS
SELECT a.codfil,
    b.cgccpf,
    a.numpedven pedido,
    a.col_vlrguia AS VLICMRET,
    a.dtpedido,
    a.hrpedido,
    a.dtcancela,
    a.dtlibfat dtliberacao,
    CASE
      WHEN TRUNC(a.dtentrega) > TRUNC(a.dtpedido)
      THEN dataEntrega(a.dtentrega,NVL(e.diasentmax,0))
      ELSE dataEntrega(NVL(TRUNC(a.dtlibfat),a.dtpedido+1),NVL(e.diasentmax,3))
    END dtentrega,
    e.hrnota dtfaturamento,
    NVL(a.vldesconto,0) vldesconto,
    NVL(a.vlentrada,0) vlentrada,
    NVL(a.vlfrete,0) vlfrete,
    NVL(a.vlmercad,0) vlmercad,
    NVL(a.vljurosfin,0) vljuros,
    a.sitcarga situacao_carga,
    a.status,
    a.fllibfat liberacao_faturamento,
    NVL(a.qtprc,1) parcelas,
    NVL(a.vlprc,0) valorParcela,
    NVL(a.col_formapgto,DECODE(a.qtprc,1,5,1)) forma_pagto,
    NVL(a.col_admcartao,0) cartao,
    c.endereco,
    c.numero,
    c.complemento,
    c.bairro,
    c.cidade,
    c.estado,
    c.cep,
    c.refer referencia,
    c.dddfone1 dddres,
    c.fone1 foneres,
    c.ramalfone1 ramalres,
    c.dddfone2 dddcom,
    c.fone2 fonecom,
    c.ramalfone2 ramalcom,
    c.ddd dddcel,
    c.fone fonecel,
    a.col_numlistnoiva listanoiva,
    util.cut(a.obs,' -ENVIAR ',0) obs,
    a.cod_prontuario vendedor,
    e.diasentmin,
    e.diasentmax,
    a.filorig deposito,
    a.numcontrafin,
    a.digcontrafin,
    e.banco,
    e.codEmailMkt,
    a.praca,
    g.cgccpf cnpj_fatura,
    e.numnota numNota,
    e.fl_refaturamento refaturamento,
    a.numpedvenagrup pedidoagrup,
    e.data_agendamento_entrega,
    e.turno_agendamento_entrega,
    nvl(e.versao_contrato, a.versao_contrato_web) as versao_contrato,
    a.col_filent as codfil_retira,
    h.col_tpfil as tp_filial_entrega,
    a.vltotal,
    e.numcupom,
    a.dtlimite
  FROM website.mov_pedido a,
    website.cad_cliente b,
    website.cad_endcli c,
    website.mov_pedido_web e,
    website.cad_filial g,
    website.cad_filial h
  WHERE a.codcli  = b.codcli
  AND a.codcli    = c.codcli
  AND a.endent    = c.codend
  AND a.numpedven = e.numpedven(+)
  AND a.filorig   = g.codfil
  AND a.col_filent   = h.codfil(+)
  AND a.codfil    = 400
  AND A.tipoped
    ||'' = 0
  and a.tpnota
    ||'' = 52;
    
create or replace public synonym web_pedidos for website.web_pedidos;
grant select on web_pedidos to lvirtual;

-- conn as lvirtual
drop view lvirtual.web_pedidos;
