create table agendamentos_uf (
uf varchar(2),
fl_ativo char(1) default 'N',
constraint pk_agendamentos_uf primary key (uf),
constraint ck_agendamentos_uf check (fl_ativo in ('S','N')));

insert into agendamentos_uf (uf,fl_ativo) values ('DF','N');
insert into agendamentos_uf (uf,fl_ativo) values ('AC','N');
insert into agendamentos_uf (uf,fl_ativo) values ('AL','N');
insert into agendamentos_uf (uf,fl_ativo) values ('AP','N');
insert into agendamentos_uf (uf,fl_ativo) values ('AM','N');
insert into agendamentos_uf (uf,fl_ativo) values ('BA','N');
insert into agendamentos_uf (uf,fl_ativo) values ('CE','N');
insert into agendamentos_uf (uf,fl_ativo) values ('ES','N');
insert into agendamentos_uf (uf,fl_ativo) values ('GO','N');
insert into agendamentos_uf (uf,fl_ativo) values ('MA','N');
insert into agendamentos_uf (uf,fl_ativo) values ('MT','N');
insert into agendamentos_uf (uf,fl_ativo) values ('MS','N');
insert into agendamentos_uf (uf,fl_ativo) values ('MG','N');
insert into agendamentos_uf (uf,fl_ativo) values ('PA','N');
insert into agendamentos_uf (uf,fl_ativo) values ('PB','N');
insert into agendamentos_uf (uf,fl_ativo) values ('PR','N');
insert into agendamentos_uf (uf,fl_ativo) values ('PE','N');
insert into agendamentos_uf (uf,fl_ativo) values ('PI','N');
insert into agendamentos_uf (uf,fl_ativo) values ('RJ','N');
insert into agendamentos_uf (uf,fl_ativo) values ('RN','N');
insert into agendamentos_uf (uf,fl_ativo) values ('RS','N');
insert into agendamentos_uf (uf,fl_ativo) values ('RO','N');
insert into agendamentos_uf (uf,fl_ativo) values ('RR','N');
insert into agendamentos_uf (uf,fl_ativo) values ('SC','N');
insert into agendamentos_uf (uf,fl_ativo) values ('SP','N');
insert into agendamentos_uf (uf,fl_ativo) values ('SE','N');
insert into agendamentos_uf (uf,fl_ativo) values ('TO','N')