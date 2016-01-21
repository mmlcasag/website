create or replace package pkg_web_cupom_regras is
  
  type web_cupom_regra_vo is record
  ( id_regra       web_cupom_regras.id_regra%type
  , id_regra_pai   web_cupom_regras.id_regra_pai%type
  , id_cupom       web_cupom_regras.id_cupom%type
  , tipo_regra     web_cupom_regras.tipo_regra%type
  , clausula_1     web_cupom_regras.clausula_1%type
  , clausula_2     web_cupom_regras.clausula_2%type
  , clausula_3     web_cupom_regras.clausula_3%type
  , clausula_4     web_cupom_regras.clausula_4%type
  ) ;
  
  type array_web_cupom_regra_vo is table of web_cupom_regra_vo index by binary_integer;
  
  function get_next_id return number;
  
  function get_desc_tipo_regra ( p_tipo_regra in number ) return varchar2;
  
  function get_desc_simnao ( p_status in number ) return varchar2;
  
  function get_desc_clausula_11 ( p_clausula_11 in varchar2 ) return varchar2;
  
  function get_desc_clausula_12 ( p_clausula_12 in varchar2 ) return varchar2;
  
  function get_desc_clausula_13 ( p_clausula_13 in varchar2 ) return varchar2;
  
  function get_desc_clausula_21 ( p_clausula_21 in varchar2 ) return varchar2;
  
  function get_desc_clausula_23 ( p_clausula_23 in varchar2 ) return varchar2;
  
  function get_desc_clausula_24 ( p_clausula_24 in varchar2 default null ) return varchar2;
  
  function ret_teste_clausula_13_number
  ( p_prefixo  in number   default null
  , p_operador in varchar2 
  , p_sufixo   in number 
  ) return boolean;
  
  function ret_teste_clausula_13_date
  ( p_prefixo  in date     default null
  , p_operador in varchar2 
  , p_sufixo   in date 
  ) return boolean;
  
  function ret_teste_clausula_13_varchar
  ( p_prefixo  in varchar2 default null
  , p_operador in varchar2 
  , p_sufixo   in varchar2 
  ) return boolean;
  
  function ret_teste_clausula_13_array
  ( p_prefixo  in owa_util.ident_arr
  , p_operador in varchar2 
  , p_sufixo   in varchar2 
  ) return boolean;
  
  procedure insere ( p_vo in web_cupom_regra_vo ) ;
  
  procedure altera ( p_vo in web_cupom_regra_vo ) ;
  
  procedure exclui ( p_id_cupom     in number default null,
                     p_id_regra_pai in number default null,
                     p_id_regra     in number default null);
  
  function seleciona ( p_vo in web_cupom_regra_vo ) return array_web_cupom_regra_vo;
  
  function carrega ( p_id_regra in number ) return web_cupom_regra_vo;
  
  procedure startup 
  ( p_id_regra       in number   default null
  , p_id_regra_pai   in number   default null
  , p_id_cupom       in number   default null
  , p_tipo_regra     in number   default null
  , p_clausula_1     in varchar2 default null
  , p_clausula_2     in varchar2 default null
  , p_clausula_3     in varchar2 default null
  , p_clausula_4     in varchar2 default null
  , z_action         in varchar2 default null
  ) ;
  
  procedure formulario 
  ( p_id_regra       in number   default null
  , p_id_cupom       in number   default null
  , p_id_regra_pai   in number   default null
  , p_tipo_regra     in number   default null
  ) ;
  
  function valida 
  ( p_vo             in web_cupom_regra_vo
  ) return boolean;
  
  procedure update_filhos(p_vo in web_cupom_regra_vo);
  
  procedure servlet 
  ( p_id_regra       in number   default null
  , p_id_regra_pai   in number   default null
  , p_id_cupom       in number   default null
  , p_tipo_regra     in number   default null
  , p_clausula_1     in varchar2 default null
  , p_clausula_2     in varchar2 default null
  , p_clausula_3     in varchar2 default null
  , p_clausula_4     in varchar2 default null
  , z_action         in varchar2 default null
  ) ;
  
end pkg_web_cupom_regras;
/
