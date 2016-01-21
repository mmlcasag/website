create or replace package body htf as

/* These variables are used only in escape_sc.  In the past, they
 * were declared as inline literals in each replace
 * call.  However, sqlplus would prompt for input if "set define off"
 * wasn't present, and svrmgrl would complain if "set define off" was
 * present.  Therefore, the '&' and the 'amp' (or 'quot' or whatever)
 * had to be separated.
 * They were put into these package variables in hopes that we could
 * salvage some performance; that is, instead of doing a concat with
 * each call to escape_sc (or four concats!), we only do the concats
 * once at package instantiation time.
 */
AMP  CONSTANT varchar2(10) := '&' || 'amp;';
QUOT CONSTANT varchar2(10) := '&' || 'quot;';
LT   CONSTANT varchar2(10) := '&' || 'lt;';
GT   CONSTANT varchar2(10) := '&' || 'gt;';

/* This function is private to the HTF package */
function IFNOTNULL(str1 in varchar2, str2 in varchar2) return varchar2 is
begin
   if (str1 is NULL)
     then return (NULL);
     else return (str2);
   end if;
end;

/* STRUCTURE tags */
function bodyOpen(cbackground in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BODY'||
              IFNOTNULL(cbackground,' BACKGROUND="'||cbackground||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;
/* END STRUCTURE tags */

/* HEAD Related elements tags */
function title  (ctitle in varchar2) return varchar2 is
begin return ('<TITLE>'||ctitle||'</TITLE>'); end;

function htitle(ctitle      in varchar2,
                nsize       in integer  DEFAULT 1,
                calign      in varchar2 DEFAULT NULL,
                cnowrap     in varchar2 DEFAULT NULL,
                cclear      in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return (title(ctitle)||
              header(nsize,ctitle,calign,cnowrap,cclear,cattributes)); end;

function base(  ctarget   in varchar2 DEFAULT NULL,
    cattributes   in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BASE'||
    IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
                IFNOTNULL(cattributes,' '||cattributes)||
    ' HREF="http://'||owa_util.get_cgi_env('SERVER_NAME')||':'||
                                    owa_util.get_cgi_env('SERVER_PORT')||
                                    owa_util.get_cgi_env('SCRIPT_NAME')||
                                    owa_util.get_cgi_env('PATH_INFO')||'">');
end;

function isindex(cprompt in varchar2 DEFAULT NULL,
                 curl    in varchar2 DEFAULT NULL) return varchar2 is
begin return('<ISINDEX'||
              IFNOTNULL(cprompt,' PROMPT="'||cprompt||'"')||
              IFNOTNULL(curl,' HREF="'||curl||'"')||
             '>'); end;

function linkRel(crel   in varchar2,
                 curl   in varchar2,
                 ctitle in varchar2 DEFAULT NULL) return varchar2 is
begin return('<LINK REL="'||crel||'"'||
                  ' HREF="'||curl||'"'||
               IFNOTNULL(ctitle,' TITLE="'||ctitle||'"')||
             '>'); end;

function linkRev(crev   in varchar2,
                 curl   in varchar2,
                 ctitle in varchar2 DEFAULT NULL) return varchar2 is
begin return('<LINK REV="'||crev||'"'||
                  ' HREF="'||curl||'"'||
               IFNOTNULL(ctitle,' TITLE="'||ctitle||'"')||
             '>'); end;

function meta(chttp_equiv in varchar2,
              cname       in varchar2,
              ccontent    in varchar2) return varchar2 is
begin return('<META HTTP-EQUIV="'||chttp_equiv||
                       '" NAME="'||cname||
                    '" CONTENT="'||ccontent||
                    '">');
end;

function nextid(cidentifier in varchar2) return varchar2 is
begin return ('<NEXTID N="'||cidentifier||'>'); end;

function style(cstyle in varchar2) return varchar2 is
begin return ('<STYLE>'||cstyle||'</STYLE>'); end;

function script(cscript in varchar2,
    clanguage in varchar2 DEFAULT NULL) return varchar2 is
begin return('<SCRIPT'||
        IFNOTNULL(clanguage,' LANGUAGE='''||clanguage||'''')||
        '>'||cscript||
        '</SCRIPT>');
end;

/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
function hr  (cclear      in varchar2 DEFAULT NULL,
              csrc        in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<HR'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(csrc,' SRC="'||csrc||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function line(cclear      in varchar2 DEFAULT NULL,
              csrc        in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(hr(cclear, csrc, cattributes)); end;

function br(cclear      in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BR'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function nl(cclear      in varchar2 DEFAULT NULL,
            cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(br(cclear, cattributes)); end;

function header(nsize   in integer,
                cheader in varchar2,
                calign  in varchar2 DEFAULT NULL,
                cnowrap in varchar2 DEFAULT NULL,
                cclear  in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) return varchar2 is
  ch varchar2(2);
begin
  ch := 'H'||to_char(least(abs(nsize),6));
  return('<'||ch||
                IFNOTNULL(calign,' ALIGN="'||calign||'"')||
                IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
                IFNOTNULL(cnowrap,' NOWRAP')||
                IFNOTNULL(cattributes,' '||cattributes)||
               '>'||cheader||
               '</'||ch||'>');
end;

function anchor(curl        in varchar2,
                ctext       in varchar2,
                cname       in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return( anchor2(curl,
      ctext,
      cname,
      NULL,
      cattributes));
end;

function anchor2(curl       in varchar2,
                ctext       in varchar2,
                cname       in varchar2 DEFAULT NULL,
    ctarget     in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) return varchar2 is
  curl_cname_null EXCEPTION;
begin
  if curl is NULL and cname is NULL then
                return('<!-- ERROR in anchor2 usage, curl and cname cannot be NULL --><A NAME=" "'||
                        IFNOTNULL(ctext,'> '||ctext||' </A')||
                       '>');

  end if;

  if curl is NULL then
    return('<A NAME="'||cname||'"'||
      IFNOTNULL(ctext,'> '||ctext||' </A')||
                       '>');
  else
    return('<A HREF="'||curl||'"'||
                  IFNOTNULL(cname,' NAME="'||cname||'"')||
      IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
                  IFNOTNULL(cattributes,' '||cattributes)||
                  '>'||ctext||
                  '</A>');
  end if;
end;


function mailto(caddress in varchar2,
                ctext    in varchar2,
                cname       in varchar2 DEFAULT NULL,
                cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return (anchor('mailto:'||caddress,ctext,cname,cattributes)); end;

function img(curl        in varchar2,
             calign      in varchar2 DEFAULT NULL,
             calt        in varchar2 DEFAULT NULL,
             cismap      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL
             ) return varchar2 is
begin return('<IMG SRC="'||curl||'"'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(calt,' ALT="'||calt||'"')||
               IFNOTNULL(cismap,' ISMAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function img2(curl        in varchar2,
             calign      in varchar2 DEFAULT NULL,
             calt        in varchar2 DEFAULT NULL,
             cismap      in varchar2 DEFAULT NULL,
             cusemap     in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL
             ) return varchar2 is
begin return('<IMG SRC="'||curl||'"'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(calt,' ALT="'||calt||'"')||
               IFNOTNULL(cismap,' ISMAP')||
               IFNOTNULL(cusemap,' USEMAP="'||cusemap||'"')||
               IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;


function area(  ccoords in varchar2,
              cshape  in varchar2 DEFAULT NULL,
              chref in varchar2 DEFAULT NULL,
              cnohref in varchar2 DEFAULT NULL,
    ctarget in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<AREA'||
    IFNOTNULL(cshape,' SHAPE="'||cshape||'"')||
    ' COORDS="'||ccoords||'"'||
                IFNOTNULL(chref,' HREF="'||chref||'"')||
                IFNOTNULL(cnohref,' NOHREF')||
                IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
    IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function mapOpen(cname  in varchar2,cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<MAP NAME="'||cname||'"'||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>'); end;

function bgsound(csrc in varchar2,
     cloop  in varchar2 DEFAULT NULL,
     cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BGSOUND SRC="'||csrc||'"'||
    IFNOTNULL(cloop,' LOOP="'||cloop||'"')||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>');end;


function paragraph(calign       in varchar2 DEFAULT NULL,
                   cnowrap      in varchar2 DEFAULT NULL,
                   cclear       in varchar2 DEFAULT NULL,
                   cattributes  in varchar2 DEFAULT NULL) return varchar2 is
begin return('<P'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cnowrap,' NOWRAP')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function div( calign       in varchar2 DEFAULT NULL,
                cattributes  in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DIV'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function address(cvalue       in varchar2,
                 cnowrap      in varchar2 DEFAULT NULL,
                 cclear       in varchar2 DEFAULT NULL,
                 cattributes  in varchar2 DEFAULT NULL) return varchar2 is
begin return('<ADDRESS'||
               IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
             '>'||cvalue||
             '</ADDRESS>'); end;

function comment(ctext in varchar2) return varchar2 is
begin return('<!-- '||ctext||' -->'); end;

function preOpen(cclear      in varchar2 DEFAULT NULL,
                 cwidth      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<PRE'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cwidth,' WIDTH="'||cwidth||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function nobr(ctext in varchar2) return varchar2 is
begin return('<NOBR>'||ctext||'</NOBR>'); end;

function center(ctext in varchar2) return varchar2 is
begin return('<CENTER>'||ctext||'</CENTER>'); end;


function blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                        cclear       in varchar2 DEFAULT NULL,
                        cattributes  in varchar2 DEFAULT NULL) return varchar2
 is
begin return('<BLOCKQUOTE'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cnowrap,' NOWRAP')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

/* LIST tags */
function listHeader(ctext in varchar2,
                    cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<LH'||
              IFNOTNULL(cattributes,' '||cattributes)||
            '>'||ctext||
            '</LH>'); end;

function listItem(ctext       in varchar2 DEFAULT NULL,
                  cclear      in varchar2 DEFAULT NULL,
                  cdingbat    in varchar2 DEFAULT NULL,
                  csrc        in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<LI'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cdingbat,' DINGBAT="'||cdingbat||'"')||
              IFNOTNULL(csrc,' SRC="'||csrc||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext);
end;

function ulistOpen(cclear      in varchar2 DEFAULT NULL,
                   cwrap       in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<UL'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cdingbat,' DINGBAT="'||cdingbat||'"')||
              IFNOTNULL(csrc,' SRC="'||csrc||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function olistOpen(cclear      in varchar2 DEFAULT NULL,
                   cwrap       in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<OL'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function dlistOpen(cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DL'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function dlistTerm(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DT'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext);
end;

function dlistDef(ctext       in varchar2 DEFAULT NULL,
                  cclear      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DD'||
              IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext);
end;
/* END LIST tags */

/* SEMANTIC FORMAT ELEMENTS */
function dfn(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<DFN'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</DFN>'); end;

function cite(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<CITE'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</CITE>'); end;

function code(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<CODE'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</CODE>'); end;

function em   (ctext  in varchar2,
               cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<EM'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</EM>'); end;

function emphasis(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(em(ctext,cattributes)); end;

function kbd(ctext in varchar2,
             cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<KBD'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</KBD>'); end;

function keyboard(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(kbd(ctext,cattributes)); end;

function sample(ctext in varchar2,
                cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<SAMP'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SAMP>'); end;

function strong   (ctext  in varchar2,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<STRONG'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</STRONG>'); end;

function variable(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<VAR'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</VAR>'); end;

function big( ctext     in varchar2,
                cattributes   in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BIG'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</BIG>'); end;

function small( ctext     in varchar2,
                cattributes   in varchar2 DEFAULT NULL) return varchar2 is
begin return('<SMALL'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SMALL>'); end;

function sub(   ctext     in varchar2,
    calign    in varchar2 DEFAULT NULL,
                cattributes   in varchar2 DEFAULT NULL) return varchar2 is
begin return('<SUB'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SUB>'); end;

function sup( ctext     in varchar2,
    calign    in varchar2 DEFAULT NULL,
                cattributes   in varchar2 DEFAULT NULL) return varchar2 is
begin return('<SUP'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</SUP>'); end;

/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
function basefont(nsize in integer,
      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<BASEFONT SIZE="'||nsize||'"'||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>'); end;


function fontOpen(  ccolor  in varchar2 DEFAULT NULL,
    cface in varchar2 DEFAULT NULL,
    csize in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<FONT'||
    IFNOTNULL(ccolor,' COLOR="'||ccolor||'"')||
    IFNOTNULL(cface,' FACE="'||cface||'"')||
    IFNOTNULL(csize,' SIZE="'||csize||'"')||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>');end;

function bold   (ctext  in varchar2,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<B'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</B>'); end;

function italic (ctext  in varchar2,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<I'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</I>'); end;

function teletype(ctext in varchar2,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<TT'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</TT>'); end;

function plaintext   (ctext  in varchar2,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<PLAINTEXT'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</PLAINTEXT>'); end;
function s   (ctext  in varchar2,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<S'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</S>'); end;
function strike   (ctext  in varchar2,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<STRIKE'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</STRIKE>'); end;
function underline   (ctext  in varchar2,
                 cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<U'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||ctext||'</U>'); end;
/* END PHYSICAL FORMAT ELEMENTS */


/* HTML FORMS */

function formOpen(curl in varchar2,
                  cmethod  in varchar2 DEFAULT 'POST',
      ctarget  in varchar2 DEFAULT NULL,
      cenctype in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<FORM ACTION="'||curl||'" METHOD="'||cmethod||'"'||
    IFNOTNULL(ctarget,' TARGET="'||ctarget||'"')||
    IFNOTNULL(cenctype,' ENCTYPE="'||cenctype||'"')||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>'); end;

function formCheckbox(cname in varchar2,
                      cvalue      in varchar2 DEFAULT 'on',
                      cchecked    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin
   return('<INPUT TYPE="checkbox" NAME="'||cname||'"'||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cchecked,' CHECKED')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>');
end;

function formFile(cname       in varchar2,
                  caccept     in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="file"'||
              IFNOTNULL(cname,' NAME="'||cname||'"')||
              IFNOTNULL(caccept,' ACCEPT="'||caccept||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function formHidden(cname       in varchar2,
                    cvalue      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin
   return('<INPUT TYPE="hidden" NAME="'||cname||'"'||' VALUE="'||cvalue||'"'||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>');
end;

function formImage(cname       in varchar2,
                   csrc        in varchar2,
                   calign      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="image" NAME="'||cname||'"'||
                                 ' SRC="'||csrc||'"'||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function formPassword(cname       in varchar2,
                      csize       in varchar2 DEFAULT NULL,
                      cmaxlength  in varchar2 DEFAULT NULL,
                      cvalue      in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin
   return('<INPUT TYPE="password" NAME="'||cname||'"'||
           IFNOTNULL(csize,' SIZE="'||csize||'"')||
           IFNOTNULL(cmaxlength,' MAXLENGTH="'||cmaxlength||'"')||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>');
end;

function formRadio(cname       in varchar2,
                   cvalue      in varchar2,
                   cchecked    in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="radio" NAME="'||cname||'"'||
                               ' VALUE="'||cvalue||'"'||
              IFNOTNULL(cchecked,' CHECKED')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;

function formReset(cvalue      in varchar2 DEFAULT 'Reset',
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="reset" VALUE="'||cvalue||'"'||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function formSubmit(cname       in varchar2 DEFAULT NULL,
                    cvalue      in varchar2 DEFAULT 'Submit',
                    cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<INPUT TYPE="submit"'||
              IFNOTNULL(cname,' NAME="'||cname||'"')||
              IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'); end;

function formText(cname       in varchar2,
                  csize       in varchar2 DEFAULT NULL,
                  cmaxlength  in varchar2 DEFAULT NULL,
                  cvalue      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin
/*   return('<INPUT TYPE="text" NAME="'||cname||'"'||
           IFNOTNULL(csize,' SIZE="'||csize||'"')||
           IFNOTNULL(cmaxlength,' MAXLENGTH="'||cmaxlength||'"')||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>');*/
          
  return('<INPUT TYPE="text"'||
           IFNOTNULL(cname, ' NAME="'||cname||'"')||
           IFNOTNULL(csize,' SIZE="'||csize||'"')||
           IFNOTNULL(cmaxlength,' MAXLENGTH="'||cmaxlength||'"')||
           IFNOTNULL(cvalue,' VALUE="'||cvalue||'"')||
           IFNOTNULL(cattributes,' '||cattributes)||
          '>');          
end;

function formSelectOpen(cname       in varchar2,
                        cprompt     in varchar2 DEFAULT NULL,
                        nsize       in integer  DEFAULT NULL,
                        cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return(cprompt||
            '<SELECT NAME="'||cname||'"'||
             IFNOTNULL(nsize,' SIZE="'||nsize||'"')||
             IFNOTNULL(cattributes,' '||cattributes)||
            '>');
end;

function formSelectOption(cvalue      in varchar2,
                          cselected   in varchar2 DEFAULT NULL,
                          cattributes in varchar2) return varchar2 is
begin return('<OPTION'||
              IFNOTNULL(cselected,' SELECTED')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>'||cvalue); end;

function formTextarea(cname       in varchar2,
                      nrows       in integer,
                      ncolumns    in integer,
                      calign      in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '></TEXTAREA>');
end;


function formTextarea2(cname       in varchar2,
                      nrows       in integer,
                      ncolumns    in integer,
                      calign      in varchar2 DEFAULT NULL,
                      cwrap       in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '></TEXTAREA>');
end;

function formTextareaOpen(cname       in varchar2,
                          nrows       in integer,
                          ncolumns    in integer,
                          calign      in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) return varchar2
 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;


function formTextareaOpen2(cname       in varchar2,
                          nrows       in integer,
                          ncolumns    in integer,
                          calign      in varchar2 DEFAULT NULL,
                          cwrap       in varchar2 DEFAULT NULL,
                          cattributes in varchar2 DEFAULT NULL) return varchar2
 is
begin return('<TEXTAREA NAME="'||cname||'"'||
                      ' ROWS='||to_char(nrows)||
                      ' COLS='||to_char(ncolumns)||
              IFNOTNULL(calign,' ALIGN="'||calign||'"')||
              IFNOTNULL(cwrap,' WRAP="'||cwrap||'"')||
              IFNOTNULL(cattributes,' '||cattributes)||
             '>');
end;
/* END HTML FORMS */

/* HTML TABLES */
function tableOpen(cborder     in varchar2 DEFAULT NULL,
                   calign      in varchar2 DEFAULT NULL,
                   cnowrap     in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return ('<TABLE '||
               IFNOTNULL(cborder,' '||cborder)||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cclear,' CLEAR="'||cclear||'"')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'); end;

function tableCaption(ccaption in varchar2,
                      calign   in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return ('<CAPTION'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'||
              ccaption||'</CAPTION>'); end;

function tableRowOpen(calign      in varchar2 DEFAULT NULL,
                      cvalign     in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return ('<TR'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cvalign,' VALIGN="'||cvalign||'"')||
               IFNOTNULL(cdp,' DP="'||cdp||'"')||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'); end;

function tableHeader(cvalue      in varchar2 DEFAULT NULL,
                     calign      in varchar2 DEFAULT NULL,
                     cdp         in varchar2 DEFAULT NULL,
                     cnowrap     in varchar2 DEFAULT NULL,
                     crowspan    in varchar2 DEFAULT NULL,
                     ccolspan    in varchar2 DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return ('<TH'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cdp,' DP="'||cdp||'"')||
               IFNOTNULL(crowspan,' ROWSPAN="'||crowspan||'"')||
               IFNOTNULL(ccolspan,' COLSPAN="'||ccolspan||'"')||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'||
              cvalue||'</TH>'); end;

function tableData(cvalue      in varchar2 DEFAULT NULL,
                   calign      in varchar2 DEFAULT NULL,
                   cdp         in varchar2 DEFAULT NULL,
                   cnowrap     in varchar2 DEFAULT NULL,
                   crowspan    in varchar2 DEFAULT NULL,
                   ccolspan    in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return ('<TD'||
               IFNOTNULL(calign,' ALIGN="'||calign||'"')||
               IFNOTNULL(cdp,' DP="'||cdp||'"')||
               IFNOTNULL(crowspan,' ROWSPAN="'||crowspan||'"')||
               IFNOTNULL(ccolspan,' COLSPAN="'||ccolspan||'"')||
               IFNOTNULL(cnowrap,' NOWRAP')||
               IFNOTNULL(cattributes,' '||cattributes)||
              '>'||
              cvalue||'</TD>'); end;

function format_cell(
   columnValue in varchar2, format_numbers in varchar2 default null
) return varchar2 is
   dummy    number;
   function tochar(d in number, f in varchar2) return varchar2 is
   begin
      return nvl(ltrim(to_char(d,f)), '(null)');
   end tochar;
begin
   if (format_numbers is NULL) then
      return(tableData(columnValue));
   end if;

   dummy := to_number(columnValue);
   if (trunc(dummy) = dummy) then
      return(tableData(tochar(dummy,'999,999,999,999'), 'right'));
   else
      return(tableData(tochar(dummy,'999,999,990.99'), 'right'));
   end if;
   exception
   when others then
       return(tableData(nvl(columnValue, '(null)')));
end format_cell;
/* END HTML TABLES */

/* BEGIN HTML FRAMES - Netscape Extensions FRAMESET, FRAME tags */
function framesetOpen(  crows in varchar2 DEFAULT NULL,     /* row height value list */
      ccols in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL) return varchar2 is  /* column width list */
begin
 return('<FRAMESET'||
  IFNOTNULL(crows, ' ROWS="'||crows||'"')||
  IFNOTNULL(ccols, ' COLS="'||ccols||'"')||
  IFNOTNULL(cattributes,' '||cattributes)||
  '>');
end framesetOpen;


function frame(   csrc  in varchar2,        /* URL */
      cname in varchar2 DEFAULT NULL,   /* Window name */
      cmarginwidth  in varchar2 DEFAULT NULL, /* value in pixels */
      cmarginheight in varchar2 DEFAULT NULL, /* value in pixels */
      cscrolling  in varchar2 DEFAULT NULL, /* yes | no | auto */
      cnoresize in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL) return varchar2 is  /* user cannot resize frame */
begin
 return('<FRAME SRC="'||csrc||'"'||
  IFNOTNULL(cname, ' NAME="'||cname||'"')||
  IFNOTNULL(cmarginwidth, ' MARGINWIDTH="'||cmarginwidth||'"')||
  IFNOTNULL(cmarginheight, ' MARGINHEIGHT="'||cmarginheight||'"')||
  IFNOTNULL(cscrolling, ' SCROLLING="'||cscrolling||'"')||
  IFNOTNULL(cnoresize, ' NORESIZE')||
  IFNOTNULL(cattributes,' '||cattributes)||
  '>');
end frame;


/* END HTML FRAMES */

/* SPECIAL HTML TAGS */
function appletOpen(ccode   in varchar2,
        cwidth  in integer,
        cheight in integer,
        cattributes in varchar2 DEFAULT NULL) return varchar2 is
begin return('<APPLET CODE='||ccode||
    ' WIDTH='||cwidth||
    ' HEIGHT='||cheight||
    IFNOTNULL(cattributes,' '||cattributes)||
    '>');
end;

function param(cname  in varchar2,
         cvalue in varchar2) return varchar2 is
begin return('<PARAM NAME='||cname||' VALUE= "'||cvalue||
    '" >');
end;

/* END SPECIAL HTML TAGS */

/* SPECIAL FUNCTIONS */
function escape_sc(ctext in varchar2) return varchar2 IS
begin return(replace(
             replace(
             replace(
             replace(ctext, '&', AMP),
                            '"', QUOT),
                            '<', LT),
                            '>', GT));
end;

function escape_url(p_url in varchar2) return varchar2 is
begin
        return replace(escape_sc(p_url), '%', '%25');
end;
/* END SPECIAL FUNCTIONS */

/* END BODY ELEMENT tags */
end;
/
