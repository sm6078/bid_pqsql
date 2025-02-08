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

do $$
  declare
    result_row record;   
  begin  
    for result_row in (select product_type, client_name, is_company, amount from bid) loop 	
		--raise notice 'product_type %, client_name %', result_row.product_type,  result_row.client_name;					
		if (result_row.product_type = 'credit') then
			if (result_row.is_company = 'false') then
			   --raise notice 'кредит и не компания %', result_row.client_name;
	           execute 'create table if not exists person_credit(id serial primary key,
	  													  		   client_name varchar(100),
				   												   amount numeric(12,2)	
														          )';	                                
		        execute format ('insert into person_credit (client_name, amount) values ($1, $2);')					 
   					 USING result_row.client_name, result_row.amount;  				
			else
				--raise notice 'кредит и компания %', result_row.client_name;
				execute 'create table if not exists company_credit(id serial primary key,
	  													  		   client_name varchar(100),	
														           amount numeric(12,2))';	                
		        execute format ('insert into company_credit (client_name, amount) values ($1, $2);')					 
   					 USING result_row.client_name, result_row.amount;  
			end if;			
		end if;	
	end loop;
  end;
$$