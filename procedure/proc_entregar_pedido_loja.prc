create or replace procedure proc_entregar_pedido_loja
( p_numpedven in integer default null
, p_codfilial in integer default null
) is
  
  cursor cur_dados_filial (p_codfil in positive) is
  select endereco, bairro, cidade, estado, cep, complemento, ddd, fone, numero, col_codcidade
  from   cad_filial
  where  codfil = p_codfil;
  
  b_erro     boolean := false;
  v_mensagem long;
  v_sql      long;
  
  n_aux      number;
  n_codcli   number;
  n_codend   number;
  
BEGIN
  
  if not b_erro then
    select count(*)
    into   n_aux
    from   mov_pedido p
    where  nvl(p.status,0) between 0 and 5
    and    p.numpedven     = p_numpedven
    and    p.tpnota        = 52;
    
    if n_aux = 0 then
      b_erro := true;
      v_mensagem := 'Reserva informada e invalida para este processo!' || htf.br || 'Somente reservas de venda que estao pendentes sao validas.';
    end if;
  end if;
  
  if not b_erro then
    select count(*)
    into   n_aux
    from   cad_filial
    where  nvl(status,0)      <> 9
    and    nvl(codregiao,0)   <> 99
    and    codfil             = p_codfilial;
    
    if n_aux = 0 then
      b_erro := true;
      v_mensagem := 'Filial informada e invalida para este processo!' || htf.br || 'Somente lojas nao fechadas sao validas.';
    end if;
  end if;
  
  if not b_erro then
    for i in cur_dados_filial (p_codfilial) loop
      
      if not b_erro then
        begin
          select codcli
          into   n_codcli
          from   mov_pedido
          where  numpedven = p_numpedven;
        exception
          when others then
            b_erro := true;
            v_mensagem := 'Ocorreu um erro ao buscar codigo do cliente do pedido!' || htf.br || 'Erro: ' || sqlerrm;
        end;
      end if;
      
      if not b_erro then
        begin
          select nvl(max(codend) + 1,0)
          into   n_codend
          from   cad_endcli
          where  codcli = n_codcli;
        exception
          when others then
            b_erro := true;
            v_mensagem := 'Ocorreu um erro ao buscar numero do novo endereço de entrega!' || htf.br || 'Erro: ' || sqlerrm;
        end;
      end if;
      
      if not b_erro then
        begin
          insert into cad_endcli
            ( codcli
            , codend
            , tpender
            , endereco
            , bairro
            , cidade
            , estado
            , cep
            , complemento
            , dddfone1
            , fone1
            , numero
            , col_codcidade
            )
          values
            ( n_codcli
            , n_codend
            , decode(n_codend, 0, 'R', 'E')
            , i.endereco
            , i.bairro
            , i.cidade
            , i.estado
            , i.cep
            , i.complemento
            , i.ddd
            , i.fone
            , i.numero
            , i.col_codcidade
          ) ;
        exception
          when others then
            b_erro := true;
            v_mensagem := 'Ocorreu um erro ao inserir novo endereço de entrega!' || htf.br || 'Erro: ' || sqlerrm;
        end;
      end if;
      
      if not b_erro then
        begin
          update mov_pedido
          set    col_entregar_loja = 'S'
          ,      endcob     = 0
          ,      endent     = n_codend
          ,      col_filent = p_codfilial
          where  numpedven  = p_numpedven;
        exception
          when others then
            b_erro := true;
            v_mensagem := 'Ocorreu um erro ao vincular novo endereço de entrega ao pedido!' || htf.br || 'Erro: ' || sqlerrm;
        end;
        
        v_sql := ' update mov_pedido
                   set    col_entregar_loja = ''S''
                   ,      endcob     = 0
                   ,      endent     = ' || n_codend || '
                   ,      col_filent = ' || p_codfilial || '
                   where  numpedven  = ' || p_numpedven;
        
        insert into web_nuv_pendencias
          ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
        values
          ( seq_nuv_pendencias.nextval, sysdate, 'PROC_ENTREGAR_PEDIDO_LOJA', p_numpedven, v_sql, 'N', null );
      end if;
      
    end loop;
  end if;
  
end proc_entregar_pedido_loja;
/
