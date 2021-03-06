--MANDELLI
-- 100 registros
CREATE TABLE WEB_FONTE(
CODFONTE  VARCHAR2(4) NOT NULL ,
DESCRICAO VARCHAR2(15), 
CODMIDIA  VARCHAR2(40),
CONSTRAINT PK_CAD_FONTE_WEB PRIMARY KEY (CODFONTE));

--SCRIPT INICIALIZACAO
INSERT INTO WEB_FONTE
  select codfonte, descricao, codmidia
from cad_fonteinf
where nvl(status,0) = 0;

-- GRANT PARA TRIGGERS
GRANT ALL ON WEB_FONTE TO COLOMBO;