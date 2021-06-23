DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table pessoa(
name varchar,
endereco varchar
);

insert into pessoa values ('Michel', 'Avenida Rio Branco');
insert into pessoa values ('May', 'Rua dos Marijos');

select * from pessoa;
