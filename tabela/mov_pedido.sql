create table mov_pedido as
select codfil, tipoped, numpedven, codvendr, tpped, filorig, local, condpgto
,      codcli, codtransp, dtpedido, dtcancela, dtentrega, endcob, endent, praca
,      vloutdesp, vldespfin, vldesconto, vlentrada, vlfrete, vlseguro, vlmercad
,      sitcarga, status, vljurosfin, tpnota, flfatura, vltotal, nome, codmodal
,      pjuros, vlvdvista, vliof, vlvdliq, digcontrafin, hrpedido, qtprc, tpfrete
,      numcontrafin, fllibfat, vltotalind, redutorbaseicms, obs, coduser, vlprc
,      identproc, vlmontagem, flinstalaterceiro, vlfreteterceiro, codcargo, flestat
,      regracreditscore, tpcontrato, seriecontrafin, vlirrf, codlista, codconvenio
,      codfunc, codfiltransffat, flentvar, vljuros, codclipublicidade, codendclipublicidade
,      vlpiscofinscsll, codfonte, pmargrent, vltotitemacum, numcontra, col_formapgto
,      col_admcartao, col_dtentregaant, col_numlistnoiva, cod_prontuario, cod_plan_cart
,      qtd_parc_cart, fllibfatant, condpgtofil, col_taxajuros, numpedvenagrup, codnatop
,      col_entregar_loja, col_aliquota, col_vlrguia, vlicmret, dtlimite, vldespaces
,      col_filent, versao_contrato_web, dtlibfat, dtalter, coduseralter, col_flencom
,      codfilsolic, tipopedsolic, numpedsolic, encomenda, col_seq_garantia, vloutras
,      dtlibcre, situatef, flos, col_litiner, endclipres, codclipres
from   colombo.mov_pedido@lnkproducao
where  codfil = 400
and    tpnota = 52
and    dtpedido >= '01/01/2015';

create index MOV_PEDIDO_FILDTPED on MOV_PEDIDO (CODFIL, DTPEDIDO);
create index MOV_PEDIDO_IDX_1 on MOV_PEDIDO (TPNOTA, PRACA, SITCARGA, STATUS, FILORIG, TPPED, DTENTREGA);
create index MOV_PEDIDO_IDX_CLINUMCONTRA on MOV_PEDIDO (CODCLI, NUMCONTRA);
create index MOV_PEDIDO_IDX_CLINUMPEDVEN on MOV_PEDIDO (CODCLI, NUMPEDVEN);
create index MOV_PEDIDO_IDX_CLI_DTPED on MOV_PEDIDO (CODCLI, DTPEDIDO);
create index MOV_PEDIDO_IDX_COD_PRONT on MOV_PEDIDO (COD_PRONTUARIO);
create index MOV_PEDIDO_IDX_CONDPG_DTPED on MOV_PEDIDO (CONDPGTO, DTPEDIDO);
create index MOV_PEDIDO_IDX_DTENT on MOV_PEDIDO (DTENTREGA);
create index MOV_PEDIDO_IDX_DTPEDFIL on MOV_PEDIDO (DTPEDIDO, CODFIL);
create index MOV_PEDIDO_IDX_FILCLISITSTAT on MOV_PEDIDO (CODFIL, CODCLI, STATUS, SITCARGA);
create index MOV_PEDIDO_IDX_FILCODPLANCART on MOV_PEDIDO (CODFIL, COD_PLAN_CART);
create index MOV_PEDIDO_IDX_FILDTCANC on MOV_PEDIDO (CODFIL, DTCANCELA);
create index MOV_PEDIDO_IDX_FILDTENT on MOV_PEDIDO (CODFIL, DTENTREGA);
create index MOV_PEDIDO_IDX_FILORIGNUMC on MOV_PEDIDO (FILORIG, NUMCONTRA);
create index MOV_PEDIDO_IDX_FILORIGNUMPED on MOV_PEDIDO (FILORIG, NUMPEDVEN);
create index MOV_PEDIDO_IDX_FILSTUSPAGTO on MOV_PEDIDO (CODFIL, STATUS, CONDPGTO);
create index MOV_PEDIDO_IDX_FILTPFLSTSIT on MOV_PEDIDO (CODFIL, TPNOTA, FLLIBFAT, STATUS, SITCARGA);
create index MOV_PEDIDO_IDX_FIL_NUMCONTRAF on MOV_PEDIDO (CODFIL, NUMCONTRAFIN);
create index MOV_PEDIDO_IDX_FIL_VENDR on MOV_PEDIDO (CODFIL, CODVENDR);
create index MOV_PEDIDO_IDX_NOIVAS on MOV_PEDIDO (CODFIL, COL_NUMLISTNOIVA);
create index MOV_PEDIDO_IDX_NUMCONTRAFIL on MOV_PEDIDO (NUMCONTRA, CODFIL);
create index MOV_PEDIDO_IDX_ORIGSTATDTENTRE on MOV_PEDIDO (FILORIG, STATUS, FLLIBFAT, DTENTREGA);
create index MOV_PEDIDO_IDX_ORIGSTATSIT on MOV_PEDIDO (FILORIG, STATUS, SITCARGA);
create index MOV_PEDIDO_IDX_ORIG_DTENTREGA on MOV_PEDIDO (FILORIG, DTENTREGA);
create index MOV_PEDIDO_IDX_PEDVEN on MOV_PEDIDO (NUMPEDVEN);
create index MOV_PEDIDO_IDX_PED_AGR on MOV_PEDIDO (CODFIL, NUMPEDVENAGRUP);
create index MOV_PEDIDO_IDX_PRACADTENT on MOV_PEDIDO (PRACA, DTENTREGA);
create index MOV_PEDIDO_IDX_SITCARGA on MOV_PEDIDO (STATUS, SITCARGA);
create index MOV_PEDIDO_IDX_TPNOTANUMCONTRA on MOV_PEDIDO (TPNOTA, NUMCONTRA);

alter table MOV_PEDIDO add constraint MOV_PEDIDO_PK primary key (CODFIL, TIPOPED, NUMPEDVEN);
  
alter table MOV_PEDIDO add check ("CODFIL" IS NOT NULL);
alter table MOV_PEDIDO add check ("TIPOPED" IS NOT NULL);
alter table MOV_PEDIDO add check ("NUMPEDVEN" IS NOT NULL);
alter table MOV_PEDIDO add check ("TPPED" IS NOT NULL);