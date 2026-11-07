-- ============================================================================
-- TechShop Eletrônicos - Esquema do Banco de Dados (DDL)
-- Arquivo: 01_schema.sql
-- Descrição: Criação completa das tabelas do sistema de gestão da loja
--            de eletrônicos TechShop. Inclui todas as chaves primárias,
--            chaves estrangeiras e valores padrão.
-- Autor: Engenheiro de Banco de Dados Senior
-- Encoding: UTF-8
-- ============================================================================

-- ============================================================================
-- REMOÇÃO DAS TABELAS (ordem reversa de dependência)
-- ============================================================================

DROP TABLE IF EXISTS MOVIMENTACAO_ESTOQUE;
DROP TABLE IF EXISTS ITEM_PEDIDO;
DROP TABLE IF EXISTS PEDIDO;
DROP TABLE IF EXISTS FUNCIONARIO;
DROP TABLE IF EXISTS CLIENTE;
DROP TABLE IF EXISTS PRODUTO;
DROP TABLE IF EXISTS FORNECEDOR;
DROP TABLE IF EXISTS CATEGORIA;

-- ============================================================================
-- CRIAÇÃO DAS TABELAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabela: CATEGORIA
-- Descrição: Armazena as categorias de produtos vendidos na loja.
-- ----------------------------------------------------------------------------
CREATE TABLE CATEGORIA (
    id_categoria SERIAL       PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    descricao    TEXT
);

-- ----------------------------------------------------------------------------
-- Tabela: FORNECEDOR
-- Descrição: Cadastro dos fornecedores de produtos eletrônicos.
-- ----------------------------------------------------------------------------
CREATE TABLE FORNECEDOR (
    id_fornecedor SERIAL       PRIMARY KEY,
    nome          VARCHAR(150) NOT NULL,
    cnpj          VARCHAR(18)  NOT NULL UNIQUE,
    telefone      VARCHAR(15),
    email         VARCHAR(100)
);

-- ----------------------------------------------------------------------------
-- Tabela: PRODUTO
-- Descrição: Catálogo de produtos disponíveis para venda.
--            Relaciona-se com CATEGORIA e FORNECEDOR.
-- ----------------------------------------------------------------------------
CREATE TABLE PRODUTO (
    id_produto         SERIAL        PRIMARY KEY,
    id_categoria       INTEGER       NOT NULL REFERENCES CATEGORIA(id_categoria) ON DELETE RESTRICT,
    id_fornecedor      INTEGER       NOT NULL REFERENCES FORNECEDOR(id_fornecedor) ON DELETE RESTRICT,
    nome               VARCHAR(200)  NOT NULL,
    descricao          TEXT,
    preco              NUMERIC(10,2) NOT NULL,
    quantidade_estoque INTEGER       NOT NULL DEFAULT 0,
    estoque_minimo     INTEGER       NOT NULL DEFAULT 5,
    ativo              BOOLEAN       DEFAULT TRUE
);

-- ----------------------------------------------------------------------------
-- Tabela: CLIENTE
-- Descrição: Cadastro dos clientes da loja.
-- ----------------------------------------------------------------------------
CREATE TABLE CLIENTE (
    id_cliente     SERIAL       PRIMARY KEY,
    nome           VARCHAR(150) NOT NULL,
    cpf            VARCHAR(14)  NOT NULL UNIQUE,
    email          VARCHAR(100),
    telefone       VARCHAR(15),
    data_cadastro  TIMESTAMP    DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- Tabela: FUNCIONARIO
-- Descrição: Cadastro dos funcionários que operam no sistema.
-- ----------------------------------------------------------------------------
CREATE TABLE FUNCIONARIO (
    id_funcionario SERIAL       PRIMARY KEY,
    nome           VARCHAR(150) NOT NULL,
    cpf            VARCHAR(14)  NOT NULL UNIQUE,
    cargo          VARCHAR(50)  NOT NULL,
    email          VARCHAR(100),
    data_admissao  DATE         NOT NULL
);

-- ----------------------------------------------------------------------------
-- Tabela: PEDIDO
-- Descrição: Registro de pedidos realizados pelos clientes.
--            Cada pedido é atendido por um funcionário.
-- ----------------------------------------------------------------------------
CREATE TABLE PEDIDO (
    id_pedido      SERIAL        PRIMARY KEY,
    id_cliente     INTEGER       NOT NULL REFERENCES CLIENTE(id_cliente) ON DELETE RESTRICT,
    id_funcionario INTEGER       NOT NULL REFERENCES FUNCIONARIO(id_funcionario) ON DELETE RESTRICT,
    data_pedido    TIMESTAMP     DEFAULT NOW(),
    valor_total    NUMERIC(10,2) DEFAULT 0,
    status         VARCHAR(20)   DEFAULT 'PENDENTE'
);

-- ----------------------------------------------------------------------------
-- Tabela: ITEM_PEDIDO
-- Descrição: Itens individuais que compõem cada pedido.
--            Relaciona PEDIDO com PRODUTO.
-- ----------------------------------------------------------------------------
CREATE TABLE ITEM_PEDIDO (
    id_item        SERIAL        PRIMARY KEY,
    id_pedido      INTEGER       NOT NULL REFERENCES PEDIDO(id_pedido) ON DELETE RESTRICT,
    id_produto     INTEGER       NOT NULL REFERENCES PRODUTO(id_produto) ON DELETE RESTRICT,
    quantidade     INTEGER       NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,
    desconto       NUMERIC(5,2)  DEFAULT 0,
    subtotal       NUMERIC(10,2) NOT NULL
);

-- ----------------------------------------------------------------------------
-- Tabela: MOVIMENTACAO_ESTOQUE
-- Descrição: Registro de todas as movimentações de entrada e saída
--            de produtos no estoque.
-- ----------------------------------------------------------------------------
CREATE TABLE MOVIMENTACAO_ESTOQUE (
    id_movimentacao   SERIAL      PRIMARY KEY,
    id_produto        INTEGER     NOT NULL REFERENCES PRODUTO(id_produto) ON DELETE RESTRICT,
    tipo_movimentacao VARCHAR(10) NOT NULL,
    quantidade        INTEGER     NOT NULL,
    data_movimentacao TIMESTAMP   DEFAULT NOW(),
    observacao        TEXT
);

-- ============================================================================
-- Fim do arquivo 01_schema.sql
-- ============================================================================
