--MANDELLI
-- TABELA REFERENCIA A CAD_CEP
-- 2 MILHOES DE REGISTROS
CREATE TABLE WEB_CEP(
CEP NUMBER(8) NOT NULL,
UF CHAR(2) NOT NULL,
LOCAL VARCHAR2(60),
BAIRRO VARCHAR2(144),
LOGRADOURO VARCHAR2(30),
ENDERECO VARCHAR2(108),
FL_LITORAL CHAR(1),
CONSTRAINT PK_WEB_CEP PRIMARY KEY (CEP));

INSERT INTO WEB_CEP
SELECT CEP, UF, LOCAL, BAIRRO, LOGRADOURO, ENDERECO, FL_LITORAL FROM CAD_CEP;

GRANT ALL ON WEB_CEP TO COLOMBO;