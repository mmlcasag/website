create or replace trigger trg_bef_upd_mov_pedido
before update on mov_pedido
for each row
  
begin
  
  -- Marcio Casagrande
  -- 15/03/2013
  -- Solicitado por Alvaro
  -- Estamos enfrentando problemas referente a alteração da data de entrega dos pedidos de vendas.
  -- Muitas vezes o pessoal do televendas necessita alterar a data de entrega de um pedido, mas o problema ocorre quando este pedido já está MONTADO e o pessoal do cd já iniciou a separação e efetuará o faturamento.
  -- O cliente quase sempre cancela a compra qdo recebe antes do combinado.
  -- Como isto é feito pelo GEMCO seria necessário criar uma trigger que só permite alterar se o sitcarga da mov_pedido é zero.
  -- Pode providenciar isto, pois está causando vários cancelamentos de vendas.
  
  if :old.dtentrega is not null and :new.dtentrega is not null then
    if :old.dtentrega <> :new.dtentrega and nvl(:new.sitcarga,0) > 0 then
      raise_application_error(-20000,'Não é permitido alterar data de entrega de pedidos já separados para entrega!');
    end if;
  end if;
  
end trg_bef_upd_mov_pedido;
/
