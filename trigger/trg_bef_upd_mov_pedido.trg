create or replace trigger trg_bef_upd_mov_pedido
before update on mov_pedido
for each row
  
begin
  
  -- Marcio Casagrande
  -- 15/03/2013
  -- Solicitado por Alvaro
  -- Estamos enfrentando problemas referente a altera��o da data de entrega dos pedidos de vendas.
  -- Muitas vezes o pessoal do televendas necessita alterar a data de entrega de um pedido, mas o problema ocorre quando este pedido j� est� MONTADO e o pessoal do cd j� iniciou a separa��o e efetuar� o faturamento.
  -- O cliente quase sempre cancela a compra qdo recebe antes do combinado.
  -- Como isto � feito pelo GEMCO seria necess�rio criar uma trigger que s� permite alterar se o sitcarga da mov_pedido � zero.
  -- Pode providenciar isto, pois est� causando v�rios cancelamentos de vendas.
  
  if :old.dtentrega is not null and :new.dtentrega is not null then
    if :old.dtentrega <> :new.dtentrega and nvl(:new.sitcarga,0) > 0 then
      raise_application_error(-20000,'N�o � permitido alterar data de entrega de pedidos j� separados para entrega!');
    end if;
  end if;
  
end trg_bef_upd_mov_pedido;
/
