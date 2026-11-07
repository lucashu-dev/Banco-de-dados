# 📚 Dicionário de Dados — TechShop Eletrônicos

**Instituição:** Universidade Presbiteriana Mackenzie  
**Curso:** Engenharia da Computação  
**Disciplina:** Banco de Dados  
**SGBD Alvo:** PostgreSQL 15+ (compatível com SQLite 3 com adaptações de tipos)

---

## 1. Convenções e Notações

- **PK (Primary Key):** Identificador exclusivo e imutável da tupla. No PostgreSQL implementado como `SERIAL` (inteiro auto-incremental de 4 bytes indexado por árvore B-Tree).
- **FK (Foreign Key):** Chave estrangeira que assegura integridade referencial com regra `ON DELETE RESTRICT` e `ON UPDATE CASCADE`.
- **UK (Unique Key):** Restrição de unicidade para evitar duplicidade lógica (índice B-Tree implícito).
- **NOT NULL:** Campo de preenchimento obrigatório.
- **CHECK:** Restrição de domínio e integridade semântica no nível de tupla.

---

## 2. Entidades do Sistema

### 2.1. Tabela: `CATEGORIA`
Classificação mercadológica de produtos eletrônicos e componentes de informática.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_categoria` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Chave primária auto-incremental da categoria |
| `nome` | `VARCHAR(100)` | NÃO | `NOT NULL` | Nome descritivo da categoria (ex: 'Notebooks') |
| `descricao` | `TEXT` | SIM | — | Detalhamento sobre os tipos de produtos enquadrados |

---

### 2.2. Tabela: `FORNECEDOR`
Registro de fabricantes, importadores e distribuidores credenciados pela TechShop.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_fornecedor` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Chave primária auto-incremental do fornecedor |
| `nome` | `VARCHAR(150)` | NÃO | `NOT NULL` | Razão Social ou Nome Fantasia da empresa |
| `cnpj` | `VARCHAR(18)` | NÃO | `NOT NULL`, `UNIQUE` | Cadastro Nacional de Pessoa Jurídica formatado |
| `telefone` | `VARCHAR(15)` | SIM | — | Telefone institucional para contato e compras |
| `email` | `VARCHAR(100)` | SIM | — | E-mail corporativo para envio de ordens de fornecimento |

---

### 2.3. Tabela: `PRODUTO`
Catálogo de produtos físicos comercializados pela loja, com controle de estoque integrado.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_produto` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Identificador único do produto |
| `id_categoria` | `INTEGER` | NÃO | `FOREIGN KEY` (CATEGORIA) | Categoria mercadológica do produto |
| `id_fornecedor`| `INTEGER` | NÃO | `FOREIGN KEY` (FORNECEDOR)| Fornecedor responsável pela entrega do lote |
| `nome` | `VARCHAR(200)` | NÃO | `NOT NULL` | Nome técnico e comercial do produto |
| `descricao` | `TEXT` | SIM | — | Ficha técnica e especificações do equipamento |
| `preco` | `NUMERIC(10,2)` | NÃO | `NOT NULL`, `CHECK (preco > 0)` | Preço unitário de venda ao consumidor (R$) |
| `quantidade_estoque` | `INTEGER` | NÃO | `DEFAULT 0`, `CHECK (>= 0)` | Saldo físico atual em estoque na loja |
| `estoque_minimo` | `INTEGER` | NÃO | `DEFAULT 5`, `CHECK (>= 0)` | Ponto crítico de ressuprimento (gatilho de alerta) |
| `ativo` | `BOOLEAN` | NÃO | `DEFAULT TRUE` | Flag de ativação no catálogo (Soft delete) |

---

### 2.4. Tabela: `CLIENTE`
Cadastro de clientes consumidores finais ou corporativos da TechShop Eletrônicos.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_cliente` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Identificador único do cliente |
| `nome` | `VARCHAR(150)` | NÃO | `NOT NULL` | Nome completo do cliente |
| `cpf` | `VARCHAR(14)` | NÃO | `NOT NULL`, `UNIQUE` | CPF único e formatado (ex: '000.000.000-00') |
| `email` | `VARCHAR(100)` | NÃO | `NOT NULL` | E-mail para envio de comprovantes e tracking |
| `telefone` | `VARCHAR(15)` | SIM | — | Contato celular ou fixo |
| `data_cadastro`| `TIMESTAMP` | NÃO | `DEFAULT NOW()` | Carimbo temporal do momento de ingresso no sistema |

---

### 2.5. Tabela: `FUNCIONARIO`
Corpo de colaboradores autorizados a operar os módulos de venda, estoque e gestão.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_funcionario` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Identificador único do colaborador |
| `nome` | `VARCHAR(150)` | NÃO | `NOT NULL` | Nome completo do funcionário |
| `cpf` | `VARCHAR(14)` | NÃO | `NOT NULL`, `UNIQUE` | CPF oficial do colaborador |
| `cargo` | `VARCHAR(50)` | NÃO | `NOT NULL` | Cargo funcional (ex: 'Vendedor', 'Gerente', 'Estoquista') |
| `email` | `VARCHAR(100)` | NÃO | `NOT NULL` | E-mail corporativo da empresa |
| `data_admissao` | `DATE` | NÃO | `NOT NULL` | Data formal de admissão na TechShop |

---

### 2.6. Tabela: `PEDIDO`
Registro central de cada transação de venda realizada no estabelecimento.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_pedido` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Número da ordem de venda / pedido |
| `id_cliente` | `INTEGER` | NÃO | `FOREIGN KEY` (CLIENTE) | Cliente titular da compra |
| `id_funcionario` | `INTEGER` | NÃO | `FOREIGN KEY` (FUNCIONARIO)| Vendedor ou atendente responsável pelo atendimento |
| `data_pedido` | `TIMESTAMP` | NÃO | `DEFAULT NOW()` | Data e hora em que a ordem foi gerada |
| `valor_total` | `NUMERIC(10,2)` | NÃO | `DEFAULT 0`, `CHECK (>= 0)`| Somatório líquido consolidado de todos os itens |
| `status` | `VARCHAR(20)` | NÃO | `DEFAULT 'PENDENTE'`, `CHECK` | Estado da venda: 'PENDENTE', 'CONFIRMADO', 'CANCELADO', 'ENTREGUE' |

---

### 2.7. Tabela: `ITEM_PEDIDO`
Detalhamento de cada linha de produto vinculada a um pedido específico.

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_item` | `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Identificador sequencial da linha de item |
| `id_pedido` | `INTEGER` | NÃO | `FOREIGN KEY` (PEDIDO) | Vínculo obrigatório com o cabeçalho do pedido |
| `id_produto` | `INTEGER` | NÃO | `FOREIGN KEY` (PRODUTO) | Produto que está sendo adquirido |
| `quantidade` | `INTEGER` | NÃO | `CHECK (quantidade > 0)` | Número de unidades solicitadas |
| `preco_unitario`| `NUMERIC(10,2)` | NÃO | `CHECK (preco_unitario > 0)`| Preço de tabela no momento do fechamento da compra |
| `desconto` | `NUMERIC(5,2)` | NÃO | `DEFAULT 0`, `CHECK (>= 0)`| Desconto monetário concedido na unidade ou linha |
| `subtotal` | `NUMERIC(10,2)` | NÃO | `CHECK (subtotal > 0)` | `(quantidade * preco_unitario) - desconto` |

---

### 2.8. Tabela: `MOVIMENTACAO_ESTOQUE`
Livro-razão e log imutável de fluxo de estoque (auditoria e rastreabilidade).

| Campo | Tipo de Dado | Nullable | Restrição | Descrição |
| :--- | :--- | :---: | :--- | :--- |
| `id_movimentacao`| `SERIAL` (INTEGER) | NÃO | `PRIMARY KEY` | Registro individual do evento de estoque |
| `id_produto` | `INTEGER` | NÃO | `FOREIGN KEY` (PRODUTO) | Item físico envolvido no fluxo |
| `tipo_movimentacao`| `VARCHAR(10)` | NÃO | `CHECK IN ('ENTRADA', 'SAIDA')`| Natureza do fluxo: ENTRADA (compra/devolução) ou SAIDA (venda/avaria) |
| `quantidade` | `INTEGER` | NÃO | `CHECK (quantidade > 0)` | Volume de itens transacionados no evento |
| `data_movimentacao`| `TIMESTAMP` | NÃO | `DEFAULT NOW()` | Registro de data/hora exata do lançamento físico |
| `observacao` | `TEXT` | SIM | — | Motivo ou documento de lastro (ex: 'Venda Pedido #12', 'NF Entrada 4410') |

---

## 3. Matriz de Integridade Referencial (Regras de FK)

| Chave Estrangeira | Tabela Origem | Tabela Destino | Ação `ON DELETE` | Ação `ON UPDATE` | Justificativa de Negócio |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `fk_prod_categoria` | `PRODUTO` | `CATEGORIA` | `RESTRICT` | `CASCADE` | Impede apagar categorias com produtos em catálogo. |
| `fk_prod_fornecedor`| `PRODUTO` | `FORNECEDOR` | `RESTRICT` | `CASCADE` | Mantém histórico de quem forneceu cada mercadoria. |
| `fk_ped_cliente` | `PEDIDO` | `CLIENTE` | `RESTRICT` | `CASCADE` | Impede expurgar clientes com histórico fiscal/vendas. |
| `fk_ped_funcionario`| `PEDIDO` | `FUNCIONARIO` | `RESTRICT` | `CASCADE` | Mantém rastreabilidade de comissão e auditoria. |
| `fk_item_pedido` | `ITEM_PEDIDO` | `PEDIDO` | `CASCADE` / `RESTRICT`| `CASCADE` | Pedido excluído em rascunho limpa itens; em produção, usa-se cancelamento. |
| `fk_item_produto` | `ITEM_PEDIDO` | `PRODUTO` | `RESTRICT` | `CASCADE` | Não permite apagar produto já faturado. |
| `fk_mov_produto` | `MOVIMENTACAO`| `PRODUTO` | `RESTRICT` | `CASCADE` | Auditoria de estoque não pode sofrer perda de referência. |
