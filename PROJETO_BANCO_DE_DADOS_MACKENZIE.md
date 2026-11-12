# Projeto de Banco de Dados

**Nomes:** Felipe Siqueira, Lucas Hu, Luiggi e Giuseppe  
**Instituição:** Universidade Presbiteriana Mackenzie  
**Curso:** Engenharia da Computação  
**Disciplina:** Banco de Dados Relacional  
**SGBD:** MySQL 8.0+ (Engine InnoDB)  

---

## Situação-Problema

A loja TechShop Eletrônicos opera no ramo de varejo e enfrenta dificuldades para gerenciar suas vendas, controle de estoque, histórico de clientes e acompanhamento de desempenho dos seus vendedores. Atualmente, os dados são registrados em planilhas dispersas, gerando duplicidade de informações, falta de integridade nos pedidos e lentidão para gerar relatórios financeiros e de estoque.

---

## Usuários do Sistema

- **Atendentes/Vendedores:** Registram novas vendas e consultam a disponibilidade de produtos no estoque.
- **Gerente de Loja:** Acompanha métricas de desempenho de vendas, rankings de vendedores e produtos mais vendidos.
- **Administrador de Estoque:** Cadastra novos produtos, atualiza preços e monitora reposições.

---

## Requisitos Funcionais (RF)

- **RF01:** Cadastrar e gerenciar clientes, funcionários, categorias e produtos.
- **RF02:** Registrar pedidos de venda associando cliente, funcionário e itens vendidos.
- **RF03:** Dar baixa automática no estoque de produtos ao confirmar uma venda.
- **RF04:** Garantir a consistência de valores monetários e quantidades sem permitir valores negativos.
- **RF05:** Consultar vendas por período, faturamento total, ticket médio e rankings de vendedores e produtos.

---

## Requisitos Não-Funcionais (RNF)

- **RNF01 (Integridade):** Garantir a integridade referencial por meio de Chaves Estrangeiras (FK) utilizando a engine InnoDB do MySQL.
- **RNF02 (Desempenho):** Adicionar índices B-Tree em colunas frequentemente consultadas (ex: data do pedido e e-mail do cliente).
- **RNF03 (Consistência):** Utilizar transações ACID para garantir que a inserção de um pedido e a baixa de estoque ocorram atomicamente.

---

## Normalização até a 3ª Forma Normal (3FN)

- **1FN:** Todos os atributos são atômicos (ex: dados de clientes estruturados de forma indivisível, cidade e UF separados; pedidos separados de seus itens).
- **2FN:** As tabelas com chave primária composta (`ITEM_PEDIDO`) possuem todos os atributos não-chave (`quantidade`, `preco_praticado`) dependentes da totalidade da chave (`id_pedido` + `id_produto`).
- **3FN:** Não há dependências transitivas entre atributos não-chave (dados de categoria residem na entidade própria `CATEGORIA`, e os dados de funcionários e clientes estão isolados sem redundância no pedido).

---

## Modelagem das Tabelas

### 1. CATEGORIA

| Campo | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_categoria` | `INT` | `PK, AUTO_INCREMENT` | Identificador único da categoria |
| `nome_categoria` | `VARCHAR(50)` | `NOT NULL, UNIQUE` | Nome da categoria de produto |

### 2. PRODUTO

| Campo | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_produto` | `INT` | `PK, AUTO_INCREMENT` | Identificador único do produto |
| `nome_produto` | `VARCHAR(100)` | `NOT NULL` | Nome comercial do produto |
| `preco_unitario` | `DECIMAL(10,2)` | `NOT NULL, CHECK (>0)` | Preço de venda unitário |
| `qtd_estoque` | `INT` | `NOT NULL, CHECK (>=0)` | Quantidade disponível em estoque |
| `id_categoria` | `INT` | `FK CATEGORIA` | Categoria à qual o produto pertence |

### 3. CLIENTE

| Campo | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_cliente` | `INT` | `PK, AUTO_INCREMENT` | Identificador único do cliente |
| `nome_cliente` | `VARCHAR(100)` | `NOT NULL` | Nome completo do cliente |
| `cpf` | `CHAR(11)` | `NOT NULL, UNIQUE` | CPF único do cliente |
| `email` | `VARCHAR(100)` | `NOT NULL, UNIQUE` | Endereço de e-mail |
| `cidade` | `VARCHAR(50)` | `NOT NULL` | Cidade do endereço |
| `uf` | `CHAR(2)` | `NOT NULL` | Estado (UF) |

### 4. FUNCIONARIO

| Campo | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_funcionario` | `INT` | `PK, AUTO_INCREMENT` | Identificador do funcionário/vendedor |
| `nome_funcionario`| `VARCHAR(100)` | `NOT NULL` | Nome do funcionário |
| `cargo` | `VARCHAR(50)` | `NOT NULL` | Cargo ocupado na empresa |
| `salario` | `DECIMAL(10,2)` | `NOT NULL, CHECK (>0)` | Salário base |

### 5. PEDIDO

| Campo | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_pedido` | `INT` | `PK, AUTO_INCREMENT` | Código único do pedido de venda |
| `data_pedido` | `DATETIME` | `NOT NULL, DEFAULT NOW()`| Data e hora em que a compra ocorreu |
| `id_cliente` | `INT` | `FK CLIENTE` | Cliente que realizou o pedido |
| `id_funcionario` | `INT` | `FK FUNCIONARIO` | Vendedor responsável pelo atendimento |

### 6. ITEM_PEDIDO

| Campo | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_pedido` | `INT` | `PK (Composta), FK PEDIDO` | Código do pedido associado |
| `id_produto` | `INT` | `PK (Composta), FK PRODUTO` | Código do produto associado |
| `quantidade` | `INT` | `NOT NULL, CHECK (>0)` | Quantidade comprada do produto |
| `preco_praticado` | `DECIMAL(10,2)` | `NOT NULL` | Preço unitário aplicado na venda |

---

## Scripts SQL

### 1. Criação do Banco e Tabelas (DDL)

```sql
DROP DATABASE IF EXISTS techshop;
CREATE DATABASE techshop;
USE techshop;

CREATE TABLE CATEGORIA (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE PRODUTO (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    qtd_estoque INT NOT NULL DEFAULT 0,
    id_categoria INT NOT NULL,
    CONSTRAINT chk_produto_preco CHECK (preco_unitario > 0),
    CONSTRAINT chk_produto_estoque CHECK (qtd_estoque >= 0),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome_cliente VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    cidade VARCHAR(50) NOT NULL,
    uf CHAR(2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE FUNCIONARIO (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome_funcionario VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_funcionario_salario CHECK (salario > 0)
) ENGINE=InnoDB;

CREATE TABLE PEDIDO (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INT NOT NULL,
    id_funcionario INT NOT NULL,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_funcionario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ITEM_PEDIDO (
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_praticado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT chk_item_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_preco CHECK (preco_praticado > 0),
    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
```

---

## Consultas SQL e Resultados

### Consulta 1: Catálogo de Produtos e Categorias

```sql
SELECT 
    p.nome_produto, 
    c.nome_categoria, 
    p.preco_unitario
FROM PRODUTO p
INNER JOIN CATEGORIA c ON p.id_categoria = c.id_categoria
ORDER BY c.nome_categoria, p.nome_produto;
```

#### Resultado Comando SQL:

| nome_produto | nome_categoria | preco_unitario |
| :--- | :--- | :--- |
| Caixa de Som Bluetooth | Áudio | 290.00 |
| Fone TWS Cancelamento Ruído | Áudio | 550.00 |
| Soundbar 2.1 Canais | Áudio | 890.00 |
| Monitor 27" 144Hz Gamer | Monitores | 1400.00 |
| Monitor Ultrawide 34" | Monitores | 2200.00 |
| MacBook Air M2 | Notebooks | 7999.00 |
| Dell XPS 13 | Notebooks | 8500.00 |
| Lenovo IdeaPad3 | Notebooks | 2800.00 |
| Teclado Mecânico RGB | Periféricos | 350.00 |
| Mouse Sem Fio Ergonomico | Periféricos | 180.00 |
| Headset Gamer 7.1 | Periféricos | 420.00 |
| Webcam Full HD 1080p | Periféricos | 250.00 |
| iPhone 15 128GB | Smartphones | 5499.00 |
| Samsung Galaxy S24 | Smartphones | 4999.00 |
| Xiaomi 13 Pro | Smartphones | 3800.00 |

---

### Consulta 2: Faturamento Total por Cliente

```sql
SELECT 
    c.nome_cliente, 
    SUM(i.quantidade * i.preco_praticado) AS faturamento_total
FROM CLIENTE c
INNER JOIN PEDIDO p ON c.id_cliente = p.id_cliente
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY faturamento_total DESC;
```

#### Resultado Comando SQL:

| nome_cliente | faturamento_total |
| :--- | :--- |
| Bruno Henrique Dias | 13678.00 |
| Helena Vasconcelos | 11599.00 |
| Eduardo Martins | 10080.00 |
| Camila Rodrigues | 9769.00 |
| Juliana Paes | 9729.00 |
| Ana Clara Ribeiro | 9349.00 |
| Gabriel Fernandes | 9250.00 |
| Patricia Gomes | 9099.00 |
| Daniel Oliveira | 6650.00 |
| Lucas Gabriel Lima | 5499.00 |
| Nicolas Teodoro | 4999.00 |
| Fernanda Barbosa | 4350.00 |
| Renato Aragão | 2800.00 |
| Igor Carvalho | 2050.00 |
| Manuela Santos | 710.00 |

---

### Consulta 3: Produtos com Preço Acima da Média

```sql
SELECT 
    nome_produto, 
    preco_unitario
FROM PRODUTO
WHERE preco_unitario > (SELECT AVG(preco_unitario) FROM PRODUTO)
ORDER BY preco_unitario DESC;
```

#### Resultado Comando SQL:

| nome_produto | preco_unitario |
| :--- | :--- |
| Dell XPS 13 | 8500.00 |
| MacBook Air M2 | 7999.00 |
| iPhone 15 128GB | 5499.00 |
| Samsung Galaxy S24 | 4999.00 |
| Xiaomi 13 Pro | 3800.00 |
| Lenovo IdeaPad3 | 2800.00 |

---

### Consulta 4: Clientes Cadastrados

```sql
SELECT 
    nome_cliente, 
    email, 
    cidade
FROM CLIENTE
ORDER BY nome_cliente;
```

#### Resultado Comando SQL:

| nome_cliente | email | cidade |
| :--- | :--- | :--- |
| Ana Clara Ribeiro | ana.ribeiro@email.com | São Paulo |
| Bruno Henrique Dias | bruno.dias@email.com | São Paulo |
| Camila Rodrigues | camila.rodrigues@email.com | Campinas |
| Daniel Oliveira | daniel.oliveira@email.com | Santos |
| Eduardo Martins | eduardo.martins@email.com | Rio de Janeiro |
| Fernanda Barbosa | fernanda.barbosa@email.com | Niterói |
| Gabriel Fernandes | gabriel.fernandes@email.com | Belo Horizonte |
| Helena Vasconcelos | helena.v@email.com | Curitiba |
| Igor Carvalho | igor.carvalho@email.com | Porto Alegre |
| Juliana Paes | juliana.paes@email.com | São Paulo |
| Patricia Gomes | patricia.gomes@email.com | Guarulhos |
| Renato Aragão | renato.aragao@email.com | Osasco |

---

### Consulta 5: Desempenho de Vendedores

```sql
SELECT 
    f.nome_funcionario, 
    SUM(i.quantidade * i.preco_praticado) AS total_vendido
FROM FUNCIONARIO f
INNER JOIN PEDIDO p ON f.id_funcionario = p.id_funcionario
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido
GROUP BY f.id_funcionario, f.nome_funcionario
ORDER BY total_vendido DESC;
```

#### Resultado Comando SQL:

| nome_funcionario | total_vendido |
| :--- | :--- |
| Mariana Rocha Costa | 32878.00 |
| Fernanda Lima Souza | 26188.00 |
| Beatriz Mendes Castro | 25347.00 |

---

### Consulta 6: Total de Itens Vendidos por Categoria

```sql
SELECT 
    c.nome_categoria, 
    SUM(i.quantidade) AS total_itens_vendidos
FROM CATEGORIA c
INNER JOIN PRODUTO p ON c.id_categoria = p.id_categoria
INNER JOIN ITEM_PEDIDO i ON p.id_produto = i.id_produto
GROUP BY c.id_categoria, c.nome_categoria
ORDER BY total_itens_vendidos DESC;
```

#### Resultado Comando SQL:

| nome_categoria | total_itens_vendidos |
| :--- | :--- |
| Periféricos | 17 |
| Áudio | 10 |
| Notebooks | 8 |
| Smartphones | 8 |
| Monitores | 6 |

---

### Consulta 7: Ticket Médio da Loja

```sql
SELECT 
    ROUND(SUM(i.quantidade * i.preco_praticado) / COUNT(DISTINCT p.id_pedido), 2) AS ticket_medio_loja
FROM PEDIDO p
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido;
```

#### Resultado Comando SQL:

| ticket_medio_loja |
| :--- |
| 4215.81 |

---

### Consulta 8: Busca por E-mail do Cliente

```sql
SELECT 
    nome_cliente, 
    email
FROM CLIENTE
WHERE email = 'ana.ribeiro@email.com';
```

#### Resultado Comando SQL:

| nome_cliente | email |
| :--- | :--- |
| Ana Clara Ribeiro | ana.ribeiro@email.com |

---

### Consulta 9: Resumo de Pedidos e Datas

```sql
SELECT 
    p.id_pedido, 
    p.data_pedido, 
    SUM(i.quantidade * i.preco_praticado) AS valor_total_pedido
FROM PEDIDO p
INNER JOIN ITEM_PEDIDO i ON p.id_pedido = i.id_pedido
GROUP BY p.id_pedido, p.data_pedido
ORDER BY p.id_pedido;
```

#### Amostra do Resultado Comando SQL:

| id_pedido | data_pedido | valor_total_pedido |
| :--- | :--- | :--- |
| 1 | 2026-01-10 10:15:00 | 5849.00 |
| 16 | 2026-03-05 13:45:00 | 2800.00 |
| 26 | 2026-10-28 15:32:26 | 700.00 |

---

### Consulta 10: Alerta de Reposição de Estoque

```sql
SELECT 
    p.id_produto, 
    p.nome_produto, 
    c.nome_categoria, 
    p.qtd_estoque
FROM PRODUTO p
INNER JOIN CATEGORIA c ON p.id_categoria = c.id_categoria
WHERE p.qtd_estoque <= 10
ORDER BY p.qtd_estoque ASC;
```

---

## Índices B-Tree

```sql
CREATE INDEX idx_pedido_data ON PEDIDO (data_pedido);
CREATE INDEX idx_cliente_email ON CLIENTE (email);

EXPLAIN SELECT * FROM PEDIDO WHERE data_pedido BETWEEN '2026-01-01' AND '2026-03-31';
EXPLAIN SELECT * FROM CLIENTE WHERE email = 'ana.ribeiro@email.com';
```

---

## Operação com Transação ACID

```sql
START TRANSACTION;

INSERT INTO PEDIDO (id_pedido, data_pedido, id_cliente, id_funcionario) 
VALUES (27, NOW(), 1, 1);

INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_praticado) 
VALUES (27, 9, 2, 350.00);

UPDATE PRODUTO 
SET qtd_estoque = qtd_estoque - 2 
WHERE id_produto = 9 AND qtd_estoque >= 2;

COMMIT;
```
