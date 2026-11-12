USE techshop;

CREATE INDEX idx_pedido_data ON PEDIDO (data_pedido);

CREATE INDEX idx_cliente_email ON CLIENTE (email);

EXPLAIN SELECT * FROM PEDIDO WHERE data_pedido BETWEEN '2026-01-01' AND '2026-03-31';

EXPLAIN SELECT * FROM CLIENTE WHERE email = 'ana.ribeiro@email.com';
