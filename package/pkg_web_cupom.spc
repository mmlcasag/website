create or replace package pkg_web_cupom is
  
  type web_cupom_vo is record
  ( id             web_cupom.id%type
  , descricao      web_cupom.descricao%type
  , codigo         web_cupom.codigo%type
  , status         web_cupom.status%type
  , limite_total   web_cupom.limite_total%type
  , limite_cliente web_cupom.limite_cliente%type
  , dtvalini       web_cupom.dtvalini%type
  , dtvalfim       web_cupom.dtvalfim%type
  ) ;
  
  type array_web_cupom_vo is table of web_cupom_vo index by binary_integer;
  
  function get_next_id return number;
  
  function get_desc_status ( p_status in number ) return varchar2;
  
  procedure insere ( p_vo in web_cupom_vo ) ;
  
  procedure altera ( p_vo in web_cupom_vo ) ;
  
  procedure exclui ( p_vo in web_cupom_vo ) ;
  
  function seleciona ( p_vo in web_cupom_vo ) return array_web_cupom_vo;
  
  function carrega ( p_id in number ) return web_cupom_vo;
  
  procedure startup 
  ( p_id             in number   default null
  , p_descricao      in varchar2 default null
  , p_codigo         in varchar2 default null
  , p_status         in number   default null
  , p_limite_total   in number   default null
  , p_limite_cliente in number   default null
  , p_dtvalini       in date     default null
  , p_dtvalfim       in date     default null
  , z_action         in varchar2 default null
  ) ;
  
  procedure formulario 
  ( p_id             in number   default null
  ) ;
  
  procedure valida 
  ( p_vo             in web_cupom_vo
  ) ;
  
  procedure servlet 
  ( p_id             in number   default null
  , p_descricao      in varchar2 default null
  , p_codigo         in varchar2 default null
  , p_status         in number   default null
  , p_limite_total   in number   default null
  , p_limite_cliente in number   default null
  , p_dtvalini       in date     default null
  , p_dtvalfim       in date     default null
  , z_action         in varchar2 default null
  ) ;
  
  procedure utiliza_cupom_desconto
  ( p_num_cupom   in varchar2
  , p_cod_cliente in number
  , p_retorno    out varchar2
  ) ;
  
end pkg_web_cupom;
/
