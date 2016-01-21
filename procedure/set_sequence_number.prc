create or replace procedure set_sequence_number( p_sequence_name in varchar2 , p_sequence_value in number ) as
  n_aux number;
begin
  execute immediate ' select ' || p_sequence_value || ' - website.' || p_sequence_name || '.nextval from dual ' into n_aux;
  execute immediate ' alter sequence website.' || p_sequence_name || ' increment by ' || n_aux || ' ';
  
  execute immediate ' select website.' || p_sequence_name || '.nextval from dual ' into n_aux;
  execute immediate ' alter sequence website.' || p_sequence_name || ' increment by 1 ';
  
  dbms_output.put_line(n_aux);
end;
/
