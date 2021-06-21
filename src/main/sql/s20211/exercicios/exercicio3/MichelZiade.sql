--Apaga tables anteriores
DROP TABLE IF EXISTS mtzA CASCADE;
DROP TABLE IF EXISTS mtzB CASCADE;
DROP TABLE IF EXISTS mtzC CASCADE;

--Cria tables novas
CREATE TABLE mtzA(
    valor float[][]);

CREATE TABLE mtzB(
    valor float[][]);

CREATE TABLE mtzC(
    valor float[][]);

--Preenche tabelas
INSERT INTO mtzA (valor) VALUES (ARRAY[ [1,3,5], [2,4,6] ]);
INSERT INTO mtzB (valor) VALUES (ARRAY[ [1,4], [2,5], [3,6] ]);
INSERT INTO mtzC (valor) VALUES (ARRAY[ [1,1,1], [1,1,1], [1,1,1] ]);

--Funcao que multiplica matrizes
CREATE OR REPLACE FUNCTION multMtz(mtz1 float[][], mtz2 float[][]) RETURNS float[][] AS $$
    DECLARE
        mtzFinal float[][];
        lin1 integer;
        col1 integer;
        lin2 integer;
        col2 integer;
    BEGIN
        SELECT array_length(mtz1, 1) INTO lin1;
        SELECT array_length(mtz1, 2) INTO col1;
        SELECT array_length(mtz2, 1) INTO lin2;
        SELECT array_length(mtz2, 2) INTO col2;
        SELECT array_fill(0, ARRAY[lin1, col2]) INTO mtzFinal;

        IF col1 != lin2 THEN
            RAISE EXCEPTION 'Matrizes imcompativeis';
        ELSE
            FOR i IN 1.. lin1 LOOP
                FOR j IN 1.. col2 LOOP
                    FOR k IN 1.. lin2 LOOP
                        mtzFinal[i][j] := mtzFinal[i][j] + (mtz1[i][k] * mtz2[k][j]);
                    END LOOP;
                END LOOP;
            END LOOP;
        END IF;
        
        RETURN mtzFinal;
    END;
$$
LANGUAGE PLPGSQL;

SELECT multMtz (mtzA.valor, mtzB.valor) FROM mtzA, mtzB; --COMPATIVEL
SELECT multMtz (mtzB.valor, mtzC.valor) FROM mtzB, mtzC; --IMCOMPATIVEL