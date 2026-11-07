-- ============================================================================
-- TechShop Eletrônicos - Índices Estratégicos
-- Arquivo: 04_indexes.sql
-- Descrição: Criação de índices B-Tree para otimização de consultas
--            frequentes no sistema. Inclui exemplos com EXPLAIN ANALYZE
--            para demonstração do plano de execução.
-- Autor: Engenheiro de Banco de Dados Senior
-- Encoding: UTF-8
-- ============================================================================

-- ============================================================================
-- ÍNDICE 1: idx_pedido_data_pedido
-- Tipo: B-Tree (padrão)
-- Justificativa: Otimiza consultas de relatórios mensais e anuais que
--                filtram pedidos por intervalo de datas. Sem este índice,
--                o PostgreSQL realizaria um Sequential Scan (varredura
--                completa) na tabela PEDIDO para cada consulta temporal.
--                Com o índice, o otimizador pode utilizar um Index Scan
--                ou Bitmap Index Scan, reduzindo significativamente o
--                número de páginas lidas do disco.
-- ============================================================================
CREATE INDEX idx_pedido_data_pedido
    ON PEDIDO (data_pedido);

-- Exemplo de consulta que utiliza o índice idx_pedido_data_pedido:
-- Busca todos os pedidos realizados no primeiro trimestre de 2024.
-- Plano esperado: Index Scan usando idx_pedido_data_pedido, pois o filtro
-- por intervalo de datas (BETWEEN) permite o uso eficiente do B-Tree.
-- Em tabelas pequenas, o otimizador pode preferir Seq Scan por ser mais
-- econômico; em produção com milhares de registros, o Index Scan prevalece.
EXPLAIN ANALYZE
SELECT id_pedido, id_cliente, data_pedido, valor_total, status
FROM PEDIDO
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-03-31';

-- ============================================================================
-- ÍNDICE 2: idx_cliente_cpf
-- Tipo: B-Tree (padrão)
-- Justificativa: Embora a coluna CPF já possua uma constraint UNIQUE
--                (que cria implicitamente um índice único), este índice
--                explícito é criado para fins de demonstração com
--                EXPLAIN ANALYZE. Na prática, o PostgreSQL já utiliza
--                o índice único da constraint para buscas por CPF.
--                Este índice é redundante, porém serve como exercício
--                didático para analisar planos de execução.
-- Nota: O comando abaixo pode gerar um aviso de índice duplicado em
--       algumas versões do PostgreSQL. Utilizamos IF NOT EXISTS para
--       evitar erro caso o índice já exista pela constraint UNIQUE.
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_cliente_cpf
    ON CLIENTE (cpf);

-- Exemplo de consulta que utiliza o índice idx_cliente_cpf:
-- Busca um cliente específico pelo número do CPF.
-- Plano esperado: Index Scan usando o índice único do CPF (ou este índice),
-- retornando exatamente 1 linha. A busca B-Tree por igualdade tem
-- complexidade O(log n), extremamente eficiente mesmo em tabelas grandes.
EXPLAIN ANALYZE
SELECT id_cliente, nome, cpf, email, telefone
FROM CLIENTE
WHERE cpf = '345.678.901-22';

-- ============================================================================
-- ÍNDICE 3 (BÔNUS): idx_produto_categoria
-- Tipo: B-Tree (padrão)
-- Justificativa: Otimiza consultas que filtram ou agrupam produtos por
--                categoria, como listagens de catálogo e relatórios de
--                vendas por segmento. Chaves estrangeiras no PostgreSQL
--                não criam índices automaticamente (diferente de alguns
--                outros SGBDs), então este índice é essencial para
--                evitar Sequential Scans em JOINs com a tabela CATEGORIA.
-- ============================================================================
CREATE INDEX idx_produto_categoria
    ON PRODUTO (id_categoria);

-- Exemplo de consulta que utiliza o índice idx_produto_categoria:
-- Lista todos os produtos da categoria "Smartphones" (id_categoria = 1)
-- com seus respectivos nomes e preços.
-- Plano esperado: Index Scan (ou Bitmap Index Scan) usando
-- idx_produto_categoria, seguido de acesso à heap para buscar as
-- colunas restantes. Em tabelas maiores, o ganho de performance
-- em relação ao Seq Scan é substancial.
EXPLAIN ANALYZE
SELECT p.id_produto, p.nome, p.preco, p.quantidade_estoque
FROM PRODUTO p
WHERE p.id_categoria = 1;

-- ============================================================================
-- Fim do arquivo 04_indexes.sql
-- ============================================================================
