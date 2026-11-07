-- ============================================================================
-- TechShop Eletrônicos - Restrições de Integridade (Constraints)
-- Arquivo: 02_constraints.sql
-- Descrição: Adição de constraints CHECK nomeadas para garantir a
--            integridade dos dados em nível de aplicação e banco.
-- Autor: Engenheiro de Banco de Dados Senior
-- Encoding: UTF-8
-- ============================================================================

-- ============================================================================
-- CONSTRAINTS DA TABELA PRODUTO
-- ============================================================================

-- Garante que o preço do produto seja sempre positivo
ALTER TABLE PRODUTO
    ADD CONSTRAINT CHK_PRODUTO_PRECO
    CHECK (preco > 0);

-- Garante que a quantidade em estoque nunca seja negativa
ALTER TABLE PRODUTO
    ADD CONSTRAINT CHK_PRODUTO_ESTOQUE
    CHECK (quantidade_estoque >= 0);

-- Garante que o estoque mínimo nunca seja negativo
ALTER TABLE PRODUTO
    ADD CONSTRAINT CHK_PRODUTO_ESTOQUE_MIN
    CHECK (estoque_minimo >= 0);

-- ============================================================================
-- CONSTRAINTS DA TABELA ITEM_PEDIDO
-- ============================================================================

-- Garante que a quantidade de itens no pedido seja ao menos 1
ALTER TABLE ITEM_PEDIDO
    ADD CONSTRAINT CHK_ITEM_QUANTIDADE
    CHECK (quantidade > 0);

-- Garante que o preço unitário do item seja sempre positivo
ALTER TABLE ITEM_PEDIDO
    ADD CONSTRAINT CHK_ITEM_PRECO
    CHECK (preco_unitario > 0);

-- Garante que o desconto não seja negativo
ALTER TABLE ITEM_PEDIDO
    ADD CONSTRAINT CHK_ITEM_DESCONTO
    CHECK (desconto >= 0);

-- Garante que o subtotal do item seja sempre positivo
ALTER TABLE ITEM_PEDIDO
    ADD CONSTRAINT CHK_ITEM_SUBTOTAL
    CHECK (subtotal > 0);

-- ============================================================================
-- CONSTRAINTS DA TABELA PEDIDO
-- ============================================================================

-- Garante que o valor total do pedido não seja negativo
ALTER TABLE PEDIDO
    ADD CONSTRAINT CHK_PEDIDO_VALOR
    CHECK (valor_total >= 0);

-- Restringe os valores possíveis para o status do pedido
ALTER TABLE PEDIDO
    ADD CONSTRAINT CHK_PEDIDO_STATUS
    CHECK (status IN ('PENDENTE', 'CONFIRMADO', 'CANCELADO', 'ENTREGUE'));

-- ============================================================================
-- CONSTRAINTS DA TABELA MOVIMENTACAO_ESTOQUE
-- ============================================================================

-- Restringe o tipo de movimentação a ENTRADA ou SAIDA
ALTER TABLE MOVIMENTACAO_ESTOQUE
    ADD CONSTRAINT CHK_MOV_TIPO
    CHECK (tipo_movimentacao IN ('ENTRADA', 'SAIDA'));

-- Garante que a quantidade movimentada seja sempre positiva
ALTER TABLE MOVIMENTACAO_ESTOQUE
    ADD CONSTRAINT CHK_MOV_QUANTIDADE
    CHECK (quantidade > 0);

-- ============================================================================
-- Fim do arquivo 02_constraints.sql
-- ============================================================================
