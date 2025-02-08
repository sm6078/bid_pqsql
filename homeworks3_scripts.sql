--Скрипт №1 - Распределение заявок по продуктовым таблицам
--Создать скрипт, который будет: 

--1. Создавать таблицы на основании таблицы bid:
--Имя таблицы должно быть основано на типе продукта + является ли он компанией
--Если такая таблица уже есть, скрипт не должен падать!
--Например:
--для записи где product_type = credit, is_company = false будет создана таблица:
--person_credit, с колонками: id (новый id), client_name, amount
--для записи где product_type = credit, is_company = true:
--company_credit, с колонками: id (новый id), client_name, amount
--2. Копировать заявки в соответствующие таблицы c помощью конструкции:
--2.1 Для вставки значений можно использовать конструкцию
--insert into (col1, col2)
--select col1, col2
--from [наименование таблицы]
--2.2 Для исполнения динамического запроса с параметрами можно использовать конструкцию
--execute '[текст запроса]' using [значение параметра №1], [значение параметра №2].
--Пример:
--execute 'select * from product where product_type = $1 and is_company = $2' using 'credit', false;

do $$
  declare
    result_row record;   
  begin  
    for result_row in (select product_type, client_name, is_company, amount from bid where product_type = 'credit') loop 	
		--raise notice 'product_type %, client_name %', result_row.product_type,  result_row.client_name;							
			if (result_row.is_company = 'false') then
			   --raise notice 'кредит и не компания %', result_row.client_name;
	           execute 'create table if not exists person_credit(id serial primary key, client_name varchar(100), amount numeric(12,2))';	                                
		        execute format ('insert into person_credit (client_name, amount) values ($1, $2);')					 
   					 USING result_row.client_name, result_row.amount;  				
			else
				--raise notice 'кредит и компания %', result_row.client_name;
				execute 'create table if not exists company_credit(id serial primary key, client_name varchar(1001), amount numeric(12,2))';	                
		        execute format ('insert into company_credit (client_name, amount) values ($1, $2);')					 
   					 USING result_row.client_name, result_row.amount;  		
		end if;	
	end loop;
  end;
$$




--Скрипт №3 - Разделение ответственности. 
--Менеджеры компаний, должны видеть только заявки компаний.
--Создать view которая отображает только заявки компаний

create view сompany_bid as (select product_type, client_name, amount from bid where is_company = true);