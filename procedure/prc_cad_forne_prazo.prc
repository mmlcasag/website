create or replace procedure website.prc_cad_forne_prazo
( p_coditprod in number
, p_prazo    out number
) is
  
  v_codforne    number;
  v_codlinha    number;
  v_codfam      number;
  v_codgrupo    number;
  v_codprod     number;
  
  v_flag        varchar2(1);
  v_prazo       cad_forne_prazo.dias%type;
  
  --
  
  procedure inicializa_variaveis
  ( p_flag  in out varchar2
  , p_prazo in out number
  ) is
  begin
    p_flag := 'N';
    p_prazo := 0;
  end;
  
  --
  
  procedure busca_dados_produto
  ( p_coditprod in number
  , p_codprod  out number
  , p_codgrupo out number
  , p_codfam   out number
  , p_codlinha out number
  , p_codforne out number
  ) is
  begin
    
    begin
      select p.codprod, g.codgrupo, f.codfam, l.codlinha, o.codforne
      into   p_codprod, p_codgrupo, p_codfam, p_codlinha, p_codforne
      from   web_itprod  i
      join   web_prod    p on p.codprod  = i.codprod
      join   web_forne   o on o.codforne = p.codforne
      join   web_grupo   g on g.codgrupo = p.codgrupo
      join   web_familia f on f.codfam   = g.codfam
      join   web_linha   l on l.codlinha = f.codlinha
      where  i.coditprod = p_coditprod;
    exception
      when no_data_found then
        raise_application_error(-20002, 'O produto informado é inválido ou não existe na base de dados.');
    end;
    
  end busca_dados_produto;
  
  --
  
  procedure busca_promocao_por_tipo
  ( p_tipo      in varchar2
  , p_coditprod in number default null
  , p_codprod   in number default null
  , p_codgrupo  in number default null
  , p_codfam    in number default null
  , p_codlinha  in number default null
  , p_codforne  in number default null
  , p_flag  in out varchar2
  , p_prazo in out number
  ) is
  begin
    
    case p_tipo

    when 'I' then -- Item
      
      select 'S', dias
      into   p_flag, p_prazo
      from   cad_forne_prazo
      where  rownum = 1
      and    coditprod = p_coditprod
      and    nvl(codprod, p_codprod) = p_codprod
      and    nvl(codgrupo, p_codgrupo) = p_codgrupo
      and    nvl(codfam, p_codfam) = p_codfam
      and    nvl(codlinha, p_codlinha) = p_codlinha
      and    nvl(codforne, p_codforne) = p_codforne;
      
    when 'P' then -- Produto
      
      select 'S', dias
      into   p_flag, p_prazo
      from   cad_forne_prazo
      where  rownum = 1
      and    coditprod is null
      and    codprod = p_codprod
      and    nvl(codgrupo, p_codgrupo) = p_codgrupo
      and    nvl(codfam, p_codfam) = p_codfam
      and    nvl(codlinha, p_codlinha) = p_codlinha
      and    nvl(codforne, p_codforne) = p_codforne;
      
    when 'G' then -- Grupo
      
      select 'S', dias
      into   p_flag, p_prazo
      from   cad_forne_prazo
      where  rownum = 1
      and    coditprod is null
      and    codprod is null
      and    codgrupo = p_codgrupo
      and    nvl(codfam, p_codfam) = p_codfam
      and    nvl(codlinha, p_codlinha) = p_codlinha
      and    nvl(codforne, p_codforne) = p_codforne;
      
    when 'F' then -- Família
      
      select 'S', dias
      into   p_flag, p_prazo
      from   cad_forne_prazo
      where  rownum = 1
      and    coditprod is null
      and    codprod is null
      and    codgrupo is null
      and    codfam = p_codfam
      and    nvl(codlinha, p_codlinha) = p_codlinha
      and    nvl(codforne, p_codforne) = p_codforne;
      
    when 'L' then -- Linha
      
      select 'S', dias
      into   p_flag, p_prazo
      from   cad_forne_prazo
      where  rownum = 1
      and    coditprod is null
      and    codprod is null
      and    codgrupo is null
      and    codfam is null
      and    codlinha = p_codlinha
      and    nvl(codforne, p_codforne) = p_codforne;
      
    when 'O' then -- Fornecedor
      
      select 'S', dias
      into   p_flag, p_prazo
      from   cad_forne_prazo
      where  rownum = 1
      and    coditprod is null
      and    codprod is null
      and    codgrupo is null
      and    codfam is null
      and    codlinha is null
      and    codforne = p_codforne;
      
    end case;
    
  exception
    when no_data_found then
      inicializa_variaveis(p_flag, p_prazo);
  end busca_promocao_por_tipo;
  
  --
  
begin
  
  --
  
  inicializa_variaveis(v_flag, v_prazo);
  
  --
  
  busca_dados_produto(p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne);
  
  --
  
  dbms_output.put_line('BUSCA DADOS DO PRODUTO');
  dbms_output.put_line('--> Fornecedor...: ' || to_char(v_codforne));
  dbms_output.put_line('--> Linha........: ' || to_char(v_codlinha));
  dbms_output.put_line('--> Família......: ' || to_char(v_codfam));
  dbms_output.put_line('--> Grupo........: ' || to_char(v_codgrupo));
  dbms_output.put_line('--> Produto......: ' || to_char(v_codprod));
  dbms_output.put_line('--> Item.........: ' || to_char(p_coditprod));
  
  --
  
  -- Tenta buscar promoção pelo item
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por item');
    busca_promocao_por_tipo('I', p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne, v_flag, v_prazo);
    dbms_output.put_line('Retorno: ' || v_flag || ' - ' || v_prazo);
  end if;
  
  -- Tenta buscar promoção pelo produto
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por produto');
    busca_promocao_por_tipo('P', p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne, v_flag, v_prazo);
    dbms_output.put_line('Retorno: ' || v_flag || ' - ' || v_prazo);
  end if;
  
  -- Tenta buscar promoção pelo grupo
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por grupo');
    busca_promocao_por_tipo('G', p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne, v_flag, v_prazo);
    dbms_output.put_line('Retorno: ' || v_flag || ' - ' || v_prazo);
  end if;
  
  -- Tenta buscar promoção pela família
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por família');
    busca_promocao_por_tipo('F', p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne, v_flag, v_prazo);
    dbms_output.put_line('Retorno: ' || v_flag || ' - ' || v_prazo);
  end if;
  
  -- Tenta buscar promoção pela linha
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por linha');
    busca_promocao_por_tipo('L', p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne, v_flag, v_prazo);
    dbms_output.put_line('Retorno: ' || v_flag || ' - ' || v_prazo);
  end if;
  
  -- Tenta buscar promoção pelo fornecedor
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por fornecedor');
    busca_promocao_por_tipo('O', p_coditprod, v_codprod, v_codgrupo, v_codfam, v_codlinha, v_codforne, v_flag, v_prazo);
    dbms_output.put_line('Retorno: ' || v_flag || ' - ' || v_prazo);
  end if;
  
  --
  
  if v_flag = 'N' then
    dbms_output.put_line('RESULTADO: Atribuiu prazo do cadastro de parâmetros: ' || to_char(fnc_retorna_parametro('LOGISTICA','PRAZO ENCOMENDA')));
    p_prazo := fnc_retorna_parametro('LOGISTICA','PRAZO ENCOMENDA');
  else
    dbms_output.put_line('RESULTADO: ' || v_prazo);
    p_prazo := v_prazo;
  end if;
  
  --
  
end prc_cad_forne_prazo;
/
