-- conn as system@oraprod
revoke all privileges on colombo.seqcliente to website;

create sequence website.seqped minvalue 1 maxvalue 9999999999 start with 7000000000 increment by 1 nocache;

/*
-- conn as system@oraprod

-- SEQPED
declare
  n_id number;
begin
  select nvl(last_number,0) + 1
  into   n_id
  from   dba_sequences 
  where  sequence_name = 'SEQPED';
  
  drop sequence colombo.seqped;
  
  execute immediate ' create sequence website.seqped minvalue 1 maxvalue 99999999 start with ' || n_id || ' increment by 1 nocache ';
  
  create public synonym seqped for website.seqped;
  
  grant select to seqped to public;
end;
*/