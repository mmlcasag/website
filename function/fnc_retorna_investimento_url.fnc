create or replace
FUNCTION FNC_RETORNA_INVESTIMENTO_URL (p_url in varchar,
                                       p_portal  in number) RETURN number AS                                     
  v_linha_pos number(10);
  v_familia_pos number(10);
  v_linha varchar2(400);
  v_familia varchar2(400);
  
  v_investimento number(5,2) := 0;
BEGIN
  -- se for produto
  if (p_url like '/produto%') then 
  
      --busca posicao da linha e familia
      --segunda ocorrencia da / = linha
      v_linha_pos := INSTRC(p_url, '/', 2, 1);      
      --busca terceira ocorrencia da / = familia
      v_familia_pos := INSTRC(p_url, '/',v_linha_pos + 1,1);
      
      
      --busca descricao da familia e linha
      if (v_familia_pos > 0) then
        v_linha := substr(p_url,v_linha_pos+1, v_familia_pos - v_linha_pos -1);
        
        v_familia := substr(p_url, v_familia_pos +1);
      else
        v_linha := substr(p_url,v_linha_pos+1);
      end if;
      
      
      -- prepara dados para consulta
      v_linha := replace(v_linha,'-','+');      
      v_familia := replace(v_familia,'-','+');
      
      
      -- busca a familia
      begin
      select codfam
        into v_familia_pos
       from web_familia
       where f_convert_url(descricao) = v_familia;
      exception
        when no_data_found then
          v_familia_pos := null;
      end;
      
      -- busca a linha
      begin
      select codlinha
        into v_linha_pos
       from web_linha
       where f_convert_url(descricao) = v_linha;
      exception
        when no_data_found then
          v_linha_pos := null;
      end;
      
      -- busca o investimento
      
      -- familia
      v_investimento := 0;
      if (v_familia_pos is not null) then
        begin
          select valor
            into v_investimento
          from web_integr_portal_invest
          where tipo = 'L'
            and portal = 8
            and codtipo = v_linha_pos;      
        exception
          when no_data_found then
            v_investimento := 0;
        end;
      end if;
      
      --linha
      if (v_linha_pos is not null and v_investimento = 0) then
        begin
          select valor
            into v_investimento
          from web_integr_portal_invest
          where tipo = 'L'
            and portal = p_portal
            and codtipo = v_linha_pos;
        exception
          when no_data_found then
            v_investimento := 0;
        end;
      end if;      
            
  else
      -- se nao for produto, entao faz a media
        begin
          select avg(valor)
            into v_investimento
           from web_integr_portal_invest
           where tipo = 'L'
             and portal = p_portal;
        exception
          when no_data_found then
            v_investimento := 0;
        end;
  end if;
  
  return v_investimento;
END FNC_RETORNA_INVESTIMENTO_URL;