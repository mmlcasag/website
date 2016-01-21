create or replace type tp_web_preco_ativo_parcela as object(
    codprod number(10),
    plano   varchar2(10),
    parcela number(10),
    preco_parcela                  NUMBER(10,2),
    preco_normal                   NUMBER(10,2),
    preco_total                    NUMBER(10,2),
    preco_antigo                   NUMBER(10,2),
    juros                          NUMBER(10,2)
);
