create table web_itprod_brinde_parcelas (
codfil number(10),
codBrinde number(10),
tppgto number(3),
parcela number(2),
precoNormal number(15,2),
preco number(15,2),
primary key (codfil, codbrinde,tppgto,parcela),
constraint fk_brinde_parcela_codbrinde foreign key (codbrinde) references Web_ItProd_Brinde (cod_brinde),
constraint fk_brinde_parcela_tppgto foreign key (tppgto) references web_tppgto (tppgto)) 