# TechShop Eletrônicos — Normalização de Dados

## Demonstração Formal: 1FN → 2FN → 3FN

---

## 1. Introdução

A **normalização** é o processo formal de organização das tabelas de um banco de dados relacional com o objetivo de:

- **Eliminar redundâncias** de dados (o mesmo fato armazenado em múltiplos lugares);
- **Prevenir anomalias** de inserção, atualização e exclusão;
- **Garantir dependências funcionais** corretas entre atributos.

O processo segue uma sequência progressiva de **Formas Normais** (FN), onde cada forma impõe restrições adicionais sobre a estrutura das tabelas. Neste documento, demonstramos formalmente que o esquema da TechShop Eletrônicos satisfaz a **Terceira Forma Normal (3FN)**, passando pelas etapas intermediárias (1FN e 2FN).

---

## 2. Primeira Forma Normal (1FN)

### 2.1 Regra

> Uma tabela está na **Primeira Forma Normal (1FN)** se, e somente se:
> 1. Todos os atributos contêm apenas **valores atômicos** (indivisíveis);
> 2. Não existem **grupos repetitivos** (atributos multivalorados ou compostos);
> 3. Cada linha é **única**, identificada por uma chave primária.

### 2.2 Cenário ANTES — Tabela Desnormalizada

Considere a seguinte tabela hipotética `PEDIDO_DESNORMALIZADO`, onde todas as informações de um pedido são armazenadas em uma única linha:

| id_pedido | data | cliente_nome | cliente_cpf | cliente_endereco | funcionario_nome | produtos | quantidades | precos |
|---|---|---|---|---|---|---|---|---|
| 1 | 2024-01-15 | Ana Silva | 111.222.333-44 | Rua das Flores, 100, São Paulo, SP, 01234-567 | João Santos | iPhone 15 Pro, Capa Silicone, Película Vidro | 1, 2, 2 | 7999.99, 89.90, 29.90 | 
| 2 | 2024-01-16 | Carlos Souza | 555.666.777-88 | Av. Paulista, 1500, Apto 42, São Paulo, SP, 01310-100 | Maria Oliveira | Galaxy S24, Carregador USB-C | 1, 1 | 5499.00, 149.90 |

### 2.3 Problemas Identificados

| Problema | Coluna(s) | Descrição |
|---|---|---|
| **Atributo composto** | `cliente_endereco` | O endereço agrega múltiplas informações (rua, número, cidade, estado, CEP) em um único campo, impedindo consultas e filtros por componentes individuais |
| **Atributo multivalorado** | `produtos` | Múltiplos nomes de produtos concatenados em uma única célula, separados por vírgula |
| **Atributo multivalorado** | `quantidades` | Múltiplas quantidades na mesma célula, sem associação formal com os produtos |
| **Atributo multivalorado** | `precos` | Múltiplos preços na mesma célula |
| **Anomalia de inserção** | — | Não é possível cadastrar um cliente sem que ele tenha um pedido |
| **Anomalia de atualização** | `cliente_nome`, `cliente_endereco` | Se o cliente mudar de endereço, é necessário atualizar todas as linhas de pedido |

### 2.4 Cenário DEPOIS — Conformidade com 1FN

Para atingir a 1FN, aplicamos duas transformações:

**Transformação 1 — Decompor atributos compostos**: o campo `cliente_endereco` é decomposto em campos atômicos.

**Transformação 2 — Eliminar atributos multivalorados**: cada produto em um pedido gera uma linha separada.

**Tabela resultante — `PEDIDO_1FN`:**

| id_pedido | data | cliente_nome | cliente_cpf | rua | numero | cidade | estado | cep | funcionario_nome | produto_nome | quantidade | preco |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2024-01-15 | Ana Silva | 111.222.333-44 | Rua das Flores | 100 | São Paulo | SP | 01234-567 | João Santos | iPhone 15 Pro | 1 | 7999.99 |
| 1 | 2024-01-15 | Ana Silva | 111.222.333-44 | Rua das Flores | 100 | São Paulo | SP | 01234-567 | João Santos | Capa Silicone | 2 | 89.90 |
| 1 | 2024-01-15 | Ana Silva | 111.222.333-44 | Rua das Flores | 100 | São Paulo | SP | 01234-567 | João Santos | Película Vidro | 2 | 29.90 |
| 2 | 2024-01-16 | Carlos Souza | 555.666.777-88 | Av. Paulista | 1500 | São Paulo | SP | 01310-100 | Maria Oliveira | Galaxy S24 | 1 | 5499.00 |
| 2 | 2024-01-16 | Carlos Souza | 555.666.777-88 | Av. Paulista | 1500 | São Paulo | SP | 01310-100 | Maria Oliveira | Carregador USB-C | 1 | 149.90 |

> **Resultado**: todos os valores são atômicos e não há grupos repetitivos. A tabela está em **1FN**. Porém, ainda apresenta séria redundância de dados (nome e endereço do cliente repetidos em cada linha).

---

## 3. Segunda Forma Normal (2FN)

### 3.1 Regra

> Uma tabela está na **Segunda Forma Normal (2FN)** se, e somente se:
> 1. Está em **1FN**;
> 2. Todos os atributos não-chave dependem **totalmente** da chave primária completa (não existe **dependência parcial**).

A dependência parcial ocorre quando um atributo não-chave depende apenas de **parte** de uma chave primária composta.

### 3.2 Cenário ANTES — Tabela em 1FN com Dependências Parciais

Considere a tabela `PEDIDO_ITENS` resultante de uma tentativa de normalização que unifica pedidos e itens com uma chave composta:

**Chave primária composta**: `(id_pedido, id_produto)`

| id_pedido | id_produto | data_pedido | status | cliente_nome | cliente_cpf | funcionario_nome | produto_nome | produto_preco_catalogo | categoria_nome | quantidade | preco_unitario | subtotal |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 101 | 2024-01-15 | Confirmado | Ana Silva | 111.222.333-44 | João Santos | iPhone 15 Pro | 7999.99 | Smartphones | 1 | 7999.99 | 7999.99 |
| 1 | 205 | 2024-01-15 | Confirmado | Ana Silva | 111.222.333-44 | João Santos | Capa Silicone | 89.90 | Acessórios | 2 | 89.90 | 179.80 |
| 2 | 102 | 2024-01-16 | Pendente | Carlos Souza | 555.666.777-88 | Maria Oliveira | Galaxy S24 | 5499.00 | Smartphones | 1 | 5499.00 | 5499.00 |

### 3.3 Análise de Dependências Funcionais

| Dependência | Atributo | Depende de | Tipo |
|---|---|---|---|
| DF1 | `data_pedido`, `status`, `cliente_nome`, `cliente_cpf`, `funcionario_nome` | `id_pedido` (apenas parte da PK) | **Parcial** ❌ |
| DF2 | `produto_nome`, `produto_preco_catalogo`, `categoria_nome` | `id_produto` (apenas parte da PK) | **Parcial** ❌ |
| DF3 | `quantidade`, `preco_unitario`, `subtotal` | `(id_pedido, id_produto)` (PK completa) | **Total** ✔️ |

**Problema**: `cliente_nome` depende apenas de `id_pedido`, não de `id_produto`. Se o cliente alterar seu nome, a atualização deve ser feita em todas as linhas onde ele aparece (anomalia de atualização). Da mesma forma, `produto_nome` depende apenas de `id_produto`, não de `id_pedido`.

### 3.4 Cenário DEPOIS — Conformidade com 2FN

Decompomos a tabela em três tabelas, eliminando as dependências parciais:

**Tabela PEDIDO** (atributos que dependem apenas de `id_pedido`):

| id_pedido | data_pedido | status | id_cliente | id_funcionario |
|---|---|---|---|---|
| 1 | 2024-01-15 | Confirmado | 1 | 1 |
| 2 | 2024-01-16 | Pendente | 2 | 2 |

**Tabela PRODUTO** (atributos que dependem apenas de `id_produto`):

| id_produto | nome_produto | preco_unitario | id_categoria |
|---|---|---|---|
| 101 | iPhone 15 Pro | 7999.99 | 1 |
| 102 | Galaxy S24 | 5499.00 | 1 |
| 205 | Capa Silicone | 89.90 | 4 |

**Tabela ITEM_PEDIDO** (atributos que dependem da chave completa):

| id_item | id_pedido | id_produto | quantidade | preco_unitario | subtotal |
|---|---|---|---|---|---|
| 1 | 1 | 101 | 1 | 7999.99 | 7999.99 |
| 2 | 1 | 205 | 2 | 89.90 | 179.80 |
| 3 | 2 | 102 | 1 | 5499.00 | 5499.00 |

> **Resultado**: cada atributo não-chave depende totalmente da chave primária de sua respectiva tabela. As tabelas estão em **2FN**. Porém, ainda podem existir dependências transitivas.

---

## 4. Terceira Forma Normal (3FN)

### 4.1 Regra

> Uma tabela está na **Terceira Forma Normal (3FN)** se, e somente se:
> 1. Está em **2FN**;
> 2. Nenhum atributo não-chave depende **transitivamente** de outro atributo não-chave (toda dependência funcional é diretamente da chave primária).

A dependência transitiva ocorre quando: `PK → A → B`, ou seja, `B` depende de `A`, que por sua vez depende da PK. Nesse caso, `B` não depende diretamente da PK.

### 4.2 Cenário ANTES — Tabela em 2FN com Dependência Transitiva

Considere a tabela PRODUTO com informações do fornecedor embutidas:

| id_produto | nome_produto | preco_unitario | qtd_estoque | id_fornecedor | fornecedor_nome | fornecedor_cnpj | fornecedor_telefone |
|---|---|---|---|---|---|---|---|
| 101 | iPhone 15 Pro | 7999.99 | 25 | 1 | Apple Brasil Ltda. | 00.623.904/0001-73 | (11) 3500-1234 |
| 102 | Galaxy S24 | 5499.00 | 40 | 2 | Samsung Brasil Ltda. | 00.280.273/0001-37 | (11) 3600-5678 |
| 103 | Galaxy Tab S9 | 3299.00 | 15 | 2 | Samsung Brasil Ltda. | 00.280.273/0001-37 | (11) 3600-5678 |
| 104 | MacBook Air M3 | 12999.00 | 10 | 1 | Apple Brasil Ltda. | 00.623.904/0001-73 | (11) 3500-1234 |

### 4.3 Análise de Dependências Funcionais

```
id_produto → nome_produto                 (direta da PK) ✔️
id_produto → preco_unitario               (direta da PK) ✔️
id_produto → qtd_estoque                  (direta da PK) ✔️
id_produto → id_fornecedor                (direta da PK) ✔️
id_fornecedor → fornecedor_nome           (transitiva!) ❌
id_fornecedor → fornecedor_cnpj           (transitiva!) ❌
id_fornecedor → fornecedor_telefone       (transitiva!) ❌
```

**Cadeia transitiva identificada:**

```
id_produto → id_fornecedor → fornecedor_nome
id_produto → id_fornecedor → fornecedor_cnpj
id_produto → id_fornecedor → fornecedor_telefone
```

**Problemas decorrentes:**

| Anomalia | Descrição |
|---|---|
| **Redundância** | O nome e CNPJ da Samsung são armazenados duas vezes (produtos 102 e 103), desperdiçando espaço e criando risco de inconsistência |
| **Anomalia de atualização** | Se a Samsung alterar seu telefone, é necessário atualizar todas as linhas de produtos da Samsung. Se uma linha for esquecida, haverá inconsistência |
| **Anomalia de exclusão** | Se todos os produtos da Apple forem excluídos, perdem-se também os dados cadastrais da Apple |
| **Anomalia de inserção** | Não é possível cadastrar um novo fornecedor enquanto ele não tiver pelo menos um produto associado |

### 4.4 Cenário DEPOIS — Conformidade com 3FN

Decompomos a tabela, extraindo os atributos transitivamente dependentes para uma tabela própria:

**Tabela PRODUTO** (sem atributos do fornecedor):

| id_produto | nome_produto | preco_unitario | qtd_estoque | id_fornecedor | id_categoria |
|---|---|---|---|---|---|
| 101 | iPhone 15 Pro | 7999.99 | 25 | 1 | 1 |
| 102 | Galaxy S24 | 5499.00 | 40 | 2 | 1 |
| 103 | Galaxy Tab S9 | 3299.00 | 15 | 2 | 2 |
| 104 | MacBook Air M3 | 12999.00 | 10 | 1 | 3 |

**Tabela FORNECEDOR** (entidade independente):

| id_fornecedor | razao_social | cnpj | telefone | email |
|---|---|---|---|---|
| 1 | Apple Brasil Ltda. | 00.623.904/0001-73 | (11) 3500-1234 | contato@apple.com.br |
| 2 | Samsung Brasil Ltda. | 00.280.273/0001-37 | (11) 3600-5678 | contato@samsung.com.br |

> **Resultado**: todos os atributos não-chave dependem exclusivamente da chave primária de sua tabela. A dependência transitiva foi eliminada. As tabelas estão em **3FN**.

---

## 5. Verificação Final — Conformidade 3FN de Todas as Tabelas

A tabela a seguir demonstra que cada uma das 8 tabelas do esquema final da TechShop Eletrônicos satisfaz a Terceira Forma Normal:

### 5.1 CATEGORIA

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_categoria` | `nome_categoria` | `id_categoria → nome_categoria` | Direta da PK ✔️ |
| `id_categoria` | `descricao` | `id_categoria → descricao` | Direta da PK ✔️ |

- **1FN**: todos os valores são atômicos, sem grupos repetitivos ✔️
- **2FN**: chave primária simples (não composta), portanto não há dependências parciais ✔️
- **3FN**: nenhuma dependência transitiva entre atributos não-chave ✔️

### 5.2 FORNECEDOR

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_fornecedor` | `razao_social` | `id_fornecedor → razao_social` | Direta da PK ✔️ |
| `id_fornecedor` | `cnpj` | `id_fornecedor → cnpj` | Direta da PK ✔️ |
| `id_fornecedor` | `telefone` | `id_fornecedor → telefone` | Direta da PK ✔️ |
| `id_fornecedor` | `email` | `id_fornecedor → email` | Direta da PK ✔️ |

- **1FN** ✔️ | **2FN** ✔️ (PK simples) | **3FN** ✔️ (sem dependências transitivas)

### 5.3 PRODUTO

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_produto` | `nome_produto` | `id_produto → nome_produto` | Direta da PK ✔️ |
| `id_produto` | `descricao` | `id_produto → descricao` | Direta da PK ✔️ |
| `id_produto` | `preco_unitario` | `id_produto → preco_unitario` | Direta da PK ✔️ |
| `id_produto` | `qtd_estoque` | `id_produto → qtd_estoque` | Direta da PK ✔️ |
| `id_produto` | `estoque_minimo` | `id_produto → estoque_minimo` | Direta da PK ✔️ |
| `id_produto` | `id_categoria` | `id_produto → id_categoria` | Direta da PK ✔️ (FK, não transitiva) |
| `id_produto` | `id_fornecedor` | `id_produto → id_fornecedor` | Direta da PK ✔️ (FK, não transitiva) |

- **1FN** ✔️ | **2FN** ✔️ (PK simples) | **3FN** ✔️

> **Nota sobre FKs e 3FN**: As chaves estrangeiras `id_categoria` e `id_fornecedor` são atributos da tabela PRODUTO e dependem diretamente de `id_produto`. Os atributos de CATEGORIA e FORNECEDOR (como `nome_categoria`, `razao_social`) **não estão armazenados** em PRODUTO — estão em suas respectivas tabelas. Portanto, não há dependência transitiva.

### 5.4 CLIENTE

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_cliente` | `nome_completo` | `id_cliente → nome_completo` | Direta da PK ✔️ |
| `id_cliente` | `cpf` | `id_cliente → cpf` | Direta da PK ✔️ |
| `id_cliente` | `email` | `id_cliente → email` | Direta da PK ✔️ |
| `id_cliente` | `telefone` | `id_cliente → telefone` | Direta da PK ✔️ |
| `id_cliente` | `data_cadastro` | `id_cliente → data_cadastro` | Direta da PK ✔️ |

- **1FN** ✔️ | **2FN** ✔️ (PK simples) | **3FN** ✔️

### 5.5 FUNCIONARIO

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_funcionario` | `nome_completo` | `id_funcionario → nome_completo` | Direta da PK ✔️ |
| `id_funcionario` | `cpf` | `id_funcionario → cpf` | Direta da PK ✔️ |
| `id_funcionario` | `cargo` | `id_funcionario → cargo` | Direta da PK ✔️ |
| `id_funcionario` | `data_admissao` | `id_funcionario → data_admissao` | Direta da PK ✔️ |

- **1FN** ✔️ | **2FN** ✔️ (PK simples) | **3FN** ✔️

### 5.6 PEDIDO

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_pedido` | `data_pedido` | `id_pedido → data_pedido` | Direta da PK ✔️ |
| `id_pedido` | `status` | `id_pedido → status` | Direta da PK ✔️ |
| `id_pedido` | `valor_total` | `id_pedido → valor_total` | Direta da PK ✔️ |
| `id_pedido` | `id_cliente` | `id_pedido → id_cliente` | Direta da PK ✔️ (FK) |
| `id_pedido` | `id_funcionario` | `id_pedido → id_funcionario` | Direta da PK ✔️ (FK) |

- **1FN** ✔️ | **2FN** ✔️ (PK simples) | **3FN** ✔️

### 5.7 ITEM_PEDIDO

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_item` | `quantidade` | `id_item → quantidade` | Direta da PK ✔️ |
| `id_item` | `preco_unitario` | `id_item → preco_unitario` | Direta da PK ✔️ |
| `id_item` | `subtotal` | `id_item → subtotal` | Direta da PK ✔️ |
| `id_item` | `id_pedido` | `id_item → id_pedido` | Direta da PK ✔️ (FK) |
| `id_item` | `id_produto` | `id_item → id_produto` | Direta da PK ✔️ (FK) |

- **1FN** ✔️ | **2FN** ✔️ (PK simples — `id_item` surrogate) | **3FN** ✔️

> **Nota**: Embora ITEM_PEDIDO tenha uma dependência funcional natural `(id_pedido, id_produto) → quantidade, preco_unitario, subtotal`, a utilização de `id_item` como chave primária surrogate torna a PK simples, eliminando a questão de dependências parciais por definição.

### 5.8 MOVIMENTACAO_ESTOQUE

| Chave Primária | Atributo | Dependência | Tipo |
|---|---|---|---|
| `id_movimentacao` | `tipo` | `id_movimentacao → tipo` | Direta da PK ✔️ |
| `id_movimentacao` | `quantidade` | `id_movimentacao → quantidade` | Direta da PK ✔️ |
| `id_movimentacao` | `data_movimentacao` | `id_movimentacao → data_movimentacao` | Direta da PK ✔️ |
| `id_movimentacao` | `observacao` | `id_movimentacao → observacao` | Direta da PK ✔️ |
| `id_movimentacao` | `id_produto` | `id_movimentacao → id_produto` | Direta da PK ✔️ (FK) |

- **1FN** ✔️ | **2FN** ✔️ (PK simples) | **3FN** ✔️

---

## 6. Resumo da Normalização

```mermaid
flowchart LR
    A["Tabela Desnormalizada<br/>PEDIDO_DESNORMALIZADO<br/>Atributos compostos<br/>Grupos repetitivos"] -->|"1FN<br/>Atomicidade"| B["Tabela em 1FN<br/>PEDIDO_1FN<br/>Valores atômicos<br/>Sem repetições"]
    B -->|"2FN<br/>Sem dependência parcial"| C["Tabelas em 2FN<br/>PEDIDO + PRODUTO<br/>+ ITEM_PEDIDO"]
    C -->|"3FN<br/>Sem dependência transitiva"| D["Tabelas em 3FN<br/>8 tabelas finais<br/>Esquema completo"]
```

| Forma Normal | Violação Eliminada | Transformação Aplicada |
|---|---|---|
| **1FN** | Atributos compostos e multivalorados | Decomposição em valores atômicos; separação de itens em linhas individuais |
| **2FN** | Dependências parciais da chave composta | Decomposição em PEDIDO, PRODUTO e ITEM_PEDIDO, cada uma com PK própria |
| **3FN** | Dependências transitivas via `id_fornecedor` | Extração de FORNECEDOR como tabela independente |

---

## 7. Conclusão

O esquema final do banco de dados da TechShop Eletrônicos, composto por **8 tabelas** (CATEGORIA, FORNECEDOR, PRODUTO, CLIENTE, FUNCIONARIO, PEDIDO, ITEM_PEDIDO, MOVIMENTACAO_ESTOQUE), está integralmente em conformidade com a **Terceira Forma Normal (3FN)**.

Essa conformidade garante:

1. **Ausência de redundância**: cada fato é armazenado em um único lugar;
2. **Integridade de dados**: atualizações afetam apenas uma tabela, sem risco de inconsistência;
3. **Flexibilidade**: novas entidades podem ser adicionadas sem alterar tabelas existentes;
4. **Eficiência de armazenamento**: eliminação de dados duplicados reduz o consumo de espaço;
5. **Consultas confiáveis**: JOINs reconstroem as visões completas sob demanda, garantindo dados sempre atualizados.

---

> **Documento elaborado como parte do projeto acadêmico da disciplina de Banco de Dados — Engenharia da Computação — Universidade Presbiteriana Mackenzie.**
