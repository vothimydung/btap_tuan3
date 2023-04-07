
--Câu 1
CREATE PROCEDURE Insert_Hangsx (@mahangsx VARCHAR(50),
								@tenhang VARCHAR(50),
								@diachi VARCHAR(100),
								@sodt VARCHAR(20),
								@email VARCHAR(50))
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        PRINT 'Tên hãng sản xuất đã tồn tại, vui lòng nhập tên khác!'
    END
    ELSE
    BEGIN
        INSERT INTO Hangsx (mahangsx, tenhang, diachi, sodt, email)
        VALUES (@mahangsx, @tenhang, @diachi, @sodt, @email)
        PRINT 'Thêm hãng sản xuất thành công!'
    END
END
EXEC Insert_Hangsx 'H01','Samsung','Korea','011-08271717','ss@gmail.com.kr'

--câu 2
CREATE PROCEDURE Insert_SanPham (@masp varchar(20),
								 @mahangsx varchar(20),
								 @tensp nvarchar(50),
								 @soluong int,
								 @mausac nvarchar(50),
								 @giaban money,
								 @donvitinh nvarchar(20),
							     @mota nvarchar(100))
AS
BEGIN
    IF EXISTS (SELECT masp FROM Sanpham WHERE masp = @masp)
    BEGIN
        
        UPDATE Sanpham 
        SET mahangsx = @mahangsx, tensp = @tensp, soluong = @soluong, mausac = @mausac, giaban = @giaban, donvitinh = @donvitinh, mota = @mota
        WHERE masp = @masp
        PRINT N'Cập nhật thông tin sản phẩm thành công'
    END
    ELSE
    BEGIN
        
        INSERT INTO Sanpham(masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, @mahangsx, @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)
        PRINT N'Thêm mới sản phẩm thành công'
    END
END
EXEC Insert_SanPham 'SP06', 'H01', 'Galaxy V21', 500, N'Nâu', 8000000, N'Chiếc', N'Hàng cận cao cấp'
--câu 3
CREATE PROCEDURE Delete_HangSX
    @tenhang NVARCHAR(50)
AS
BEGIN
    
    IF NOT EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        PRINT 'Hãng không tồn tại trong bảng'
        RETURN
    END

    BEGIN TRANSACTION

    DELETE FROM Sanpham WHERE mahangsx = (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang)

    
    DELETE FROM Hangsx WHERE tenhang = @tenhang

    COMMIT TRANSACTION
END

---Câu 4---
CREATE PROCEDURE sp_NhapNhanVien
    @manv VARCHAR(10),
    @tennv NVARCHAR(50),
    @gioitinh NVARCHAR(3),
    @diachi NVARCHAR(100),
    @sodt VARCHAR(20),
    @email NVARCHAR(50),
    @phong NVARCHAR(50),
    @flag BIT
AS
BEGIN
    IF @flag = 0
    BEGIN
        UPDATE Nhanvien
        SET tennv = @tennv,
            gioitinh = @gioitinh,
            diachi = @diachi,
            sodt = @sodt,
            email = @email,
            phong = @phong
        WHERE manv = @manv;
    END
    ELSE
    BEGIN
        IF EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
        BEGIN
            RAISERROR('Mã nhân viên đã tồn tại!', 16, 1);
            RETURN;
        END
        INSERT INTO Nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
        VALUES (@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    END
END

---Câu 5---

CREATE PROCEDURE ThemNhap(@sohdn varchar(20),
						 @masp varchar(20), 
						 @manv varchar(20), 
						 @ngaynhap date, 
						 @soluongN int, 
						 @dongiaN float)
AS
BEGIN
    
    IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Mã sản phẩm không tồn tại'
        RETURN
    END
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Mã nhân viên không tồn tại'
        RETURN
    END

  
    IF EXISTS(SELECT * FROM Nhap WHERE sohdn = @sohdn)
    BEGIN
        UPDATE Nhap SET masp = @masp, manv = @manv, ngaynhap = @ngaynhap, soluongN = @soluongN, dongiaN = @dongiaN
        WHERE sohdn = @sohdn
    END
    ELSE 
    BEGIN
        INSERT INTO Nhap(sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
        VALUES(@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN)
    END

   
    IF EXISTS(SELECT * FROM Xuat WHERE sohdx = @sohdn)
    BEGIN
        UPDATE Xuat SET masp = @masp, manv = @manv, ngayxuat = @ngaynhap, soluongX = @soluongN
        WHERE sohdx = @sohdn
    END
    ELSE 
    BEGIN
        DECLARE @sohdx varchar(20)
        SET @sohdx = 'X' + @sohdn
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES(@sohdx, @masp, @manv, @ngaynhap, @soluongN)
    END
END

---Câu 6---
CREATE PROCEDURE them_capnhat_Xuat 
(
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
)
AS
BEGIN
    
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Mã sản phẩm không tồn tại trong bảng Sanpham.'
        RETURN
    END
    
    
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Mã nhân viên không tồn tại trong bảng Nhanvien.'
        RETURN
    END
    
    
    IF @soluongX > (SELECT soluong FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Số lượng xuất vượt quá số lượng tồn kho.'
        RETURN
    END
    
    
    IF EXISTS (SELECT * FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        UPDATE Xuat 
        SET masp = @masp, manv = @manv, ngayxuat = @ngayxuat, soluongX = @soluongX 
        WHERE sohdx = @sohdx
        PRINT 'Cập nhật dữ liệu bảng Xuat thành công.'
    END
    ELSE
    BEGIN
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES (@sohdx, @masp, @manv, @ngayxuat, @soluongX)
        PRINT 'Thêm dữ liệu vào bảng Xuat thành công.'
    END
END

---Câu 7---
CREATE PROCEDURE Delete_Nhanvien 
    @manv INT
AS
BEGIN
    
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Không tìm thấy nhân viên với mã ' + CAST(@manv AS NVARCHAR)
        RETURN
    END

   
    DELETE FROM Nhap WHERE manv = @manv
    DELETE FROM Xuat WHERE manv = @manv

 
    DELETE FROM Nhanvien WHERE manv = @manv

    PRINT 'đã xóa nhân viên với mã ' + CAST(@manv AS NVARCHAR)
END


---Câu 8---
CREATE PROCEDURE Delete_Sanpham
  @masp VARCHAR(10)
AS
BEGIN
  SET NOCOUNT ON;

  IF NOT EXISTS (SELECT 1 FROM Sanpham WHERE masp = @masp)
  BEGIN
    PRINT 'Không tìm thấy sản phẩm  xóa!'
    RETURN;
  END

  BEGIN TRY
    BEGIN TRANSACTION

  
    DELETE FROM Nhap WHERE masp = @masp;

    
    DELETE FROM Xuat WHERE masp = @masp;

   
    DELETE FROM Sanpham WHERE masp = @masp;

    COMMIT TRANSACTION
    PRINT 'đã xóa sản phẩm ' + @masp
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT 'Đã xẩy ra lỗi trong quá trình xóa sản phẩm!'
  END CATCH
END
