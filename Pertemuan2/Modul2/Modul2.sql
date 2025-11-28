USE TokoRetailDB;

SELECT name FROM sys.tables;

SELECT * FROM KategoriProduk ;

SELECT * FROM Produk ;

SELECT * FROM Pelanggan ;

SELECT * FROM PesananHeader ;

SELECT * FROM PesananDetail ;

INSERT INTO Pelanggan(NamaDepan, NamaBelakang, Email, NoTelepon) VALUES
('Reisya', 'Gandhi', 'reisyaprasetya12@gmail.com', '088229484178'),
('Revan', 'Sonjaya', 'revansonjaya03@gmail.com', NULL);

INSERT INTO KategoriProduk (NamaKategori)
VALUES 
('Elektronik'),
('Pakaian'),
('Buku');

SELECT NamaDepan, NamaBelakang, NoTelepon FROM Pelanggan ;

INSERT INTO Produk (SKU, NamaProduk, Harga, Stok, KategoriID)
VALUES 
('ELEC-001', 'Laptop Pro 14 inch', 15000000.00, 50, 1),
('PAK-001', 'Kaos Polos Putih', 75000.00, 200, 2),
('BUK-001', 'Dasar-dasar SQL', 120000.00, 100, 3);

SELECT P.*, K.NamaKategori FROM Produk AS P
JOIN KategoriProduk AS K ON P.KategoriID = K.KategoriID;

/*==========PELAJARI==========*/

/* 1. Pelanggaran UNIQUE Constraint */
-- Error: Mencoba mendaftarkan email yang SAMA dengan Budi Santoso
PRINT 'Uji Coba Error 1 (UNIQUE):';
INSERT INTO Pelanggan (NamaDepan, Email)
VALUES ('Budi', 'budi.santoso@email.com');
GO
/* 2. Pelanggaran FOREIGN KEY Constraint */
-- Error: Mencoba memasukkan produk dengan KategoriID 99 (tidak ada di tabel KategoriProduk)
PRINT 'Uji Coba Error 2 (FOREIGN KEY):';
INSERT INTO Produk (SKU, NamaProduk, Harga, Stok, KategoriID)
VALUES ('XXX-001', 'Produk Aneh', 1000, 10, 99);
GO
/* 3. Pelanggaran CHECK Constraint */
-- Error: Mencoba memasukkan harga negatif
PRINT 'Uji Coba Error 3 (CHECK):';
INSERT INTO Produk (SKU, NamaProduk, Harga, Stok, KategoriID)
VALUES ('NGT-001', 'Produk Minus', -50000, 10, 1);
GO

/* Cek data SEBELUM di-update */
PRINT 'Data Citra SEBELUM Update:';
SELECT * FROM Pelanggan WHERE PelangganID = 2;

BEGIN TRANSACTION; -- Mulai zona aman

UPDATE Pelanggan
SET NoTelepon = '085566778899'
WHERE PelangganID = 2; -- Klausa WHERE sangat penting!

/* Cek data SETELAH di-update (masih di dalam transaksi) */
PRINT 'Data Citra SETELAH Update (Belum di-COMMIT):';
SELECT * FROM Pelanggan WHERE PelangganID = 2;

-- Jika sudah yakin, jadikan permanen
COMMIT TRANSACTION;

-- Jika ragu, ganti COMMIT dengan ROLLBACK
PRINT 'Data Citra setelah di-COMMIT:';
SELECT * FROM Pelanggan WHERE PelangganID = 2;

PRINT 'Data Elektronik SEBELUM Update:';
SELECT * FROM Produk WHERE KategoriID = 1;

BEGIN TRANSACTION;

UPDATE Produk
SET Harga = Harga * 1.10 -- Operasi aritmatika pada nilai kolom
WHERE KategoriID = 1;
PRINT 'Data Elektronik SETELAH Update (Belum di-COMMIT):';

SELECT * FROM Produk WHERE KategoriID = 1;

-- Cek apakah ada kesalahan? Jika tidak, commit.
COMMIT TRANSACTION;

PRINT 'Data Produk SEBELUM Delete:';
SELECT * FROM Produk WHERE SKU = 'BUK-001';

BEGIN TRANSACTION;

DELETE FROM Produk
WHERE SKU = 'BUK-001';
PRINT 'Data Produk SETELAH Delete (Belum di-COMMIT):';
SELECT * FROM Produk WHERE SKU = 'BUK-001'; -- Harusnya kosong

COMMIT TRANSACTION;

/* Cek data stok. Harusnya 50 dan 200 */
PRINT 'Data Stok SEBELUM Bencana:';
SELECT SKU, NamaProduk, Stok FROM Produk;
BEGIN TRANSACTION; -- WAJIB! Ini adalah jaring pengaman kita.

-- BENCANA TERJADI: Lupa klausa WHERE!
UPDATE Produk
SET Stok = 0;

/* Cek data setelah bencana. SEMUA STOK JADI 0! */
PRINT 'Data Stok SETELAH Bencana (PANIK!):';
SELECT SKU, NamaProduk, Stok FROM Produk;

-- JANGAN COMMIT! BATALKAN!
PRINT 'Melakukan ROLLBACK...';
ROLLBACK TRANSACTION;

/* Cek data setelah diselamatkan */
PRINT 'Data Stok SETELAH di-ROLLBACK (AMAN):';
SELECT SKU, NamaProduk, Stok FROM Produk;

/* 1. Buat 1 pesanan untuk Budi */
INSERT INTO PesananHeader (PelangganID, StatusPesanan)
VALUES (1, 'Baru');

PRINT 'Data Pesanan Budi:';
SELECT * FROM PesananHeader WHERE PelangganID = 1;
GO

/* 2. Coba hapus Pelanggan Budi (PelangganID 1) */
PRINT 'Mencoba menghapus Budi...';

BEGIN TRANSACTION;

DELETE FROM Pelanggan
WHERE PelangganID = 1;
-- Perintah ini akan GAGAL!

ROLLBACK TRANSACTION; -- Batalkan (walaupun sudah gagal)

/* 1. Buat tabel arsip (DDL) */
CREATE TABLE ProdukArsip (
ProdukID INT PRIMARY KEY, -- Tanpa IDENTITY
SKU VARCHAR(20) NOT NULL,
NamaProduk VARCHAR(150) NOT NULL,
Harga DECIMAL(10, 2) NOT NULL,
TanggalArsip DATE DEFAULT GETDATE()
);
GO

BEGIN TRANSACTION;

/* 2. Habiskan stok Kaos (SKU PAK-001) */
UPDATE Produk SET Stok = 0 WHERE SKU = 'PAK-001';

/* 3. Salin data dari Produk ke ProdukArsip (INSERT ... SELECT) */
INSERT INTO ProdukArsip (ProdukID, SKU, NamaProduk, Harga)
SELECT ProdukID, SKU, NamaProduk, Harga
FROM Produk
WHERE Stok = 0;

/* 4. Hapus data yang sudah diarsip dari tabel Produk */
DELETE FROM Produk
WHERE Stok = 0;

/* Verifikasi */
PRINT 'Cek Produk Aktif (Kaos harus hilang):';
SELECT * FROM Produk;

PRINT 'Cek Produk Arsip (Kaos harus ada):';
SELECT * FROM ProdukArsip;

-- Jika yakin, commit
COMMIT TRANSACTION;
