create or replace function f_get_id_limitores
( p_coditprod in number
, p_codfil    in number
, p_rowid    out varchar2
, p_tipo     out number -- 1 = tipo_margens_familia; 2 = limite_margem
) return boolean is
  
  /******************************************************************************
   NAME:       F_RET_SEQ_LIMITE2

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        01/06/2006  Enor Paim       1. Created this package.
  ******************************************************************************/
  
  v_codsitprod  varchar2(2);
  v_codforne    number;
  v_codlinha    number;
  v_codfam      number;
  v_codgrupo    number;
  v_rowid       varchar2(200);
  v_tipo        number;
  
begin
  
  v_rowid := null;
  v_tipo  := null;
  
  -- Consulta dados do produto
  select cps.codsitprod, ci.codforne, ci.codlinha, ci.codfam, ci.codgrupo
  into   v_codsitprod, v_codforne, v_codlinha, v_codfam, v_codgrupo
  from   cad_preco_situacao cps, cad_itprod ci
  where  ci.coditprod = cps.coditprod
  and    ci.coditprod = p_coditprod;
  
  if v_rowid is null then
    -- seleciona a margem limitadora do (item)
    begin
      select lm.rowid
      into   v_rowid
      from   limite_margem lm, limite_margem_loja lml
      where  rownum = 1
      and    lm.coditprod = p_coditprod
      and    lm.seq_limite_margem = lml.seq_limite_margem
      and    lml.codfil = p_codfil;
      v_tipo := 2;
    exception
      when others then
        v_rowid := null;
    end;
  end if;
  
  if v_rowid is null then
    -- seleciona o limite por atributo e linha não nula
    begin
      select id
      into   v_rowid
      from   ( 
               select lm.rowid id
               from   limite_margem lm, limite_margem_loja lml
               where  codforne is null
               and    codsitprod           = v_codsitprod
               and    codlinha             = v_codlinha
               and    lm.seq_limite_margem = lml.seq_limite_margem
               and    lml.codfil           = p_codfil
               order  by lim_menor
             )
      where  rownum = 1;
      v_tipo := 2;
    exception
      when others then
        v_rowid := null;
    end;
  end if;
  
  if v_rowid is null then
    -- seleciona o limite por atributo
    begin
      select id
      into   v_rowid
      from   (
               select lm.rowid id
               from   limite_margem lm, limite_margem_loja lml
               where  codfam   is null
               and    codlinha is null
               and    codforne is null
               and    codsitprod           = v_codsitprod
               and    lm.seq_limite_margem = lml.seq_limite_margem
               and    lml.codfil           = p_codfil
               order  by lim_menor
             )
      where  rownum = 1;
      v_tipo := 2;
    exception
      when others then
        v_rowid := null;
    end;
  end if;
  
  if v_rowid is null then
    -- seleciona o limite por atributo e familia não nula
    begin
      select id
      into   v_rowid
      from   (
               select lm.rowid id
               from   limite_margem lm, limite_margem_loja lml
               where  codforne is null
               and    codsitprod           = v_codsitprod
               and    lm.codfam            = v_codfam
               and    lm.seq_limite_margem = lml.seq_limite_margem
               and    lml.codfil           = p_codfil
               order  by lim_menor
             )
      where  rownum = 1;
      v_tipo := 2;
    exception
      when others then
        v_rowid := null;
    end;
  end if;
  
  if v_rowid is null then
    -- seleciona o limite por fornecedor
    begin
      select id
      into   v_rowid
      from   (
               select lm.rowid id
               from   limite_margem_loja lml, limite_margem lm
               where  lm.codforne          = v_codforne
               and    lm.codsitprod        = v_codsitprod
               and  ( lm.codlinha          = v_codlinha or lm.codlinha is null )
               and  ( lm.codfam            = v_codfam   or lm.codfam   is null )
               and    lm.seq_limite_margem = lml.seq_limite_margem
               and    lml.codfil           = p_codfil
               order  by lim_menor
             )
      where  rownum = 1;
      v_tipo := 2;
    exception
      when others then
        v_rowid := null;
    end;
  end if;
  
  if v_rowid is null then
    -- seleciona a margem limitadora da familia
    begin
      select f.rowid
      into   v_rowid
      from   tipo_margens_familias f, tipo_margens_lojas l
      where  f.codfam = v_codfam
      and    f.codigo = l.codigo
      and    l.codfil = p_codfil;
      v_tipo := 1;
    exception
      when others then
        v_rowid := null;
    end;
  end if;
  
  p_rowid := v_rowid;
  p_tipo  := v_tipo;
  
  return true;
  
exception
  when others then
    p_rowid := null;
    p_tipo  := null;
    
    return false;
end f_get_id_limitores;
/
