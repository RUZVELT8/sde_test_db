/* Создание таблицы results */

create table results 
(id INT,
responce TEXT
)


/* Задача №1 1.	Вывести максимальное количество человек в одном бронировании */

insert into results (id, responce)
select 
	1 as id,
	max(count_pass) as per_booking_pass_cnt
from 
	(select b.book_ref, count(t.passenger_id) as count_pass 
		from 
			bookings b 
		join tickets t on b.book_ref =t.book_ref 
	group by b.book_ref) foo
	

/* Задача №2 Вывести количество бронирований с количеством людей больше среднего значения людей на одно бронирование */

with pass_per_booking as (
	select
		book_ref as booking_id,
		count(*) as ticket_cnt
	from 
		bookings.tickets
		group by book_ref)
		insert into results (id, responce)
		select
			2 as id,
			count(booking_id) as booking_cnt
		from
			pass_per_booking
		where 
			pass_per_booking.ticket_cnt > (select avg(ticket_cnt) from pass_per_booking)
			
			
	

/* Задача №3 Вывести количество бронирований, у которых состав пассажиров повторялся два и более раза, среди бронирований с максимальным количеством людей (п.1)? */

with books as (
	select 
		t.book_ref , count(t.passenger_id) as pass_cnt 	
	from 
		bookings.tickets t
	group by 
		t.book_ref 
-- having count(t.passenger_id) = 2 --(для проверки)
	having 
		count(t.passenger_id) = (select max(count_pass)
	from 
		(select b.book_ref, count(t.passenger_id) as count_pass 
	from 
		bookings b join tickets t on b.book_ref =t.book_ref 
	group by 
		b.book_ref) foo) 
		),
	books_compare as (
		select 
			t1.book_ref as book_a,
			t2.book_ref as book_b,
			count(distinct t2.passenger_name) as book_b_cnt
		from books
			join tickets t1 on t1.book_ref = books.book_ref
			join tickets t2 on t2.passenger_name = t1.passenger_name and t1.book_ref <> t2.book_ref 
		    join books b2 on b2.book_ref = t2.book_ref 
		group by	
			t1.book_ref,
			books.pass_cnt,
			t2.book_ref
		having  books.pass_cnt = count(distinct t2.passenger_name) 
			)
	insert into results (id, responce)
	select 3 as id, count(distinct book_a) from books_compare
	

/* Задача №4 Вывести номера брони и контактную информацию по пассажирам в брони (passenger_id, passenger_name, contact_data) с количеством людей в брони = 3 */
	
with a as (
	select 
		b.book_ref, 
		count(t.passenger_id) as count_pass 
	from 
		bookings b join tickets t on b.book_ref =t.book_ref 
	group by 
		b.book_ref),
b as (
	select 
		t.book_ref, 
		t.passenger_id, 
		t.passenger_name, 
		t.contact_data 
	from 
		tickets t 
	group by 
		t.book_ref, 
		t.passenger_id , 
		t.passenger_name, 
		t.contact_data
		)
--having count(t.passenger_id) = 3
		insert into results (id, responce)
		select 
			4 as id,
			b.book_ref || ' | ' ||
			(b.passenger_id || ' | ' || b.passenger_name  || ' | ' ||b.contact_data) as contact_info
		from 
			b 
		join 
			a 
		on 
			b.book_ref = a.book_ref
		where 
			count_pass = 3

			
/* Задача №5 Вывести максимальное количество перелётов на бронь */

with fl_per_ticket as (
	SELECT 
		to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
		tf.ticket_no as ticket_num
	FROM 
		ticket_flights tf
	join
		flights_v f 
	ON 
		tf.flight_id = f.flight_id
	ORDER by
		f.scheduled_departure),
fl_cnt_book as
	(select 
		t.book_ref , 
		count(t.ticket_no) as tickets_per_booking
	from 
		tickets t 
	join 
		fl_per_ticket 
	on
		t.ticket_no = fl_per_ticket.ticket_num
	group by
		t.book_ref)
insert into results (id, responce)
select 
	5 as id,
	max(fl_cnt_book.tickets_per_booking) as max_fl_per_booking
from 
	fl_cnt_book
	
	
/* Задача №6 Вывести максимальное количество перелётов на пассажира в одной брони */

with a as (
	select
		t.book_ref, t.passenger_id,count(tf.flight_id) over (partition by t.passenger_id) as max_flights_per_booking
	from 
		ticket_flights tf 
	join
		tickets t 
	on
		tf.ticket_no  = t.ticket_no )
		insert into results (id, responce)
		select 
			6 as id,
			max(a.max_flights_per_booking) as max_flights_per_booking
		from a

		
/* Задача №7 Вывести максимальное количество перелётов на пассажира 
(запрос аналогичный запросу №6 так как есть условие: "Ни идентификатор пассажира, ни имя не являются постоянными (можно поменять паспорт,
можно сменить фамилию), поэтому однозначно найти все билеты одного и того же пассажира невозможно.") */

with a as (
	select
		count(tf.flight_id) over (partition by t.passenger_id) as max_flights_per_booking
	from 
		ticket_flights tf 
	join
		tickets t 
	on
		tf.ticket_no  = t.ticket_no )
		insert into results (id, responce)
		select 
			7 as id,
			max(a.max_flights_per_booking) as max_flights_per_booking
		from a

		
/* Задача №8 Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общие траты на билеты, для пассажира потратившему минимальное количество денег на перелеты */

with a as(
	select  distinct 
		t.passenger_id,
		t.passenger_name,
		t.contact_data,
		tf.amount,
		sum(tf.amount) over(partition by t.passenger_id) as amount_sum
	from
		ticket_flights tf 
	join 
		tickets t 
	on
		tf.ticket_no = t.ticket_no 
	)
		insert into results (id, responce)
		select 
			8 as id,
			(a.passenger_id || ' | ' ||a.passenger_name || ' | ' ||a.contact_data||' | '||a.amount_sum) as "pass_contact information"
		from 
			a
		where 
			a.amount_sum = (select min(a.amount_sum) as min_amount_sum from a)


/* Задача №9 Вывести контактную информацию по пассажиру(ам) (passenger_id, passenger_name, contact_data) и общее время в полётах, для пассажира, который провёл максимальное время в полётах */

with a as(
	select 
		t.passenger_id, 	
		t.passenger_name, 
		t.contact_data,
		sum(f.actual_arrival - f.actual_departure) over (partition by t.passenger_id) as "time on board"
	from
		ticket_flights tf 
	join
		flights f 
	on
		tf.flight_id = f.flight_id 
	join 
		tickets t 
	on
		tf.ticket_no = t.ticket_no 
	where 
		(f.actual_arrival - f.actual_departure) notnull
	)
insert into results (id, responce)
select distinct 9 as id,
	(a.passenger_id || ' | ' ||a.passenger_name || ' | ' ||a.contact_data||' | '||a."time on board") as "contact information"
from a
where a."time on board" = (select max(a."time on board") from a)


/* Задача №10 Вывести город(а) с количеством аэропортов больше одного */

insert into results (id, responce)
select distinct 
	10 as id,
	a.city as "Cites with two and more airports"
from 
	airports a
join 
	airports a2 
on a.city = a2.city and a.airport_code <> a2.airport_code 


/* Задача №11 Вывести город(а), у которого самое меньшее количество городов прямого сообщения */

with a as(	
	select 
	r.departure_city, 
	count(distinct r.arrival_city) as routes_cnt 
	from 
		routes r 
	group by 
		r.departure_city
		)
	insert into results (id, responce)
	select 
		 11 as id,
		a.departure_city
	from 
			a
	where 
			a.routes_cnt = (select min(a.routes_cnt) from a)

		
/* Задача №12 Вывести пары городов, у которых нет прямых сообщений исключив реверсные дубликаты */

with first_t as (
	select distinct 
		a.city as start_point, 
		a2.city as end_point, 
		a.city ||'_'||a2.city as split_da, a2.city||'_'||a.city as split_ad, 
		row_number() over () as id1 
	from 
		airports a
	inner join 
		airports a2 
	on 
		a.city <> a2.city
	order by 
		start_point),
second_t as (
	select 
		first_t.start_point, 
		first_t.end_point, 
		first_t.split_da, 
		first_t.split_ad , 
		first_t.id1 
	from 
		first_t
	left join 
		routes r
	on 
		first_t.split_da = r.departure_city||'_'||r.arrival_city
	where 
		r.departure_city||'_'||r.arrival_city  is null--)
	order by 
		first_t.id1
		)
	insert into results (id, responce)
	select distinct 
		12 as id,
		st.start_point||'|'||st.end_point as "route through transfer"
	from 
		second_t st
	left join 
		second_t st2
	on 
		st.split_da = st2.split_ad 
	where 
		st.id1 > st2.id1
	order by 
		st.start_point||'|'||st.end_point	
		
		
/* Задача №13 Вывести города, до которых нельзя добраться без пересадок из Москвы? */
		
with a as (
	select 
	departure_city, 
	count(arrival_city) as city_cnt
	from 
		flights_v fv
	where 
		arrival_city <> 'Москва'
	group by 
		departure_city
		)
	insert into results (id, responce)
	select 
		13 as id,
		a.departure_city
	from 
		a 
	where 
		a.city_cnt = 0


/* Задача №14 Вывести модель самолета, который выполнил больше всего рейсов */

with model_c as (
	select  distinct 
		a.model , 
		count(f.flight_id) over (partition by a.model) as model_cnt
	FROM 
		flights_v f 
	join 
		aircrafts a 
	on 
		f.aircraft_code = a.aircraft_code 
	order by 
		model_cnt desc 
		)
	insert into results (id, responce)
	select 
		14 as id,
		model_c.model
	from
		model_c
	where 
		model_c.model_cnt = (select max(model_c.model_cnt) from model_c)
		
		
/* Задача №15 Вывести модель самолета, который перевез больше всего пассажиров */

with bp_per_aircraft as (
	select distinct 
		a.model, 
		count(bp.ticket_no) over (partition by a.model) as total_pass_cnt
	 from 
 		boarding_passes bp 
 	join
 		flights f
	 on 
 		f.flight_id = bp.flight_id 
	 join 
 		aircrafts a 
	 on
 		f.aircraft_code = a.aircraft_code 
 	 		)
 	 	insert into results (id, responce)
	 	select 
	 		15 as id,
	 		bp_per_aircraft.model
	 	from 
	 		bp_per_aircraft
	 	where 
	 		bp_per_aircraft.total_pass_cnt = (select max(bp_per_aircraft.total_pass_cnt) from bp_per_aircraft )
	 		
	 		
/* Задача №16 Вывести отклонение в минутах суммы запланированного времени перелета от фактического по всем перелётам */

insert into results (id, responce)
select 
	16 as id,
 	ABS(
 	(extract (hour from sum(fv.scheduled_arrival-fv.scheduled_departure))*60 
 	+ 
 	extract (minute from sum(fv.scheduled_arrival-fv.scheduled_departure))) 
 	-
	(extract (hour from sum(fv.actual_arrival-fv.actual_departure))*60 
	+ 
	extract (minute from sum(fv.actual_arrival-fv.actual_departure))))	as delta_in_minutes
from 
	flights_v fv 
where 
	fv.status in ('Arrived')
	
	
/* Задача №17 Вывести города, в которые осуществлялся перелёт из Санкт-Петербурга 2016-09-13 (Заменено на 2017-08-13) */

insert into results (id, responce)
select  
	distinct 
17 as id,
	f.arrival_city 
from 
	flights_v f
where  
	f.departure_city = 'Санкт-Петербург'
and 
	f.scheduled_departure::date = '2017-08-13'
and 
	f.status = 'Arrived'
order by 
	f.arrival_city
	
	
/* Задача №18 Вывести перелёт(ы) с максимальной стоимостью всех билетов */

 with a as (
 	select distinct 
 		flight_id, 
 		(sum(amount) over (partition by flight_id)) as full_ticket_amount
 	from 
 		ticket_flights tf 
 	order by 
 		full_ticket_amount desc)
 	insert into results (id, responce)
	 select 
	 	18 as id,
	 	a.flight_id
 	from 
 		a
	where 
		a.full_ticket_amount = (select max(a.full_ticket_amount) from a)
		
		
/* Задача №19 Выбрать дни в которых было осуществлено минимальное количество перелётов */

with a as (
	select distinct 
		f.scheduled_departure::date as date_when, 
		count(f.flight_id) over (partition by f.scheduled_departure::date order by f.scheduled_departure::date) as flight_cnt
	from 
		flights f 
	where 
		f.status in ('Arrived'))
	insert into results (id, responce)
	select distinct 
		19 as id,
		a.date_when
	from 
		a 
	where 
		a.flight_cnt = (select min(a.flight_cnt) from a)
		
		
/* Задача №20 Вывести среднее количество вылетов в день из Москвы за 09 месяц 2016 года (Заменено на 08 месяц 2017 года) */

insert into results (id, responce)
select
	20 as id,
	count(fv.flight_id)/count(distinct fv.actual_departure::date) as avg_flights_per_day
from 
	flights_v fv 
WHERE 
	fv.departure_city = 'Москва'
and 
	fv.actual_departure::date between '2017-08-01'::date and '2017-08-31'::date
	
	
/* Задача №21 Вывести топ 5 городов у которых среднее время перелета до пункта назначения больше 3 часов */

with a as(
	select 
		fv.departure_city , 
		(extract(hour from avg(fv.scheduled_arrival-fv.scheduled_departure))*60+extract(minute from avg(fv.scheduled_arrival-fv.scheduled_departure))) as minutes_delta
	from 
		flights_v fv 
	group by 
		departure_city
	order by 
		(extract(hour from avg(fv.scheduled_arrival-fv.scheduled_departure))*60+extract(minute from avg(fv.scheduled_arrival-fv.scheduled_departure))) desc 
	)
	insert into results (id, responce)
	select  
		21 as id,
		a.departure_city
	from 
		a 
	where 
		a.minutes_delta > 180
	limit 5



