create or replace
FUNCTION replaceChars(hWord VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN translate(hword,
  '��������������������������������������������������������������������������š~�`^()"*#$%@[]{}/\|<>''',
  'aeiouaoaeiouaeiouaeiouaeiouaeiouyyycnaiAEIOUAOAEIOUAEIOUAEIOUAEIOUAEIOUYYCNAI                      ');
END replaceChars;
