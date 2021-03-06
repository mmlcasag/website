CREATE TABLE WEB_CAMP_PRECO_BRINDES
(
   ID decimal(10,0) PRIMARY KEY NOT NULL,
   CAMPANHA_ID decimal(10,0) NOT NULL,
   BRINDE_ID decimal(10,0) NOT NULL,
   CPD_FLATIVO char(1),
   CONSTRAINT FK_CAMP_CAMPANHA_ID FOREIGN KEY(CAMPANHA_ID) REFERENCES WEB_CAMPANHAS_PRECO(CPR_ID),
   CONSTRAINT FK_CAMP_BRINDE_ID FOREIGN KEY(BRINDE_ID) REFERENCES WEB_ITPROD_BRINDE(COD_BRINDE)
);
CREATE UNIQUE INDEX WEB_CAMP_PRECO_BRINDES_PK ON WEB_CAMP_PRECO_BRINDES(ID);
CREATE INDEX WEB_CAMP_PRECO_BRINDES_IDX_1 ON WEB_CAMP_PRECO_BRINDES(CAMPANHA_ID);
CREATE INDEX WEB_CAMP_PRECO_BRINDES_IDX_3 ON WEB_CAMP_PRECO_BRINDES(BRINDE_ID);
CREATE INDEX WEB_CAMP_PRECO_BRINDES_IDX_2 ON WEB_CAMP_PRECO_BRINDES
(
  CAMPANHA_ID,
  BRINDE_ID
);

CREATE SEQUENCE WEB_CAMP_PRECO_BRINDES_SEQ
 START WITH     1
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;