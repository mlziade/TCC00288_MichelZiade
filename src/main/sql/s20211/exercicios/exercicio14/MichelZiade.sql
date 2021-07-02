drop table if exists bairro cascade;
drop table if exists municipio cascade;
drop table if exists antena cascade;
drop table if exists ligacao cascade;

CREATE TABLE bairro (
    bairro_id integer NOT NULL,
    nome character varying NOT NULL,
    CONSTRAINT bairro_pk PRIMARY KEY
    (bairro_id)
);

CREATE TABLE municipio (
    municipio_id integer NOT NULL,
    nome character varying NOT NULL,
    CONSTRAINT municipio_pk PRIMARY KEY
    (municipio_id)
);

CREATE TABLE antena (
    antena_id integer NOT NULL,
    bairro_id integer NOT NULL,
    municipio_id integer NOT NULL,
    CONSTRAINT antena_pk PRIMARY KEY
    (antena_id),
    CONSTRAINT bairro_fk FOREIGN KEY
    (bairro_id) REFERENCES bairro
    (bairro_id),
    CONSTRAINT municipio_fk FOREIGN KEY
    (municipio_id) REFERENCES municipio
    (municipio_id)
);

CREATE TABLE ligacao (
    ligacao_id bigint NOT NULL,
    numero_orig integer NOT NULL,
    numero_dest integer NOT NULL,
    antena_orig integer NOT NULL,
    antena_dest integer NOT NULL,
    inicio timestamp NOT NULL,
    fim timestamp NOT NULL,
    CONSTRAINT ligacao_pk PRIMARY KEY
    (ligacao_id),
    CONSTRAINT antena_orig_fk FOREIGN KEY
    (antena_orig) REFERENCES antena
    (antena_id),
    CONSTRAINT antena_dest_fk FOREIGN KEY
    (numero_dest) REFERENCES antena
    (antena_id)
);

INSERT INTO municipio VALUES(1, 'Rio de Janeiro');
INSERT INTO municipio VALUES(2, 'Niteroi');
INSERT INTO municipio VALUES(3, 'São Paulo');

INSERT INTO bairro VALUES(1, 'Meier');
INSERT INTO bairro VALUES(2, 'Leblon');
INSERT INTO bairro VALUES(3, 'Tanque');
INSERT INTO bairro VALUES(4, 'Icarai');
INSERT INTO bairro VALUES(5, 'Gragoata');
INSERT INTO bairro VALUES(6, 'Itacoatiara');
INSERT INTO bairro VALUES(7, 'Paraiso');
INSERT INTO bairro VALUES(8, 'Pinheiros');
INSERT INTO bairro VALUES(9, 'Sé');

INSERT INTO antena VALUES(1, 1, 1);
INSERT INTO antena VALUES(2, 2, 1);
INSERT INTO antena VALUES(3, 3, 1);
INSERT INTO antena VALUES(4, 4, 2);
INSERT INTO antena VALUES(5, 5, 2);
INSERT INTO antena VALUES(6, 6, 2);
INSERT INTO antena VALUES(7, 7, 3);
INSERT INTO antena VALUES(8, 8, 3);
INSERT INTO antena VALUES(9, 9, 3);

CREATE OR REPLACE FUNCTION chamadaMediaRegiao(inicioIntervalo timestamp, fimIntervalo timestamp)
    RETURNS TABLE (bairro text, municipio text, duracaoM int) AS $$
    
    DECLARE
        totalTempoLigacoesRegiao float;
        totalLigacoesRegiao int;
        --Todas as ligações em um intervalo
        ligacoesIntervalo CURSOR FOR SELECT * FROM ligacao WHERE (inicio >= inicioIntervalo OR fim <= fimIntervalo);
        --Todas as antenas que participaram de uma ligação em um certo intervalo
        /* Projeção de ligação(antena_origem, antena_destino, inicio, fim) onde (incio >= inicioIntervalo e fim <= fimIntervalo)
        seguido de uma junção com condições (antena_origem ou antena_destino igual a antena_id)
        seguido de uma projeção da tabela resultante (antena_id, municipio_id, bairro_id)*/
        antenasIntervalo CURSOR FOR (SELECT antena_orig AS antenaPa, bairro_id, municipio_id FROM ligacao INNER JOIN antena ON antena.antena_id = ligacao.antena_orig WHERE inicio >= inicioIntervalo AND fim <= fimIntervalo  UNION SELECT antena_dest AS antenaPa, bairro_id, municipio_id FROM ligacao INNER JOIN antena ON antena.antena_id = ligacao.antena_dest WHERE inicio >= inicioIntervalo AND fim <= fimIntervalo );
    BEGIN
        --FOR ligacao in SELECT * FROM ligacoesIntervalo WHERE 
    
    END;
$$
LANGUAGE PLPGSQL;

