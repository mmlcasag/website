-- conn as system@oraprod
revoke all privileges on colombo.seqcliente to website;

create sequence website.seqcliente minvalue 1 maxvalue 9999999999 start with 7000000000 increment by 1 nocache;

/*
-- conn as system@oraprod

-- SEQCLIENTE
declare
  n_id number;
begin
  select nvl(last_number,0) + 1
  into   n_id
  from   dba_sequences 
  where  sequence_name = 'SEQCLIENTE';
  
  drop sequence colombo.seqcliente;
  
  execute immediate ' create sequence website.seqcliente minvalue 1 maxvalue 999999999 start with ' || n_id || ' increment by 1 nocache ';
  
  create public synonym seqcliente for website.seqcliente;
  
  grant select to seqcliente to public;
end;
*/