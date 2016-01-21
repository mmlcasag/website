create or replace function fnc_url_rastreio
( p_pedido  in number
, p_sistema in number default 1 -- 1 site e 2 televendas
, p_filial  in number default 400
) return varchar2 as
  
  v_cgccpf_cliente number;
  v_cgccpf_filial  number;
  v_transportadora number;
  v_reg_expedicao  varchar2(200);
  v_numnota        number;
  v_serie          varchar2(5);
  v_url_rastreio   varchar2(4000);
  
begin
  
  -- busca documento cliente
  select c.cgccpf, f.cgccpf
  into   v_cgccpf_cliente, v_cgccpf_filial
  from   mov_pedido p, cad_cliente c, cad_filial f
  where  p.numpedven = p_pedido
  and    p.codcli    = c.codcli
  and    p.filorig   = f.codfil;
  
  -- busca a transportadora do pedido
  select p.transp, p.reg_expedicao, p.numnota, p.serie
  into   v_transportadora, v_reg_expedicao, v_numnota, v_serie
  from   mov_pedido_web p
  where  p.numpedven = p_pedido;
  
  -- busca a url de rastreio
  select t.url_rastreio 
  into   v_url_rastreio
  from   fretes_transportadora t
  where  t.codigo = v_transportadora;
  
  -- substitui variáveis da URL
  v_url_rastreio := replace(v_url_rastreio, '#pedido#', p_pedido);
  v_url_rastreio := replace(v_url_rastreio, '#nota#', v_numnota);
  v_url_rastreio := replace(v_url_rastreio, '#serie#', v_serie);
  v_url_rastreio := replace(v_url_rastreio, '#cnpj-emissor#', v_cgccpf_filial);
  v_url_rastreio := replace(v_url_rastreio, '#doc-cliente#', v_cgccpf_cliente);
  v_url_rastreio := replace(v_url_rastreio, '#correios-chave#', v_reg_expedicao);
  
  if p_sistema = 1 then
    v_url_rastreio := replace(v_url_rastreio,'#sistema#','www.colombo.com.br');
  else
    v_url_rastreio := replace(v_url_rastreio,'#sistema#','100.1.1.70/Site');
  end if;
  
  return v_url_rastreio;
  
exception
  when others then
    return null;
end fnc_url_rastreio;
/
