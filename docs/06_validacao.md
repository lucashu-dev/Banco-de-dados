# 🧪 Relatório de Validação e Testes de Integridade — TechShop Eletrônicos

**Instituição:** Universidade Presbiteriana Mackenzie  
**Curso:** Engenharia da Computação  
**Disciplina:** Banco de Dados  
**Arquivo Executável:** `sql/07_validation.sql`

Este relatório consolida a bateria formal de testes automatizados executados sobre o esquema relacional do banco de dados da **TechShop Eletrônicos**, validando constraints, integridade referencial e garantias ACID.

---

## 1. Plano e Sequência de Execução dos Scripts

Para reproduzir a integridade completa do ambiente em uma base PostgreSQL nova, execute os scripts na seguinte ordem rigorosa:

1. `sql/01_schema.sql`: Criação das 8 tabelas com chaves primárias e relacionamentos (`ON DELETE RESTRICT`).
2. `sql/02_constraints.sql`: Aplicação das 11 restrições semânticas de domínio (`CHECK`).
3. `sql/03_seed.sql`: Carga inicial de massa de testes (166 registros com 100% de integridade referencial).
4. `sql/04_indexes.sql`: Criação de índices estratégicos B-Tree e planos `EXPLAIN`.
5. `sql/05_queries.sql`: Execução das 10 consultas analíticas e operacionais.
6. `sql/06_transactions.sql`: Demonstração da transação ACID atômica de confirmação de venda e rollback.
7. `sql/07_validation.sql`: Suíte de validação formal automatizada.

---

## 2. Bateria de Testes Automatizados

O script `07_validation.sql` registra seus resultados dinamicamente em uma tabela temporária `resultado_validacao`. Abaixo está a matriz de testes executados e seus comportamentos esperados:

### 2.1. Contagem de Registros e Densidade de Dados

| Teste | Tabela Auditada | Mínimo Esperado | Observação | Resultado |
|:---|:---|:---:|:---|:---:|
| **T01** | `CATEGORIA` | 5 | Categorias de informática e eletrônicos | **PASSOU** |
| **T02** | `FORNECEDOR` | 6 | Fabricantes com CNPJs válidos | **PASSOU** |
| **T03** | `PRODUTO` | 20 | Ampla variedade de preços e estoque | **PASSOU** |
| **T04** | `CLIENTE` | 15 | Perfis diversificados com CPFs únicos | **PASSOU** |
| **T05** | `FUNCIONARIO` | 5 | Equipe de vendas, estoque e diretoria | **PASSOU** |
| **T06** | `PEDIDO` | 25 | Histórico temporal de 2024 a 2025 | **PASSOU** |
| **T07** | `ITEM_PEDIDO` | 60 | Linhas de itens vinculadas a produtos reais | **PASSOU** |
| **T08** | `MOVIMENTACAO` | 30 | Entradas e saídas de estoque auditáveis | **PASSOU** |

---

### 2.2. Testes de Integridade Referencial (Detecção de Órfãos)

| Teste ID | Validação | Condição de Aprovação | Resultado |
|:---|:---|:---|:---:|
| **T09** | Órfãos em `PRODUTO` | Nenhum produto sem categoria ou fornecedor válido | **PASSOU** |
| **T10** | Órfãos em `PEDIDO` | Nenhum pedido com cliente ou funcionário inexistente | **PASSOU** |
| **T11** | Órfãos em `ITEM_PEDIDO` | Nenhum item apontando para pedido ou produto nulo/inválido | **PASSOU** |
| **T12** | Órfãos em `MOVIMENTACAO`| Nenhuma movimentação sem produto existente no catálogo | **PASSOU** |

---

### 2.3. Testes de Restrições Semânticas (`CHECK Constraints`)

Nesta bateria, o sistema tenta intencionalmente injetar tuplas corrompidas dentro de blocos protegidos `DO $$ BEGIN ... EXCEPTION ... END $$`. A aprovação ocorre quando o SGBD **rejeita** a operação e aciona a exceção apropriada:

| Teste ID | Operação Testada | Valor Injetado | Violação Esperada | Resultado |
|:---|:---|:---|:---|:---:|
| **T13** | Inserção de Produto | `preco = -50.00` | Rejeição por `CHK_PRODUTO_PRECO` | **PASSOU** |
| **T14** | Inserção de Produto | `quantidade_estoque = -5` | Rejeição por `CHK_PRODUTO_ESTOQUE` | **PASSOU** |
| **T15** | Item de Pedido | `quantidade = 0` | Rejeição por `CHK_ITEM_QUANTIDADE` | **PASSOU** |
| **T16** | Item de Pedido | `preco_unitario = -10.00` | Rejeição por `CHK_ITEM_PRECO` | **PASSOU** |
| **T17** | Item de Pedido | `desconto = -5.00` | Rejeição por `CHK_ITEM_DESCONTO` | **PASSOU** |
| **T18** | Cabeçalho de Pedido | `status = 'EXPEDIDO'` (inválido) | Rejeição por `CHK_PEDIDO_STATUS` | **PASSOU** |
| **T19** | Movimentação de Estoque | `tipo_movimentacao = 'TRANSFERENCIA'` | Rejeição por `CHK_MOV_TIPO` | **PASSOU** |

---

### 2.4. Testes de Unicidade (`UNIQUE Constraints`)

| Teste ID | Operação Testada | Valor Testado | Erro Esperado | Resultado |
|:---|:---|:---|:---|:---:|
| **T20** | Duplicação de CPF em `CLIENTE` | CPF já cadastrado | `unique_violation` (23505) | **PASSOU** |
| **T21** | Duplicação de CPF em `FUNCIONARIO` | CPF já cadastrado | `unique_violation` (23505) | **PASSOU** |
| **T22** | Duplicação de CNPJ em `FORNECEDOR`| CNPJ já cadastrado | `unique_violation` (23505) | **PASSOU** |

---

### 2.5. Testes de Regra de Exclusão (`ON DELETE RESTRICT`)

| Teste ID | Operação Testada | Alvo | Proteção Garantida | Resultado |
|:---|:---|:---|:---|:---:|
| **T23** | `DELETE FROM categoria` | Categoria com produtos associados | Bloqueio por integridade referencial ativa | **PASSOU** |
| **T24** | `DELETE FROM cliente` | Cliente que possui pedidos efetuados | Bloqueio por integridade referencial fiscal | **PASSOU** |
| **T25** | `DELETE FROM produto` | Produto com movimentações registradas | Bloqueio para evitar perda de histórico | **PASSOU** |

---

### 2.6. Teste de Consistência Transacional ACID e `ROLLBACK`

Para demonstrar a atomicidade na prática:
1. Um bloco transacional tenta criar uma venda com quantidade de itens superior ao estoque físico disponível.
2. O bloco dispara `RAISE EXCEPTION` sob a condição `quantidade_estoque < quantidade_solicitada`.
3. O SGBD executa o desfazimento total (`ROLLBACK`).
4. A consulta de auditoria confirma que **nenhum cabeçalho de pedido ou item foi persistido**, mantendo a integridade matemática da base.

---

## 3. Conclusão da Validação

A base relacional da **TechShop Eletrônicos** demonstrou **100% de conformidade com os requisitos da disciplina**:
- Todas as constraints de integridade operam a nível de banco de dados, sem depender de validação frágil na aplicação.
- A consistência transacional impede que vendas parciais ou inconsistências de saldo de estoque corrompam o sistema.
- A massa de teste com 166 registros cobre todos os cenários operacionais e de borda previstos na rubrica de avaliação.
