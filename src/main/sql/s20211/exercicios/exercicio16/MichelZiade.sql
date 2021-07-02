DROP TABLE IF EXISTS produto CASCADE;
CREATE TABLE produto(
    id bigint not null,
    nome varchar not null
);

DROP TABLE IF EXISTS venda CASCADE;
CREATE TABLE venda(
    "data" timestamp not null,
    produto bigint not null,
    qtd integer not null
);

INSERT INTO produto VALUES(1, 'sapato');
INSERT INTO produto VALUES(2, 'blusa');
INSERT INTO produto VALUES(3, 'calça');
INSERT INTO produto VALUES(4, 'short');
INSERT INTO produto VALUES(5, 'casaco');

INSERT INTO venda VALUES('2021-01-02 12:00:00', 1, 3);
INSERT INTO venda VALUES('2021-01-02 13:00:00', 2, 4);
INSERT INTO venda VALUES('2021-01-02 12:00:00', 3, 2);
INSERT INTO venda VALUES('2021-01-02 12:00:00', 4, 5);
INSERT INTO venda VALUES('2021-01-02 13:00:00', 5, 7);
INSERT INTO venda VALUES('2021-02-02 13:00:00', 1, 8);
INSERT INTO venda VALUES('2021-02-02 14:00:00', 2, 1);
INSERT INTO venda VALUES('2021-02-02 15:00:00', 3, 5);
INSERT INTO venda VALUES('2021-02-02 13:00:00', 4, 15);
INSERT INTO venda VALUES('2021-02-02 14:00:00', 5, 3);
INSERT INTO venda VALUES('2021-03-02 12:00:00', 1, 6);
INSERT INTO venda VALUES('2021-03-02 12:00:00', 2, 4);
INSERT INTO venda VALUES('2021-03-02 12:00:00', 3, 9);
INSERT INTO venda VALUES('2021-03-02 12:00:00', 4, 10);

--Retorna inteiro com total de vendas de um certo produto num determinado mês
CREATE OR REPLACE FUNCTION totalVendasMesProduto(codigo bigint, mes float, ano float) RETURNS float AS $$
    DECLARE
        vendas CURSOR FOR SELECT * FROM venda WHERE (EXTRACT(YEAR FROM "data") = ano AND EXTRACT(MONTH FROM "data") = mes AND produto = codigo);
        qtdProdutoAtual int default 0;
    BEGIN
        FOR vendaAtual IN vendas LOOP
            IF vendaAtual.produto = codigo THEN
                qtdProdutoAtual := qtdProdutoAtual + vendaAtual.qtd;
            END IF;
        END LOOP;
        RETURN qtdProdutoAtual;
    END;
$$
LANGUAGE PLPGSQL;

--Retorna inteiro com mêdia de vendas de todos os produtos em um determinado mês
DROP FUNCTION mediaTodosProdutosMes(integer,integer);
CREATE OR REPLACE FUNCTION mediaTodosProdutosMes(mes int, ano int) RETURNS float AS $$
    DECLARE
        produtos CURSOR FOR SELECT * FROM produto;
        vendasMes CURSOR FOR SELECT * FROM venda;
        qtdProdutos int default 0;
        totalVendas int default 0;
        mediaVendas float default 0.0;
    BEGIN
        FOR produtoAtual in produtos LOOP
            totalVendas := totalVendas + totalVendasMesProduto(produtoAtual.id, mes, ano);
            qtdProdutos := qtdProdutos + 1;
        END LOOP;
        mediaVendas := totalVendas/qtdProdutos::float;
        RETURN mediaVendas;
    END;
$$
LANGUAGE PLPGSQL;

--Retorna tabela com bestSellers de cada mês
CREATE OR REPLACE FUNCTION bestSellersIntervalo(d1 timestamp, d2 timestamp) RETURNS TABLE(anomes bigint, lista varchar[]) AS $$
    DECLARE
        meses CURSOR FOR SELECT DISTINCT EXTRACT(month from data) AS mes, EXTRACT(year from data) AS ano FROM venda WHERE "data" <= d2 AND "data" >= d1;
        produtos CURSOR FOR SELECT * FROM produto;
        mediaMesAtual float default 0.0;
        listaBestSellerMesAtual varchar[];
        textoMesAnoAtual bigint;
    BEGIN
        RAISE NOTICE 'teste1';
        FOR mesAtual in meses LOOP
            textoMesAnoAtual := (mesAtual.ano*100 + mesAtual.mes)::bigint;
            RAISE NOTICE 'teste2';
            listaBestSellerMesAtual = '{}';
            mediaMesAtual = mediaTodosProdutosMes(mesAtual.mes, mesAtual.ano);
            FOR produtoAtual in produtos LOOP
                IF totalVendasMesProduto(produtoAtual.id, mesAtual.mes, mesAtual.ano) > (mediaMesAtual * 1.6) THEN
                    SELECT array_append(listaBestSellerMesAtual, produtoAtual.nome) INTO listaBestSellerMesAtual;
                END IF;
            END LOOP;
            RETURN QUERY SELECT textoMesAnoAtual, listaBestSellerMesAtual;
        END LOOP;
    RETURN;
    END;
$$
LANGUAGE PLPGSQL;

SELECT * FROM totalVendasMesProduto(1, 01, 2021);
SELECT * FROM mediaTodosProdutosMes(02, 2021);
SELECT * FROM bestSellersIntervalo('2021-01-02 12:00:00', '2021-03-02 12:00:00');