DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

drop table if exists Produto cascade;
create table Produto(
    id int primary key not null,
    nome varchar,
    preco float not null,
    estoque int not null,
    estoqueMinimo int not null,
    estoqueMaximo int not null
);

drop table if exists Venda cascade;
create table Venda(
    id int primary key not null,
    data_ timestamp not null
);

drop table if exists ItemVenda cascade;
create table ItemVenda(
    venda int references Venda(id) not null, --referencia uma venda
    item int not null, --uma venda pode ter varios itens
    produto int references Produto(id) not null,
    qtd int not null,
    CONSTRAINT vendaUnica PRIMARY KEY
    (venda, item)
);

drop table if exists OrdemReposicao cascade;
create table OrdemReposicao(
    produto int primary key references Produto(id) not null,
    qtd int not null
);

--------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION validaVenda() RETURNS TRIGGER AS $validaVenda$
    DECLARE
        ProdutoAtual RECORD;
    BEGIN
        SELECT * FROM Produto WHERE id = NEW.produto INTO ProdutoAtual; --Recebe o produto que esta se vendendo
        IF (ProdutoAtual = NULL) THEN --Se nao existir este produto
            RAISE EXCEPTION 'Produto não existe';
        END IF;
        IF (NEW.qtd > ProdutoAtual.estoque) THEN --Se não tiver estoque suficiente
            RAISE EXCEPTION 'Estoque de % insuficiente', ProdutoAtual.nome;
        ELSIF (NEW.qtd <= ProdutoAtual.estoque) THEN --Se tiver estoque suficiente
            UPDATE Produto SET estoque = (ProdutoAtual.estoque - NEW.qtd) WHERE (NEW.produto = ProdutoAtual.id);
        END IF;
        RETURN NULL;
    END;
$validaVenda$
LANGUAGE plpgsql;

CREATE TRIGGER validaVenda
BEFORE INSERT ON ItemVenda FOR EACH ROW
EXECUTE PROCEDURE validaVenda();

CREATE OR REPLACE FUNCTION ordenarReposicao() RETURNS TRIGGER AS $ordenarReposicao$
    DECLARE
        ProdutoAtual RECORD;
        PedidosJaRealizados int;
    BEGIN
        SELECT * FROM Produto WHERE id = NEW.produto INTO ProdutoAtual; --Recebe o produto que acabou de ser vendido
        IF (ProdutoAtual.estoque < ProdutoAtual.estoqueMinimo) THEN --Se o estoque for menos que o estoque minimo
            SELECT COALESCE(SUM(qtd),0) AS PedidosJaRealizados FROM OrdemReposicao WHERE produto = ProdutoAtual.id; --Calcula o total de produtos que já foram ordenados para reposicao
            IF (ProdutoAtual.estoque + PedidosJaRealizados < ProdutoAtual.estoqueMaximo) THEN --Se o estoque atual mais os já ordenados forem menor que o estoque maximo
                INSERT INTO OrdemReposicao VALUES(ProdutoAtual.id, ProdutoAtual.estoqueMaximo - (ProdutoAtual.estoque + PedidosJaRealizados)); --Ordenar mais produtos ate o estoque maximo
            END IF;
        END IF;
        RETURN NULL;
    END;
$ordenarReposicao$
LANGUAGE plpgsql;

CREATE TRIGGER ordenarReposicao
AFTER INSERT ON ItemVenda FOR EACH ROW
EXECUTE PROCEDURE ordenarReposicao();



INSERT INTO produto VALUES (1, 'banana', 10.0, 10, 5, 50);
INSERT INTO produto VALUES (2, 'maca', 20.0, 10, 5, 50);
INSERT INTO produto VALUES (3, 'abacaxi', 30.0, 10, 5, 50);
INSERT INTO venda VALUES (1, '2021-07-06 12:00:01');
INSERT INTO venda VALUES (2, '2021-07-06 22:00:01');
INSERT INTO venda VALUES (3, '2021-07-07 12:00:01');

INSERT INTO OrdemReposicao VALUES (2,10);

INSERT INTO ItemVenda VALUES
(1, 1, 1, 1),
(1, 2, 2, 5),
(1, 3, 3, 5),
(1, 4, 1, 3),
(2, 1, 2, 3),
(2, 2, 1, 3),
(3, 1, 3, 3);