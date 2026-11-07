-- ============================================================
-- Arquivo: 05_queries.sql
-- Projeto: TechShop Eletrônicos — Banco de Dados PostgreSQL
-- Descrição: 10 consultas avançadas demonstrando técnicas
--            profissionais de SQL (JOINs, agrupamentos,
--            subconsultas, CTEs e Window Functions).
-- Codificação: UTF-8
-- ============================================================

-- ============================================================
-- CONSULTA 01: Catálogo Completo de Produtos
-- Técnica: Triplo INNER JOIN (PRODUTO + CATEGORIA + FORNECEDOR)
-- Objetivo: Exibir o catálogo com nome do produto, preço,
--           categoria, fornecedor e quantidade em estoque,
--           permitindo visão unificada para equipe comercial.
-- ============================================================
SELECT
    p.id_produto                          AS "ID Produto",
    p.nome                                AS "Produto",
    p.preco                               AS "Preço (R$)",
    c.nome                                AS "Categoria",
    f.nome                                AS "Fornecedor",
    p.quantidade_estoque                  AS "Qtd. Estoque",
    CASE
        WHEN p.ativo THEN 'Sim'
        ELSE 'Não'
    END                                   AS "Ativo"
FROM produto p
INNER JOIN categoria c   ON c.id_categoria  = p.id_categoria
INNER JOIN fornecedor f  ON f.id_fornecedor = p.id_fornecedor
ORDER BY c.nome, p.nome;


-- ============================================================
-- CONSULTA 02: Pedidos Completos com Cliente e Funcionário
-- Técnica: INNER JOIN (PEDIDO + CLIENTE + FUNCIONARIO)
-- Objetivo: Listar todos os pedidos com informações do cliente
--           que realizou a compra e do funcionário responsável
--           pelo atendimento, incluindo valor e status.
-- ============================================================
SELECT
    pe.id_pedido                                       AS "Nº Pedido",
    TO_CHAR(pe.data_pedido, 'DD/MM/YYYY HH24:MI')     AS "Data/Hora",
    cl.nome                                            AS "Cliente",
    fu.nome                                            AS "Funcionário",
    fu.cargo                                           AS "Cargo",
    pe.valor_total                                     AS "Valor Total (R$)",
    pe.status                                          AS "Status"
FROM pedido pe
INNER JOIN cliente cl      ON cl.id_cliente     = pe.id_cliente
INNER JOIN funcionario fu  ON fu.id_funcionario = pe.id_funcionario
ORDER BY pe.data_pedido DESC;


-- ============================================================
-- CONSULTA 03: Faturamento por Cliente (clientes VIP)
-- Técnica: GROUP BY + SUM + COUNT + HAVING
-- Objetivo: Identificar os clientes que gastaram mais de
--           R$ 500,00 no total, exibindo a quantidade de
--           pedidos e o valor acumulado — útil para programas
--           de fidelidade e campanhas de marketing.
-- ============================================================
SELECT
    cl.id_cliente                          AS "ID Cliente",
    cl.nome                                AS "Cliente",
    cl.email                               AS "E-mail",
    COUNT(pe.id_pedido)                    AS "Total de Pedidos",
    SUM(pe.valor_total)                    AS "Valor Total Gasto (R$)",
    ROUND(AVG(pe.valor_total), 2)          AS "Ticket Médio (R$)"
FROM cliente cl
INNER JOIN pedido pe ON pe.id_cliente = cl.id_cliente
WHERE pe.status IN ('CONFIRMADO', 'ENTREGUE')
GROUP BY cl.id_cliente, cl.nome, cl.email
HAVING SUM(pe.valor_total) > 500.00
ORDER BY SUM(pe.valor_total) DESC;


-- ============================================================
-- CONSULTA 04: Faturamento Mensal
-- Técnica: DATE_TRUNC + GROUP BY (ano/mês) + SUM + filtro
-- Objetivo: Apresentar o faturamento mensal considerando
--           apenas pedidos confirmados ou entregues, essencial
--           para relatórios financeiros e análise de tendência.
-- ============================================================
SELECT
    EXTRACT(YEAR FROM DATE_TRUNC('month', pe.data_pedido))   AS "Ano",
    EXTRACT(MONTH FROM DATE_TRUNC('month', pe.data_pedido))  AS "Mês",
    TO_CHAR(DATE_TRUNC('month', pe.data_pedido), 'MM/YYYY')  AS "Período",
    COUNT(pe.id_pedido)                                       AS "Qtd. Pedidos",
    SUM(pe.valor_total)                                       AS "Faturamento (R$)",
    ROUND(AVG(pe.valor_total), 2)                             AS "Ticket Médio (R$)"
FROM pedido pe
WHERE pe.status IN ('CONFIRMADO', 'ENTREGUE')
GROUP BY DATE_TRUNC('month', pe.data_pedido)
ORDER BY DATE_TRUNC('month', pe.data_pedido);


-- ============================================================
-- CONSULTA 05: Ranking de Vendedores
-- Técnica: GROUP BY + SUM + ORDER BY DESC + ROW_NUMBER
-- Objetivo: Classificar os funcionários pelo volume total de
--           vendas (pedidos confirmados/entregues), permitindo
--           avaliação de desempenho e cálculo de comissões.
-- ============================================================
SELECT
    ROW_NUMBER() OVER (ORDER BY SUM(pe.valor_total) DESC)  AS "Posição",
    fu.id_funcionario                                       AS "ID Funcionário",
    fu.nome                                                 AS "Funcionário",
    fu.cargo                                                AS "Cargo",
    COUNT(pe.id_pedido)                                     AS "Pedidos Atendidos",
    SUM(pe.valor_total)                                     AS "Total Vendido (R$)",
    ROUND(AVG(pe.valor_total), 2)                           AS "Ticket Médio (R$)"
FROM funcionario fu
INNER JOIN pedido pe ON pe.id_funcionario = fu.id_funcionario
WHERE pe.status IN ('CONFIRMADO', 'ENTREGUE')
GROUP BY fu.id_funcionario, fu.nome, fu.cargo
ORDER BY SUM(pe.valor_total) DESC;


-- ============================================================
-- CONSULTA 06: Top 10 Produtos Mais Vendidos
-- Técnica: JOIN + GROUP BY + SUM + ORDER BY DESC + LIMIT
-- Objetivo: Listar os 10 produtos com maior volume de vendas
--           (em unidades), auxiliando na gestão de estoque
--           e nas decisões de reposição.
-- ============================================================
SELECT
    p.id_produto                          AS "ID Produto",
    p.nome                                AS "Produto",
    c.nome                                AS "Categoria",
    SUM(ip.quantidade)                    AS "Total Vendido (un.)",
    SUM(ip.subtotal)                      AS "Receita Total (R$)",
    ROUND(AVG(ip.preco_unitario), 2)      AS "Preço Médio (R$)"
FROM item_pedido ip
INNER JOIN produto p    ON p.id_produto   = ip.id_produto
INNER JOIN categoria c  ON c.id_categoria = p.id_categoria
INNER JOIN pedido pe    ON pe.id_pedido   = ip.id_pedido
WHERE pe.status IN ('CONFIRMADO', 'ENTREGUE')
GROUP BY p.id_produto, p.nome, c.nome
ORDER BY SUM(ip.quantidade) DESC
LIMIT 10;


-- ============================================================
-- CONSULTA 07: Alerta de Estoque Baixo
-- Técnica: WHERE com comparação entre colunas + filtro booleano
-- Objetivo: Identificar produtos ativos cujo estoque atual
--           está igual ou abaixo do estoque mínimo definido,
--           sinalizando necessidade urgente de reposição.
-- ============================================================
SELECT
    p.id_produto                          AS "ID Produto",
    p.nome                                AS "Produto",
    c.nome                                AS "Categoria",
    f.nome                                AS "Fornecedor",
    f.telefone                            AS "Tel. Fornecedor",
    f.email                               AS "E-mail Fornecedor",
    p.quantidade_estoque                  AS "Estoque Atual",
    p.estoque_minimo                      AS "Estoque Mínimo",
    (p.estoque_minimo - p.quantidade_estoque) AS "Déficit"
FROM produto p
INNER JOIN categoria c   ON c.id_categoria  = p.id_categoria
INNER JOIN fornecedor f  ON f.id_fornecedor = p.id_fornecedor
WHERE p.quantidade_estoque <= p.estoque_minimo
  AND p.ativo = TRUE
ORDER BY (p.estoque_minimo - p.quantidade_estoque) DESC;


-- ============================================================
-- CONSULTA 08: Clientes Inativos (sem nenhum pedido)
-- Técnica: LEFT JOIN + IS NULL / alternativa com NOT EXISTS
-- Objetivo: Encontrar clientes cadastrados que nunca fizeram
--           pedidos, possibilitando ações de reengajamento
--           e campanhas de primeira compra.
-- ============================================================

-- Versão A: LEFT JOIN + IS NULL
SELECT
    cl.id_cliente                                              AS "ID Cliente",
    cl.nome                                                    AS "Cliente",
    cl.email                                                   AS "E-mail",
    cl.telefone                                                AS "Telefone",
    TO_CHAR(cl.data_cadastro, 'DD/MM/YYYY')                    AS "Data Cadastro"
FROM cliente cl
LEFT JOIN pedido pe ON pe.id_cliente = cl.id_cliente
WHERE pe.id_pedido IS NULL
ORDER BY cl.data_cadastro;

-- Versão B (alternativa): NOT EXISTS
SELECT
    cl.id_cliente                                              AS "ID Cliente",
    cl.nome                                                    AS "Cliente",
    cl.email                                                   AS "E-mail",
    cl.telefone                                                AS "Telefone",
    TO_CHAR(cl.data_cadastro, 'DD/MM/YYYY')                    AS "Data Cadastro"
FROM cliente cl
WHERE NOT EXISTS (
    SELECT 1
    FROM pedido pe
    WHERE pe.id_cliente = cl.id_cliente
)
ORDER BY cl.data_cadastro;


-- ============================================================
-- CONSULTA 09: Produtos com Preço Acima da Média
-- Técnica: Subconsulta escalar no WHERE (subquery)
-- Objetivo: Listar produtos ativos cujo preço é superior à
--           média geral de preços dos produtos ativos,
--           destacando itens premium do catálogo.
-- ============================================================
SELECT
    p.id_produto                          AS "ID Produto",
    p.nome                                AS "Produto",
    c.nome                                AS "Categoria",
    p.preco                               AS "Preço (R$)",
    ROUND((
        SELECT AVG(p2.preco)
        FROM produto p2
        WHERE p2.ativo = TRUE
    ), 2)                                 AS "Média Geral (R$)",
    ROUND(p.preco - (
        SELECT AVG(p2.preco)
        FROM produto p2
        WHERE p2.ativo = TRUE
    ), 2)                                 AS "Diferença (R$)",
    ROUND(
        (p.preco / NULLIF((
            SELECT AVG(p2.preco)
            FROM produto p2
            WHERE p2.ativo = TRUE
        ), 0) - 1) * 100, 1
    )                                     AS "% Acima da Média"
FROM produto p
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
WHERE p.ativo = TRUE
  AND p.preco > (
      SELECT AVG(p2.preco)
      FROM produto p2
      WHERE p2.ativo = TRUE
  )
ORDER BY p.preco DESC;


-- ============================================================
-- CONSULTA 10: Histórico de Movimentação com Saldo Acumulado
-- Técnica: CTE + Window Function (SUM OVER PARTITION BY / ORDER BY)
-- Objetivo: Exibir o histórico completo de movimentações de
--           estoque por produto, calculando o saldo acumulado
--           em tempo real (entradas somam, saídas subtraem),
--           essencial para auditoria e rastreabilidade.
-- ============================================================
WITH movimentacoes_calculadas AS (
    SELECT
        me.id_movimentacao,
        me.id_produto,
        p.nome                                          AS nome_produto,
        me.tipo_movimentacao,
        me.quantidade,
        CASE
            WHEN me.tipo_movimentacao = 'ENTRADA' THEN  me.quantidade
            WHEN me.tipo_movimentacao = 'SAIDA'   THEN -me.quantidade
        END                                             AS quantidade_sinalizada,
        me.data_movimentacao,
        me.observacao
    FROM movimentacao_estoque me
    INNER JOIN produto p ON p.id_produto = me.id_produto
)
SELECT
    mc.id_movimentacao                                  AS "ID Mov.",
    mc.nome_produto                                     AS "Produto",
    mc.tipo_movimentacao                                AS "Tipo",
    mc.quantidade                                       AS "Quantidade",
    mc.quantidade_sinalizada                            AS "Qtd. Sinalizada",
    SUM(mc.quantidade_sinalizada) OVER (
        PARTITION BY mc.id_produto
        ORDER BY mc.data_movimentacao, mc.id_movimentacao
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                   AS "Saldo Acumulado",
    TO_CHAR(mc.data_movimentacao, 'DD/MM/YYYY HH24:MI') AS "Data/Hora",
    COALESCE(mc.observacao, '—')                        AS "Observação"
FROM movimentacoes_calculadas mc
ORDER BY mc.id_produto, mc.data_movimentacao, mc.id_movimentacao;
