CREATE DATABASE RS;
USE RS;

-- 1. Tabel DOKTER
CREATE TABLE DOKTER (
    ID_Dokter VARCHAR(10) PRIMARY KEY,
    Nama_Dokter VARCHAR(100) NOT NULL,
    Spesialisasi VARCHAR(50),
    Nomor_STR VARCHAR(50) UNIQUE,
    Nomor_Telepon VARCHAR(15),
    Email VARCHAR(100)
);

-- 2. Tabel PASIEN
CREATE TABLE PASIEN (
    No_Rekam_Medis VARCHAR(10) PRIMARY KEY,
    Nama_Pasien VARCHAR(100) NOT NULL,
    Tempat_Lahir VARCHAR(50),
    Tanggal_Lahir DATE,
    Jenis_Kelamin CHAR(1) CHECK (Jenis_Kelamin IN ('L', 'P')),
    Alamat VARCHAR(255),
    Nomor_Telepon VARCHAR(15),
    Golongan_Darah VARCHAR(2) CHECK (Golongan_Darah IN ('A', 'B', 'AB', 'O')),
    Tanggal_Pendaftaran DATE
);

-- 3. Tabel OBAT
CREATE TABLE OBAT (
    Kode_Obat VARCHAR(10) PRIMARY KEY,
    Nama_Obat VARCHAR(100) NOT NULL,
    Bentuk_Obat VARCHAR(20) CHECK (Bentuk_Obat IN ('Tablet', 'Kapsul', 'Sirup', 'Salep', 'Lainnya')),
    Harga_Satuan DECIMAL(10, 2) NOT NULL,
    Stok_Obat INT NOT NULL
);

-- 4. Tabel KUNJUNGAN
CREATE TABLE KUNJUNGAN (
    ID_Kunjungan VARCHAR(15) PRIMARY KEY,
    Tanggal_Kunjungan DATE NOT NULL,
    No_Rekam_Medis VARCHAR(10) NOT NULL,
    ID_Dokter VARCHAR(10) NOT NULL,
    Keluhan_Utama VARCHAR(255),
    FOREIGN KEY (No_Rekam_Medis) REFERENCES PASIEN(No_Rekam_Medis),
    FOREIGN KEY (ID_Dokter) REFERENCES DOKTER(ID_Dokter)
);

-- 5. Tabel REKAM_MEDIS
CREATE TABLE REKAM_MEDIS (
    ID_Kunjungan VARCHAR(15) PRIMARY KEY,
    Tanggal_Pemeriksaan DATE NOT NULL,
    Anamnesis TEXT,
    Pemeriksaan_Fisik TEXT,
    Diagnosa VARCHAR(255),
    Tindakan_Terapi TEXT,
    FOREIGN KEY (ID_Kunjungan) REFERENCES KUNJUNGAN(ID_Kunjungan)
);

-- 6. Tabel RESEP
CREATE TABLE RESEP (
    No_Resep VARCHAR(15) PRIMARY KEY,
    ID_Kunjungan VARCHAR(15) NOT NULL,
    Tanggal_Resep DATE NOT NULL,
    FOREIGN KEY (ID_Kunjungan) REFERENCES KUNJUNGAN(ID_Kunjungan)
);

-- 7. Tabel DETAIL_RESEP (Tabel penghubung untuk relasi M:N antara RESEP dan OBAT)
CREATE TABLE DETAIL_RESEP (
    No_Resep VARCHAR(15),
    Kode_Obat VARCHAR(10),
    Jumlah INT NOT NULL,
    Dosis VARCHAR(50),
    Aturan_Pakai VARCHAR(100),
    PRIMARY KEY (No_Resep, Kode_Obat),
    FOREIGN KEY (No_Resep) REFERENCES RESEP(No_Resep),
    FOREIGN KEY (Kode_Obat) REFERENCES OBAT(Kode_Obat)
);

-- Data Dummy untuk DOKTER
INSERT INTO DOKTER (ID_Dokter, Nama_Dokter, Spesialisasi, Nomor_STR, Nomor_Telepon, Email) VALUES
('D001', 'Dr. Santoso', 'Umum', 'STR-12345', '08123456789', 'santoso.s@klinik.com'),
('D002', 'Dr. Citra Dewi', 'Anak', 'STR-67890', '08567890123', 'citra.d@klinik.com');

-- Data Dummy untuk PASIEN
INSERT INTO PASIEN (No_Rekam_Medis, Nama_Pasien, Tempat_Lahir, Tanggal_Lahir, Jenis_Kelamin, Alamat, Nomor_Telepon, Golongan_Darah, Tanggal_Pendaftaran) VALUES
('RM001', 'Ahmad Raya', 'Jakarta', '1990-05-10', 'L', 'Jl. Merdeka No. 1', '08111111111', 'A', '2025-01-15'),
('RM002', 'Bunga Citra', 'Bandung', '2000-11-20', 'P', 'Jl. Indah No. 5', '08222222222', 'O', '2025-01-20'),
('RM003', 'Charlie P.', 'Surabaya', '1985-03-01', 'L', 'Jl. Mawar No. 10', '08333333333', 'B', '2025-02-01');

-- Data Dummy untuk OBAT
INSERT INTO OBAT (Kode_Obat, Nama_Obat, Bentuk_Obat, Harga_Satuan, Stok_Obat) VALUES
('O001', 'Paracetamol 500mg', 'Tablet', 500.00, 150),
('O002', 'Amoxicillin Sirup', 'Sirup', 15000.00, 0), -- Stok Habis
('O003', 'Salep Kulit 10g', 'Salep', 8000.00, 75),
('O004', 'Vitamin C', 'Kapsul', 200.00, 200);

-- Data Dummy untuk KUNJUNGAN (RM001 berkunjung 3x, RM002 2x, RM003 1x)
INSERT INTO KUNJUNGAN (ID_Kunjungan, Tanggal_Kunjungan, No_Rekam_Medis, ID_Dokter, Keluhan_Utama) VALUES
('K-001', '2025-10-01', 'RM001', 'D001', 'Demam dan pusing'),
('K-002', '2025-10-05', 'RM002', 'D002', 'Batuk dan pilek pada anak'),
('K-003', '2025-10-10', 'RM001', 'D001', 'Kontrol pasca demam'),
('K-004', '2025-10-15', 'RM003', 'D001', 'Sakit gigi'),
('K-005', '2025-10-18', 'RM002', 'D002', 'Ruam kulit'),
('K-006', '2025-10-20', 'RM001', 'D001', 'Flu biasa');

-- Data Dummy untuk REKAM_MEDIS
INSERT INTO REKAM_MEDIS (ID_Kunjungan, Tanggal_Pemeriksaan, Anamnesis, Pemeriksaan_Fisik, Diagnosa, Tindakan_Terapi) VALUES
('K-001', '2025-10-01', 'Pasien mengeluh demam sejak 3 hari', 'Suhu 38.5C, TD 120/80', 'Common Cold', 'Pemberian obat penurun panas dan vitamin'),
('K-002', '2025-10-05', 'Anak batuk parah di malam hari', 'Suhu 37.0C', 'Bronkitis ringan', 'Pemberian antibiotik dan sirup batuk'),
('K-003', '2025-10-10', 'Pasien merasa sudah lebih baik', 'Suhu 36.5C', 'Observasi', 'Tidak ada resep baru'),
('K-004', '2025-10-15', 'Pasien mengeluh sakit gigi berdenyut', 'Gigi geraham bengkak', 'Pulpitis', 'Pemberian obat pereda nyeri dan anjuran ke dokter gigi');

-- Data Dummy untuk RESEP
INSERT INTO RESEP (No_Resep, ID_Kunjungan, Tanggal_Resep) VALUES
('R-001', 'K-001', '2025-10-01'),
('R-002', 'K-002', '2025-10-05'),
('R-003', 'K-005', '2025-10-18');

-- Data Dummy untuk DETAIL_RESEP
INSERT INTO DETAIL_RESEP (No_Resep, Kode_Obat, Jumlah, Dosis, Aturan_Pakai) VALUES
('R-001', 'O001', 10, '500mg', '3 x 1 sesudah makan'),
('R-001', 'O004', 15, '1 tablet', '1 x 1 sesudah makan'),
('R-002', 'O002', 1, '5ml', '2 x 1 sesudah makan'), -- Obat stok habis
('R-003', 'O003', 1, 'Secukupnya', '2 x sehari dioles');

-- Kujungan ke Dokter
SELECT
    D.Nama_Dokter,
    P.No_Rekam_Medis,
    P.Nama_Pasien,
    K.Tanggal_Kunjungan
FROM
    DOKTER D
JOIN
    KUNJUNGAN K ON D.ID_Dokter = K.ID_Dokter
JOIN
    PASIEN P ON K.No_Rekam_Medis = P.No_Rekam_Medis
ORDER BY
    D.Nama_Dokter, K.Tanggal_Kunjungan;

-- Obat
SELECT
    Kode_Obat,
    Nama_Obat,
    Stok_Obat,
    Bentuk_Obat
FROM
    OBAT
WHERE
    Stok_Obat <= 0;
    
-- Rekaman Medis
SELECT
    K.No_Rekam_Medis,
    P.Nama_Pasien,
    COUNT(K.ID_Kunjungan) AS Total_Kunjungan
FROM
    KUNJUNGAN K
JOIN
    PASIEN P ON K.No_Rekam_Medis = P.No_Rekam_Medis
GROUP BY
    K.No_Rekam_Medis, P.Nama_Pasien
ORDER BY
    Total_Kunjungan DESC
LIMIT 1; -- Mengambil Pasien dengan Total Kunjungan Tertinggi