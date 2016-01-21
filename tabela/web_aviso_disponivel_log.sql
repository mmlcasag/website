-- armazena os dados para avisar quando um produto esta disponivel
-- 500 registros por mes - Mandelli 08/11
CREATE TABLE web_aviso_disponivel_log (
  codigo NUMBER(15),
  codigo_aviso_disponivel number(15),
  prontuario NUMBER(10),
  hora_envio DATE,
  CONSTRAINT pk_aviso_disponivel_log PRIMARY KEY (codigo),
  CONSTRAINT fk_aviso_disponivel_log FOREIGN KEY (codigo_aviso_disponivel) REFERENCES web_aviso_disponivel(codigo)
);

-- Mandelli 08/11

ALTER TABLE WEB_AVISO_DISPONIVEL_LOG
ADD CONSTRAINT FK_WEB_AVISO_DISPONIVEL_CODIGO FOREIGN KEY 
(
 CODIGO
)
REFERENCES WEB_AVISO_DISPONIVEL
(
 CODIGO
)
ENABLE;
