CREATE MATERIALIZED VIEW correio_parametros
REFRESH FAST ON DEMAND
AS
SELECT id, entrega_gratis, peso_maximo, medida_maxima, altura_maxima, largura_maxima, comprimento_maximo
FROM   lvirtual.correio_parametros;
