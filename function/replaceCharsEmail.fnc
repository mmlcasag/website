create or replace
FUNCTION replaceCharsEmail(hWord VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN translate(hword,
  '��������������������������������������������������������������������������š~�`^()"*#$%[]{}/\|<>''',
  'aeiouaoaeiouaeiouaeiouaeiouaeiouyyycnaiAEIOUAOAEIOUAEIOUAEIOUAEIOUAEIOUYYCNAI                      ');
END replaceCharsEmail;
