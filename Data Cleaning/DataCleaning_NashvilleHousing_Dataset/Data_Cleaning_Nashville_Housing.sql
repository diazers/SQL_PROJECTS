/* 

Pada Project ini akan dilakukan Proses Data Cleaning, Data Cleaning adalah proses dimana seorang data analyst 
memformat dan mentransform data, mengisi data yang hilang, menyiapkan raw data menjadi sesuai dengan 
apa yang kita inginkan sehingga data siap untuk dianalisis, hal ini merupakan 80% kurang lebih porsi pekerjaan
dari proses keseluruhan data analisis, sehingga penting untuk dikuasai. aplikasi yang digunakan pada projects ini 
menggunkan Microsoft SQL Server Management Studio

*/

-- Data yang digunakan adalah data perumahan kota Nashville
Select *
From SQL_Portofolio_Projects.dbo.NashvilleHousing
-- terdapat 56.477 baris


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- pertama kita coba cek sekilas data dari dataset yang kita gunakan agar kita dapat gambaran secara luas 
-- dataset yang kita kerjakan dan masalah apa yang kita hadapi
-- bisa dengan cara klik kanan pada tabel di object explorer lalu pilih 'select top 1000 rows'
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [SQL_Portofolio_Projects].[dbo].[NashvilleHousing]

  -- atau dengan cara menggunakan 'TOP' 
SELECT TOP(100) *
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Problem 1 [Standardize Date Format]
-- dariquery yang sebelumnya dijalankan, kolom SalesDate formatnya dalam bentuk DateTime
-- saya akan merubah format kolom tersebiy ke menjadiformat Date saja agar lebih ringkas
-- run query dibawah ini terlebih dahulu
Select saleDate, CONVERT(Date,SaleDate) AS saleDateCoverted
From SQL_Portofolio_Projects.dbo.NashvilleHousing

-- kemudian run kueri dibawah
Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- terkadang walaupun hasil kueri menunjukan semua baris berhasil diubah, tetapi ketika dicek
-- belum ada perubahan, kita bisa menggunakan cara lain

-- gunakan kueri ini bila cara diatas tidak berhasil
-- kita akan menambahkan kolom baru bernama SaleDateConverted
-- jalankan kueri dibawah ini satu persatu (jangan sekaligus) dengan cara diblock dan run atau excecute
Select saleDate, CONVERT(Date,SaleDate) AS saleDateCoverted
From SQL_Portofolio_Projects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- setelah dicek akan terlihat ada kolom baru bernama SaleDateConverted
-- selanjutnya kita akan menggunakan SaleDateConverted sebagai tanggal
-- kolom SaleDate bisa juga di DROP, tapi saya kali ini tidak akan menDROP kolom tersebut


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Problem 2 [Populate / Filling Miising Value]
-- teknik mengisi data yang hilang dinamakan 'Imputation'. Ada berbagai cara mengisi data yang hilang, beberapa diantaranya adalah :
-- 1. mengkontak stakeholder atau orang terkait yang berkaitan dengan data yang hilang
-- 2. mengisi dengan suatu hitungan statistik yang merepresentasikan gambaran umum dari data tersebut seperti mengisi dengan median, modus, atau mode apabila data tersebut berdata numerik
-- 3. menggunakan algoritma machine learning untuk mengisi data yang hilang
-- 4. melihat relasi antar data yang ada di tabel ataupun di database, teknik inin dinamakan proxy

-- cara melihat data yang hilang (NULL Values) kita dapat mengexplor secara manual ataupun menggunakan kueri yang kita desain sedemikian rupa
-- apabila dataset berjumlah sangat banyak, akan sangat tidak efisien apabila kita mengeksplor secara manual
-- oleh karena itu kita akan melihat berapa banyak nulll values di beberapa kolom yang terindikasi terdapat null values
-- agar kita mendapat jumlah null values
SELECT	SUM(CASE WHEN ParcelID is null 
		THEN 1 ELSE 0 END) AS [Number Of Null Values], 
		COUNT(ParcelID) AS [Number Of Non-Null Values] 
FROM	SQL_Portofolio_Projects.dbo.NashvilleHousing
-- dr kueri inin terlihat tidak terdapat null values karena kolom ParcelID adalah index yang kemungkinan besar tidak terdapat null values

-- melihat banyak null valuew di kolom OwnerName
SELECT	SUM(CASE WHEN OwnerName is null 
		THEN 1 ELSE 0 END) AS [Number Of Null Values], 
		COUNT(OwnerName) AS [Number Of Non-Null Values] 
FROM	SQL_Portofolio_Projects.dbo.NashvilleHousing
-- terdapat 31216 data yang hilang pada kolom OwnerName

-- Untuk mengetahui apakah setidaknya di suatu kolom terdapat null values kit dapat menggunakan kueri dibawah ini
SELECT *
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
WHERE 
	[UniqueID ] IS NULL OR
      [ParcelID] IS NULL OR
      [LandUse] IS NULL OR
      [PropertyAddress] IS NULL OR
      [SaleDate] IS NULL OR
      [SalePrice] IS NULL OR
      [LegalReference] IS NULL OR
      [SoldAsVacant] IS NULL OR
      [OwnerName] IS NULL OR
      [OwnerAddress] IS NULL OR
      [Acreage] IS NULL OR
      [TaxDistrict] IS NULL OR
      [LandValue] IS NULL OR
	  [BuildingValue] IS NULL OR
      [TotalValue] IS NULL OR
      [YearBuilt] IS NULL OR
      [Bedrooms] IS NULL OR
      [FullBath] IS NULL OR
      [HalfBath] IS NULL
-- namun cara ini masih mengharuskan kita melihat tabel untuk mengecek apakah di kolom-kolom tertentu
-- terdapat null values, apabila data null valuesnya sedikit kita masih bisa menggunaka cara ini, 
-- tetapi apabila terdapat banayak null values, cara ini kurang baik dan kurang efisien

-- untuk melihat jumlah null values pada masing-masing kolom tanpa harus mengecek satu persatu secara manual
-- kita dapat menggunbakan COUNT
select 
  sum(case when [UniqueID] is null then 1 else 0 end) A,
  sum(case when [ParcelID] is null then 1 else 0 end) B,
  sum(case when [LandUse] is null then 1 else 0 end) C,
  sum(case when [PropertyAddress] is null then 1 else 0 end) D,
  sum(case when [SaleDate] is null then 1 else 0 end) E,
  sum(case when [SalePrice] is null then 1 else 0 end) F,
  sum(case when [LegalReference] is null then 1 else 0 end) G,
  sum(case when [SoldAsVacant] is null then 1 else 0 end) H,
  sum(case when [OwnerName] is null then 1 else 0 end) I,
  sum(case when [OwnerAddress] is null then 1 else 0 end) J,
  sum(case when [Acreage] is null then 1 else 0 end) K,
  sum(case when [TaxDistrict] is null then 1 else 0 end)L,
  sum(case when [LandValue] is null then 1 else 0 end) M,
  sum(case when [BuildingValue] is null then 1 else 0 end) N,
  sum(case when [TotalValue] is null then 1 else 0 end) O,
  sum(case when [YearBuilt] is null then 1 else 0 end) P,
  sum(case when [FullBath] is null then 1 else 0 end) Q,
  sum(case when [HalfBath] is null then 1 else 0 end) R
from SQL_Portofolio_Projects.dbo.NashvilleHousing
-- jika dilihat dari kueri diatas, terlihat jelas jumlah kolom yang memiliki nulll values,
-- null values terdapat pada kolom :
/*
[PropertyAddress]
[OwnerName]
[OwnerAddress]
[Acreage]
[TaxDistrict]
[LandValue]
[BuildingValue]
[TotalValue]
[YearBuilt]
[Bedrooms]
[FullBath]
[HalfBath]
*/

-- POPULATE NULL VALUES in [PropertyAddress]
-- saya akan mencoba mengisi null values pada kolom [PropertyAddress]
-- mari kita lihat kolom [PropertyAddress] dengan  Null Values
SELECT * 
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
-- terapat 29 rows dimana terdapat null values, sesuai dengan hail kueri kita sebelumnya

-- umumnya sebelum kita melakukan data cleaning, kita harus mengerti terlebih dahulu dataset yg kita kerjakan, sehingga kita memiliki konteks
-- kita harus mengetahui kolom-kolom yang terdapat di dataset yg kita gunakan mewakili apa, sehingga kita paham apa yang kita kerjakan, dan mengurangi error
-- Untuk dapat mengisi null values alamat dari properti rumah, kita tau bahwa data alamat properti rumah tidak berubah, pemiliknya mungkin berubah tetapi lokasi dari
-- objek rumahnya itu sendiri tidak akan berubah, bila kita memiliki referensi lain untuk memproxy data kita, 
-- sebelumnya kita lihat terlebih dahulu di kolom PropertyAddtress itu sendiri, apakah terdapat duplicate value, bila terdapat duplicate value
-- kemungkinan bisa terdapat dua value, bila memiliki dua value, kemungkinan data yang null juga sebenarnya memiliki duplicate value yang tidak null
-- mari kita coba 
SELECT PropertyAddress, COUNT(PropertyAddress)
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
GROUP BY PropertyAddress
HAVING COUNT(PropertyAddress)>1
-- terdapat duplicate value di kolom PropertyAddres

-- selanjutnya untuk mengetahui apakah terdapat duplicate value yang tidak null terhadap baris yang null di kolom PropertyAdress kita harus merujuk atau merefernsikan
-- kolom PropertyAdress terhadap suatu kolom yang digunakan sebagai ID, karena UniqueID tidak mungkin terdapat duplicate value, kita cek terhadap kolom ParcelID
SELECT ParcelID, PropertyAddress
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
ORDER BY ParcelID
-- terlihat di baris 84 dan 85 ParcelID memiliki 2 value yang sama, sama seperti PropertyAddress
-- dengan begitu kita bisa menggunakan ParcelID sebagai kolom Referensi

-- kita akan menggunakan self join untuk mengeceknya
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing AS A
JOIN SQL_Portofolio_Projects.dbo.NashvilleHousing AS B
	 ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]  -- kita harus tulis agar menjadi pembeda dimana walaupun ParcelID dan PropertyAddres sama, uniqueID beda jadi kita tahu bahwa hasil yg muncul dr row yang berbeda
WHERE A.PropertyAddress IS NULL
ORDER BY A.ParcelID
-- terbukti bahwa pada nilai data ParcelID yang sama, tedapat satu rows yang PropertyAddressnya NULL, dan yang satnnya terdapat valuenya atau alamatnya
-- sehingga kita bisa mengisi data yang null dengan pasangan duplicatenya yang meiliki value

SELECT ISNULL(A.PropertyAddress, B.PropertyAddress) -- ini menyatakan dimana bila A.PropertyAddress NULL, kita isi dengan B.PropertyAdress yang tidak NULL
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing AS A
JOIN SQL_Portofolio_Projects.dbo.NashvilleHousing AS B
	 ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
-- akan menampilkan B.PropertyAddress yang tidak NULL, nilai ini yang akan kita masukan ke A.PropertyAddress

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing AS A
JOIN SQL_Portofolio_Projects.dbo.NashvilleHousing AS B
	 ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
-- akan muncul 29 baris affected yang mana data null value di PropertyAddress sudah terisi, bila dicek sudah tidak ada lagi nulll values di PropertyAddress


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- PROBLEM 3 [Breaking out Address into Individual Columns (Address, City, State)]
-- data di kolom PropertAddress adalah gabungan dari alamat, kota, dan negara bagian. apabila kita ingin melihat rata-rata dari suatu negara bagian
-- kolom gabungan seperti itu akan menyulitkan kita apabila kita ingin menagregasi suatu wilayah tertentu, oleh karena itu lebih baik apabila 3 b agian itu dipisah menjadi kolom kolom tersendiri
SELECT PropertyAddress
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
-- jika dilihaturutan dari dua bagian dari kolom PropertyAddress adalah
-- pertama adalah alamat, kedua adalah nama kota
-- kita akan pisahkan dua bagian tersebut menjadi kolom tersendiri
-- jika diperhatikan alamat dan nama kota dipisahkan oleh karakter koma
-- suatu pemisah antar kolom atau nilai bisa juga disebut delimiter

-- kita akan nmenggunakan SUBSTRING untuk memisahkannya
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address  -- CHARINDEX memberitahu sampai karakter keberapa yang akan ditampilkan, dia akan menhitung dari awal sampai karakter akhir yang ditentukan
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
-- kueri diatas akan mulai mengqambil dari karakter pertama sampai dengan karakter ','
-- kita akan modifikasi kueri diatas agar kita tidak memasukan koma

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address  -- CHARINDEX memberitahu sampai karakter keberapa yang akan ditampilkan, dia akan menhitung dari awal sampai karakter akhir yang ditentukan
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
-- koma sudah tidak ada lagi karena jumlah karakter yang seharusnya diambil kita kurangkan satu, jd karakter terakhir, yaitu koma, tidak diambil

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as PAddress,  
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as PCity  -- ini akan mulai mengambil dari karakter koma, tetapi karena kita tidak inigin memasukan koma kita masukan + 1 agar karakter yg diambil +1 setelah koma
FROM SQL_Portofolio_Projects.dbo.NashvilleHousing
-- dua bagian dqari kolom PropertyAddress sudah terpisah menjadi dua kolom, alamat dan nama kota

-- menambahkan dua kolom baru ke tabel utama
-- jalankan kueri dibawah satu-persatu
ALTER TABLE NashvilleHousing
Add PAddress Nvarchar(255);

Update NashvilleHousing
SET PAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PCity Nvarchar(255)

Update NashvilleHousing
SET PCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
-- maka 2 kolom baru akan ditambahkan ke master tabel

-- selain kolomPropertyAddress kolom OwnerAdrress juga terdiri dari beberapa bagian
-- bagian pertama alamat, kedua nama kota, ketika kode negara bagian (state)
-- kita juga akan memisahkan ketiga bagian tersebut menjadi kolom-kolom tersendiri
-- disini kita akan split menggunakan cara lain yaitu menggunakan PARSENAME
Select
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQL_Portofolio_Projects.dbo.NashvilleHousing
-- hal yang perlu diperhatikan adalah PARSENAME hanya bekerja dengan mengidentifikasi karakter titik '.'
-- oleh karena itu kita harus merubah tanda koma menjadi titik terlebih dahulu menggunakan REPLACE
-- baru kemudian PARSENAME bisa mensplit berdasarkan letak titik
-- dan PARSENAME bekerja secara terbalik, jadi kita mulai dari belakang dahulu (DESCENDING)
-- bila kita tulis 1,2,3 maka akan mulai dari kode state lalu ke alamat

-- kemudian kita update ke tabel master
ALTER TABLE NashvilleHousing
Add OAddress Nvarchar(255);

Update NashvilleHousing
SET OAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OCity Nvarchar(255);

Update NashvilleHousing
SET OCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OState Nvarchar(255);

Update NashvilleHousing
SET OState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
-- setelah dicek akan menambahkan 3 kolom baru di tabel master


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Problem 4 [Changing Inconsistent Categorical Value]
-- pada kolom yang bertipe kategorikal, terkadang dalam penginputan data penulisannya tidak seragam
-- pada contoh kasus ini, kolom SoldAsVacant memiliki dua value, yaitu YES dan NO, tetapi bila kita cek
-- terdapat value yang penulisannya 'Y' dan 'N'. hal ini membuat ketidakkonsistenan penulisan yang akan berakibat keakuratan analisis kita
SELECT	SoldAsVacant, 
		COUNT(SoldAsVacant)
FROM  SQL_Portofolio_Projects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
-- terdapat 399 baris kolom bertuliskan 'N' dan 52 baris bertuliskan 'Y'
-- sedangkan 'YES' sebanyak 4623 dan 'No' 51403.
-- karena lebih umum dan banyak menggunakan 'YES' dan 'NO', kita akan menggunakan itu untuk seluruh baris di kolom SoldAsVacant

-- kita akan menggunakan CASE WHEN statement 
Select	SoldAsVacant, 
		CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From	SQL_Portofolio_Projects.dbo.NashvilleHousing

-- kemudian kita update ke tabel master
Update NashvilleHousing
SET	SoldAsVacant =	CASE When SoldAsVacant = 'Y' THEN 'Yes'
						 When SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- PROBLEM 5 [Remove Duplicates]
-- pada umumnya, apabila kita ingin agar query kita lebih efisien kita menghapus duplicate value
-- namun bisa juga duplicate value kita taruh sementara di temp table
-- pada kali ini saya akan mencontohkan menghapus duplicate value menggunakan windowing CTE

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQL_Portofolio_Projects.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From SQL_Portofolio_Projects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Problem 6 [Delete Unused Columns]
-- pada umumnya kita harus sangat hati-hati dalam menghapus rows ataupun columns yang terdapat di master tabel, karena ketika di dunia nyata hal tersebut sangatlah vital
-- biasanya masing-masing user akan diberikan batasan dalam akses di databse oleh admin, seihingga kejadian sengaja ataupun tidak disengaja untuk merubah tabel master kemungkinannya akan keci
-- dalam hal ini saya hanya mencontohkan bagaimana menghapus tabel yang sudah tidak digunakan
-- dalam hal ini tabel yang sudah di split seperti PropertyAddress dan OwnerAddress
-- tabel yang sudah diformat dalam format DATE yaitu SalesDate
-- dan bisa juga kolom yang selanjutnya tidak diapakai


ALTER TABLE SQL_Portofolio_Projects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate