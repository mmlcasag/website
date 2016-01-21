create or replace TYPE BODY TP_WEB_VIRTUAL_GSA AS

  CONSTRUCTOR FUNCTION tp_web_virtual_gsa(CODIGO NUMBER, TIPO CHAR)
    RETURN SELF AS RESULT AS
  BEGIN
    self.codigo   := codigo;
    self.tipoprod := tipo;
    return;
  END tp_web_virtual_gsa;

END;
