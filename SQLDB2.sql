-- ============================================================
-- 1. Create Database
-- ============================================================
CREATE DATABASE IF NOT EXISTS smartcity_bintaro
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartcity_bintaro;

-- ============================================================
-- 2. Create Tables
-- ============================================================

-- Roles
CREATE TABLE IF NOT EXISTS roles (
  id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB;

-- Users
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  role_id TINYINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(30),
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Complaints
CREATE TABLE IF NOT EXISTS complaints (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reporter_id BIGINT UNSIGNED NOT NULL,
  category_id SMALLINT UNSIGNED NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('Baru','Diterima','Diproses','Selesai','Ditolak') NOT NULL DEFAULT 'Baru',
  priority ENUM('Rendah','Sedang','Tinggi') NOT NULL DEFAULT 'Sedang',
  address VARCHAR(255),
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  closed_at TIMESTAMP NULL DEFAULT NULL,
  FOREIGN KEY (reporter_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX (status),
  INDEX (category_id),
  INDEX (reporter_id)
) ENGINE=InnoDB;

-- Complaint Media
CREATE TABLE IF NOT EXISTS complaint_media (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  complaint_id BIGINT UNSIGNED NOT NULL,
  uploaded_by BIGINT UNSIGNED NULL,
  file_path VARCHAR(500) NOT NULL,
  file_type VARCHAR(100),
  file_size INT UNSIGNED,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- Assignments
CREATE TABLE IF NOT EXISTS assignments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  complaint_id BIGINT UNSIGNED NOT NULL,
  assigned_to BIGINT UNSIGNED NOT NULL,
  assigned_by BIGINT UNSIGNED NULL,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Assigned','Accepted','Rejected','In Progress','Completed') DEFAULT 'Assigned',
  notes TEXT,
  FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (assigned_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX (assigned_to),
  INDEX (complaint_id)
) ENGINE=InnoDB;

-- Status History
CREATE TABLE IF NOT EXISTS status_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  complaint_id BIGINT UNSIGNED NOT NULL,
  old_status VARCHAR(50),
  new_status VARCHAR(50) NOT NULL,
  changed_by BIGINT UNSIGNED NULL,
  note TEXT,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX (complaint_id),
  INDEX (changed_at)
) ENGINE=InnoDB;

-- Responses
CREATE TABLE IF NOT EXISTS responses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  complaint_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  message TEXT NOT NULL,
  is_public TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX (complaint_id)
) ENGINE=InnoDB;

-- ============================================================
-- 3. Seed Data
-- ============================================================

-- Roles
INSERT IGNORE INTO roles (name, description) VALUES
 ('warga','Pengguna/pelapor (citizen)'),
 ('petugas','Petugas lapangan'),
 ('admin','Operator/Admin Pemda'),
 ('manager','Manajer / Kepala Dinas'),
 ('developer','Tim IT / Support');

-- Categories
INSERT IGNORE INTO categories (name, description) VALUES
 ('Sampah','Aduan terkait sampah/penumpukan'),
 ('Jalan Rusak','Lubang/permukaan jalan rusak'),
 ('Keamanan','Isu keamanan/kriminalitas'),
 ('Transportasi','Masalah transportasi umum'),
 ('Penerangan Jalan','Lampu jalan mati'),
 ('Drainase','Tersumbat/banjir');

-- Users (gunakan ON DUPLICATE agar tidak error duplikat)
INSERT INTO users (role_id, name, email, phone, password_hash)
VALUES ((SELECT id FROM roles WHERE name='warga' LIMIT 1), 'Budi Santoso', 'budi@example.com', '08123456789', 'dummyhash_warga')
ON DUPLICATE KEY UPDATE
    role_id=VALUES(role_id), name=VALUES(name), phone=VALUES(phone), password_hash=VALUES(password_hash);

INSERT INTO users (role_id, name, email, phone, password_hash)
VALUES ((SELECT id FROM roles WHERE name='admin' LIMIT 1), 'Admin Pemda', 'admin@example.com', '08111111111', 'dummyhash_admin')
ON DUPLICATE KEY UPDATE
    role_id=VALUES(role_id), name=VALUES(name), phone=VALUES(phone), password_hash=VALUES(password_hash);

INSERT INTO users (role_id, name, email, phone, password_hash)
VALUES ((SELECT id FROM roles WHERE name='petugas' LIMIT 1), 'Petugas A', 'petugas1@example.com', '08222222222', 'dummyhash_petugas')
ON DUPLICATE KEY UPDATE
    role_id=VALUES(role_id), name=VALUES(name), phone=VALUES(phone), password_hash=VALUES(password_hash);

-- ============================================================
-- 4. Insert Dummy Complaint
-- ============================================================
INSERT INTO complaints (reporter_id, category_id, title, description, address, latitude, longitude)
VALUES (
  (SELECT id FROM users WHERE email='budi@example.com' LIMIT 1),
  (SELECT id FROM categories WHERE name='Sampah' LIMIT 1),
  'Tumpukan sampah di Jalan Melati',
  'Sudah 3 hari tumpukan sampah di depan blok C, bau menyengat dan mengganggu.',
  'Jl. Melati RT 02 RW 01',
  -6.2675123, 106.7853456
);

SET @reporter_id = (SELECT id FROM users WHERE email='budi@example.com' LIMIT 1);
SET @category_id = (SELECT id FROM categories WHERE name='Sampah' LIMIT 1);

INSERT INTO complaints (reporter_id, category_id, title, description, address, latitude, longitude)
VALUES (
  @reporter_id,
  @category_id,
  'Tumpukan sampah di Jalan Anggrek',
  'Sudah 5 hari sampah menumpuk di depan blok D, belum diangkut.',
  'Jl. Anggrek RT 03 RW 02',
  -6.2700000, 106.7800000
);

-- ambil id aduan terakhir
SET @complaint_id = LAST_INSERT_ID();

SET @petugas_id = (SELECT id FROM users WHERE email='petugas1@example.com' LIMIT 1);
SET @admin_id   = (SELECT id FROM users WHERE email='admin@example.com' LIMIT 1);

INSERT INTO assignments (complaint_id, assigned_to, assigned_by, notes)
VALUES (@complaint_id, @petugas_id, @admin_id, 'Segera ditangani oleh tim kebersihan');

-- Admin menerima aduan
UPDATE complaints SET status='Diterima', updated_at=NOW()
WHERE id=@complaint_id;

-- Petugas mulai proses
UPDATE complaints SET status='Diproses', updated_at=NOW()
WHERE id=@complaint_id;

-- Setelah selesai
UPDATE complaints SET status='Selesai', closed_at=NOW(), updated_at=NOW()
WHERE id=@complaint_id;

-- Admin kasih tanggapan ke warga
INSERT INTO responses (complaint_id, user_id, message, is_public)
VALUES (@complaint_id, @admin_id, 'Aduan sudah diproses dan sampah sudah diangkut. Terima kasih atas laporannya.', 1);

-- Petugas juga bisa kasih catatan
INSERT INTO responses (complaint_id, user_id, message, is_public)
VALUES (@complaint_id, @petugas_id, 'Sampah sudah dibersihkan pukul 10 pagi.', 1);

INSERT INTO complaint_media (complaint_id, uploaded_by, file_path, file_type, file_size)
VALUES (@complaint_id, @petugas_id, '/uploads/foto_sampah_selesai.jpg', 'image/jpeg', 400000);

-- Semua aduan dengan reporter + kategori
SELECT c.id, c.title, c.status, u.name AS reporter, cat.name AS kategori, c.created_at
FROM complaints c
JOIN users u ON c.reporter_id=u.id
JOIN categories cat ON c.category_id=cat.id
ORDER BY c.created_at DESC;

-- Aduan + petugas yang ditugaskan
SELECT c.id, c.title, a.assigned_at, u.name AS petugas, a.status
FROM assignments a
JOIN complaints c ON a.complaint_id=c.id
JOIN users u ON a.assigned_to=u.id
WHERE c.id=@complaint_id;

-- Respon terkait aduan
SELECT r.message, u.name AS responder, r.created_at
FROM responses r
JOIN users u ON r.user_id=u.id
WHERE r.complaint_id=@complaint_id;

-- Media bukti
SELECT file_path, file_type, file_size, created_at
FROM complaint_media
WHERE complaint_id=@complaint_id;

-- Statistik ringkas
-- Jumlah aduan per kategori
SELECT cat.name AS kategori, COUNT(*) AS total
FROM complaints c
JOIN categories cat ON c.category_id=cat.id
GROUP BY cat.name;

-- Jumlah aduan per status
SELECT status, COUNT(*) AS total
FROM complaints
GROUP BY status;