create or replace
FUNCTION fnc_tiraacentos (value IN VARCHAR2)
RETURN VARCHAR2 IS
resultado VARCHAR2(4000);
tamanho NUMBER(30);
BEGIN
   tamanho := 0;
   resultado := '';
   resultado := TRANSLATE(value    ,'����������','aAaAAaAaAa');
   resultado := TRANSLATE(resultado,'����������','oOoOOoOoOo');
   resultado := TRANSLATE(resultado,'��������','eEEeeEEe');
   resultado := TRANSLATE(resultado,'��������','iIIiiIIi');
   resultado := TRANSLATE(resultado,'��������','uUUuuUUu');
   resultado := TRANSLATE(resultado,'����','CCCc');
   resultado := TRANSLATE(resultado,'(){}[]/|\','         ');
   resultado := TRANSLATE(resultado,',.;:?!~^"','         ');
   resultado := TRANSLATE(resultado,'@#$%�*=+-_&��','             ');
   tamanho := LENGTH(resultado);
   RETURN SUBSTR(resultado,1,tamanho);
END;
/
