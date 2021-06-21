--Apaga tables anteriores
DROP TABLE IF EXISTS mtz CASCADE;

--Cria tables novas
CREATE TABLE mtz(
    valor float[][]);

--Preenche tabelas
INSERT INTO mtz (valor) VALUES (ARRAY[ [1,2,3], [4,5,6], [7,8,9] ]);

--Funcao que apaga linha e coluna
CREATE OR REPLACE FUNCTION apagaColLin(j int, i int, m float[][]) RETURNS float[][] AS $$
    DECLARE
        mtzAux float[];
        mtzFinal float[][];
        totalLin integer;
        totalCol integer;
    BEGIN
        SELECT array_length(m, 1) INTO totalLin;
        SELECT array_length(m, 2) INTO totalCol;

        FOR lin in 1.. totalLin LOOP
            IF lin <> i THEN --Se nao for a linha apagada
                SELECT ARRAY[]::float[] INTO mtzAux; --Cria vetor vazio
                FOR col in 1.. totalCol LOOP
                    IF col <> j THEN --Se nao for a coluna apagada
                        mtzAux = array_append(mtzAux, m[lin][col]); --Adiciona valores, que nao foram apagados pelo coluna, na linha
                    END IF;
                END LOOP;
                mtzFinal = array_cat(mtzFinal, mtzAux); --Adiciona a linha corrigida na matriz
            END IF;
        END LOOP;
        
        RETURN mtzFinal;
    END;
$$
LANGUAGE PLPGSQL;

--Funcao que acha determinante por La Place
DROP FUNCTION IF EXISTS determinante(m float[][]) CASCADE;
CREATE OR REPLACE FUNCTION determinante(m float[][]) RETURNS float AS $$
    DECLARE
        totalLin integer;
        totalCol integer;
        det float;
    BEGIN
        SELECT array_length(m, 1) INTO totalLin;
        SELECT array_length(m, 2) INTO totalCol;
        det = 0;

        IF totalLin = 1 THEN
            RETURN m[1][1];
        ELSE
            FOR j in 1.. totalCol LOOP
                det := m[1][j] * (power(-1, 1+j) * determinante(apagaColLin(1,j, m.valor))) ;
            END LOOP;

            RETURN det;
        END IF;
    END;
$$
LANGUAGE PLPGSQL;

SELECT determinante(mtz.valor) FROM mtz;