create or replace procedure prc_promocoes_frete
( p_cep          in number
, p_item         in number
, p_vlnota       in number
, p_flag        out varchar2
, p_perc        out number
, p_fixo        out number
) is
  
  -- Procedure utilizada para identificar as promoções de fretes
  -- Entrada: estado, item, valor da nota
  -- Alterações/inclusão grupo - 12/09/2011 - Eliane
  
  v_flag        varchar2(1);
  v_perc        number;
  v_fixo        number;
  
  v_uf          cad_cidade.uf%type;
  v_tpcidade    cad_cidade.col_itapemirim_tipo%type;
  
  v_codlinha    cad_itprod.codlinha%type;
  v_codfam      cad_itprod.codfam%type;
  v_codgrupo    cad_itprod.codgrupo%type;
  
  --
  
  procedure busca_dados_cep
  ( p_cep       in number
  , p_uf       out varchar2
  , p_tpcidade out varchar2
  ) is
  begin
    
    -- identifica o tipo de municipio e a uf a partir do cep
    begin
      select trim(a.uf), nvl(a.col_itapemirim_tipo,'I')
      into   p_uf, p_tpcidade
      from   cad_cidade a, cad_cep b
      where  trim(b.local) = trim(a.local)
      and    trim(b.uf)    = trim(a.uf)
      and    b.cep         = p_cep
      and    rownum        = 1;
    exception
      when others then
        raise_application_error(-20001, 'O CEP informado é inválido ou não existe na base de dados.');
    end;

  end busca_dados_cep;

  --

  procedure busca_dados_produto
  ( p_coditprod in number
  , p_codlinha out number
  , p_codfam   out number
  , p_codgrupo out number
  ) is
  begin

    -- identifica o produto, familia e linha do produto
    begin
      select codlinha, codfam, codgrupo
      into   p_codlinha, p_codfam, p_codgrupo
      from   cad_itprod
      where  coditprod = p_coditprod;
    exception
      when no_data_found then
        raise_application_error(-20002, 'O produto informado é inválido ou não existe na base de dados.');
    end;

  end busca_dados_produto;

  --

  procedure inicializa_variaveis
  ( p_flag  in out varchar2
  , p_perc  in out number
  , p_fixo  in out number
  ) is
  begin

    p_flag := 'N';
    p_perc := 100;
    p_fixo := 0;

  end inicializa_variaveis;

  --

  procedure busca_promocao_por_tipo
  ( p_tipo      in varchar2
  , p_uf        in varchar2
  , p_tpcidade  in varchar2
  , p_vlnota    in number
  , p_coditprod in number default null
  , p_codgrupo  in number default null
  , p_codfam    in number default null
  , p_codlinha  in number default null
  , p_flag     out varchar2
  , p_perc     out number
  , p_fixo     out number
  ) is
  begin

    case p_tipo

    when 'P' then -- Produto
        
        -- seleciona a ultima promocao para produto
        select 'S', perccliente, vlfixo
          into p_flag, p_perc, p_fixo
          from (
                select perccliente, vlfixo
                from   promocoes_frete
                where  sysdate between dtini and dtfim
                and    estado in (p_uf,'TS')
                and    tpcidade in (p_tpcidade,'T')
                and    p_vlnota between vlminimo and vlmaximo
                and    nvl(codproduto,0) = p_coditprod
                order by codpromocao desc
              ) promos
        where rowNum < 2;

    when 'G' then -- Grupo

        -- seleciona a ultima promocao para grupo
        select 'S', perccliente, vlfixo
          into p_flag, p_perc, p_fixo
          from (
                select perccliente, vlfixo
                from   promocoes_frete
                where  sysdate between dtini and dtfim
                and    estado in (p_uf,'TS')
                and    tpcidade in (p_tpcidade,'T')
                and    p_vlnota between vlminimo and vlmaximo
                and    codproduto is null
                and    nvl(codgrupo,0) = p_codgrupo
                and    nvl(codfamilia,0) = p_codfam
                order by codpromocao desc
              ) promos
        where rowNum < 2;

    when 'F' then -- Família

        -- seleciona a ultima promocao para familia
        select 'S', perccliente, vlfixo
          into p_flag, p_perc, p_fixo
          from (
                select perccliente, vlfixo
                from   promocoes_frete
                where  sysdate between dtini and dtfim
                and    estado in (p_uf,'TS')
                and    tpcidade in (p_tpcidade,'T')
                and    p_vlnota between vlminimo and vlmaximo
                and    codproduto is null
                and    codgrupo is null
                and    nvl(codfamilia,0) = p_codfam
                order by codpromocao desc
              ) promos
        where rowNum < 2;

    when 'L' then -- Linha

        -- seleciona a ultima promocao para linha
        select 'S', perccliente, vlfixo
          into p_flag, p_perc, p_fixo
          from (
                select perccliente, vlfixo      
                from   promocoes_frete
                where  sysdate between dtini and dtfim
                and    estado in (p_uf,'TS')
                and    tpcidade in (p_tpcidade,'T')
                and    p_vlnota between vlminimo and vlmaximo
                and    codproduto is null
                and    codgrupo is null
                and    codfamilia is null
                and    nvl(codlinha,0) = p_codlinha
                order by codpromocao desc                
              ) promos
        where rowNum < 2;

    when 'O' then -- Outra / Geral

        -- seleciona a ultima promocao para outros
        select 'S', perccliente, vlfixo
          into p_flag, p_perc, p_fixo
          from (
                select perccliente, vlfixo    
                from   promocoes_frete
                where  sysdate between dtini and dtfim
                and    estado in (p_uf,'TS')
                and    tpcidade in (p_tpcidade,'T')
                and    p_vlnota between vlminimo and vlmaximo
                and    codproduto is null
                and    codgrupo is null
                and    codfamilia is null
                and    codlinha is null
                order by codpromocao desc                
              ) promos
        where rowNum < 2;

    end case;
    
  exception
    when others then
      inicializa_variaveis(p_flag, p_perc, p_fixo);
  end busca_promocao_por_tipo;
  
  --
  
begin
  
  busca_dados_cep(p_cep, v_uf, v_tpcidade);
  
  dbms_output.put_line('Cep: ' || to_char(p_cep));
  dbms_output.put_line('--> UF: ' || v_uf);
  dbms_output.put_line('--> Tp: ' || v_tpcidade);
  
  busca_dados_produto(p_item, v_codlinha, v_codfam, v_codgrupo);
  
  dbms_output.put_line('Produto: ' || to_char(p_item));
  dbms_output.put_line('--> Linha: ' || to_char(v_codlinha));
  dbms_output.put_line('--> Família: ' || to_char(v_codfam));
  dbms_output.put_line('--> Grupo: ' || to_char(v_codgrupo));
  
  inicializa_variaveis(v_flag, v_perc, v_fixo);
  
  dbms_output.put_line('Inicializado: ' || v_flag || ' ' || to_char(v_perc) || ' ' || to_char(v_fixo));
  
  --
  
  -- Tenta buscar promoção pelo produto
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por produto');
    busca_promocao_por_tipo('P', v_uf, v_tpcidade, p_vlnota, p_item, v_codgrupo, v_codfam, v_codlinha, v_flag, v_perc, v_fixo);
  end if;
  
  -- Se não achou, tenta pelo grupo
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por grupo');
    busca_promocao_por_tipo('G', v_uf, v_tpcidade, p_vlnota, p_item, v_codgrupo, v_codfam, v_codlinha, v_flag, v_perc, v_fixo);
  end if;
  
  -- Se não achou, tenta pela família
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por família');
    busca_promocao_por_tipo('F', v_uf, v_tpcidade, p_vlnota, p_item, v_codgrupo, v_codfam, v_codlinha, v_flag, v_perc, v_fixo);
  end if;
  
  -- Se não achou, tenta pela linha
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por linha');
    busca_promocao_por_tipo('L', v_uf, v_tpcidade, p_vlnota, p_item, v_codgrupo, v_codfam, v_codlinha, v_flag, v_perc, v_fixo);
  end if;
  
  -- Se não achou, tenta geralzão
  if v_flag = 'N' then
    dbms_output.put_line('Foi buscar por geralzão');
    busca_promocao_por_tipo('O', v_uf, v_tpcidade, p_vlnota, p_item, v_codgrupo, v_codfam, v_codlinha, v_flag, v_perc, v_fixo);
  end if;
  
  --
  
  p_flag := v_flag;
  p_perc := v_perc;
  p_fixo := v_fixo;
  
  dbms_output.put_line('Resultado: ' || v_flag || ' ' || to_char(v_perc) || ' ' || to_char(v_fixo));
  
end prc_promocoes_frete;
/
