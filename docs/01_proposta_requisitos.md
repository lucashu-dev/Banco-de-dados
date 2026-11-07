# TechShop Eletrônicos — Sistema de Gestão de Vendas e Estoque

## Proposta e Levantamento de Requisitos

---

**Instituição:** Universidade Presbiteriana Mackenzie  
**Curso:** Engenharia da Computação  
**Disciplina:** Banco de Dados  
**Projeto:** TechShop Eletrônicos — Sistema de Gestão de Vendas e Estoque

---

## 1. Introdução

O presente documento descreve a proposta do projeto de banco de dados relacional desenvolvido para a disciplina de Banco de Dados do curso de Engenharia da Computação da Universidade Presbiteriana Mackenzie. O sistema tem como objetivo informatizar as operações de uma loja de eletrônicos fictícia denominada **TechShop Eletrônicos**, abrangendo a gestão de vendas, controle de estoque, cadastro de clientes e funcionários, e geração de relatórios gerenciais.

O projeto contempla todas as etapas do ciclo de vida de um banco de dados relacional: levantamento de requisitos, modelagem conceitual e lógica, normalização, implementação física em PostgreSQL, carga de dados, consultas avançadas e validação de integridade.

---

## 2. Situação-Problema

A TechShop Eletrônicos é uma loja de varejo especializada em produtos eletrônicos — smartphones, notebooks, tablets, periféricos, acessórios e componentes. Atualmente, a empresa enfrenta quatro gargalos operacionais críticos que comprometem sua eficiência e competitividade:

### 2.1 Duplicação de Dados

O controle de informações é realizado por meio de planilhas eletrônicas independentes, mantidas por diferentes setores da empresa. Dados de clientes, fornecedores e produtos são replicados em múltiplas planilhas sem qualquer mecanismo de sincronização. Isso resulta em:

- Cadastros duplicados de clientes com informações divergentes (endereço desatualizado em uma planilha, correto em outra);
- Dados de fornecedores repetidos com variações de grafia e CNPJ;
- Ocupação desnecessária de espaço de armazenamento;
- Dificuldade em determinar qual versão do dado é a correta (ausência de fonte única de verdade).

### 2.2 Erros em Pedidos

O processo de registro de pedidos é realizado manualmente, sem validações automáticas. Funcionários preenchem formulários em papel ou planilhas sem restrições de integridade, o que ocasiona:

- Pedidos registrados com códigos de produtos inexistentes ou descontinuados;
- Quantidades negativas ou zeradas aceitas sem qualquer alerta;
- Pedidos atribuídos a clientes não cadastrados, dificultando a cobrança e o pós-venda;
- Ausência de vínculo formal entre o pedido e o funcionário responsável, impossibilitando a rastreabilidade;
- Cálculos de subtotal e total realizados manualmente, sujeitos a erros aritméticos.

### 2.3 Ausência de Controle de Estoque

Não existe um sistema integrado para rastreamento de entradas e saídas de produtos no estoque. As consequências incluem:

- Impossibilidade de determinar em tempo real a quantidade disponível de cada produto;
- Vendas realizadas de produtos já esgotados, gerando frustração no cliente e cancelamentos;
- Compras de reposição feitas sem base quantitativa, levando a excessos ou rupturas de estoque;
- Ausência de registro histórico de movimentações (entradas de fornecedores, saídas por venda, devoluções, ajustes de inventário);
- Perdas financeiras por produtos parados (capital imobilizado) ou vendas perdidas por falta de mercadoria.

### 2.4 Inconsistência no Faturamento

A apuração financeira é comprometida pela falta de integração entre os dados de pedidos, produtos e pagamentos:

- Relatórios de faturamento são elaborados manualmente, consolidando dados de múltiplas fontes com alto risco de erro;
- Não há mecanismo para calcular automaticamente o faturamento por período, por cliente ou por vendedor;
- Descontos e promoções aplicados de forma ad hoc não são registrados de maneira padronizada;
- A conciliação entre pedidos realizados e valores efetivamente faturados é imprecisa;
- A ausência de dados confiáveis compromete decisões estratégicas de precificação e investimento.

---

## 3. Perfis de Usuário

O sistema foi projetado para atender quatro perfis de usuário, cada um com responsabilidades e necessidades de acesso distintas:

### 3.1 Vendedor / Atendente

| Aspecto | Descrição |
|---|---|
| **Papel** | Profissional responsável pelo atendimento direto ao cliente e pela efetivação de vendas |
| **Responsabilidades** | Cadastrar novos clientes no sistema; registrar pedidos de venda com os respectivos itens e quantidades; consultar disponibilidade de produtos em estoque; acompanhar o status dos pedidos sob sua responsabilidade |
| **Necessidades de acesso** | Leitura e escrita em CLIENTE, PEDIDO e ITEM_PEDIDO; leitura em PRODUTO (consulta de preço e estoque); leitura em CATEGORIA (classificação de produtos) |
| **Frequência de uso** | Diária, durante todo o expediente da loja |

### 3.2 Gerente de Loja

| Aspecto | Descrição |
|---|---|
| **Papel** | Responsável pela supervisão das operações comerciais e pelo acompanhamento de desempenho da equipe |
| **Responsabilidades** | Consultar relatórios de faturamento total e por período; analisar o ranking de vendedores por volume de vendas; identificar os produtos mais vendidos para orientar estratégias comerciais; monitorar clientes inativos para ações de reativação; supervisionar o cadastro de funcionários |
| **Necessidades de acesso** | Leitura em todas as tabelas; escrita em FUNCIONARIO; execução de consultas analíticas e relatórios |
| **Frequência de uso** | Diária, com ênfase em consultas analíticas no início e final do expediente |

### 3.3 Administrador de Estoque

| Aspecto | Descrição |
|---|---|
| **Papel** | Profissional responsável pelo controle físico e lógico do estoque de mercadorias |
| **Responsabilidades** | Cadastrar novos produtos e atualizar informações de produtos existentes; registrar entradas de mercadoria provenientes de fornecedores; acompanhar as baixas automáticas de estoque geradas por vendas; monitorar alertas de estoque mínimo para acionar reposição; consultar o histórico completo de movimentações de estoque; manter o cadastro de categorias e fornecedores atualizado |
| **Necessidades de acesso** | Leitura e escrita em PRODUTO, CATEGORIA, FORNECEDOR e MOVIMENTACAO_ESTOQUE; leitura em ITEM_PEDIDO (para rastrear saídas) |
| **Frequência de uso** | Diária, com picos nos dias de recebimento de mercadoria |

### 3.4 Analista Financeiro

| Aspecto | Descrição |
|---|---|
| **Papel** | Profissional responsável pela análise econômico-financeira das operações da loja |
| **Responsabilidades** | Gerar relatórios de faturamento mensal e acumulado; analisar o desempenho financeiro por cliente (identificar os maiores compradores); avaliar a rentabilidade por categoria de produto; realizar projeções de receita com base em dados históricos; identificar tendências sazonais de vendas |
| **Necessidades de acesso** | Leitura em PEDIDO, ITEM_PEDIDO, PRODUTO, CLIENTE e CATEGORIA; execução de consultas complexas com agregações, subconsultas e funções de janela |
| **Frequência de uso** | Semanal a mensal, com intensificação em períodos de fechamento contábil |

---

## 4. Requisitos Funcionais

Os requisitos funcionais descrevem as funcionalidades que o sistema de banco de dados deve prover. Cada requisito está vinculado a operações SQL específicas (DDL, DML ou DQL).

| ID | Requisito | Descrição | Operação SQL |
|---|---|---|---|
| **RF01** | Cadastro de Clientes | O sistema deve permitir o cadastro de clientes com nome completo, CPF (único), e-mail, telefone e data de cadastro. O CPF deve ser validado como único para evitar duplicidade. | `INSERT INTO CLIENTE` com constraint `UNIQUE(cpf)` |
| **RF02** | Cadastro de Funcionários | O sistema deve permitir o cadastro de funcionários com nome completo, CPF (único), cargo e data de admissão. Apenas cargos válidos devem ser aceitos (Vendedor, Gerente, Estoquista). | `INSERT INTO FUNCIONARIO` com `CHECK(cargo IN (...))` |
| **RF03** | Cadastro de Categorias | O sistema deve permitir o cadastro de categorias de produtos com nome e descrição. Categorias são utilizadas para classificar e organizar o catálogo de produtos. | `INSERT INTO CATEGORIA` |
| **RF04** | Cadastro de Fornecedores | O sistema deve permitir o cadastro de fornecedores com razão social, CNPJ (único), telefone de contato e e-mail. O CNPJ deve ser único no sistema. | `INSERT INTO FORNECEDOR` com constraint `UNIQUE(cnpj)` |
| **RF05** | Cadastro de Produtos | O sistema deve permitir o cadastro de produtos com nome, descrição, preço unitário, quantidade em estoque, estoque mínimo, categoria e fornecedor. O preço e a quantidade devem ser valores positivos. | `INSERT INTO PRODUTO` com `CHECK(preco > 0)`, `CHECK(qtd >= 0)` |
| **RF06** | Registro de Pedidos | O sistema deve permitir o registro de pedidos de venda vinculados a um cliente e a um funcionário responsável. Cada pedido deve conter data, status (Pendente, Confirmado, Cancelado) e valor total. | `INSERT INTO PEDIDO` com FKs para CLIENTE e FUNCIONARIO |
| **RF07** | Registro de Itens de Pedido | O sistema deve permitir a inclusão de itens em um pedido, especificando o produto, a quantidade e o preço unitário praticado. O subtotal de cada item deve ser calculado automaticamente. | `INSERT INTO ITEM_PEDIDO` com FK para PEDIDO e PRODUTO |
| **RF08** | Baixa Automática de Estoque | Ao confirmar um pedido, o sistema deve realizar automaticamente a baixa na quantidade em estoque dos produtos vendidos, registrando cada saída na tabela de movimentações. | `UPDATE PRODUTO SET qtd_estoque = qtd_estoque - N` + `INSERT INTO MOVIMENTACAO_ESTOQUE` via transação |
| **RF09** | Registro de Movimentações de Estoque | O sistema deve registrar todas as movimentações de estoque (entrada, saída, ajuste, devolução), incluindo o tipo de movimentação, a quantidade movimentada e a data/hora. | `INSERT INTO MOVIMENTACAO_ESTOQUE` com `CHECK(tipo IN (...))` |
| **RF10** | Alerta de Estoque Mínimo | O sistema deve permitir a consulta de produtos cuja quantidade em estoque esteja igual ou abaixo do estoque mínimo definido, sinalizando a necessidade de reposição. | `SELECT ... WHERE qtd_estoque <= estoque_minimo` |
| **RF11** | Relatórios de Faturamento | O sistema deve gerar relatórios de faturamento total por cliente, por período (mensal) e ranking de vendedores, utilizando consultas com agregação, agrupamento e ordenação. | `SELECT ... GROUP BY ... HAVING ... ORDER BY` |
| **RF12** | Consulta de Clientes Inativos | O sistema deve identificar clientes cadastrados que nunca realizaram pedidos ou que estão inativos há um período determinado, permitindo ações de reativação comercial. | `LEFT JOIN ... WHERE ... IS NULL` ou `NOT EXISTS (...)` |

---

## 5. Requisitos Não Funcionais

Os requisitos não funcionais definem as qualidades e restrições técnicas que o sistema deve satisfazer, independentemente de funcionalidades específicas.

### RNF01 — Integridade Referencial por Chaves Estrangeiras

| Aspecto | Descrição |
|---|---|
| **Descrição** | Todas as relações entre tabelas devem ser garantidas por chaves estrangeiras (FOREIGN KEY) com ação `ON DELETE RESTRICT`, impedindo a exclusão de registros pai que possuam dependências |
| **Justificativa** | Evita registros órfãos (pedidos sem cliente, itens sem pedido, produtos sem categoria) que comprometeriam a consistência do banco |
| **Implementação** | Cláusulas `REFERENCES ... ON DELETE RESTRICT` em todas as FKs do esquema DDL |
| **Verificação** | Tentar excluir um registro pai com dependências e confirmar que o SGBD rejeita a operação com erro de violação de FK |

### RNF02 — Consistência Transacional (ACID)

| Aspecto | Descrição |
|---|---|
| **Descrição** | Operações compostas (como a confirmação de um pedido com baixa de estoque) devem ser executadas dentro de transações que garantam as propriedades ACID (Atomicidade, Consistência, Isolamento, Durabilidade) |
| **Justificativa** | Garante que, em caso de falha parcial, todas as alterações sejam revertidas (ROLLBACK), mantendo o banco em estado consistente |
| **Implementação** | Blocos `BEGIN ... COMMIT` e `BEGIN ... ROLLBACK` no PostgreSQL para operações críticas |
| **Verificação** | Executar uma transação de confirmação de pedido com simulação de falha e verificar que o ROLLBACK restaura o estado anterior |

### RNF03 — Desempenho com Índices B-Tree

| Aspecto | Descrição |
|---|---|
| **Descrição** | Colunas frequentemente utilizadas em cláusulas WHERE, JOIN e ORDER BY devem possuir índices B-Tree para otimizar o tempo de resposta das consultas |
| **Justificativa** | Consultas sobre tabelas com grande volume de dados (PEDIDO, ITEM_PEDIDO, MOVIMENTACAO_ESTOQUE) devem retornar resultados em tempo aceitável, mesmo com milhares de registros |
| **Implementação** | `CREATE INDEX` em colunas como `cpf`, `cnpj`, `data_pedido`, `id_produto`, `id_cliente`, `id_pedido` |
| **Verificação** | Executar `EXPLAIN ANALYZE` antes e depois da criação do índice para comparar os planos de execução e tempos de resposta |

### RNF04 — Segurança contra SQL Injection

| Aspecto | Descrição |
|---|---|
| **Descrição** | Todas as entradas de dados devem ser tratadas para prevenir ataques de injeção SQL, utilizando consultas parametrizadas e validação de tipos |
| **Justificativa** | Proteger o banco de dados contra acesso não autorizado, alteração ou exclusão maliciosa de dados por meio de entradas manipuladas |
| **Implementação** | Uso de prepared statements (`$1, $2, ...`) em vez de concatenação de strings; validação de tipos nas constraints do esquema |
| **Verificação** | Testar inserções com caracteres especiais (`'; DROP TABLE --`) e confirmar que são tratados como dados literais, não como comandos SQL |

### RNF05 — Validação por Constraints

| Aspecto | Descrição |
|---|---|
| **Descrição** | O esquema do banco deve utilizar constraints (CHECK, UNIQUE, NOT NULL, DEFAULT) para garantir a validade dos dados no nível do SGBD, independentemente da aplicação cliente |
| **Justificativa** | A validação no nível do banco é a última linha de defesa contra dados inválidos, funcionando mesmo quando a aplicação falha em validar |
| **Implementação** | `CHECK(preco_unitario > 0)`, `CHECK(quantidade > 0)`, `CHECK(status IN ('Pendente','Confirmado','Cancelado'))`, `CHECK(tipo IN ('entrada','saida','ajuste','devolucao'))`, `UNIQUE(cpf)`, `UNIQUE(cnpj)`, `NOT NULL` em campos obrigatórios |
| **Verificação** | Tentar inserir dados que violem cada constraint e confirmar que o SGBD rejeita a operação com mensagem de erro apropriada |

### RNF06 — Normalização até a Terceira Forma Normal (3FN)

| Aspecto | Descrição |
|---|---|
| **Descrição** | O esquema do banco deve estar normalizado até a Terceira Forma Normal (3FN), eliminando redundâncias, dependências parciais e dependências transitivas |
| **Justificativa** | A normalização reduz a redundância de dados, minimiza anomalias de inserção, atualização e exclusão, e garante que cada fato seja armazenado em um único lugar |
| **Implementação** | Decomposição de tabelas durante a fase de modelagem, garantindo que cada atributo não-chave dependa exclusivamente da chave primária completa e de nenhum outro atributo não-chave |
| **Verificação** | Análise formal de dependências funcionais demonstrando conformidade com 1FN, 2FN e 3FN para todas as 8 tabelas do esquema |

---

## 6. Escopo do Projeto

### 6.1 Dentro do Escopo

- Modelagem conceitual e lógica do banco de dados (diagrama ER);
- Normalização formal até a 3FN com demonstração passo a passo;
- Implementação física do esquema em PostgreSQL (DDL);
- Carga de dados de teste representativos (DML);
- Desenvolvimento de 10 consultas SQL avançadas com explicação detalhada (DQL);
- Validação de integridade com testes de constraints, FK e transações;
- Documentação completa (dicionário de dados, proposta, modelagem, normalização, consultas, validação);
- Preparação para defesa com roteiro e perguntas técnicas.

### 6.2 Fora do Escopo

- Desenvolvimento de interface gráfica (front-end);
- Implementação de API ou serviços web (back-end);
- Integração com sistemas externos (gateways de pagamento, ERPs);
- Controle de acesso por usuário (GRANT/REVOKE) — mencionado conceitualmente, mas não implementado;
- Triggers e stored procedures — discutidos como melhorias futuras na defesa;
- Deploy em ambiente de produção.

---

## 7. Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| PostgreSQL | 15+ | Sistema Gerenciador de Banco de Dados Relacional (SGBDR) |
| SQL | SQL:2016 | Linguagem para definição (DDL), manipulação (DML) e consulta (DQL) de dados |
| Mermaid | 10+ | Geração de diagramas ER a partir de código declarativo |
| Markdown | — | Documentação técnica do projeto |

---

## 8. Cronograma de Desenvolvimento

| Fase | Atividade | Entregável |
|---|---|---|
| 1 | Levantamento de requisitos e proposta | `01_proposta_requisitos.md` |
| 2 | Modelagem conceitual e lógica | `02_modelagem.md`, `modelo_er.mmd` |
| 3 | Normalização formal | `03_normalizacao.md` |
| 4 | Dicionário de dados | `04_dicionario_dados.md` |
| 5 | Implementação DDL + DML | Scripts SQL (`01_schema.sql` a `04_indices.sql`) |
| 6 | Consultas avançadas | `05_consultas_explicadas.md` |
| 7 | Validação e testes | `06_validacao.md` |
| 8 | Preparação para defesa | `07_apresentacao.md` |
| 9 | Revisão final e entrega | `README.md` |

---

> **Documento elaborado como parte do projeto acadêmico da disciplina de Banco de Dados — Engenharia da Computação — Universidade Presbiteriana Mackenzie.**
