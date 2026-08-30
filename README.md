E-Market — Sistema de Fluxo de Vendas

Sistema de banco de dados desenvolvido para o gerenciamento de clientes, produtos, categorias, pedidos e controle de estoque.

O projeto tem como objetivo aplicar conceitos fundamentais e avançados de bancos de dados relacionais utilizando SQL, incluindo modelagem, relacionamentos, consultas, procedimentos armazenados, funções, triggers e views.

Sobre o projeto

O e-Market representa a estrutura de um sistema de vendas, permitindo o gerenciamento das principais entidades envolvidas em um processo comercial.

O banco de dados contempla:

Clientes
Categorias
Produtos
Pedidos
Itens dos pedidos
Controle de estoque
Consultas e relatórios
Automação através de objetos programáveis

Além da estrutura das tabelas, o projeto utiliza recursos importantes do SQL para garantir integridade, consistência e organização dos dados.

Tecnologias utilizadas
MySQL
MariaDB
SQL
Estrutura do banco de dados

O banco de dados é composto por cinco tabelas principais:

CATEGORIAS
     │
     │ 1:N
     ▼
 PRODUTOS
     │
     │ N:N
     ▼
ITENS_PEDIDO
     ▲
     │
     │ 1:N
  PEDIDOS
     ▲
     │
     │ N:1
  CLIENTES
Tabelas
CATEGORIAS

Responsável pelo armazenamento das categorias dos produtos.

Campo	Descrição
id_categoria	Identificador da categoria
nome	Nome da categoria
descricao	Descrição da categoria
CLIENTES

Armazena as informações dos clientes cadastrados no sistema.

Campo	Descrição
id_cliente	Identificador do cliente
nome	Nome do cliente
email	E-mail do cliente
telefone	Telefone
endereco	Endereço
criado_em	Data de cadastro
ativo	Status do cliente

O campo de e-mail possui uma restrição de unicidade para evitar cadastros duplicados.

PRODUTOS

Responsável pelo armazenamento dos produtos disponíveis para venda.

Campo	Descrição
id_produto	Identificador do produto
nome	Nome do produto
descricao	Descrição do produto
preco	Preço
estoque	Quantidade disponível
id_categoria	Categoria do produto

O banco possui validações para impedir valores negativos relacionados ao preço e à quantidade disponível em estoque.

PEDIDOS

Armazena os pedidos realizados pelos clientes.

Campo	Descrição
id_pedido	Identificador do pedido
id_cliente	Cliente responsável pelo pedido
data_pedido	Data do pedido
status	Situação do pedido
total	Valor total

Os pedidos podem possuir diferentes status:

Aberto
Em andamento
Concluído
Cancelado
ITENS_PEDIDO

Tabela responsável por representar os produtos presentes em cada pedido.

Essa tabela resolve o relacionamento entre pedidos e produtos, permitindo que:

Um pedido possua vários produtos.
Um produto esteja presente em vários pedidos.
Campo	Descrição
id_item	Identificador do item
id_pedido	Pedido relacionado
id_produto	Produto relacionado
quantidade	Quantidade adquirida
preco_unitario	Preço do produto no momento da compra

O armazenamento do preço unitário permite manter o histórico correto das vendas, mesmo que o preço do produto seja alterado posteriormente.

Relacionamentos

O banco possui os seguintes relacionamentos:

CLIENTES 1 ─── N PEDIDOS

PEDIDOS 1 ─── N ITENS_PEDIDO

PRODUTOS 1 ─── N ITENS_PEDIDO

CATEGORIAS 1 ─── N PRODUTOS

A relação entre PEDIDOS e PRODUTOS é realizada através da tabela ITENS_PEDIDO.

Normalização

A estrutura do banco foi desenvolvida seguindo princípios de normalização.

Primeira Forma Normal (1FN)
Os atributos possuem valores atômicos.
Não existem grupos repetidos.
Segunda Forma Normal (2FN)
Os atributos dependem completamente da chave primária.
Terceira Forma Normal (3FN)
Não existem dependências transitivas desnecessárias.

A separação das categorias em uma tabela própria, por exemplo, evita a duplicação de informações dentro da tabela de produtos.

Recursos SQL utilizados
DDL — Data Definition Language

O projeto utiliza comandos para definição da estrutura do banco:

CREATE DATABASE
CREATE TABLE
ALTER TABLE
CREATE INDEX

Também foram implementados:

Primary Keys
Foreign Keys
Unique Constraints
Check Constraints
Índices
DML — Data Manipulation Language

O projeto utiliza comandos para manipulação dos dados:

INSERT
UPDATE
DELETE

Foram inseridos dados de exemplo para clientes, categorias, produtos, pedidos e itens dos pedidos.

Consultas SQL

O projeto inclui consultas utilizando diferentes recursos da linguagem SQL.

Filtros e ordenação
WHERE
BETWEEN
LIKE
IN
ORDER BY

Exemplo:

SELECT nome, preco, estoque
FROM PRODUTOS
WHERE preco BETWEEN 100 AND 500
ORDER BY preco ASC;
Funções de agregação

Também são utilizadas funções como:

COUNT()
SUM()
AVG()
MAX()

Essas consultas permitem obter informações como:

Quantidade de pedidos por cliente
Total gasto por cliente
Ticket médio
Quantidade de produtos por categoria
JOINs

O projeto utiliza diferentes tipos de JOIN para relacionar as tabelas.

INNER JOIN

Utilizado para consultar informações relacionadas entre:

Pedidos
Clientes
Itens do pedido
Produtos
LEFT JOIN

Utilizado para retornar todos os produtos, incluindo aqueles que ainda não possuem vendas associadas.

View

O projeto possui uma View chamada:

v_resumo_pedidos

Essa View permite consultar informações consolidadas sobre os pedidos realizados pelos clientes.

Entre as informações disponíveis estão:

Cliente
E-mail
Quantidade de pedidos
Valor total gasto
Último pedido realizado

Exemplo:

SELECT *
FROM v_resumo_pedidos
ORDER BY valor_total_gasto DESC;
Function

Foi implementada a função:

fn_calcula_desconto()

Sua finalidade é calcular o valor de um produto após a aplicação de um desconto percentual.

Exemplo:

SELECT
    nome,
    preco,
    fn_calcula_desconto(preco, 10) AS preco_com_desconto
FROM PRODUTOS;
Stored Procedure

O projeto possui uma Stored Procedure chamada:

sp_fechar_pedido()

Sua responsabilidade é realizar o processo de finalização de um pedido.

Entre as validações realizadas estão:

Verificar se o pedido existe.
Impedir que pedidos concluídos sejam processados novamente.
Impedir alterações em pedidos cancelados.
Atualizar o status do pedido.

Exemplo:

CALL sp_fechar_pedido(1);
Trigger

O projeto utiliza uma Trigger chamada:

trg_atualiza_estoque

A Trigger é responsável por automatizar o controle de estoque durante a inserção de itens em um pedido.

Suas principais responsabilidades são:

Verificar a disponibilidade do produto.
Impedir vendas com estoque insuficiente.
Atualizar automaticamente a quantidade disponível.

Esse mecanismo ajuda a garantir maior consistência e integridade dos dados.

Integridade referencial

O banco utiliza chaves estrangeiras para garantir a integridade dos relacionamentos entre as tabelas.

Principais relações:

CLIENTES → PEDIDOS

CATEGORIAS → PRODUTOS

PEDIDOS → ITENS_PEDIDO

PRODUTOS → ITENS_PEDIDO

Também são utilizadas regras como:

ON UPDATE CASCADE
ON DELETE CASCADE
ON DELETE RESTRICT
Índices

Foram criados índices para auxiliar no desempenho das consultas.

Exemplos:

idx_produtos_categoria

idx_pedidos_cliente

Esses índices são especialmente úteis para consultas que realizam relacionamentos frequentes entre as tabelas.
