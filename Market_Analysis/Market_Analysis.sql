-- 1.A Berapa banyak pelanggan wanita di Jakarta yang memiliki akun Gmail ?
select count (*)
from	(
		select	trsct.customer_id,
				count(trsct.customer_id) as total_transactions,
				cstmr.gender,
				cstmr.city,
				cstmr.email 
		from		datasource_sql_ds11."transaction" as trsct
		left join	datasource_sql_ds11.customer as cstmr
		on	cstmr.id = trsct.customer_id
		where	cstmr.gender = 'Female'
				and
				(cstmr.email = 'Gmail' and cstmr.city = 'Jakarta')
		group by 1, 3, 4, 5
		order by 2 desc
		) sub_query

-- 1.B Berapa banyak pelanggan wanita di Jakarta yang memiliki akun Gmail 
--     dengan syarat hanya pelanggan wanita yang memiliki transaksi setidaknya 10 kali ?
select count (*)
from	(
		select	trsct.customer_id,
				count(trsct.customer_id) as total_transactions,
				cstmr.gender,
				cstmr.city,
				cstmr.email 
		from		datasource_sql_ds11."transaction" as trsct
		left join	datasource_sql_ds11.customer as cstmr
		on	cstmr.id = trsct.customer_id
		where	cstmr.gender = 'Female'
				and
				(cstmr.email = 'Gmail' and cstmr.city = 'Jakarta')
		group by 1, 3, 4, 5
		having count(trsct.customer_id) >= 10
		order by 2 desc
		) sub_query

		

-- 2.A Produk mana yang memiliki kinerja maksimum di Q4 (Okt 2018 - Des 2018) di marketplace ? 
--     dengan syarat hanya 5 produk teratas yang memiliki total transaksi (kuantitas) di atas rata-rata.
with
	pool as (	
			select 	product_id, 
					sum(quantity) as sum_quantity
			from  datasource_sql_ds11.transaction
			where extract ('year' from created_at) in (2018)
	  			  and 
	  			  extract ('month' from created_at) in (10,11,12)
			group by 1
			order by 2 desc
			)
			
select 	trsct.product_id,
		trsct.created_at,
		store."type", 
		row_number() over(partition by trsct.product_id) as transactions_order,
		sum(trsct.quantity) over(partition by trsct.product_id) as total_quantity,
		(select avg(sum_quantity) from pool) as average_total_quantity
from 		datasource_sql_ds11."transaction" as trsct 
left join 	datasource_sql_ds11.store as store on trsct.store_id = store.id 
where extract ('year' from created_at) in (2018)
	  and 
	  extract ('month' from created_at) in (10,11,12)
	  and 
	  store."type" = 'Online store'
order by 4, 5 desc 
limit 5



-- 3.A jenis toko apa yang saat ini mendapatkan jumlah transaksi paling banyak secara kuantitas dari wilayah Jakarta?
--    apakah sama antara perempuan dan laki-laki ? 
with
	pool as (select	trsct.store_id,
					store."type", 
					cstmr.city,
					cstmr.gender,
					sum(trsct.quantity) as gender_total_quantity
			 from	datasource_sql_ds11."transaction" as trsct
			 left join datasource_sql_ds11.customer as cstmr on trsct.customer_id = cstmr.id
			 left join datasource_sql_ds11.store as store on trsct.store_id = store.id 
			 where cstmr.city = 'Jakarta'
			 group by 1, 2, 3, 4
			 order by 1, 2 desc
			)
			
select 	store_id,
		"type",
		city,
		gender,
		gender_total_quantity,
		SUM(gender_total_quantity) over(partition by store_id) as store_type_total_quantity
from pool
group by 1, 2, 3, 4, 5

-- 3.B untuk perbandingan coba cek juga daerah lain diluar jakarta.
with
	pool as (select	trsct.store_id,
					store."type", 
					cstmr.city,
					cstmr.gender,
					sum(trsct.quantity) as total_quantity
			 from	datasource_sql_ds11."transaction" as trsct
			 left join datasource_sql_ds11.customer as cstmr on trsct.customer_id = cstmr.id
			 left join datasource_sql_ds11.store as store on trsct.store_id = store.id 
			 group by 1, 2, 3, 4
			 order by 1, 2 desc
			)
			
select 	store_id,
		"type",
		city,
		gender,
		total_quantity
from pool
group by 1, 2, 3, 4, 5
order by 3, 1, 4


































select * 
from datasource_sql_ds11."transaction" 
limit 10



select count (*) 
from 
    (
     select customer_id, 
     count(*) total_transaction 
     from "transaction" t 
     join customer c 
     on customer_id =c.id 
     where
          c.city = 'Jakarta' and
          c.email = 'Gmail' and 
          c.gender ='Female'
     group by 1
    ) A







