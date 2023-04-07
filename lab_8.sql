---Câu 1---

CREATE PROCEDURE sp_ThemMoiNhanVien
    @manv INT,
    @tennv NVARCHAR(50),
    @gioitinh NVARCHAR(10),
    @diachi NVARCHAR(100),
    @sodt VARCHAR(20),
    @email VARCHAR(50),
    @phong NVARCHAR(50),
    @Flag INT
AS
BEGIN
    SET NOCOUNT ON;
    
    --Kiểm tra giới tính
    IF @gioitinh NOT IN ('Nam', 'Nữ')
    BEGIN
        RETURN 1;
    END
    
    --Kiểm tra Flag để xác định là thêm mới hay cập nhật thông tin nhân viên
    IF @Flag = 0 
    BEGIN
        INSERT INTO Nhanvien(manv, tennv, gioitinh, diachi, sodt, email, phong)
        VALUES(@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    END
    ELSE
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
    
    RETURN 0;
END

---Câu 2---

CREATE PROCEDURE ThemMoiSanPham @masp int, @tenhang varchar(50), @tensp varchar(50), @soluong int, @mausac varchar(20), @giaban float, @donvitinh varchar(20), @mota varchar(100), @Flag int
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tên hãng sản xuất
    IF NOT EXISTS(SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        SELECT 1 AS 'MaLoi', 'Không tìm thấy tên hãng sản xuất' AS 'MoTaLoi'
        RETURN
    END

    -- Kiểm tra số lượng sản phẩm
    IF @soluong < 0
    BEGIN
        SELECT 2 AS 'MaLoi', 'Số lượng sản phẩm phải lớn hơn hoặc bằng 0' AS 'MoTaLoi'
        RETURN
    END

    -- Nếu là chế độ thêm mới sản phẩm
    IF @Flag = 0
    BEGIN
        INSERT INTO Sanpham (masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang), @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)

        SELECT 0 AS 'MaLoi', 'Thêm mới sản phẩm thành công' AS 'MoTaLoi'
    END
    ELSE -- Nếu là chế độ cập nhật sản phẩm
    BEGIN
        UPDATE Sanpham
        SET mahangsx = (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang), 
            tensp = @tensp, 
            soluong = @soluong, 
            mausac = @mausac, 
            giaban = @giaban, 
            donvitinh = @donvitinh, 
            mota = @mota
        WHERE masp = @masp

        SELECT 0 AS 'MaLoi', 'Cập nhật sản phẩm thành công' AS 'MoTaLoi'
    END
END

---Câu 3---

CREATE PROCEDURE XoaNhanVien 
    @manv int
AS
BEGIN
    -- Kiểm tra xem manv đã tồn tại trong bảng nhanvien hay chưa
    IF NOT EXISTS (SELECT * FROM nhanvien WHERE manv = @manv)
    BEGIN
        RETURN 1; -- Trả về 1 nếu manv chưa tồn tại trong bảng nhanvien
    END

    BEGIN TRANSACTION; -- Bắt đầu transaction để đảm bảo tính toàn vẹn của dữ liệu

    -- Xóa dữ liệu trong bảng Nhap
    DELETE FROM Nhap WHERE manv = @manv;
-- Xóa dữ liệu trong bảng Xuat
    DELETE FROM Xuat WHERE manv = @manv;

    -- Xóa dữ liệu trong bảng nhanvien
    DELETE FROM nhanvien WHERE manv = @manv;

    COMMIT TRANSACTION; -- Kết thúc transaction và lưu các thay đổi vào database

    RETURN 0; -- Trả về 0 nếu xóa thành công
END

---Câu 4---

CREATE PROCEDURE XoaSanPham
    @masp varchar(10),
    @errorCode int OUTPUT
AS
BEGIN
    -- Kiểm tra xem masp đã tồn tại trong bảng sanpham chưa
    IF NOT EXISTS (SELECT * FROM sanpham WHERE masp = @masp)
    BEGIN
        SET @errorCode = 1;
        RETURN;
    END
    
    -- Thực hiện xóa sản phẩm đó khỏi bảng sanpham
    DELETE FROM sanpham WHERE masp = @masp;
    
    -- Thực hiện xóa các bản ghi trong bảng Nhap và Xuat mà sản phẩm này đã tham gia
    DELETE FROM Nhap WHERE masp = @masp;
    DELETE FROM Xuat WHERE masp = @masp;
    
    SET @errorCode = 0;
END

---Câu 5---

CREATE PROCEDURE sp_ThemMoiHangsx 
    @mahangsx INT,
    @tenhang NVARCHAR(50),
    @diachi NVARCHAR(100),
    @sodt NVARCHAR(20),
    @email NVARCHAR(50)
AS
BEGIN
    -- Kiểm tra tên hàng đã tồn tại hay chưa
    IF EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        RETURN 1; -- Mã lỗi 1: tên hàng đã tồn tại
    END

    -- Thêm mới hàng hóa
    INSERT INTO Hangsx(mahangsx, tenhang, diachi, sodt, email)
    VALUES(@mahangsx, @tenhang, @diachi, @sodt, @email)

    RETURN 0; -- Thành công
END

---Câu 6---

CREATE PROCEDURE sp_NhapXuat_Xuat
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
AS
BEGIN
    
    IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        RETURN 1 
    END
    
    
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        RETURN 2 
		END
    
    
    IF @soluongX > (SELECT soluong FROM Sanpham WHERE masp = @masp)
    BEGIN
        RETURN 3 
    END
    
    
    IF EXISTS(SELECT * FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        
        UPDATE Xuat
        SET masp = @masp,
            manv = @manv,
            ngayxuat = @ngayxuat,
            soluongX = @soluongX
        WHERE sohdx = @sohdx
    END
    ELSE
    BEGIN
        
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES(@sohdx, @masp, @manv, @ngayxuat, @soluongX)
    END
    
    
    RETURN 0
END
--Câu 7--
CREATE PROCEDURE sp_XuatHangHoa
    @sohdx nvarchar(10),
    @masp nvarchar(10),
    @manv nvarchar(10),
    @ngayxuat date,
    @soluongX int
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp) -- Kiểm tra mã sản phẩm
    BEGIN
        -- Trả về mã lỗi 1 nếu mã sản phẩm không tồn tại
        RETURN 1
    END
    
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv) -- Kiểm tra mã nhân viên
    BEGIN
        -- Trả về mã lỗi 2 nếu mã nhân viên không tồn tại
        RETURN 2
    END
    
    DECLARE @SoluongS int
    SELECT @SoluongS = soluong FROM Sanpham WHERE masp = @masp -- Lấy số lượng sản phẩm trong kho
    
    IF @soluongX <= @SoluongS -- Kiểm tra số lượng xuất
    BEGIN
        IF EXISTS(SELECT * FROM Xuat WHERE sohdx = @sohdx) -- Kiểm tra số hóa đơn xuất
        BEGIN
            -- Cập nhật dữ liệu trong bảng Xuat
            UPDATE Xuat SET masp = @masp, manv = @manv, ngayxuat = @ngayxuat, soluongX = @soluongX WHERE sohdx = @sohdx
        END
        ELSE
        BEGIN
            -- Thêm dữ liệu vào bảng Xuat
            INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX) 
            VALUES (@sohdx, @masp, @manv, @ngayxuat, @soluongX)
        END

        -- Cập nhật số lượng sản phẩm còn lại trong kho
        UPDATE Sanpham SET soluong = @SoluongS - @soluongX WHERE masp = @masp

        -- Trả về mã lỗi 0 để thông báo thành công
        RETURN 0
    END
    ELSE
    BEGIN
        -- Trả về mã lỗi 3 nếu số lượng sản phẩm không đủ để xuất
        RETURN 3
    END
END

DECLARE @errorCode int
EXEC @errorCode = sp_XuatHangHoa @sohdx = 'HDX001', @masp = 'SP001', @manv = 'NV001', @ngayxuat = '2023-04-09', @soluongX = 5

IF (@errorCode = 0)
BEGIN
    PRINT 'Thành công'
END
ELSE IF (@errorCode = 1)
BEGIN
    PRINT 'Mã sản phẩm không tồn tại'
END
ELSE IF (@errorCode = 2)
BEGIN
    PRINT 'Mã nhân viên không tồn tại'
END
ELSE IF (@errorCode = 3)
BEGIN
    PRINT 'Số lượng sản phẩm không đủ để xuất'
END