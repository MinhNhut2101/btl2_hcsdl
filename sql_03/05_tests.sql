/* SQL Server 2019+/2022. SSMS: Query > SQLCMD Mode.
   Demo: 01_schema -> 02_routines_triggers -> 03_demo_data -> 05_tests -> 04_queries.
   Khi tich hop: doi USE sang DB nhom; khong chay du lieu/test demo.
*/
:ON ERROR EXIT
USE [BTL2_Nguoi3_Demo];
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOCOUNT ON;
GO
/* CHI CHAY MOT LAN SAU 01 -> 02 -> 03 TREN DB DEMO.
 Quy trinh phan cong, ghi/sua/duyet cong, lap/chot/chi tra va T01--T33.
 File thay doi du lieu; khong chay tren DB nhom/van hanh.
 Ky vong PV1=502500, PV2=60000, tong=562500 dong.
 Da kiem tra cu phap; chua thuc thi tren SQL Server.
*/
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_C1001S','NgayThuong','N3_B01';
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_C1001S','NgayThuong','N3_B02';
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV2','N3_C1001S','NgayThuong','N3_B01';
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_C1002S','NgayThuong';
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_C1003S','NgayNghiTuan';
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_C1004S','NgayLe','N3_B01';
-- Lich chieu tam de kiem thu OT giao ca khac; xoa sau test vi chua co cham cong.
EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_C1001C','NgayThuong';

EXEC dbo.usp_N3_ChamCong 'GhiNhan','N3_QL1','N3_PV1','N3_C1001S',
 @GioVaoThucTe='2026-10-01T06:00:00',@GioRaThucTe='2026-10-01T10:45:00',
 @OTSauBatDau='2026-10-01T10:00:00',@OTSauKetThuc='2026-10-01T10:45:00';
EXEC dbo.usp_N3_ChamCong 'Sua','N3_QL1','N3_PV1','N3_C1001S',
 @GioVaoThucTe='2026-10-01T06:00:00',@GioRaThucTe='2026-10-01T11:00:00',
 @OTSauBatDau='2026-10-01T10:00:00',@OTSauKetThuc='2026-10-01T11:00:00',
 @LyDoSua=N'Đối chiếu nhật ký kết ca, bổ sung 15 phút làm thêm còn thiếu';
-- PV2 nhap check-in truoc, checkout bo sung sau test phu dinh.
EXEC dbo.usp_N3_ChamCong 'GhiNhan','N3_QL1','N3_PV2','N3_C1001S',
 @GioVaoThucTe='2026-10-01T08:00:00';
EXEC dbo.usp_N3_ChamCong 'GhiNhan','N3_QL1','N3_PV1','N3_C1002S',
 @TrangThaiCong='NghiPhepHuongLuong',@GhiChu=N'Nghỉ phép được hưởng đủ lương ca';
EXEC dbo.usp_N3_ChamCong 'GhiNhan','N3_QL1','N3_PV1','N3_C1003S',
 @TrangThaiCong='NghiPhepKhongLuong',@GhiChu=N'Nghỉ không hưởng lương';
EXEC dbo.usp_N3_ChamCong 'GhiNhan','N3_QL1','N3_PV1','N3_C1004S',
 @GioVaoThucTe='2026-10-04T06:00:00',@GioRaThucTe='2026-10-04T10:30:00',
 @OTSauBatDau='2026-10-04T10:00:00',@OTSauKetThuc='2026-10-04T10:30:00';
GO

/* PHAN IV-A. TEST PHU DINH TRUOC DUYET/CHOT.
   Moi test doc lap, khong boc trong giao dich ngoai thu tuc.
   Chi PASS neu ERROR_NUMBER() dung ma mong doi; loi khac duoc nem lai.
*/
DECLARE @Tests TABLE(Id INT PRIMARY KEY,Ten NVARCHAR(200),MaLoi INT,CauLenh NVARCHAR(MAX));
INSERT @Tests VALUES
 (1,N'Người phục vụ không được phân công nhân sự',51010,
  N'EXEC dbo.usp_N3_PhanCongNhanVien ''N3_PV1'',''N3_PV2'',''N3_C1001S'',''NgayThuong'',''N3_B01'';'),
 (2,N'Nhân viên nghỉ việc không được xếp lịch',51012,
  N'EXEC dbo.usp_N3_PhanCongNhanVien ''N3_QL1'',''N3_NGHI'',''N3_C1001S'',''NgayThuong'';'),
 (3,N'Thu ngân không có vai trò phục vụ không được gán bàn',51017,
  N'EXEC dbo.usp_N3_PhanCongNhanVien ''N3_QL1'',''N3_TN1'',''N3_C1001S'',''NgayThuong'',''N3_B01'';'),
 (4,N'Bàn tạm ngừng không được phân công',51018,
  N'EXEC dbo.usp_N3_PhanCongNhanVien ''N3_QL1'',''N3_PV1'',''N3_C1001S'',''NgayThuong'',''N3_BTAM'';'),
 (5,N'Không vượt số bàn tối đa trong ca',51019,
  N'EXEC dbo.usp_N3_PhanCongNhanVien ''N3_QL1'',''N3_PV2'',''N3_C1001S'',''NgayThuong'',''N3_B02'';'),
 (6,N'Ngày lễ phải khớp loại ngày của ca',51014,
  N'EXEC dbo.usp_N3_PhanCongNhanVien ''N3_QL1'',''N3_PV2'',''N3_C1004S'',''NgayThuong'';'),
 (7,N'Quản lý không có quyền không được duyệt công',51101,
  N'EXEC dbo.usp_N3_ChamCong ''Duyet'',''N3_QL0'',''N3_PV1'',''N3_C1001S'',@PhutCongDuyet=240,@CanCuDuyetCong=N''Đối soát'';'),
 (8,N'Công đi làm thiếu checkout không được duyệt',51116,
  N'EXEC dbo.usp_N3_ChamCong ''Duyet'',''N3_QL1'',''N3_PV2'',''N3_C1001S'',@PhutCongDuyet=120,@CanCuDuyetCong=N''Đối soát'';'),
 (9,N'Sửa công phải có lý do',51106,
  N'EXEC dbo.usp_N3_ChamCong ''Sua'',''N3_QL1'',''N3_PV2'',''N3_C1001S'';'),
 (10,N'OT không giao ca khác của chính nhân viên',53115,
  N'EXEC dbo.usp_N3_ChamCong ''Sua'',''N3_QL1'',''N3_PV1'',''N3_C1001S'',@GioVaoThucTe=''2026-10-01T06:00:00'',@GioRaThucTe=''2026-10-01T13:00:00'',@OTSauBatDau=''2026-10-01T10:00:00'',@OTSauKetThuc=''2026-10-01T13:00:00'',@LyDoSua=N''Thử OT giao ca chiều'';'),
 (11,N'Các ca cùng ngày không được chồng giờ',53102,
  N'INSERT dbo.CA_LAM(MaCa,NgayLam,GioBatDau,GioKetThuc,LoaiNgayLich,MaMauCa) VALUES(''N3_CA_TRUNG'',''20261001'',''09:00'',''11:00'',''NgayThuong'',''N3_SANG'');'),
 (12,N'Mức lương cùng nhân viên/mẫu ca không chồng hiệu lực',53110,
  N'INSERT dbo.MUC_LUONG_CA(MaMucLuong,MaNV,MaMauCa,TuNgay,DenNgay,DonGiaCa,HeSoTangCaThuong,HeSoTangCaNghiTuan,HeSoTangCaNgayLe) VALUES(''N3_ML_TRUNG'',''N3_PV1'',''N3_SANG'',''20261001'',''20261005'',150000,1.5,2,3);'),
 (13,N'Quản lý thiếu quyền không được lập/chốt lương',51201,
  N'EXEC dbo.usp_N3_BangLuong ''Lap'',''N3_QL0'',''N3_BL_SAI'',N''Kỳ bị từ chối'',''20261001'',''20261005'';');

DECLARE @Id INT,@Ten NVARCHAR(200),@MaLoi INT,@SQL NVARCHAR(MAX),@NhanLoi INT;
DECLARE @KetQua TABLE(Id INT,Ten NVARCHAR(200),MaLoiMongDoi INT,MaLoiNhanDuoc INT,KetQua VARCHAR(4));
WHILE EXISTS(SELECT 1 FROM @Tests)
BEGIN
 SELECT TOP(1) @Id=Id,@Ten=Ten,@MaLoi=MaLoi,@SQL=CauLenh FROM @Tests ORDER BY Id;
 SET @NhanLoi=NULL;
 BEGIN TRY
  EXEC sys.sp_executesql @SQL;
 END TRY
 BEGIN CATCH
  SET @NhanLoi=ERROR_NUMBER();
  IF XACT_STATE()<>0 ROLLBACK;
  IF @NhanLoi<>@MaLoi THROW;
 END CATCH;
 IF @NhanLoi IS NULL THROW 51999,N'Test phu dinh khong phat sinh loi nhu mong doi.',1;
 INSERT @KetQua VALUES(@Id,@Ten,@MaLoi,@NhanLoi,'PASS');
 DELETE @Tests WHERE Id=@Id;
END;
SELECT N'T01-T13' AS NhomTest,* FROM @KetQua ORDER BY Id;
GO

-- Bo lich chieu tam; khong xoa bat ky lich da co cham cong.
DELETE dbo.LAM_VIEC WHERE MaNV='N3_PV1' AND MaCa='N3_C1001C';
EXEC dbo.usp_N3_ChamCong 'Sua','N3_QL1','N3_PV2','N3_C1001S',
 @GioVaoThucTe='2026-10-01T08:00:00',@GioRaThucTe='2026-10-01T10:00:00',
 @LyDoSua=N'Bổ sung checkout theo biên bản kết ca';
BEGIN TRY
 EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV2','N3_C1001S',
  @PhutCongDuyet=121,@CanCuDuyetCong=N'Thử duyệt vượt 120 phút có mặt';
 THROW 51999,N'T14 khong chan phut duyet vuot thuc te.',1;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER()<>51117 THROW;
 SELECT N'T14' AS Test,N'PASS: từ chối 121 phút khi thực tế giao ca 120 phút' AS KetQua;
END CATCH;
/* Chen ngay SAU T14 va TRUOC cac lenh Duyet hop le chinh.
   Hai test nay khong lam thay doi so luong lich/cong hay so tien demo cuoi cung.
*/
-- T31. Ngoai le BR44 duoc phe duyet ro rang, luu co va ghi nhat ky.
EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV2','N3_C1001S',
 @PhutCongDuyet=121,@ChoPhepNgoaiLe=1,
 @CanCuDuyetCong=N'Biên bản ngoại lệ demo: quản lý xác nhận bổ sung 1 phút công';
IF NOT EXISTS(SELECT 1 FROM dbo.CHAM_CONG WHERE MaNV='N3_PV2' AND MaCa='N3_C1001S'
 AND TrangThaiDuyet='DaDuyet' AND PhutCongDuyet=121 AND LaNgoaiLeCong=1)
 OR NOT EXISTS(SELECT 1 FROM dbo.LICH_SU_SUA_CHAM_CONG WHERE MaNV='N3_PV2' AND MaCa='N3_C1001S'
 AND TruongThayDoi='LaNgoaiLeCong' AND GiaTriTruoc=N'0' AND GiaTriSau=N'1'
 AND MaNVSua='N3_QL1' AND LEN(LyDoSua)>0)
 THROW 51999,N'T31 ngoai le cong phai co phe duyet, can cu va log.',1;
-- Dua ve cong cho duyet de luong demo van duoc tinh theo 120 phut trong phan tiep theo.
EXEC dbo.usp_N3_ChamCong 'Sua','N3_QL1','N3_PV2','N3_C1001S',
 @GioVaoThucTe='2026-10-01T08:00:00',@GioRaThucTe='2026-10-01T10:00:00',
 @LyDoSua=N'Kết thúc kiểm thử ngoại lệ, tính lại theo 120 phút thực tế trong ca';
IF NOT EXISTS(SELECT 1 FROM dbo.CHAM_CONG WHERE MaNV='N3_PV2' AND MaCa='N3_C1001S'
 AND TrangThaiDuyet='ChoDuyet' AND PhutCongDuyet IS NULL AND LaNgoaiLeCong=0)
 OR NOT EXISTS(SELECT 1 FROM dbo.LICH_SU_SUA_CHAM_CONG WHERE MaNV='N3_PV2' AND MaCa='N3_C1001S'
 AND TruongThayDoi='LaNgoaiLeCong' AND GiaTriTruoc=N'1' AND GiaTriSau=N'0')
 THROW 51999,N'T31 sua cong phai go duyet va luu log thay doi co ngoai le.',1;
SELECT N'T31' AS Test,N'PASS: ngoại lệ cần duyệt rõ ràng và có nhật ký; sửa công đưa về chờ duyệt' AS KetQua;

-- T32. Chieu nguoc: khong xep them ca vao khoang OT da ghi nhan truoc do.
INSERT dbo.MAU_CA(MaMauCa,TenMauCa,GioBatDau,GioKetThuc,TrangThai)
 VALUES('N3_TEST_GAP',N'Mẫu ca kiểm thử giao OT','10:00','12:00','DangSuDung');
INSERT dbo.CA_LAM(MaCa,NgayLam,GioBatDau,GioKetThuc,LoaiNgayLich,MaMauCa)
 VALUES('N3_TEST_GAP','20261001','10:00','12:00','NgayThuong','N3_TEST_GAP');
BEGIN TRY
 EXEC dbo.usp_N3_PhanCongNhanVien 'N3_QL1','N3_PV1','N3_TEST_GAP','NgayThuong';
 THROW 51999,N'T32 khong chan ca moi giao OT da ghi nhan.',1;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER()<>53138 THROW;
 SELECT N'T32' AS Test,N'PASS: từ chối xếp ca mới giao khoảng OT đã ghi nhận' AS KetQua;
END CATCH;
IF EXISTS(SELECT 1 FROM dbo.LAM_VIEC WHERE MaNV='N3_PV1' AND MaCa='N3_TEST_GAP')
 THROW 51999,N'T32 lich lam sai phai duoc rollback.',1;
DELETE dbo.CA_LAM WHERE MaCa='N3_TEST_GAP';
DELETE dbo.MAU_CA WHERE MaMauCa='N3_TEST_GAP';

EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV1','N3_C1001S',
 @PhutCongDuyet=240,@CanCuDuyetCong=N'Đối soát giờ vào/ra và 60 phút OT sau ca';
EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV2','N3_C1001S',
 @PhutCongDuyet=120,@CanCuDuyetCong=N'Đi trễ, duyệt 120 phút công thực tế trong ca';
EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV1','N3_C1002S',
 @CanCuDuyetCong=N'Đơn nghỉ phép hưởng lương đã được quản lý chấp thuận';
EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV1','N3_C1003S',
 @CanCuDuyetCong=N'Đơn nghỉ phép không hưởng lương';
EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV1','N3_C1004S',
 @PhutCongDuyet=240,@CanCuDuyetCong=N'Ca có loại ngày lễ minh họa, OT 30 phút, dùng mức lương mới';

IF NOT EXISTS(SELECT 1 FROM dbo.LICH_SU_SUA_CHAM_CONG
 WHERE MaNV='N3_PV1' AND MaCa='N3_C1001S' AND TruongThayDoi='GioRaThucTe'
 AND GiaTriTruoc=N'2026-10-01T10:45:00' AND GiaTriSau=N'2026-10-01T11:00:00'
 AND MaNVSua='N3_QL1' AND LEN(LyDoSua)>0)
 THROW 51999,N'T15 thieu nhat ky sua gio ra.',1;
IF (SELECT COUNT(*) FROM dbo.LICH_SU_SUA_CHAM_CONG
 WHERE MaNV='N3_PV1' AND MaCa='N3_C1001S' AND TruongThayDoi IN('GioRaThucTe','OTSauKetThuc')
 AND LyDoSua=N'Đối chiếu nhật ký kết ca, bổ sung 15 phút làm thêm còn thiếu')<>2
 THROW 51999,N'T15 moi truong sua phai co mot dong nhat ky.',1;
SELECT N'T15' AS Test,N'PASS: lưu riêng trước/sau của hai trường đã sửa' AS KetQua;

DECLARE @KyVong TABLE(MaNV VARCHAR(30),MaCa VARCHAR(30),Luong DECIMAL(18,2),OT DECIMAL(18,2));
INSERT @KyVong VALUES ('N3_PV1','N3_C1001S',120000,45000),('N3_PV1','N3_C1002S',120000,0),
 ('N3_PV1','N3_C1003S',0,0),('N3_PV1','N3_C1004S',140000,52500),('N3_PV2','N3_C1001S',60000,0);
IF EXISTS(SELECT 1 FROM @KyVong k OUTER APPLY dbo.fn_N3_TinhTienCong(k.MaNV,k.MaCa) f
 WHERE f.MaNV IS NULL OR f.TienLuongCa<>k.Luong OR f.TienTangCa<>k.OT)
 THROW 51999,N'T16 ham tinh luong khong khop gia tri doi soat.',1;
SELECT N'T16' AS Test,k.MaNV,k.MaCa,k.Luong AS LuongKyVong,k.OT AS OTKyVong,
 f.TienLuongCa AS LuongTinhDuoc,f.TienTangCa AS OTTinhDuoc
FROM @KyVong k CROSS APPLY dbo.fn_N3_TinhTienCong(k.MaNV,k.MaCa) f;

EXEC dbo.usp_N3_BangLuong 'Lap','N3_QL1','N3_BL1001',N'Kỳ demo 01 đến 04 tháng 10 năm 2026','20261001','20261005';
INSERT dbo.DIEU_CHINH_LUONG(MaBangLuong,MaNV,STTDieuChinh,LoaiDieuChinh,SoTien,LyDo,MaNVDuyet,ThoiDiemDuyet)
VALUES ('N3_BL1001','N3_PV1',1,'Thuong',20000,N'Thưởng được quản lý phê duyệt, không tự động từ KPI','N3_QL1',SYSDATETIME()),
 ('N3_BL1001','N3_PV1',2,'PhuCap',10000,N'Phụ cấp ca theo thỏa thuận demo','N3_QL1',SYSDATETIME()),
 ('N3_BL1001','N3_PV1',3,'GiamTru',5000,N'Khoản đối soát theo thỏa thuận demo','N3_QL1',SYSDATETIME());

BEGIN TRY
 EXEC dbo.usp_N3_BangLuong 'Lap','N3_QL1','N3_BL_TRUNG',N'Kỳ chồng ngày','20261004','20261006';
 THROW 51999,N'T17 khong chan ky luong chong ngay.',1;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER()<>51204 THROW;
 SELECT N'T17' AS Test,N'PASS: từ chối kỳ lương chồng ngày' AS KetQua;
END CATCH;
BEGIN TRY
 EXEC dbo.usp_N3_BangLuong 'ChiTra','N3_QL1','N3_BL1001',@MaNV='N3_PV1',@PhuongThucChiTra='TienMat';
 THROW 51999,N'T18 khong chan chi tra truoc chot.',1;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER()<>51214 THROW;
 SELECT N'T18' AS Test,N'PASS: từ chối chi trả trước chốt' AS KetQua;
END CATCH;

-- T33. Sua cong da co luong nhap: xoa dong snapshot cu, chan chot, duyet va lap lai.
EXEC dbo.usp_N3_ChamCong 'Sua','N3_QL1','N3_PV2','N3_C1001S',
 @GioVaoThucTe='2026-10-01T08:00:00',@GioRaThucTe='2026-10-01T10:00:00',
 @LyDoSua=N'Kiểm tra quy trình xác nhận lại công trước chốt';
IF EXISTS(SELECT 1 FROM dbo.CHI_TIET_LUONG_CA WHERE MaNV='N3_PV2' AND MaCa='N3_C1001S')
 THROW 51999,N'T33 snapshot nhap cu chua bi loai bo sau sua cong.',1;
BEGIN TRY
 EXEC dbo.usp_N3_BangLuong 'Chot','N3_QL1','N3_BL1001';
 THROW 51999,N'T33 khong chan chot khi con cong chua duyet.',1;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER()<>51210 THROW;
END CATCH;
EXEC dbo.usp_N3_ChamCong 'Duyet','N3_QL1','N3_PV2','N3_C1001S',
 @PhutCongDuyet=120,@CanCuDuyetCong=N'Đối chiếu lại công trước khi lập lại lương nháp';
EXEC dbo.usp_N3_BangLuong 'Lap','N3_QL1','N3_BL1001';
SELECT N'T33' AS Test,N'PASS: công sửa phải duyệt lại và lập lại snapshot trước chốt' AS KetQua;

EXEC dbo.usp_N3_BangLuong 'Chot','N3_QL1','N3_BL1001';
IF NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG
 WHERE MaBangLuong='N3_BL1001' AND MaNV='N3_PV1' AND SoTienChot=502500)
 OR NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG
 WHERE MaBangLuong='N3_BL1001' AND MaNV='N3_PV2' AND SoTienChot=60000)
 THROW 51999,N'T19 luong chot khong khop: PV1=502500, PV2=60000.',1;
IF (SELECT COUNT(*) FROM dbo.CHI_TIET_LUONG_CA WHERE MaBangLuong='N3_BL1001')<>5
 THROW 51999,N'T19 phai co dung 5 dong luong ca.',1;
SELECT N'T19' AS Test,N'PASS: 5 dòng công; PV1 chốt 502.500, PV2 chốt 60.000 đồng' AS KetQua;
EXEC dbo.usp_N3_BangLuong 'ChiTra','N3_QL1','N3_BL1001',@MaNV='N3_PV1',@PhuongThucChiTra='ChuyenKhoan';
EXEC dbo.usp_N3_BangLuong 'ChiTra','N3_QL1','N3_BL1001',@MaNV='N3_PV2',@PhuongThucChiTra='TienMat';
GO

/* PHAN IV-B. TEST BAT BIEN SAU CHOT. */
DECLARE @Tests TABLE(Id INT PRIMARY KEY,Ten NVARCHAR(200),MaLoi INT,CauLenh NVARCHAR(MAX));
INSERT @Tests VALUES
 (20,N'Sửa công kỳ đã chốt qua thủ tục bị từ chối',51103,
  N'EXEC dbo.usp_N3_ChamCong ''Sua'',''N3_QL1'',''N3_PV1'',''N3_C1001S'',@LyDoSua=N''Thử sửa kỳ cũ'';'),
 (21,N'Chốt lại kỳ đã chốt bị từ chối',51207,
  N'EXEC dbo.usp_N3_BangLuong ''Chot'',''N3_QL1'',''N3_BL1001'';'),
 (22,N'Lập lại kỳ đã chốt bị từ chối',51202,
  N'EXEC dbo.usp_N3_BangLuong ''Lap'',''N3_QL1'',''N3_BL1001'';'),
 (23,N'Chi trả lương lần hai bị từ chối',51216,
  N'EXEC dbo.usp_N3_BangLuong ''ChiTra'',''N3_QL1'',''N3_BL1001'',@MaNV=''N3_PV1'',@PhuongThucChiTra=''TienMat'';'),
 (24,N'Trigger bảo vệ sửa công trực tiếp sau chốt',53111,
  N'UPDATE dbo.CHAM_CONG SET GhiChu=N''Thử sửa trái quy trình'' WHERE MaNV=''N3_PV1'' AND MaCa=''N3_C1001S'';'),
 (25,N'Trigger bảo vệ phiên bản lương đã dùng',53109,
  N'UPDATE dbo.MUC_LUONG_CA SET DonGiaCa=999999 WHERE MaMucLuong=''N3_MLPV1A'';'),
 (26,N'Trigger bảo vệ nhật ký sửa công',53117,
  N'UPDATE dbo.LICH_SU_SUA_CHAM_CONG SET LyDoSua=N''Thử thay lịch sử'' WHERE MaNV=''N3_PV1'' AND MaCa=''N3_C1001S'';'),
 (27,N'Trigger bảo vệ điều chỉnh thuộc kỳ đã chốt',53130,
  N'UPDATE dbo.DIEU_CHINH_LUONG SET SoTien=999999 WHERE MaBangLuong=''N3_BL1001'' AND MaNV=''N3_PV1'' AND STTDieuChinh=1;'),
 (28,N'Trigger bảo vệ thông tin chi trả đã ghi nhận',53125,
  N'UPDATE dbo.CHI_TIET_BANG_LUONG SET ThoiDiemChiTra=DATEADD(SECOND,1,ThoiDiemChiTra) WHERE MaBangLuong=''N3_BL1001'' AND MaNV=''N3_PV1'';'),
 (29,N'Trigger bảo vệ ca đã có lịch làm',53101,
  N'UPDATE dbo.CA_LAM SET GioKetThuc=''09:30'' WHERE MaCa=''N3_C1001S'';');
DECLARE @Id INT,@Ten NVARCHAR(200),@MaLoi INT,@SQL NVARCHAR(MAX),@NhanLoi INT;
DECLARE @KetQua TABLE(Id INT,Ten NVARCHAR(200),MaLoiMongDoi INT,MaLoiNhanDuoc INT,KetQua VARCHAR(4));
WHILE EXISTS(SELECT 1 FROM @Tests)
BEGIN
 SELECT TOP(1) @Id=Id,@Ten=Ten,@MaLoi=MaLoi,@SQL=CauLenh FROM @Tests ORDER BY Id;
 SET @NhanLoi=NULL;
 BEGIN TRY
  EXEC sys.sp_executesql @SQL;
 END TRY
 BEGIN CATCH
  SET @NhanLoi=ERROR_NUMBER();
  IF XACT_STATE()<>0 ROLLBACK;
  IF @NhanLoi<>@MaLoi THROW;
 END CATCH;
 IF @NhanLoi IS NULL THROW 51999,N'Test phu dinh khong phat sinh loi nhu mong doi.',1;
 INSERT @KetQua VALUES(@Id,@Ten,@MaLoi,@NhanLoi,'PASS');
 DELETE @Tests WHERE Id=@Id;
END;
SELECT N'T20-T29' AS NhomTest,* FROM @KetQua ORDER BY Id;
IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN n WHERE n.MaNV LIKE 'N3[_]%'
 AND (NOT EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN h WHERE h.MaNV=n.MaNV)
 OR NOT EXISTS(SELECT MaNV FROM dbo.PHUC_VU WHERE MaNV=n.MaNV UNION ALL
 SELECT MaNV FROM dbo.THU_NGAN WHERE MaNV=n.MaNV UNION ALL SELECT MaNV FROM dbo.QUAN_LY WHERE MaNV=n.MaNV)))
 THROW 51999,N'T30 ho so demo thieu lien he hoac vai tro.',1;
IF EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG WHERE MaBangLuong='N3_BL1001'
 AND (TrangThaiChiTra<>'DaTra' OR SoTienChiTra<>SoTienChot))
 THROW 51999,N'T30 chi tra phai bang so tien da chot.',1;
SELECT N'T30' AS Test,N'PASS: hồ sơ đủ vai trò/liên hệ; trả đủ một lần; dữ liệu sau các test lỗi được giữ nguyên' AS KetQua;
GO

