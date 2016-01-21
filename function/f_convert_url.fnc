CREATE OR REPLACE FUNCTION F_CONVERT_URL( p_str IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC AS
  v_saida varchar2(4000);
BEGIN
  v_saida := trim(p_str);
  v_saida := TRANSLATE(v_saida,'áàãâéêíóõôúçÁÀÃÂÉÊÍÓÕÔÚÇ','aaaaeeioooucAAAAEEIOOOUC');
  v_saida := replace(v_saida, '''');
  v_saida := replace(v_saida, '&');
  v_saida := TRANSLATE(v_saida  ,'"/=-.,& ()','++++++++++');
  v_saida := replace(v_saida, 'º');
  v_saida := replace(v_saida, ':');
  v_saida := replace(v_saida, ';');
  v_saida := replace(v_saida, '?');
  v_saida := replace(v_saida, '!');
  v_saida := replace(v_saida, '_e_', '+');
  v_saida := replace(v_saida, '_-_', '+');
  while (instr(v_saida, '__') > 0) loop
    v_saida := replace(v_saida, '__', '+');
  end loop;
  while (instr(v_saida, '++') > 0) loop
    v_saida := replace(v_saida, '++', '+');
  end loop;

  RETURN v_saida;
END F_CONVERT_URL;
/
