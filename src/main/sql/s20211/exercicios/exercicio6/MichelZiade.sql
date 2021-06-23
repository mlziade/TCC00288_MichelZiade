--Funcao que substitui a linha por uma combinação linear
CREATE OR REPLACE FUNCTION combLinear(m int, n int, c1 int, c2 int, mtz float[][]) RETURNS float[][] AS $$
    DECLARE
        mtzAux float[];
        totalLin integer;
        totalCol integer;
        mn int[] := array[m, n];
        i int;
    BEGIN
        SELECT array_length(mtz, 1) INTO totalLin;
        SELECT array_length(mtz, 2) INTO totalCol;
        SELECT array_fill(0, ARRAY[totalCol]) INTO mtzAux;
    
        --SELECT ARRAY[]::float[] INTO mtzAux; --Cria vetor vazio
        FOREACH i IN ARRAY mn LOOP
            FOR j IN 1.. totalCol LOOP
                IF i = m THEN
                    mtzAux[j] = mtzAux[j] + c1 * mtz[i][j];
                ELSEIF i = n THEN
                    mtzAux[j] = mtzAux[j] + c2 * mtz[i][j];
                END IF;
            END LOOP;
        END LOOP;
        SELECT mtzAux into mtz[m];
        RETURN mtz;
END;
$$
LANGUAGE PLPGSQL;

SELECT combLinear(1, 2, 4, 5, ARRAY[ [1,2,3], [4,5,6], [7,8,9] ]::float[]);
                
        
        