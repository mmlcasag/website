create or replace procedure prc_rateia_frete
( p_vl_frete       in number
, p_vl_itens       in varchar2
, p_vl_frete_item out varchar2
) is
  
  type tvetor    is record(valor number, frete number);
  type tab_frete is table of tvetor index by binary_integer;
  v_tab_frete    tab_frete;
  
  v_vl_frete     number := p_vl_frete / 100;
  v_vl_itens     varchar2(4000) := p_vl_itens;
  v_itens        varchar2(4000);
  v_aux          number := 0;
  v_index        number := 1;
  v_total_itens  number := 0;
  v_percentual   number := 0;
  v_frete_aux    number := 0;
  v_dif_frete    number := 0;
  
begin
  
  -- Valida valores do parâmetro p_vl_itens
  -- Em alguns casos os valores estavam vindo com zero na frente do número e isso acabava gerando loop infinito no loop abaixo
  while v_vl_itens is not null loop
    v_aux      := substr(v_vl_itens, 1, instr(v_vl_itens,'#') - 1);
    v_vl_itens := substr(v_vl_itens, instr(v_vl_itens,'#') + 1, length(v_vl_itens));
    v_itens    := v_itens || to_char(v_aux) || '#';
  end loop;
  
  /* joga valore em um vetor */
  loop
    v_tab_frete(v_index).valor := replace(substr(v_itens,1,instr(v_itens,'#')),'#',null);
    
    v_itens := regexp_replace(v_itens, '^' || v_tab_frete(v_index).valor || '#','');
    
    v_tab_frete(v_index).valor := v_tab_frete(v_index).valor / 100;
    v_total_itens := v_total_itens + v_tab_frete(v_index).valor;
    
    v_index := v_index + 1;
    
    exit when v_itens is null;
  end loop;
  
  /* calcula % */
  for v in v_tab_frete.first..v_tab_frete.last loop
    v_percentual := v_tab_frete(v).valor / v_total_itens;
    v_tab_frete(v).frete := trunc(v_vl_frete * v_percentual,2);
  end loop;
  
  /* adiciona a diferença de arredondamento no ultimo item */
  for v in v_tab_frete.first..v_tab_frete.last loop
    v_frete_aux := v_frete_aux + v_tab_frete(v).frete;
  end loop;
  
  v_dif_frete := abs(v_frete_aux - v_vl_frete);
  v_tab_frete(v_tab_frete.last).frete := v_tab_frete(v_tab_frete.last).frete + v_dif_frete;
  
  /* mostra os valores */
  for v in v_tab_frete.first..v_tab_frete.last loop
    p_vl_frete_item := p_vl_frete_item || v_tab_frete(v).frete * 100 ||'#';
  end loop;
  
end prc_rateia_frete;
/
