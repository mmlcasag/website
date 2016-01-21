CREATE MATERIALIZED VIEW cad_calendario
REFRESH FAST ON DEMAND
AS
SELECT codfil, dtcalendario, flcom, flent, flfin, percprev, vlprev, status
FROM   colombo.cad_calendario
WHERE  codfil = 400
AND    dtcalendario >= '01/01/2011';