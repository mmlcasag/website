create or replace package htp as

/* STRUCTURE tags */
procedure htmlOpen;
procedure htmlClose;
procedure headOpen;
procedure headClose;
procedure bodyOpen(cbackground in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)   ;
procedure bodyClose;
/* END STRUCTURE tags */

/* HEAD Related elements tags */
procedure title  (ctitle in varchar2)                      ;
procedure htitle(ctitle      in varchar2,
                 nsize       in integer  DEFAULT 1,
                 calign      in varchar2 DEFAULT NULL,
                 cnowrap     in varchar2 DEFAULT NULL,
                 cclear      in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure base( ctarget in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL);
procedure isindex(cprompt in varchar2 DEFAULT NULL,
                  curl    in varchar2 DEFAULT NULL) ;
procedure linkRel(crel   in varchar2,
                  curl   in varchar2,
                  ctitle in varchar2 DEFAULT NULL)          ;
procedure linkRev(crev  in varchar2,
                  curl  in varchar2,
                  ctitle in varchar2 DEFAULT NULL)          ;
procedure meta(chttp_equiv in varchar2,
               cname       in varchar2,
               ccontent    in varchar2)                     ;
procedure nextid(cidentifier in varchar2)                   ;
procedure style(cstyle in varchar2)         ;
procedure script(cscript  in varchar2,
     clanguage  in varchar2 DEFAULT NULL)   ;
/* END HEAD Related elements tags */

/* BODY ELEMENT tags */
procedure hr  (cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL)       ;
procedure line(cclear      in varchar2 DEFAULT NULL,
               csrc        in varchar2 DEFAULT NULL,
               cattributes in varchar2 DEFAULT NULL)       ;
procedure br(cclear      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL)         ;
procedure nl(cclear      in varchar2 DEFAULT NULL,
             cattributes in varchar2 DEFAULT NULL)         ;

procedure header(nsize   in integer,
                 cheader in varchar2,
                 calign  in varchar2 DEFAULT NULL,
                 cnowrap in varchar2 DEFAULT NULL,
                 cclear  in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure anchor(curl        in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure anchor2(curl        in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
     ctarget     in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure mailto(caddress    in varchar2,
                 ctext       in varchar2,
                 cname       in varchar2 DEFAULT NULL,
                 cattributes in varchar2 DEFAULT NULL)     ;
procedure img(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL)        ;
procedure img2(curl        in varchar2,
              calign      in varchar2 DEFAULT NULL,
              calt        in varchar2 DEFAULT NULL,
              cismap      in varchar2 DEFAULT NULL,
              cusemap     in varchar2 DEFAULT NULL,
              cattributes in varchar2 DEFAULT NULL)        ;
procedure area( ccoords in varchar2,
                cshape  in varchar2 DEFAULT NULL,
                chref in varchar2 DEFAULT NULL,
                cnohref in varchar2 DEFAULT NULL,
    ctarget in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL);

procedure mapOpen(cname in varchar2,
      cattributes in varchar2 DEFAULT NULL);
procedure mapClose;

procedure bgsound(csrc  in varchar2,
      cloop in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL);


procedure para;
procedure paragraph(calign       in varchar2 DEFAULT NULL,
                    cnowrap      in varchar2 DEFAULT NULL,
                    cclear       in varchar2 DEFAULT NULL,
                    cattributes  in varchar2 DEFAULT NULL) ;
procedure div(  calign       in varchar2 DEFAULT NULL,
                cattributes  in varchar2 DEFAULT NULL) ;
procedure address(cvalue       in varchar2,
                  cnowrap      in varchar2 DEFAULT NULL,
                  cclear       in varchar2 DEFAULT NULL,
                  cattributes  in varchar2 DEFAULT NULL)   ;
procedure comment(ctext in varchar2)                       ;
procedure preOpen(cclear      in varchar2 DEFAULT NULL,
                  cwidth      in varchar2 DEFAULT NULL,
                  cattributes in varchar2 DEFAULT NULL)    ;
procedure preClose;
procedure listingOpen;
procedure listingClose;
procedure nobr(ctext in varchar2);
procedure wbr;
procedure center(ctext in varchar2);
procedure centerOpen;
procedure centerClose;

procedure blockquoteOpen(cnowrap      in varchar2 DEFAULT NULL,
                         cclear       in varchar2 DEFAULT NULL,
                         cattributes  in varchar2 DEFAULT NULL) ;
procedure blockquoteClose;

/* LIST tags */
procedure listHeader(ctext in varchar2,
                     cattributes in varchar2 DEFAULT NULL) ;
procedure listItem(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cdingbat    in varchar2 DEFAULT NULL,
                   csrc        in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)   ;
procedure ulistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cdingbat    in varchar2 DEFAULT NULL,
                    csrc        in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure ulistClose;
procedure olistOpen(cclear      in varchar2 DEFAULT NULL,
                    cwrap       in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure olistClose;
procedure dlistOpen(cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure dlistTerm(ctext       in varchar2 DEFAULT NULL,
                    cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL)  ;
procedure dlistDef(ctext       in varchar2 DEFAULT NULL,
                   cclear      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL)  ;
procedure dlistClose;

procedure menulistOpen;
procedure menulistClose;
procedure dirlistOpen;
procedure dirlistClose;
/* END LIST tags */

/* SEMANTIC FORMAT ELEMENTS */
procedure dfn(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure cite(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure code(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure em(ctext in varchar2,
             cattributes in varchar2 DEFAULT NULL) ;
procedure emphasis(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure keyboard(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure kbd(ctext in varchar2,
              cattributes in varchar2 DEFAULT NULL) ;
procedure sample(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure strong(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure variable(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure big(  ctext     in varchar2,
    cattributes   in varchar2 DEFAULT NULL);
procedure small(ctext     in varchar2,
    cattributes   in varchar2 DEFAULT NULL);
procedure sub(  ctext     in varchar2,
    calign    in varchar2 DEFAULT NULL,
    cattributes   in varchar2 DEFAULT NULL);
procedure sup(  ctext     in varchar2,
    calign    in varchar2 DEFAULT NULL,
    cattributes   in varchar2 DEFAULT NULL);

/* END SEMANTIC FORMAT ELEMENTS */

/* PHYSICAL FORMAT ELEMENTS */
procedure basefont(nsize in integer);
procedure fontOpen( ccolor  in varchar2 DEFAULT NULL,
    cface in varchar2 DEFAULT NULL,
    csize in varchar2 DEFAULT NULL,
    cattributes in varchar2 DEFAULT NULL);
procedure fontClose;
procedure bold(ctext in varchar2,
               cattributes in varchar2 DEFAULT NULL) ;
procedure italic(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure teletype(ctext in varchar2,
                   cattributes in varchar2 DEFAULT NULL) ;
procedure plaintext(ctext in varchar2,
                    cattributes in varchar2 DEFAULT NULL) ;
procedure s(ctext in varchar2,
            cattributes in varchar2 DEFAULT NULL) ;
procedure strike(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
procedure underline(ctext in varchar2,
                 cattributes in varchar2 DEFAULT NULL) ;
/* END PHYSICAL FORMAT ELEMENTS */

/* HTML FORMS */
procedure formOpen(curl     in varchar2,
                   cmethod  in varchar2 DEFAULT 'POST',
       ctarget  in varchar2 DEFAULT NULL,
       cenctype in varchar2 DEFAULT NULL,
       cattributes in varchar2 DEFAULT NULL);

procedure formCheckbox(cname       in varchar2,
                       cvalue      in varchar2 DEFAULT 'on',
                       cchecked    in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure formFile(cname       in varchar2,
                   caccept     in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL);
procedure formHidden(cname       in varchar2,
                     cvalue      in varchar2 DEFAULT NULL,
                     cattributes in varchar2 DEFAULT NULL);
procedure formImage(cname       in varchar2,
                    csrc        in varchar2,
                    calign      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure formPassword(cname       in varchar2,
                       csize       in varchar2 DEFAULT NULL,
                       cmaxlength  in varchar2 DEFAULT NULL,
                       cvalue      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure formRadio(cname       in varchar2,
                    cvalue      in varchar2,
                    cchecked    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure formReset(cvalue      in varchar2 DEFAULT 'Reset',
                    cattributes in varchar2 DEFAULT NULL);
procedure formSubmit(cname       in varchar2 DEFAULT NULL,
                     cvalue      in varchar2 DEFAULT 'Submit',
                     cattributes in varchar2 DEFAULT NULL);
procedure formText(cname       in varchar2,
                   csize       in varchar2 DEFAULT NULL,
                   cmaxlength  in varchar2 DEFAULT NULL,
                   cvalue      in varchar2 DEFAULT NULL,
                   cattributes in varchar2 DEFAULT NULL);

procedure formSelectOpen(cname       in varchar2,
                         cprompt     in varchar2 DEFAULT NULL,
                         nsize       in integer  DEFAULT NULL,
                         cattributes in varchar2 DEFAULT NULL);
procedure formSelectOption(cvalue      in varchar2,
                           cselected   in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL);
procedure formSelectClose;

procedure formTextarea(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);

procedure formTextarea2(cname       in varchar2,
                       nrows       in integer,
                       ncolumns    in integer,
                       calign      in varchar2 DEFAULT NULL,
           cwrap     in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);

procedure formTextareaOpen(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL);

procedure formTextareaOpen2(cname       in varchar2,
                           nrows       in integer,
                           ncolumns    in integer,
                           calign      in varchar2 DEFAULT NULL,
         cwrap       in varchar2 DEFAULT NULL,
                           cattributes in varchar2 DEFAULT NULL);
procedure formTextareaClose;

procedure formClose;
/* END HTML FORMS */

/* HTML TABLES */
procedure tableOpen(cborder     in varchar2 DEFAULT NULL,
                    calign      in varchar2 DEFAULT NULL,
                    cnowrap     in varchar2 DEFAULT NULL,
                    cclear      in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure tableCaption(ccaption    in varchar2,
                       calign      in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure tableRowOpen(calign      in varchar2 DEFAULT NULL,
                       cvalign     in varchar2 DEFAULT NULL,
                       cdp         in varchar2 DEFAULT NULL,
                       cnowrap     in varchar2 DEFAULT NULL,
                       cattributes in varchar2 DEFAULT NULL);
procedure tableHeader(cvalue      in varchar2 DEFAULT NULL,
                      calign      in varchar2 DEFAULT NULL,
                      cdp         in varchar2 DEFAULT NULL,
                      cnowrap     in varchar2 DEFAULT NULL,
                      crowspan    in varchar2 DEFAULT NULL,
                      ccolspan    in varchar2 DEFAULT NULL,
                      cattributes in varchar2 DEFAULT NULL);
procedure tableData(cvalue      in varchar2 DEFAULT NULL,
                    calign      in varchar2 DEFAULT NULL,
                    cdp         in varchar2 DEFAULT NULL,
                    cnowrap     in varchar2 DEFAULT NULL,
                    crowspan    in varchar2 DEFAULT NULL,
                    ccolspan    in varchar2 DEFAULT NULL,
                    cattributes in varchar2 DEFAULT NULL);
procedure tableRowClose;

procedure tableClose;
/* END HTML TABLES */

/* BEGIN HTML FRAMES - Netscape Extensions FRAMESET, FRAME tags */
procedure framesetOpen( crows in varchar2 DEFAULT NULL, /* row height value list */
      ccols in varchar2 DEFAULT NULL,
      cattributes in varchar2 DEFAULT NULL);  /* column width list */
procedure framesetClose;
procedure frame(  csrc  in varchar2,        /* URL */
      cname in varchar2 DEFAULT NULL,   /* Window Name */
      cmarginwidth  in varchar2 DEFAULT NULL, /* Value in pixels */
      cmarginheight in varchar2 DEFAULT NULL, /* Value in pixels */
      cscrolling  in varchar2 DEFAULT NULL, /* yes | no | auto */
      cnoresize in varchar2 DEFAULT NULL,
      cattributes   in varchar2 DEFAULT NULL);  /* Not resizable by user */
procedure noframesOpen;
procedure noframesClose;

/* END FRAMES */

/* BEGIN SPECIAL HTML TAGS */
procedure appletOpen( ccode   in varchar2,
      cwidth    in integer,
      cheight   in integer,
      cattributes in varchar2 DEFAULT NULL);
procedure param(  cname   in varchar2,
      cvalue    in varchar2);
procedure appletClose;

/* END BODY ELEMENT tags */

/* TYPES FOR htp.print */
-- PL/SQL table used for output buffering
HTBUF_LEN number := 255;
type htbuf_arr is table of varchar2(256) index by binary_integer;

/* SPECIAL PROCEDURES */
procedure init;
-- call addDefaultHTMLHdr(FALSE) before your first call
-- to prn or print to suppress HTML header generation
-- if not present
procedure addDefaultHTMLHdr(bAddHTMLHdr in boolean);
procedure flush;
function get_line (irows out integer) return varchar2;
procedure get_page (thepage out htbuf_arr, irows in out integer);
procedure showpage;

/* Following procedures are for file download feature */
procedure download_file(sFileName in varchar2,
   bCompress in boolean default false);
procedure get_download_files_list(sFilesList out varchar2,
   nCompress out binary_integer);

  -- Output Procedures
procedure print (cbuf in varchar2 DEFAULT NULL);
procedure print (dbuf in date);
procedure print (nbuf in number);

  -- Output without the newline
procedure prn (cbuf in varchar2 DEFAULT NULL);
procedure prn (dbuf in date);
procedure prn (nbuf in number);

  -- Abbrev call to print()
procedure p (cbuf in varchar2 DEFAULT NULL);
procedure p (dbuf in date);
procedure p (nbuf in number);

procedure prints(ctext in varchar2);
procedure ps(ctext in varchar2);
procedure escape_sc(ctext in varchar2);
procedure print_header(cbuf in varchar2, nline in number);
/* END SPECIAL PROCEDURES */

end;
/
