DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

drop table if exists produto cascade;
CREATE TABLE produto (
    codigo character varying NOT NULL,
    descricao character varying NOT NULL,
    preco float NOT NULL,
    CONSTRAINT produto_pk PRIMARY KEY
    (codigo)
);


INSERT INTO produto VALUES('A', 'CHOCOLATE', 5.0);
INSERT INTO produto VALUES('B', 'BALA', 1.0);
INSERT INTO produto VALUES('C', 'CHICLETE', 2.0);
INSERT INTO produto VALUES('D', 'SUSPIRO', 2.5);
INSERT INTO produto VALUES('E', 'JUJUBA', 4.0);
INSERT INTO produto VALUES('F', 'PACOCA', 1.5);
INSERT INTO produto VALUES('G', 'PIRULITO', 3.25);

CREATE OR REPLACE FUNCTION analisaPedido(produtos varchar[], quantidades int[]) RETURNS float as $$
    DECLARE
        total float default 0;
        precoAux float;
        tamanhoVets int;
        tabelaPrecos CURSOR FOR SELECT * FROM produto;
    BEGIN
        SELECT array_length(produtos, 1) INTO tamanhoVets;
        FOR i IN 1.. tamanhoVets LOOP
            SELECT preco FROM produto WHERE codigo = produtos[i] INTO precoAux;
            total := total + (quantidades[i] * precoAux);
        END LOOP;
        RETURN total;
    END;
$$
LANGUAGE PLPGSQL;

SELECT analisaPedido(ARRAY['A', 'B', 'C', 'F', 'G'], ARRAY[1, 2, 1, 10, 7]);