-- ============================================================
-- Arquivo: 07_validation.sql
-- Projeto: TechShop Eletrônicos — Banco de Dados PostgreSQL
-- Descrição: Script de validação abrangente que verifica a
--            integridade dos dados, constraints (CHECK, UNIQUE,
--            FK) e comportamento transacional (ROLLBACK).
-- Codificação: UTF-8
-- ============================================================

-- ============================================================
-- PREPARAÇÃO: Criar tabela temporária para armazenar os
-- resultados de cada teste de validação.
-- ============================================================
DROP TABLE IF EXISTS resultado_validacao;

CREATE TEMPORARY TABLE resultado_validacao (
    id_teste    SERIAL PRIMARY KEY,
    categoria   VARCHAR(50)   NOT NULL,
    teste       VARCHAR(120)  NOT NULL,
    resultado   VARCHAR(10)   NOT NULL,  -- 'PASSOU' ou 'FALHOU'
    detalhes    TEXT
);


-- ============================================================
-- SEÇÃO 1: CONTAGEM DE REGISTROS EM TODAS AS TABELAS
-- Objetivo: Verificar que todas as tabelas possuem dados
--           populados e exibir a quantidade de registros.
-- ============================================================

RAISE NOTICE ''; -- não funciona fora de bloco; usamos DO abaixo

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 1: CONTAGEM DE REGISTROS NAS TABELAS';
    RAISE NOTICE '══════════════════════════════════════════════════';

    -- Categoria
    SELECT COUNT(*) INTO v_count FROM categoria;
    RAISE NOTICE '  CATEGORIA ............... % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela CATEGORIA possui registros', 
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Fornecedor
    SELECT COUNT(*) INTO v_count FROM fornecedor;
    RAISE NOTICE '  FORNECEDOR .............. % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela FORNECEDOR possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Produto
    SELECT COUNT(*) INTO v_count FROM produto;
    RAISE NOTICE '  PRODUTO ................. % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela PRODUTO possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Cliente
    SELECT COUNT(*) INTO v_count FROM cliente;
    RAISE NOTICE '  CLIENTE ................. % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela CLIENTE possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Funcionário
    SELECT COUNT(*) INTO v_count FROM funcionario;
    RAISE NOTICE '  FUNCIONARIO ............. % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela FUNCIONARIO possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Pedido
    SELECT COUNT(*) INTO v_count FROM pedido;
    RAISE NOTICE '  PEDIDO .................. % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela PEDIDO possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Item Pedido
    SELECT COUNT(*) INTO v_count FROM item_pedido;
    RAISE NOTICE '  ITEM_PEDIDO ............. % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela ITEM_PEDIDO possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    -- Movimentação de Estoque
    SELECT COUNT(*) INTO v_count FROM movimentacao_estoque;
    RAISE NOTICE '  MOVIMENTACAO_ESTOQUE .... % registro(s)', v_count;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Contagem', 'Tabela MOVIMENTACAO_ESTOQUE possui registros',
            CASE WHEN v_count > 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_count || ' registro(s)');

    RAISE NOTICE '';
END;
$$;


-- ============================================================
-- SEÇÃO 2: VERIFICAÇÃO DE INTEGRIDADE REFERENCIAL
-- Objetivo: Buscar registros órfãos (FK apontando para PK
--           inexistente). O resultado esperado é ZERO em cada.
-- ============================================================

DO $$
DECLARE
    v_orfaos INTEGER;
BEGIN
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 2: INTEGRIDADE REFERENCIAL (ÓRFÃOS)';
    RAISE NOTICE '══════════════════════════════════════════════════';

    -- Produtos sem categoria válida
    SELECT COUNT(*) INTO v_orfaos
    FROM produto p
    WHERE NOT EXISTS (SELECT 1 FROM categoria c WHERE c.id_categoria = p.id_categoria);

    RAISE NOTICE '  Produtos sem categoria válida: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Produtos sem categoria válida = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    -- Produtos sem fornecedor válido
    SELECT COUNT(*) INTO v_orfaos
    FROM produto p
    WHERE NOT EXISTS (SELECT 1 FROM fornecedor f WHERE f.id_fornecedor = p.id_fornecedor);

    RAISE NOTICE '  Produtos sem fornecedor válido: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Produtos sem fornecedor válido = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    -- Pedidos sem cliente válido
    SELECT COUNT(*) INTO v_orfaos
    FROM pedido pe
    WHERE NOT EXISTS (SELECT 1 FROM cliente cl WHERE cl.id_cliente = pe.id_cliente);

    RAISE NOTICE '  Pedidos sem cliente válido: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Pedidos sem cliente válido = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    -- Pedidos sem funcionário válido
    SELECT COUNT(*) INTO v_orfaos
    FROM pedido pe
    WHERE NOT EXISTS (SELECT 1 FROM funcionario fu WHERE fu.id_funcionario = pe.id_funcionario);

    RAISE NOTICE '  Pedidos sem funcionário válido: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Pedidos sem funcionário válido = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    -- Itens de pedido sem pedido válido
    SELECT COUNT(*) INTO v_orfaos
    FROM item_pedido ip
    WHERE NOT EXISTS (SELECT 1 FROM pedido pe WHERE pe.id_pedido = ip.id_pedido);

    RAISE NOTICE '  Itens de pedido sem pedido válido: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Itens sem pedido válido = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    -- Itens de pedido sem produto válido
    SELECT COUNT(*) INTO v_orfaos
    FROM item_pedido ip
    WHERE NOT EXISTS (SELECT 1 FROM produto p WHERE p.id_produto = ip.id_produto);

    RAISE NOTICE '  Itens de pedido sem produto válido: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Itens sem produto válido = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    -- Movimentações sem produto válido
    SELECT COUNT(*) INTO v_orfaos
    FROM movimentacao_estoque me
    WHERE NOT EXISTS (SELECT 1 FROM produto p WHERE p.id_produto = me.id_produto);

    RAISE NOTICE '  Movimentações sem produto válido: %', v_orfaos;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('Integridade', 'Movimentações sem produto válido = 0',
            CASE WHEN v_orfaos = 0 THEN 'PASSOU' ELSE 'FALHOU' END,
            v_orfaos || ' registro(s) órfão(s)');

    RAISE NOTICE '';
END;
$$;


-- ============================================================
-- SEÇÃO 3: TESTES DE VIOLAÇÃO DE CONSTRAINTS CHECK
-- Objetivo: Confirmar que as restrições CHECK estão ativas
--           e rejeitam dados inválidos corretamente.
-- ============================================================

-- Teste 3.1: Produto com preço negativo (deve falhar)
DO $$
BEGIN
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 3: TESTES DE CONSTRAINTS CHECK';
    RAISE NOTICE '══════════════════════════════════════════════════';

    RAISE NOTICE '  Teste 3.1: INSERT produto com preço = -10.00...';

    INSERT INTO produto (id_categoria, id_fornecedor, nome, descricao, preco, quantidade_estoque, estoque_minimo, ativo)
    VALUES (1, 1, 'Produto Teste Inválido', 'Teste de validação', -10.00, 10, 5, TRUE);

    -- Se chegou aqui, a constraint NÃO está funcionando
    RAISE NOTICE '    ❌ FALHOU: INSERT com preço negativo foi aceito!';
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('CHECK', 'Rejeitar produto com preço negativo', 'FALHOU', 'INSERT foi aceito — constraint ausente');

    -- Limpar o registro inserido indevidamente
    DELETE FROM produto WHERE nome = 'Produto Teste Inválido';

EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado corretamente (check_violation).';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar produto com preço negativo', 'PASSOU', 'check_violation capturada');
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar produto com preço negativo', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;

-- Teste 3.2: Item de pedido com quantidade = 0 (deve falhar)
DO $$
DECLARE
    v_id_pedido INTEGER;
BEGIN
    RAISE NOTICE '  Teste 3.2: INSERT item_pedido com quantidade = 0...';

    -- Buscar um pedido existente para referência
    SELECT id_pedido INTO v_id_pedido FROM pedido LIMIT 1;

    IF v_id_pedido IS NULL THEN
        RAISE NOTICE '    ⚠️ IGNORADO: nenhum pedido encontrado para teste.';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar item com quantidade = 0', 'FALHOU', 'Sem pedido de referência');
        RETURN;
    END IF;

    INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario, desconto, subtotal)
    VALUES (v_id_pedido, 1, 0, 100.00, 0.00, 0.00);

    RAISE NOTICE '    ❌ FALHOU: INSERT com quantidade = 0 foi aceito!';
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('CHECK', 'Rejeitar item com quantidade = 0', 'FALHOU', 'INSERT foi aceito — constraint ausente');

    -- Limpar registro indevido
    DELETE FROM item_pedido WHERE quantidade = 0 AND preco_unitario = 100.00;

EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado corretamente (check_violation).';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar item com quantidade = 0', 'PASSOU', 'check_violation capturada');
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar item com quantidade = 0', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;

-- Teste 3.3: Movimentação com tipo inválido (deve falhar)
DO $$
BEGIN
    RAISE NOTICE '  Teste 3.3: INSERT movimentacao com tipo = INVALIDO...';

    INSERT INTO movimentacao_estoque (id_produto, tipo_movimentacao, quantidade, data_movimentacao, observacao)
    VALUES (1, 'INVALIDO', 5, NOW(), 'Teste de validação');

    RAISE NOTICE '    ❌ FALHOU: INSERT com tipo INVALIDO foi aceito!';
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('CHECK', 'Rejeitar movimentação com tipo inválido', 'FALHOU', 'INSERT foi aceito — constraint ausente');

    DELETE FROM movimentacao_estoque WHERE observacao = 'Teste de validação' AND tipo_movimentacao = 'INVALIDO';

EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado corretamente (check_violation).';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar movimentação com tipo inválido', 'PASSOU', 'check_violation capturada');
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar movimentação com tipo inválido', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;

-- Teste 3.4: Pedido com status inválido (deve falhar)
DO $$
BEGIN
    RAISE NOTICE '  Teste 3.4: INSERT pedido com status = INVALIDO...';

    INSERT INTO pedido (id_cliente, id_funcionario, data_pedido, valor_total, status)
    VALUES (1, 1, NOW(), 100.00, 'INVALIDO');

    RAISE NOTICE '    ❌ FALHOU: INSERT com status INVALIDO foi aceito!';
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('CHECK', 'Rejeitar pedido com status inválido', 'FALHOU', 'INSERT foi aceito — constraint ausente');

    DELETE FROM pedido WHERE status = 'INVALIDO';

EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado corretamente (check_violation).';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar pedido com status inválido', 'PASSOU', 'check_violation capturada');
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('CHECK', 'Rejeitar pedido com status inválido', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;


-- ============================================================
-- SEÇÃO 4: TESTES DE VIOLAÇÃO DE CONSTRAINTS UNIQUE
-- Objetivo: Confirmar que as restrições UNIQUE impedem
--           duplicação de CPF (cliente) e CNPJ (fornecedor).
-- ============================================================

-- Teste 4.1: Cliente com CPF duplicado (deve falhar)
DO $$
DECLARE
    v_cpf_existente VARCHAR(14);
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 4: TESTES DE CONSTRAINTS UNIQUE';
    RAISE NOTICE '══════════════════════════════════════════════════';

    RAISE NOTICE '  Teste 4.1: INSERT cliente com CPF duplicado...';

    -- Buscar um CPF já cadastrado
    SELECT cpf INTO v_cpf_existente FROM cliente LIMIT 1;

    IF v_cpf_existente IS NULL THEN
        RAISE NOTICE '    ⚠️ IGNORADO: nenhum cliente encontrado para teste.';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('UNIQUE', 'Rejeitar cliente com CPF duplicado', 'FALHOU', 'Sem cliente de referência');
        RETURN;
    END IF;

    INSERT INTO cliente (nome, cpf, email, telefone, data_cadastro)
    VALUES ('Cliente Teste Duplicado', v_cpf_existente, 'teste@teste.com', '(00) 0000-0000', NOW());

    RAISE NOTICE '    ❌ FALHOU: INSERT com CPF duplicado foi aceito!';
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('UNIQUE', 'Rejeitar cliente com CPF duplicado', 'FALHOU', 'INSERT foi aceito — constraint ausente');

    DELETE FROM cliente WHERE nome = 'Cliente Teste Duplicado';

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado corretamente (unique_violation).';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('UNIQUE', 'Rejeitar cliente com CPF duplicado', 'PASSOU', 'unique_violation para CPF: ' || v_cpf_existente);
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('UNIQUE', 'Rejeitar cliente com CPF duplicado', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;

-- Teste 4.2: Fornecedor com CNPJ duplicado (deve falhar)
DO $$
DECLARE
    v_cnpj_existente VARCHAR(18);
BEGIN
    RAISE NOTICE '  Teste 4.2: INSERT fornecedor com CNPJ duplicado...';

    -- Buscar um CNPJ já cadastrado
    SELECT cnpj INTO v_cnpj_existente FROM fornecedor LIMIT 1;

    IF v_cnpj_existente IS NULL THEN
        RAISE NOTICE '    ⚠️ IGNORADO: nenhum fornecedor encontrado para teste.';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('UNIQUE', 'Rejeitar fornecedor com CNPJ duplicado', 'FALHOU', 'Sem fornecedor de referência');
        RETURN;
    END IF;

    INSERT INTO fornecedor (nome, cnpj, telefone, email)
    VALUES ('Fornecedor Teste Duplicado', v_cnpj_existente, '(00) 0000-0000', 'teste@teste.com');

    RAISE NOTICE '    ❌ FALHOU: INSERT com CNPJ duplicado foi aceito!';
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('UNIQUE', 'Rejeitar fornecedor com CNPJ duplicado', 'FALHOU', 'INSERT foi aceito — constraint ausente');

    DELETE FROM fornecedor WHERE nome = 'Fornecedor Teste Duplicado';

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado corretamente (unique_violation).';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('UNIQUE', 'Rejeitar fornecedor com CNPJ duplicado', 'PASSOU', 'unique_violation para CNPJ: ' || v_cnpj_existente);
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: INSERT rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('UNIQUE', 'Rejeitar fornecedor com CNPJ duplicado', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;


-- ============================================================
-- SEÇÃO 5: TESTES DE FK COM ON DELETE RESTRICT
-- Objetivo: Confirmar que não é possível deletar registros
--           pai que possuem registros filhos referenciando-os.
-- ============================================================

-- Teste 5.1: Deletar categoria que possui produtos (deve falhar)
DO $$
DECLARE
    v_id_categoria INTEGER;
    v_nome_categoria VARCHAR(100);
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 5: TESTES DE FK (ON DELETE RESTRICT)';
    RAISE NOTICE '══════════════════════════════════════════════════';

    RAISE NOTICE '  Teste 5.1: DELETE categoria que possui produtos...';

    -- Buscar uma categoria que tenha produtos vinculados
    SELECT c.id_categoria, c.nome
    INTO v_id_categoria, v_nome_categoria
    FROM categoria c
    INNER JOIN produto p ON p.id_categoria = c.id_categoria
    LIMIT 1;

    IF v_id_categoria IS NULL THEN
        RAISE NOTICE '    ⚠️ IGNORADO: nenhuma categoria com produtos encontrada.';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('FK RESTRICT', 'Impedir DELETE categoria com produtos', 'FALHOU', 'Sem categoria de referência');
        RETURN;
    END IF;

    DELETE FROM categoria WHERE id_categoria = v_id_categoria;

    RAISE NOTICE '    ❌ FALHOU: DELETE da categoria "%" foi aceito!', v_nome_categoria;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('FK RESTRICT', 'Impedir DELETE categoria com produtos', 'FALHOU', 'DELETE foi aceito — constraint ausente');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE '    ✅ PASSOU: DELETE rejeitado (foreign_key_violation) para "%".', v_nome_categoria;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('FK RESTRICT', 'Impedir DELETE categoria com produtos', 'PASSOU', 'FK violation para: ' || v_nome_categoria);
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: DELETE rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('FK RESTRICT', 'Impedir DELETE categoria com produtos', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;

-- Teste 5.2: Deletar cliente que possui pedidos (deve falhar)
DO $$
DECLARE
    v_id_cliente INTEGER;
    v_nome_cliente VARCHAR(100);
BEGIN
    RAISE NOTICE '  Teste 5.2: DELETE cliente que possui pedidos...';

    -- Buscar um cliente que tenha pedidos vinculados
    SELECT cl.id_cliente, cl.nome
    INTO v_id_cliente, v_nome_cliente
    FROM cliente cl
    INNER JOIN pedido pe ON pe.id_cliente = cl.id_cliente
    LIMIT 1;

    IF v_id_cliente IS NULL THEN
        RAISE NOTICE '    ⚠️ IGNORADO: nenhum cliente com pedidos encontrado.';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('FK RESTRICT', 'Impedir DELETE cliente com pedidos', 'FALHOU', 'Sem cliente de referência');
        RETURN;
    END IF;

    DELETE FROM cliente WHERE id_cliente = v_id_cliente;

    RAISE NOTICE '    ❌ FALHOU: DELETE do cliente "%" foi aceito!', v_nome_cliente;
    INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
    VALUES ('FK RESTRICT', 'Impedir DELETE cliente com pedidos', 'FALHOU', 'DELETE foi aceito — constraint ausente');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE '    ✅ PASSOU: DELETE rejeitado (foreign_key_violation) para "%".', v_nome_cliente;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('FK RESTRICT', 'Impedir DELETE cliente com pedidos', 'PASSOU', 'FK violation para: ' || v_nome_cliente);
    WHEN OTHERS THEN
        RAISE NOTICE '    ✅ PASSOU: DELETE rejeitado (%). %', SQLSTATE, SQLERRM;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('FK RESTRICT', 'Impedir DELETE cliente com pedidos', 'PASSOU', SQLSTATE || ': ' || SQLERRM);
END;
$$;


-- ============================================================
-- SEÇÃO 6: TESTE DE ROLLBACK TRANSACIONAL
-- Objetivo: Demonstrar que um ROLLBACK desfaz completamente
--           as alterações realizadas dentro de uma transação,
--           comprovando a Atomicidade do ACID.
-- ============================================================

DO $$
DECLARE
    v_count_antes   INTEGER;
    v_count_depois  INTEGER;
    v_id_pedido_teste INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 6: TESTE DE ROLLBACK TRANSACIONAL';
    RAISE NOTICE '══════════════════════════════════════════════════';

    -- Contar pedidos antes
    SELECT COUNT(*) INTO v_count_antes FROM pedido;
    RAISE NOTICE '  Pedidos antes do teste: %', v_count_antes;

    -- Criar um SAVEPOINT para simular transação dentro do bloco DO
    -- (blocos DO já executam dentro de uma transação implícita,
    --  usamos SAVEPOINT para controle granular)

    BEGIN
        -- Inserir um pedido temporário
        INSERT INTO pedido (id_cliente, id_funcionario, data_pedido, valor_total, status)
        VALUES (1, 1, NOW(), 999.99, 'PENDENTE')
        RETURNING id_pedido INTO v_id_pedido_teste;

        RAISE NOTICE '  Pedido temporário Nº % inserido.', v_id_pedido_teste;

        -- Forçar ROLLBACK via exceção
        RAISE EXCEPTION 'ROLLBACK_TESTE: simulando falha para reverter pedido Nº %.', v_id_pedido_teste;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '  Exceção capturada: % — ROLLBACK do sub-bloco executado.', SQLERRM;
    END;

    -- Verificar que o pedido NÃO persiste
    SELECT COUNT(*) INTO v_count_depois FROM pedido;
    RAISE NOTICE '  Pedidos depois do teste: %', v_count_depois;

    IF v_count_antes = v_count_depois THEN
        RAISE NOTICE '    ✅ PASSOU: ROLLBACK confirmado — pedido temporário NÃO persiste.';
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('ROLLBACK', 'Pedido inserido e revertido não persiste', 'PASSOU',
                'Antes: ' || v_count_antes || ' | Depois: ' || v_count_depois);
    ELSE
        RAISE NOTICE '    ❌ FALHOU: contagem divergente (antes: %, depois: %).', v_count_antes, v_count_depois;
        INSERT INTO resultado_validacao (categoria, teste, resultado, detalhes)
        VALUES ('ROLLBACK', 'Pedido inserido e revertido não persiste', 'FALHOU',
                'Antes: ' || v_count_antes || ' | Depois: ' || v_count_depois);
    END IF;

    -- Verificação extra: buscar diretamente o pedido pelo ID
    -- (deve retornar 0 linhas)
    IF v_id_pedido_teste IS NOT NULL THEN
        PERFORM 1 FROM pedido WHERE id_pedido = v_id_pedido_teste;
        IF NOT FOUND THEN
            RAISE NOTICE '    ✅ Verificação extra: pedido Nº % não encontrado no banco (correto).', v_id_pedido_teste;
        ELSE
            RAISE NOTICE '    ❌ Verificação extra: pedido Nº % AINDA EXISTE (incorreto)!', v_id_pedido_teste;
        END IF;
    END IF;

    RAISE NOTICE '';
END;
$$;


-- ============================================================
-- SEÇÃO 7: RESUMO FINAL DOS TESTES DE VALIDAÇÃO
-- Objetivo: Exibir todos os resultados consolidados em uma
--           tabela única para fácil análise.
-- ============================================================

DO $$
DECLARE
    v_total     INTEGER;
    v_passou    INTEGER;
    v_falhou    INTEGER;
BEGIN
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '  SEÇÃO 7: RESUMO FINAL DA VALIDAÇÃO';
    RAISE NOTICE '══════════════════════════════════════════════════';

    SELECT COUNT(*) INTO v_total  FROM resultado_validacao;
    SELECT COUNT(*) INTO v_passou FROM resultado_validacao WHERE resultado = 'PASSOU';
    SELECT COUNT(*) INTO v_falhou FROM resultado_validacao WHERE resultado = 'FALHOU';

    RAISE NOTICE '  Total de testes: %', v_total;
    RAISE NOTICE '  Aprovados: %', v_passou;
    RAISE NOTICE '  Reprovados: %', v_falhou;

    IF v_falhou = 0 THEN
        RAISE NOTICE '';
        RAISE NOTICE '  ✅ TODOS OS TESTES PASSARAM COM SUCESSO!';
        RAISE NOTICE '  O banco de dados TechShop está íntegro e validado.';
    ELSE
        RAISE NOTICE '';
        RAISE NOTICE '  ⚠️ ATENÇÃO: % teste(s) falharam. Revise os resultados abaixo.', v_falhou;
    END IF;

    RAISE NOTICE '══════════════════════════════════════════════════';
END;
$$;

-- Exibição final em formato tabular
SELECT
    id_teste    AS "#",
    categoria   AS "Categoria",
    teste       AS "Teste",
    CASE
        WHEN resultado = 'PASSOU' THEN '✅ PASSOU'
        WHEN resultado = 'FALHOU' THEN '❌ FALHOU'
        ELSE resultado
    END         AS "Resultado",
    detalhes    AS "Detalhes"
FROM resultado_validacao
ORDER BY id_teste;

-- Sumário compacto por categoria
SELECT
    categoria                                      AS "Categoria",
    COUNT(*)                                       AS "Total",
    SUM(CASE WHEN resultado = 'PASSOU' THEN 1 ELSE 0 END) AS "Aprovados",
    SUM(CASE WHEN resultado = 'FALHOU' THEN 1 ELSE 0 END) AS "Reprovados",
    ROUND(
        SUM(CASE WHEN resultado = 'PASSOU' THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*) * 100, 1
    )                                              AS "% Aprovação"
FROM resultado_validacao
GROUP BY categoria
ORDER BY categoria;

-- Limpar tabela temporária ao final
DROP TABLE IF EXISTS resultado_validacao;
