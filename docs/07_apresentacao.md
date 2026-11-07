# 🎓 Guia de Apresentação e Roteiro de Defesa Acadêmica

**Instituição:** Universidade Presbiteriana Mackenzie  
**Curso:** Engenharia da Computação  
**Disciplina:** Banco de Dados  
**Projeto:** TechShop Eletrônicos — Sistema de Gestão de Vendas e Estoque  

---

## 1. Estrutura Recomendada para Apresentação (Slides / Pitch de 10-15 min)

1. **Slide 1 — Introdução e Contexto Operacional:**
   - Apresentação da TechShop Eletrônicos.
   - Os 4 gargalos enfrentados (duplicidade cadastral, falta de rastreio de estoque, inconsistência de faturamento e erros operacionais em pedidos).
2. **Slide 2 — Modelo Entidade-Relacionamento e Normalização:**
   - Exibição do DER em notação Chen ou Mermaid (8 entidades interligadas).
   - Demonstração sintética da evolução 1FN → 2FN → 3FN.
3. **Slide 3 — Integridade Relacional e Engenharia DDL:**
   - Explicação das constraints explícitas (`CHECK`, `UNIQUE`, `NOT NULL`).
   - Política de exclusão (`ON DELETE RESTRICT`) como barreira contra corrupção referencial.
4. **Slide 4 — Transação ACID e Atomicidade:**
   - O fluxo de confirmação de pedido em bloco transacional.
   - Demonstração do mecanismo de `ROLLBACK` em caso de falta de estoque físico.
5. **Slide 5 — Engenharia de Otimização e Consultas Avançadas:**
   - Criação de índices B-Tree e análise de planos de execução (`EXPLAIN ANALYZE`).
   - Destaque para consultas com CTEs, Window Functions e agregações com `HAVING`.
6. **Slide 6 — Demonstração Prática e Conclusão:**
   - Execução do script `07_validation.sql` comprovando 100% dos testes aprovados.

---

## 2. Roteiro de Defesa: 14 Perguntas e Respostas da Banca Examinadora

### Pergunta 01: Por que o PostgreSQL foi selecionado como SGBD primário deste projeto?
**Resposta Técnica:**  
"O PostgreSQL é um SGBD relacional objeto-relacional maduro, de código aberto e estritamente aderente ao padrão ANSI SQL. Ele implementa o modelo de concorrência MVCC (Multi-Version Concurrency Control), garantindo níveis rigorosos de isolamento transacional ACID sem que operações de leitura bloqueiem gravações. Além disso, dispõe de suporte nativo a Window Functions avançadas, CTEs recursivas, índices B-Tree balanceados e um motor robusto de checagem de constraints (`CHECK`, `DOMAIN`), o que se alinha perfeitamente com os requisitos de auditoria fiscal e rastreabilidade de estoque exigidos pela TechShop."

---

### Pergunta 02: Como foi comprovado que o modelo relacional atende rigorosamente à Terceira Forma Normal (3FN)?
**Resposta Técnica:**  
"Para estar na 3FN, o esquema precisa satisfazer primeiro a 1FN e a 2FN:
1. **1FN:** Todos os atributos são atômicos e indivisíveis. Removemos qualquer atributo multivalorado (como telefones compostos ou múltiplos produtos agrupados numa mesma linha textual).
2. **2FN:** Não existem dependências parciais. Como a maioria das tabelas possui PK simples (`SERIAL`) e a tabela associativa `ITEM_PEDIDO` possui PK própria (`id_item`), todo atributo não-chave depende de toda a chave primária.
3. **3FN:** Não há dependências transitivas do tipo \( X \to Y \to Z \). Por exemplo, em vez de armazenar o nome e o telefone do fornecedor dentro da tabela `PRODUTO`, criamos uma entidade independente `FORNECEDOR` relacionada por `id_fornecedor`. Assim, atributos não-chave dependem exclusivamente da chave primária."

---

### Pergunta 03: Explique detalhadamente como o bloco transacional de confirmação de venda cumpre cada uma das 4 propriedades ACID.
**Resposta Técnica:**  
- **Atomicidade:** A operação é tratada como uma unidade indivisível dentro de um bloco `BEGIN ... COMMIT / ROLLBACK`. Se a inserção dos itens falhar ou o estoque for insuficiente, nenhuma linha é gravada (nem pedido, nem item, nem movimentação).
- **Consistência:** O banco transita exclusivamente entre estados válidos. As regras de integridade (`CHECK preco > 0`, `CHECK quantidade_estoque >= 0`) impedem estados corrompidos.
- **Isolamento:** No nível `READ COMMITTED` (ou `SERIALIZABLE`), modificações intermediárias não são visíveis para sessões concorrentes antes do `COMMIT`, prevenindo leituras sujas (*dirty reads*).
- **Durabilidade:** Uma vez emitido o `COMMIT`, os logs WAL (Write-Ahead Logging) garantem a persistência em disco não-volátil, mesmo se houver falha de hardware ou reinicialização do servidor.

---

### Pergunta 04: Por que foram criados índices B-Tree específicos em `PEDIDO(data_pedido)` e `CLIENTE(cpf)`?
**Resposta Técnica:**  
"O índice B-Tree (Balanced Tree) organiza os valores em uma árvore de busca balanceada com custo de acesso \( O(\log n) \).  
1. No campo `PEDIDO(data_pedido)`, relatórios mensais e anuais filtram faixas temporais (`WHERE data_pedido BETWEEN ...`). O índice B-Tree viabiliza operações de *Index Scan* e *Index Range Scan*, evitando a necessidade de um *Sequential Scan* custoso em bases com milhares de pedidos.  
2. No campo `CLIENTE(cpf)`, o índice acelera as buscas pontuais pelo documento do cliente no momento da abertura do carrinho pelo vendedor no PDV."

---

### Pergunta 05: Como o comando `EXPLAIN ANALYZE` comprova a eficácia de um índice?
**Resposta Técnica:**  
"O `EXPLAIN` apresenta o plano estimado gerado pelo otimizador de custos (*query optimizer*), detalhando custos de I/O em páginas e tuplas estimadas. O modificador `ANALYZE` executa a consulta de fato no motor e mede os tempos reais em milissegundos (*actual time*), a contagem exata de tuplas lidas e a memória consumida. Quando o índice é eficaz, observamos a transição de um nó `Seq Scan` (que varre todas as páginas da tabela) para um `Index Scan` ou `Bitmap Index Scan`, com redução drástica no custo computacional e tempo de resposta."

---

### Pergunta 06: Qual é a justificativa de negócio para utilizar a cláusula `ON DELETE RESTRICT` nas Foreign Keys?
**Resposta Técnica:**  
"Em um ambiente corporativo e fiscal, dados históricos não podem desaparecer sem rastreabilidade. Se permitíssemos `ON DELETE CASCADE` na relação entre `CLIENTE` e `PEDIDO`, a exclusão acidental de um cliente apagaria todas as notas e registros de vendas já realizadas por ele, violando a legislação fiscal e a contabilidade da empresa. Com `RESTRICT`, o próprio motor do banco rejeita a deleção caso existam dependências filhas, forçando a adoção de estratégias corporativas de inativação lógica (*soft delete* com flag `ativo = FALSE`)."

---

### Pergunta 07: Qual é a diferença fundamental entre aplicar regras de integridade via constraints `CHECK` no banco versus validar apenas no backend/aplicação?
**Resposta Técnica:**  
"Validar apenas na camada de aplicação é frágil e perigoso: múltiplos clientes de software (aplicativo web, app mobile, script de integração ETL, carga via terminal psql) podem acessar a base e ignorar as validações da aplicação. Ao consolidar as constraints `CHECK`, `NOT NULL` e `UNIQUE` no catálogo do SGBD, o banco atua como o árbitro supremo e intransponível da integridade dos dados, garantindo que nenhuma tupla semanticamente inválida seja gravada sob nenhuma circunstância."

---

### Pergunta 08: Como a consulta 10 utiliza uma Window Function para calcular o saldo acumulado de estoque sem gerar inconsistência?
**Resposta Técnica:**  
"A consulta 10 utiliza a função analítica:  
`SUM(quantidade_sinalizada) OVER (PARTITION BY id_produto ORDER BY data_movimentacao, id_movimentacao ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.  
O `PARTITION BY` segmenta o cálculo para cada produto isoladamente. O `ORDER BY` estabelece a linha do tempo cronológica das operações. A cláusula de janela define que o somatório deve considerar desde o primeiro registro histórico até a linha em avaliação no momento. Isso gera um cálculo progressivo com custo computacional otimizado em uma única passagem pelos dados (*single-pass*), sem recorrer a *self-joins* quadráticos."

---

### Pergunta 09: Qual a diferença semântica entre `LEFT JOIN ... WHERE id IS NULL` e `NOT EXISTS` para encontrar clientes inativos (Consulta 08)?
**Resposta Técnica:**  
"Ambas as formulações atingem o mesmo objetivo de negócio (encontrar clientes sem compras). No entanto:
- O `LEFT JOIN ... WHERE pe.id_pedido IS NULL` combina todas as linhas da tabela da esquerda com as da direita, preservando nulos e filtrando-os posteriormente.
- O `NOT EXISTS` opera como um *Anti-Semi-Join*: o otimizador pode interromper a busca na tabela interna assim que encontrar a primeira ocorrência correspondente (*short-circuit evaluation*), tornando-o frequentemente mais performático em bases volumosas e com estatísticas atualizadas."

---

### Pergunta 10: O que acontece durante a transação de venda caso o estoque seja menor que a quantidade solicitada?
**Resposta Técnica:**  
"O bloco PL/pgSQL possui uma cláusula condicional de proteção:  
`IF v_estoque_atual < v_quantidade_solicitada THEN RAISE EXCEPTION ...; END IF;`.  
A ocorrência dessa exceção desvia imediatamente o fluxo de execução para a seção `EXCEPTION` do bloco, onde é disparado o cancelamento total de qualquer operação pendente na sessão (`ROLLBACK`). Assim, não há risco de persistir um pedido sem os respectivos produtos em estoque."

---

### Pergunta 11: Como o modelo lida com descontos nos itens de pedido para garantir que o faturamento não seja negativado?
**Resposta Técnica:**  
"Aplicamos duas camadas de defesa no banco:  
1. No DDL da tabela `ITEM_PEDIDO`, temos a constraint `CHK_ITEM_DESCONTO` garantindo que o desconto seja maior ou igual a zero, e `CHK_ITEM_SUBTOTAL` validando que `subtotal > 0`.  
2. No cálculo do subtotal da transação, definimos `subtotal = (quantidade * preco_unitario) - desconto`. Qualquer operação que resulte em subtotal menor ou igual a zero é sumariamente rejeitada pelas constraints da tabela."

---

### Pergunta 12: Como você lidaria com alta concorrência de múltiplos vendedores tentando comprar a última unidade do mesmo produto?
**Resposta Técnica:**  
"Utilizaríamos a cláusula de bloqueio explícito pessimista `SELECT ... FOR UPDATE` sobre a tupla do produto dentro da transação:  
`SELECT quantidade_estoque FROM produto WHERE id_produto = 5 FOR UPDATE;`.  
Isso bloqueia a linha do produto no nível de tupla para outras transações concorrentes até o término da transação corrente. O primeiro vendedor que adquirir a trava efetua a compra; o segundo vendedor aguardará a liberação, relerá o estoque já atualizado como zero e receberá a exceção de estoque insuficiente, prevenindo a anomalia de venda fantasma (*lost update*)."

---

### Pergunta 13: Quais melhorias de arquitetura você proporia em uma versão de produção de larga escala?
**Resposta Técnica:**  
"Três evoluções principais:  
1. **Triggers de Automação:** Implementar um gatilho `AFTER INSERT ON item_pedido` para realizar a baixa no estoque e a inserção na tabela de movimentações de forma automática e transparente.  
2. **Views Materializadas:** Criar uma `MATERIALIZED VIEW` para os relatórios mensais de faturamento com atualização periódica agendada via `REFRESH MATERIALIZED VIEW CONCURRENTLY`, poupando recursos do banco analítico.  
3. **Particionamento de Tabelas:** Particionar a tabela `MOVIMENTACAO_ESTOQUE` e `PEDIDO` por intervalo de datas (*Range Partitioning* por ano ou trimestre), otimizando a retenção de dados históricos e consultas analíticas."

---

### Pergunta 14: Como a integridade dos dados foi testada e homologada de ponta a ponta?
**Resposta Técnica:**  
"Desenvolvemos o script de suíte automatizada `sql/07_validation.sql` com mais de 650 linhas de código. O script cria uma tabela temporária de resultados e submete o banco a testes de estresse intencionais com valores negativos em preços, estoques, quantidades, duplicação intencional de CPFs e CNPJs, e tentativa de deleção de registros com filhos vinculados. Apenas quando o SGBD intercepta e rejeita com sucesso todas as tentativas ilegais, o teste é marcado com a flag `PASSOU`."
