
--SIBD-2425-G20-E2
--Gabriel Li 61790 TP14
--Gonçalo Wang 61828 TP14
--Jin Zhengrong 61808 TP14
--Luxia Liu 61834 TP14

--Contribuições:
--Gabriel 25%- a tabela de ficha de equipamento,usa,loja,insert
--Gonçalo 25%- a tabela de pessoa ,ficha de equipamento,cliente,insert
--Jin 25%- a tabela de empregado,equipamento,ficha de equipamento,insert
--Luxia 25%-  a tabela de fatura,equipamento,ficha de equipamento,insert
--fizemos sempre em presencial conjunto, cada um pensa e contribui para
--realização do projeto, e ajudando em toda parte do trabalho, as divisões são feitas de forma em geral, mas cada um
--também ajudou em partes que não foram referidas


---------------------------------------------------------------------

/*
RIAs nao implementaveis:
1. Um empregado num dia de semana só pode trabalhar numa loja.
2. O empregado que compra um equipamento a um cliente numa data e numa loja tem de trabalhar nessa loja nessa data.
3. O empregado que vende um ou mais equipamentos a um cliente numa data e numa loja tem de trabalhar nessa loja nessa data.
4. Um equipamento que conste na fatura emitida por uma loja tem de ter sido comprado por essa loja.
5. Empregado AND Cliente COVER Pessoa.
6. Empregado OVERLAPS Cliente.
7. A hora de abertura de uma loja num dia de semana tem de ser anterior à hora de fecho.
8. As horas de abertura e de fecho de uma loja têm de estar entre as 0h e as 23h59.
9. A data de nascimento de um empregado tem de ser 16 ou mais anos anterior à data atual.
10. O ano de lançamento numa ficha de equipamento tem de ser anterior ou igual ao ano atual.
11. A data de colocação na loja de um equipamento tem de ser posterior à data de compra desse equipamento a um cliente.
12. A data de uma fatura tem de ser posterior à data de colocação na loja de todos os equipamentos que nela constam.
18. As moradas vão do ID 1 em diante.
19. O nome de um dia de semana tem de ser segunda, terça, …, sexta, sábado, e domingo.
20. O tipo de dia de semana tem de ser dia útil ou fim de semana.
31. O preço de compra de um equipamento a um cliente tem de ser positivo.
*/

---------------------------------------------------------------------

DROP TABLE equipamento;
DROP TABLE fatura;
DROP TABLE cliente;
DROP TABLE empregado;
DROP TABLE pessoa;
DROP TABLE usa;
DROP TABLE loja;
DROP TABLE ficha_equipamento;

---------------------------------------------------------------------
CREATE TABLE ficha_equipamento (
    EAN              NUMBER (13),
    modelo           VARCHAR (20) CONSTRAINT nn_ficha_equipamento_modelo           NOT NULL,  
    marca            VARCHAR (20) CONSTRAINT nn_ficha_equipamento_marca            NOT NULL,
    tipo             VARCHAR (20) CONSTRAINT nn_ficha_equipamento_tipo             NOT NULL,
    ano_lancamento   NUMBER (4)   CONSTRAINT nn_ficha_equipamento_ano   NOT NULL,
    preco_lancamento NUMBER (6,2) CONSTRAINT nn_ficha_equipamento_preco NOT NULL,
--
    CONSTRAINT pk_ficha_equipamento 
        PRIMARY KEY (EAN),
--
    -- RIA29
    CONSTRAINT ck_ficha_equipamento_EAN
        CHECK (LENGTH(EAN) = 13 AND EAN > 0),
--
    -- RIA30
    CONSTRAINT ck_ficha_equipamento_preco
        CHECK (preco_lancamento > 0.00)
);

---------------------------------------------------------------------
CREATE TABLE loja (
    NIPC     NUMBER (9),
    nome     VARCHAR (20) CONSTRAINT nn_loja_nome     NOT NULL,
    telefone NUMBER (9)   CONSTRAINT nn_loja_telefone NOT NULL,
    email    VARCHAR (40) CONSTRAINT nn_loja_email    NOT NULL,
--
    CONSTRAINT pk_loja
        PRIMARY KEY (NIPC),
--
    -- RIA13
    CONSTRAINT ck_loja_NIPC
        CHECK (NIPC > 0 AND LENGTH(NIPC) = 9),
--
    -- RIA15
    CONSTRAINT ck_loja_telefone
        CHECK (LENGTH(telefone) = 9 AND telefone > 0),
--
    -- RIA16
    CONSTRAINT un_loja_telefone
        UNIQUE (telefone),
--
    -- RIA14
    CONSTRAINT un_loja_nome
        UNIQUE (nome),
--      
    -- RIA17
    CONSTRAINT un_loja_email
        UNIQUE (email)
);
---------------------------------------------------------------------
CREATE TABLE usa (
    loja,
    ficha_equipamento,
--
    CONSTRAINT pk_usa
        PRIMARY KEY (loja, ficha_equipamento),
    --
    CONSTRAINT fk_usa_loja
        FOREIGN KEY (loja) 
        REFERENCES loja (NIPC),
    --
    CONSTRAINT fk_usa_ficha_equipamento 
        FOREIGN KEY (ficha_equipamento) 
        REFERENCES ficha_equipamento (EAN)
);
---------------------------------------------------------------------
CREATE TABLE pessoa (
    NIF       NUMBER (9),
    nome      VARCHAR (30) CONSTRAINT nn_pessoa_nome      NOT NULL, 
    genero    VARCHAR (9),
    telemovel NUMBER (9)   CONSTRAINT nn_pessoa_telemovel NOT NULL,
--
    CONSTRAINT pk_pessoa
	    PRIMARY KEY (NIF),
--
    -- RIA21
    CONSTRAINT ck_pessoa_NIF
	    CHECK (NIF > 0 AND LENGTH(NIF) = 9),
--
    -- RIA22
    CONSTRAINT ck_pessoa_genero
        CHECK (genero IN ('feminino', 'masculino', NULL)),
--
    -- RIA23
    CONSTRAINT ck_pessoa_telemovel
	    CHECK (telemovel > 0 AND LENGTH(telemovel) = 9),
--             
    -- RIA24
    CONSTRAINT un_pessoa_telemovel
	    UNIQUE (telemovel)
);
-----------------------------------------------------------------------------
CREATE TABLE empregado (
    NIF,
    NIC             NUMBER (8),
    numero_interno  NUMBER (5),
    data_nascimento DATE,
--
    CONSTRAINT pk_empregado
	    PRIMARY KEY (NIF),
    --
    CONSTRAINT fk_empregado_NIF 
	    FOREIGN KEY (NIF) 
        REFERENCES pessoa(NIF)
        ON DELETE CASCADE,
--
    -- RIA25
    CONSTRAINT ck_empregado_NIC 
	    CHECK (LENGTH(NIC) = 8 AND NIC > 0),
--
    -- RIA26
    CONSTRAINT un_empregado_NIC
	    UNIQUE (NIC),
--  
    -- RIA27
    CONSTRAINT ck_empregado_numero_interno 
	    CHECK (LENGTH(numero_interno) = 5 AND numero_interno > 0),
--
    -- RIA28
    CONSTRAINT un_empregado_numero_interno
	    UNIQUE (numero_interno)
);

------------------------------------------------------------------------

CREATE TABLE cliente (
    NIF,
--
    CONSTRAINT pk_cliente
	    PRIMARY KEY (NIF),
    --
    CONSTRAINT fk_cliente_NIF
	    FOREIGN KEY (NIF)
        REFERENCES pessoa(NIF)
        ON DELETE CASCADE
);

------------------------------------------------------------------------
CREATE TABLE fatura (
    data              DATE   CONSTRAINT nn_fatura_data      NOT NULL,        
    numero_sequencial NUMBER(9),
    loja,
    empregado                CONSTRAINT nn_fatura_empregado NOT NULL,
    cliente                  CONSTRAINT nn_fatura_cliente   NOT NULL,
--
    CONSTRAINT pk_fatura
        PRIMARY KEY (loja, numero_sequencial),
    --
    CONSTRAINT fk_fatura_loja
        FOREIGN KEY (loja) 
        REFERENCES loja (NIPC)
        ON DELETE CASCADE,
    --
    CONSTRAINT fk_fatura_empregado
        FOREIGN KEY (empregado) 
        REFERENCES empregado (NIF),
    --
    CONSTRAINT fk_fatura_cliente
        FOREIGN KEY (cliente) 
        REFERENCES cliente (NIF),
--
    -- RIA35
    CONSTRAINT ck_numero_sequencial
        CHECK (numero_sequencial > 1)
);

---------------------------------------------------------------------

CREATE TABLE equipamento (
    numero_exemplar   NUMBER (9)    CONSTRAINT nn_equipamento_numero_exemplar NOT NULL,
    estado_consevacao VARCHAR (3)   CONSTRAINT nn_equipamento_estado_conserv  NOT NULL,
    preco_loja        NUMBER (6,2)  CONSTRAINT nn_equipamento_preco_loja      NOT NULL,
    data_loja         DATE          CONSTRAINT nn_equipamento_data_loja       NOT NULL,
    fatura,
    loja,
    ficha_equipamento,
--
    CONSTRAINT pk_equipamento
        PRIMARY KEY (loja, ficha_equipamento, numero_exemplar),
    --
    CONSTRAINT fk_equipamento_usa
        FOREIGN KEY (loja, ficha_equipamento) 
        REFERENCES usa (loja, ficha_equipamento) 
        ON DELETE CASCADE,
    --
    CONSTRAINT fk_equipamento_fatura
        FOREIGN KEY (numero_sequencial) 
        REFERENCES fatura (numero_sequencial),
--
    -- RIA32
    CONSTRAINT ck_equipamento_numero_exemplar
        CHECK (numero_exemplar > 0),
--
    -- RIA33
    CONSTRAINT ck_equipamento_estado_conserv
        CHECK (estado_consevacao IN ('bom', 'mau')),
--
    -- RIA34
    CONSTRAINT ck_equipamento_preco_loja
        CHECK (preco_loja > 0.00)
);

---------------------------------------------------------------------

INSERT INTO ficha_equipamento (EAN, modelo, marca, tipo, ano_lancamento, preco_lancamento) VALUES 
(1234567890123, 'NB', 'nice', 'calculadora', 6666, 888.00);
INSERT INTO ficha_equipamento (EAN, modelo, marca, tipo, ano_lancamento, preco_lancamento) VALUES 
(3210987654321, 'A', 'bad', 'coputador', 2000, 1000.10);
---------------------------------------------------------------------~

INSERT INTO loja (NIPC, nome, telefone, email) VALUES
(666888666, 'ai', 123456789, 'wozhenniu@gmail.com');
INSERT INTO loja (NIPC, nome, telefone, email) VALUES
(111222333, 'heihei', 987654321, 'nizhenniu@loja.com');
---------------------------------------------------------------------

INSERT INTO usa (loja, ficha_equipamento) VALUES 
(111222333, 3210987654321);
INSERT INTO usa (loja, ficha_equipamento) VALUES 
(666888666, 1234567890123);

---------------------------------------------------------------------

INSERT INTO pessoa (NIF,nome,genero,telemovel) VALUES
(666666666, 'haha', 'feminino', 999999999);
INSERT INTO pessoa (NIF,nome,genero,telemovel) VALUES
(999999999, 'hehe', 'masculino', 666666666);

---------------------------------------------------------------------

INSERT INTO empregado (NIF, NIC, numero_interno, data_nascimento) VALUES 
(999999999, 88888888, 66666, (TO_DATE('2024-01-20','YY-MM-DD')));
INSERT INTO empregado (NIF, NIC, numero_interno, data_nascimento) VALUES 
(666666666, 87888888, 66366, (TO_DATE('2024-06-20','YY-MM-DD'))); 

---------------------------------------------------------------------

INSERT INTO cliente (NIF) VALUES 
(999999999);
INSERT INTO cliente (NIF) VALUES
(666666666);

---------------------------------------------------------------------

INSERT INTO fatura(data, numero_sequencial) VALUES
((DATE '2024-11-05'), 88888888);
INSERT INTO fatura(data, numero_sequencial) VALUES
((DATE '2024-10-05'), 88868888);

---------------------------------------------------------------------

INSERT INTO equipamento (numero_exemplar, estado_consevacao, preco_loja, data_loja, loja, ficha_equipamento) VALUES 
(987654321, 'bom', 666, (TO_DATE('2021-01-20','YY-MM-DD')), 666888666, 1234567890123);
INSERT INTO equipamento (numero_exemplar, estado_consevacao, preco_loja, data_loja, loja, ficha_equipamento) VALUES
(987656321, 'bom', 676,(TO_DATE('2022-01-20','YY-MM-DD')), 111222333, 3210987654321);
