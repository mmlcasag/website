create or replace 
procedure proc_cliente(-- dados do cliente
                       pcodfil in number,   -- Filial de cadastro do cliente
                       pprontuario in number, -- Codigo do vendedor
                       pcodcli in number,   -- Codigo do cliente (se existir)
                       pcgccpf in number,
                       pnatjur in char,
                       pnomcli in varchar2,
                       pdtnasc in date,
                       pdtcadast in date,
                       pinscr in varchar2,
                       pnumdoc in varchar2,
                       pemissor in varchar2,
                       pnomemae in varchar2,
                       pnomepai in varchar2,
                       pconjuge in varchar2,
                       pempresa in varchar2,
                       pcargo in number,
                       pcodestcivil in number,
                       psexo in char,
                       prendabruta in number,
                       ptiporesid in varchar2,
                       ptemporesid in number,
                       -- endereco do cliente residencial
                       pendereco in varchar2,
                       pnumero in number,
                       prefer in varchar2,
                       pbairro in varchar2,
                       pcidade in varchar2,
                       pestado in varchar2,
                       pcep in number,
                       pcomplemento in varchar2,
                       pdddfone1 in varchar2,
                       pfone1 in varchar2,
                       pramalfone1 in varchar2,
                       pdddfone2 in varchar2,
                       pfone2 in varchar2,
                       pramalfone2 in varchar2,
                       pdddcelular in varchar2,
                       pcelular in varchar2,
                       pe_mail in varchar2,
                       -- Endereço de entrega
                       pendereco_e in varchar2,
                       pnumero_e in number,
                       pbairro_e in varchar2,
                       prefer_e in varchar2,
                       pcidade_e in varchar2,
                       pestado_e in varchar2,
                       pcep_e in number,
                       pcomplemento_e in varchar2,
                       pdddfone1_e in varchar2,
                       pfone1_e in varchar2,
                       pramal1_e in varchar2,
                       pdddfone2_e in varchar2,
                       pfone2_e in varchar2,
                       pramal2_e in varchar2,
                       pdddcelular_e in varchar2,
                       pcelular_e in varchar2,
                       -- Retorna o código do cliente e o endereço
                       pcodcliout out number,
                       pcodender out number) is
  
  wseqcodauto      varchar2(11);
  wcodcliauto      varchar2(11);
  v_sql            long;
  wdigcli          number;
  wcodvendr        number;
  wcodlocal        number;
  wcodlocal_e      number;
  v_existe_cliente number;
  
begin
  
  begin
    select codvendr
      into wcodvendr
      from ven_vend
     where codfil = pcodfil
       and codfunc = pprontuario
       and nvl(status,0) = 0;
  exception
    when others then
      wcodvendr := 9999;
  end;
  
  if pcodcli is null then
    select min(codcli)
      into pcodcliout
      from cad_cliente
     where cgccpf = pcgccpf
       and codfilcad = pcodfil;
  else
    pcodcliout := pcodcli;
  end if;
  
  begin
    select codlocal
      into wcodlocal
      from cad_cidade
     where uf = pestado
       and local = pcidade
       and rowNum < 2; -- gambiarra para contornar problema de duplicidade de cidades em tabela
  exception
    when no_data_found then
      wcodlocal := null;
  end;
  
  begin
    select codlocal
      into wcodlocal_e
      from cad_cidade
     where uf = pestado_e
       and local = pcidade_e
       and rowNum < 2; -- gambiarra para contornar problema de duplicidade de cidades em tabela;
  exception
    when no_data_found then
      wcodlocal_e := null;
  end;
  
  -- CLIENTE NOVO
  if pcodcliout is null then
    select seqcliente.nextval into pcodcliout from dual;
    
    begin
      calcdigcli(pcodcliout, wdigcli);
    exception
      when others then
        send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','[LojaVirtual] ERRO CALCULANDO DIGITO CLIENTE',pcodcliout||' - '||sqlcode||' - '||sqlerrm);
        raise;
    end;
    
    pcodender := 1;
    
    if wdigcli is null then
      wdigcli := 0;
    end if;
    
    begin
      while (true) loop
        select seq_cod_cli_auto_web.nextval into wseqcodauto from dual;
        
        verifica_modulo_11_web(wseqcodauto, wcodcliauto);
        
        select count(cod_cli_auto)
          into v_existe_cliente
          from cad_cliente
         where cod_cli_auto = wcodcliauto;
        
        if v_existe_cliente = 0 then
          exit;
        end if;
      end loop;
    exception
      when others then
        send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','[LojaVirtual] ERRO VERIFICA MODULO 11',wseqcodauto||' - '||sqlcode||' - '||sqlerrm);
        raise;
    end;
    
    -- Cadastra o cliente
    begin
      insert into cad_cliente
        (codcli, digcli, codvendr, cgccpf, nomcli, dtnasc, codfilcad,
         dtcadast, numdoc, emissor, nomemae, nomepai, conjuge, empresa,
         codcargo, ramatv, codestcivil, codsitcred, natjur, cod_cli_auto,
         status, inscr, sexo, vlrendbruto, tpresid, temporesidmes)
      values
        (pcodcliout, wdigcli, wcodvendr, pcgccpf, upper(pnomcli), pdtnasc, pcodfil,
         pdtcadast, pnumdoc, pemissor, upper(pnomemae), upper(pnomepai), pconjuge, pempresa,
         pcargo, null, pcodestcivil, 'NO', pnatjur, wcodcliauto,
         0, replace(fnc_tiraacentos(trim(pinscr)),' ',''), psexo, prendabruta, ptiporesid, ptemporesid);
    exception
      when others then
        raise_application_error(-20903, ' inserindo na cad_cliente ' || sqlerrm);
    end;
    
    -- Cadastra os complementos
    -- Não inclui dtultaltcre para não mexer nos cadastros a serem importados na loja fisica
    -- Projeto 783-010 definição 029 - Scheila - 25/05/2006
    v_sql := ' begin
                 insert into cad_cliente_compl
                   ( codcli, codcliant, dtultaltcre )
                 values
                   ( ' || pcodcliout || ', ''' || to_char(wcodcliauto) || ''', null );
               exception
                 when dup_val_on_index then
                   null;
               end; ';
    
    insert into web_nuv_pendencias
      ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
    values
      ( seq_nuv_pendencias.nextval, sysdate, 'PROC_CLIENTE', pcodcliout, v_sql, 'N', null );
    
    -- Cadastra o endereço residencial do cliente
    begin
      insert into cad_endcli
        (codcli, codend, tpender, endereco, numero, refer, bairro,
         cidade, estado, cep, complemento, dddfone1, fone1, ramalfone1,
         dddfone2, fone2, ramalfone2, ddd, fone, e_mail, col_codcidade)
      values
        (pcodcliout, 0, 'R', pendereco, pnumero, prefer, pbairro,
         pcidade, pestado, pcep, pcomplemento, pdddfone1, pfone1, pramalfone1,
         pdddfone2, pfone2, pramalfone2, pdddcelular, pcelular, pe_mail, wcodlocal);
    exception
      when others then
        raise_application_error(-20903, 'Cliente: '||pcodcliout||' - inserindo na cad_endcli - endresid ' || sqlerrm);
    end;
    
    -- Cadastra o endereço de entrega
    begin
      insert into cad_endcli
        (codcli, codend, tpender, endereco, numero, refer, bairro,
         cidade, estado, cep, complemento, dddfone1, fone1, ramalfone1,
         dddfone2, fone2, ramalfone2, ddd, fone, col_codcidade)
      values
        (pcodcliout, 1, 'E', pendereco_e, pnumero_e, prefer_e, pbairro_e,
         pcidade_e, pestado_e, pcep_e, pcomplemento_e, pdddfone1_e, pfone1_e, pramal1_e,
         pdddfone2_e, pfone2_e, pramal2_e, pdddcelular_e, pcelular_e, wcodlocal_e);
    exception
      when others then
        raise_application_error(-20903, 'inserindo na cad_endcli - endentrega ' || sqlerrm);
    end;
    
  -- CLIENTE JÁ EXISTENTE
  else
    
    -- Atualiza dados do cliente
    begin
      update cad_cliente
         set codvendr = wcodvendr,
             cgccpf = pcgccpf,
             nomcli = upper(pnomcli),
             dtnasc = pdtnasc,
             codfilcad = pcodfil,
             numdoc = pnumdoc,
             emissor = pemissor,
             nomemae = upper(pnomemae),
             nomepai = upper(pnomepai),
             conjuge = nvl(pconjuge,conjuge),
             empresa = nvl(pempresa,empresa),
             codcargo = nvl(pcargo,codcargo),
             vlrendbruto = nvl(prendabruta,vlrendbruto),
             tpresid = nvl(ptiporesid,tpresid),
             temporesidmes = nvl(ptemporesid,temporesidmes),
             codestcivil = nvl(pcodestcivil,codestcivil),
             natjur = pnatjur,
             inscr = nvl(replace(fnc_tiraacentos(trim(pinscr)),' ',''),inscr),
             sexo = psexo
       where codcli = pcodcliout;
    exception
      when others then
        raise_application_error(-20903, 'alterando a cad_cliente ' || sqlerrm);
    end;
    
    -- Atualiza endereco residencial
    begin
      update cad_endcli
         set endereco = pendereco,
             numero = pnumero,
             complemento = pcomplemento,
             bairro = pbairro,
             cidade = pcidade,
             estado = pestado,
             cep = pcep,
             refer = prefer,
             dddfone1 = pdddfone1,
             fone1 = pfone1,
             ramalfone1 = pramalfone1,
             dddfone2 = pdddfone2,
             fone2 = pfone2,
             ramalfone2 = pramalfone2,
             ddd = pdddcelular,
             fone = pcelular,
             e_mail = pe_mail,
             col_codcidade = wcodlocal
       where codcli = pcodcliout
         and tpender = 'R'
         and codend = 0;
    exception
      when others then
        raise_application_error(-20903, 'alterando a cad_endcli - endresid ' || sqlerrm);
    end;
    
    -- Atualiza o endereco entrega
    begin
      select codend
        into pcodender
        from cad_endcli
       where codcli = pcodcliout
         and tpender = 'E'
         and nvl(cep, 0) = pcep_e
         and endereco = pendereco_e
         and numero = pnumero_e;
    exception
      when others then
        select nvl(max(nvl(codend, 0)), 0) + 1
          into pcodender
          from cad_endcli
         where codcli = pcodcliout;
    end;
    
    begin
      update cad_endcli
         set endereco = pendereco_e,
             numero = pnumero_e,
             complemento = pcomplemento_e,
             bairro = pbairro_e,
             cidade = pcidade_e,
             estado = pestado_e,
             cep = pcep_e,
             refer = prefer_e,
             dddfone1 = pdddfone1_e,
             fone1 = pfone1_e,
             ramalfone1 = pramal1_e,
             dddfone2 = pdddfone2_e,
             fone2 = pfone2_e,
             ramalfone2 = pramal2_e,
             ddd = pdddcelular_e,
             fone = pcelular_e,
             col_codcidade = wcodlocal_e
       where codcli = pcodcliout
         and tpender = 'E'
         and codend = pcodender;
      
      if sql%notfound then
        insert into cad_endcli
          (codcli, codend, tpender, endereco, numero, refer, bairro,
           cidade, estado, cep, complemento, dddfone1, fone1, ramalfone1,
           dddfone2, fone2, ramalfone2, ddd, fone, col_codcidade)
        values
          (pcodcliout, pcodender, 'E', pendereco_e, pnumero_e, prefer_e, pbairro_e,
           pcidade_e, pestado_e, pcep_e, pcomplemento_e, pdddfone1_e, pfone1_e, pramal1_e,
           pdddfone2_e, pfone2_e, pramal2_e, pdddcelular_e, pcelular_e, wcodlocal_e);
      end if;
    exception
      when others then
        raise_application_error(-20903, 'alterando a cad_endcli - endentrega ' || sqlerrm);
    end;
  end if;
  
  v_sql := ' begin proc_sincroniza_cliente(' || pcodcliout || '); end; ';
  
  insert into web_nuv_pendencias
    ( id, dat_inclusao, nom_programa, primary_key, sql_comando, flg_processado, dat_processado )
  values
    ( seq_nuv_pendencias.nextval, sysdate, 'PROC_CLIENTE', pcodcliout, v_sql, 'N', null );

exception
  when others then
    rollback;
    
declare
  v_mensagem clob;
begin
  v_mensagem := '
declare
  
  v1 varchar2(200);
  v2 varchar2(200);
  
begin
  
  website.proc_cliente
  ( pcodfil        => ''' || pcodfil || '''
  , pprontuario    => ''' || pprontuario || '''
  , pcodcli        => ''' || pcodcli || '''
  , pcgccpf        => ''' || pcgccpf || '''
  , pnatjur        => ''' || pnatjur || '''
  , pnomcli        => ''' || pnomcli || '''
  , pdtnasc        => to_date(''' || to_char(pdtnasc,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , pdtcadast      => to_date(''' || to_char(pdtcadast,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')
  , pinscr         => ''' || pinscr || '''
  , pnumdoc        => ''' || pnumdoc || '''
  , pemissor       => ''' || pemissor || '''
  , pnomemae       => ''' || pnomemae || '''
  , pnomepai       => ''' || pnomepai || '''
  , pconjuge       => ''' || pconjuge || '''
  , pempresa       => ''' || pempresa || '''
  , pcargo         => ''' || pcargo || '''
  , pcodestcivil   => ''' || pcodestcivil || '''
  , psexo          => ''' || psexo || '''
  , prendabruta    => ''' || prendabruta || '''
  , ptiporesid     => ''' || ptiporesid || '''
  , ptemporesid    => ''' || ptemporesid || '''
  , pendereco      => ''' || pendereco || '''
  , pnumero        => ''' || pnumero || '''
  , prefer         => ''' || prefer || '''
  , pbairro        => ''' || pbairro || '''
  , pcidade        => ''' || pcidade || '''
  , pestado        => ''' || pestado || '''
  , pcep           => ''' || pcep || '''
  , pcomplemento   => ''' || pcomplemento || '''
  , pdddfone1      => ''' || pdddfone1 || '''
  , pfone1         => ''' || pfone1 || '''
  , pramalfone1    => ''' || pramalfone1 || '''
  , pdddfone2      => ''' || pdddfone2 || '''
  , pfone2         => ''' || pfone2 || '''
  , pramalfone2    => ''' || pramalfone2 || '''
  , pdddcelular    => ''' || pdddcelular || '''
  , pcelular       => ''' || pcelular || '''
  , pe_mail        => ''' || pe_mail || '''
  , pendereco_e    => ''' || pendereco_e || '''
  , pnumero_e      => ''' || pnumero_e || '''
  , pbairro_e      => ''' || pbairro_e || '''
  , prefer_e       => ''' || prefer_e || '''
  , pcidade_e      => ''' || pcidade_e || '''
  , pestado_e      => ''' || pestado_e || '''
  , pcep_e         => ''' || pcep_e || '''
  , pcomplemento_e => ''' || pcomplemento_e || '''
  , pdddfone1_e    => ''' || pdddfone1_e || '''
  , pfone1_e       => ''' || pfone1_e || '''
  , pramal1_e      => ''' || pramal1_e || '''
  , pdddfone2_e    => ''' || pdddfone2_e || '''
  , pfone2_e       => ''' || pfone2_e || '''
  , pramal2_e      => ''' || pramal2_e || '''
  , pdddcelular_e  => ''' || pdddcelular_e || '''
  , pcelular_e     => ''' || pcelular_e || '''
  , pcodcliout     => v1
  , pcodender      => v2
  ) ;
  
  dbms_output.put_line(v1);
  dbms_output.put_line(v2);
  
end;';
  
  send_mail('site-erros@colombo.com.br','site-erros@colombo.com.br','PROC_CLIENTE','Erro: ' || chr(13) || chr(13) || sqlerrm || ' - Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || chr(13) || 'Debug: ' || chr(13) || chr(13) || chr(13) || v_mensagem);
end;
    
    raise_application_error(-20903, 'Erro na PROC_CLIENTE ' || sqlerrm || ' - Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end proc_cliente;
/
