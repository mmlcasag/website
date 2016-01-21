CREATE OR REPLACE PROCEDURE PROC_PRODUTO_XML
( p_codprod             IN NUMBER
, p_codfil              IN NUMBER
, p_codperfil           IN NUMBER
, p_datacache           IN DATE
, p_melhor_condicao     IN VARCHAR2
, exibirDePor          OUT VARCHAR2
, precoAntigo          OUT NUMBER
, preco                OUT NUMBER
, precoPrimeiraParcela OUT NUMBER
, parcelas             OUT NUMBER
, prestacao            OUT NUMBER
, juros                OUT NUMBER
, precoVista           OUT NUMBER
, exibePrecoVista      OUT VARCHAR2
) AS
  
  cursor cProduto is
  select *
  from   WEB_PROD
  where  codprod = p_codprod;
  
  cursor cMelhorCampanha is
  select cpd.*
  from  WEB_CAMP_PRECO_PRODUTOS cpd, WEB_PROD prd
  where  cpd.prd_codprod = prd.codprod
  and    prd.codprod     = p_codprod
  and    cpd.cpr_id = (
      select max(cpd2.cpr_id)
      from   WEB_CAMP_PRECO_PRODUTOS cpd2, WEB_CAMPANHAS_PRECO cpr
      where  cpd2.prd_codprod  = cpd.prd_codprod
      and    cpd2.cpr_id       = cpr.cpr_id
      and    p_datacache between cpr.CPR_INICIO and cpr.CPR_FIM
  );
  
  cursor cCampanhaProdutoPlano(p_id in number) is
  select *
  from   WEB_CAMP_PRECO_PROD_PLANOS
  where  cpd_id = p_id;
  
  cursor cCampanhaPlano(p_id in number) is
  select *
  from   WEB_CAMP_PRECO_PLANOS
  where  cpr_id = p_id;
  
  cursor cUltimaParcelaCartao(v_codprod in number, v_codplano in varchar2) is
  select max(parcela)
  from   table(web_preco_ativo_parcela(v_codprod))
  where  plano = v_codplano;
  
  cursor cParcela(v_codprod in number, v_codplano in varchar2, v_parcela in number) is
  select *
  from   table(web_preco_ativo_parcela(v_codprod))
  where  plano = v_codplano
  and    parcela = v_parcela;
  
  type rec_web_preco_ativo_parcela is record(
      codprod       number(10),
      plano         varchar2(10),
      parcela       number(10),
      preco_parcela number(10,2),
      preco_normal  number(10,2),
      preco_total   number(10,2),
      preco_antigo  number(10,2),
      juros         number(10,2)
  );
  
  rProd                 web_prod%rowtype;
  rCampanhaProduto      WEB_CAMP_PRECO_PRODUTOS%rowtype;
  rCampanhaProdutoPlano WEB_CAMP_PRECO_PROD_PLANOS%rowtype;
  rCampanhaPlano        WEB_CAMP_PRECO_PLANOS%rowtype;
  rParcela              rec_web_preco_ativo_parcela;
  rParcelaBoleto        rec_web_preco_ativo_parcela;
  rWebPerfil            WEB_PLANO_PERFIL%rowtype;
  rPerfil               WEB_PERFIL%rowtype;
  
  vAchou                boolean;

  v_plano               WEB_PLANO.codplano%type;
  v_ultima_parcela      integer;
  
BEGIN
  
  open cProduto;
  fetch cProduto into rProd;
  if cProduto%found then
    open cMelhorCampanha;
    fetch cMelhorCampanha into rCampanhaProduto;
    
    if cMelhorCampanha%found then
      vAchou := false;
      for R1 in cCampanhaProdutoPlano(rCampanhaProduto.cpd_id) loop
        if R1.pla_codplano = rProd.melhorplano then
          rCampanhaProdutoPlano := R1;
          vAchou := true;
        end if;
      end loop;
      
      if vAchou then
        v_plano := rCampanhaProdutoPlano.pla_codplano;
      else
        for R1 in cCampanhaPlano(rCampanhaProduto.cpr_id) loop
          if R1.pla_codplano = rProd.melhorplano then
            rCampanhaPlano := R1;
            vAchou := true;
          end if;
        end loop;
        
        if vAchou then
          v_plano := rCampanhaPlano.pla_codplano;
        else
          v_plano := rProd.melhorplano;
          -- aqui parcelas do plano
        end if;
      end if;
    else
      v_plano := rProd.melhorplano;
    end if;
    close cMelhorCampanha;

    v_ultima_parcela := 0;
    open cUltimaParcelaCartao(p_codprod,v_plano);
    fetch cUltimaParcelaCartao into v_ultima_parcela;
    close cUltimaParcelaCartao;
    v_ultima_parcela := nvl(v_ultima_parcela,0);
    
    open cParcela(p_codprod,'BO',1);
    fetch cParcela into rParcelaBoleto;
    vAchou := cParcela%found;
    close cParcela;
    
    if v_ultima_parcela <> 0 then
      open cParcela(p_codprod, v_plano, v_ultima_parcela);
      fetch cParcela into rParcela;
      close cParcela;
    end if;
    
    if rParcela.parcela is not null then
      exibirDePor           := util.test(rCampanhaProduto.CPD_VALOR_ANTIGO is not null and rCampanhaProduto.CPD_VALOR_ANTIGO <> 0, 'S', 'N');
      precoAntigo           := util.test(rCampanhaProduto.CPD_VALOR_ANTIGO is not null and rCampanhaProduto.CPD_VALOR_ANTIGO <> 0, rCampanhaProduto.CPD_VALOR_ANTIGO, 0);
      preco                 := rParcela.PRECO_TOTAL;
      precoPrimeiraParcela  := rParcelaBoleto.PRECO_TOTAL;
      parcelas              := rParcela.PARCELA;
      prestacao             := rParcela.PRECO_PARCELA;
      juros                 := rParcela.JUROS;
      precoVista            := rParcelaBoleto.PRECO_TOTAL;
      exibePrecoVista       := util.test(rParcelaBoleto.PRECO_TOTAL < rParcela.PRECO_TOTAL, 'S', 'N');
    else
      exibirDePor           := 'N';
      precoAntigo           := null;
      preco                 := rProd.preco;
      precoPrimeiraParcela  := rProd.preco;
      parcelas              := 1;
      prestacao             := rProd.preco;
      juros                 := 0;
      precoVista            := rProd.preco;
      exibePrecoVista       := util.test(precoVista < preco, 'S', 'N');
    end if;
    
  end if;
  
  close cProduto;
  
END PROC_PRODUTO_XML;
/
