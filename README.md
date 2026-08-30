E-Market — Sistema de Fluxo de Vendas

Sistema de banco de dados relacional desenvolvido para gerenciar clientes, produtos, categorias, pedidos e estoque.

O projeto foi desenvolvido com foco na aplicação prática de conceitos fundamentais e avançados de SQL e modelagem de bancos de dados relacionais.

Principais Tecnologias e Conceitos

Este projeto aborda os seguintes conceitos:

Modelagem de Banco de Dados
Banco de Dados Relacional
SQL
DDL
DML
Primary Keys
Foreign Keys
Constraints
Integridade Referencial
Normalização
JOINs
Funções de Agregação
Views
Functions
Stored Procedures
Triggers
Índices
Controle de Estoque
Sobre o Projeto

O e-Market simula a estrutura de um sistema de vendas.

O banco permite o gerenciamento de:

Clientes
Categorias
Produtos
Pedidos
Itens dos Pedidos
Estoque

Além das operações básicas de cadastro e consulta, o projeto implementa recursos avançados do SQL para automatizar processos e garantir a consistência dos dados.

Estrutura do Banco de Dados

O banco de dados possui as seguintes entidades principais:

CLIENTES
    │
    │ 1:N
    ▼
PEDIDOS
    │
    │ 1:N
    ▼
ITENS_PEDIDO
    ▲
    │
    │ N:1
PRODUTOS
    ▲
    │
    │ N:1
CATEGORIAS
Relacionamentos
Tabela	Relacionamento
CLIENTES → PEDIDOS	Um cliente pode realizar vários pedidos
PEDIDOS → ITENS_PEDIDO	Um pedido pode possuir vários itens
PRODUTOS → ITENS_PEDIDO	Um produto pode estar presente em vários pedidos
CATEGORIAS → PRODUTOS	Uma categoria pode possuir vários produtos
Modelagem e Normalização

O banco foi estruturado utilizando princípios de normalização, buscando reduzir redundâncias e garantir maior organização dos dados.

Primeira Forma Normal — 1FN
Valores atômicos.
Ausência de grupos repetidos.
Segunda Forma Normal — 2FN
Os atributos dependem completamente da chave primária.
Terceira Forma Normal — 3FN
Redução de dependências transitivas.

A separação das categorias em uma tabela própria evita, por exemplo, a repetição das mesmas informações em diversos registros de produtos.

DDL — Estrutura do Banco

Foram utilizados comandos SQL para criação e configuração do banco de dados.

Principais comandos:

CREATE DATABASE
CREATE TABLE
ALTER TABLE
CREATE INDEX

Também foram implementados:

Chaves primárias
Chaves estrangeiras
Restrições de unicidade
Validações de dados
Índices
DML — Manipulação dos Dados

O projeto utiliza operações para inserção, atualização e remoção de dados.

INSERT
UPDATE
DELETE

Foram criados registros de exemplo para:

Clientes
Categorias
Produtos
Pedidos
Itens dos pedidos
Consultas SQL

O projeto implementa diferentes tipos de consultas para recuperação e análise dos dados.

Filtros e Ordenação
WHERE
BETWEEN
LIKE
IN
ORDER BY
Funções de Agregação
COUNT()
SUM()
AVG()
MAX()

Essas funções permitem gerar informações importantes como:

Total de pedidos por cliente
Total gasto por cliente
Ticket médio
Quantidade de produtos por categoria
JOINs

Os relacionamentos entre as tabelas são explorados através de JOINs.

INNER JOIN

Utilizado para relacionar informações de:

Clientes
Pedidos
Itens dos Pedidos
Produtos
LEFT JOIN

Utilizado para retornar todos os produtos, incluindo aqueles que ainda não possuem vendas registradas.

View

O projeto implementa a View:

v_resumo_pedidos

A View centraliza informações sobre os pedidos e clientes.

Entre os dados disponíveis estão:

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

A função permite calcular automaticamente o valor de um produto após a aplicação de um desconto percentual.

Exemplo:

SELECT
    nome,
    preco,
    fn_calcula_desconto(preco, 10) AS preco_com_desconto
FROM PRODUTOS;
Stored Procedure

O projeto possui a Stored Procedure:

sp_fechar_pedido()

Sua responsabilidade é realizar o processo de finalização de um pedido.

Principais validações:

Verificação da existência do pedido.
Prevenção de processamento duplicado.
Impedimento de alterações em pedidos cancelados.
Atualização do status do pedido.

Exemplo:

CALL sp_fechar_pedido(1);
Trigger e Controle de Estoque

Uma das principais funcionalidades do projeto é a automação do controle de estoque.

A Trigger:

trg_atualiza_estoque

É responsável por:

Verificar a disponibilidade do produto.
Impedir vendas com estoque insuficiente.
Atualizar automaticamente o estoque após a inclusão de itens.

Esse processo permite garantir maior consistência e integridade dos dados.

Integridade Referencial

O banco utiliza chaves estrangeiras para garantir que os relacionamentos entre as tabelas permaneçam consistentes.

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

Foram criados índices para auxiliar na otimização de consultas e relacionamentos frequentes.

Exemplos:

idx_produtos_categoria

idx_pedidos_cliente
Como Executar o Projeto
1. Clone o repositório
git clone <URL_DO_REPOSITORIO>
2. Abra uma ferramenta de gerenciamento

O projeto pode ser executado utilizando:

MySQL Workbench
DBeaver
phpMyAdmin
Terminal MySQL
3. Execute o script SQL

Execute o arquivo:

emarket DB.sql

O script criará toda a estrutura necessária para o funcionamento do banco de dados.

Estrutura do Projeto
e-Market/
│
├── emarket DB.sql
│
└── README.md


Autor
Hebert Rocha
Estudante de Ciência da Computação e desenvolvedor
