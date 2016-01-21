-- armazena as restrições de perfis por ip
-- 10 registros
create table Web_Perfil_Ip (
wpi_id number(10),
wpi_codPerfil number(3),
wpi_ip varchar2(15),
primary key (wpi_id),
constraint fk_webPerfilIp_codPerfil foreign key (wpi_codPerfil) references Web_Perfil (codigo));

create unique index idx_web_perfil_ip on Web_Perfil_ip (wpi_codPerfil, wpi_ip);  
  
create unique index idx_webPerfilIp_ip on web_perfil_ip (wpi_ip);