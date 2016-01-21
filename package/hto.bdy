create or replace package body hto as

  -----------------------------------------------------------------------------
  
  function divopen 
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
    
    v_out varchar2(100) := '<DIV';
  
  begin
    
    if calign is not null then
      v_out := v_out || ' ALIGN="' || calign || '"';
    end if;
    
    if cattributes is not null then
      v_out := v_out || ' ' || cattributes;
    end if;
    
    v_out := v_out || '>';
    
    return v_out;
    
  end divopen;
  
  -----------------------------------------------------------------------------
  
  procedure divopen
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.divopen
      ( calign => calign
      , cattributes => cattributes 
      )
    );
  end divopen;
  
  -----------------------------------------------------------------------------
    
  function divclose
  return varchar2 is
  begin
    return '</DIV>';
  end divclose;
  
  -----------------------------------------------------------------------------
  
  procedure divclose is
  begin
    htp.p(hto.divclose);
  end divclose;
  
  -----------------------------------------------------------------------------
  
  function div 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
  begin
    return hto.divopen(calign => calign, cattributes => cattributes) || ctext || hto.divclose;
  end div;
  
  -----------------------------------------------------------------------------
  
  procedure div 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.div
      ( ctext => ctext
      , calign => calign
      , cattributes => cattributes
      )
    ) ;
  end div;
  
  -----------------------------------------------------------------------------
  
  function spanopen 
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
    
    v_out varchar2(100) := '<SPAN';
  
  begin
    
    if calign is not null then
      v_out := v_out || ' ALIGN="' || calign || '"';
    end if;
    
    if cattributes is not null then
      v_out := v_out || ' ' || cattributes;
    end if;
    
    v_out := v_out || '>';
    
    return v_out;
    
  end spanopen;
  
  -----------------------------------------------------------------------------
  
  procedure spanopen
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.spanopen
      ( calign => calign
      , cattributes => cattributes 
      )
    );
  end spanopen;
  
  -----------------------------------------------------------------------------
    
  function spanclose
  return varchar2 is
  begin
    return '</SPAN>';
  end spanclose;
  
  -----------------------------------------------------------------------------
  
  procedure spanclose is
  begin
    htp.p(hto.spanclose);
  end spanclose;
  
  -----------------------------------------------------------------------------
  
  function span 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
  begin
    return hto.spanopen(calign => calign, cattributes => cattributes) || ctext || hto.spanclose;
  end span;
  
  -----------------------------------------------------------------------------
  
  procedure span 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.span
      ( ctext => ctext
      , calign => calign
      , cattributes => cattributes
      )
    ) ;
  end span;
  
  -----------------------------------------------------------------------------
  
  function popen 
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
    
    v_out varchar2(100) := '<P';
  
  begin
    
    if calign is not null then
      v_out := v_out || ' ALIGN="' || calign || '"';
    end if;
    
    if cattributes is not null then
      v_out := v_out || ' ' || cattributes;
    end if;
    
    v_out := v_out || '>';
    
    return v_out;
    
  end popen;
  
  -----------------------------------------------------------------------------
  
  procedure popen
  ( calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.popen
      ( calign => calign
      , cattributes => cattributes 
      )
    );
  end popen;
  
  -----------------------------------------------------------------------------
    
  function pclose
  return varchar2 is
  begin
    return '</P>';
  end pclose;
  
  -----------------------------------------------------------------------------
  
  procedure pclose is
  begin
    htp.p(hto.pclose);
  end pclose;
  
  -----------------------------------------------------------------------------
  
  function p 
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
  begin
    return hto.popen(calign => calign, cattributes => cattributes) || ctext || hto.pclose;
  end p;
  
  -----------------------------------------------------------------------------
  
  procedure p
  ( ctext in varchar2 default null
  , calign in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.p
      ( ctext => ctext
      , calign => calign
      , cattributes => cattributes
      )
    ) ;
  end p;
  
  -----------------------------------------------------------------------------
  
  function tabledataopen
  ( calign in varchar2 default null
  , ccolspan in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
    
    v_out varchar2(100) := '<TD';
  
  begin
    
    if calign is not null then
      v_out := v_out || ' ALIGN="' || calign || '"';
    end if;
    
    if ccolspan is not null then
      v_out := v_out || ' COLSPAN="' || ccolspan || '"';
    end if;
    
    if cattributes is not null then
      v_out := v_out || ' ' || cattributes;
    end if;
    
    v_out := v_out || '>';
    
    return v_out;
    
  end tabledataopen;
  
  -----------------------------------------------------------------------------
  
  procedure tabledataopen
  ( calign in varchar2 default null
  , ccolspan in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.tabledataopen
      ( calign => calign
      , ccolspan => ccolspan
      , cattributes => cattributes 
      )
    );
  end tabledataopen;
  
  -----------------------------------------------------------------------------
  
  function tabledataclose
  return varchar2 is
  begin
    return '</TD>';
  end tabledataclose;
  
  -----------------------------------------------------------------------------
  
  procedure tabledataclose is
  begin
    htp.p(hto.tabledataclose);
  end tabledataclose;
    
  -----------------------------------------------------------------------------
  
  function fieldsetopen
  ( calign in varchar2 default null
  , csize in varchar2 default null
  , clegend in varchar2 default null
  , cattributes in varchar2 default null 
  ) return varchar2 is
  
    v_out varchar2(200) := '<FIELDSET';
  
  begin
    
    if calign is not null then
      v_out := v_out || ' ALIGN="' || calign || '"';
    end if;
    
    if csize is not null then
      v_out := v_out || ' STYLE="width:' || csize || ';"';
    end if;
    
    if cattributes is not null then
      v_out := v_out || ' ' || cattributes;
    end if;
    
    v_out := v_out || '>';
    
    if clegend is not null then
      v_out := v_out || '<LEGEND>' || clegend || '</LEGEND>';
    end if;
    
    return v_out;
    
  end fieldsetopen;
  
  -----------------------------------------------------------------------------
  
  procedure fieldsetopen 
  ( calign in varchar2 default null
  , csize in varchar2 default null
  , clegend in varchar2 default null
  , cattributes in varchar2 default null 
  ) is
  begin
    htp.p( 
      hto.fieldsetopen
      ( calign => calign
      , csize => csize
      , clegend => clegend
      , cattributes => cattributes
      )
    );
  end fieldsetopen;
  
  -----------------------------------------------------------------------------
  
  function fieldsetclose
  return varchar2 is
  begin
    return '</FIELDSET>';
  end fieldsetclose;
  
  -----------------------------------------------------------------------------
  
  procedure fieldsetclose is
  begin
    htp.p(hto.fieldsetclose);
  end fieldsetclose;
  
  -----------------------------------------------------------------------------
  
  function legend
  ( clegend in varchar2 default null
  , cattributes in varchar2 default null
  ) return varchar2 is
    
    v_out varchar2(100) := '<LEGEND';
    
  begin
    
    if cattributes is not null then
      v_out := v_out || ' ' || cattributes;
    end if;
    
    v_out := v_out || '>';
    
    if clegend is not null then
      v_out := v_out || clegend;
    end if;
  
    v_out := v_out || '</LEGEND>';
    
    return v_out;
    
  end legend;
  
  -----------------------------------------------------------------------------
  
  procedure legend
  ( clegend in varchar2 default null
  , cattributes in varchar2 default null
  ) is
  begin
    htp.p(
      hto.legend
      ( clegend => clegend
      , cattributes => cattributes
      )
    );
  end legend;
  
  -----------------------------------------------------------------------------
  
  function formselectoption
  ( cvalue in varchar2
  , ctext in varchar2
  , cselected in varchar2 default null 
  ) return varchar2 is
    
    v_out varchar2(100) := '<OPTION ';
  
  begin
    
    if cselected is not null then
      v_out := v_out || 'SELECTED ';
    end if;
    
    v_out := v_out || 'VALUE="' || cvalue || '">' || ctext || '</OPTION>';
    
    return v_out;
    
  end formselectoption;
  
  -----------------------------------------------------------------------------
  
  procedure formselectoption
  ( cvalue in varchar2
  , ctext in varchar2
  , cselected in varchar2 default null 
  ) is
  begin
    htp.p(
      hto.formselectoption
      ( cvalue => cvalue
      , ctext => ctext
      , cselected => cselected
      )
    );
  end formselectoption;
  
  -----------------------------------------------------------------------------
  
end hto;
/
