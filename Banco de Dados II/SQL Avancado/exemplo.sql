--Discente: João Eduardo Pelegrini Ferrari
--Matrícula: 2211100012

--criando diretorio absoluto
sudo mkdir /space1
sudo mkdir /space2

--permissão ao postgres
sudo chown postgres.postgres /space1
sudo chown postgres.postgres /space2

--acesando o postgres
psql -h localhost -U postgres

--criando e acessando o banco de dados
CREATE DATABASE homework;
\c homework

--criando as duas tablespaces
CREATE TABLESPACE new_space
OWNER postgres
LOCATION '/space1';

CREATE TABLESPACE new_space2
OWNER postgres
LOCATION '/space2';

--criando os usuarios
CREATE USER first PASSWORD 'one';
CREATE USER second PASSWORD 'two';

--criando um banco de dados com a tablespace criada como padrão
CREATE DATABASE mywork tablespace new_space connection limit=5 TEMPLATE homework;

--acessando o banco criado
\c mywork

--criando o schema
CREATE SCHEMA schema1;

--apontando o esquema criado como padrão para um dos usuários
 ALTER USER first set search_path to schema1;

--alterando o dono do BD para um dos usuários criados e o esquema default para o recém criado
ALTER DATABASE mywork OWNER TO first;
SET SEARCH_PATH TO schema1;

--crie o script do banco de dados utilizado em aulas anteriores

CREATE TABLE product (					
	pid integer not null primary key,				
	name varchar(30) not null,					
	pqty  integer not null);

CREATE TABLE sale (
   sid integer not null primary key,
   sdate date not null,
   address VARCHAR(30) not null);
   
CREATE TABLE sale_item (
	sid integer not null,
	pid integer not null,
	sqty integer not null,
	CONSTRAINT pk_sale_item PRIMARY KEY (sid,pid),
	CONSTRAINT fk_sale_item_sale FOREIGN KEY (sid) REFERENCES sale(sid),
	CONSTRAINT fk_sale_item_product FOREIGN KEY (pid) REFERENCES product(pid)
);


create or replace procedure ins_product(qttup int ) Language plpgsql
as $$
declare
   prd_tup product%rowtype;
   counter int:=0;
   stock int[5]:='{3,5,8,10,15}';
begin
   raise notice 'Range ids: %',100*qttup;
   -- Or stock:=Array[3,5,8,10,15];
   loop
      prd_tup.pid:=(random()*100*qttup)::int;
      prd_tup.name:=left(MD5(random()::text),20);
      prd_tup.pqty:=stock[(random()*4)::int+1];
      raise notice 'product: %',prd_tup;
      if (not exists (select 1 from product where pid=prd_tup.pid))
      then
        insert into product (pid,name,pqty) values (prd_tup.pid,prd_tup.name,prd_tup.pqty);
        counter:=counter+1;
      end if;
      exit when counter >= qttup;
   end loop;
end; $$;

--
create or replace procedure ins_sale(qttup int ) Language plpgsql
as $$
declare
   sale_tup sale%rowtype;
   counter int:=0;
begin
   raise notice 'Range ids: %',100*qttup;
   loop
      sale_tup.sid:=(random()*100*qttup)::int;
      sale_tup.sdate:='2023-01-01 00:00:00'::timestamp + random()*(now()-timestamp '2023-01-01 00:00:00');
      raise notice 'Sale: %',sale_tup;
      sale_tup.address := left(MD5(random()::text),29);
      if (not exists (select 1 from sale where sid=sale_tup.sid))
      then
        insert into sale (sid,sdate, address) values (sale_tup.sid,sale_tup.sdate, sale_tup.address);
        counter:=counter+1;
      end if;
      exit when counter >= qttup;
   end loop;
end; $$;

create or replace procedure ins_sale_item (qttup int) language plpgsql
as $$
declare
    itBySale int[6]:='{2,4,7,8,9,10}';
    nprod int;
    counter_nprod int := 0;
    sale_item_tup sale_item%rowtype;
    array_prod int[];
    array_sale int[];
    qt_prod int;
    qt_sale int;
    counter int:=0;
begin

    select array_agg(pid) into array_prod from product;
    select count(pid) into qt_prod from product;

    select array_agg(sid) into array_sale from sale;
    select count(sid) into qt_sale from sale;

    nprod := itBySale[(random()*6)::int+1];


    -- executa qttup vezes
    loop
        -- seleciona um sid
        sale_item_tup.sid := array_sale[(random()*(qt_sale-1))::int+1];

        -- impede que tente inserir em uma sale ja existente
        --if (not exists(select 1 from sale_item where sid=sale_item_tup.sid))
        --    then

            --executa nprod vezes (vindo de itBySale)
            loop
                -- seleciona um pid e um sqty
                sale_item_tup.pid := array_prod[(random()*(qt_prod-1))::int+1];
                sale_item_tup.sqty := (random()*1000)::int;

                -- insere em sale item
                
                if (not exists (select 1 from sale_item where sid=sale_item_tup.sid and pid=sale_item_tup.pid))
                    then
                    insert into sale_item (sid, pid, sqty) values (sale_item_tup.sid, sale_item_tup.pid, sale_item_tup.sqty);
                    counter_nprod := counter_nprod + 1;
                    raise notice '%',counter_nprod;
                end if;

                exit when counter_nprod > nprod;
            end loop;

            counter := counter +1;

        --end if;

        exit when counter >= qttup;
    end loop;

end; $$;


--popule o BD com os scripts implementados em aulas anteriores (1000 produtos, 500 cupons, e +1000 produtos vendidos

CALL ns_products(1000);
CALL ins_sale(500);
CALL ins_sale_item(1000);

--crie uma trigger que armazene em uma tabela de auditoria todas as vezes que a quantidade vendida de um produto for alterada( ou venda de produto for excluida)

CREATE TABLE audit (
    operation VARCHAR(10) NOT NULL,
    old_value INTEGER NOT NULL,
    new_value INTEGER NOT NULL,
    user_name VARCHAR(50),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION write_audit() RETURNS TRIGGER AS
$write_audit$
BEGIN
IF (TG_OP = 'DELETE') THEN
INSERT INTO audit VALUES ('D', old.sqty, 0, CURRENT_USER, now());
RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
INSERT INTO audit VALUES ('U', old.sqty, new.sqty, CURRENT_USER, now());
RETURN NEW;
END IF;
END;
$write_audit$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER write_audit
AFTER UPDATE OR DELETE ON sale_item
FOR EACH ROW EXECUTE FUNCTION write_audit();

--crie um índice não único para a data da venda, neste índice, inclua o endereço.

CREATE INDEX index_sale_address ON sale (sdate, address);


--para o usuário não dono do BD, dê alguns privilégios: select em product e sale, todos para sale_item.

GRANT SELECT ON product TO second;
GRANT SELECT ON sale TO second;
GRANT ALL PRIVILEGES ON sale_item TO second;

