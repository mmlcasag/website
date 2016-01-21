create or replace view web_itped as
select mov.codfil, mov.numpedven pedido, mov.coditprod, mov.qtcomp qtd, mov.status,
       mov.precoorig preco_lista, mov.vljurosfin juros, mov.vltotitem total, mov.vldescitem desconto,
       mov.precounit - trunc(mov.vldescitem/mov.qtcomp,2) preco, web.coddesconto, numpedcomp
  from mov_itped mov,
       mov_itped_web web
 where web.codfil (+) = mov.codfil
   and web.tipoped  (+) = mov.tipoped
   and web.numpedven (+) = mov.numpedven
   and web.coditprod (+) = mov.coditprod
 order by item;
