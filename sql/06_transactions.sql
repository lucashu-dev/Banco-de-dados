-- ============================================================
-- Arquivo: 06_transactions.sql
-- Projeto: TechShop Eletrônicos — Banco de Dados PostgreSQL
-- Descrição: Transações ACID completas para confirmação de
--            pedidos de venda, demonstrando Atomicidade,
--            Consistência, Isolamento e Durabilidade.
-- Codificação: UTF-8
-- ============================================================

-- ============================================================
-- TRANSAÇÃO 1: Confirmar Pedido de Venda (cenário de SUCESSO)
-- ============================================================
-- Propriedades ACID demonstradas:
--
-- ATOMICIDADE: Todas as operações (INSERT pedido, INSERT itens,
--   UPDATE estoque, INSERT movimentações) são executadas como
--   uma unidade indivisível. Se qualquer etapa falhar, NENHUMA
--   alteração é persistida no banco de dados.
--
-- CONSISTÊNCIA: Antes de qualquer modificação, validamos a
--   existência do cliente, do funcionário e dos produtos,
--   além de verificar se há estoque suficiente. As constraints
--   (CHECK, FK, UNIQUE) garantem que o banco permanece em
--   estado válido antes e depois da transação.
--
-- ISOLAMENTO: O nível READ COMMITTED garante que esta transação
--   não enxerga dados sujos de transações concorrentes ainda
--   não commitadas. Cada leitura vê apenas dados confirmados.
--
-- DURABILIDADE: Após o COMMIT, as alterações são permanentes
--   mesmo em caso de falha de energia ou crash do servidor,
--   pois o PostgreSQL utiliza WAL (Write-Ahead Logging).
-- ============================================================

DO $$
DECLARE
    -- Variáveis de identificação dos participantes
    v_id_cliente      INTEGER := 1;    -- Cliente que realiza a compra
    v_id_funcionario  INTEGER := 2;    -- Funcionário responsável pelo atendimento

    -- Variáveis do pedido
    v_id_pedido       INTEGER;         -- ID do novo pedido (gerado pelo SERIAL/SEQUENCE)
    v_valor_total     NUMERIC(10,2) := 0.00;  -- Acumulador do valor total do pedido

    -- Produto 1: dados da solicitação
    v_id_produto_1    INTEGER := 3;    -- ID do primeiro produto
    v_qtd_1           INTEGER := 2;    -- Quantidade solicitada do primeiro produto
    v_desconto_1      NUMERIC(5,2) := 0.00;  -- Desconto aplicado ao primeiro produto

    -- Produto 2: dados da solicitação
    v_id_produto_2    INTEGER := 5;    -- ID do segundo produto
    v_qtd_2           INTEGER := 1;    -- Quantidade solicitada do segundo produto
    v_desconto_2      NUMERIC(5,2) := 5.00;  -- Desconto percentual (5%) no segundo produto

    -- Variáveis de controle e cálculo
    v_preco_1         NUMERIC(10,2);   -- Preço unitário recuperado do produto 1
    v_preco_2         NUMERIC(10,2);   -- Preço unitário recuperado do produto 2
    v_estoque_1       INTEGER;         -- Estoque atual do produto 1
    v_estoque_2       INTEGER;         -- Estoque atual do produto 2
    v_subtotal_1      NUMERIC(10,2);   -- Subtotal calculado para o item 1
    v_subtotal_2      NUMERIC(10,2);   -- Subtotal calculado para o item 2
    v_ativo_1         BOOLEAN;         -- Indica se o produto 1 está ativo
    v_ativo_2         BOOLEAN;         -- Indica se o produto 2 está ativo

    -- Variáveis de validação de existência
    v_cliente_existe  BOOLEAN;         -- Flag: cliente encontrado no banco
    v_func_existe     BOOLEAN;         -- Flag: funcionário encontrado no banco

BEGIN
    -- ============================================================
    -- ETAPA 1: VALIDAÇÃO DO CLIENTE
    -- Consistência: verificar se o cliente existe antes de
    -- associá-lo a um pedido, evitando violação de FK.
    -- ============================================================
    RAISE NOTICE '=== TRANSAÇÃO 1: CONFIRMAÇÃO DE PEDIDO (SUCESSO) ===';
    RAISE NOTICE 'Etapa 1: Validando cliente ID %...', v_id_cliente;

    SELECT EXISTS(
        SELECT 1 FROM cliente WHERE id_cliente = v_id_cliente
    ) INTO v_cliente_existe;

    IF NOT v_cliente_existe THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Cliente ID % não encontrado no cadastro.', v_id_cliente;
    END IF;

    RAISE NOTICE '  ✓ Cliente ID % validado com sucesso.', v_id_cliente;

    -- ============================================================
    -- ETAPA 2: VALIDAÇÃO DO FUNCIONÁRIO
    -- Consistência: verificar se o funcionário existe antes de
    -- registrá-lo como responsável pelo pedido.
    -- ============================================================
    RAISE NOTICE 'Etapa 2: Validando funcionário ID %...', v_id_funcionario;

    SELECT EXISTS(
        SELECT 1 FROM funcionario WHERE id_funcionario = v_id_funcionario
    ) INTO v_func_existe;

    IF NOT v_func_existe THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Funcionário ID % não encontrado no cadastro.', v_id_funcionario;
    END IF;

    RAISE NOTICE '  ✓ Funcionário ID % validado com sucesso.', v_id_funcionario;

    -- ============================================================
    -- ETAPA 3: VALIDAÇÃO DOS PRODUTOS (existência + ativo)
    -- Consistência: confirmar que os produtos estão cadastrados
    -- e ativos antes de incluí-los no pedido.
    -- ============================================================
    RAISE NOTICE 'Etapa 3: Validando produtos...';

    -- Produto 1: buscar preço, estoque e status
    SELECT preco, quantidade_estoque, ativo
    INTO v_preco_1, v_estoque_1, v_ativo_1
    FROM produto
    WHERE id_produto = v_id_produto_1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Produto ID % não encontrado no catálogo.', v_id_produto_1;
    END IF;

    IF NOT v_ativo_1 THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Produto ID % está inativo e não pode ser vendido.', v_id_produto_1;
    END IF;

    RAISE NOTICE '  ✓ Produto ID %: preço R$ %, estoque % un.', v_id_produto_1, v_preco_1, v_estoque_1;

    -- Produto 2: buscar preço, estoque e status
    SELECT preco, quantidade_estoque, ativo
    INTO v_preco_2, v_estoque_2, v_ativo_2
    FROM produto
    WHERE id_produto = v_id_produto_2;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Produto ID % não encontrado no catálogo.', v_id_produto_2;
    END IF;

    IF NOT v_ativo_2 THEN
        RAISE EXCEPTION 'ERRO DE VALIDAÇÃO: Produto ID % está inativo e não pode ser vendido.', v_id_produto_2;
    END IF;

    RAISE NOTICE '  ✓ Produto ID %: preço R$ %, estoque % un.', v_id_produto_2, v_preco_2, v_estoque_2;

    -- ============================================================
    -- ETAPA 4: VERIFICAÇÃO DE ESTOQUE SUFICIENTE
    -- Consistência: impedir a venda de quantidade superior ao
    -- estoque disponível, evitando saldo negativo.
    -- ============================================================
    RAISE NOTICE 'Etapa 4: Verificando disponibilidade de estoque...';

    IF v_estoque_1 < v_qtd_1 THEN
        RAISE EXCEPTION 'ESTOQUE INSUFICIENTE: Produto ID % — disponível: % un., solicitado: % un.',
            v_id_produto_1, v_estoque_1, v_qtd_1;
    END IF;

    IF v_estoque_2 < v_qtd_2 THEN
        RAISE EXCEPTION 'ESTOQUE INSUFICIENTE: Produto ID % — disponível: % un., solicitado: % un.',
            v_id_produto_2, v_estoque_2, v_qtd_2;
    END IF;

    RAISE NOTICE '  ✓ Estoque suficiente para todos os produtos.';

    -- ============================================================
    -- ETAPA 5: CRIAR O PEDIDO
    -- Atomicidade: o pedido é inserido com valor_total = 0.00
    -- e será atualizado após o cálculo dos itens.
    -- ============================================================
    RAISE NOTICE 'Etapa 5: Criando pedido...';

    INSERT INTO pedido (id_cliente, id_funcionario, data_pedido, valor_total, status)
    VALUES (v_id_cliente, v_id_funcionario, NOW(), 0.00, 'CONFIRMADO')
    RETURNING id_pedido INTO v_id_pedido;

    RAISE NOTICE '  ✓ Pedido Nº % criado com sucesso.', v_id_pedido;

    -- ============================================================
    -- ETAPA 6: INSERIR ITENS DO PEDIDO
    -- Atomicidade: cada item é inserido individualmente com
    -- cálculo de subtotal = (quantidade × preço) - desconto.
    -- ============================================================
    RAISE NOTICE 'Etapa 6: Inserindo itens do pedido...';

    -- Item 1: cálculo do subtotal (sem desconto percentual neste caso)
    v_subtotal_1 := (v_qtd_1 * v_preco_1) - v_desconto_1;

    IF v_subtotal_1 <= 0 THEN
        RAISE EXCEPTION 'ERRO DE CÁLCULO: Subtotal do item 1 é R$ % (deve ser > 0). Desconto excessivo.', v_subtotal_1;
    END IF;

    INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario, desconto, subtotal)
    VALUES (v_id_pedido, v_id_produto_1, v_qtd_1, v_preco_1, v_desconto_1, v_subtotal_1);

    RAISE NOTICE '  ✓ Item 1: Produto ID %, % un. × R$ % - R$ % desconto = R$ %',
        v_id_produto_1, v_qtd_1, v_preco_1, v_desconto_1, v_subtotal_1;

    -- Item 2: cálculo do subtotal com desconto percentual
    v_subtotal_2 := (v_qtd_2 * v_preco_2) - v_desconto_2;

    IF v_subtotal_2 <= 0 THEN
        RAISE EXCEPTION 'ERRO DE CÁLCULO: Subtotal do item 2 é R$ % (deve ser > 0). Desconto excessivo.', v_subtotal_2;
    END IF;

    INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario, desconto, subtotal)
    VALUES (v_id_pedido, v_id_produto_2, v_qtd_2, v_preco_2, v_desconto_2, v_subtotal_2);

    RAISE NOTICE '  ✓ Item 2: Produto ID %, % un. × R$ % - R$ % desconto = R$ %',
        v_id_produto_2, v_qtd_2, v_preco_2, v_desconto_2, v_subtotal_2;

    -- ============================================================
    -- ETAPA 7: ATUALIZAR VALOR TOTAL DO PEDIDO
    -- Consistência: o valor_total do pedido deve refletir
    -- exatamente a soma dos subtotais de todos os itens.
    -- ============================================================
    RAISE NOTICE 'Etapa 7: Calculando valor total do pedido...';

    v_valor_total := v_subtotal_1 + v_subtotal_2;

    UPDATE pedido
    SET valor_total = v_valor_total
    WHERE id_pedido = v_id_pedido;

    RAISE NOTICE '  ✓ Valor total do pedido Nº %: R$ %', v_id_pedido, v_valor_total;

    -- ============================================================
    -- ETAPA 8: ATUALIZAR ESTOQUE DOS PRODUTOS
    -- Atomicidade: o estoque é decrementado para cada produto
    -- vendido. Se qualquer falha ocorrer após este ponto, o
    -- ROLLBACK restaurará os valores originais.
    -- ============================================================
    RAISE NOTICE 'Etapa 8: Atualizando estoque dos produtos...';

    UPDATE produto
    SET quantidade_estoque = quantidade_estoque - v_qtd_1
    WHERE id_produto = v_id_produto_1;

    RAISE NOTICE '  ✓ Produto ID %: estoque % → % un.',
        v_id_produto_1, v_estoque_1, (v_estoque_1 - v_qtd_1);

    UPDATE produto
    SET quantidade_estoque = quantidade_estoque - v_qtd_2
    WHERE id_produto = v_id_produto_2;

    RAISE NOTICE '  ✓ Produto ID %: estoque % → % un.',
        v_id_produto_2, v_estoque_2, (v_estoque_2 - v_qtd_2);

    -- ============================================================
    -- ETAPA 9: REGISTRAR MOVIMENTAÇÕES DE ESTOQUE
    -- Consistência + Rastreabilidade: cada saída de estoque
    -- gera um registro na tabela de movimentações para
    -- auditoria e controle.
    -- ============================================================
    RAISE NOTICE 'Etapa 9: Registrando movimentações de estoque...';

    INSERT INTO movimentacao_estoque (id_produto, tipo_movimentacao, quantidade, data_movimentacao, observacao)
    VALUES (
        v_id_produto_1,
        'SAIDA',
        v_qtd_1,
        NOW(),
        'Saída por venda — Pedido Nº ' || v_id_pedido
    );

    RAISE NOTICE '  ✓ Movimentação SAÍDA registrada: Produto ID %, % un.', v_id_produto_1, v_qtd_1;

    INSERT INTO movimentacao_estoque (id_produto, tipo_movimentacao, quantidade, data_movimentacao, observacao)
    VALUES (
        v_id_produto_2,
        'SAIDA',
        v_qtd_2,
        NOW(),
        'Saída por venda — Pedido Nº ' || v_id_pedido
    );

    RAISE NOTICE '  ✓ Movimentação SAÍDA registrada: Produto ID %, % un.', v_id_produto_2, v_qtd_2;

    -- ============================================================
    -- COMMIT IMPLÍCITO (dentro do bloco DO, o PostgreSQL faz
    -- commit automático ao final se nenhuma exceção ocorrer)
    -- DURABILIDADE: após o commit, todas as alterações são
    -- gravadas de forma permanente no disco via WAL.
    -- ============================================================
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  ✅ TRANSAÇÃO CONCLUÍDA COM SUCESSO!';
    RAISE NOTICE '  Pedido Nº %: R$ % — Status: CONFIRMADO', v_id_pedido, v_valor_total;
    RAISE NOTICE '  Itens: 2 | Produtos atualizados: 2';
    RAISE NOTICE '  Movimentações de estoque registradas: 2';
    RAISE NOTICE '══════════════════════════════════════════════════';

EXCEPTION
    -- ============================================================
    -- TRATAMENTO DE EXCEÇÕES — ROLLBACK AUTOMÁTICO
    -- Atomicidade: se QUALQUER etapa acima lançar uma exceção,
    -- o PostgreSQL executa ROLLBACK de todas as alterações feitas
    -- dentro deste bloco. Nenhum dado parcial é persistido.
    -- ============================================================
    WHEN OTHERS THEN
        RAISE NOTICE '';
        RAISE NOTICE '══════════════════════════════════════════════════';
        RAISE NOTICE '  ❌ TRANSAÇÃO REVERTIDA (ROLLBACK)!';
        RAISE NOTICE '  Erro: %', SQLERRM;
        RAISE NOTICE '  Código: %', SQLSTATE;
        RAISE NOTICE '  Nenhuma alteração foi persistida no banco.';
        RAISE NOTICE '══════════════════════════════════════════════════';
END;
$$;


-- ============================================================
-- TRANSAÇÃO 2: Demonstração de ROLLBACK (estoque insuficiente)
-- ============================================================
-- Este bloco demonstra o cenário em que o cliente tenta comprar
-- uma quantidade maior do que o estoque disponível.
-- A transação deve ser COMPLETAMENTE REVERTIDA, demonstrando
-- a propriedade de ATOMICIDADE do ACID.
-- ============================================================

DO $$
DECLARE
    -- Variáveis de identificação
    v_id_cliente      INTEGER := 1;    -- Cliente existente
    v_id_funcionario  INTEGER := 2;    -- Funcionário existente

    -- Produto com quantidade absurdamente alta para forçar falha
    v_id_produto      INTEGER := 3;    -- Produto a ser "comprado"
    v_qtd_solicitada  INTEGER := 99999; -- Quantidade impossível (forçar ROLLBACK)

    -- Variáveis de controle
    v_estoque_atual   INTEGER;         -- Estoque real do produto
    v_preco           NUMERIC(10,2);   -- Preço do produto
    v_ativo           BOOLEAN;         -- Status do produto
    v_id_pedido       INTEGER;         -- ID do pedido (será revertido)

    -- Contadores para verificação antes/depois
    v_count_pedidos_antes   INTEGER;
    v_count_pedidos_depois  INTEGER;
    v_count_mov_antes       INTEGER;
    v_count_mov_depois      INTEGER;

BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '=== TRANSAÇÃO 2: DEMONSTRAÇÃO DE ROLLBACK ===';
    RAISE NOTICE 'Cenário: tentativa de compra com estoque insuficiente.';
    RAISE NOTICE '';

    -- Guardar contadores antes da transação para comparação
    SELECT COUNT(*) INTO v_count_pedidos_antes FROM pedido;
    SELECT COUNT(*) INTO v_count_mov_antes FROM movimentacao_estoque;

    RAISE NOTICE 'Estado ANTES da tentativa:';
    RAISE NOTICE '  Pedidos no banco: %', v_count_pedidos_antes;
    RAISE NOTICE '  Movimentações no banco: %', v_count_mov_antes;
    RAISE NOTICE '';

    -- Buscar dados do produto
    SELECT preco, quantidade_estoque, ativo
    INTO v_preco, v_estoque_atual, v_ativo
    FROM produto
    WHERE id_produto = v_id_produto;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto ID % não encontrado.', v_id_produto;
    END IF;

    RAISE NOTICE 'Produto ID %: estoque atual = % un.', v_id_produto, v_estoque_atual;
    RAISE NOTICE 'Quantidade solicitada: % un.', v_qtd_solicitada;
    RAISE NOTICE '';

    -- Verificação de estoque — DEVE FALHAR aqui
    IF v_estoque_atual < v_qtd_solicitada THEN
        RAISE EXCEPTION 'ESTOQUE INSUFICIENTE: Produto ID % possui apenas % un. em estoque, mas foram solicitadas % un. A transação será revertida.',
            v_id_produto, v_estoque_atual, v_qtd_solicitada;
    END IF;

    -- As linhas abaixo NUNCA serão executadas neste cenário
    INSERT INTO pedido (id_cliente, id_funcionario, data_pedido, valor_total, status)
    VALUES (v_id_cliente, v_id_funcionario, NOW(), 0.00, 'CONFIRMADO')
    RETURNING id_pedido INTO v_id_pedido;

    RAISE NOTICE 'Esta mensagem NUNCA deve aparecer.';

EXCEPTION
    -- ============================================================
    -- ROLLBACK AUTOMÁTICO
    -- Atomicidade em ação: como a exceção foi lançada, o
    -- PostgreSQL reverte automaticamente qualquer alteração
    -- feita dentro deste bloco. O banco permanece inalterado.
    -- ============================================================
    WHEN OTHERS THEN
        RAISE NOTICE '══════════════════════════════════════════════════';
        RAISE NOTICE '  ❌ EXCEÇÃO CAPTURADA — ROLLBACK EXECUTADO!';
        RAISE NOTICE '  Mensagem: %', SQLERRM;
        RAISE NOTICE '  Código SQLSTATE: %', SQLSTATE;
        RAISE NOTICE '══════════════════════════════════════════════════';

        -- Verificar que nada foi alterado (prova do ROLLBACK)
        SELECT COUNT(*) INTO v_count_pedidos_depois FROM pedido;
        SELECT COUNT(*) INTO v_count_mov_depois FROM movimentacao_estoque;

        RAISE NOTICE '';
        RAISE NOTICE 'Verificação pós-ROLLBACK:';
        RAISE NOTICE '  Pedidos antes: % | Pedidos depois: %', v_count_pedidos_antes, v_count_pedidos_depois;
        RAISE NOTICE '  Movimentações antes: % | Movimentações depois: %', v_count_mov_antes, v_count_mov_depois;

        IF v_count_pedidos_antes = v_count_pedidos_depois
           AND v_count_mov_antes = v_count_mov_depois THEN
            RAISE NOTICE '  ✅ ATOMICIDADE CONFIRMADA: nenhum dado foi alterado.';
        ELSE
            RAISE NOTICE '  ⚠️ ATENÇÃO: contagem divergente — investigar!';
        END IF;

        RAISE NOTICE '';
        RAISE NOTICE '══════════════════════════════════════════════════';
        RAISE NOTICE '  CONCLUSÃO: A propriedade ACID foi respeitada.';
        RAISE NOTICE '  O banco de dados permanece em estado consistente.';
        RAISE NOTICE '══════════════════════════════════════════════════';
END;
$$;
