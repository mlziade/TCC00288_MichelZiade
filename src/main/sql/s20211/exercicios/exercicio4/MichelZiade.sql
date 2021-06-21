--Apaga tables anteriores
DROP TABLE IF EXISTS mtz CASCADE;

--Cria tables novas
CREATE TABLE mtz(
    valor int[][]);

--Preenche tabelas
INSERT INTO mtz (valor) VALUES (ARRAY[ [1,2,3], [4,5,6], [7,8,9] ]);

--Funcao que apaga coluna e linha
CREATE OR REPLACE FUNCTION apagaColLin(j int, i int, m int[][]) RETURNS int[][] AS $$
    DECLARE
        mtzAux int[];
        mtzFinal int[][];
        totalLin integer;
        totalCol integer;
    BEGIN
        SELECT array_length(m, 1) INTO totalLin;
        SELECT array_length(m, 2) INTO totalCol;

        FOR lin in 1.. totalLin LOOP
            IF lin <> i THEN --Se nao for a linha apagada
                SELECT ARRAY[]::integer[] INTO mtzAux; --Cria vetor vazio
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

SELECT apagaColLin(2, 2, mtz.valor) FROM mtz;

