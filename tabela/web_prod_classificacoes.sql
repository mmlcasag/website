/*
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Autor: Jucemar Vaccaro
	Data: 01/09/2008
	Estimativa de registros: 10
	OWNER: WEBSITE
*/

CREATE TABLE web_prod_classificacoes (
  pcl_id NUMBER(10) NOT NULL,
  pcl_txt_nome VARCHAR2(255),
  pcl_num_nota_min NUMBER(5,2),
  pcl_num_nota_max NUMBER(5,2),
  pcl_txt_especificacao VARCHAR2(4000),
  pcl_txt_imagemselo VARCHAR2(255),
  CONSTRAINT PCL_PK PRIMARY KEY(pcl_id)
);

-- INSERTING into WEB_PROD_CLASSIFICACOES
Insert into WEB_PROD_CLASSIFICACOES (PCL_ID,PCL_TXT_NOME,PCL_NUM_NOTA_MIN,PCL_NUM_NOTA_MAX,PCL_TXT_ESPECIFICACAO,PCL_TXT_IMAGEMSELO) values (10,'Sem Classficação',0,4,9,'Descrição Sem Classificação',null);
Insert into WEB_PROD_CLASSIFICACOES (PCL_ID,PCL_TXT_NOME,PCL_NUM_NOTA_MIN,PCL_NUM_NOTA_MAX,PCL_TXT_ESPECIFICACAO,PCL_TXT_IMAGEMSELO) values (1,'Diamante',9,10,'Descrição Diamante','selo_diamante.gif');
Insert into WEB_PROD_CLASSIFICACOES (PCL_ID,PCL_TXT_NOME,PCL_NUM_NOTA_MIN,PCL_NUM_NOTA_MAX,PCL_TXT_ESPECIFICACAO,PCL_TXT_IMAGEMSELO) values (2,'Ouro',7,1,8,9,'Descrição Ouro','selo_ouro.gif');
Insert into WEB_PROD_CLASSIFICACOES (PCL_ID,PCL_TXT_NOME,PCL_NUM_NOTA_MIN,PCL_NUM_NOTA_MAX,PCL_TXT_ESPECIFICACAO,PCL_TXT_IMAGEMSELO) values (3,'Prata',6,7,'Descrição Prata','selo_prata.gif');
Insert into WEB_PROD_CLASSIFICACOES (PCL_ID,PCL_TXT_NOME,PCL_NUM_NOTA_MIN,PCL_NUM_NOTA_MAX,PCL_TXT_ESPECIFICACAO,PCL_TXT_IMAGEMSELO) values (4,'Bronze',5,5,9,'Descrição Bronze','selo_bronze.gif');


-- atualização de registros para a nova classificação por estrelas
-- SOMENTE EXECUTAR QUANDO FOR PARA DEPLOY A VERSÃO DO PROJETO!!!!
update web_prod_classificacoes set pcl_num_nota_min = 5, pcl_num_nota_max = 5, pcl_txt_nome = 'Excelente' where pcl_id = 1;
update web_prod_classificacoes set pcl_num_nota_min = 4, pcl_num_nota_max = 4, pcl_txt_nome = 'Ótimo' where pcl_id = 2;
update web_prod_classificacoes set pcl_num_nota_min = 3, pcl_num_nota_max = 3, pcl_txt_nome = 'Bom' where pcl_id = 3;
update web_prod_classificacoes set pcl_num_nota_min = 2, pcl_num_nota_max = 2, pcl_txt_nome = 'Regular' where pcl_id = 4;
insert into web_prod_classificacoes values (5,'Ruim',1,1,'Descrição Ruim', 'ruim.gif');
update web_prod set nota = pkg_produto_avaliacao.avaliacao_nota_geral(codprod) where nota is not null;