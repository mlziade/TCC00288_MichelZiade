DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

drop table if exists cidade cascade;
create table cidade(
numero int not null primary key,
nome varchar not null
);

drop table if exists bairro cascade;
create table bairro(
numero int not null primary key,
nome varchar not null,
cidade int not null,
foreign key (cidade) references cidade(numero)
);

drop table if exists pesquisa cascade;
create table pesquisa(
numero int not null,
descricao varchar not null,
primary key (numero)
);

drop table if exists pergunta cascade;
create table pergunta(
pesquisa int not null,
numero int not null,
descricao varchar not null,
primary key (pesquisa,numero),
foreign key (pesquisa) references pesquisa(numero)
);

drop table if exists resposta cascade;
create table resposta(
pesquisa int not null,
pergunta int not null,
numero int not null,
descricao varchar not null,
primary key (pesquisa,pergunta,numero),
foreign key (pesquisa,pergunta) references pergunta(pesquisa,numero)
);

drop table if exists entrevista cascade;
create table entrevista(
numero int not null primary key,
data_hora timestamp not null,
bairro int not null,
foreign key (bairro) references bairro(numero)
);

drop table if exists escolha cascade;
create table escolha(
entrevista int not null,
pesquisa int not null,
pergunta int not null,
resposta int not null,
primary key (entrevista,pesquisa,pergunta),
foreign key (entrevista) references entrevista(numero),
foreign key (pesquisa,pergunta,resposta) references resposta(pesquisa,pergunta,numero)
);

insert into cidade values (1,'Rio de Janeiro');
insert into cidade values (2,'Niterói');
insert into cidade values (3,'São Paulo');

insert into bairro values (1,'Tijuca',1);
insert into bairro values (2,'Centro',1);
insert into bairro values (3,'Lagoa',1);
insert into bairro values (4,'Icaraí',2);
insert into bairro values (5,'São Domingos',2);
insert into bairro values (6,'Santa Rosa',2);
insert into bairro values (7,'Moema',3);
insert into bairro values (8,'Jardim Paulista',3);
insert into bairro values (9,'Higienópolis',3);


insert into pesquisa values (1,'Pesquisa 1');

insert into pergunta values (1,1,'Pergunta 1');
insert into pergunta values (1,2,'Pergunta 2');
insert into pergunta values (1,3,'Pergunta 3');
insert into pergunta values (1,4,'Pergunta 4');

insert into resposta values (1,1,1,'Resposta 1 da pergunta 1');
insert into resposta values (1,1,2,'Resposta 2 da pergunta 1');
insert into resposta values (1,1,3,'Resposta 3 da pergunta 1');
insert into resposta values (1,1,4,'Resposta 4 da pergunta 1');
insert into resposta values (1,1,5,'Resposta 5 da pergunta 1');

insert into resposta values (1,2,1,'Resposta 1 da pergunta 2');
insert into resposta values (1,2,2,'Resposta 2 da pergunta 2');
insert into resposta values (1,2,3,'Resposta 3 da pergunta 2');
insert into resposta values (1,2,4,'Resposta 4 da pergunta 2');
insert into resposta values (1,2,5,'Resposta 5 da pergunta 2');
insert into resposta values (1,2,6,'Resposta 5 da pergunta 2');

insert into resposta values (1,3,1,'Resposta 1 da pergunta 3');
insert into resposta values (1,3,2,'Resposta 2 da pergunta 3');
insert into resposta values (1,3,3,'Resposta 3 da pergunta 3');

insert into resposta values (1,4,1,'Resposta 1 da pergunta 4');
insert into resposta values (1,4,2,'Resposta 2 da pergunta 4');

insert into entrevista values (1,'2020-03-01'::timestamp,1);
insert into escolha values (1,1,1,2);
insert into escolha values (1,1,2,2);
insert into escolha values (1,1,3,1);

insert into entrevista values (2,'2020-03-01'::timestamp,1);
insert into escolha values (2,1,1,3);
insert into escolha values (2,1,2,1);
insert into escolha values (2,1,3,2);

insert into entrevista values (3,'2020-03-01'::timestamp,1);
insert into escolha values (3,1,1,4);
insert into escolha values (3,1,2,1);
insert into escolha values (3,1,3,1);

insert into entrevista values (4,'2020-03-01'::timestamp,1);
insert into escolha values (4,1,1,2);
insert into escolha values (4,1,2,1);
insert into escolha values (4,1,3,1);

insert into entrevista values (5,'2020-03-01'::timestamp,1);
insert into escolha values (5,1,1,2);
insert into escolha values (5,1,2,1);
insert into escolha values (5,1,3,1);

CREATE OR REPLACE FUNCTION formata(pergunta_ int, respostas int[], totalRespostas int) RETURNS float[] AS $$
    DECLARE
        respostaFinal float[];
    BEGIN
        FOR i IN 1.. totalRespostas LOOP
            respostaFinal[i] = respostas[i]/totalRespostas;
        END LOOP;
        RETURN respostaFinal;
    END;
$$
LANGUAGE PLPGSQL;

--p_pesquisa é o identificador da pesquisa, p_bairros é uma lista de bairros, p_cidades é lista de cidades
--Se p_bairros ou p_cidades for null, considerar todas as cidades e bairros
CREATE OR REPLACE FUNCTION resultado(p_pesquisa int, p_bairros varchar[], p_cidades varchar[])
RETURNS TABLE(pergunta_ int, histograma float[])AS $$
    DECLARE
        cidades CURSOR FOR SELECT * FROM cidade WHERE numero = ANY(p_cidades);
        bairros CURSOR FOR SELECT * FROM bairro WHERE numero = ANY(p_bairros);
        perguntas CURSOR FOR SELECT * FROM pergunta WHERE pesquisa = p_pesquisa;
        qtdRespostas int default 0;
        respsPerguntaAux int[];
        escolhaAtual RECORD;
    BEGIN
        FOR perguntaAtual IN perguntas LOOP
            raise notice 'pergunta %', perguntaAtual.numero;
            SELECT COUNT(*) FROM resposta WHERE pesquisa = p_pesquisa AND pergunta = perguntaAtual.numero INTO qtdRespostas;
            raise notice 'qtdRespostas %', qtdRespostas;
            SELECT array_fill(0, ARRAY[0, qtdRespostas]) INTO respsPerguntaAux;
            FOR escolhaAtual IN (SELECT * FROM escolha WHERE pesquisa = p_pesquisa AND pergunta = perguntaAtual.numero AND entrevista IN (SELECT numero FROM entrevista WHERE bairro IN (SELECT numero FROM bairro WHERE nome = ANY(p_bairros)))) LOOP
                raise notice 'escolha %' escolhaAtual.resposta;
                respsPerguntaAux[escolhaAtual.resposta] := respsPerguntaAux[escolhaAtual.resposta] + escolhaAtual.resposta;
            END LOOP;
            RETURN QUERY SELECT perguntaAtual.numero, formata(perguntaAtual.numero, respsPerguntaAux, qtdRespostas);
        END LOOP;
        RETURN;
    END;
$$
LANGUAGE PLPGSQL;

SELECT * FROM resultado(1, ARRAY[ 'Tijuca', 'Centro', 'Lagoa', 'Icaraí', 'São Domingos', 'Santa Rosa', 'Moema', 'Jardim Paulista', 'Higienópolis'] ,ARRAY[ 'Rio de Janeiro', 'Niteroi', 'Sao Paulo']);
