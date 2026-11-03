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
/* NAM TRUY VAN DOC Q01--Q05. Chay 05 truoc de xem du luong demo.
 Co the chay lai nhieu lan; dieu chinh tham so theo nhu cau. */
/* E. NAM TRUY VAN BAN GIAO Q01--Q05.
   Doi tham so tu/ngay theo nhu cau; ma demo chi dung de minh hoa dau vao.
*/
-- Q01. Lich lam viec: tach lich da xep khoi ket qua cham cong.
DECLARE @Q01TuNgay DATE='20261001',@Q01DenNgay DATE='20261005',@Q01MaNV VARCHAR(30)=NULL;
SELECT n.MaNV,n.HoTen,c.MaCa,m.TenMauCa,c.NgayLam,c.GioBatDau,c.GioKetThuc,
 c.LoaiNgayLich,l.LoaiNgayApDung,cc.TrangThaiCong,cc.TrangThaiDuyet
FROM dbo.LAM_VIEC l JOIN dbo.NHAN_VIEN n ON n.MaNV=l.MaNV
JOIN dbo.CA_LAM c ON c.MaCa=l.MaCa JOIN dbo.MAU_CA m ON m.MaMauCa=c.MaMauCa
LEFT JOIN dbo.CHAM_CONG cc ON cc.MaNV=l.MaNV AND cc.MaCa=l.MaCa
WHERE c.NgayLam>=@Q01TuNgay AND c.NgayLam<@Q01DenNgay AND (@Q01MaNV IS NULL OR l.MaNV=@Q01MaNV)
ORDER BY c.NgayLam,c.GioBatDau,n.MaNV;
GO
-- Q02. Nhan vien phu trach ban tai mot thoi diem, dung khoang nua mo.
DECLARE @Q02MaBan VARCHAR(30)='N3_B01',@Q02ThoiDiem DATETIME2(0)='2026-10-01T09:00:00';
SELECT p.MaBan,b.TenBan,p.MaCa,c.NgayLam,c.GioBatDau,c.GioKetThuc,p.MaNV,n.HoTen
FROM dbo.PHAN_CONG p JOIN dbo.BAN b ON b.MaBan=p.MaBan
JOIN dbo.LAM_VIEC l ON l.MaNV=p.MaNV AND l.MaCa=p.MaCa
JOIN dbo.NHAN_VIEN n ON n.MaNV=p.MaNV JOIN dbo.CA_LAM c ON c.MaCa=p.MaCa
WHERE p.MaBan=@Q02MaBan AND c.NgayLam=CONVERT(DATE,@Q02ThoiDiem)
 AND CONVERT(TIME(0),@Q02ThoiDiem)>=c.GioBatDau AND CONVERT(TIME(0),@Q02ThoiDiem)<c.GioKetThuc
ORDER BY p.MaCa,p.MaNV;
GO
-- Q03. Cong thuc te va cong duyet: phut co mat khong dong nhat phut tra luong.
DECLARE @Q03TuNgay DATE='20261001',@Q03DenNgay DATE='20261005';
SELECT cc.MaNV,n.HoTen,cc.MaCa,c.NgayLam,cc.TrangThaiCong,cc.TrangThaiDuyet,
 cc.GioVaoThucTe,cc.GioRaThucTe,DATEDIFF(MINUTE,cc.GioVaoThucTe,cc.GioRaThucTe) AS PhutCoMat,
 DATEDIFF(MINUTE,c.GioBatDau,c.GioKetThuc) AS PhutCaChuan,
 cc.PhutCongDuyet,cc.PhutTangCaDuyet,f.PhutCongTinhLuong,cc.MaNVDuyet,cc.CanCuDuyetCong
FROM dbo.CHAM_CONG cc JOIN dbo.NHAN_VIEN n ON n.MaNV=cc.MaNV
JOIN dbo.CA_LAM c ON c.MaCa=cc.MaCa OUTER APPLY dbo.fn_N3_TinhTienCong(cc.MaNV,cc.MaCa) f
WHERE c.NgayLam>=@Q03TuNgay AND c.NgayLam<@Q03DenNgay
ORDER BY cc.MaNV,c.NgayLam,c.GioBatDau;
GO
-- Q04. Tang ca da duyet, tong hop theo nhan vien va loai ngay; khong dem cong chua duyet.
DECLARE @Q04TuNgay DATE='20261001',@Q04DenNgay DATE='20261005';
SELECT cc.MaNV,n.HoTen,cc.LoaiNgayTangCa,COUNT(*) AS SoCaTangCa,
 SUM(cc.PhutTangCaDuyet) AS TongPhutTangCa,SUM(f.TienTangCa) AS TongTienTangCa
FROM dbo.CHAM_CONG cc JOIN dbo.NHAN_VIEN n ON n.MaNV=cc.MaNV
JOIN dbo.CA_LAM c ON c.MaCa=cc.MaCa CROSS APPLY dbo.fn_N3_TinhTienCong(cc.MaNV,cc.MaCa) f
WHERE c.NgayLam>=@Q04TuNgay AND c.NgayLam<@Q04DenNgay
 AND cc.TrangThaiDuyet='DaDuyet' AND cc.PhutTangCaDuyet>0
GROUP BY cc.MaNV,n.HoTen,cc.LoaiNgayTangCa ORDER BY cc.MaNV,cc.LoaiNgayTangCa;
GO
-- Q05. Bang luong: gom ca va dieu chinh rieng truoc JOIN, tranh nhan cheo cac dong tien.
DECLARE @Q05MaBangLuong VARCHAR(30)='N3_BL1001';
WITH LuongCa AS (
 SELECT MaBangLuong,MaNV,COUNT(*) AS SoCa,SUM(TienLuongCaSnapshot) AS LuongChinh,
  SUM(TienTangCaSnapshot) AS LuongTangCa
 FROM dbo.CHI_TIET_LUONG_CA GROUP BY MaBangLuong,MaNV
), DieuChinh AS (
 SELECT MaBangLuong,MaNV,
 SUM(CASE WHEN LoaiDieuChinh='Thuong' THEN SoTien ELSE 0 END) AS TongThuong,
 SUM(CASE WHEN LoaiDieuChinh='PhuCap' THEN SoTien ELSE 0 END) AS TongPhuCap,
 SUM(CASE WHEN LoaiDieuChinh='GiamTru' THEN SoTien ELSE 0 END) AS TongGiamTru
 FROM dbo.DIEU_CHINH_LUONG GROUP BY MaBangLuong,MaNV
)
SELECT p.MaBangLuong,b.TenKy,b.TrangThaiBangLuong,p.MaNV,n.HoTen,ISNULL(l.SoCa,0) AS SoCa,
 ISNULL(l.LuongChinh,0) AS LuongChinh,ISNULL(l.LuongTangCa,0) AS LuongTangCa,
 ISNULL(d.TongThuong,0) AS TongThuong,ISNULL(d.TongPhuCap,0) AS TongPhuCap,ISNULL(d.TongGiamTru,0) AS TongGiamTru,
 ISNULL(l.LuongChinh,0)+ISNULL(l.LuongTangCa,0)+ISNULL(d.TongThuong,0)+ISNULL(d.TongPhuCap,0)-ISNULL(d.TongGiamTru,0) AS LuongThucNhan,
 p.SoTienChot,p.TrangThaiChiTra,p.SoTienChiTra,p.ThoiDiemChiTra,p.PhuongThucChiTra
FROM dbo.CHI_TIET_BANG_LUONG p JOIN dbo.BANG_LUONG b ON b.MaBangLuong=p.MaBangLuong
JOIN dbo.NHAN_VIEN n ON n.MaNV=p.MaNV
LEFT JOIN LuongCa l ON l.MaBangLuong=p.MaBangLuong AND l.MaNV=p.MaNV
LEFT JOIN DieuChinh d ON d.MaBangLuong=p.MaBangLuong AND d.MaNV=p.MaNV
WHERE p.MaBangLuong=@Q05MaBangLuong ORDER BY p.MaNV;
GO
