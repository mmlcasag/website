CREATE OR REPLACE FUNCTION F_RET_CUBAGEM_ITEM (p_coditprod in number)
RETURN number IS

  cursor c1 (pcoditprod in number) is
  select it.coditprod, pr.codprod, pr.status, pr.difer, (pr.altura*pr.largura*pr.comp/1000000) cubagmax
  from   cad_prod pr, cad_itprod it
  where  it.coditprod = pcoditprod
  and    pr.codprod   = it.codprod;
  
  cursor c2 (pcoditprod in number) is
  select vol.coditprodvolume, pr.codprod
  from   cad_prod pr, cad_itprod it, cad_itvolume vol
  where  vol.coditprodprinc = pcoditprod
  and    it.coditprod       = vol.coditprodvolume
  and    pr.codprod         = it.codprod;
  
  wcubagmax           number := 0;
  wcubvol             number := 0;
  
begin
  
  wcubagmax := 0;
  for r1 in c1 (p_coditprod) loop
    if r1.difer = 0 and r1.status = 0 then
      wcubagmax := r1.cubagmax;
    elsif r1.difer = 9 and r1.status = 4 then
      wcubagmax := r1.cubagmax;
    elsif r1.difer = 9 and r1.status = 0 then
      for r2 in c2 (r1.coditprod) loop
        wcubvol := 0;
        begin
          select (pr.altura*pr.largura*pr.comp/1000000) cubagmax
          into   wcubvol
          from   cad_prod pr
          where  pr.codprod = r2.codprod;
        exception
          when no_data_found then
            wcubvol := 0;
        end;
        
        wcubagmax := nvl(wcubagmax,0) + nvl(wcubvol,0);
      end loop;
    end if;
  end loop;
  
  return wcubagmax;
  
end;
/
