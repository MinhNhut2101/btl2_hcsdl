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
/* CHI CHAY MOT LAN SAU 01 VA 02 TREN DB DEMO.
 Them du lieu nen: khu vuc, ban, ho so, vai tro, mau ca, ca va muc luong.
 Chua phan cong/cham cong/chot luong; quy trinh nay nam trong 05_tests.sql.
*/
INSERT dbo.KHU_VUC(MaKhuVuc,TenKhuVuc) VALUES('N3_KV',N'Khu vực demo người 3');
INSERT dbo.BAN(MaBan,MaKhuVuc,TenBan,TrangThaiHoatDong) VALUES
 ('N3_B01','N3_KV',N'Bàn 01','HoatDong'),('N3_B02','N3_KV',N'Bàn 02','HoatDong'),
 ('N3_B03','N3_KV',N'Bàn 03','HoatDong'),('N3_BTAM','N3_KV',N'Bàn tạm ngừng','TamNgung');
GO
-- Ho so, vai tro va lien he duoc hoan tat cung giao dich.
EXEC dbo.usp_N3_HoSoNhanVien @MaNV='N3_QL1',@HoTen=N'Quản lý có quyền',@NgayVaoLam='20260101',
 @LienHe=N'[{"Loai":"SDT","GiaTri":"0903000001"}]',@VaiTro=N'[{"VaiTro":"QuanLy","DuocDuyetChamCong":1,"DuocChotBangLuong":1,"DuocDuyetKho":1,"DuocDuyetKPI":1},{"VaiTro":"ThuNgan","DuocHuyHoaDon":1}]';
EXEC dbo.usp_N3_HoSoNhanVien @MaNV='N3_QL0',@HoTen=N'Quản lý chưa được cấp quyền',@NgayVaoLam='20260101',
 @LienHe=N'[{"Loai":"SDT","GiaTri":"0903000002"}]',@VaiTro=N'[{"VaiTro":"QuanLy","DuocDuyetChamCong":0,"DuocChotBangLuong":0}]';
EXEC dbo.usp_N3_HoSoNhanVien @MaNV='N3_PV1',@HoTen=N'Nguyễn An',@NgayVaoLam='20260101',
 @LienHe=N'[{"Loai":"SDT","GiaTri":"0903000003"}]',@VaiTro=N'[{"VaiTro":"PhucVu","SoBanPhuTrachToiDa":2}]',@TenNganHang=N'Ngân hàng demo',@SoTaiKhoan='N3_DEMO_001',@ChuTaiKhoan=N'NGUYEN AN';
EXEC dbo.usp_N3_HoSoNhanVien @MaNV='N3_PV2',@HoTen=N'Trần Bình',@NgayVaoLam='20260101',
 @LienHe=N'[{"Loai":"SDT","GiaTri":"0903000004"}]',@VaiTro=N'[{"VaiTro":"PhucVu","SoBanPhuTrachToiDa":1}]';
EXEC dbo.usp_N3_HoSoNhanVien @MaNV='N3_TN1',@HoTen=N'Lê Chi',@NgayVaoLam='20260101',
 @LienHe=N'[{"Loai":"SDT","GiaTri":"0903000005"}]',@VaiTro=N'[{"VaiTro":"ThuNgan"}]';
EXEC dbo.usp_N3_HoSoNhanVien @MaNV='N3_NGHI',@HoTen=N'Nhân viên đã nghỉ',@NgayVaoLam='20260101',
 @LienHe=N'[{"Loai":"SDT","GiaTri":"0903000006"}]',@VaiTro=N'[{"VaiTro":"PhucVu","SoBanPhuTrachToiDa":1}]',@TrangThaiLamViec='DaNghi',@NgayNghiViec='20260901';
INSERT dbo.MAU_CA(MaMauCa,TenMauCa,GioBatDau,GioKetThuc,TrangThai)
VALUES ('N3_SANG',N'Ca sáng','06:00','10:00','DangSuDung'),
 ('N3_CHIEU',N'Ca chiều','12:00','16:00','DangSuDung');
INSERT dbo.CA_LAM(MaCa,NgayLam,GioBatDau,GioKetThuc,LoaiNgayLich,MaMauCa)
VALUES ('N3_C1001S','20261001','06:00','10:00','NgayThuong','N3_SANG'),
 ('N3_C1001C','20261001','12:00','16:00','NgayThuong','N3_CHIEU'),
 ('N3_C1002S','20261002','06:00','10:00','NgayThuong','N3_SANG'),
 ('N3_C1003S','20261003','06:00','10:00','NgayThuong','N3_SANG'),
 -- NgayLe la du lieu cau hinh minh hoa, khong khang dinh day la ngay le thuc te.
 ('N3_C1004S','20261004','06:00','10:00','NgayLe','N3_SANG');
INSERT dbo.MUC_LUONG_CA(MaMucLuong,MaNV,MaMauCa,TuNgay,DenNgay,DonGiaCa,
 HeSoTangCaThuong,HeSoTangCaNghiTuan,HeSoTangCaNgayLe,GhiChu)
VALUES ('N3_MLPV1A','N3_PV1','N3_SANG','20260101','20261004',120000,1.5,2,3,N'Mức trước ngày 04/10'),
 ('N3_MLPV1B','N3_PV1','N3_SANG','20261004','20270101',140000,1.5,2,3,N'Mức mới từ ngày 04/10'),
 ('N3_MLPV2','N3_PV2','N3_SANG','20260101','20270101',120000,1.5,2,3,NULL);

