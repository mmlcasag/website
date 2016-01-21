DROP SYNONYM fretes_calculo;

CREATE MATERIALIZED VIEW fretes_calculo
REFRESH FAST ON DEMAND
AS
SELECT transportadora, polo, tipo, peso_ini, peso_fim, frete_minimo, frete_quilo, frete_vlnota, taxa_despacho
,      gris, gris_min, pedagio, taxa_sefaz, taxa_dificuldade, taxa_dificuldade_min, taxa_fluvial, taxa_aereo
,      taxa_suframa, prazo_min, prazo_max, filorig, dias_coleta
FROM   lvirtual.fretes_calculo;