DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

drop table if exists empregado cascade;
create table empregado(
    id int primary key,
    nome varchar not null,
    salario float not null
);


drop table if exists auditoria cascade;
create table auditoria(
    id SERIAL,
    data_ timestamp not null,
    userid text not null,
    emp_nome_antigo varchar,
    emp_nome_novo varchar ,
    emp_salario_antigo float,
    emp_salario_novo float,
    alteracao character varying
);



CREATE OR REPLACE FUNCTION emp_audit() RETURNS TRIGGER AS $emp_audit$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO auditoria(data_, userid, emp_nome_antigo, emp_nome_novo, emp_salario_antigo, emp_salario_novo, alteracao) SELECT now(), user, OLD.nome, NEW.nome , OLD.salario, NEW.salario, TG_OP;
            RETURN OLD; 
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria(data_, userid, emp_nome_antigo, emp_nome_novo, emp_salario_antigo, emp_salario_novo, alteracao) SELECT now(), user, OLD.nome, NEW.nome , OLD.salario, NEW.salario, TG_OP;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria(data_, userid, emp_nome_antigo, emp_nome_novo, emp_salario_antigo, emp_salario_novo, alteracao) SELECT now(), user, OLD.nome, NEW.nome , OLD.salario , NEW.salario, TG_OP;
            RETURN NEW;
        END IF;
        RETURN NULL;
    END;
$emp_audit$ LANGUAGE plpgsql;

CREATE TRIGGER emp_audit AFTER INSERT OR UPDATE OR DELETE ON empregado FOR EACH ROW EXECUTE PROCEDURE emp_audit();


INSERT INTO empregado VALUES(1, 'michel', 200.50);
INSERT INTO empregado VALUES(2, 'pedro', 500.0);
INSERT INTO empregado VALUES(3, 'luiz', 1500.0);
INSERT INTO empregado VALUES(4, 'maria', 1000.20);
INSERT INTO empregado VALUES(5, 'julia', 750.75);

SELECT * FROM empregado;
SELECT * FROM auditoria;

UPDATE empregado SET salario = 100.0 WHERE id = 1;
UPDATE empregado SET salario = 10000.0 WHERE id = 2;

SELECT * FROM empregado;
SELECT * FROM auditoria;

DELETE FROM empregado WHERE id=3;
SELECT * FROM empregado;
SELECT * FROM auditoria;