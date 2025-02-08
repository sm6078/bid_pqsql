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
    prefix varchar;
    name_table varchar;
    
  begin  
    for result_row in (select product_type, client_name, is_company, amount from bid) loop 	
		--raise notice 'product_type %, client_name %', result_row.product_type,  result_row.client_name;							
			if (result_row.is_company = 'false') then
	            prefix := 'person_';
	         else
	  			prefix := 'company_';	
	        end if;
            name_table := prefix || result_row.product_type;
			execute format ('create table if not exists %I (id serial primary key, client_name varchar(100), amount numeric(12,2));', name_table);
            execute format ('insert into %I (client_name, amount) 
				select client_name, amount from bid 
				where product_type = $1 
				and is_company = $2;', name_table) using result_row.product_type, result_row.is_company;
	end loop;
  end;
$$

--Скрипт №2 - Начисление процентов по кредитам за день
--Создать скрипт, который:
--1. Создаст(если нет) таблицу credit_percent для начисления процентов по кредитам: имя клиента, сумма начисленных процентов
--2. Имеет переменную - базовая кредитная ставка со значением "0.1" 
--3. Возьмет значения из таблиц person_credit и company_credit и вставит их в credit_percent:
-- необходимо выбрать id клиента и (сумму кредита * базовую ставку) / 365 для компаний
-- необходимо выбрать id клиента и (сумму кредита * (базовую ставку + 0.05) / 365 для физ лиц
--4. Печатает на экран общую сумму начисленных процентов в таблице
do $$
  declare
    result_row record;   
  begin  
	execute 'create table if not exists credit_percent(client_name varchar(100), amount_accruals numeric(12,2))';	                                
    
  end;
$$






--Скрипт №3 - Разделение ответственности. 
--Менеджеры компаний, должны видеть только заявки компаний.
--Создать view которая отображает только заявки компаний

create view сompany_bid as (select product_type, client_name, amount from bid where is_company = true);