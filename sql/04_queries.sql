USE techshop;

-- 1. Catalogo de produtos com categoria e preco
SELECT 
    p.nome_produto, 
    c.nome_categoria, 
    p.preco_unitario
FROM PRODUTO p
INNER JOIN CATEGORIA c ON p.id_categoria = c.id_categoria
ORDER BY c.nome_categoria, p.nome_produto;

-- 2. Faturamento total por cliente
SELECT 
    c.nome_cliente, 
    SUM(i.quantidade * i.preco_praticado) AS faturamento_total
FROM CLIENTE c
INNER JOIN PEDIDO p ON c.id_cliente = p.id_cliente
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY faturamento_total DESC;

-- 3. Produtos com preco acima da media
SELECT 
    nome_produto, 
    preco_unitario
FROM PRODUTO
WHERE preco_unitario > (SELECT AVG(preco_unitario) FROM PRODUTO)
ORDER BY preco_unitario DESC;

-- 4. Clientes cadastrados e localizacao
SELECT 
    nome_cliente, 
    email, 
    cidade
FROM CLIENTE
ORDER BY nome_cliente;

-- 5. Total vendido por funcionario
SELECT 
    f.nome_funcionario, 
    SUM(i.quantidade * i.preco_praticado) AS total_vendido
FROM FUNCIONARIO f
INNER JOIN PEDIDO p ON f.id_funcionario = p.id_funcionario
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido
GROUP BY f.id_funcionario, f.nome_funcionario
ORDER BY total_vendido DESC;

-- 6. Quantidade de itens vendidos por categoria
SELECT 
    c.nome_categoria, 
    SUM(i.quantidade) AS total_itens_vendidos
FROM CATEGORIA c
INNER JOIN PRODUTO p ON c.id_categoria = p.id_categoria
INNER JOIN ITEM_PEDIDO i ON p.id_produto = i.id_produto
GROUP BY c.id_categoria, c.nome_categoria
ORDER BY total_itens_vendidos DESC;

-- 7. Ticket medio da loja
SELECT 
    ROUND(SUM(i.quantidade * i.preco_praticado) / COUNT(DISTINCT p.id_pedido), 2) AS ticket_medio_loja
FROM PEDIDO p
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido;

-- 8. Busca de cliente por email
SELECT 
    nome_cliente, 
    email
FROM CLIENTE
WHERE email = 'ana.ribeiro@email.com';

-- 9. Detalhamento de pedidos com valor total
SELECT 
    p.id_pedido, 
    p.data_pedido, 
    SUM(i.quantidade * i.preco_praticado) AS valor_total_pedido
FROM PEDIDO p
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido
GROUP BY p.id_pedido, p.data_pedido
ORDER BY p.id_pedido;

-- 10. Alerta de produtos com estoque baixo
SELECT 
    p.id_produto, 
    p.nome_produto, 
    c.nome_categoria, 
    p.qtd_estoque
FROM PRODUTO p
INNER JOIN CATEGORIA c ON p.id_categoria = c.id_categoria
WHERE p.qtd_estoque <= 10
ORDER BY p.qtd_estoque ASC;
