USE techshop;

-- Operacao com transacao: confirmacao de pedido com baixa no estoque

START TRANSACTION;

INSERT INTO PEDIDO (id_pedido, data_pedido, id_cliente, id_funcionario) 
VALUES (27, NOW(), 1, 1);

INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_praticado) 
VALUES (27, 9, 2, 350.00);

UPDATE PRODUTO 
SET qtd_estoque = qtd_estoque - 2 
WHERE id_produto = 9 AND qtd_estoque >= 2;

COMMIT;

-- Exemplo de rollback em caso de inconsistencia de estoque

START TRANSACTION;

INSERT INTO PEDIDO (id_pedido, data_pedido, id_cliente, id_funcionario) 
VALUES (28, NOW(), 2, 2);

INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_praticado) 
VALUES (28, 6, 999, 7999.00);

ROLLBACK;
