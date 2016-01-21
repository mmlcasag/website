CREATE OR REPLACE
function str2num (str varchar2) return varchar2 as
begin
  return to_number(replace(str, ',', '.'));--OC4J
exception
  when others then
    begin
      return to_number(replace(str, '.', ','));--TOMCAT
    exception
      when others then
        return null;
    end;
end;
