create or replace
FUNCTION replaceCharsEmail(hWord VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN translate(hword,
  'ביםףתדץאטלעשגךמפûאטלעשגךמפûהכןצü‎ÿ‎חסו¡ֱֹֽ׃ÚֳױְָּׂÙֲÊ־װÛְָּׂÙֲÊ־װÛִֻֿײÜÝÝֵַׁ¡~´`^()"*#$%[]{}/\|<>''',
  'aeiouaoaeiouaeiouaeiouaeiouaeiouyyycnaiAEIOUAOAEIOUAEIOUAEIOUAEIOUAEIOUYYCNAI                      ');
END replaceCharsEmail;
