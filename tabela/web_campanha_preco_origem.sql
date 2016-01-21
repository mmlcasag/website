
  CREATE TABLE WEB_CAMPANHA_PRECO_ORIGEM
   (	CODIGO NUMBER(10,0),
	CPR_ID NUMBER(10,0),
	ORIGEM NUMBER(10,0),
	 CONSTRAINT PK_CAMPANHA_PRECO_ORIGEM PRIMARY KEY (CODIGO),
	 CONSTRAINT FK_CPR_ID_ORIGEM FOREIGN KEY (CPR_ID) REFERENCES WEB_CAMPANHAS_PRECO (CPR_ID),
	 CONSTRAINT FK_ORIGEM FOREIGN KEY (ORIGEM) REFERENCES WEB_ORIGEM (CODIGO),
	 constraint uk_web_campanha_preco_origem unique (cpr_id,origem)
   );


insert into web_campanha_preco_origem select seq_camp_preco_origem.nextval, cpr_id, 1 from web_campanhas_preco;