/* Nang cap database da cai ban truoc; KHONG chay lai 01 tren database nay.
   Doi USE neu ten database khac. Sau do chay lai 02 de cap nhat trigger/SP/quyen.
   Database moi: bo qua 00, chay 01 -> 02 -> 03 -> 05 -> 04.
*/
:ON ERROR EXIT
USE [BTL2_Nguoi3_Demo];
GO
SET XACT_ABORT ON;
IF OBJECT_ID(N'dbo.NHAN_VIEN',N'U') IS NULL
 THROW 53222,N'Chưa có lược đồ cũ; dùng quy trình cài mới.',1;
IF COL_LENGTH(N'dbo.NHAN_VIEN',N'TrangThaiHoSo') IS NULL
 ALTER TABLE dbo.NHAN_VIEN ADD TrangThaiHoSo VARCHAR(12) NOT NULL
  CONSTRAINT DF_NV_HoSo DEFAULT 'Nhap' WITH VALUES,
  CONSTRAINT CK_NV_HoSo CHECK(TrangThaiHoSo IN('Nhap','HoanTat'));
GO
-- Khong tu tao vai tro hay lien he gia cho ho so cu thieu du lieu.
UPDATE n SET TrangThaiHoSo='HoanTat' FROM dbo.NHAN_VIEN n
 WHERE n.TrangThaiHoSo='Nhap'
 AND EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN h WHERE h.MaNV=n.MaNV)
 AND (EXISTS(SELECT 1 FROM dbo.PHUC_VU p WHERE p.MaNV=n.MaNV)
  OR EXISTS(SELECT 1 FROM dbo.THU_NGAN t WHERE t.MaNV=n.MaNV)
  OR EXISTS(SELECT 1 FROM dbo.QUAN_LY q WHERE q.MaNV=n.MaNV));
SELECT MaNV,HoTen,TrangThaiHoSo FROM dbo.NHAN_VIEN WHERE TrangThaiHoSo='Nhap';
PRINT N'Các hồ sơ còn ở trạng thái Nhap cần bổ sung bằng usp_N3_HoSoNhanVien sau khi cập nhật 02.';
GO
