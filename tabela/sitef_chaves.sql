/*
-- Create table
create table SITEF_CHAVES
( sequence_name          VARCHAR2(255)
, sequence_next_hi_value NUMBER(10)
);

-- Grant/Revoke object privileges 
grant select on SITEF_CHAVES to COLOMBO;
grant select on SITEF_CHAVES to LVIRTUAL;
*/

alter table sitef_chaves add constraint pk_sitef_chaves primary key (sequence_name);