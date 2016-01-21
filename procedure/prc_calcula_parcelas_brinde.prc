create or replace procedure prc_calcula_parcelas_brinde
( p_codFil    in number
, p_codBrinde in number
) as
  
  cursor planosBrinde (p_brinde number) is 
  select bp.codPlano, bp.qtdPrc, l.tppgto, l.vlminParc, bp.preco, bp.precoanterior, bp.taxa
  from web_itprod_brindePlano bp, web_plano l
  where bp.cod_brinde = p_brinde
  and bp.codplano = l.codPlano
  and sysdate between l.dtInicio and l.dtFim;
  
  v_codBrinde     number;
  v_qtnparcela    number;
  v_valor_parcela number;
  
begin
  
  -- seleciona o brinde, valor anterior
  begin
    select b.cod_brinde
      into v_codbrinde
      from web_itprod_brinde b
     where b.cod_brinde = p_codBrinde
       and sysdate between b.dtInicio and b.dtFim;
  exception
    when others then
      v_codBrinde := 0;
      return;
  end;
  
  -- grava as parcelas
  for planos in planosBrinde(v_codBrinde) loop
    
    -- verifica qtn maxima de parcelas
    v_qtnparcela := planos.qtdPrc;
    
    while v_qtnparcela > 1 and planos.preco / v_qtnparcela < planos.vlminParc loop 
      v_qtnparcela := v_qtnparcela-1;
    end loop;
    
    if v_qtnparcela = 0 then
      v_qtnparcela := 1;
    end if;
    
    for prc in 1..v_qtnparcela loop
      select fnc_calc_parcela(planos.taxa, planos.preco, prc)
      into   v_valor_parcela
      from   dual;
      
      begin
        insert into web_itprod_brinde_parcelas(codfil, codBrinde, parcela, tppgto, precoNormal, preco)
        values (p_codfil, v_codBrinde, prc, planos.tppgto, planos.precoanterior, v_valor_parcela);
      exception
        when others then
          null;
      end;
    end loop;
  end loop;
  
  commit;
  
end;
/
