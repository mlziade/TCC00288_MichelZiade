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
    (antena_dest) REFERENCES antena
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
        ligacoesParticipantes CURSOR FOR SELECT *  FROM ligacao WHERE inicio >= intervaloInicio AND fim <= intervaloFim UNION SELECT *  FROM ligacao WHERE inicio >= intervaloInicio AND fim <= intervaloFim;
        antenasParticipantes CURSOR FOR (SELECT antena_orig AS antenaPa, bairro_id, municipio_id FROM ligacao INNER JOIN antena ON antena.antena_id = ligacao.antena_orig WHERE inicio >= intervaloInicio AND fim <= intervaloFim  UNION SELECT antena_dest AS antenaPa, bairro_id, municipio_id FROM ligacao INNER JOIN antena ON antena.antena_id = ligacao.antena_dest WHERE inicio >= intervaloInicio AND fim <= intervaloFim );
        numLigacoes integer default 0;
        tempoMinutos float default 0;
        tempoAbsolutoLigacao interval;
        municipioAtual text;
        bairroAtual text;
        media float default 0;
    BEGIN
        FOR antena IN antenasParticipantes loop
          FOR ligacao IN ligacoesParticipantes loop
            IF ligacao.antena_orig = antena.antenaPa OR ligacao.antena_dest = antena.antenaPa THEN
                numLigacoes := numLigacoes + 1;
                tempoAbsolutoLigacao := ligacao.fim - ligacao.inicio;
                tempoMinutos := extract(minute from tempoAbsolutoLigacao);
                tempoMinutos := tempoMinutos + extract(second from tempoAbsolutoLigacao)/60;
                tempoMinutos := tempoMinutos + extract(hour from tempoAbsolutoLigacao)*60;
                tempoMinutos := tempoMinutos + extract(day from tempoAbsolutoLigacao)*24*60;
            END IF;
          END LOOP;
          SELECT nome FROM bairro WHERE bairro_id = antena.bairro_id INTO bairroAtual;
          SELECT nome FROM municipio WHERE municipio_id = antena.municipio_id INTO municipioAtual;
          media := round((tempoMinutos / numLigacoes)::numeric, 2);
          RETURN QUERY SELECT bairroAtual, municipioAtual, media;
          media := 0;
          numLigacoes := 0;
          tempoMinutos := 0;
        END LOOP;
        RETURN;
    END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION tabelaOrdenadaDeDuracaoMedia(intervaloInicio timestamp, intervaloFim timestamp)
    RETURNS TABLE(bairro TEXT, municipio TEXT, duracaoMedia float)
    AS $$
    DECLARE
        
    BEGIN
        RETURN QUERY SELECT * FROM chamadaMediaRegiao(intervaloInicio, intervaloFim) ORDER BY duracaoMedia DESC;
    END;
$$
LANGUAGE PLPGSQL;