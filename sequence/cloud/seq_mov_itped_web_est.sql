-- conn as system@oraprod
revoke all privileges on lvirtual.seq_mov_itped_web_est to website;

create sequence website.seq_mov_itped_web_est minvalue 1 maxvalue 9999999999 start with 7000000000 increment by 1 nocache;

/*
-- conn as system@oraprod

-- SEQ_MOV_ITPED_WEB_EST
declare
  n_id number;
begin
  select nvl(last_number,0) + 1
  into   n_id
  from   dba_sequences 
  where  sequence_name = 'SEQ_MOV_ITPED_WEB_EST';
  
  drop sequence lvirtual.seq_mov_itped_web_est;
  
  execute immediate ' create sequence website.seq_mov_itped_web_est minvalue 1 maxvalue 999999999999999999999999999 start with ' || n_id || ' increment by 1 nocache ';
  
  create public synonym seq_mov_itped_web_est for website.seq_mov_itped_web_est;
  
  grant select to seq_mov_itped_web_est to public;
end;
*/