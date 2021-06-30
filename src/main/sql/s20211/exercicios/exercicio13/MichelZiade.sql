drop table if exists campeonato cascade;
drop table if exists jogo cascade;
drop table if exists time_ cascade;

--Campeonatos tem nome, ano e codigo (ChaveP codigo)
CREATE TABLE campeonato (
    codigo text NOT NULL,
    nome TEXT NOT NULL,
    ano integer not null,
    CONSTRAINT campeonato_pk PRIMARY KEY
    (codigo)
);

--Times tem nome e sigla (ChaveP sigla)
CREATE TABLE time_ (
    sigla text NOT NULL,
    nome TEXT NOT NULL,
    CONSTRAINT time_pk PRIMARY KEY
    (sigla)
);

--Jogos tem campeonato, numero, time1, time2, gols1, gols2 e data_ (ChaveP campeonato + numero)
CREATE TABLE jogo (
    campeonato text not null,
    numero integer NOT NULL,
    time1 text NOT NULL,
    time2 text NOT NULL,
    gols1 integer not null,
    gols2 integer not null,
    data_ date not null,
    CONSTRAINT jogo_pk PRIMARY KEY
    (campeonato,numero),
    CONSTRAINT jogo_campeonato_fk FOREIGN KEY
    (campeonato) REFERENCES campeonato
    (codigo),
    CONSTRAINT jogo_time_fk1 FOREIGN KEY
    (time1) REFERENCES time_ (sigla),
    CONSTRAINT jogo_time_fk2 FOREIGN KEY
    (time2) REFERENCES time_ (sigla)
);

--Insert campeonato
INSERT INTO campeonato VALUES ('CRC21', 'Campeonato Carioca 2021', 2021);

--Insert Times
INSERT INTO time_ VALUES ('Fla', 'Flamengo');
INSERT INTO time_ VALUES ('Vas', 'Vasco');
INSERT INTO time_ VALUES ('Flu', 'Fluminense');
INSERT INTO time_ VALUES ('Bot', 'Botafogo');

--Insert Jogos
INSERT INTO jogo VALUES ('CRC21', 2, 'Fla', 'Vas', 5, 0, '15/06/2021');
INSERT INTO jogo VALUES ('CRC21', 5, 'Flu', 'Bot', 2, 3, '18/06/2021');
INSERT INTO jogo VALUES ('CRC21', 3, 'Fla', 'Flu', 1, 1, '16/06/2021');
INSERT INTO jogo VALUES ('CRC21', 6, 'Vas', 'Bot', 0, 2, '19/06/2021');
INSERT INTO jogo VALUES ('CRC21', 4, 'Bot', 'Fla', 3, 1, '17/06/2021');
INSERT INTO jogo VALUES ('CRC21', 1, 'Flu', 'Vas', 4, 4, '14/06/2021');

--Recebe o codigo do campeonato, faz query dos times e jogos e retorna table não organizada
CREATE OR REPLACE FUNCTION computaJogos(codigo text)
    RETURNS TABLE(sigla text, pontuacao int, qtdJogos int, vits int, emps int, ders int, golsPro int, golsCon int, saldo int) AS $$
    
    DECLARE
    qtdJogosAux int;
    vitsAux int;
    dersAux int;
    empsAux int;
    golsProAux int;
    golsConAux int;
    timeAtual RECORD;
    partida RECORD;

    BEGIN
        FOR timeAtual in SELECT * FROM time_ LOOP --Query times
            qtdJogosAux = 0;
            vitsAux = 0;
            dersAux = 0;
            empsAux = 0;
            golsProAux = 0;
            golsConAux = 0;
            FOR partida IN SELECT * FROM jogo WHERE campeonato = codigo AND (time1 = timeAtual.sigla OR time2 = timeAtual.sigla) LOOP --Query jogos do timeAtual
                raise notice 'numero %', partida.numero;
                qtdJogosAux := qtdJogosAux + 1;
                IF partida.time1 <> timeAtual.sigla THEN --Se for time1
                    IF partida.gols1 > partida.gols2 THEN --Ganhou
                        vitsAux := vitsAux + 1;
                    ELSEIF partida.gols1 < partida.gols2 THEN --Perdeu
                        dersAux := dersAux + 1;
                    ELSEIF partida.gols1 = partida.gols2 THEN --Empatou
                        empsAux := empsAux + 1;
                    END IF;
                    golsProAux := golsProAux + partida.gols1;
                    golsConAux := golsConAux + partida.gols2;
                ELSEIF partida.time2 <> timeAtual.sigla THEN --Se for time2
                    IF partida.gols2 > partida.gols1 THEN --Ganhou
                        vitsAux := vitsAux + 1;
                    ELSEIF partida.gols2 < partida.gols1 THEN --Perdeu
                        dersAux := dersAux + 1;
                    ELSEIF partida.gols2 = partida.gols1 THEN --Empatou
                        empsAux := empsAux + 1;
                    END IF;
                    golsProAux := golsProAux + partida.gols2;
                    golsConAux := golsConAux + partida.gols1;
                END IF;
            END LOOP;
            RETURN QUERY SELECT timeAtual.nome, (vitsAux * 3 + empsAux), qtdJogosAux, vitsAux, empsAux, dersAux, golsProAux, golsConAux, (golsProAux - golsConAux);
        END LOOP;
        RETURN;
    END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION organizaTabela(codigo text, posInicial int, posFinal int)
    RETURNS TABLE(sigle text, pontuacao int, qtdJogos int, vits int, emps int, ders int, golsPro int, golsCon int, saldo int) AS $$

    BEGIN
        RETURN QUERY SELECT * FROM computaJogos(codigo) ORDER BY pontuacao DESC, vits DESC;
    END;
$$
LANGUAGE PLPGSQL;

SELECT * FROM organizaTabela('CRC21', 1, 4);
        