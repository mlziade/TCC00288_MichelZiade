DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE ATIVIDADE(
    id INT PRIMARY KEY,
    nome VARCHAR NOT NULL
);

CREATE TABLE ARTISTA(
    id INT PRIMARY KEY,
    nome VARCHAR NOT NULL,
    rua VARCHAR NOT NULL,
    cidade VARCHAR NOT NULL,
    estado VARCHAR NOT NULL,
    atividade INT NOT NULL,
    cep INT NOT NULL,
    CONSTRAINT artista_atividade_fk FOREIGN KEY
    (atividade) REFERENCES ATIVIDADE (id)
);

CREATE TABLE ARENA(
    id INT PRIMARY KEY,
    nome VARCHAR NOT NULL,
    cidade VARCHAR NOT NULL,
    capacidade INT NULL
);

CREATE TABLE CONCERTO(
    id INT PRIMARY KEY,
    artista_id INT NOT NULL,
    arena_id INT NOT NULL,
    inicio TIMESTAMP NOT NULL,
    fim TIMESTAMP NOT NULL,
    preco FLOAT NOT NULL,
    CONSTRAINT concerto_artista_fk FOREIGN KEY
    (artista_id) REFERENCES ARTISTA (id),
    CONSTRAINT concerto_arena_fk FOREIGN KEY
    (arena_id) REFERENCES ARENA (id)
);

INSERT INTO ATIVIDADE VALUES (1, 'musica classica'), (2, 'dança'), (3, 'exposicao artistica'), (4, 'show');
INSERT INTO ARTISTA VALUES (
1, 'michel', 'rua A', 'cidadeA', 'estadoA', 1, 1), (
2, 'maria', 'rua B', 'cidadeA', 'estadoA', 2, 2), (
3, 'joao', 'rua C', 'cidadeB', 'estadoB', 3, 3),(
4, 'luiz', 'rua D', 'cidadeB', 'estadoB', 4, 4),(
5, 'carlos', 'rua E', 'cidadeB', 'estadoB', 4, 5);

INSERT INTO ARENA VALUES (1, 'arenaA', 'cidadeA', 15000), (2, 'arenaB', 'cidadeA', 10000),(3, 'arenaC', 'cidadeB', 5000),(4, 'arenaD', 'cidadeB', 3000);

CREATE OR REPLACE FUNCTION garante_nao_sobreposicao_de_concerto() RETURNS TRIGGER AS $garante_nao_sobreposicao_de_concerto$
    DECLARE
        concertoAtual RECORD;
    BEGIN
        --Loop entre os concertos com a mesma arena
        FOR concertoAtual IN SELECT * FROM CONCERTO WHERE arena_id = NEW.arena_id LOOP
            --Verifica se arena esta ocupada
            IF NEW.inicio >= concertoAtual.inicio OR NEW.inicio <= concertoAtual.inicio THEN
                RAISE NOTICE 'CONCERTO "%" DO ARTISTA "%" JA ESTA MARCADO NESTA DATA', concertoAtual.id, concertoAtual.artista_id;
            END IF;
        END LOOP;
        
        --Loop entre os concertos com o mesmo artista
        FOR concertoAtual IN SELECT * FROM CONCERTO WHERE artista_id = NEW.artista_id LOOP
            --Verifica se artista esta ocupado
            IF NEW.inicio >= concertoAtual.inicio OR NEW.inicio <= concertoAtual.inicio THEN
                RAISE NOTICE 'CONCERTO "%" DO ARTISTA "%" JA ESTA MARCADO NESTA DATA', concertoAtual.id, concertoAtual.artista_id;
            END IF;
        END LOOP;
        RETURN NEW;
    END;
$garante_nao_sobreposicao_de_concerto$ LANGUAGE plpgsql;

CREATE TRIGGER garante_nao_sobreposicao_de_concerto BEFORE INSERT OR UPDATE ON CONCERTO FOR EACH ROW EXECUTE PROCEDURE garante_nao_sobreposicao_de_concerto();

INSERT INTO CONCERTO VALUES (1, 4, 4, '2021-09-11'::timestamp, '2021-09-11'::timestamp, 200.0);

INSERT INTO CONCERTO VALUES (1, 4, 2, '2021-09-11'::timestamp, '2021-09-11'::timestamp, 200.0);

INSERT INTO CONCERTO VALUES (2, 3, 3, '2021-09-11'::timestamp, '2021-09-11'::timestamp, 200.0);

INSERT INTO CONCERTO VALUES (2, 5, 3, '2021-09-11'::timestamp, '2021-09-11'::timestamp, 200.0);

CREATE OR REPLACE FUNCTION garante_atividade_nao_vazia() RETURNS TRIGGER AS $garante_atividade_nao_vazia$
    DECLARE
        artistaAtual RECORD;
        qtdArtistasAtividade INTEGER DEFAULT 0;
     BEGIN
        SELECT COUNT(*) FROM ARTISTA WHERE ATIVIDADE = OLD.atividade INTO qtdArtistasAtividade;
        IF qtdArtistasAtividade = 1 THEN
            RAISE EXCEPTION 'NAO FOI POSSIVEL RETIRAR ARTISTA, APENAS 1 SOBRANDO';
        END IF;

        RETURN OLD;
    END;
$garante_atividade_nao_vazia$ LANGUAGE plpgsql;

CREATE TRIGGER garante_atividade_nao_vazia BEFORE DELETE OR UPDATE ON ARTISTA FOR EACH ROW EXECUTE PROCEDURE garante_atividade_nao_vazia();

INSERT INTO ARTISTA VALUES (6, 'teste', 'rua F', 'cidadeA', 'estadoA', 1, 1);

DELETE FROM ARTISTA WHERE id=1;

DELETE FROM ARTISTA WHERE id = 2;

SELECT * FROM ARTISTA;