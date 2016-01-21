create or replace
FUNCTION           "WEB_PRECO_ATIVO" (p_codprod number, p_cpr_id number default null, p_portal number default null, p_origem number default 1, p_codfil number default 400)
  RETURN tp_web_preco_ativo_tb PIPELINED IS

  cursor c1 is
    select *
      from web_prod_preco p
     where ( (p_cpr_id is not null and promocao = p_cpr_id) or
             (p_cpr_id is null and
                 (
                  promocao is not null
                    and not exists (select 1
                                      from web_campanhas_preco cp, web_campanha_preco_portal cpp
                                     where cp.cpr_id  = cpp.cpr_id
                                       and cp.cpr_id  = p.promocao
                                  )
                    and exists (
                                select 1
                                  from web_campanhas_preco cp, web_campanha_preco_origem cpo
                                 where cp.cpr_id  = cpo.cpr_id
                                   and cp.cpr_id  = p.promocao
                                   and cpo.origem = p_origem
                               )
                 )
             )
           )
       and codfil = p_codfil
       and codprod = p_codprod
       and cpd_flativo = 'S'
       and (p_cpr_id is not null or sysdate between p.dt_inicio and p.dt_fim)
     order by codprod, dt_alteracao desc, promocao;

  cursor c3 is
    select *
      from web_prod_preco p
     where (
              promocao is not null
                and exists (select 1
                             from web_campanhas_preco cp, web_campanha_preco_portal cpp, web_campanha_preco_origem cpo
                            where cp.cpr_id  = cpp.cpr_id
                              and cp.cpr_id  = cpo.cpr_id
                              and cp.cpr_id  = p.promocao
                              and cpp.portal = p_portal
                              and cpo.origem = p_origem
                          )

           )
       and codprod = p_codprod
       and codfil = p_codfil
       and cpd_flativo = 'S'
       and sysdate between p.dt_inicio and p.dt_fim
     order by codprod, dt_alteracao desc, promocao;

  cursor c2 is
    select *
      from web_prod_preco
     where promocao is null
       and codprod = p_codprod
       and codfil = p_codfil;

  rLinha web_prod_preco%rowtype;
  out_rec tp_web_preco_ativo;
  v_contador integer;
  v_ativo varchar2(1);

  function processaLinha return boolean is
    v_retorno boolean := false;
  begin
    v_ativo := 'S';
    if(rLinha.promocao is not null and p_cpr_id is null) then
      select cpr_fl_ativo into v_ativo from web_campanhas_preco where cpr_id = rLinha.promocao;
    end if;

    if(v_ativo = 'S' and v_contador = 0) then
      out_rec := tp_web_preco_ativo(rLinha.codigo, rLinha.codprod, rLinha.dt_inicio, rLinha.dt_fim,
                                  rLinha.promocao, rLinha.preco, rLinha.preco_antigo, rLinha.dt_alteracao);
      v_retorno  := true;
      v_contador := v_contador+1;
    end if;
    return (v_retorno);
  end;

begin
  v_contador:=0;

  if(p_cpr_id is null and p_portal is not null) then
    open c3;
    loop
      fetch c3 into rLinha;
      exit when c3%notfound;

      if(processaLinha) then
        pipe row(out_rec);
      end if;

    end loop;
    close c3;
  end if;

  if(v_contador = 0) then
    open c1;
    loop
      fetch c1 into rLinha;
      exit when c1%notfound;

      if(processaLinha) then
        pipe row(out_rec);
      end if;

    end loop;
    close c1;
  end if;

  if(v_contador = 0 and p_cpr_id is null) then
    open c2;
    fetch c2 into rLinha;
    if(c2%found) then
      out_rec := tp_web_preco_ativo(rLinha.codigo, rLinha.codprod, rLinha.dt_inicio, rLinha.dt_fim,
                                  rLinha.promocao, rLinha.preco, rLinha.preco_antigo, rLinha.dt_alteracao);
      pipe row(out_rec);
    end if;
    close c2;
  end if;
end;