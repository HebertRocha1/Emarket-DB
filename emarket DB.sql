-- ============================================================
--  e-Market: Sistema Completo de Fluxo de Vendas
--  Compatível com MySQL 8+ / MariaDB 10.6+
-- ============================================================

-- ============================================================
--  FASE 2 — DDL: Criação da Estrutura
-- ============================================================

CREATE DATABASE IF NOT EXISTS emarket
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE emarket;

-- 1FN: cada coluna atômica, sem grupos repetidos
-- 2FN: todo atributo depende da PK completa
-- 3FN: sem dependências transitivas (ex: nome da categoria
--       fica em CATEGORIAS, não em PRODUTOS)

CREATE TABLE IF NOT EXISTS CATEGORIAS (
  id_categoria INT          NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(100) NOT NULL,
  descricao    TEXT,
  CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
  CONSTRAINT uq_cat_nome   UNIQUE (nome)
);

CREATE TABLE IF NOT EXISTS CLIENTES (
  id_cliente  INT          NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(150) NOT NULL,
  email       VARCHAR(150) NOT NULL,
  telefone    VARCHAR(20),
  endereco    TEXT,
  criado_em   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_clientes   PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cli_email  UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS PRODUTOS (
  id_produto   INT            NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(200)   NOT NULL,
  descricao    TEXT,
  preco        DECIMAL(10, 2) NOT NULL,
  estoque      INT            NOT NULL DEFAULT 0,
  id_categoria INT            NOT NULL,
  CONSTRAINT pk_produtos      PRIMARY KEY (id_produto),
  CONSTRAINT fk_prod_cat      FOREIGN KEY (id_categoria)
    REFERENCES CATEGORIAS (id_categoria)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_preco        CHECK (preco >= 0),
  CONSTRAINT chk_estoque      CHECK (estoque >= 0)
);

-- Status possíveis: Aberto | Em andamento | Concluído | Cancelado
CREATE TABLE IF NOT EXISTS PEDIDOS (
  id_pedido   INT            NOT NULL AUTO_INCREMENT,
  id_cliente  INT            NOT NULL,
  data_pedido TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status      VARCHAR(30)    NOT NULL DEFAULT 'Aberto',
  total       DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  CONSTRAINT pk_pedidos       PRIMARY KEY (id_pedido),
  CONSTRAINT fk_ped_cliente   FOREIGN KEY (id_cliente)
    REFERENCES CLIENTES (id_cliente)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_status       CHECK (status IN
    ('Aberto','Em andamento','Concluído','Cancelado'))
);

-- Tabela associativa N:N (Pedidos x Produtos) — resolve a cardinalidade
-- preco_unitario salvo no momento da compra (histórico real)
CREATE TABLE IF NOT EXISTS ITENS_PEDIDO (
  id_item        INT            NOT NULL AUTO_INCREMENT,
  id_pedido      INT            NOT NULL,
  id_produto     INT            NOT NULL,
  quantidade     INT            NOT NULL,
  preco_unitario DECIMAL(10, 2) NOT NULL,
  CONSTRAINT pk_itens           PRIMARY KEY (id_item),
  CONSTRAINT fk_item_pedido     FOREIGN KEY (id_pedido)
    REFERENCES PEDIDOS (id_pedido)
    ON DELETE CASCADE,
  CONSTRAINT fk_item_produto    FOREIGN KEY (id_produto)
    REFERENCES PRODUTOS (id_produto)
    ON DELETE RESTRICT,
  CONSTRAINT chk_qtd            CHECK (quantidade > 0)
);

-- ALTER TABLE — adição de coluna e índice (exemplo de manutenção DDL)
ALTER TABLE CLIENTES
  ADD COLUMN IF NOT EXISTS ativo TINYINT(1) NOT NULL DEFAULT 1;

CREATE INDEX IF NOT EXISTS idx_produtos_categoria
  ON PRODUTOS (id_categoria);

CREATE INDEX IF NOT EXISTS idx_pedidos_cliente
  ON PEDIDOS (id_cliente);


-- ============================================================
--  FASE 3 — DML: Inserção, Atualização e Remoção
-- ============================================================

-- INSERT --

INSERT INTO CATEGORIAS (nome, descricao) VALUES
  ('Eletrônicos',  'Smartphones, notebooks e acessórios tecnológicos'),
  ('Vestuário',    'Roupas, calçados e moda em geral'),
  ('Livros',       'Títulos físicos e digitais de todas as áreas'),
  ('Casa & Cozinha','Utensílios domésticos e decoração');

INSERT INTO CLIENTES (nome, email, telefone, endereco) VALUES
  ('Ana Souza',    'ana.souza@email.com',   '71 99001-1111',
   'Rua das Flores, 10, Salvador-BA'),
  ('Bruno Lima',   'bruno.lima@email.com',  '71 99002-2222',
   'Av. Paralela, 500, Salvador-BA'),
  ('Carla Mendes', 'carla.m@email.com',     '71 99003-3333',
   'Rua do Sol, 77, Lauro de Freitas-BA'),
  ('Diego Rocha',  'diego.r@email.com',     '71 99004-4444',
   'Alameda das Acácias, 22, Salvador-BA');

INSERT INTO PRODUTOS (nome, descricao, preco, estoque, id_categoria) VALUES
  ('Smartphone Galaxy S25', 'Android 15, 256 GB', 4299.90, 50, 1),
  ('Notebook UltraSlim X1', 'Intel Core i7, 16 GB RAM, SSD 512 GB', 5799.00, 20, 1),
  ('Fone Bluetooth Premium', 'Cancelamento de ruído ativo', 399.00, 200, 1),
  ('Camiseta Básica Premium','100% algodão, vários tamanhos', 59.90, 300, 2),
  ('Tênis Running Pro',      'Amortecimento avançado, Nº 40', 349.00, 80, 2),
  ('Clean Code',             'Robert C. Martin — Edição revisada', 89.90, 150, 3),
  ('Panela de Pressão 7L',   'Inox, tampa com válvula de segurança', 219.00, 60, 4);

INSERT INTO PEDIDOS (id_cliente, status) VALUES
  (1, 'Aberto'),
  (2, 'Em andamento'),
  (3, 'Aberto'),
  (1, 'Concluído');

INSERT INTO ITENS_PEDIDO (id_pedido, id_produto, quantidade, preco_unitario) VALUES
  (1, 1, 1, 4299.90),
  (1, 3, 2,  399.00),
  (2, 6, 3,   89.90),
  (2, 4, 5,   59.90),
  (3, 2, 1, 5799.00),
  (3, 7, 2,  219.00),
  (4, 5, 1,  349.00);

-- UPDATE --

-- Atualizar preço de um produto
UPDATE PRODUTOS
  SET preco = 3999.90
WHERE id_produto = 1;

-- Atualizar endereço de um cliente
UPDATE CLIENTES
  SET endereco = 'Rua Nova Esperança, 88, Salvador-BA'
WHERE id_cliente = 2;

-- Recalcular total dos pedidos (boa prática após inserts manuais)
UPDATE PEDIDOS p
  JOIN (
    SELECT id_pedido, SUM(quantidade * preco_unitario) AS soma
    FROM ITENS_PEDIDO
    GROUP BY id_pedido
  ) AS sub ON p.id_pedido = sub.id_pedido
SET p.total = sub.soma;

-- DELETE com cuidado de integridade referencial --

-- Cancelar um pedido (ITENS_PEDIDO usa ON DELETE CASCADE)
-- Primeiro mudamos o status; só excluímos se necessário
UPDATE PEDIDOS SET status = 'Cancelado' WHERE id_pedido = 3;

-- Remoção física do pedido cancelado (cascata remove os itens)
DELETE FROM PEDIDOS WHERE id_pedido = 3 AND status = 'Cancelado';


-- ============================================================
--  FASE 4 — SELECT: Extração de Inteligência
-- ============================================================

-- 4.1 Filtros e Ordenação

-- Produtos com preço entre R$100 e R$500, ordenados por preço
SELECT nome, preco, estoque
FROM PRODUTOS
WHERE preco BETWEEN 100 AND 500
ORDER BY preco ASC;

-- Clientes cujo nome começa com 'A' ou 'B'
SELECT nome, email
FROM CLIENTES
WHERE nome LIKE 'A%' OR nome LIKE 'B%'
ORDER BY nome;

-- Pedidos abertos ou em andamento
SELECT p.id_pedido, c.nome AS cliente, p.status, p.data_pedido
FROM PEDIDOS p
JOIN CLIENTES c ON p.id_cliente = c.id_cliente
WHERE p.status IN ('Aberto', 'Em andamento')
ORDER BY p.data_pedido DESC;

-- 4.2 Agregação

-- Total de pedidos por cliente
SELECT c.nome,
       COUNT(p.id_pedido)  AS qtd_pedidos,
       SUM(p.total)        AS gasto_total,
       AVG(p.total)        AS ticket_medio
FROM CLIENTES c
LEFT JOIN PEDIDOS p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY gasto_total DESC;

-- Categorias com mais de 1 produto cadastrado
SELECT cat.nome AS categoria, COUNT(prod.id_produto) AS total_produtos
FROM CATEGORIAS cat
JOIN PRODUTOS prod ON cat.id_categoria = prod.id_categoria
GROUP BY cat.id_categoria, cat.nome
HAVING COUNT(prod.id_produto) > 1
ORDER BY total_produtos DESC;

-- 4.3 INNER JOIN — pedidos com seus itens e produtos
SELECT p.id_pedido,
       c.nome        AS cliente,
       pr.nome       AS produto,
       ip.quantidade,
       ip.preco_unitario,
       (ip.quantidade * ip.preco_unitario) AS subtotal
FROM PEDIDOS p
INNER JOIN CLIENTES     c  ON p.id_cliente  = c.id_cliente
INNER JOIN ITENS_PEDIDO ip ON p.id_pedido   = ip.id_pedido
INNER JOIN PRODUTOS     pr ON ip.id_produto = pr.id_produto
ORDER BY p.id_pedido, pr.nome;

-- 4.4 LEFT JOIN — todos os produtos, mesmo os não vendidos
SELECT pr.nome          AS produto,
       cat.nome         AS categoria,
       pr.estoque,
       COUNT(ip.id_item) AS vezes_vendido
FROM PRODUTOS pr
LEFT JOIN CATEGORIAS    cat ON pr.id_categoria = cat.id_categoria
LEFT JOIN ITENS_PEDIDO  ip  ON pr.id_produto   = ip.id_produto
GROUP BY pr.id_produto, pr.nome, cat.nome, pr.estoque
ORDER BY vezes_vendido DESC;


-- ============================================================
--  FASE 5 — OBJETOS PROGRAMÁVEIS
-- ============================================================

-- 5.1 VIEW — Resumo de pedidos por cliente

CREATE OR REPLACE VIEW v_resumo_pedidos AS
SELECT
  c.id_cliente,
  c.nome                            AS cliente,
  c.email,
  COUNT(DISTINCT p.id_pedido)       AS total_pedidos,
  SUM(ip.quantidade * ip.preco_unitario) AS valor_total_gasto,
  MAX(p.data_pedido)                AS ultimo_pedido
FROM CLIENTES c
LEFT JOIN PEDIDOS      p  ON c.id_cliente  = p.id_cliente
LEFT JOIN ITENS_PEDIDO ip ON p.id_pedido   = ip.id_pedido
GROUP BY c.id_cliente, c.nome, c.email;

-- Uso da view (sem refazer o JOIN complexo):
-- SELECT * FROM v_resumo_pedidos ORDER BY valor_total_gasto DESC;


-- 5.2 FUNCTION — Calcula valor com desconto

DELIMITER $$

CREATE FUNCTION IF NOT EXISTS fn_calcula_desconto(
  p_valor       DECIMAL(10,2),
  p_porcentagem DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
COMMENT 'Retorna o valor após aplicar o desconto percentual'
BEGIN
  IF p_porcentagem < 0 OR p_porcentagem > 100 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Porcentagem deve estar entre 0 e 100';
  END IF;
  RETURN ROUND(p_valor * (1 - p_porcentagem / 100), 2);
END$$

DELIMITER ;

-- Uso da função em relatório de vendas:
-- SELECT nome, preco,
--        fn_calcula_desconto(preco, 10) AS preco_com_10pct_desconto
-- FROM PRODUTOS;


-- 5.3 STORED PROCEDURE — Fechar pedido

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS sp_fechar_pedido(
  IN p_id_pedido INT
)
BEGIN
  DECLARE v_status VARCHAR(30);

  -- Valida se o pedido existe
  SELECT status INTO v_status
  FROM PEDIDOS
  WHERE id_pedido = p_id_pedido;

  IF v_status IS NULL THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Pedido não encontrado.';
  END IF;

  -- Valida se já foi concluído ou cancelado
  IF v_status IN ('Concluído', 'Cancelado') THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Pedido já foi finalizado ou cancelado.';
  END IF;

  -- Muda o status para Concluído
  UPDATE PEDIDOS
    SET status = 'Concluído'
  WHERE id_pedido = p_id_pedido;

  SELECT CONCAT('Pedido #', p_id_pedido, ' fechado com sucesso.') AS mensagem;
END$$

DELIMITER ;

-- Uso da procedure:
-- CALL sp_fechar_pedido(1);


-- 5.4 TRIGGER — Atualização de estoque após venda

DELIMITER $$

CREATE TRIGGER IF NOT EXISTS trg_atualiza_estoque
BEFORE INSERT ON ITENS_PEDIDO
FOR EACH ROW
BEGIN
  DECLARE v_estoque_atual INT;

  -- Verifica estoque atual
  SELECT estoque INTO v_estoque_atual
  FROM PRODUTOS
  WHERE id_produto = NEW.id_produto;

  -- Impede estoque negativo
  IF v_estoque_atual < NEW.quantidade THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Estoque insuficiente para o produto solicitado.';
  END IF;

  -- Subtrai a quantidade vendida do estoque
  UPDATE PRODUTOS
    SET estoque = estoque - NEW.quantidade
  WHERE id_produto = NEW.id_produto;
END$$

DELIMITER ;

-- ============================================================
--  Limpeza / DROP (executar apenas se necessário)
-- ============================================================

-- DROP TRIGGER  IF EXISTS trg_atualiza_estoque;
-- DROP PROCEDURE IF EXISTS sp_fechar_pedido;
-- DROP FUNCTION  IF EXISTS fn_calcula_desconto;
-- DROP VIEW      IF EXISTS v_resumo_pedidos;
-- DROP TABLE     IF EXISTS ITENS_PEDIDO;
-- DROP TABLE     IF EXISTS PEDIDOS;
-- DROP TABLE     IF EXISTS PRODUTOS;
-- DROP TABLE     IF EXISTS CLIENTES;
-- DROP TABLE     IF EXISTS CATEGORIAS;
-- DROP DATABASE  IF EXISTS emarket;

-- ============================================================
--  FIM DO SCRIPT
-- ============================================================
