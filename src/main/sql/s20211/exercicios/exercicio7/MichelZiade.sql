DROP TABLE IF EXISTS matrizM CASCADE;

CREATE TABLE matrizM(
    valor float[][]
);

INSERT INTO matrizM VALUES ('{{9, 2}, {-5, 4}, {1, 7}}');

CREATE OR REPLACE FUNCTION transporMtz(mtz float[][]) RETURNS float[][] as $$
DECLARE
    linMtz integer;
    colMtz integer;
    linha float[];
    mtzFinal float[][];
BEGIN
    SELECT array_length(mtz, 1) INTO linMtz;
    SELECT array_length(mtz, 2)INTO colMtz;
    mtzFinal := array_fill(0, ARRAY[0,0]);
    FOR j IN 1..colMtz LOOP
        linha := '{}';
        FOR i IN 1..linMtz LOOP
            linha := array_append(linha, mtz[i][j]);
        END LOOP;
        mtzFinal := array_cat(mtzFinal, ARRAY[linha]);
    END LOOP;
    RETURN mtzFinal;
END 
$$ LANGUAGE plpgsql;

SELECT * FROM matrizM;

SELECT transporMtz(matrizM.valor) FROM matrizM;
