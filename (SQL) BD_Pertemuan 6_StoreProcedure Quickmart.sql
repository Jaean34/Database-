-------------------- DDL (Stored Procedure) --------------------
-- Membuat Database
CREATE DATABASE marketplace1;
USE marketplace1;

-- Membuat table USER
CREATE TABLE USER (
    User_id INT AUTO_INCREMENT PRIMARY KEY, 	-- AUTO ADA SAAT INPUT
    Nama VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Role ENUM('Penjual', 'Pembeli') NOT NULL
);
SELECT * FROM user;

-- Tabel Kategori Produk (yg input penjual)
CREATE TABLE Kategori (
    Kategori_id INT AUTO_INCREMENT PRIMARY KEY, 		-- AUTO ADA SAAT INPUT
    Nama_kategori VARCHAR(100) NOT NULL,
    Deskripsi TEXT,
    Tanggal_input DATETIME DEFAULT CURRENT_TIMESTAMP 	-- AUTO ADA SAAT INPUT
);
SELECT * FROM kategori;

-- Tabel Produk (yg input penjual)
CREATE TABLE Produk (
    Produk_id INT AUTO_INCREMENT PRIMARY KEY,         	-- AUTO ADA SAAT INPUT
    User_id INT NOT NULL,           				  	-- penjual
    Kategori_id INT NOT NULL,       				  	-- kategori produk
    Nama_produk VARCHAR(150) NOT NULL,
    Harga DECIMAL(12,2) NOT NULL,
    Stok INT NOT NULL,
    Tanggal_upload DATETIME DEFAULT CURRENT_TIMESTAMP, 	-- AUTO ADA SAAT PENJUAL INPUT
    FOREIGN KEY (User_id) REFERENCES User(User_id),
    FOREIGN KEY (Kategori_id) REFERENCES Kategori(Kategori_id)
);
SELECT * FROM produk;

-- Tabel Pesanan (yg input pembeli)
CREATE TABLE Pesanan (
    Pesanan_id INT AUTO_INCREMENT PRIMARY KEY, 			-- AUTO ADA SAAT INPUT
    User_id INT NOT NULL,         						-- pembeli
    Produk_id INT NOT NULL,       						-- produk yang dibeli
    Jumlah_barang INT NOT NULL,
    Total_harga DECIMAL(12,2) NOT NULL,
    status ENUM('Menunggu', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan') DEFAULT 'Menunggu', -- AUTO ADA SAAT PEMBELI INPUT
    Tanggal_pesanan DATETIME DEFAULT CURRENT_TIMESTAMP,	-- AUTO ADA SAAT INPUT
    FOREIGN KEY (User_id) REFERENCES User(User_id),
    FOREIGN KEY (Produk_id) REFERENCES Produk(Produk_id)
);
SELECT * FROM pesanan;
ALTER TABLE Pesanan RENAME COLUMN Jumlah TO Harga;
ALTER TABLE Pesanan RENAME COLUMN Jumlah TO Jumlah_barang;
ALTER TABLE Pesanan RENAME COLUMN status TO Status;

-- Tabel Pembayaran (sistem)
CREATE TABLE Pembayaran (
    Pembayaran_id INT AUTO_INCREMENT PRIMARY KEY, 				-- AUTO ADA SAAT INPUT
    Pesanan_id INT NOT NULL,
    Metode ENUM('Transfer Bank', 'E-Wallet', 'COD') NOT NULL,
    Harga DECIMAL(12,2) NOT NULL,
    Status ENUM('Menunggu', 'Berhasil', 'Gagal') DEFAULT 'Menunggu',
    Tanggal_bayar DATETIME DEFAULT CURRENT_TIMESTAMP, 			-- AUTO ADA SAAT INPUT
    FOREIGN KEY (Pesanan_id) REFERENCES Pesanan(Pesanan_id)
);
SELECT * FROM pembayaran;

-- View untuk menampilkan transaksi lengkap (table virtual)
CREATE VIEW view_transaksi_lengkap AS
SELECT 
    u.nama AS nama_pembeli,
    p.nama_produk,
    ps.jumlah_barang,
    ps.total_harga,
    ps.status AS status_pesanan,
    pb.metode,
    pb.status AS status_pembayaran
FROM pesanan ps
JOIN user u ON ps.user_id = u.user_id
JOIN produk p ON ps.produk_id = p.produk_id
JOIN pembayaran pb ON ps.pesanan_id = pb.pesanan_id;
SELECT * FROM view_transaksi_lengkap;


-------------------- DML (Stored Procedure) --------------------
-- A. Tambah Data
-- Tambah User
DELIMITER //
CREATE PROCEDURE sp_tambah_user(
    IN p_nama VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_role ENUM('Penjual','Pembeli')
)
BEGIN
    INSERT INTO user(Nama, Email, Role)
    VALUES (p_nama, p_email, p_role);
END //
DELIMITER ;

CALL sp_tambah_user ('Lala', 'lala@gmail.com', 'Pembeli');
SELECT * FROM User;

-- Tambah Kategori
DELIMITER //
CREATE PROCEDURE sp_tambah_kategori(
    IN p_nama_kategori VARCHAR(100),
    IN p_deskripsi TEXT
)
BEGIN
    INSERT INTO kategori(Nama_kategori, Deskripsi)
    VALUES (p_nama_kategori, p_deskripsi);
END //
DELIMITER ;

CALL sp_tambah_kategori ('Make Up', 'Alat kecantikan lipstik, bedak, eyeshadow');
SELECT * FROM Kategori;

-- Tambah Produk
DELIMITER //
CREATE PROCEDURE sp_tambah_produk(
    IN p_user_id INT,
    IN p_kategori_id INT,
    IN p_nama_produk VARCHAR(150),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    INSERT INTO produk(User_id, Kategori_id, Nama_produk, Harga, Stok)
    VALUES (p_user_id, p_kategori_id, p_nama_produk, p_harga, p_stok);
END //
DELIMITER ;

CALL sp_tambah_produk ('3', '4', 'Liptint Dior', '500000', '20');
SELECT * FROM produk;

-- Buat Pesanan
DELIMITER //
CREATE PROCEDURE sp_buat_pesanan(
    IN p_user_id INT,
    IN p_produk_id INT,
    IN p_jumlah INT
)
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT harga * p_jumlah INTO v_total FROM produk WHERE produk_id = p_produk_id;
			-- hitung total harga
    INSERT INTO pesanan(User_id, Produk_id, Jumlah_barang, Total_harga)
    VALUES (p_user_id, p_produk_id, p_jumlah, v_total);
END //
DELIMITER ;

CALL sp_buat_pesanan ('6', '6', '1'); -- Harga sudah terhitung otomatis jd tdk diinputkan
SELECT * FROM pesanan;

-- Tambah Pembayaran
DELIMITER //
CREATE PROCEDURE sp_tambah_pembayaran(
    IN p_pesanan_id INT,
    IN p_metode ENUM('Transfer Bank','E-Wallet','COD'),
    IN p_harga DECIMAL(12,2)
)
BEGIN
    INSERT INTO pembayaran(Pesanan_id, Metode, Harga)
    VALUES (p_pesanan_id, p_metode, p_harga);
END //
DELIMITER ;

CALL sp_tambah_pembayaran ('4', 'Transfer Bank', '500000');
SELECT * FROM pembayaran;

-- B. Update Data
-- Update Status Pesanan
DELIMITER //
CREATE PROCEDURE sp_upstatus_pesanan(
    IN p_pesanan_id INT,
    IN p_status ENUM('Menunggu','Diproses','Dikirim','Selesai','Dibatalkan')
)
BEGIN
    UPDATE pesanan SET status = p_status WHERE pesanan_id = p_pesanan_id;
END //
DELIMITER ;

CALL sp_upstatus_pesanan ('1', 'Dikirim');
SELECT pesanan_id, status FROM pesanan WHERE pesanan_id = 1;

-- Update Stok Produk
DELIMITER //
CREATE PROCEDURE sp_upstok_produk(
    IN p_produk_id INT,
    IN p_stok_baru INT
)
BEGIN
    UPDATE produk SET stok = p_stok_baru WHERE produk_id = p_produk_id;
END //
DELIMITER ;

CALL sp_upstok_produk ('6', '19');
SELECT produk_id, stok FROM produk;

-- C. Hapus Data
-- Hapus Produk
DELIMITER //
CREATE PROCEDURE sp_hapus_produk(IN p_produk_id INT)
BEGIN
    DELETE FROM produk WHERE produk_id = p_produk_id;
END //
DELIMITER ;
CALL sp_hapus_produk(6);
SELECT * FROM pesanan WHERE produk_id = 6;

-- Hapus Pesanan
DELIMITER //
CREATE PROCEDURE sp_hapus_pesanan(IN p_pesanan_id INT)
BEGIN
    DELETE FROM pesanan WHERE pesanan_id = p_pesanan_id;
END //
DELIMITER ;
CALL sp_hapus_pesanan(4);


-------------------- DQL (Stored Procedure) --------------------
-- Laporan Penjualan Harian
DELIMITER //
CREATE PROCEDURE sp_lap_penjualan(IN p_tanggal DATE)
BEGIN
    SELECT 
        p.nama_produk,
        SUM(ps.jumlah_barang) AS total_terjual,
        SUM(ps.total_harga) AS total_penjualan
    FROM pesanan ps
    JOIN produk p ON ps.produk_id = p.produk_id
    WHERE DATE(ps.tanggal_pesanan) = p_tanggal
    GROUP BY p.nama_produk;
END //
DELIMITER ;
CALL sp_lap_penjualan(CURDATE());

-- Riwayat Pesanan Pembeli
DELIMITER //
CREATE PROCEDURE sp_riwayat_pesanan(IN p_user_id INT)
BEGIN
    SELECT 
        ps.pesanan_id,
        p.nama_produk,
        ps.jumlah_barang,
        ps.total_harga,
        ps.status,
        ps.tanggal_pesanan
    FROM pesanan ps
    JOIN produk p ON ps.produk_id = p.produk_id
    WHERE ps.user_id = p_user_id;
END //
DELIMITER ;
CALL sp_riwayat_pesanan(2); -- riwayat pesanan user id = 2
SELECT*FROM pesanan;

-- Cek Stok Menipis Kurang dr 10
DELIMITER //
CREATE PROCEDURE sp_cek_stok()
BEGIN
    SELECT nama_produk, stok FROM produk WHERE stok < 10;
END //
DELIMITER ;
CALL sp_cek_stok();
