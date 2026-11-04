-- =======================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU QLTKB (HỆ THỐNG QUẢN LÝ THỜI KHÓA BIỂU)
-- Khớp 100% với toàn bộ Model Entity Framework trong dự án
-- =======================================================

-- 1. Tạo Database CNPM nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CNPM')
BEGIN
    CREATE DATABASE CNPM;
END
GO

USE CNPM;
GO

-- 2. Tạo bảng VaiTro
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'VaiTro')
BEGIN
    CREATE TABLE VaiTro (
        VaiTroID INT IDENTITY(1,1) PRIMARY KEY,
        TenVaiTro NVARCHAR(50) NOT NULL UNIQUE,
        MoTa NVARCHAR(255) NULL
    );
END
GO

-- 3. Tạo bảng TaiKhoan
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TaiKhoan')
BEGIN
    CREATE TABLE TaiKhoan (
        TaiKhoanID INT IDENTITY(1,1) PRIMARY KEY,
        TenDangNhap NVARCHAR(50) NOT NULL UNIQUE,
        Email NVARCHAR(255) NOT NULL UNIQUE,
        MatKhau NVARCHAR(255) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        VaiTroID INT NOT NULL,
        TrangThai BIT NOT NULL DEFAULT 1,
        NgayTao DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_TaiKhoan_VaiTro
            FOREIGN KEY (VaiTroID)
            REFERENCES VaiTro(VaiTroID)
    );
END
GO

-- 4. Tạo bảng HocPhan
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HocPhan')
BEGIN
    CREATE TABLE HocPhan (
        HocPhanID INT IDENTITY(1,1) PRIMARY KEY,
        MaHocPhan NVARCHAR(20) NOT NULL UNIQUE,
        TenHocPhan NVARCHAR(150) NOT NULL,
        SoTinChi INT NOT NULL DEFAULT 3,
        SoTietLyThuyet INT NOT NULL DEFAULT 0,
        SoTietThucHanh INT NOT NULL DEFAULT 0,
        MoTa NVARCHAR(500) NULL,
        TrangThai BIT NOT NULL DEFAULT 1
    );
END
GO

-- 5. Tạo bảng PhongHoc
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PhongHoc')
BEGIN
    CREATE TABLE PhongHoc (
        PhongHocID INT IDENTITY(1,1) PRIMARY KEY,
        MaPhong NVARCHAR(20) NOT NULL UNIQUE,
        TenPhong NVARCHAR(100) NOT NULL,
        ToaNha NVARCHAR(100) NULL,
        SucChua INT NOT NULL DEFAULT 40,
        LoaiPhong NVARCHAR(50) NULL,
        TrangThai BIT NOT NULL DEFAULT 1
    );
END
GO

-- 6. Tạo bảng GiangVien
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GiangVien')
BEGIN
    CREATE TABLE GiangVien (
        GiangVienID INT IDENTITY(1,1) PRIMARY KEY,
        TaiKhoanID INT NOT NULL,
        MaGiangVien NVARCHAR(20) NOT NULL UNIQUE,
        Khoa NVARCHAR(100) NULL,
        BoMon NVARCHAR(100) NULL,
        HocVi NVARCHAR(50) NULL,
        SoDienThoai NVARCHAR(15) NULL,

        CONSTRAINT FK_GiangVien_TaiKhoan
            FOREIGN KEY (TaiKhoanID)
            REFERENCES TaiKhoan(TaiKhoanID)
    );
END
GO

-- 7. Tạo bảng SinhVien
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SinhVien')
BEGIN
    CREATE TABLE SinhVien (
        SinhVienID INT IDENTITY(1,1) PRIMARY KEY,
        TaiKhoanID INT NOT NULL,
        MaSinhVien NVARCHAR(20) NOT NULL UNIQUE,
        Lop NVARCHAR(50) NULL,
        Nganh NVARCHAR(100) NULL,
        KhoaHoc NVARCHAR(20) NULL,
        SoDienThoai NVARCHAR(15) NULL,

        CONSTRAINT FK_SinhVien_TaiKhoan
            FOREIGN KEY (TaiKhoanID)
            REFERENCES TaiKhoan(TaiKhoanID)
    );
END
GO

-- =======================================================
-- 8. NẠP DỮ LIỆU MẪU BAN ĐẦU
-- =======================================================

-- 8.1. Các Vai trò hệ thống
IF NOT EXISTS (SELECT * FROM VaiTro WHERE TenVaiTro = 'Admin')
    INSERT INTO VaiTro (TenVaiTro, MoTa) VALUES (N'Admin', N'Quản trị viên hệ thống');

IF NOT EXISTS (SELECT * FROM VaiTro WHERE TenVaiTro = 'AcademicStaff')
    INSERT INTO VaiTro (TenVaiTro, MoTa) VALUES (N'AcademicStaff', N'Giáo vụ / Phòng đào tạo');

IF NOT EXISTS (SELECT * FROM VaiTro WHERE TenVaiTro = 'GiangVien')
    INSERT INTO VaiTro (TenVaiTro, MoTa) VALUES (N'GiangVien', N'Giảng viên');

-- Đảm bảo vai trò SinhVien có VaiTroID = 6 (do code AccountController hardcode ID = 6)
IF NOT EXISTS (SELECT * FROM VaiTro WHERE VaiTroID = 6)
BEGIN
    SET IDENTITY_INSERT VaiTro ON;
    INSERT INTO VaiTro (VaiTroID, TenVaiTro, MoTa) VALUES (6, N'SinhVien', N'Sinh viên');
    SET IDENTITY_INSERT VaiTro OFF;
END
GO

-- 8.2. Tài khoản quản trị và mẫu
DECLARE @AdminRoleID INT = (SELECT TOP 1 VaiTroID FROM VaiTro WHERE TenVaiTro = 'Admin');
DECLARE @StaffRoleID INT = (SELECT TOP 1 VaiTroID FROM VaiTro WHERE TenVaiTro = 'AcademicStaff');
DECLARE @GvRoleID INT = (SELECT TOP 1 VaiTroID FROM VaiTro WHERE TenVaiTro = 'GiangVien');
DECLARE @SvRoleID INT = 6;

IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE TenDangNhap = 'admin')
BEGIN
    INSERT INTO TaiKhoan (TenDangNhap, Email, MatKhau, HoTen, VaiTroID, TrangThai, NgayTao) VALUES
    ('admin', 'admin@example.com', 'admin123', N'Quản Trị Viên', @AdminRoleID, 1, GETDATE());
END

IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE TenDangNhap = 'giaovu')
BEGIN
    INSERT INTO TaiKhoan (TenDangNhap, Email, MatKhau, HoTen, VaiTroID, TrangThai, NgayTao) VALUES
    ('giaovu', 'giaovu@example.com', '123456', N'Cán Bộ Giáo Vụ', @StaffRoleID, 1, GETDATE());
END

IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE TenDangNhap = 'gv_hung')
BEGIN
    INSERT INTO TaiKhoan (TenDangNhap, Email, MatKhau, HoTen, VaiTroID, TrangThai, NgayTao) VALUES
    ('gv_hung', 'hung@example.com', '123456', N'ThS. Nguyễn Văn Hùng', @GvRoleID, 1, GETDATE());
END

IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE TenDangNhap = 'sv_nam')
BEGIN
    INSERT INTO TaiKhoan (TenDangNhap, Email, MatKhau, HoTen, VaiTroID, TrangThai, NgayTao) VALUES
    ('sv_nam', 'nam@example.com', '123456', N'Trần Văn Nam', @SvRoleID, 1, GETDATE());
END
GO

-- 8.3. Bổ sung liên kết Giảng viên & Sinh viên
IF NOT EXISTS (SELECT * FROM GiangVien WHERE MaGiangVien = 'GV001')
BEGIN
    DECLARE @GvTaiKhoanID INT = (SELECT TOP 1 TaiKhoanID FROM TaiKhoan WHERE TenDangNhap = 'gv_hung');
    IF @GvTaiKhoanID IS NOT NULL
    BEGIN
        INSERT INTO GiangVien (TaiKhoanID, MaGiangVien, Khoa, BoMon, HocVi, SoDienThoai) VALUES
        (@GvTaiKhoanID, 'GV001', N'Công nghệ thông tin', N'Kỹ thuật phần mềm', N'Thạc sĩ', '0912345678');
    END
END
GO

IF NOT EXISTS (SELECT * FROM SinhVien WHERE MaSinhVien = 'SV001')
BEGIN
    DECLARE @SvTaiKhoanID INT = (SELECT TOP 1 TaiKhoanID FROM TaiKhoan WHERE TenDangNhap = 'sv_nam');
    IF @SvTaiKhoanID IS NOT NULL
    BEGIN
        INSERT INTO SinhVien (TaiKhoanID, MaSinhVien, Lop, Nganh, KhoaHoc, SoDienThoai) VALUES
        (@SvTaiKhoanID, 'SV001', N'D20CNPM01', N'Công nghệ thông tin', N'K20', '0987654321');
    END
END
GO

-- 8.4. Dữ liệu học phần mẫu (chỉ insert nếu mã chưa tồn tại)
IF NOT EXISTS (SELECT * FROM HocPhan WHERE MaHocPhan = 'INT1306')
    INSERT INTO HocPhan (MaHocPhan, TenHocPhan, SoTinChi, SoTietLyThuyet, SoTietThucHanh, MoTa, TrangThai) VALUES
    ('INT1306', N'Lập trình Web nâng cao', 3, 30, 30, N'Học về ASP.NET Core, MVC và Entity Framework', 1);

IF NOT EXISTS (SELECT * FROM HocPhan WHERE MaHocPhan = 'INT1310')
    INSERT INTO HocPhan (MaHocPhan, TenHocPhan, SoTinChi, SoTietLyThuyet, SoTietThucHanh, MoTa, TrangThai) VALUES
    ('INT1310', N'Cơ sở dữ liệu', 3, 36, 18, N'Kiến thức về RDBMS, SQL Server, thiết kế CSDL', 1);

IF NOT EXISTS (SELECT * FROM HocPhan WHERE MaHocPhan = 'INT1315')
    INSERT INTO HocPhan (MaHocPhan, TenHocPhan, SoTinChi, SoTietLyThuyet, SoTietThucHanh, MoTa, TrangThai) VALUES
    ('INT1315', N'Công nghệ phần mềm', 3, 45, 0, N'Quy trình phát triển phần mềm, Agile/Scrum', 1);

IF NOT EXISTS (SELECT * FROM HocPhan WHERE MaHocPhan = 'MAT1101')
    INSERT INTO HocPhan (MaHocPhan, TenHocPhan, SoTinChi, SoTietLyThuyet, SoTietThucHanh, MoTa, TrangThai) VALUES
    ('MAT1101', N'Toán rời rạc', 3, 45, 0, N'Đồ thị, logic toán và đại số boolean', 1);
GO

-- 8.5. Dữ liệu phòng học mẫu
IF NOT EXISTS (SELECT * FROM PhongHoc WHERE MaPhong = 'A101')
    INSERT INTO PhongHoc (MaPhong, TenPhong, ToaNha, SucChua, LoaiPhong, TrangThai) VALUES
    ('A101', N'Phòng lý thuyết 101', N'Tòa A', 60, N'Lý thuyết', 1);

IF NOT EXISTS (SELECT * FROM PhongHoc WHERE MaPhong = 'A102')
    INSERT INTO PhongHoc (MaPhong, TenPhong, ToaNha, SucChua, LoaiPhong, TrangThai) VALUES
    ('A102', N'Phòng lý thuyết 102', N'Tòa A', 60, N'Lý thuyết', 1);

IF NOT EXISTS (SELECT * FROM PhongHoc WHERE MaPhong = 'LAB01')
    INSERT INTO PhongHoc (MaPhong, TenPhong, ToaNha, SucChua, LoaiPhong, TrangThai) VALUES
    ('LAB01', N'Phòng máy thực hành 01', N'Tòa C', 40, N'Thực hành', 1);

IF NOT EXISTS (SELECT * FROM PhongHoc WHERE MaPhong = 'LAB02')
    INSERT INTO PhongHoc (MaPhong, TenPhong, ToaNha, SucChua, LoaiPhong, TrangThai) VALUES
    ('LAB02', N'Phòng máy thực hành 02', N'Tòa C', 40, N'Thực hành', 1);
GO
