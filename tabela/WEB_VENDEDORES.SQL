-- MANDELLI
-- 100 mil registros
CREATE TABLE WEB_VENDEDORES(
PRONTUARIO  NUMBER(10) NOT NULL,
CODFIL      NUMBER(3) NOT NULL, 
NOME        VARCHAR2(30) NOT NULL,
DTNASC      DATE,
FUN_CARGO   NUMBER(5) NOT NULL,
GRUPO_CARGO NUMBER(4),
ATIVO       NUMBER(1) NOT NULL,
CONSTRAINT PK_WEB_VENDEDORES PRIMARY KEY (PRONTUARIO),
CONSTRAINT CK_WEB_VEN_ATIVO CHECK (ATIVO in (1,2,3)));

-- SCRIPT DE INICIALIZACAO
INSERT INTO WEB_VENDEDORES
SELECT DISTINCT a.fun_pront prontuario,
    a.fun_estab codfil,
    initcap(a.fun_nome) nome,
    a.fun_nascimento dtnasc,
    a.fun_cargo,
    b.grupo_cargo,
    a.fun_ativo ativo
  FROM vendedores a
  LEFT JOIN rem_grupos_cargos b
  ON a.fun_cargo      = b.car_cdicargo
  WHERE (A.FUN_CARGO IN (91621,61230,90348,90371)
  OR B.GRUPO_CARGO    IN(12,43));

--GRANT PARA TRIGGERS
grant all on web_vendedores to colombo;