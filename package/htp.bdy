create or replace package body htp as

   /* The broken line below is intentional */
   NL_CHAR    constant  varchar2(1) := '
';
   NLNL_CHAR  constant  varchar2(2) := '

';
   htcurline  varchar2(256) := ''; -- htbuf_arr element size
   htbuf      htbuf_arr;
   rows_in    number;
   rows_out   number;
   pack_after constant number := 60;

   sContentType   constant varchar2(16) := 'CONTENT-TYPE:';
   sContentLength constant varchar2(16) := 'CONTENT-LENGTH:';
   sLocation    constant varchar2(16) := 'LOCATION:';
   sStatus    constant varchar2(16) := 'STATUS:';
   sTextHtml    constant varchar2(16) := 'text/html';

   nContentTypeLen  constant number := length(sContentType);
   nContentLengthLen  constant number := length(sContentLength);
   nLocationLen   constant number := length(sLocation);
   nStatusLen   constant number := length(sStatus);

   bAddDefaultHTMLHdr   boolean := TRUE;
   bHTMLPageReady boolean := FALSE;
   bHasHTMLHdr    boolean := FALSE;
   bHasContentLength  boolean := FALSE;
   nEndOfHdrIx    binary_integer := -1;
   nContentLengthIx binary_integer := -1;

   sDownloadFilesList     varchar2(256); -- for file download feature
   nCompressDownloadFiles binary_integer;

   bFirstCall           boolean := TRUE;

/* STRUCTURE tags */
procedure htmlOpen is
begin p(htf.htmlOpen); end;

procedure htmlClose is
begin p(htf.htmlClose); end;

procedure headOpen is
begin p(htf.headOpen); end;

procedure headClose is
begin p(htf.headClose); end;

procedure bodyOpen(cbackground in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.bodyOpen(cbackground,cattributes)); end;

procedure bodyClose is
begin p(htf.bodyClose); end;
/* END STRUCTURE tags */

/* HEAD Related elements tags */
procedure title  (ctitle in varchar2) is
begin p(htf.title(ctitle)); end;

procedure htitle(ctitle      in varchar2,
                 nsize       in integer  DEFAULT 1,
                 calign      in varchar2 DEFAULT NULL,
                 cnowrap     in varchar2 DEFAULT NULL,
                 cclear      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.htitle(ctitle,nsize,calign,cnowrap,cclear,cattributes)); end;

procedure base( ctarget   in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.base(ctarget,cattributes)); end;

procedure isindex(cprompt in varchar2 DEFAULT NULL,
                  curl    in varchar2 DEFAULT NULL) is
begin p(htf.isindex(cprompt, curl)); end;

procedure linkRel(crel   in varchar2,
                  curl   in varchar2,
                  ctitle in varchar2 DEFAULT NULL) is
begin p(htf.linkRel(crel, curl, ctitle)); end;

procedure linkRev(crev   in varchar2,
                  curl   in varchar2,
                  ctitle in varchar2 DEFAULT NULL) is
begin p(htf.linkRev(crev, curl, ctitle)); end;

procedure meta(chttp_equiv in varchar2,
               cname       in varchar2,
               ccontent    in varchar2) is
begin p(htf.meta(chttp_equiv, cname, ccontent)); end;

procedure nextid(cidentifier in varchar2) is
begin p(htf.nextid(cidentifier)); end;

procedure style(cstyle in varchar2) is
begin p(htf.style(cstyle)); end;

procedure script(cscript  in varchar2,
     clanguage  in varchar2 DEFAULT NULL) is
begin p(htf.script(cscript, clanguage)); end;

/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
procedure hr  (cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.hr(cclear, csrc, cattributes)); end;

procedure line(cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is
begin htp.hr(cclear, csrc, cattributes); end;

procedure nl  (cclear      in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.nl(cclear,cattributes)); end;

procedure br  (cclear      in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL) is
begin htp.nl(cclear,cattributes); end;

procedure header(nsize   in integer,
                 cheader in varchar2,
                 calign  in varchar2 DEFAULT NULL,
                 cnowrap in varchar2 DEFAULT NULL,
                 cclear  in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.header(nsize,cheader,calign,cnowrap,cclear,cattributes)); end;

procedure anchor(curl        in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.anchor(curl,ctext,cname,cattributes)); end;

procedure anchor2(curl        in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
     ctarget     in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.anchor2(curl,ctext,cname,ctarget,cattributes)); end;

procedure mailto(caddress    in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.mailto(caddress,ctext,cname,cattributes)); end;

procedure img(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) is
begin p(htf.img(curl,calign,calt,cismap,cattributes)); end;

procedure img2(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cusemap     in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL) is
begin p(htf.img2(curl,calign,calt,cismap,cusemap,cattributes)); end;

procedure area( ccoords in varchar2,
                cshape  in varchar2 DEFAULT NULL,
                chref in varchar2 DEFAULT NULL,
              cnohref in varchar2 DEFAULT NULL,
    ctarget in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.area(ccoords,cshape,chref,cnohref,ctarget,cattributes));end;

procedure mapOpen(cname in varchar2,cattributes in varchar2 DEFAULT NULL) is
begin p(htf.mapOpen(cname,cattributes)); end;
procedure mapClose is
begin p(htf.mapClose); end;

procedure bgsound(csrc  in varchar2,
      cloop in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL) is
begin p(htf.bgsound(csrc,cloop,cattributes));end;

procedure para is
begin p(htf.para); end;

procedure paragraph(calign       in varchar2 DEFAULT NULL,
                    cnowrap      in varchar2 DEFAULT NULL,
                    cclear       in varchar2 DEFAULT NULL,
                    cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.paragraph(calign,cnowrap,cclear,cattributes)); end;

procedure div(  calign       in varchar2 DEFAULT NULL,
                cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.div(calign,cattributes)); end;

procedure address(cvalue       in varchar2,
                  cnowrap      in varchar2 DEFAULT NULL,
                  cclear       in varchar2 DEFAULT NULL,
                  cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.address(cvalue, cnowrap, cclear, cattributes)); end;

procedure comment(ctext in varchar2) is
begin p(htf.comment(ctext)); end;

procedure preOpen(cclear      in varchar2 DEFAULT NULL,
                  cwidth      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.preOpen(cclear,cwidth,cattributes)); end;

procedure preClose is
begin p(htf.preClose); end;

procedure listingOpen is
begin p(htf.listingOpen); end;
procedure listingClose is
begin p(htf.listingClose); end;

procedure nobr(ctext in varchar2) is
begin p(htf.nobr(ctext)); end;
procedure wbr is
begin p(htf.wbr); end;

procedure center(ctext in varchar2) is
begin p(htf.center(ctext)); end;

procedure centerOpen is
begin p(htf.centerOpen); end;

procedure centerClose is
begin p(htf.centerClose); end;



procedure blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                         cclear       in varchar2 DEFAULT NULL,
                         cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.blockquoteOpen(cnowrap,cclear,cattributes)); end;

procedure blockquoteClose is
begin p(htf.blockquoteClose); end;

/* LIST tags */
procedure listHeader(ctext in varchar2,
                     cattributes in varchar2 DEFAULT NULL) is
begin p(htf.listHeader(ctext,cattributes)); end;

procedure listItem(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.listItem(ctext,cclear,cdingbat,csrc,cattributes)); end;

procedure ulistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cdingbat    in varchar2 DEFAULT NULL,
                    csrc        in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.ulistOpen(cclear,cwrap,cdingbat,csrc,cattributes)); end;

procedure ulistClose is
begin p(htf.ulistClose); end;

procedure olistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.olistOpen(cclear,cwrap,cattributes)); end;

procedure olistClose is
begin p(htf.olistClose); end;

procedure dlistOpen(cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.dlistOpen(cclear,cattributes)); end;

procedure dlistTerm(ctext       in varchar2 DEFAULT NULL,
                    cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.dlistTerm(ctext,cclear,cattributes)); end;

procedure dlistDef(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.dlistDef(ctext,cclear,cattributes)); end;

procedure dlistClose is
begin p(htf.dlistClose); end;

procedure menulistOpen is
begin p(htf.menulistOpen); end;

procedure menulistClose is
begin p(htf.menulistClose); end;

procedure dirlistOpen is
begin p(htf.dirlistOpen); end;

procedure dirlistClose is
begin p(htf.dirlistClose); end;
/* END LIST tags */

/* SEMANTIC FORMAT ELEMENTS */
procedure dfn(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.dfn(ctext,cattributes)); end;

procedure cite(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.cite(ctext,cattributes)); end;

procedure code(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) is
begin p(htf.code(ctext,cattributes)); end;

procedure em(ctext  in varchar2,
             cattributes in varchar2 DEFAULT NULL) is
begin p(htf.em(ctext,cattributes)); end;

procedure emphasis(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.emphasis(ctext,cattributes)); end;

procedure kbd(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) is
begin p(htf.kbd(ctext,cattributes)); end;

procedure keyboard(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.keyboard(ctext,cattributes)); end;

procedure sample(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) is
begin p(htf.sample(ctext,cattributes)); end;

procedure strong (ctext  in varchar2,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.strong(ctext,cattributes)); end;

procedure variable(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.variable(ctext,cattributes)); end;

procedure big(  ctext     in varchar2,
                cattributes   in varchar2 DEFAULT NULL) is
begin p(htf.big(ctext,cattributes)); end;

procedure small(ctext     in varchar2,
                cattributes   in varchar2 DEFAULT NULL) is
begin p(htf.small(ctext,cattributes)); end;

procedure sub(  ctext     in varchar2,
    calign    in varchar2 DEFAULT NULL,
                cattributes   in varchar2 DEFAULT NULL) is
begin p(htf.sub(ctext,calign,cattributes)); end;

procedure sup(  ctext     in varchar2,
    calign    in varchar2 DEFAULT NULL,
                cattributes   in varchar2 DEFAULT NULL) is
begin p(htf.sup(ctext,calign,cattributes)); end;


/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
procedure basefont(nsize in integer) is
begin p(htf.basefont(nsize));end;

procedure fontOpen(ccolor in varchar2 DEFAULT NULL,
       cface  in varchar2 DEFAULT NULL,
       csize  in varchar2 DEFAULT NULL,
       cattributes  in varchar2 DEFAULT NULL) is
begin p(htf.fontOpen(ccolor,cface,csize,cattributes)); end;

procedure fontClose is
begin p(htf.fontClose); end;

procedure bold   (ctext  in varchar2,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.bold(ctext,cattributes)); end;

procedure italic (ctext  in varchar2,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.italic(ctext,cattributes)); end;

procedure teletype(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.teletype(ctext,cattributes)); end;

procedure plaintext(ctext  in varchar2,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.plaintext(ctext,cattributes)); end;

procedure s(ctext  in varchar2,
            cattributes in varchar2 DEFAULT NULL) is
begin p(htf.s(ctext,cattributes)); end;

procedure strike (ctext  in varchar2,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.strike(ctext,cattributes)); end;

procedure underline (ctext  in varchar2,
                  cattributes in varchar2 DEFAULT NULL) is
begin p(htf.underline(ctext,cattributes)); end;

/* END PHYSICAL FORMAT ELEMENTS */

/* HTML FORMS */

procedure formOpen(curl     in varchar2,
                   cmethod  in varchar2 DEFAULT 'POST',
       ctarget  in varchar2 DEFAULT NULL,
       cenctype in varchar2 DEFAULT NULL,
       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formOpen(curl,cmethod,ctarget,cenctype,cattributes)); end;

procedure formCheckbox(cname       in varchar2,
                       cvalue      in varchar2 DEFAULT 'on',
                       cchecked    in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formCheckbox(cname,cvalue,cchecked,cattributes)); end;

procedure formFile(cname       in varchar2,
                   caccept     in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formFile(cname,caccept,cattributes)); end;

procedure formHidden(cname       in varchar2,
                     cvalue      in varchar2 DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formHidden(cname,cvalue,cattributes)); end;

procedure formImage(cname       in varchar2,
                    csrc        in varchar2,
                    calign      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formImage(cname,csrc,calign,cattributes)); end;

procedure formPassword(cname       in varchar2,
                       csize       in varchar2 DEFAULT NULL,
                       cmaxlength  in varchar2 DEFAULT NULL,
                       cvalue      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formPassword(cname,csize,cmaxlength,cvalue,cattributes)); end;

procedure formRadio(cname       in varchar2,
                    cvalue      in varchar2,
                    cchecked    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formRadio(cname,cvalue,cchecked,cattributes)); end;

procedure formReset(cvalue      in varchar2 DEFAULT 'Reset',
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formReset(cvalue,cattributes)); end;

procedure formSubmit(cname       in varchar2 DEFAULT NULL,
                     cvalue      in varchar2 DEFAULT 'Submit',
                     cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formSubmit(cname,cvalue,cattributes)); end;

procedure formText(cname       in varchar2,
                   csize       in varchar2 DEFAULT NULL,
                   cmaxlength  in varchar2 DEFAULT NULL,
                   cvalue      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formText(cname,csize,cmaxlength,cvalue,cattributes)); end;

procedure formSelectOpen(cname       in varchar2,
                         cprompt     in varchar2 DEFAULT NULL,
                         nsize       in integer  DEFAULT NULL,
                         cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formSelectOpen(cname,cprompt,nsize,cattributes)); end;

procedure formSelectOption(cvalue      in varchar2,
                           cselected   in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formSelectOption(cvalue,cselected,cattributes)); end;

procedure formSelectClose is
begin p(htf.formSelectClose); end;

procedure formTextarea(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextarea(cname,nrows,ncolumns,calign,cattributes)); end;


procedure formTextarea2(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
                       cwrap       in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextarea2(cname,nrows,ncolumns,calign,cwrap,cattributes)); end;


procedure formTextareaOpen(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextareaOpen(cname,nrows,ncolumns,calign,cattributes)); end;


procedure formTextareaOpen2(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
                           cwrap       in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL) is
begin p(htf.formTextareaOpen2(cname,nrows,ncolumns,calign,cwrap,cattributes)); end;

procedure formTextareaClose is
begin p(htf.formTextareaClose); end;

procedure formClose is
begin p(htf.formClose); end;
/* END HTML FORMS */

/* HTML TABLES */
procedure tableOpen(cborder in varchar2 DEFAULT NULL,
                   calign in varchar2 DEFAULT NULL,
                   cnowrap in varchar2 DEFAULT NULL,
                   cclear in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableOpen(cborder,calign,cnowrap,cclear,cattributes)); end;

procedure tableCaption(ccaption    in varchar2,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableCaption(ccaption,calign,cattributes)); end;

procedure tableRowOpen(calign      in varchar2 DEFAULT NULL,
                       cvalign     in varchar2 DEFAULT NULL,
                       cdp         in varchar2 DEFAULT NULL,
                       cnowrap     in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableRowOpen(calign,cvalign,cdp,cnowrap,cattributes)); end;

procedure tableHeader(cvalue      in varchar2 DEFAULT NULL,
                      calign      in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      crowspan    in varchar2 DEFAULT NULL,
                      ccolspan    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableHeader(cvalue,calign,cdp,cnowrap,
                        crowspan,ccolspan,cattributes)); end;

procedure tableData(cvalue      in varchar2 DEFAULT NULL,
                    calign      in varchar2 DEFAULT NULL,
                    cdp         in varchar2 DEFAULT NULL,
                    cnowrap     in varchar2 DEFAULT NULL,
                    crowspan    in varchar2 DEFAULT NULL,
                    ccolspan    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL) is
begin p(htf.tableData(cvalue,calign,cdp,cnowrap,
                      crowspan,ccolspan,cattributes)); end;

procedure tableRowClose is
begin p(htf.tableRowClose); end;

procedure tableClose is
begin p(htf.tableClose); end;
/* END HTML TABLES */

/* BEGIN HTML FRAMES - Netscape Extensions FRAMESET, FRAME tags */
procedure framesetOpen( crows in varchar2 DEFAULT NULL, /* row height value list */
      ccols in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL) is  /* column width list */
begin
 p(htf.framesetOpen( crows, ccols, cattributes ));
end framesetOpen;

procedure framesetClose is
begin
 p(htf.framesetClose);
end framesetClose;

procedure frame(  csrc  in varchar2,        /* URL */
      cname in varchar2 DEFAULT NULL,   /* Window Name */
      cmarginwidth  in varchar2 DEFAULT NULL, /* Value in pixels */
      cmarginheight in varchar2 DEFAULT NULL, /* Value in pixels */
      cscrolling  in varchar2 DEFAULT NULL, /* yes | no | auto */
      cnoresize in varchar2 DEFAULT NULL,
      cattributes   in varchar2 DEFAULT NULL) is  /* Not resizable by user */
begin
 p(htf.frame( csrc, cname, cmarginwidth, cmarginheight, cscrolling, cnoresize, cattributes ));
end frame;

procedure noframesOpen is
begin
 p(htf.noframesOpen);
end noframesOpen;

procedure noframesClose is
begin
 p(htf.noframesClose);
end noframesClose;

/* END HTML FRAMES */

/* SPECIAL HTML TAGS */
procedure appletOpen( ccode   in varchar2,
      cwidth    in integer,
      cheight   in integer,
      cattributes in varchar2 DEFAULT NULL) is
begin p(htf.appletOpen(ccode,cwidth,cheight,cattributes));end;

procedure param(  cname   in varchar2,
      cvalue    in varchar2) is
begin p(htf.param(cname,cvalue));end;

procedure appletClose is
begin p(htf.appletClose);end;

/* END SPECIAL HTML TAGS */


/* SPECIAL PROCEDURES */
function getContentLength return number is
   len      binary_integer := 0;
   nFromIx  binary_integer;
begin
   -- Check to see if we have a BLOB download, and if so,
   -- return the length of the BLOB
   IF (wpg_docload.is_file_download)
   THEN
      RETURN wpg_docload.get_content_length;
   END IF;

   nFromIx := nEndOfHdrIx + 1;
   for nIx in nFromIx..rows_in
   loop
      len := len + lengthb(htbuf(nIx)); -- use lengthb to get in bytes
   end loop;
   return(len);
end getContentLength;

procedure init is
begin
   rows_in := 0;
   rows_out := 0;
   htbuf.delete;
   htcurline := '';

   bAddDefaultHTMLHdr := TRUE;
   bHTMLPageReady := FALSE;
   bHasHTMLHdr := FALSE;
   bHasContentLength := FALSE;
   nEndOfHdrIx := -1;
   nContentLengthIx := -1;

   sDownloadFilesList := '';
   nCompressDownloadFiles := 0;

   addDefaultHTMLHdr(TRUE);

   bFirstCall := TRUE;
end init;

procedure flush is
begin
   if (htcurline is not null)
   then
      rows_in := rows_in + 1;
      htbuf(rows_in) := htcurline;
      htcurline := '';
   end if;
   if (not bHTMLPageReady)
   then
      if (nEndOfHdrIx < 0) -- how come?
      then
         nEndOfHdrIx := rows_in;
      end if;
      if (nContentLengthIx > 0)
      then
         htbuf(nContentLengthIx) := 'Content-length: '
            || getContentLength || NL_CHAR;
      end if;
      bHTMLPageReady := TRUE;
   end if;
end flush;

function get_line (irows out integer) return varchar2 is
   cnt      number;
begin
   flush;

   cnt := rows_in - rows_out;

   if (cnt > 1)
   then
      irows := 1;
   else
      irows := 0;
      if (cnt < 1)
      then
         return(NULL);
      end if;
   end if;

   rows_out := rows_out + 1;
   return(htbuf(rows_out));
end;

procedure get_page (thepage     out htbuf_arr,
                    irows    in out integer ) is
begin
   flush;

   irows := least(irows, rows_in - rows_out);
   if (irows = 0)
   then
      return;
   end if;

   for i in 1..irows
   loop
      thepage(i) := htbuf(rows_out + i);
   end loop;

   rows_out := rows_out + irows;
end;

procedure showpage is
   dbms_buf_size integer;

   buffer   varchar2(510);    /* size = 255 * 2 */
   i        integer;

   sp_loc   integer;
   nl_loc   integer;
begin
   /* First figure out how large to make the dbms_output buffer */
   dbms_buf_size := (rows_in - rows_out)*255;
   if (dbms_buf_size > 1000000)
   then
      dbms_output.enable(1000000);
   else
      dbms_output.enable(dbms_buf_size);
   end if;

   /* Now, loop through, adding lines from htbuf, but   */
   /* never getting larger than 510 characters.         */
   /* If a newline is found, print everything and clear */
   /* the buffer, otherwise, break on the last space    */
   /* possible.  If the last space is past 255 chars,   */
   /* or there is no space at all, then break on 255.   */
   flush;

   buffer := NULL;
   i := rows_out + 1;
   while (i <= rows_in)
   loop
      if (nvl(length(buffer),0) <= 255)
      then
         buffer := buffer || htbuf(i);
         i := i + 1;
      end if;

      nl_loc := instr(buffer, NL_CHAR, -1);
      if (nl_loc = 0)
      then
         sp_loc := instr(buffer, ' ', -1);
         if (sp_loc = 0)
         then
            dbms_output.put_line(substr(buffer, 1, 255));
            buffer := substr(buffer,256);
         else
            if (sp_loc <= 255)
            then
               dbms_output.put_line(substr(buffer, 1, sp_loc - 1));
               buffer := substr(buffer, sp_loc + 1);
            else  /* sp_loc > 255 */
               dbms_output.put_line(substr(buffer, 1, 255));
               buffer := substr(buffer, 256);
            end if;
         end if;
      else
         /* Always strip out the newlines */
         /* PUT_LINE will put them in.    */
         if (nl_loc <= 255)
         then
            dbms_output.put_line(substr(buffer, 1, nl_loc - 1));
            buffer := substr(buffer, nl_loc + 1);
         else /* nl_loc > 255 */
            dbms_output.put_line(substr(buffer, 1, 255));
            buffer := substr(buffer, 256);
         end if;
      end if;
   end loop;

   rows_out := rows_in;
end;

procedure download_file(sFileName in varchar2,
   bCompress in boolean default false) is
begin
   if (sDownloadFilesList is NULL)
   then
      sDownLoadFilesList := sFileName;
      if (bCompress)
      then
         nCompressDownloadFiles := 1;
      else
         nCompressDownloadFiles := 0;
      end if;
   end if;
end;

procedure get_download_files_list(sFilesList out varchar2,
   nCompress out binary_integer) is
begin
   sFilesList := sDownloadFilesList;
   nCompress := nCompressDownloadFiles;
end;

function isHTMLHdr(cbuf in varchar2) return boolean is
   len number := length(cbuf);
begin
   return
      ((len >= nContentTypeLen
           and sContentType = substr(cbuf, 1, nContentTypeLen))
    or (len >= nContentLengthLen
           and sContentLength = substr(cbuf, 1, nContentLengthLen))
    or (len >= nLocationLen
           and sLocation = substr(cbuf, 1, nLocationLen))
    or (len >= nStatusLen
           and sStatus = substr(cbuf, 1, nStatusLen))
      );
end isHTMLHdr;

procedure addDefaultHTMLHdr(bAddHTMLHdr boolean) is
begin
   bAddDefaultHTMLHdr := bAddHTMLHdr;
end addDefaultHTMLHdr;

procedure prn(cbuf in varchar2 DEFAULT NULL) is
   bSeenNL      boolean;
   loc    number;
   len    number;
   tlen   number;
   ccharset     VARCHAR2(1000);
   cversion     VARCHAR2(1000);
begin
   if (cbuf is NULL)
   then
      return;
   end if;

   if (bFirstCall)
   then
      bFirstCall := FALSE;
      -- Check if we need to reserve the headers for caching
      cversion := owa_util.get_cgi_env('GATEWAY_IVERSION');
      if (cversion IS NOT NULL AND cversion = '2' AND rows_in = 0)
      then
         owa_cache.init(htbuf, rows_in);
      end if;
      if (bAddDefaultHTMLHdr)
      then
         bHTMLPageReady := FALSE;
         bHasContentLength := FALSE;
         nEndOfHdrIx := -1;
         nContentLengthIx := -1;
         -- Check for HTML headers
         bHasHTMLHdr := isHTMLHdr(upper(cbuf));
         if (not bHasHTMLHdr)
         then
            -- add Content-type: text/html[; charset=<IANA_CHARSET_NAME> ]
            rows_in := rows_in + 1;
            ccharset := owa_util.get_cgi_env('REQUEST_IANA_CHARSET');
            IF (ccharset IS NULL) THEN
               htbuf(rows_in) := 'Content-type: ' || stexthtml || NL_CHAR;
             ELSE
               htbuf(rows_in) := 'Content-type: ' || sTextHtml || '; charset=' ||
                 ccharset || NL_CHAR;
            END IF;

            -- reserve space for Content-length: header
            rows_in := rows_in + 1;
            nContentLengthIx := rows_in;
            rows_in := rows_in + 1;
            htbuf(rows_in) := NL_CHAR;
            nEndOfHdrIx := rows_in;
            bHasContentLength := TRUE;
         end if;
      else
         bHTMLPageReady := TRUE;
      end if;
   end if;

   len := length(cbuf);
   if (not bHTMLPageReady)
   then
      -- We assume that 'pack_after' is sufficiently large that we won't be
      -- packing HTML headers.
      -- We also assume that end of headers request will be by itself
      if (nEndOfHdrIx < 0) -- we have not seen end of headers yet
      then
         if (len >= nContentLengthLen
                and sContentLength = substr(upper(cbuf), 1, nContentLengthLen))
         then
            bHasContentLength := TRUE;
         end if;
         if ((cbuf = NL_CHAR
                 and (rows_in > 0
                         and substr(htbuf(rows_in), length(htbuf(rows_in)), 1)
                                = NL_CHAR)
             ) or (instr(cbuf, NLNL_CHAR, -1) != 0))
         then -- we now have seen!
            if (not bHasContentLength)
            then
               -- reserve space for Content-length: header
               rows_in := rows_in + 1;
               nContentLengthIx := rows_in;
            end if;
            nEndOfHdrIx := (rows_in + 1);
            bHasContentLength := TRUE;
         end if;
      end if;
   end if;

   loc := 0;
   if (rows_in < pack_after) then
      while ((len - loc) >= HTBUF_LEN)
      loop
         rows_in := rows_in + 1;
         htbuf(rows_in) := substr(cbuf, loc + 1, HTBUF_LEN);
         loc := loc + HTBUF_LEN;
      end loop;
      if (loc < len)
      then
         rows_in := rows_in + 1;
         htbuf(rows_in) := substr(cbuf, loc + 1);
      end if;
      return;
   end if;

   -- calculate remaining buffer size
   if (htcurline is null)
   then
      tlen := HTBUF_LEN;
   else
      tlen := HTBUF_LEN - length(htcurline);
   end if;

   while (loc < len)
   loop
      if ((len - loc) <= tlen)
      then
         if (loc = 0)
         then
            htcurline := htcurline || cbuf;
         else
            htcurline := htcurline || substr(cbuf, loc + 1);
         end if;
         exit;
      end if;
      rows_in := rows_in + 1;
      htbuf(rows_in) := htcurline || substr(cbuf, loc + 1, tlen);
      htcurline := '';
      loc := loc + tlen;
      tlen := HTBUF_LEN; -- remaining buffer size
   end loop;
end;

procedure print (cbuf in varchar2 DEFAULT NULL) is
begin
   prn(cbuf || '
');
   /* The above broken line is intentional.  Do not modify */
end;

procedure print (dbuf in date) is
begin print(to_char(dbuf)); end;

procedure print (nbuf in number) is
begin print(to_char(nbuf)); end;

procedure prn (dbuf in date) is
begin prn(to_char(dbuf)); end;

procedure prn (nbuf in number) is
begin prn(to_char(nbuf)); end;

procedure p (cbuf in varchar2 DEFAULT NULL) is
begin print(cbuf); end;

procedure p (dbuf in date) is
begin print(to_char(dbuf)); end;

procedure p (nbuf in number) is
begin print(to_char(nbuf)); end;

procedure prints(ctext in varchar2) is
begin p(htf.escape_sc(ctext)); end;

procedure ps(ctext in varchar2) is
begin p(htf.escape_sc(ctext)); end;

procedure escape_sc(ctext in varchar2) is
begin p(htf.escape_sc(ctext)); end;

procedure print_header (cbuf in varchar2, nline in number) is
   cversion varchar2(1000);
begin
   -- This procedure only works with the gateway version 2
   cversion := owa_util.get_cgi_env('GATEWAY_IVERSION');
   if (cversion IS NOT NULL AND cversion = '2')
   then
      -- Check if we need reserve the headers for caching
      if (rows_in = 0)
      then
         -- Call owa_cache.init to reserve the headers
         owa_cache.init(htbuf, rows_in);
      end if;
      htbuf(nline) := cbuf || NL_CHAR;
   end if;
end;
/* END SPECIAL PROCEDURES */

begin
   init;
end;
/
