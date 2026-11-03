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
INSERT dbo.NHAN_VIEN(MaNV,HoTen,TrangThaiLamViec,NgayVaoLam,NgayNghiViec,
 TenNganHang,SoTaiKhoan,ChuTaiKhoan)
VALUES
 ('N3_QL1',N'Quản lý có quyền','DangLam','20260101',NULL,NULL,NULL,NULL),
 ('N3_QL0',N'Quản lý chưa được cấp quyền','DangLam','20260101',NULL,NULL,NULL,NULL),
 ('N3_PV1',N'Nguyễn An','DangLam','20260101',NULL,N'Ngân hàng demo','N3_DEMO_001',N'NGUYEN AN'),
 ('N3_PV2',N'Trần Bình','DangLam','20260101',NULL,NULL,NULL,NULL),
 ('N3_TN1',N'Lê Chi','DangLam','20260101',NULL,NULL,NULL,NULL),
 ('N3_NGHI',N'Nhân viên đã nghỉ','DaNghi','20260101','20260901',NULL,NULL,NULL);
INSERT dbo.LIEN_HE_NHAN_VIEN(MaNV,Loai,GiaTri)
VALUES ('N3_QL1','SDT',N'0903000001'),('N3_QL0','SDT',N'0903000002'),
 ('N3_PV1','SDT',N'0903000003'),('N3_PV2','SDT',N'0903000004'),
 ('N3_TN1','SDT',N'0903000005'),('N3_NGHI','SDT',N'0903000006');
INSERT dbo.QUAN_LY(MaNV,DuocDuyetChamCong,DuocChotBangLuong,DuocDuyetKho,DuocDuyetKPI)
VALUES ('N3_QL1',1,1,1,1),('N3_QL0',0,0,0,0);
INSERT dbo.PHUC_VU(MaNV,SoBanPhuTrachToiDa)
VALUES ('N3_PV1',2),('N3_PV2',1),('N3_NGHI',1);
-- QL1 kiem nhiem thu ngan: minh hoa chuyen biet hoa chong lap.
INSERT dbo.THU_NGAN(MaNV,DuocHuyHoaDon) VALUES ('N3_TN1',0),('N3_QL1',1);
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

