create or replace
FUNCTION fnc_tiraacentos (value IN VARCHAR2)
RETURN VARCHAR2 IS
resultado VARCHAR2(4000);
tamanho NUMBER(30);
BEGIN
   tamanho := 0;
   resultado := '';
   resultado := TRANSLATE(value    ,'ãÃáÁÀàÂâÄä','aAaAAaAaAa');
   resultado := TRANSLATE(resultado,'õÕóÓÒòÔôÖö','oOoOOoOoOo');
   resultado := TRANSLATE(resultado,'éÉÈèëËÊê','eEEeeEEe');
   resultado := TRANSLATE(resultado,'íÍÌìïÏÎî','iIIiiIIi');
   resultado := TRANSLATE(resultado,'úÚÙùüÜÛû','uUUuuUUu');
   resultado := TRANSLATE(resultado,'¿¿Çç','CCCc');
   resultado := TRANSLATE(resultado,'(){}[]/|\','         ');
   resultado := TRANSLATE(resultado,',.;:?!~^"','         ');
   resultado := TRANSLATE(resultado,'@#$%¨*=+-_&ª°','             ');
   tamanho := LENGTH(resultado);
   RETURN SUBSTR(resultado,1,tamanho);
END;
/
