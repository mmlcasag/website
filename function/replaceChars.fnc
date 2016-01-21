create or replace
FUNCTION replaceChars(hWord VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  RETURN translate(hword,
  'ביםףתדץאטלעשגךמפûאטלעשגךמפûהכןצü‎ÿ‎חסו¡ֱֹֽ׃ÚֳױְָּׂÙֲÊ־װÛְָּׂÙֲÊ־װÛִֻֿײÜÝÝֵַׁ¡~´`^()"*#$%@[]{}/\|<>''',
  'aeiouaoaeiouaeiouaeiouaeiouaeiouyyycnaiAEIOUAOAEIOUAEIOUAEIOUAEIOUAEIOUYYCNAI                      ');
END replaceChars;
