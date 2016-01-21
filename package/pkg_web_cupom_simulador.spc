create or replace package pkg_web_cupom_simulador is
  
  procedure startup;
  
  procedure servlet
  ( p_numpedven      in number 
  , p_numcupom       in varchar2
  ) ;
  
  procedure carrega_enderecos_cliente
  ( p_cgccpf in number default null 
  ) ;
  
  procedure carrega_dados_produto
  ( p_coditprod in number default null 
  ) ;
  
  procedure startup_2;
  
  procedure servlet_2
  ( p_numcupom       in varchar2 default null
  , p_forma_pagto    in number   default null
  , p_num_cep        in number   default null
  , p_cgccpf         in number   default null
  , p_codend         in number   default null
  , p_arr_coditprod  in owa_util.ident_arr default util.empty
  , p_arr_qtcomp     in owa_util.ident_arr default util.empty
  , p_arr_precounit  in owa_util.ident_arr default util.empty
  , p_arr_vldescitem in owa_util.ident_arr default util.empty
  ) ;
  
  procedure busca_desconto
  ( p_numcupom       in varchar2
  , p_forma_pagto    in number   default null
  , p_num_cep        in number   default null
  , p_cod_cliente    in number   default null
  , p_cod_endcli     in number   default null
  , p_arr_coditprod  in varchar2 default null
  , p_arr_qtcomp     in varchar2 default null
  , p_arr_precounit  in varchar2 default null
  , p_arr_vldescitem in varchar2 default null
  , p_tip_desc      out varchar2
  , p_per_desc      out number
  , p_vlr_desc      out number
  , p_caller         in varchar2 default null
  , p_debug          in number   default 0
  ) ;
  
  function processa_regra 
  ( p_arr_regras     in owa_util.ident_arr 
  ) return number;
  
end pkg_web_cupom_simulador;
/
