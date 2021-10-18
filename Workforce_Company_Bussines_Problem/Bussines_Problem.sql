/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
-- QUESTION 1 --
-- Who is the most active worker in our platform based on their job application
SELECT 	COUNT(status) AS count_of_job_application,
		worker_id
FROM 	sampingan.job_post_applications
GROUP BY worker_id
ORDER BY count_of_job_application DESC

-- melihat detail status apa saja pada worker_id 1033357
SELECT 	worker_id,
		status
FROM 	sampingan.job_post_applications
WHERE 	worker_id = 1033357
-- ANSWER --
-- worker_id 1033357 is the most active worker, he has  5 new_application and 2 on_process status


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
-- QUESTION 2 --
-- How many workers in Semarang city that registered in our platform during second week of March
select 	date_format(str_to_date(created_at,'%d/%m/%Y' ), '%Y/%m/%d' ) as date_formated,
		domicile,
        id
FROM 	sampingan.workers
WHERE domicile = 'Semarang' AND date_format(str_to_date(created_at,'%d/%m/%Y' ), '%Y/%m/%d' ) BETWEEN '2021/03/07' AND '2021/03/15'
-- terdapat 3 pendaftar pada rentang waktu minngu kedua di bulan maret 2021 yaitu :
-- 1032462
-- 1017468
-- 825983


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
-- QUESTION 3 --
-- Show worker application distribution in Jakarta City between March to May 2021 (Distribution of workers that have done 1 applications, 2,3,4,5,etc)
SELECT 	jpa.Worker_id,
		COUNT(jpa.Worker_id) AS number_of_application,
        jp.city
FROM 	job_post_applications AS jpa
JOIN 	job_posts AS jp
ON		jp.id = jpa.job_post_id
WHERE 	date_format(str_to_date(created_at,'%d/%m/%Y' ), '%Y/%m/%d' ) <= '2021/04/31'
		AND
        jp.city LIKE "%Jakarta%"
GROUP BY jpa.Worker_id
ORDER BY number_of_application DESC
		

/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
-- QUESTION 4 --
-- Return the possible monthly revenue if all the job post’s quota were to be fulfilled
-- melakukan ini cukup sulit dikarenakan kita tidak mengetahui lama durasi pekerjaan dari masing-masing job_category
-- hanya terdapat kolom salary_period yang tidak terlalu membantu dalam penghitungan revenue bulanan
-- karena bisa saja pekerjaannya yang daily hanya beberapa hari seperti kegiatan event yang hanya 1-7 hari rata-rata
-- atau bisa jadi terdapat outlier gajinya dalam bentuk daily tapi kerjanya selama seminggu lebih
-- ditambah lagi terdapat job_category yang memiliki durasi berbeda-beda, seperti job other memiliki ketiga kategori dari salary_period
-- hal tersebut hanya bisa dihitung bila kita mengetahui benar-benar durasi waktu kerjanya
-- disini saya , melakukan pendekatan generalisasi, kalau diasumsikan setiap jenis pekerjaan, durasi waktu kerjanya dalam sebulan 20 hari, perhitungannya
SELECT 	jp.job_category,
		cs.job_category,
        cs.salary,
		COUNT(employment_quota) as jumlah_employment_quota,
        cs.salary * (COUNT(jp.employment_quota)) * 20 AS perkiraan_total_revenue_masing2_job_category  -- disini saya mengasumsikan 20 hari kerja untuk semua job_category
FROM job_posts AS jp
JOIN category_salary AS cs
ON   jp.job_category = cs.job_category
WHERE date_format(str_to_date(created_at,'%d/%m/%Y' ), '%Y/%m/%d' ) <= '2021/03/31'
GROUP BY jp.job_category
ORDER BY jumlah_employment_quota DESC

-- sekarang saya menjadikan query diatas menjadi temporary table
CREATE TEMPORARY TABLE temp_table_revenue
SELECT jp.job_category,
        cs.salary,
		COUNT(employment_quota) as jumlah_employment_quota,
        cs.salary * (COUNT(jp.employment_quota)) * 20 AS perkiraan_total_revenue_masing2_job_category  -- disini saya mengasumsikan 20 hari kerja untuk semua job_category
FROM job_posts AS jp
JOIN category_salary AS cs
ON   jp.job_category = cs.job_category
WHERE str_to_date(substr(jp.created_at,1,10),'%d/%m/%Y') <= '2021/03/31'  -- menggunakan konversi menjadi date_time menimbulkan error, jadi saya ubah seperti ini
GROUP BY jp.job_category
ORDER BY jumlah_employment_quota DESC

SELECT SUM(perkiraan_total_revenue_masing2_job_category)
FROM   temp_table_revenue
-- hasilnya revenue dari perkiraan query saya di bulan maret adalah Rp.683.800.000


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
-- QUESTION 5 --
-- List all the worker id that have more than 1 applications in jabodetabek region
-- sebelumnya kita cek terlebih dahulu apakah penulisan kotamadya di jakarta menggunakan format yang sama
SELECT DISTINCT city
FROM sampingan.job_posts
WHERE city LIKE "%Jakarta%"
-- ternyata terdapat penulisan "Kota Jakarta Pusat" dan "Kota Jakarta Selatan", ada juga yang hanya menulis "Jakarta"
-- untuk yang ada penulisan kata "Kota" kita hapus katav tersebut agar berformat sama 
-- untuk yang hanya menggunakan "Jakarta", karena kita tidak tahu Jakarta mana, maka kita perlu mengkontak ke bagian atau divisi yang menangani input dataset ini
SELECT *
FROM sampingan.job_posts
WHERE city IN ('Kota Jakarta Pusat', 'Kota Jakarta Selatan')
-- terdapat 3 penulisan "Kota Jakarta Selatan" dan 1 penulisan "Kota Jakarta Pusat"

-- kita ubah menggunakan control flow function (CASE dan WHEN)
Select	city, 
		CASE When city = 'Kota Jakarta Pusat' THEN 'Jakarta Pusat'
		When city = 'Kota Jakarta Selatan' THEN 'Jakarta Selatan'
		ELSE city
		END AS edited_city
From	sampingan.job_posts
WHERE city LIKE "%Jakarta%"
ORDER BY city DESC

-- kemudian kita update ke tabel master
Update job_posts
SET	city =	CASE When city = 'Kota Jakarta Pusat' THEN 'Jakarta Pusat'
				 When city = 'Kota Jakarta Selatan' THEN 'Jakarta Selatan'
				 ELSE city
				 END
-- dan setelah dicek tidak ada lagi kedua value tersebut dan sudah digantikan

-- lalu kita cari worker yang memiliki lebih dari 1 pekerjaan di area jabodetabek
SELECT 	job_post_Applications.worker_id as worker_id,
		job_posts.city as city,
        COUNT(job_post_Applications.worker_id) as Number_of_applications
FROM sampingan.job_posts as job_posts
JOIN sampingan.job_post_Applications as job_post_Applications
ON   job_posts.id = job_post_Applications.job_post_id
WHERE  	city IN ("Bogor", "Depok", "Tangerang", "Tangerang Selatan", "Bekasi") OR city LIKE "%Jakarta%"
GROUP BY worker_id
ORDER BY Number_of_applications DESC

-- query diatas kita jadikan temp_table lalu kita filter yang Number_of_applications lebih dari 1
CREATE TEMPORARY TABLE temp_table_jabodetabek_worker
SELECT 	job_post_Applications.worker_id as worker_id,
		job_posts.city as city,
        COUNT(job_post_Applications.worker_id) as Number_of_applications
FROM sampingan.job_posts as job_posts
JOIN sampingan.job_post_Applications as job_post_Applications
ON   job_posts.id = job_post_Applications.job_post_id
WHERE  	city IN ("Bogor", "Depok", "Tangerang", "Tangerang Selatan", "Bekasi") OR city LIKE "%Jakarta%"
GROUP BY worker_id
ORDER BY Number_of_applications DESC

SELECT 	worker_id,
		city,
        Number_of_applications
FROM	temp_table_jabodetabek_worker
WHERE	Number_of_applications > 1
-- Terdapat 33 worker_id yang memiliki lebih dari satu pekerjaan di area Jabodetabek


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */	
-- QUESTION 6 --
-- Show list of all worker who their second job application is “Sales Lapangan”
-- untuk kasus ini kita harus mengetahui tanggal berapa pekerjaan dari suatu worker_id diambil
-- pada kasus ini kita cek terlebih dahulu dan kita urutkan tanggalnya
-- kita bisa menggunakan Window Function, kita nomori urutan dari tanggal tersebut untuk memudahkan query selanjutnya agar kita ekstrak RN yang bernomor 2
SELECT 	job_post_Applications.worker_id as worker_id,
		job_posts.city as city,
        str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y') AS date_converted,
        ROW_NUMBER() OVER(PARTITION BY worker_id ORDER BY str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y')) AS RN,
        job_posts.job_category
FROM sampingan.job_posts as job_posts
JOIN sampingan.job_post_Applications as job_post_Applications
ON   job_posts.id = job_post_Applications.job_post_id

-- sekarang kita ambil RN yang bernomor 2
-- kita bisa memanfaatkan sub-query
SELECT	*
FROM	(
		SELECT	job_post_Applications.worker_id as worker_id,
				job_posts.city as city,
				str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y') AS date_converted,
				ROW_NUMBER() OVER(PARTITION BY worker_id ORDER BY str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y')) AS RN,
                job_posts.job_category
		FROM sampingan.job_posts as job_posts
		JOIN sampingan.job_post_Applications as job_post_Applications
		ON   	job_posts.id = job_post_Applications.job_post_id
        ) AS sub_query
WHERE sub_query.RN = 2 AND sub_query.job_category = "Sales Lapangan"
-- terdapat 87 worker_id yang memilih Sales_lapangan di pekerjaan keduanya dari berbagai kota


/* --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
-- QUESTION 7 --
-- List all the worker who changed their job category on their second or third application 
-- (example worker 1 first and second application is in “Sales Lapangan” then they switched to “Admin” in third application)
-- dalam pengerjaan masalah ini kita harus offset satu lag agar kita dapat membandingkan ketika RN = 2 dan RN = 3 tidak sama, maka disaat itu kita tahu bahwa pekerja tersebut berganti pekerjaan
-- saya terlebih dahulu query awal untuk nantinya dijadikan sub-query
SELECT 	job_post_Applications.worker_id as worker_id,
		job_posts.city as city,
        str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y') AS date_converted,
        ROW_NUMBER() OVER(PARTITION BY worker_id ORDER BY str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y')) AS RN,
        job_posts.job_category,
        LAG(job_posts.job_category) OVER(ORDER BY worker_id) AS lag_job_category
FROM sampingan.job_posts as job_posts
JOIN sampingan.job_post_Applications as job_post_Applications
ON   job_posts.id = job_post_Applications.job_post_id

-- lalu kita masukan sub-query kita dan tambahkan control flow function menggunakan CASE WHEN statement
SELECT	*,
		CASE WHEN sub_query.RN = 2 AND sub_query.job_category <> sub_query.lag_job_category THEN "Change job on second application"
			 WHEN sub_query.RN = 3 AND sub_query.job_category <> sub_query.lag_job_category THEN "Change job on third application"
             ELSE NULL END AS change_job_category
FROM	(
		SELECT 	job_post_Applications.worker_id as worker_id,
				job_posts.city as city,
				str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y') AS date_converted,
				ROW_NUMBER() OVER(PARTITION BY worker_id ORDER BY str_to_date(substr(job_posts.created_at,1,10),'%d/%m/%Y')) AS RN,
				job_posts.job_category,
				LAG(job_posts.job_category) OVER(ORDER BY worker_id) AS lag_job_category
		FROM sampingan.job_posts as job_posts
		JOIN sampingan.job_post_Applications as job_post_Applications
		ON   job_posts.id = job_post_Applications.job_post_id
        ) AS sub_query
HAVING change_job_category IS NOT NULL

-- bisa hitung menggunakan count untuk masing-masing kategori