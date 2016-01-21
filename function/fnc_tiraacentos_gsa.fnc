create or replace
function fnc_tiraacentos_gsa (palavra varchar2) return varchar2 as
 v_aux varchar2(4000) := '';
 v_palavra varchar2(4000);
begin
    v_palavra := fnc_tiraacentos(palavra);
    if(v_palavra is not null) then
      for cr in 1..length(v_palavra)
       loop
          if (ascii(substr(v_palavra,cr,1)) > 31  -- caracteres nao imprimiveis
              and substr(v_palavra,cr,1) <> '"'  and substr(v_palavra,cr,1) <> ''''  -- remove aspas
              ) then
             v_aux := v_aux || substr(v_palavra, cr, 1);
          end if;
       end loop;
    end if;
    return v_aux;
end fnc_tiraacentos_gsa;
