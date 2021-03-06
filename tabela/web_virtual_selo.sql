CREATE TABLE "WEBSITE"."WEB_VIRTUAL_SELO" (
	"CODIGO" NUMBER(10,0) NOT NULL ENABLE,
	"SELO" NUMBER(6,0) NOT NULL ENABLE,
	"TIPO" CHAR(1 BYTE) NOT NULL ENABLE,
	"CODIGO_TIPO" NUMBER(10,0) NOT NULL ENABLE,
	"FL_ATIVO" CHAR(1 BYTE) DEFAULT 'S' NOT NULL ENABLE,
	CONSTRAINT "PK_WEB_VITUAL_SELO" PRIMARY KEY ("CODIGO"),
	CONSTRAINT "UK_WEB_VIRTUAL_SELO" UNIQUE ("SELO", "TIPO", "CODIGO_TIPO"),
	CONSTRAINT "FK_WEB_VIRT_SELO_SELO" FOREIGN KEY ("SELO") REFERENCES "WEBSITE"."WEB_SELO" ("CODIGO") ENABLE
);