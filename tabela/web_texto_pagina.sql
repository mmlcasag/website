 /*CREATE TABLE "WEBSITE"."WEB_TEXTO_PAGINA"
(
    CODABA  VARCHAR2(40 BYTE) NOT NULL,
    TITULO  VARCHAR2(60 BYTE) NOT NULL,
    USALTER NUMBER,
    DTALTER DATE,
    IDIOMA VARCHAR2(40 BYTE) NOT NULL,
    HTML CLOB,
    CODPAGINA NUMBER(6,0) NOT NULL,
    primary key (CODABA, IDIOMA),
    constraint web_texto_pagina_codpagina_fk foreign key (CODPAGINA) references web_pagina (CODPAGINA),
  )*/
  
  -- Thiago 19/03/2013 - alterado formato do campo usuário
  update web_texto_pagina set usalter = null;
  alter table web_texto_pagina modify usalter varchar2(100)

-- Thiago 29/07/2013 - adicionado relacao com link do rodape
alter table web_texto_pagina
add ( codigo_menu number(10),
      constraint fk_web_texto_pagina_link foreign key (codigo_menu) references web_link_rodape(codigo))

-- Joao 23/08/2013 - versão do texto
alter table web_texto_pagina add versao varchar2(10);
