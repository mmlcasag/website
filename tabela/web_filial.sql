-- mesma quantidade de registros da tabela colombo.cad_filial
/*
create table web_filial(
codigo number(10),
google_coordenadaslat number(20,10),
google_coordenadaslon number(20,10),
constraint pk_web_filial primary key (codigo));

RENAME WEB_FILIAL TO WEB_FILIAL_TMP;

drop table web_filial;

create table web_filial(
CODFIL NUMBER(3),
COL_TPFIL VARCHAR2(1),
CODREGIAO NUMBER(2),
STATUS NUMBER(1),
COL_FANTASIA VARCHAR2(30),
CGCCPF NUMBER(15),
ENDERECO VARCHAR2(40),
numero number(6),
COMPLEMENTO VARCHAR2(20),
BAIRRO VARCHAR2(20),
CIDADE VARCHAR2(60),
ESTADO CHAR(2),
CEP NUMBER(8),
DDD VARCHAR2(4),
FONE VARCHAR2(8),
FAX VARCHAR2(8),
CODFILDIST NUMBER(3),
COL_TPVENDA NUMBER(2) default 1,
DESC_TPVENDA VARCHAR2(60),
LATITUDE NUMBER(20,10),
longitude NUMBER(20,10),
ENDIP VARCHAR2(100),
CONSTRAINT PK_WEB_FILIAL_1 PRIMARY KEY (CODFIL));


INSERT INTO WEB_FILIAL 
  select cf.codfil, cf.col_tpfil, cf.codregiao, cf.status, initcap(cf.col_fantasia) col_fantasia, cf.cgccpf,
       initcap(cf.endereco) endereco, cf.numero, initcap(cf.complemento) complemento, initcap(cf.bairro) bairro, cf.cidade, cf.estado, cf.cep,
       CF.DDD, CF.FONE, CF.FAX, CF.CODFILDIST, TP.COL_TPVENDA, TP.DESC_TPVENDA, F.GOOGLE_COORDENADASLAT LATITUDE, F.GOOGLE_COORDENADASLON LONGITUDE, SUBSTR(TRIM(COL_ENDIP), 0, (INSTR(TRIM(COL_ENDIP), '.', -1)-1)) AS ENDIP
  from colombo.cad_filial cf, web_filial_tmp f, colombo.cad_filial_compl fc, colombo.cad_tpvenda tp
  where cf.col_tpfil in ('L', 'D')
  and nvl(cf.status, 0) = 0
  and nvl(cf.codregiao, 99) < 91
  and f.codigo (+) = cf.codfil
  and fc.codfil = cf.codfil
  AND tp.col_tpvenda = fc.col_tpvenda
 order by estado,cidade,codfil;
 
 grant all on web_filial to colombo;
*/

/*
ALTER TABLE WEB_FILIAL
ADD EXIBE_SITE CHAR(1) DEFAULT 'N';

ALTER TABLE WEB_FILIAL 
ADD CONSTRAINT CK_WEB_FILIAL_EXIBE CHECK (EXIBE_SITE IN('S', 'N'));

DECLARE
  CURSOR C1 IS
    SELECT * FROM WEB_FILIAL;
 V_INSERT    WEB_FILIAL%ROWTYPE;
 V_EXIBE_SITE CHAR(1) := 'N';
 BEGIN
  OPEN C1;
  LOOP
  FETCH C1 INTO V_INSERT;
  EXIT WHEN C1%NOTFOUND;
    IF(V_INSERT.COL_TPFIL IN ('L', 'D') AND NVL(V_INSERT.STATUS, 0) = 0 AND NVL(V_INSERT.CODREGIAO, 99) < 91) THEN
      V_EXIBE_SITE := 'S';
    ELSE 
      V_EXIBE_SITE := 'N';
    END IF;
    UPDATE WEB_FILIAL SET EXIBE_SITE = V_EXIBE_SITE WHERE CODFIL = V_INSERT.CODFIL;
  END LOOP;
  CLOSE C1;
END;  
*/

-- Projeto Retira Loja
alter table web_filial add praca_retira number(5);
alter table web_filial add fl_retira_tele char(1) default 'N';
alter table web_filial add fl_retira_tele char(1) default 'N';
