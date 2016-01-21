create or replace procedure verifica_modulo_11_web
( pnumero     in varchar2
, pnumerodig out varchar2
) is
  
  v_filial   number := 0;
  v_numero   varchar2(20);
  v_soma     number := 0;
  v_posicao  number := 2;
  v_cont     number := 1;
  resto      number := 0;
  
begin
  
  v_filial := '998';
  v_numero := substr(lpad(v_filial,3,'0'),1,3) || lpad(pnumero,6,'0');
  
  if pnumero > 9500000 then
    begin
      send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','[LojaVirtual] ERRO VERIFICA MODULO 11','O número atual da sequencia seq_cod_cli_auto_web :'||pnumero || ' /total de (9999999), está se esgotando. Verifique um outro intervalo disponível');
    exception
      when others then
        null;
    end;
  end if;
  
  loop
    v_soma := v_soma + (to_number(substr(v_numero,v_cont,1)) * v_posicao);
    v_posicao := 10 - v_cont;
    exit when v_cont = 9;
    v_cont := v_cont + 1;
  end loop;
  
  resto := v_soma - (11 * trunc((v_soma / 11 ),0));
  
  if resto = 0 then
    pnumerodig := v_filial || lpad(pnumero,6,0) || 1;
  elsif resto = 1 then
    pnumerodig := v_filial || lpad(pnumero,6,0) || 0;
  else
    pnumerodig := v_filial || lpad(pnumero,6,0) || to_number(11 - resto);
  end if;
  
end verifica_modulo_11_web;
/
