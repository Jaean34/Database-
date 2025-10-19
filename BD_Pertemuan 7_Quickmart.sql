-- PERTEMUAN 7

-- ===========================================
-- BAGIAN 1. DDL Tambahan 
-- ===========================================

-- (1) ALTER ADD - Tambah kolom baru 'berat_produk' pada tabel produk
ALTER TABLE produk
ADD COLUMN berat_produk DECIMAL(6,2) DEFAULT 0.00;

-- (2) ALTER CHANGE - Ubah nama kolom 'berat_produk' menjadi 'berat_kg'
ALTER TABLE produk
CHANGE COLUMN berat_produk berat_kg DECIMAL(6,2);

-- (3) RENAME dan DROP - Ganti nama tabel & hapus kolom
RENAME TABLE kategori TO kategori_produk;
ALTER TABLE produk DROP COLUMN berat_kg;

-- (4) SHOW untuk melihat hasil
SHOW TABLES;
SHOW COLUMNS FROM produk;

-- ===========================================
-- BAGIAN 2. VIEW & MATERIALIZED VIEW 
-- ===========================================

-- (1) VIEW transaksi lengkap
CREATE OR REPLACE VIEW view_transaksi_lengkap AS
SELECT 
    u.Nama AS Pembeli,
    p.Nama_produk,
    ps.Jumlah_barang,
    ps.Total_harga,
    ps.Status
FROM pesanan ps
JOIN user u ON ps.User_id = u.User_id
JOIN produk p ON ps.Produk_id = p.Produk_id;

-- (2) VIEW stok rendah (produk dengan stok < 10)
CREATE OR REPLACE VIEW view_stok_rendah AS
SELECT Nama_produk, Stok
FROM produk
WHERE Stok < 10;

-- (3) Simulasi MATERIALIZED VIEW: tabel hasil agregasi
CREATE TABLE IF NOT EXISTS mv_penjualan_harian AS
SELECT 
    DATE(ps.Tanggal_pesanan) AS tanggal,
    p.Nama_produk,
    SUM(ps.Jumlah_barang) AS total_terjual,
    SUM(ps.Total_harga) AS total_penjualan
FROM pesanan ps
JOIN produk p ON ps.Produk_id = p.Produk_id
GROUP BY DATE(ps.Tanggal_pesanan), p.Nama_produk;

-- ===========================================
-- BAGIAN 3. STORED PROCEDURE Baru 
-- ===========================================
DELIMITER //

-- (1) SP menambah kolom dinamis ke tabel manapun
CREATE PROCEDURE sp_tambah_kolom(
    IN p_tabel VARCHAR(50),
    IN p_definisi VARCHAR(100)
)
BEGIN
    SET @sql = CONCAT('ALTER TABLE ', p_tabel, ' ADD ', p_definisi);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
CALL sp_tambah_kolom('produk', 'warna VARCHAR(50)');

-- (2) SP refresh materialized view (mv_penjualan_harian)
CREATE PROCEDURE sp_refresh_mv_penjualan(IN p_tanggal DATE)
BEGIN
    DELETE FROM mv_penjualan_harian WHERE tanggal = p_tanggal;
    INSERT INTO mv_penjualan_harian
    SELECT 
        DATE(ps.Tanggal_pesanan) AS tanggal,
        p.Nama_produk,
        SUM(ps.Jumlah_barang),
        SUM(ps.Total_harga)
    FROM pesanan ps
    JOIN produk p ON ps.Produk_id = p.Produk_id
    WHERE DATE(ps.Tanggal_pesanan) = p_tanggal
    GROUP BY p.Nama_produk;
END //
CALL sp_refresh_mv_penjualan(CURDATE());

-- (3) SP tampilkan semua tabel di database aktif (pakai SHOW)
CREATE PROCEDURE sp_daftar_tabel()
BEGIN
    SHOW TABLES;
END //
CALL sp_daftar_tabel();

DELIMITER ;