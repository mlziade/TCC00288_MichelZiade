--Apaga tables anteriores
DROP TABLE IF EXISTS mtz CASCADE;

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
        x integer;
        totalCol integer;
        det float;
    BEGIN
        SELECT array_length(m, 2) INTO totalCol;
        x=1;
        det = 0;

        IF totalCol > 0 THEN
            FOR y IN 1..totalCol LOOP
                IF ((x + y)%2 = 1) THEN
                    det := det + (m[x][y] * (-1) * determinante(apagaColLin(x, y, m)));
                ELSE
                    det := det + (m[x][y] * determinante(apagaColLin(x, y, m)));
                END IF;
            END LOOP;
        ELSE
            det := 1;
        END IF;
        RETURN det;
    END;
$$
LANGUAGE PLPGSQL;

SELECT determinante(ARRAY[ [1,2,3], [4,5,6], [7,8,9] ]);