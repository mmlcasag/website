create or replace procedure proc_quantidade_vezes_desconto ( p_coddesconto in number ) as
  
  desconto web_descontos%rowtype;
  
begin
  
  begin
    select *
    into   desconto
    from   web_descontos
    where  coddesconto = p_coddesconto;
    
    if desconto.codprod is not null and desconto.fl_vezes > 0 and desconto.fl_ativo = 'S' then
      desconto.fl_utilizado := nvl(desconto.fl_utilizado,0) + 1;
      
      if desconto.fl_vezes <= desconto.fl_utilizado then
        desconto.fl_ativo := 'N';
      end if;
      
      update web_descontos 
      set    row = desconto 
      where  coddesconto = desconto.coddesconto;
    end if;
  exception
    when others then
      send_mail('site-erros@colombo.com.br', 'site-erros@colombo.com.br', 'ERRO - PROC_QUANTIDADE_VEZES_DESCONTO', sqlerrm||' - CodDesconto: '||p_coddesconto);
  end;
  
end proc_quantidade_vezes_desconto;
/
