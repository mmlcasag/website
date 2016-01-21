create or replace PROCEDURE "SEND_MAIL" 
( msg_from varchar2 := 'oracle'
, msg_to varchar2
, msg_subject varchar2 := 'E-Mail message from your database'
, msg_text varchar2 := '' 
) IS
  
  c utl_tcp.connection;
  rc integer;
  v_host varchar2(15);

BEGIN
  
  v_host := '100.1.1.244';
  
  c := utl_tcp.open_connection(v_host, 25); -- open the SMTP port
  
  rc := utl_tcp.write_line(c, 'HELO localhost');
  rc := utl_tcp.write_line(c, 'MAIL FROM: '||'<'||msg_from||'>');
  rc := utl_tcp.write_line(c, 'RCPT TO: '||'<'||msg_to||'>');
  rc := utl_tcp.write_line(c, 'DATA'); -- Start message body
  rc := utl_tcp.write_line(c, 'Subject: '||msg_subject);
  rc := utl_tcp.write_line(c, '');
  rc := utl_tcp.write_line(c, msg_text);
  rc := utl_tcp.write_line(c, '.'); -- End of message body
  rc := utl_tcp.write_line(c, 'QUIT');
  
  utl_tcp.close_connection(c); -- Close the connection
  
EXCEPTION
  when others then
    raise_application_error(-20000, 'Unable to send e-mail message from pl/sql: ' || sqlerrm);
    utl_tcp.close_connection(c); -- Close the connection
END;
/
