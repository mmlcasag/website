create or replace function fnc_estoque_prod_uf 
( p_codprod in number
, p_cep     in number
) return       varchar2 as
  
  v_uf         web_depositos_uf.uf%type;
  v_estoque    web_prod_depositos.fldisponivel%type;
  
begin
  
  begin
    select c.uf
    into   v_uf
    from   cad_cep c
    where  c.cep = p_cep;
  exception
    when others then
      v_uf := null;
  end;
  
  -- FAZ A BUSCA PELOS RANGES
  if v_estoque is null then
    begin
      -- verifica em deposito principal
      select p.fldisponivel
      into   v_estoque
      from   web_depositos       d
      join   web_prod_depositos  p on p.deposito = d.codigo
      join   web_depositos_ceps  c on c.deposito = d.codigo
      where  d.flativo           = 'S'
      and    d.fldefault         = 'S'
      and    p.fldisponivel      = 'S'
      and    p.codprod           = p_codprod
      and    p_cep         between c.cep_ini and c.cep_fim
      and    rownum              = 1;
    exception
      when others then
        begin
          -- verifica em deposito secundário
          select p.fldisponivel
          into   v_estoque
          from   web_depositos       d
          join   web_prod_depositos  p on p.deposito = d.codigo
          join   web_depositos_ceps  c on c.deposito = d.codigo
          where  d.flativo           = 'S'
          and    d.fldefault         = 'N'
          and    p.fldisponivel      = 'S'
          and    p.codprod           = p_codprod
          and    p_cep         between c.cep_ini and c.cep_fim
          and    rownum              = 1;
        exception
          when others then
            -- verifica em deposito remanejo
            begin
              select p.fldisponivel
              into   v_estoque
              from   web_depositos           d 
              join   web_prod_depositos      p on p.deposito = d.codigo
              join   web_depositos_remanejos r on r.deposito = d.codigo
              where  d.flativo = 'S'
              and    p.codprod = p_codprod
              and    r.deposito_remanejo in ( 
                       select d.codigo
                       from   web_depositos      d
                       join   web_prod_depositos p on p.deposito = d.codigo
                       join   web_depositos_ceps c on c.deposito = p.deposito
                       where  d.flativo          = 'S'
                       and    d.fldefault        = 'S'
                       and    p.codprod          = p_codprod
                       and    p_cep        between c.cep_ini and c.cep_fim
                     )
              and    rownum   = 1;
            exception
              when others then
                v_estoque := null;
            end;
        end;
    end;
  end if;
  
  -- FAZ A BUSCA PELAS UF'S
  if v_estoque is null then
    begin
      -- verifica em deposito principal
      select p.fldisponivel
      into   v_estoque
      from   web_depositos       d
      join   web_prod_depositos  p on p.deposito = d.codigo
      join   web_depositos_uf    u on u.deposito = d.codigo
      where  d.flativo           = 'S'
      and    d.fldefault         = 'S'
      and    p.fldisponivel      = 'S'
      and    p.codprod           = p_codprod
      and    u.uf                = v_uf
      and    rownum              = 1;
    exception
      when others then
        begin
          -- verifica em deposito secundário
          select p.fldisponivel
          into   v_estoque
          from   web_depositos       d
          join   web_prod_depositos  p on p.deposito = d.codigo
          join   web_depositos_uf    u on u.deposito = d.codigo
          where  d.flativo           = 'S'
          and    d.fldefault         = 'N'
          and    p.fldisponivel      = 'S'
          and    p.codprod           = p_codprod
          and    u.uf                = v_uf
          and    rownum              = 1;
        exception
          when others then
            -- verifica em deposito remanejo
            begin
              select p.fldisponivel
              into   v_estoque
              from   web_depositos           d 
              join   web_prod_depositos      p on p.deposito = d.codigo
              join   web_depositos_remanejos r on r.deposito = d.codigo
              where  d.flativo = 'S'
              and    p.codprod = p_codprod
              and    r.deposito_remanejo in ( 
                       select d.codigo
                       from   web_depositos      d
                       join   web_prod_depositos p on p.deposito = d.codigo
                       join   web_depositos_uf   u on u.deposito = p.deposito
                       where  d.flativo          = 'S'
                       and    d.fldefault        = 'S'
                       and    p.codprod          = p_codprod
                       and    u.uf               = v_uf
                     )
              and    rownum   = 1;
            exception
              when others then
                v_estoque := null;
            end;
        end;
    end;
  end if;
  
  return nvl(v_estoque,'N');
  
end fnc_estoque_prod_uf;
/
