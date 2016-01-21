-- promoção por bandeira de cartão 

create table web_campanhas_preco_bandeira (
cpb_id number(10) not null,
cpr_id number(10) not null,
bandeira number(10) not null,
prc_maxima number(2) not null,
constraint pk_web_camp_preco_bandeira primary key (cpb_id),
constraint fk_web_camp_preco foreign key (cpr_id) references web_campanhas_preco (cpr_id),
constraint fk_web_bandeira foreign key (bandeira) references web_bandeira(codbandeira))ry key  (codigo));

create unique index idx_campanha_preco_bandeira on web_campanhas_preco_bandeira (cpr_id, bandeira);

-- script de inicialização da tabela
declare
cursor campanhas is 
        select cpr_id 
        from web_campanhas_preco;
cursor bandeiras is
        select * from web_bandeira;
begin   
   for campanha in campanhas
     loop
        for bandeira in bandeiras    
           loop
              insert into web_campanhas_preco_bandeira (cpb_id, cpr_id, bandeira, prc_maxima)
                 values ((select nvl(max(cpb_id),0) + 1 from web_campanhas_preco_bandeira),
                          campanha.cpr_id, bandeira.codBandeira, 12);
           end loop;
     end loop;
end;