/* Chay tren database THU NGHIEM da ghep bang KPI chinh thuc.
   Doi USE thanh database tich hop. Khong tao bang KPI gia.
   Can co: mot ket qua DaChot, mot ket qua chua chot cua cung nhan vien,
   va mot nhan vien khac chua co ket qua trong ky DaChot duoc chon.
   Moi tinh huong tu tao phieu luong tam trong transaction va ROLLBACK.
*/
:ON ERROR EXIT
USE [BTL2_Nguoi3_Demo];
GO
IF OBJECT_ID(N'dbo.KET_QUA_KPI',N'U') IS NULL
 THROW 53400,N'Chưa có bảng KPI chính thức; cần ghép dữ liệu KPI trước khi kiểm thử.',1;
EXEC dbo.usp_N3_LienKetThuongKPI;
GO
SET NOCOUNT ON;
DECLARE @MaNV VARCHAR(30),@KyChot VARCHAR(30),@KyNhap VARCHAR(30),@SaiNV VARCHAR(30),@QuanLy VARCHAR(30),@Tu DATE;
-- Co the gan cac bien nay bang ma cu the neu muon chon bo du lieu khac.
SELECT TOP(1) @MaNV=k.MaNV,@KyChot=k.MaKyKPI
 FROM dbo.KET_QUA_KPI k
 WHERE k.TrangThai='DaChot'
 AND EXISTS(SELECT 1 FROM dbo.KET_QUA_KPI x WHERE x.MaNV=k.MaNV AND x.TrangThai<>'DaChot')
 AND EXISTS(SELECT 1 FROM dbo.NHAN_VIEN n WHERE NOT EXISTS(SELECT 1 FROM dbo.KET_QUA_KPI x WHERE x.MaKyKPI=k.MaKyKPI AND x.MaNV=n.MaNV))
 ORDER BY k.MaNV,k.MaKyKPI;
SELECT TOP(1) @KyNhap=MaKyKPI FROM dbo.KET_QUA_KPI WHERE MaNV=@MaNV AND TrangThai<>'DaChot' ORDER BY MaKyKPI;
SELECT TOP(1) @SaiNV=n.MaNV FROM dbo.NHAN_VIEN n
 WHERE NOT EXISTS(SELECT 1 FROM dbo.KET_QUA_KPI k WHERE k.MaKyKPI=@KyChot AND k.MaNV=n.MaNV) ORDER BY n.MaNV;
SELECT TOP(1) @QuanLy=q.MaNV FROM dbo.QUAN_LY q JOIN dbo.NHAN_VIEN n ON n.MaNV=q.MaNV
 WHERE q.DuocChotBangLuong=1 AND n.TrangThaiLamViec='DangLam' AND n.TrangThaiHoSo='HoanTat' ORDER BY q.MaNV;
IF @MaNV IS NULL OR @KyNhap IS NULL OR @SaiNV IS NULL OR @QuanLy IS NULL
 THROW 53401,N'Thiếu dữ liệu KPI đã chốt/chưa chốt hoặc nhân viên/quản lý hợp lệ. Bổ sung fixture bằng quy trình KPI chính thức.',1;
SELECT @Tu=ISNULL(MAX(DenNgay),CAST(SYSDATETIME() AS DATE)) FROM dbo.BANG_LUONG;
IF EXISTS(SELECT 1 FROM dbo.BANG_LUONG WHERE MaBangLuong='N3_TEST_KPI')
 THROW 53402,N'Mã kỳ kiểm thử đã tồn tại; chọn mã khác trước khi chạy.',1;
DECLARE @Case INT=1,@Got INT,@Expected INT;
WHILE @Case<=4
BEGIN
 SET @Got=NULL;
 SET @Expected=CASE @Case WHEN 1 THEN 0 WHEN 2 THEN 547 WHEN 3 THEN 53134 WHEN 4 THEN 2601 END;
 BEGIN TRY
  BEGIN TRAN;
  INSERT dbo.BANG_LUONG(MaBangLuong,TenKy,TuNgay,DenNgay,TrangThaiBangLuong)
   VALUES('N3_TEST_KPI',N'Kỳ kiểm thử liên kết thưởng',@Tu,DATEADD(DAY,1,@Tu),'Nhap');
  INSERT dbo.CHI_TIET_BANG_LUONG(MaBangLuong,MaNV,TrangThaiChiTra)
   VALUES('N3_TEST_KPI',@MaNV,'ChuaTra'),('N3_TEST_KPI',@SaiNV,'ChuaTra');
  INSERT dbo.DIEU_CHINH_LUONG(MaBangLuong,MaNV,STTDieuChinh,LoaiDieuChinh,SoTien,LyDo,MaKyKPI,MaNVDuyet,ThoiDiemDuyet)
   VALUES('N3_TEST_KPI',CASE WHEN @Case=2 THEN @SaiNV ELSE @MaNV END,1,'Thuong',10000,
    N'Thưởng nhập và duyệt thủ công để kiểm thử',CASE WHEN @Case=3 THEN @KyNhap ELSE @KyChot END,@QuanLy,SYSDATETIME());
  IF @Case=4
   INSERT dbo.DIEU_CHINH_LUONG(MaBangLuong,MaNV,STTDieuChinh,LoaiDieuChinh,SoTien,LyDo,MaKyKPI,MaNVDuyet,ThoiDiemDuyet)
    VALUES('N3_TEST_KPI',@MaNV,2,'Thuong',10000,N'Thử khoản thưởng trùng kỳ KPI',@KyChot,@QuanLy,SYSDATETIME());
  IF @Case=1 AND (SELECT COUNT(*) FROM dbo.DIEU_CHINH_LUONG WHERE MaBangLuong='N3_TEST_KPI' AND MaNV=@MaNV AND MaKyKPI=@KyChot)<>1
   THROW 51999,N'Thưởng hợp lệ phải được tạo đúng một lần.',1;
  ROLLBACK;
 END TRY
 BEGIN CATCH
  SET @Got=ERROR_NUMBER();
  IF XACT_STATE()<>0 ROLLBACK;
  IF @Got<>@Expected THROW;
 END CATCH;
 IF ISNULL(@Got,0)<>@Expected THROW 51999,N'Kiểm thử KPI không phát lỗi đúng như dự kiến.',1;
 IF EXISTS(SELECT 1 FROM dbo.BANG_LUONG WHERE MaBangLuong='N3_TEST_KPI')
  THROW 51999,N'Dữ liệu thử phải được hoàn tác hoàn toàn.',1;
 SELECT @Case AS TestKPI,@Expected AS MaLoiMongDoi,ISNULL(@Got,0) AS MaLoiNhanDuoc,N'PASS' AS KetQua;
 SET @Case+=1;
END;
GO
