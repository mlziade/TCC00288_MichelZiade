drop table if exists cliente cascade;
create table cliente(
    id bigint primary key,
    titular bigint references cliente(id),
    nome varchar not null
);

--Procedimentos entre 22:00 e 23:59 são urgentes
drop table if exists procedimento cascade;
create table procedimento(
    id bigint primary key,
    nome varchar not null
);

drop table if exists atendimento cascade;
create table atendimento(
    id bigint primary key,
    "data" timestamp not null,
    proc bigint references procedimento(id)
    not null,
    cliente bigint not null
);

drop table if exists fato cascade;
create table fato(
    id bigint not null,
    "data" timestamp not null,
    procedimento bigint not null,
    qtd_vidas_contrato int not null,
    qtd_atend_urgencia int not null
);


INSERT INTO cliente VALUES(1, 1, 'eduardo');
INSERT INTO cliente VALUES(2, 1, 'michel');
INSERT INTO cliente VALUES(3, 1, 'maria');
INSERT INTO cliente VALUES(4, 1, 'claudia');
INSERT INTO cliente VALUES(5, 5, 'joao');
INSERT INTO cliente VALUES(6, 5, 'clara');
INSERT INTO cliente VALUES(7, 5, 'julia');


INSERT INTO procedimento VALUES(1, 'cirurgia');
INSERT INTO procedimento VALUES(2, 'teste de covid');
INSERT INTO procedimento VALUES(3, 'entubacao');
INSERT INTO procedimento VALUES(4, 'radiografia');
INSERT INTO procedimento VALUES(5, 'hemodialise');
INSERT INTO procedimento VALUES(6, 'ultrasom');
INSERT INTO procedimento VALUES(7, 'implante');


INSERT INTO atendimento VALUES(1, '2021-07-06 12:00:01', 1, 1);
INSERT INTO atendimento VALUES(2, '2021-07-06 22:00:01', 2, 1);
INSERT INTO atendimento VALUES(3, '2021-07-06 12:00:01', 3, 1);
INSERT INTO atendimento VALUES(4, '2021-07-06 22:00:01', 4, 1);
INSERT INTO atendimento VALUES(5, '2021-07-06 12:00:01', 5, 1);
INSERT INTO atendimento VALUES(6, '2021-07-06 22:00:01', 6, 1);
INSERT INTO atendimento VALUES(7, '2021-07-06 12:00:01', 7, 1);
INSERT INTO atendimento VALUES(8, '2021-07-06 12:00:01', 1, 1);
INSERT INTO atendimento VALUES(9, '2021-07-06 22:00:01', 2, 1);
INSERT INTO atendimento VALUES(10, '2021-07-06 12:00:01', 3, 2);
INSERT INTO atendimento VALUES(11, '2021-07-06 22:00:01', 4, 2);
INSERT INTO atendimento VALUES(12, '2021-07-06 22:00:01', 5, 2);
INSERT INTO atendimento VALUES(13, '2021-07-06 12:00:01', 6, 2);

CREATE OR REPLACE FUNCTION qtdAtendimentosEmergencia(IdCliente bigint) RETURNS integer AS $$
    DECLARE
        qtdTotal integer default 0;
    BEGIN
        SELECT COUNT(*) FROM atendimento WHERE cliente = IdCliente AND extract(hour from "data") >= 22 INTO qtdTotal;
        RETURN qtdTotal;
    END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION qtdDependentes(IdCliente bigint) RETURNS integer AS $$
    DECLARE
        qtdTotal integer default 0;
    BEGIN
        SELECT COUNT(*) FROM cliente WHERE titular = IdCliente INTO qtdTotal;
        --Um cliente que não tem propietario tem como propietario ele mesmo, logo nao faz sentido conta-lo
        RETURN qtdTotal - 1;
    END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION preencheTabelaFato() RETURNS VOID AS $$
    DECLARE
        clientes CURSOR FOR SELECT * FROM cliente;
        atendimentos CURSOR (IdCliente bigint) FOR SELECT * FROM atendimento WHERE cliente = IdCliente;
        qtdAtendimentosEmergencia integer default 0;
        qtdVidas integer default 0;
    BEGIN
        FOR clienteAtual IN clientes LOOP
            SELECT qtdAtendimentosEmergencia(clienteAtual.id) INTO qtdAtendimentosEmergencia;
            SELECT qtdDependentes(clienteAtual.titular) INTO qtdVidas;
            FOR atendimentoAtual IN atendimentos(clienteAtual.id) LOOP
                INSERT INTO fato VALUES(atendimentoAtual.id, atendimentoAtual."data", atendimentoAtual.proc, qtdVidas, qtdAtendimentosEmergencia);
            END LOOP;
            qtdAtendimentosEmergencia := 0;
            qtdVidas := 0;
        END LOOP;
        RETURN;
    END;
$$
LANGUAGE PLPGSQL;

SELECT preencheTabelaFato();
SELECT * FROM fato;
