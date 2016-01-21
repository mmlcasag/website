-- armazena limitadores de rebate
-- 100 registros
create table web_rebate_limitador (
wrl_id number(10),
wrl_id_perfil number(3),
wrl_desconto_de number(5,2),
wrl_desconto_ate number(5,2),
wrl_desconto_por number(5,2),
primary key (wrl_id),
constraint fk_web_rebate_limitador_perfil 
   foreign key (wrl_id_perfil) references web_perfil(codigo) );
   
create unique index idx_web_rebate_limitador on web_rebate_limitador (wrl_id_perfil, wrl_desconto_de, wrl_desconto_ate, wrl_desconto_por);