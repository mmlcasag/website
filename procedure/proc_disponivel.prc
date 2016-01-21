create or replace procedure website.proc_disponivel
( p_coditprod        in number
, p_cep              in number
, p_numlistacas      in number
, p_qtdedisp        out number
, p_diasent         out number
, p_tipo            out varchar2
, p_deposito_out in out number
) is
  
  -- cursor de remanejo
  cursor remanejo ( p_deposito in number ) is
  select deposito
  from   web_depositos_remanejos
  where  deposito_remanejo = p_deposito;
  
  v_deposito     number;
  v_deposito_sec number;
  v_produto      number;
  
begin
  
  -- busca o código do produto de um item
  select i.codprod
  into   v_produto
  from   cad_itprod i
  where  i.coditprod = p_coditprod;
  
  -- se um deposito padrao foi passado por padrao, considera ele como default
  if nvl(p_deposito_out,0) = 0 then
    v_deposito := f_deposito(nvl(p_cep, to_number(fnc_retorna_parametro('LOGISTICA','CEP PADRAO'))), v_produto);
  else
    v_deposito := p_deposito_out;
  end if;
  
  -- verifica estoque no dep principal
  website.proc_estoque(p_coditprod, v_deposito, p_numlistacas, p_qtdedisp, p_diasent, p_tipo);
  
  -- se nao tem estoque, verifica estoque nos depositos secundarios
  if p_qtdedisp <= 0 then
    for cr in remanejo (v_deposito) loop
      v_deposito_sec := cr.deposito;
      
      website.proc_estoque(p_coditprod, v_deposito_sec, p_numlistacas, p_qtdedisp, p_diasent, p_tipo);
      
      -- remanejo apenas para itens fisicos
      -- estoque deve ser maior que 5 para remanejar pois alguns produtos chegam avariados e os clientes trocam
      if p_cep is not null then
        if p_tipo is not null then
          p_tipo := 'N';
        else
          p_tipo := 'R';
        end if;
      end if;
      
      -- se a opcao remanejo estiver ativa
      -- incrementa o prazo de entrega para o remanejo
      -- se encontrou estoque interrompe pesquisa por outro deposito remanejo
      if fnc_retorna_parametro('LOGISTICA','REMANEJO') = 'S' then
        if p_qtdedisp > 0 then
          p_diasent := p_diasent + fnc_retorna_parametro('LOGISTICA','PRAZO REMANEJO');
          exit;
        end if;
      end if;
    end loop;
  end if;
  
  -- Se não remaneja, entrega será direta do depósito para o cliente
  if fnc_retorna_parametro('LOGISTICA','REMANEJO') = 'N' then
    v_deposito := v_deposito_sec; -- seta depósito de entrega como depósito com estoque.
  end if;
  
  p_deposito_out := v_deposito;
  
  dbms_output.put_line('Quantidade Disponível...: ' || p_qtdedisp);
  dbms_output.put_line('Dias para entrega.......: ' || p_diasent);
  dbms_output.put_line('Tipo de Saída...........: ' || p_tipo);
  dbms_output.put_line('Depósito de Entrega.....: ' || v_deposito);
  
exception
  when others then
    declare
      v1 varchar2(200);
      v2 varchar2(200);
      v3 varchar2(200);
      v4 varchar2(200);
    begin
      who_called_me(v1, v2, v3, v4);
      
      send_mail
      ( 'site-erros@colombo.com.br'
      , 'site-erros@colombo.com.br'
      , 'PROC_DISPONIVEL'
      , 'Erro..............: ' || sqlerrm || chr(13) || chr(13) ||
        'Who Called Me.....: ' || v1 || ' - ' || v2 || ' - ' || v3 || ' - ' || v4 || chr(13) || chr(13) ||
        'Parâmetros: ' || chr(13) ||
        '- p_coditprod.....: '  || p_coditprod || chr(13) ||
        '- p_cep...........: ' || p_cep || chr(13) ||
        '- p_numlistacas...: ' || p_numlistacas || chr(13) ||
        '- p_deposito_out..: ' || p_deposito_out || chr(13) ||
        'Environment Variables' || chr(13) || chr(13) ||
        '- Host............: ' || sys_context('USERENV','HOST') || chr(13) ||
        '- IP Address......: ' || sys_context('USERENV','IP_ADDRESS') || chr(13) ||
        '- Module..........: ' || sys_context('USERENV','MODULE') || chr(13) ||
        '- OS..............: ' || sys_context('USERENV','OS_USER') || chr(13) ||
        '- User............: ' || sys_context('USERENV','SESSION_USER') || chr(13) ||
        '- Terminal........: ' || sys_context('USERENV','TERMINAL') || chr(13) ||
        '- SQL.............: ' || sys_context('USERENV','CURRENT_SQL')
      ) ;
      
      p_deposito_out := 0;
      p_qtdedisp     := 0;
      p_diasent      := 0;
      p_tipo         := 'I';
      
      raise;
    end;
end proc_disponivel;
/
