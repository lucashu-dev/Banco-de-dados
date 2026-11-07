# 🔍 Caderno de Consultas SQL Avançadas — TechShop Eletrônicos

**Instituição:** Universidade Presbiteriana Mackenzie  
**Curso:** Engenharia da Computação  
**Disciplina:** Banco de Dados  
**Arquivo Executável:** `sql/05_queries.sql`

Este documento apresenta a fundamentação teórica, a análise algorítmica e o detalhamento técnico de cada uma das 10 consultas SQL desenvolvidas para a gestão da TechShop Eletrônicos.

---

## Sumário das Consultas

| ID | Título | Técnicas Utilizadas | Propósito de Negócio |
|---|---|---|---|
| **01** | Catálogo Completo | Triplo `INNER JOIN` | Visão integrada de produtos, categorias e fornecedores |
| **02** | Pedidos Completos | `INNER JOIN`, formatação de data | Rastreamento de pedidos com cliente e vendedor |
| **03** | Faturamento por Cliente | `GROUP BY`, `SUM`, `HAVING`, `AVG` | Identificação de clientes de alto valor (VIPs) |
| **04** | Faturamento Mensal | `DATE_TRUNC`, `GROUP BY`, agregação | Demonstração contábil e evolução temporal |
| **05** | Ranking de Vendedores | `ROW_NUMBER() OVER()`, agregação | Gamificação de vendas e comissionamento |
| **06** | Top 10 Produtos Mais Vendidos | Múltiplos `JOIN`, `SUM`, `ORDER BY DESC`, `LIMIT` | Gestão de giro e reabastecimento de estoque |
| **07** | Alerta de Estoque Crítico | Predicados condicionais, cálculo de déficit | Prevenção de ruptura de estoque |
| **08** | Clientes Inativos | `LEFT JOIN ... WHERE IS NULL` & `NOT EXISTS` | Campanhas de reativação e primeira compra |
| **09** | Produtos Acima da Média | Subconsulta Escalar Correlacionada | Segmentação de itens de alto valor agregado |
| **10** | Histórico e Saldo Acumulado | CTE (`WITH`) + Window Function `SUM() OVER()` | Auditoria fiscal e livro-razão de movimentações |

---

### 1. Consulta 01 — Catálogo Completo de Produtos
- **Técnica:** Triplo `INNER JOIN` (`PRODUTO` + `CATEGORIA` + `FORNECEDOR`).
- **Objetivo:** Oferecer aos vendedores uma tela consolidada contendo todos os dados necessários para cotação e atendimento ao cliente.
- **Trecho SQL:**
```sql
SELECT
    p.id_produto                          AS "ID Produto",
    p.nome                                AS "Produto",
    p.preco                               AS "Preço (R$)",
    c.nome                                AS "Categoria",
    f.nome                                AS "Fornecedor",
    p.quantidade_estoque                  AS "Qtd. Estoque",
    CASE WHEN p.ativo THEN 'Sim' ELSE 'Não' END AS "Ativo"
FROM produto p
INNER JOIN categoria c   ON c.id_categoria  = p.id_categoria
INNER JOIN fornecedor f  ON f.id_fornecedor = p.id_fornecedor
ORDER BY c.nome, p.nome;
```
- **Mecanismo:** O otimizador de consultas realiza Hash Joins ou Nested Loops com base nos índices de PK (`id_categoria` e `id_fornecedor`), eliminando a necessidade de varreduras sequenciais completas.

---

### 2. Consulta 02 — Pedidos Completos com Cliente e Funcionário
- **Técnica:** `INNER JOIN` duplo relacionando a tabela de fatos (`PEDIDO`) com suas dimensões (`CLIENTE` e `FUNCIONARIO`).
- **Objetivo:** Rastreabilidade operacional de cada venda, com identificação do colaborador responsável pela comissão.
- **Trecho SQL:**
```sql
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
```

---

### 3. Consulta 03 — Faturamento por Cliente (Clientes VIP)
- **Técnica:** Agrupamento com `GROUP BY`, funções de agregação `SUM()` e `AVG()`, filtrado pós-agregação via cláusula `HAVING`.
- **Objetivo:** Localizar clientes que ultrapassaram o limiar de consumo acumulado de R$ 500,00 em compras efetivadas (`CONFIRMADO` ou `ENTREGUE`).
- **Trecho SQL:**
```sql
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
```
- **Diferença Teórica `WHERE` vs `HAVING`:** O `WHERE` filtra tuplas antes da agregação (eliminando pedidos pendentes/cancelados); o `HAVING` avalia o resultado do cálculo agregado (`SUM > 500.00`).

---

### 4. Consulta 04 — Faturamento Mensal Consolidado
- **Técnica:** Função cronológica `DATE_TRUNC('month', data_pedido)` e agrupamento temporal.
- **Objetivo:** Fornecer dados para demonstrativo contábil mensal de receita bruta e evolução do ticket médio.
- **Trecho SQL:**
```sql
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
```

---

### 5. Consulta 05 — Ranking de Vendedores com Função Analítica
- **Técnica:** Window function `ROW_NUMBER() OVER()` combinada com agrupamento relacional.
- **Objetivo:** Atribuir posições competitivas dinâmicas (1º, 2º, 3º...) aos colaboradores com base no volume faturado.
- **Trecho SQL:**
```sql
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
```

---

### 6. Consulta 06 — Top 10 Produtos Mais Vendidos
- **Técnica:** Junção da tabela associativa `ITEM_PEDIDO` com `PRODUTO`, ordenação decrescente e corte determinístico via `LIMIT 10`.
- **Objetivo:** Decisão de reposição preventiva de estoque (itens de curva A).
- **Trecho SQL:**
```sql
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
```

---

### 7. Consulta 07 — Alerta de Ruptura de Estoque (Estoque Crítico)
- **Técnica:** Comparação relacional entre colunas da mesma tupla (`quantidade_estoque <= estoque_minimo`) com projeção de déficit calculado.
- **Objetivo:** Geração automática da lista de compras com dados diretos do fornecedor para contato imediato.
- **Trecho SQL:**
```sql
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
```

---

### 8. Consulta 08 — Clientes Inativos (Sem Histórico de Compras)
- **Técnica:** Junção externa à esquerda (`LEFT JOIN`) com filtro de tuplas não casadas (`WHERE pe.id_pedido IS NULL`), com formulação equivalente via `NOT EXISTS`.
- **Objetivo:** Identificar clientes da base que nunca geraram receita para remarketing.
- **Trecho SQL (Versão A — `LEFT JOIN`):**
```sql
SELECT
    cl.id_cliente,
    cl.nome,
    cl.email,
    cl.telefone,
    TO_CHAR(cl.data_cadastro, 'DD/MM/YYYY') AS "Data Cadastro"
FROM cliente cl
LEFT JOIN pedido pe ON pe.id_cliente = cl.id_cliente
WHERE pe.id_pedido IS NULL
ORDER BY cl.data_cadastro;
```
- **Trecho SQL (Versão B — `NOT EXISTS` Semi-Anti-Join):**
```sql
SELECT
    cl.id_cliente,
    cl.nome,
    cl.email,
    cl.telefone,
    TO_CHAR(cl.data_cadastro, 'DD/MM/YYYY') AS "Data Cadastro"
FROM cliente cl
WHERE NOT EXISTS (
    SELECT 1 FROM pedido pe WHERE pe.id_cliente = cl.id_cliente
)
ORDER BY cl.data_cadastro;
```

---

### 9. Consulta 09 — Produtos com Preço Superior à Média de Catálogo
- **Técnica:** Subconsulta escalar não-correlacionada no predicado `WHERE`, além de cálculo analítico de percentual de dispersão.
- **Objetivo:** Segmentação de produtos da categoria Premium.
- **Trecho SQL:**
```sql
SELECT
    p.id_produto                          AS "ID Produto",
    p.nome                                AS "Produto",
    c.nome                                AS "Categoria",
    p.preco                               AS "Preço (R$)",
    ROUND((SELECT AVG(p2.preco) FROM produto p2 WHERE p2.ativo = TRUE), 2) AS "Média Geral (R$)",
    ROUND(p.preco - (SELECT AVG(p2.preco) FROM produto p2 WHERE p2.ativo = TRUE), 2) AS "Diferença (R$)",
    ROUND((p.preco / NULLIF((SELECT AVG(p2.preco) FROM produto p2 WHERE p2.ativo = TRUE), 0) - 1) * 100, 1) AS "% Acima"
FROM produto p
INNER JOIN categoria c ON c.id_categoria = p.id_categoria
WHERE p.ativo = TRUE
  AND p.preco > (SELECT AVG(p2.preco) FROM produto p2 WHERE p2.ativo = TRUE)
ORDER BY p.preco DESC;
```

---

### 10. Consulta 10 — Auditoria de Estoque com Saldo Acumulado (Window Function)
- **Técnica:** Expressão de Tabela Comum (`WITH ... AS`) e Window Function com moldura de janela cumulativa:  
  `SUM(...) OVER (PARTITION BY id_produto ORDER BY data_movimentacao ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.
- **Objetivo:** Reconstrução histórica de saldo e rastreabilidade forense completa em caso de desvios físicos de estoque.
- **Trecho SQL:**
```sql
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
```
- **Conclusão:** Esta consulta demonstra o estado da arte do SQL moderno, viabilizando relatórios de auditoria contábil sem necessidade de recalcular estoques em memória na camada de aplicação.
