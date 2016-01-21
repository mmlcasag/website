create or replace
PROCEDURE           "PRC_CALCULA_PRECO_PRODUTO" (p_codprod number default null,
                                     fl_trigger varchar2 default 'N') is
      v_preco                         web_prod_preco.preco%type;
      v_precoAux                      web_prod_preco.preco%type;
      v_coditprod                     web_itprod.coditprod%type;
      v_margem                        number(7,2);
      v_cep                           number := 88888888;
      v_desconto                      number;

      -- Limitadores
      v_margem_min                    number;
      v_preco_min                     number;
      v_desc_max                      number;

      -- validade do preco
      v_data_inicio                   date := to_date('01/01/1900','dd/mm/yyyy');
      v_data_fim                      date := to_date('31/12/2100','dd/mm/yyyy');

      v_cod_preco                     number;
      v_codfil                        web_prod_preco.codfil%type;

      -- cursor com os planos
      cursor planos  is select codplano, taxa, qtdprc,juros_parcela
                          from website.web_plano
                          where flativo = 'S'
                            and sysdate between dtinicio and dtfim;

     -- cursor de produtos
     cursor produtos is select codprod
                        from web_prod;

     v_produto                         produtos%rowType;
     v_consulta                        varchar2(4000);
     produto                           util.ref_cursor;


begin

   begin
    select WEBSITE.fnc_retorna_parametro('GERAIS','LOJA PADRAO')
      into v_codfil
      from dual;
   exception
    when no_data_found then
      v_codfil := 400;
   end;

  v_consulta := 'select codprod from web_prod where (flativo = ''S'' or flcatalogo = ''S'') or :x1 = -1 ';
  if (p_codprod is not null) then
    v_consulta := ' select codprod from web_prod where codprod = :x1';
  end if;

    open produto for v_consulta using p_codprod;
    fetch produto into v_produto;
    loop
      exit when produto%notfound;
                -- inicializa variaveis
                v_preco      := 0;
                v_precoAux   := 0;
                v_coditprod  := 0;
                v_margem     := 0;
                v_desconto   := 0;
                v_margem_min := 0;
                v_preco_min  := 0;
                v_desc_max   := 0;
                v_cod_preco  := 0;

                -- seleciona o preco de lista de um produto
                select preco
                  into v_preco
                from web_prod
                where codprod = v_produto.codprod;
                --dbms_output.put_line('Preço '||v_preco);

                -- seleciona um item para calculo da margem de venda e desconto progressivo
                --  o item tem q ser ativo no site, se nao encontrou item ativo.. seleciona um item não ativo
                begin
                    select coditprod
                      into v_coditprod
                    from web_itprod
                    where codprod = v_produto.codprod
                      and flativo = 'S'
                      and codsitprod not in ('US','AV')
                      and rowNum < 2;
                    --dbms_output.put_line('Item sem excessao '||v_coditprod);
                exception
                  when others then
                    select coditprod
                      into v_coditprod
                    from web_itprod
                    where codprod = v_produto.codprod
                      and flativo = 'N'
                      and rowNum < 2;
                    --dbms_output.put_line('Item com excessao '||v_coditprod);
                end;

                -- Busca os limitadores para o item na filial
                begin
                          website.prc_limites_item(v_coditprod, v_codfil, v_margem_min, v_preco_min, v_desc_max);

                --dbms_output.put_line('Limitadores margem: '||v_margem_min|| ' preco: '|| v_preco_min|| ' desconto: '||v_desc_max);


                -- margem de venda
                          v_margem := fnc_ret_margem( v_coditprod,
                                                      v_codfil, -- filial
                                                      v_preco, -- preco
                                                      'CE', -- plano padrao é cartão
                                                      1, -- parcelas
                                                      v_cep);
                          dbms_output.put_line('Margem preco lista: '||v_margem);


                          -- enquanto houver limitadores, aplica desconto progressivo
                          v_precoAux := v_preco;
                          -- desconto mxm de 10%
                          if (v_desc_max < 10) then
                             v_desconto := v_desc_max;
                          else
                             v_desconto := 10;
                          end if;
                          dbms_output.put_line('Preço antes de entra no desconto: '||v_preco);
                          while (v_desconto > 0) loop
                                              dbms_output.put_line('Desconto Progressivo: '||v_desconto);
                                              v_precoAux := v_preco - (v_preco * (v_desconto/100));
                                              v_margem := fnc_ret_margem( v_coditprod,
                                                                    v_codfil, -- filial
                                                                    v_precoAux, -- preco
                                                                    'CE', -- plano padrao é cartão
                                                                    1, -- parcelas
                                                                    v_cep);
                                              if (v_precoAux > nvl(v_preco_min,0) and
                                                  v_margem > nvl(v_margem_min,0)) then
                                                     v_preco := v_precoAux;
                                                     dbms_output.put_line('Preço depois do desconto: '||v_preco);
                                                     exit;
                                              end if;
                                              v_desconto := v_desconto - 1;
                                end loop;
                -- se houver excessao no calculo.. mantem o preco de lista
                exception
                  when others then
                      null;
                end;
                  --dbms_output.put_line('Preço: '||v_preco);

                -- insere capa do preco
                begin
                   -- seleciona o codigo
                   select codigo
                    into v_cod_preco
                   from web_prod_preco
                   where codprod = v_produto.codprod
                     and codfil = v_codfil
                     and promocao is null
                     and dt_inicio = v_data_inicio
                     and dt_fim = v_data_fim;

                     -- atualiza preco
                     update web_prod_preco
                        set preco = v_preco,
                            dt_alteracao = sysdate
                      where codigo = v_cod_preco;
                exception
                    when others then

                    -- seleciona o prx codigo
                    select website.seq_web_prod_preco.nextval
                      into v_cod_preco
                    from dual;

                    -- insere preco
                    insert into web_prod_preco (codigo, codprod, dt_inicio,
                                            dt_fim, promocao, preco,
                                            preco_antigo, dt_alteracao, codfil, cpd_flativo)
                                   values (v_cod_preco, v_produto.codprod, v_data_inicio,
                                           v_data_fim, null, v_preco,
                                          null, sysdate, v_codfil, 'S');

                end;

                        -- insere os planos para o produto
                        for cr in planos
                          loop
                                   BEGIN
                                            INSERT INTO web_prod_preco_plano (codigo, prod_preco, codplano,
                                                                              preco, maior_parcela, juros, juros_parcela, vlr_maior_parcela)
                                                                    values (website.seq_web_prod_preco_plano.nextval, v_cod_preco, cr.codplano,
                                                                            v_preco, cr.qtdprc, cr.taxa, cr.juros_parcela,
                                                                            fnc_valor_parcela(cr.qtdprc, v_preco, cr.taxa));
                                   exception
                                     when others then
                                            update web_prod_preco_plano
                                               set preco = v_preco,
                                                   maior_parcela = cr.qtdprc,
                                                   juros = cr.taxa,
                                                   juros_parcela = cr.juros_parcela,
                                                   vlr_maior_parcela = fnc_valor_parcela(cr.qtdprc, v_preco, cr.taxa)
                                              where prod_preco = v_cod_preco
                                                and codplano = cr.codplano;
                                   end;
                          end loop;

                if (fl_trigger = 'N') then
                  commit;
                end if;

      fetch produto into v_produto;
    end loop;


end;
/
