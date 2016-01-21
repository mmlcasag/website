create or replace procedure PROC_RETIRA_LOJA 
( p_codfil          in number
, p_transportadora out number
, p_diasmin        out number
, p_diasmax        out number 
) is
begin
  
  p_transportadora := 11;
  p_diasmin        := 3;
  p_diasmax        := 4;
  
end PROC_RETIRA_LOJA;
/
