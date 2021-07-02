drop table if exists cliente cascade;
CREATE TABLE cliente (
    cpf integer NOT NULL,
    nome character varying NOT NULL,
    CONSTRAINT cliente_pk PRIMARY KEY
    (cpf)
);

drop table if exists conta cascade;
CREATE TABLE conta (
    agencia integer NOT NULL,
    numero integer NOT NULL,
    cliente integer NOT NULL,
    saldo real NOT NULL default 0,
    CONSTRAINT conta_pk PRIMARY KEY
    (agencia,numero),
    CONSTRAINT cliente_fk FOREIGN KEY
    (cliente) REFERENCES cliente (cpf)
);

drop table if exists movimentacao cascade;
CREATE TABLE movimentacao (
    agencia integer NOT NULL,
    conta integer NOT NULL,
    data_hora timestamp NOT NULL default
    current_timestamp,
    valor real NOT NULL,
    descricao character varying NOT NULL,
    CONSTRAINT mov_pk PRIMARY KEY
    (conta,agencia,data_hora),
    CONSTRAINT conta_fk FOREIGN KEY
    (agencia,conta) REFERENCES conta
    (agencia,numero)
);

INSERT INTO cliente VALUES(00000000001, 'Michel');
INSERT INTO cliente VALUES(00000000002, 'Luiz Andre');
INSERT INTO cliente VALUES(00000000003, 'Marcos');
INSERT INTO cliente VALUES(00000000004, 'Gabigol');

INSERT INTO conta VALUES(1, 1, 00000000001, 3500);
INSERT INTO conta VALUES(2, 1, 00000000002, 4000);
INSERT INTO conta VALUES(1, 2, 00000000003, 2000);
INSERT INTO conta VALUES(3, 1, 00000000004, 1000000);

INSERT INTO movimentacao VALUES(1, 1, '2021-07-02 07:00:00', 200, 'SAQUE');
INSERT INTO movimentacao VALUES(1, 1, '2021-07-02 08:00:00', 100, 'DEPOSITO');
INSERT INTO movimentacao VALUES(2, 1, '2021-07-02 09:00:00', 1000, 'SAQUE');
INSERT INTO movimentacao VALUES(2, 1, '2021-07-02 10:00:00', 500, 'DEPOSITO');
INSERT INTO movimentacao VALUES(1, 2, '2021-07-02 11:00:00', 2001, 'SAQUE');
INSERT INTO movimentacao VALUES(1, 2, '2021-07-02 12:00:00', 200, 'DEPOSITO');
INSERT INTO movimentacao VALUES(3, 1, '2021-07-02 13:00:00', 10000, 'SAQUE'); --Cassino do gabigol
INSERT INTO movimentacao VALUES(3, 1, '2021-07-02 14:00:00', 200000, 'DEPOSITO');

CREATE OR REPLACE FUNCTION atualizaConta() RETURNS VOID AS $$
    DECLARE
        operacoes CURSOR FOR SELECT * FROM movimentacao;
        contaAtual RECORD;
    BEGIN
        FOR operacao in operacoes LOOP
            SELECT * FROM conta WHERE (agencia = operacao.agencia AND numero = operacao.conta) INTO contaAtual;
                --IF contaAtual <> NULL THEN
                    RAISE NOTICE 'teste';
                    IF operacao.descricao = 'DEPOSITO' THEN
                        UPDATE conta SET saldo = (contaAtual.saldo + operacao.valor) WHERE (agencia = operacao.agencia AND numero = operacao.conta);
                    ELSEIF operacao.descricao = 'SALDO' THEN
                        IF contaAtual.saldo >= operacao.valor THEN
                            UPDATE conta SET saldo = (contaAtual.saldo - operacao.valor) WHERE (agencia = operacao.agencia AND numero = operacao.conta);
                        ELSEIF contaAtual.saldo < operacao.valor THEN
                            RAISE NOTICE 'SALDO INDISPONIVEL';
                        END IF;
                    END IF;
                --END IF;
        END LOOP;
        RETURN;
    END;
$$
LANGUAGE PLPGSQL;

SELECT * FROM conta;
SELECT atualizaConta();
SELECT * FROM conta;