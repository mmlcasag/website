create or replace package hto as

  function divopen 
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure divopen
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function divclose
  return varchar2;
  
  procedure divclose;
  
  function div 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure div 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function spanopen 
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure spanopen
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function spanclose
  return varchar2;
  
  procedure spanclose;
  
  function span 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure span 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function popen 
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure popen
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function pclose
  return varchar2;
  
  procedure pclose;
  
  function p 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure p 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function tabledataopen
  ( calign in varchar2 default null
  , ccolspan in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure tabledataopen
  ( calign in varchar2 default null
  , ccolspan in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function tabledataclose
  return varchar2;
  
  procedure tabledataclose;
  
  function fieldsetopen
  ( calign in varchar2 default null
  , csize in varchar2 default null
  , clegend in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2;
  
  procedure fieldsetopen 
  ( calign in varchar2 default null
  , csize in varchar2 default null
  , clegend in varchar2 default null
  , cattributes in varchar2 default null 
  ) ;
  
  function fieldsetclose
  return varchar2;
  
  procedure fieldsetclose;
  
  function legend
  ( clegend in varchar2 default null
  , cattributes in varchar2 default null
  ) return varchar2;
  
  procedure legend
  ( clegend in varchar2 default null
  , cattributes in varchar2 default null
  ) ;
  
  function formselectoption
  ( cvalue in varchar2
  , ctext in varchar2
  , cselected in varchar2 default null 
  ) return varchar2;
  
  procedure formselectoption
  ( cvalue in varchar2
  , ctext in varchar2
  , cselected in varchar2 default null 
  ) ;
  
end hto;
/
