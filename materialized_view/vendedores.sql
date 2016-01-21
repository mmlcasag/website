DROP SYNONYM vendedores;

CREATE MATERIALIZED VIEW vendedores
REFRESH FAST ON DEMAND
AS
SELECT fun_pront, fun_ativo, fun_estab, fun_nome, fun_cargo, fun_admissao, fun_cpf, fun_depto, fun_rescisao, fun_nascimento, fun_sexo, fun_rg, fun_email
FROM   colombo.vendedores
WHERE  fun_estab = 400
AND    fun_ativo <> 2;
