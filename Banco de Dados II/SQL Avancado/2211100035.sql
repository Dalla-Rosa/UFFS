--SCRIPT PARA O TRABALHO DE SQL AVANÇADO
--BERNARDO FLORES DALLA ROSA
--2211100035





-- Professor, nao consegui arrumar para que o script rodasse de uma vez só dentro do psql da minha maquina (apartir dos comandos do psql) mas se copiar cada um dos comentarios separados ele ira funcionar








--Crie duas tablespaces (CMD)
--Acessar a pasta raiz: 
sudo mkdir tb01;
sudo mkdir tb02;

sudo chown postgres.postgres tb01 
sudo chown postgres.postgres tb02
   
psql -U postgres -h localhost
 	
create tablespace tb01 owner postgres location '/tb01'; 
create tablespace tb02 owner postgres location '/tb02'; 

--Crie dois usuários (PSQL)
create user bernardo password 'bernardo' superuser; 
create user pingu password 'pingu' superuser; 

--Crie um banco de dados utilizando uma das tablespaces criadas como default (procure na documentação as opções de create database) (PSQL)
create database mydb tablespace tb01;

--Acesse o banco criado
\c mydb;  
          
--Crie um esquema (PSQL)
create schema desenv; 

--Aponte o esquema criado como padrão para um dos usuários (PSQL)
alter user pingu set search_path to desenv;

--Altere o dono do BD para um dos usuários criados e o esquema default para o recém criado (procure na documentação as opções do alter database) (PSQL)
alter database mydb owner to pingu; 
set search_path to desenv; 
       
--Crie o script do banco de dados utilizado em aulas anteriores (produto x venda) - a tabela sales foi alterada (acerte o script) (PSQL)
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

    loop
        sale_item_tup.sid := array_sale[(random()*(qt_sale-1))::int+1];
            loop
                sale_item_tup.pid := array_prod[(random()*(qt_prod-1))::int+1];
                sale_item_tup.sqty := (random()*1000)::int;
                
                if (not exists (select 1 from sale_item where sid=sale_item_tup.sid and pid=sale_item_tup.pid))
                    then
                    insert into sale_item (sid, pid, sqty) values (sale_item_tup.sid, sale_item_tup.pid, sale_item_tup.sqty);
                    counter_nprod := counter_nprod + 1;
                    raise notice '%',counter_nprod;
                end if;

                exit when counter_nprod > nprod;
            end loop;

            counter := counter +1;

        exit when counter >= qttup;
    end loop;

end; $$;

--Popule o BD com os scripts implementados em sala de aula (1000 produtos, 500 cupons e +1000 produtos vendidos) - a tabela foi alterada, acerte o script (PSQL)
call ins_product(1000); 
call ins_sale(500); 
call ins_sale_item(1000); 

--Crie uma trigger que armazene em uma tabela de auditoria todas as vezes que a quantidade vendida de um produto for alterada (ou uma venda de produto for excluída). A tabela de auditoria deverá ter a operação, o valor antigo e novo (se for o caso), data e hora da operação e usuário. Esta tabela não tem PK (PSQL)    
create table audit(
opaudit varchar (8) not null,
old_qt_value integer not null,
new_qt_value integer not null,
user_name varchar(100),
op_audit_time timestamp,
);

-- old faz referencia ao estado anterior da linha afetada pela operação que acionou o trigger
-- new faz referencia ao novo estado da linha que foi afetada pela operação que acionou o trigger

create or replace function operation() returns trigger as $operation$
begin
   -- se a operação desejada for um update
   if tg-op = 'UPDATE' then
      -- insere na tabela os detalhes do update
      insert into audit(opaudit, old_qt_value, new_qt_value, user_name, op_audit_time) values ('UPDATE', old.sqty, new.sqty, CURRENT_USER, CURRENT_TIMESTAMP);
      return old;
   -- se a operação desejada for um delete
   elsif tg-op = 'DELETE'  then
      -- insere na table os detalhes do delete
      insert into audit (opaudit, old_qt_value, new_qt_value, user_name, op_audit_time) values ('DELETE', old.sqty, new.sqty, CURRENT_USER, CURRENT_TIMESTAMP);
      return new;
   end if;
end;
$operation$ language plpgsql;

create or replace trigger operation
after update or delete on sale_item	
for each row execute function operation();


--Crie um índice não único para a data da venda, neste índice, inclua o endereço. (PSQL)
create INDEX idx_sale_address on sale (sdate, address);

--Para o usuário não dono do BD, dê alguns privilégios: select em product e sale, todos para sale_item. (PSQL)

grant select on product to bernardo
grant select on sale to bernardo
grant all privileges on sale_item to bernardo;
