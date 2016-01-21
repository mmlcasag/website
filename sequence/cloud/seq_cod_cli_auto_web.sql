-- conn as system@oraprod
revoke all privileges on lvirtual.seq_cod_cli_auto_web to website;
  
create sequence website.seq_cod_cli_auto_web minvalue 1 maxvalue 9999999999 start with 7000000000 increment by 1 nocache;