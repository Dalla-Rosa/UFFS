--   1. Crie duas tablespaces
--      Acessar a pasta raiz: cd /
	sudo mkdir mytbs (CMD)
	cd mytbs (CMD)
	sudo mkdir tb01 (CMD)
	sudo mkdir tb02 (CMD)
	sudo chown postgres.postgres mytbs 
	sudo chown postgres.postgres tb01 
	sudo chown postgres.postgres tb02 
	create tablespace tb01 location 'mytbs/tb01'; 
	create tablespace tb02 location 'mytbs/tb02'; 

--   2. Crie dois usuários
	create user bernardo password 'bernardo1' superuser; (PSQL)
	create user pingu password 'pingu' login superuser; (PSQL)

--   3. Crie um esquema
       create schema desenv; (PSQL)
       
    4. Aponte o esquema criado como padrão para um dos usuários
	grant usage on schema desenv to pingu; (PSQL)

    5. Crie um banco de dados utilizando uma das tablespaces criadas como default (procure na documentação as opções de create database)
	create database mydb tablespace tb01; (PSQL)

    6. Acesse o banco criado
       \c mydb; (PSQL)
       
       
    7. Altere o dono do BD para um dos usuários criados e o esquema default para o recém criado (procure na documentação as opções do alter database)
       alter database mydb owner pingu; (PSQL)
       alter database mydb set search_path = desenv; (PSQL)
       
    8. Crie o script do banco de dados utilizado em aulas anteriores (produto x venda) - a tabela sales foi alterada (acerte o script)
       
    9. Popule o BD com os scripts implementados em sala de aula (1000 produtos, 500 cupons e +1000 produtos vendidos) - a tabela foi alterada, acerte o script
       call ins_product(1000); (PSQL)
       call ins_sale(500); (PSQL)
       call ins_sale_item(1000); (PSQL)

    10. Crie uma trigger que armazene em uma tabela de auditoria todas as vezes que a quantidade vendida de um produto for alterada (ou uma venda de produto for excluída). A tabela de auditoria deverá ter a operação, o valor antigo e novo (se for o caso), data e hora da operação e usuário. Esta tabela não tem PK
       
	create table audit(
	opaudit varchar (8) not null,
	old_qt_value integer not null,
	new_qt_value integer not null,
	user_name varchar(100),
	op_audit_time timestamp,
	);

	create or replace function operation

	CRIAR A TABELA AUDIT, n PRECISA DE CHAVE PRIMARIA, TG_OP

    11.  Crie um índice não único para a data da venda, neste índice, inclua o endereço.
       
    12. Para o usuário não dono do BD, dê alguns privilégios: select em product e sale, todos para sale_item.



-- Aluno: Bernardo Flores Dalla Rosa
-- Matricula: 2211100035

-- Atividades - Objetos PostgreSQL

-- Crie duas tablespaces (CMD)
	sudo mkdir mytbs 
	cd mytbs 
	sudo mkdir tb01 
	sudo mkdir tb02
	
-- Permissoes para o postgres.
	sudo chown postgres.postgres mytbs 
	sudo chown postgres.postgres tb01
	sudo chown postgres.postgres tb02
	
-- Crie duas tablespaces (PSQL) 
	create tablespace tb01 location 'mytbs/tb01'; 
	create tablespace tb02 location 'mytbs/tb02'; 
	
-- Crie dois usuários (PSQL)
	create user bernardo password 'bernardo1' superuser; 
	create user pingu password 'pingu' login superuser; 
	
-- Aponte o esquema criado como padrão para um dos usuários (PSQL)
	create schema desenv; 
	grant usage on schema desenv to pingu; 

Crie um banco de dados utilizando uma das tablespaces criadas como default (procure na documentação as opções de create database)

Acesse o banco criado
	\c postgres pingu; 
Crie um esquema
	create schema desenv; 
Altere o dono do BD para um dos usuários criados e o esquema default para o recém criado (procure na documentação as opções do alter database)
	alter database
	set search_path to desenv; (PSQL)
Crie o script do banco de dados utilizado em aulas anteriores (produto x venda) - a tabela sales foi alterada (acerte o script)
Popule o BD com os scripts implementados em sala de aula (1000 produtos, 500 cupons e +1000 produtos vendidos) - a tabela foi alterada, acerte o script
Crie uma trigger que armazene em uma tabela de auditoria todas as vezes que a quantidade vendida de um produto for alterada (ou uma venda de produto for excluída). A tabela de auditoria deverá ter a operação, o valor antigo e novo (se for o caso), data e hora da operação e usuário. Esta tabela não tem PK
 Crie um índice não único para a data da venda, neste índice, inclua o endereço.
Para o usuário não dono do BD, dê alguns privilégios: select em product e sale, todos para sale_item.



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
        sale_item_tup.sid := array_sale[(random()*qt_sale)::int+1];

        -- impede que tente inserir em uma sale ja existente
        if (not exists(select 1 from sale_item where sid=sale_item_tup.sid))
            then

            --executa nprod vezes (vindo de itBySale)
            loop
                -- seleciona um pid e um sqty
                sale_item_tup.pid := array_prod[(random()*qt_prod)::int+1];
                sale_item_tup.sqty := (random()*1000)::int;

                -- insere em sale item
                
                if (not exists (select 1 from sale_item where sid=sale_item_tup.sid and pid=sale_item_tup.pid))
                    then
                    insert into sale_item (sid, pid, sqty) values (sale_item_tup.sid, sale_item_tup.pid, sale_item_tup.sqty);
                    counter_nprod := counter_nprod + 1;
                end if;

                exit when counter_nprod > nprod;
            end loop;

            counter := counter +1;4

        end if;

        exit when counter >= qttup;
    end loop;

end; $$;



CREATE TABLE product (					
	pid integer not null primary key,				
	name varchar(30) not null,					
	pqty  integer not null);

CREATE TABLE sale (
   sid integer not null primary key,
   sdate date not null,
   address varchar(30));
   
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
      if (not exists (select 1 from sale where sid=sale_tup.sid))
      then
        insert into sale (sid,sdate) values (sale_tup.sid,sale_tup.sdate);
        counter:=counter+1;
      end if;
      exit when counter >= qttup;
   end loop;
end; $$;

create or replace procedure ins_sale_item (qttup int) language plpgsql
as $$
declare
  itBySale int[6]:='{2,4,7,8,9,10}';
begin
  -- Pick one of the values from itBySale, say n, query sale, 
  -- take the id, and query product and take n IDs to insert into item_sale 
  -- (do not forget to get a value for sqty as well)
  -- repeat that qttup times
end; $$;

create or replace procedure call_all (qtsale int, qtprod int, qtitem int) language plpgsql
as $$
begin
   perform ins_product(qtprod);
   perform ins_sale(qtsale);
   perform ins_sale_item(qtitem);
end; $$;

