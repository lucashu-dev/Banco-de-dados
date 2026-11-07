-- ============================================================================
-- TechShop Eletrônicos - Dados Iniciais (Seed)
-- Arquivo: 03_seed.sql
-- Descrição: Inserção de dados realistas para popular o banco de dados
--            com informações de teste representativas do cenário brasileiro
--            de uma loja de eletrônicos.
-- Autor: Engenheiro de Banco de Dados Senior
-- Encoding: UTF-8
-- ============================================================================

-- ============================================================================
-- CATEGORIAS (5 registros)
-- ============================================================================
INSERT INTO CATEGORIA (nome, descricao) VALUES
    ('Smartphones', 'Telefones celulares inteligentes, incluindo modelos nacionais e importados'),
    ('Notebooks', 'Computadores portáteis para uso pessoal e profissional'),
    ('Periféricos', 'Dispositivos auxiliares como teclados, mouses, headsets e webcams'),
    ('Componentes', 'Peças e componentes internos para montagem e upgrade de computadores'),
    ('Acessórios', 'Capas, películas, carregadores, cabos e suportes diversos');

-- ============================================================================
-- FORNECEDORES (6 registros)
-- ============================================================================
INSERT INTO FORNECEDOR (nome, cnpj, telefone, email) VALUES
    ('Distribuidora Tech Brasil Ltda',  '12.345.678/0001-90', '(11) 3456-7890', 'contato@techbrasil.com.br'),
    ('Eletrônicos Nacionais S.A.',      '23.456.789/0001-01', '(21) 2345-6789', 'vendas@eletronacionais.com.br'),
    ('ImportTech Comércio Exterior',     '34.567.890/0001-12', '(11) 4567-8901', 'comercial@importtech.com.br'),
    ('MegaSupply Componentes Ltda',      '45.678.901/0001-23', '(31) 5678-9012', 'suporte@megasupply.com.br'),
    ('Digital Parts Distribuidora',      '56.789.012/0001-34', '(41) 6789-0123', 'pedidos@digitalparts.com.br'),
    ('Nova Era Tecnologia Ltda',         '67.890.123/0001-45', '(51) 7890-1234', 'vendas@novaera.com.br');

-- ============================================================================
-- PRODUTOS (20 registros)
-- Nota: Alguns produtos possuem estoque próximo ou abaixo do estoque_minimo
--       para facilitar testes de consultas de reposição.
-- ============================================================================
INSERT INTO PRODUTO (id_categoria, id_fornecedor, nome, descricao, preco, quantidade_estoque, estoque_minimo, ativo) VALUES
    -- Smartphones (categoria 1)
    (1, 1, 'Smartphone Galaxy S24 Ultra 256GB',       'Samsung Galaxy S24 Ultra, 256GB, 12GB RAM, câmera 200MP',               6499.90, 15, 5,  TRUE),
    (1, 3, 'iPhone 15 Pro Max 256GB',                  'Apple iPhone 15 Pro Max, 256GB, chip A17 Pro, titânio',                 9299.00, 8,  5,  TRUE),
    (1, 1, 'Motorola Edge 40 Neo 256GB',               'Motorola Edge 40 Neo, 256GB, tela pOLED 144Hz',                        2199.90, 22, 5,  TRUE),
    (1, 2, 'Xiaomi Redmi Note 13 Pro 128GB',           'Xiaomi Redmi Note 13 Pro, 128GB, câmera 200MP, 5G',                    1899.00, 3,  5,  TRUE),
    -- Notebooks (categoria 2)
    (2, 3, 'Notebook Dell Inspiron 15 i5 16GB',        'Dell Inspiron 15, Intel Core i5-1335U, 16GB RAM, SSD 512GB',            4299.00, 10, 5,  TRUE),
    (2, 1, 'MacBook Air M2 256GB',                     'Apple MacBook Air com chip M2, 8GB RAM, SSD 256GB, tela Liquid Retina', 9499.00, 4,  5,  TRUE),
    (2, 2, 'Notebook Lenovo IdeaPad 3 i7 8GB',         'Lenovo IdeaPad 3, Intel Core i7-1255U, 8GB RAM, SSD 256GB',             3599.90, 12, 5,  TRUE),
    (2, 6, 'Notebook Acer Nitro 5 RTX 3050',           'Acer Nitro 5, i5-12450H, 16GB RAM, SSD 512GB, RTX 3050',               5799.00, 2,  5,  TRUE),
    -- Periféricos (categoria 3)
    (3, 4, 'Teclado Mecânico Redragon Kumara RGB',     'Teclado mecânico 60%, switches blue, iluminação RGB',                    249.90, 45, 10, TRUE),
    (3, 4, 'Mouse Gamer Logitech G502 HERO',           'Mouse gamer com sensor HERO 25K, 11 botões programáveis',                299.90, 30, 10, TRUE),
    (3, 5, 'Headset HyperX Cloud Stinger 2',           'Headset gamer com microfone giratório, drivers 50mm',                    219.90, 18, 10, TRUE),
    (3, 5, 'Webcam Logitech C920s Full HD',             'Webcam Full HD 1080p com tampa de privacidade',                          399.00, 7,  5,  TRUE),
    -- Componentes (categoria 4)
    (4, 4, 'Placa de Vídeo RTX 4060 8GB GDDR6',        'NVIDIA GeForce RTX 4060, 8GB GDDR6, DLSS 3.0',                         2399.00, 6,  3,  TRUE),
    (4, 6, 'Processador AMD Ryzen 5 5600X',             'AMD Ryzen 5 5600X, 6 núcleos, 12 threads, 3.7GHz base',                 999.90, 20, 5,  TRUE),
    (4, 4, 'SSD NVMe Kingston 1TB',                     'Kingston NV2, 1TB, NVMe PCIe Gen 4, leitura 3500MB/s',                   399.90, 35, 10, TRUE),
    (4, 6, 'Memória RAM DDR4 16GB Corsair Vengeance',   'Corsair Vengeance LPX, 16GB (2x8GB), DDR4 3200MHz, CL16',               349.90, 28, 10, TRUE),
    -- Acessórios (categoria 5)
    (5, 2, 'Capa Protetora Galaxy S24 Ultra',            'Capa transparente anti-impacto para Samsung Galaxy S24 Ultra',            79.90, 50, 15, TRUE),
    (5, 5, 'Carregador USB-C 65W GaN',                  'Carregador rápido GaN 65W, compatível com notebooks e smartphones',      189.90, 40, 10, TRUE),
    (5, 2, 'Película de Vidro iPhone 15 Pro Max',        'Película de vidro temperado 9H, cobertura total, anti-impressão digital', 39.90, 4,  10, TRUE),
    (5, 5, 'Suporte Articulado para Monitor até 32"',    'Suporte de mesa com braço articulado, rotação 360°, VESA 75/100',       159.90, 14, 5,  TRUE);

-- ============================================================================
-- CLIENTES (15 registros)
-- ============================================================================
INSERT INTO CLIENTE (nome, cpf, email, telefone, data_cadastro) VALUES
    ('Ana Carolina Mendes Silva',     '123.456.789-00', 'ana.mendes@gmail.com',         '(11) 98765-4321', '2024-01-10 09:15:00'),
    ('Bruno Henrique Costa Oliveira', '234.567.890-11', 'bruno.oliveira@outlook.com',   '(21) 97654-3210', '2024-01-22 14:30:00'),
    ('Camila Rodrigues Ferreira',     '345.678.901-22', 'camila.ferreira@yahoo.com.br', '(31) 96543-2109', '2024-02-05 10:00:00'),
    ('Daniel Almeida Santos',         '456.789.012-33', 'daniel.santos@hotmail.com',    '(41) 95432-1098', '2024-02-18 16:45:00'),
    ('Eduarda Lima Pereira',           '567.890.123-44', 'eduarda.pereira@gmail.com',    '(51) 94321-0987', '2024-03-01 11:20:00'),
    ('Felipe Souza Araújo',           '678.901.234-55', 'felipe.araujo@uol.com.br',    '(11) 93210-9876', '2024-03-15 08:50:00'),
    ('Gabriela Martins Ribeiro',       '789.012.345-66', 'gabriela.ribeiro@gmail.com',   '(21) 92109-8765', '2024-04-02 13:10:00'),
    ('Hugo Rafael Nascimento',         '890.123.456-77', 'hugo.nascimento@outlook.com',  '(31) 91098-7654', '2024-04-20 17:30:00'),
    ('Isabela Fernandes Correia',      '901.234.567-88', 'isabela.correia@gmail.com',    '(41) 90987-6543', '2024-05-08 09:45:00'),
    ('João Pedro Barbosa Cardoso',     '012.345.678-99', 'joao.cardoso@hotmail.com',     '(51) 89876-5432', '2024-05-25 15:00:00'),
    ('Larissa Gomes Teixeira',         '111.222.333-44', 'larissa.teixeira@yahoo.com',   '(11) 88765-4321', '2024-06-10 10:30:00'),
    ('Marcos Vinícius Rocha',          '222.333.444-55', 'marcos.rocha@gmail.com',       '(21) 87654-3210', '2024-07-04 12:00:00'),
    ('Natália Cristina Duarte',        '333.444.555-66', 'natalia.duarte@outlook.com',   '(31) 86543-2109', '2024-08-15 14:20:00'),
    ('Pedro Augusto Moreira',          '444.555.666-77', 'pedro.moreira@uol.com.br',    '(41) 85432-1098', '2024-09-02 16:00:00'),
    ('Renata Beatriz Campos',          '555.666.777-88', 'renata.campos@gmail.com',      '(51) 84321-0987', '2024-10-11 11:45:00');

-- ============================================================================
-- FUNCIONÁRIOS (5 registros)
-- ============================================================================
INSERT INTO FUNCIONARIO (nome, cpf, cargo, email, data_admissao) VALUES
    ('Roberto Carlos da Silva',   '611.722.833-01', 'Vendedor',             'roberto.silva@techshop.com.br',   '2023-03-15'),
    ('Juliana Aparecida Monteiro','622.733.844-02', 'Gerente',              'juliana.monteiro@techshop.com.br','2022-01-10'),
    ('Thiago Henrique Prado',     '633.744.855-03', 'Estoquista',           'thiago.prado@techshop.com.br',   '2023-06-20'),
    ('Fernanda Souza Lima',       '644.755.866-04', 'Analista Financeiro',  'fernanda.lima@techshop.com.br',  '2023-09-01'),
    ('Lucas Gabriel Nunes',       '655.766.877-05', 'Vendedor',             'lucas.nunes@techshop.com.br',    '2024-02-01');

-- ============================================================================
-- PEDIDOS (25 registros)
-- Distribuídos entre 2024 e 2025 com diferentes status.
-- ============================================================================
INSERT INTO PEDIDO (id_cliente, id_funcionario, data_pedido, valor_total, status) VALUES
    (1,  1, '2024-01-15 10:30:00', 0, 'ENTREGUE'),
    (2,  5, '2024-01-28 14:00:00', 0, 'ENTREGUE'),
    (3,  1, '2024-02-10 09:45:00', 0, 'ENTREGUE'),
    (4,  5, '2024-02-25 16:20:00', 0, 'ENTREGUE'),
    (5,  1, '2024-03-08 11:00:00', 0, 'ENTREGUE'),
    (6,  5, '2024-03-22 13:30:00', 0, 'ENTREGUE'),
    (7,  1, '2024-04-05 10:15:00', 0, 'ENTREGUE'),
    (8,  5, '2024-04-20 15:45:00', 0, 'ENTREGUE'),
    (9,  1, '2024-05-12 09:00:00', 0, 'CONFIRMADO'),
    (10, 5, '2024-06-01 14:30:00', 0, 'CONFIRMADO'),
    (11, 1, '2024-06-18 10:00:00', 0, 'CONFIRMADO'),
    (12, 5, '2024-07-10 16:00:00', 0, 'ENTREGUE'),
    (1,  1, '2024-08-05 11:30:00', 0, 'ENTREGUE'),
    (3,  5, '2024-09-14 09:20:00', 0, 'CANCELADO'),
    (5,  1, '2024-10-02 13:00:00', 0, 'ENTREGUE'),
    (7,  5, '2024-10-28 15:10:00', 0, 'CONFIRMADO'),
    (9,  1, '2024-11-15 10:45:00', 0, 'PENDENTE'),
    (2,  5, '2024-12-03 14:00:00', 0, 'PENDENTE'),
    (4,  1, '2024-12-20 09:30:00', 0, 'CANCELADO'),
    (13, 5, '2025-01-08 11:00:00', 0, 'PENDENTE'),
    (14, 1, '2025-01-22 16:30:00', 0, 'PENDENTE'),
    (15, 5, '2025-02-05 10:15:00', 0, 'CONFIRMADO'),
    (6,  1, '2025-02-18 13:45:00', 0, 'PENDENTE'),
    (8,  5, '2025-03-10 09:00:00', 0, 'PENDENTE'),
    (10, 1, '2025-03-25 14:20:00', 0, 'PENDENTE');

-- ============================================================================
-- ITENS DE PEDIDO (60 registros)
-- Subtotal = (quantidade * preco_unitario) - desconto
-- ============================================================================
INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_unitario, desconto, subtotal) VALUES
    -- Pedido 1: Ana Carolina — 3 itens
    (1,  1,  1, 6499.90,  0.00,  6499.90),
    (1,  17, 2,   79.90,  0.00,   159.80),
    (1,  18, 1,  189.90,  0.00,   189.90),
    -- Pedido 2: Bruno — 2 itens
    (2,  5,  1, 4299.00, 50.00,  4249.00),
    (2,  9,  2,  249.90,  0.00,   499.80),
    -- Pedido 3: Camila — 3 itens
    (3,  2,  1, 9299.00,  0.00,  9299.00),
    (3,  11, 1,  219.90,  0.00,   219.90),
    (3,  18, 2,  189.90, 10.00,   369.80),
    -- Pedido 4: Daniel — 2 itens
    (4,  3,  1, 2199.90,  0.00,  2199.90),
    (4,  17, 3,   79.90,  0.00,   239.70),
    -- Pedido 5: Eduarda — 3 itens
    (5,  6,  1, 9499.00,100.00,  9399.00),
    (5,  10, 1,  299.90,  0.00,   299.90),
    (5,  15, 2,  399.90, 20.00,   779.80),
    -- Pedido 6: Felipe — 2 itens
    (6,  4,  2, 1899.00,  0.00,  3798.00),
    (6,  16, 1,  349.90,  0.00,   349.90),
    -- Pedido 7: Gabriela — 3 itens
    (7,  7,  1, 3599.90, 50.00,  3549.90),
    (7,  9,  1,  249.90,  0.00,   249.90),
    (7,  20, 1,  159.90,  0.00,   159.90),
    -- Pedido 8: Hugo — 2 itens
    (8,  13, 1, 2399.00,  0.00,  2399.00),
    (8,  14, 1,  999.90,  0.00,   999.90),
    -- Pedido 9: Isabela — 3 itens
    (9,  8,  1, 5799.00, 80.00,  5719.00),
    (9,  15, 1,  399.90,  0.00,   399.90),
    (9,  16, 2,  349.90,  0.00,   699.80),
    -- Pedido 10: João Pedro — 2 itens
    (10, 1,  1, 6499.90,  0.00,  6499.90),
    (10, 12, 1,  399.00,  0.00,   399.00),
    -- Pedido 11: Larissa — 2 itens
    (11, 3,  2, 2199.90, 30.00,  4369.80),
    (11, 19, 5,   39.90,  0.00,   199.50),
    -- Pedido 12: Marcos — 3 itens
    (12, 5,  1, 4299.00,  0.00,  4299.00),
    (12, 10, 2,  299.90, 15.00,   584.80),
    (12, 18, 1,  189.90,  0.00,   189.90),
    -- Pedido 13: Ana Carolina (2º pedido) — 2 itens
    (13, 14, 2,  999.90, 25.00,  1974.80),
    (13, 16, 1,  349.90,  0.00,   349.90),
    -- Pedido 14: Camila (cancelado) — 2 itens
    (14, 2,  1, 9299.00,  0.00,  9299.00),
    (14, 11, 2,  219.90,  0.00,   439.80),
    -- Pedido 15: Eduarda (2º pedido) — 3 itens
    (15, 9,  3,  249.90, 10.00,   739.70),
    (15, 10, 1,  299.90,  0.00,   299.90),
    (15, 20, 2,  159.90,  0.00,   319.80),
    -- Pedido 16: Gabriela (2º pedido) — 2 itens
    (16, 4,  1, 1899.00,  0.00,  1899.00),
    (16, 17, 4,   79.90,  0.00,   319.60),
    -- Pedido 17: Isabela (2º pedido) — 3 itens
    (17, 7,  1, 3599.90,  0.00,  3599.90),
    (17, 15, 3,  399.90, 30.00,  1169.70),
    (17, 11, 1,  219.90,  0.00,   219.90),
    -- Pedido 18: Bruno (2º pedido) — 2 itens
    (18, 6,  1, 9499.00, 75.00,  9424.00),
    (18, 9,  1,  249.90,  0.00,   249.90),
    -- Pedido 19: Daniel (cancelado) — 2 itens
    (19, 8,  1, 5799.00,  0.00,  5799.00),
    (19, 13, 1, 2399.00,  0.00,  2399.00),
    -- Pedido 20: Natália — 2 itens
    (20, 1,  1, 6499.90, 50.00,  6449.90),
    (20, 18, 2,  189.90,  0.00,   379.80),
    -- Pedido 21: Pedro Augusto — 3 itens
    (21, 5,  1, 4299.00,  0.00,  4299.00),
    (21, 14, 1,  999.90,  0.00,   999.90),
    (21, 20, 1,  159.90,  0.00,   159.90),
    -- Pedido 22: Renata — 2 itens
    (22, 3,  1, 2199.90, 20.00,  2179.90),
    (22, 12, 1,  399.00,  0.00,   399.00),
    -- Pedido 23: Felipe (2º pedido) — 3 itens
    (23, 13, 1, 2399.00,  0.00,  2399.00),
    (23, 15, 2,  399.90,  0.00,   799.80),
    (23, 16, 1,  349.90,  0.00,   349.90),
    -- Pedido 24: Hugo (2º pedido) — 2 itens
    (24, 2,  1, 9299.00,100.00,  9199.00),
    (24, 17, 5,   79.90,  0.00,   399.50),
    -- Pedido 25: João Pedro (2º pedido) — 2 itens
    (25, 7,  1, 3599.90, 40.00,  3559.90),
    (25, 19, 3,   39.90,  0.00,   119.70);

-- ============================================================================
-- MOVIMENTAÇÕES DE ESTOQUE (30 registros)
-- Datas alinhadas com os pedidos para manter coerência.
-- ============================================================================
INSERT INTO MOVIMENTACAO_ESTOQUE (id_produto, tipo_movimentacao, quantidade, data_movimentacao, observacao) VALUES
    -- Entradas iniciais de estoque (recebimento de mercadoria)
    (1,  'ENTRADA', 20, '2024-01-05 08:00:00', 'Recebimento inicial - NF 1001 Distribuidora Tech Brasil'),
    (2,  'ENTRADA', 15, '2024-01-05 08:30:00', 'Recebimento inicial - NF 1002 ImportTech'),
    (3,  'ENTRADA', 30, '2024-01-05 09:00:00', 'Recebimento inicial - NF 1003 Distribuidora Tech Brasil'),
    (5,  'ENTRADA', 12, '2024-01-05 09:30:00', 'Recebimento inicial - NF 1004 ImportTech'),
    (9,  'ENTRADA', 50, '2024-01-06 08:00:00', 'Recebimento inicial - NF 1005 MegaSupply'),
    (10, 'ENTRADA', 40, '2024-01-06 08:30:00', 'Recebimento inicial - NF 1006 MegaSupply'),
    (13, 'ENTRADA', 10, '2024-01-06 09:00:00', 'Recebimento inicial - NF 1007 MegaSupply'),
    (17, 'ENTRADA', 60, '2024-01-06 09:30:00', 'Recebimento inicial - NF 1008 Eletrônicos Nacionais'),
    -- Saídas referentes a vendas
    (1,  'SAIDA',   1, '2024-01-15 10:35:00', 'Venda - Pedido #1'),
    (17, 'SAIDA',   2, '2024-01-15 10:36:00', 'Venda - Pedido #1'),
    (5,  'SAIDA',   1, '2024-01-28 14:05:00', 'Venda - Pedido #2'),
    (9,  'SAIDA',   2, '2024-01-28 14:06:00', 'Venda - Pedido #2'),
    (2,  'SAIDA',   1, '2024-02-10 09:50:00', 'Venda - Pedido #3'),
    (3,  'SAIDA',   1, '2024-02-25 16:25:00', 'Venda - Pedido #4'),
    -- Reposições de estoque no meio do ano
    (4,  'ENTRADA', 10, '2024-04-01 08:00:00', 'Reposição - NF 2001 Distribuidora Tech Brasil'),
    (6,  'ENTRADA',  8, '2024-04-01 08:30:00', 'Reposição - NF 2002 Distribuidora Tech Brasil'),
    (8,  'ENTRADA',  5, '2024-04-01 09:00:00', 'Reposição - NF 2003 Nova Era Tecnologia'),
    (11, 'ENTRADA', 25, '2024-04-02 08:00:00', 'Reposição - NF 2004 Digital Parts'),
    (14, 'ENTRADA', 25, '2024-04-02 08:30:00', 'Reposição - NF 2005 Nova Era Tecnologia'),
    (19, 'ENTRADA', 20, '2024-04-02 09:00:00', 'Reposição - NF 2006 Eletrônicos Nacionais'),
    -- Mais saídas referentes a vendas
    (6,  'SAIDA',   1, '2024-03-08 11:05:00', 'Venda - Pedido #5'),
    (4,  'SAIDA',   2, '2024-03-22 13:35:00', 'Venda - Pedido #6'),
    (7,  'SAIDA',   1, '2024-04-05 10:20:00', 'Venda - Pedido #7'),
    (13, 'SAIDA',   1, '2024-04-20 15:50:00', 'Venda - Pedido #8'),
    (14, 'SAIDA',   1, '2024-04-20 15:51:00', 'Venda - Pedido #8'),
    -- Entradas adicionais no segundo semestre
    (15, 'ENTRADA', 40, '2024-07-01 08:00:00', 'Reposição - NF 3001 MegaSupply'),
    (16, 'ENTRADA', 30, '2024-07-01 08:30:00', 'Reposição - NF 3002 Nova Era Tecnologia'),
    (18, 'ENTRADA', 50, '2024-07-01 09:00:00', 'Reposição - NF 3003 Digital Parts'),
    (20, 'ENTRADA', 20, '2024-07-01 09:30:00', 'Reposição - NF 3004 Digital Parts'),
    (12, 'ENTRADA', 10, '2024-09-01 08:00:00', 'Reposição - NF 4001 Digital Parts');

-- ============================================================================
-- ATUALIZAÇÃO DO VALOR TOTAL DOS PEDIDOS
-- Calcula o valor_total de cada pedido com base na soma dos subtotais
-- dos seus respectivos itens.
-- ============================================================================
UPDATE PEDIDO p
SET valor_total = (
    SELECT COALESCE(SUM(ip.subtotal), 0)
    FROM ITEM_PEDIDO ip
    WHERE ip.id_pedido = p.id_pedido
);

-- ============================================================================
-- Fim do arquivo 03_seed.sql
-- ============================================================================
