create or replace function f_deposito
( p_cep     in number
, p_codprod in number default null
) return       number is
  
  v_deposito number;
  v_uf       cad_cep.uf%type;
  
begin
  
  -- Identifica o local a partir do CEP informado pelo cliente
  begin
    select uf
    into   v_uf
    from   cad_cep
    where  cep = p_cep;
  exception
    when others then
      raise_application_error(-20903, 'CEP não cadastrado: ' || p_cep);
  end;
  
  /*
  -- Identifica o depósito que abastece a localidade pelo estado
  if v_deposito is null then
    begin
      select b.col_codfilentr
      into   v_deposito
      from   cad_pracacep a, cad_praca b
      where  a.praca = b.praca
      and    p_cep between a.cepinic and a.cepfim;
    exception
      when others then
        v_deposito := null;
    end;
  end if;
  */
  
  -- Identifica o depósito a partir do CEP nos ranges de CEPs
  if v_deposito is null then
    begin
      select c.deposito
      into   v_deposito
      from   web_depositos_ceps c
      where  p_cep between c.cep_ini and c.cep_fim;
    exception
      when others then
        v_deposito := null;
    end;
  end if;
  
  if v_deposito is null then
    begin
      -- procura pelo deposito padrao
      select d.deposito
      into   v_deposito
      from   website.web_depositos_uf d, website.web_depositos dp
      where  d.uf         = v_uf
      and    d.deposito   = dp.codigo
      and    dp.fldefault = 'S'
      and    dp.flativo   = 'S'
      and  ( p_codprod is null or exists (
               select 1
               from   website.web_prod_depositos p
               where  dp.codigo = p.deposito
               and    p.codprod = p_codprod
           ) ) ;
    exception
      when others then
        -- procura pelo deposito não padrao
        begin
          select d.deposito
          into   v_deposito        
          from   website.web_depositos_uf d, website.web_depositos dp
          where  d.uf         = v_uf
          and    d.deposito   = dp.codigo
          and    dp.fldefault = 'N'
          and    dp.flativo   = 'S'
          and  ( p_codprod is null or exists ( 
                   select 1
                   from   website.web_prod_depositos p
                   where dp.codigo = p.deposito
                   and p.codprod = p_codprod
               ) );
        exception
          when others then
            v_deposito := null;
        end;
    end;
  end if;
  
  -- se não encontrou deposito.. adiciona depositos padrões por uf
  if v_deposito is null then
    if v_uf in ('RS') then
      v_deposito := 450;
    else
      v_deposito := 820;
    end if;
  end if;
  
  return v_deposito;
  
end f_deposito;
/
