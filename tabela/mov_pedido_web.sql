/*
  CREATE TABLE "MOV_PEDIDO_WEB" 
   (	"NUMPEDVEN" NUMBER(8,0) NOT NULL ENABLE, 
	"DIASENTMIN" NUMBER(3,0) NOT NULL ENABLE, 
	"DIASENTMAX" NUMBER(3,0) NOT NULL ENABLE, 
	"TRANSP" VARCHAR2(4000 BYTE), 
	"ENTREGAOK" CHAR(1 BYTE), 
	"PRONTUARIO_VENDEDOR" NUMBER(9,0), 
	"CODFIL_VENDEDOR" NUMBER(3,0), 
	"VLFRETE_REAL" NUMBER(15,2), 
	"CODEMAILMKT" NUMBER(10,0), 
	"BANCO" NUMBER(3,0), 
	"LOG_PEDIDO" VARCHAR2(4000 BYTE), 
	"FL_REFATURAMENTO" CHAR(1 BYTE), 
	"ORIGEM" VARCHAR2(20 BYTE), 
	"FL_EMAIL_AVALIACAO" CHAR(1 BYTE) DEFAULT 'N', 
	"COD_INTEGR_PORTAL" NUMBER(*,0), 
	 CONSTRAINT "MOV_PEDIDO_WEB_PK" PRIMARY KEY ("NUMPEDVEN")
  ;
 

  CREATE INDEX "MOV_PEDIDO_WEB_IDX_CODEMAILMKT" ON "MOV_PEDIDO_WEB" ("CODEMAILMKT");
 
  CREATE INDEX "MOV_PEDIDO_WEB_IDX_CODINTPORT" ON "MOV_PEDIDO_WEB" ("COD_INTEGR_PORTAL", "NUMPEDVEN");
 
  CREATE INDEX "MOV_PEDIDO_WEB_IDX_FILVENDR" ON "MOV_PEDIDO_WEB" ("CODFIL_VENDEDOR");
 
  CREATE INDEX "MOV_PEDIDO_WEB_IDX_PRONT_VEND" ON "MOV_PEDIDO_WEB" ("PRONTUARIO_VENDEDOR");
 
  CREATE UNIQUE INDEX "MOV_PEDIDO_WEB_PK" ON "MOV_PEDIDO_WEB" ("NUMPEDVEN");
 

  CREATE OR REPLACE TRIGGER "TRG_MOV_PED_WEB_BCO" 
  after insert on mov_pedido_web
  for each row
declare
  v_statment varchar2(500);
  v_existe number := 0;
  type cur is ref cursor;
  c cur;
begin
  if :new.banco is not null then
    v_statment := 'select count(1)
                     from bco_cta_ctb t2
                    where t2.numbco = :1';

    open c for v_statment using :new.banco;
    loop
      fetch c into v_existe;
       exit when c%notfound;
    end loop;
    close c;

    if v_existe <> 3 then
       send_mail('oracle'
              ,'conmaria@colombo.com.br'
              ,'Cadastro de Contas PCTB0043','Foi cadastrado um pedido com débito online para o banco ' ||:new.banco ||'. '|| chr(10) ||
               'É necessário cadastrar contas de crédito e débito para a contabilização.');
       send_mail('jacson@colombo.com.br','jacson@colombo.com.br','pct0043',:new.banco||'  '||v_existe);        
    end if;
  end if;
end trg_mov_ped_web_bco;
/
ALTER TRIGGER "TRG_MOV_PED_WEB_BCO" ENABLE;


alter table mov_pedido_web
add "COD_MOT_CANCELAMENTO" NUMBER(10,0);

ALTER TABLE mov_pedido_web
add constraint fk_mot_cancelamento FOREIGN KEY ("COD_MOT_CANCELAMENTO") REFERENCES "WEBSITE"."WEB_MOT_CANCELAMENTO" ("COD_MOT_CANCELAMENTO");


alter table mov_pedido_web add (
data_agendamento_entrega date,
turno_agendamento_entrega varchar2(100));

create index idx_mov_pedido_agendamento on mov_pedido_web(data_agendamento_entrega);

alter table mov_pedido_web
add (cod_frete_transportadora number(10),
constraint fk_fretes_transportadoras foreign key (cod_frete_transportadora) references fretes_transportadora (codigo));

-- Mandelli 13/08/2013 - Inclusão do campo versão
ALTER TABLE mov_pedido_web 
add versao_contrato varchar2 (10);
*/

/*
alter table mov_pedido_web
add jsession varchar2(1000);
*/

-- Marcio 27/02/2015 -- Projeto Central de Descontos
/*
alter table mov_pedido_web add numcupom varchar2(20);
alter table mov_pedido_web add tip_desc varchar2(20);
alter table mov_pedido_web add per_desc number(15,2);
alter table mov_pedido_web add vlr_desc number(15,2);
*/

-- Projeto Site na Nuvem
/*
grant select, update, insert, delete on mov_pedido_web to colombo;

----------

alter table mov_pedido_web add reg_expedicao varchar2(15);
alter table mov_pedido_web add numnota number(8);
alter table mov_pedido_web add serie varchar2(3);

----------

declare

  cursor c1 is
  select e.*
  from   MOV_ENTREGAS_TERC e, MOV_PEDIDO p
  where  p.numpedven = e.numpedven
  and    p.codfil = 400
  and    trunc(e.dt_criacao) >= '01/01/2015';
  
  n_cont number := 0;
  
begin
  
  for i in c1 loop
    n_cont := n_cont + 1;
    
    update mov_pedido_web
    set    reg_expedicao = i.reg_expedicao
    where  numpedven = i.numpedven;
    
    if n_cont >= 500 then
       n_cont := 0;
       commit ;
    end if;
  end loop;
  
  commit;
  
end;

----------

declare

  cursor c1 is
  select e.numnota, e.serie, e.numpedven
  from   MOV_saida e, MOV_PEDIDO p
  where  p.numpedven = e.numpedven
  and    p.codfil = 400
  and    p.tpnota = 52
  and    trunc(p.dtpedido) >= '01/01/2015';
  
  n_cont number := 0;
  
begin
  
  for i in c1 loop
    n_cont := n_cont + 1;
    
    update mov_pedido_web
    set    numnota = i.numnota
    ,      serie = i.serie
    where  numpedven = i.numpedven;
    
    if n_cont >= 500 then
       n_cont := 0;
       commit ;
    end if;
  end loop;
  
  commit;
  
end;
*/


/*
-- Projeto Site na Nuvem
alter table mov_pedido_web add hrnota date;
*/

alter table mov_pedido_web add constraint pk_mov_pedido_web primary key (NUMPEDVEN);