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
/* CHAY SAU 01: rang buoc, ho so nhan vien, nghiep vu cong/luong va quyen ung dung. */
/* PHAN II. TRIGGER BAO TOAN DU LIEU.
   Kiem tra da dong: cung co them lop thu tuc va quyen SQL o phan sau.
   UPDLOCK/HOLDLOCK giu khoa khoang khi kiem cac khoang thoi gian.
*/
CREATE OR ALTER TRIGGER dbo.tr_N3_NhanVien ON dbo.NHAN_VIEN AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted WHERE NgaySinh>CAST(SYSDATETIME() AS DATE))
  THROW 53100,N'Ngày sinh không được sau ngày hiện tại.',1;
 IF EXISTS(SELECT 1 FROM deleted d JOIN inserted i ON i.MaNV=d.MaNV WHERE d.TrangThaiHoSo='HoanTat' AND i.TrangThaiHoSo<>'HoanTat')
  THROW 53200,N'Hồ sơ đã hoàn tất không được đưa về trạng thái nhập.',1;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.TrangThaiHoSo='HoanTat' AND (
  NOT EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN h WHERE h.MaNV=i.MaNV) OR
  (NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU p WHERE p.MaNV=i.MaNV) AND
   NOT EXISTS(SELECT 1 FROM dbo.THU_NGAN t WHERE t.MaNV=i.MaNV) AND
   NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q WHERE q.MaNV=i.MaNV))))
  THROW 53201,N'Hoàn tất hồ sơ cần ít nhất một vai trò và một liên hệ.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_BaoToan_LIEN_HE_NHAN_VIEN ON dbo.LIEN_HE_NHAN_VIEN AFTER UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.NHAN_VIEN n WITH(UPDLOCK,HOLDLOCK)
  JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV;
 IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN n JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV
  WHERE n.TrangThaiHoSo='HoanTat' AND NOT EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN h WHERE h.MaNV=n.MaNV))
  THROW 53202,N'Hồ sơ hoàn tất phải giữ ít nhất một liên hệ và một vai trò.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.tr_N3_BaoToan_PHUC_VU ON dbo.PHUC_VU AFTER UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.NHAN_VIEN n WITH(UPDLOCK,HOLDLOCK)
  JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV;
 IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN n JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV
  WHERE n.TrangThaiHoSo='HoanTat' AND (NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU p WHERE p.MaNV=n.MaNV) AND NOT EXISTS(SELECT 1 FROM dbo.THU_NGAN t WHERE t.MaNV=n.MaNV) AND NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q WHERE q.MaNV=n.MaNV)))
  THROW 53203,N'Hồ sơ hoàn tất phải giữ ít nhất một liên hệ và một vai trò.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.tr_N3_BaoToan_THU_NGAN ON dbo.THU_NGAN AFTER UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.NHAN_VIEN n WITH(UPDLOCK,HOLDLOCK)
  JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV;
 IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN n JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV
  WHERE n.TrangThaiHoSo='HoanTat' AND (NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU p WHERE p.MaNV=n.MaNV) AND NOT EXISTS(SELECT 1 FROM dbo.THU_NGAN t WHERE t.MaNV=n.MaNV) AND NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q WHERE q.MaNV=n.MaNV)))
  THROW 53203,N'Hồ sơ hoàn tất phải giữ ít nhất một liên hệ và một vai trò.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.tr_N3_BaoToan_QUAN_LY ON dbo.QUAN_LY AFTER UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.NHAN_VIEN n WITH(UPDLOCK,HOLDLOCK)
  JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV;
 IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN n JOIN (SELECT MaNV FROM deleted UNION SELECT MaNV FROM inserted) a ON a.MaNV=n.MaNV
  WHERE n.TrangThaiHoSo='HoanTat' AND (NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU p WHERE p.MaNV=n.MaNV) AND NOT EXISTS(SELECT 1 FROM dbo.THU_NGAN t WHERE t.MaNV=n.MaNV) AND NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q WHERE q.MaNV=n.MaNV)))
  THROW 53203,N'Hồ sơ hoàn tất phải giữ ít nhất một liên hệ và một vai trò.',1;
END;
GO

CREATE OR ALTER TRIGGER dbo.tr_N3_CaLam ON dbo.CA_LAM AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted D JOIN dbo.LAM_VIEC L ON L.MaCa=D.MaCa)
  THROW 53101,N'Ca đã có lịch làm không được sửa hoặc xóa; giữ khung giờ lịch sử.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B
   ON I.NgayLam>=B.TuNgay AND I.NgayLam<B.DenNgay WHERE B.TrangThaiBangLuong='DaChot')
  THROW 53135,N'Không được thêm hoặc sửa ca trong kỳ lương đã chốt.',1;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.CA_LAM WITH(UPDLOCK,HOLDLOCK);
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM C ON C.NgayLam=I.NgayLam
    AND C.MaCa<>I.MaCa AND C.GioBatDau<I.GioKetThuc AND I.GioBatDau<C.GioKetThuc)
  THROW 53102,N'Các ca cùng ngày không được chồng giờ; cho phép hai ca nối sát.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.MAU_CA M ON M.MaMauCa=I.MaMauCa
   WHERE M.TrangThai<>'DangSuDung')
  THROW 53103,N'Không được xếp ca mới từ mẫu ca đã ngừng sử dụng.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_LamViec ON dbo.LAM_VIEC AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted D JOIN dbo.CHAM_CONG C ON C.MaNV=D.MaNV AND C.MaCa=D.MaCa)
  THROW 53104,N'Lịch làm đã có chấm công không được sửa hoặc xóa.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
   JOIN dbo.BANG_LUONG B ON C.NgayLam>=B.TuNgay AND C.NgayLam<B.DenNgay WHERE B.TrangThaiBangLuong='DaChot')
  THROW 53136,N'Không được xếp lịch thêm trong kỳ lương đã chốt.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.NHAN_VIEN N ON N.MaNV=I.MaNV
    JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
    WHERE N.TrangThaiLamViec<>'DangLam' OR N.TrangThaiHoSo<>'HoanTat' OR C.NgayLam<N.NgayVaoLam
      OR (C.LoaiNgayLich='NgayLe' AND I.LoaiNgayApDung<>'NgayLe')
      OR (C.LoaiNgayLich='NgayThuong' AND I.LoaiNgayApDung='NgayLe'))
  THROW 53105,N'Lịch làm phải đúng thời gian làm việc và đúng loại ngày áp dụng.',1;
 IF EXISTS(SELECT 1 FROM inserted I WHERE
   (NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU P WHERE P.MaNV=I.MaNV)
    AND NOT EXISTS(SELECT 1 FROM dbo.THU_NGAN T WHERE T.MaNV=I.MaNV)
    AND NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY Q WHERE Q.MaNV=I.MaNV))
   OR NOT EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN H WHERE H.MaNV=I.MaNV))
  THROW 53106,N'Nhân viên phải có ít nhất một vai trò và một liên hệ trước khi xếp lịch.',1;
 -- Chieu nguoc cua rang buoc OT: khong xep them ca giao khoang OT da ghi nhan.
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM CA ON CA.MaCa=I.MaCa
   JOIN dbo.CHAM_CONG CC ON CC.MaNV=I.MaNV AND CC.MaCa<>I.MaCa
   CROSS APPLY(SELECT DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),CA.GioBatDau),CAST(CA.NgayLam AS DATETIME2(0))) BD,
                      DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),CA.GioKetThuc),CAST(CA.NgayLam AS DATETIME2(0))) KT) T
   WHERE (CC.OTTruocBatDau<T.KT AND T.BD<CC.OTTruocKetThuc)
      OR (CC.OTSauBatDau<T.KT AND T.BD<CC.OTSauKetThuc))
  THROW 53138,N'Ca mới giao thời gian tăng ca đã ghi nhận của nhân viên.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_PhanCong ON dbo.PHAN_CONG AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 -- Phan cong da bat dau ca la can cu lich su, ke ca chua co rating.
 IF EXISTS(SELECT 1 FROM deleted d JOIN dbo.CA_LAM c ON c.MaCa=d.MaCa
  WHERE DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),c.GioBatDau),CAST(c.NgayLam AS DATETIME2(0)))<=SYSDATETIME())
  THROW 53204,N'Không sửa hoặc xóa phân công của ca đã bắt đầu.',1;
 IF EXISTS(SELECT 1 FROM deleted) AND EXISTS(SELECT 1 FROM inserted i JOIN dbo.CA_LAM c ON c.MaCa=i.MaCa
  WHERE DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),c.GioBatDau),CAST(c.NgayLam AS DATETIME2(0)))<=SYSDATETIME())
  THROW 53204,N'Không chuyển phân công tương lai vào một ca đã bắt đầu.',1;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.PHAN_CONG WITH(UPDLOCK,HOLDLOCK);
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.NHAN_VIEN N ON N.MaNV=I.MaNV
   JOIN dbo.BAN B ON B.MaBan=I.MaBan
   WHERE N.TrangThaiLamViec<>'DangLam' OR N.TrangThaiHoSo<>'HoanTat' OR B.TrangThaiHoatDong<>'HoatDong')
  THROW 53107,N'Chỉ phân công nhân viên đang làm cho bàn hoạt động.',1;
 IF EXISTS(SELECT P.MaNV,P.MaCa FROM dbo.PHAN_CONG P JOIN dbo.PHUC_VU V ON V.MaNV=P.MaNV
   WHERE V.SoBanPhuTrachToiDa IS NOT NULL
   GROUP BY P.MaNV,P.MaCa,V.SoBanPhuTrachToiDa
   HAVING COUNT_BIG(*)>V.SoBanPhuTrachToiDa)
  THROW 53108,N'Số bàn được phân công trong ca vượt giới hạn phục vụ.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_GioiHanBan ON dbo.PHUC_VU AFTER UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT I.MaNV,P.MaCa FROM inserted I JOIN dbo.PHAN_CONG P ON P.MaNV=I.MaNV
  WHERE I.SoBanPhuTrachToiDa IS NOT NULL GROUP BY I.MaNV,P.MaCa,I.SoBanPhuTrachToiDa
  HAVING COUNT_BIG(*)>I.SoBanPhuTrachToiDa)
  THROW 53108,N'Không thể hạ giới hạn dưới số bàn đã phân công.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_MucLuong ON dbo.MUC_LUONG_CA AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted D JOIN dbo.CHI_TIET_LUONG_CA C ON C.MaMucLuong=D.MaMucLuong)
  THROW 53109,N'Phiên bản mức lương đã dùng phải giữ nguyên; tạo phiên bản mới cho kỳ sau.',1;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.MUC_LUONG_CA WITH(UPDLOCK,HOLDLOCK);
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.MUC_LUONG_CA M
  ON M.MaNV=I.MaNV AND M.MaMauCa=I.MaMauCa AND M.MaMucLuong<>I.MaMucLuong
  AND M.TuNgay<I.DenNgay AND I.TuNgay<M.DenNgay)
  THROW 53110,N'Khoảng hiệu lực lương cùng nhân viên và mẫu ca không được chồng nhau.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_ChamCong ON dbo.CHAM_CONG AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted D JOIN dbo.CHI_TIET_LUONG_CA L ON L.MaNV=D.MaNV AND L.MaCa=D.MaCa
   JOIN dbo.BANG_LUONG B ON B.MaBangLuong=L.MaBangLuong WHERE B.TrangThaiBangLuong='DaChot')
  THROW 53111,N'Công thuộc bảng lương đã chốt không được sửa hoặc xóa.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
   JOIN dbo.BANG_LUONG B ON C.NgayLam>=B.TuNgay AND C.NgayLam<B.DenNgay WHERE B.TrangThaiBangLuong='DaChot')
  THROW 53111,N'Không được thêm hoặc sửa công trong kỳ lương đã chốt; điều chỉnh ở kỳ sau.',1;
 IF EXISTS(SELECT 1 FROM inserted I CROSS APPLY(VALUES(I.GioVaoThucTe),(I.GioRaThucTe),
   (I.OTTruocBatDau),(I.OTTruocKetThuc),(I.OTSauBatDau),(I.OTSauKetThuc)) T(Moc)
   WHERE DATEPART(SECOND,T.Moc)<>0)
  THROW 53137,N'Các mốc chấm công và tăng ca được ghi chính xác đến phút.',1;
 -- Ca khong qua dem. Gio vao/ra va cac khoang OT deu nam trong ngay ca.
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
   WHERE (I.GioVaoThucTe IS NOT NULL AND CAST(I.GioVaoThucTe AS DATE)<>C.NgayLam)
      OR (I.GioRaThucTe IS NOT NULL AND CAST(I.GioRaThucTe AS DATE)<>C.NgayLam))
  THROW 53112,N'Giờ vào và ra phải thuộc ngày của ca, không qua đêm.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
   WHERE (I.OTTruocBatDau IS NOT NULL AND
    (I.GioVaoThucTe IS NULL OR I.GioRaThucTe IS NULL OR I.OTTruocBatDau<I.GioVaoThucTe
     OR I.OTTruocKetThuc>I.GioRaThucTe OR CAST(I.OTTruocKetThuc AS DATE)<>C.NgayLam
     OR CAST(I.OTTruocBatDau AS DATE)<>C.NgayLam OR CAST(I.OTTruocKetThuc AS TIME(0))>C.GioBatDau))
   OR (I.OTSauBatDau IS NOT NULL AND
    (I.GioVaoThucTe IS NULL OR I.GioRaThucTe IS NULL OR I.OTSauBatDau<I.GioVaoThucTe
     OR I.OTSauKetThuc>I.GioRaThucTe OR CAST(I.OTSauBatDau AS DATE)<>C.NgayLam
     OR CAST(I.OTSauKetThuc AS DATE)<>C.NgayLam OR CAST(I.OTSauBatDau AS TIME(0))<C.GioKetThuc)))
  THROW 53113,N'Khoảng tăng ca phải nằm trong giờ thực tế và ở ngoài ca chuẩn.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
   JOIN dbo.LAM_VIEC V ON V.MaNV=I.MaNV AND V.MaCa=I.MaCa
   LEFT JOIN dbo.QUAN_LY Q ON Q.MaNV=I.MaNVDuyet
   LEFT JOIN dbo.NHAN_VIEN N ON N.MaNV=Q.MaNV
   CROSS APPLY(SELECT DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),C.GioBatDau),CAST(C.NgayLam AS DATETIME2(0))) BD,
                      DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),C.GioKetThuc),CAST(C.NgayLam AS DATETIME2(0))) KT) T
   CROSS APPLY(SELECT CASE WHEN I.GioVaoThucTe>T.BD THEN I.GioVaoThucTe ELSE T.BD END BD,
                      CASE WHEN I.GioRaThucTe<T.KT THEN I.GioRaThucTe ELSE T.KT END KT) G
   WHERE I.TrangThaiDuyet='DaDuyet' AND
    (Q.MaNV IS NULL OR Q.DuocDuyetChamCong<>1 OR N.TrangThaiLamViec<>'DangLam' OR N.TrangThaiHoSo<>'HoanTat'
     OR I.ThoiDiemDuyet<T.KT OR (I.GioRaThucTe IS NOT NULL AND I.ThoiDiemDuyet<I.GioRaThucTe)
     OR I.PhutCongDuyet>DATEDIFF(MINUTE,C.GioBatDau,C.GioKetThuc)
     OR (I.TrangThaiCong='DiLam' AND (I.GioVaoThucTe IS NULL OR I.GioRaThucTe IS NULL
       OR (I.LaNgoaiLeCong=0 AND I.PhutCongDuyet>CASE WHEN G.KT>G.BD THEN DATEDIFF(MINUTE,G.BD,G.KT) ELSE 0 END)))
     OR I.PhutTangCaDuyet<>COALESCE(DATEDIFF(MINUTE,I.OTTruocBatDau,I.OTTruocKetThuc),0)
                                +COALESCE(DATEDIFF(MINUTE,I.OTSauBatDau,I.OTSauKetThuc),0)
     OR (I.PhutTangCaDuyet>0 AND I.LoaiNgayTangCa<>V.LoaiNgayApDung)))
  THROW 53114,N'Duyệt công sai quyền, thời điểm, phút công hoặc căn cứ tăng ca.',1;
 -- OT khong giao ca duoc xep cua cung nhan vien, ke ca ca khac chua cham cong.
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.LAM_VIEC V ON V.MaNV=I.MaNV AND V.MaCa<>I.MaCa
   JOIN dbo.CA_LAM C ON C.MaCa=V.MaCa
   CROSS APPLY(SELECT DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),C.GioBatDau),CAST(C.NgayLam AS DATETIME2(0))) BD,
                      DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),C.GioKetThuc),CAST(C.NgayLam AS DATETIME2(0))) KT) T
   WHERE (I.OTTruocBatDau<T.KT AND T.BD<I.OTTruocKetThuc)
      OR (I.OTSauBatDau<T.KT AND T.BD<I.OTSauKetThuc))
  THROW 53115,N'Tăng ca giao giờ với một ca khác của cùng nhân viên.',1;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.CHAM_CONG WITH(UPDLOCK,HOLDLOCK);
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CHAM_CONG C ON C.MaNV=I.MaNV AND C.MaCa<>I.MaCa
   WHERE (I.OTTruocBatDau<C.OTTruocKetThuc AND C.OTTruocBatDau<I.OTTruocKetThuc)
      OR (I.OTTruocBatDau<C.OTSauKetThuc AND C.OTSauBatDau<I.OTTruocKetThuc)
      OR (I.OTSauBatDau<C.OTTruocKetThuc AND C.OTTruocBatDau<I.OTSauKetThuc)
      OR (I.OTSauBatDau<C.OTSauKetThuc AND C.OTSauBatDau<I.OTSauKetThuc))
  THROW 53116,N'Các khoảng tăng ca cùng nhân viên không được chồng nhau.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_NhatKyCong ON dbo.LICH_SU_SUA_CHAM_CONG AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted)
  THROW 53117,N'Nhật ký sửa công là bất biến, không được sửa hoặc xóa.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.QUAN_LY Q ON Q.MaNV=I.MaNVSua
   JOIN dbo.NHAN_VIEN N ON N.MaNV=Q.MaNV
   WHERE Q.DuocDuyetChamCong<>1 OR N.TrangThaiLamViec<>'DangLam' OR N.TrangThaiHoSo<>'HoanTat')
  THROW 53118,N'Người sửa công phải là quản lý đang làm và có quyền duyệt công.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_BangLuong ON dbo.BANG_LUONG AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM deleted WHERE TrangThaiBangLuong='DaChot')
  THROW 53119,N'Bảng lương đã chốt không được sửa, xóa hoặc mở lại.',1;
 DECLARE @Khoa BIGINT;
 SELECT @Khoa=COUNT_BIG(*) FROM dbo.BANG_LUONG WITH(UPDLOCK,HOLDLOCK);
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong<>I.MaBangLuong
   AND B.TuNgay<I.DenNgay AND I.TuNgay<B.DenNgay)
  THROW 53120,N'Các kỳ lương không được giao khoảng ngày.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.QUAN_LY Q ON Q.MaNV=I.MaNVChot
   JOIN dbo.NHAN_VIEN N ON N.MaNV=Q.MaNV WHERE I.TrangThaiBangLuong='DaChot'
    AND (Q.DuocChotBangLuong<>1 OR N.TrangThaiLamViec<>'DangLam' OR N.TrangThaiHoSo<>'HoanTat' OR I.ThoiDiemChot<CAST(I.DenNgay AS DATETIME2(0))))
  THROW 53121,N'Chốt lương sai quyền hoặc kỳ lương chưa kết thúc.',1;
 IF EXISTS(SELECT 1 FROM inserted I WHERE I.TrangThaiBangLuong='DaChot'
  AND NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG P WHERE P.MaBangLuong=I.MaBangLuong))
  THROW 53122,N'Bảng lương chốt phải có ít nhất một phiếu lương.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.CHI_TIET_BANG_LUONG P ON P.MaBangLuong=I.MaBangLuong
  OUTER APPLY(SELECT SUM(C.TienLuongCaSnapshot+C.TienTangCaSnapshot) Tien
   FROM dbo.CHI_TIET_LUONG_CA C WHERE C.MaBangLuong=P.MaBangLuong AND C.MaNV=P.MaNV) L
  OUTER APPLY(SELECT SUM(CASE WHEN D.LoaiDieuChinh='GiamTru' THEN -D.SoTien ELSE D.SoTien END) Tien
   FROM dbo.DIEU_CHINH_LUONG D WHERE D.MaBangLuong=P.MaBangLuong AND D.MaNV=P.MaNV) DC
  WHERE I.TrangThaiBangLuong='DaChot' AND (P.SoTienChot IS NULL
     OR P.SoTienChot<>COALESCE(L.Tien,0)+COALESCE(DC.Tien,0)))
  THROW 53123,N'Số tiền chốt phải bằng tổng tiền ca, tăng ca và các khoản điều chỉnh.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.DIEU_CHINH_LUONG D ON D.MaBangLuong=I.MaBangLuong
  WHERE I.TrangThaiBangLuong='DaChot' AND
    (D.MaNVDuyet IS NULL OR D.ThoiDiemDuyet IS NULL OR D.ThoiDiemDuyet>I.ThoiDiemChot))
  THROW 53124,N'Mọi khoản điều chỉnh phải được duyệt trước hoặc tại thời điểm chốt.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_PhieuLuong ON dbo.CHI_TIET_BANG_LUONG AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 -- Khi da chot, chi cho phep dung mot lan ChuaTra -> DaTra; cac truong khac giu nguyen.
 IF EXISTS(SELECT 1 FROM deleted D JOIN dbo.BANG_LUONG B ON B.MaBangLuong=D.MaBangLuong
   LEFT JOIN inserted I ON I.MaBangLuong=D.MaBangLuong AND I.MaNV=D.MaNV
   WHERE B.TrangThaiBangLuong='DaChot' AND
    (I.MaNV IS NULL OR D.TrangThaiChiTra<>'ChuaTra' OR I.TrangThaiChiTra<>'DaTra'
     OR I.SoTienChot<>D.SoTienChot OR (I.SoTienChot IS NULL AND D.SoTienChot IS NOT NULL)
     OR (I.SoTienChot IS NOT NULL AND D.SoTienChot IS NULL)
     OR ISNULL(I.GhiChu,N'')<>ISNULL(D.GhiChu,N'')
     OR (I.GhiChu IS NULL AND D.GhiChu IS NOT NULL) OR (I.GhiChu IS NOT NULL AND D.GhiChu IS NULL)))
  THROW 53125,N'Phiếu lương chốt chỉ được ghi nhận chi trả đúng một lần, giữ nguyên cơ sở lương.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong=I.MaBangLuong
   LEFT JOIN deleted D ON D.MaBangLuong=I.MaBangLuong AND D.MaNV=I.MaNV
   WHERE B.TrangThaiBangLuong='DaChot' AND D.MaNV IS NULL)
  THROW 53126,N'Không được thêm phiếu vào kỳ lương đã chốt.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong=I.MaBangLuong
   JOIN dbo.NHAN_VIEN N ON N.MaNV=I.MaNV WHERE I.TrangThaiChiTra='DaTra' AND
    (B.TrangThaiBangLuong<>'DaChot' OR I.ThoiDiemChiTra<B.ThoiDiemChot
     OR (I.PhuongThucChiTra='ChuyenKhoan' AND
       (N.TenNganHang IS NULL OR N.SoTaiKhoan IS NULL OR N.ChuTaiKhoan IS NULL))))
  THROW 53127,N'Chỉ trả sau chốt; chuyển khoản cần đủ thông tin tài khoản nhận lương.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_LuongCa ON dbo.CHI_TIET_LUONG_CA AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong=I.MaBangLuong WHERE B.TrangThaiBangLuong='DaChot')
 OR EXISTS(SELECT 1 FROM deleted D JOIN dbo.BANG_LUONG B ON B.MaBangLuong=D.MaBangLuong WHERE B.TrangThaiBangLuong='DaChot')
  THROW 53128,N'Dòng lương ca đã chốt không được thêm, sửa hoặc xóa.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong=I.MaBangLuong
  JOIN dbo.CHAM_CONG CC ON CC.MaNV=I.MaNV AND CC.MaCa=I.MaCa
  JOIN dbo.CA_LAM C ON C.MaCa=I.MaCa
  JOIN dbo.LAM_VIEC LV ON LV.MaNV=I.MaNV AND LV.MaCa=I.MaCa
  JOIN dbo.MUC_LUONG_CA M ON M.MaMucLuong=I.MaMucLuong
  CROSS APPLY(SELECT CASE WHEN CC.TrangThaiCong='NghiPhepHuongLuong'
       THEN DATEDIFF(MINUTE,C.GioBatDau,C.GioKetThuc)
       WHEN CC.TrangThaiCong='DiLam' THEN CC.PhutCongDuyet ELSE 0 END PC,
       CASE WHEN CC.PhutTangCaDuyet=0 THEN CAST(0 AS DECIMAL(8,4))
       WHEN LV.LoaiNgayApDung='NgayThuong' THEN M.HeSoTangCaThuong
       WHEN LV.LoaiNgayApDung='NgayNghiTuan' THEN M.HeSoTangCaNghiTuan ELSE M.HeSoTangCaNgayLe END HS) X
  WHERE CC.TrangThaiDuyet<>'DaDuyet' OR C.NgayLam<B.TuNgay OR C.NgayLam>=B.DenNgay
    OR M.MaNV<>I.MaNV OR M.MaMauCa<>C.MaMauCa OR C.NgayLam<M.TuNgay OR C.NgayLam>=M.DenNgay
    OR I.MucLuongCaApDung<>M.DonGiaCa OR I.PhutCaChuan<>DATEDIFF(MINUTE,C.GioBatDau,C.GioKetThuc)
    OR I.PhutCongTinhLuong<>X.PC OR I.HeSoTangCaApDung<>X.HS
    OR I.PhutTangCaSnapshot<>CC.PhutTangCaDuyet
    OR ISNULL(I.LoaiNgayTangCaSnapshot,'')<>ISNULL(CC.LoaiNgayTangCa,'')
    OR I.TyLeCongApDung<>CAST(CAST(I.PhutCongTinhLuong AS DECIMAL(18,8))/I.PhutCaChuan AS DECIMAL(12,8))
    OR I.TienLuongCaSnapshot<>ROUND(I.MucLuongCaApDung*CAST(I.PhutCongTinhLuong AS DECIMAL(18,6))/I.PhutCaChuan,0)
    OR I.TienTangCaSnapshot<>ROUND(I.MucLuongCaApDung*CAST(I.PhutTangCaSnapshot AS DECIMAL(18,6))*I.HeSoTangCaApDung/I.PhutCaChuan,0))
  THROW 53129,N'Dòng lương phải đúng công đã duyệt, kỳ, phiên bản mức lương và công thức snapshot.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.tr_N3_DieuChinhLuong ON dbo.DIEU_CHINH_LUONG AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong=I.MaBangLuong WHERE B.TrangThaiBangLuong='DaChot')
 OR EXISTS(SELECT 1 FROM deleted D JOIN dbo.BANG_LUONG B ON B.MaBangLuong=D.MaBangLuong WHERE B.TrangThaiBangLuong='DaChot')
  THROW 53130,N'Điều chỉnh thuộc kỳ đã chốt là bất biến; ghi khoản bù ở kỳ sau.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.BANG_LUONG B ON B.MaBangLuong=I.MaBangLuong
  JOIN dbo.BANG_LUONG G ON G.MaBangLuong=I.KyGocCanDieuChinh
  WHERE G.TrangThaiBangLuong<>'DaChot' OR G.DenNgay>B.TuNgay)
  THROW 53131,N'Kỳ gốc điều chỉnh phải đã chốt và đứng trước kỳ hiện tại.',1;
 IF EXISTS(SELECT 1 FROM inserted I JOIN dbo.QUAN_LY Q ON Q.MaNV=I.MaNVDuyet
  JOIN dbo.NHAN_VIEN N ON N.MaNV=Q.MaNV
  WHERE Q.DuocChotBangLuong<>1 OR N.TrangThaiLamViec<>'DangLam' OR N.TrangThaiHoSo<>'HoanTat')
  THROW 53132,N'Người duyệt điều chỉnh phải đang làm và có quyền chốt bảng lương.',1;
 IF EXISTS(SELECT 1 FROM inserted WHERE MaKyKPI IS NOT NULL)
 BEGIN
  IF OBJECT_ID(N'dbo.KET_QUA_KPI',N'U') IS NULL
    OR NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_DCL_KPI'
       AND parent_object_id=OBJECT_ID(N'dbo.DIEU_CHINH_LUONG') AND is_disabled=0 AND is_not_trusted=0)
   THROW 53133,N'Chưa tích hợp KET_QUA_KPI và khóa ngoại hợp lệ; không được nhập khoản thưởng có mã kỳ KPI.',1;
  DECLARE @Sai BIT=0;
  EXEC sys.sp_executesql N'SELECT @Sai=CASE WHEN EXISTS(
    SELECT 1 FROM dbo.DIEU_CHINH_LUONG D LEFT JOIN dbo.KET_QUA_KPI K
      ON K.MaKyKPI=D.MaKyKPI AND K.MaNV=D.MaNV
    WHERE D.MaKyKPI IS NOT NULL AND (K.MaNV IS NULL OR K.TrangThai<>''DaChot'')) THEN 1 ELSE 0 END;',
    N'@Sai BIT OUTPUT',@Sai OUTPUT;
  IF @Sai=1 THROW 53134,N'Thưởng KPI phải tham chiếu kết quả đã chốt của đúng nhân viên.',1;
 END;
END;
GO


/* C. Mot ham va ba thu tuc. SQL Server 2019+/2022, schema dbo.
   MaNguoiThucHien do ung dung da xac thuc truyen vao; khong phai ten login SQL.
   Thu tuc dung giao dich rieng, tu choi duoc goi trong giao dich dang mo.
   sp_getapplock serialize cac thao tac nghiep vu cua phan he nhan su. */
GO
CREATE OR ALTER FUNCTION dbo.fn_N3_TinhTienCong
(@MaNV VARCHAR(30), @MaCa VARCHAR(30))
RETURNS TABLE
AS RETURN
(
 SELECT cc.MaNV,cc.MaCa,ml.MaMucLuong,ml.DonGiaCa AS MucLuongCaApDung,
   p.PhutCaChuan,p.PhutCongTinhLuong,cc.PhutTangCaDuyet,
   CONVERT(DECIMAL(12,8),1.0*p.PhutCongTinhLuong/p.PhutCaChuan) AS TyLeCongApDung,
   h.HeSoTangCaApDung,lv.LoaiNgayApDung,
   CONVERT(DECIMAL(18,0),ROUND(ml.DonGiaCa*p.PhutCongTinhLuong/p.PhutCaChuan,0)) AS TienLuongCa,
   CONVERT(DECIMAL(18,0),ROUND(ml.DonGiaCa*CAST(cc.PhutTangCaDuyet AS DECIMAL(18,6))*h.HeSoTangCaApDung/p.PhutCaChuan,0)) AS TienTangCa
 FROM dbo.CHAM_CONG cc
 JOIN dbo.LAM_VIEC lv ON lv.MaNV=cc.MaNV AND lv.MaCa=cc.MaCa
 JOIN dbo.CA_LAM ca ON ca.MaCa=cc.MaCa
 JOIN dbo.MUC_LUONG_CA ml ON ml.MaNV=cc.MaNV AND ml.MaMauCa=ca.MaMauCa
   AND ca.NgayLam>=ml.TuNgay AND ca.NgayLam<ml.DenNgay
 CROSS APPLY (SELECT DATEDIFF(MINUTE,ca.GioBatDau,ca.GioKetThuc) AS PhutCaChuan,
   CASE cc.TrangThaiCong WHEN 'DiLam' THEN cc.PhutCongDuyet
    WHEN 'NghiPhepHuongLuong' THEN DATEDIFF(MINUTE,ca.GioBatDau,ca.GioKetThuc)
    ELSE 0 END AS PhutCongTinhLuong) p
 CROSS APPLY (SELECT CONVERT(DECIMAL(9,4),CASE WHEN cc.PhutTangCaDuyet=0 THEN 0
   WHEN lv.LoaiNgayApDung='NgayLe' THEN ml.HeSoTangCaNgayLe
   WHEN lv.LoaiNgayApDung='NgayNghiTuan' THEN ml.HeSoTangCaNghiTuan
   ELSE ml.HeSoTangCaThuong END) AS HeSoTangCaApDung) h
 WHERE cc.MaNV=@MaNV AND cc.MaCa=@MaCa AND cc.TrangThaiDuyet='DaDuyet'
);
GO
CREATE OR ALTER PROCEDURE dbo.usp_N3_PhanCongNhanVien
 @MaNguoiThucHien VARCHAR(30), @MaNV VARCHAR(30), @MaCa VARCHAR(30),
 @LoaiNgayApDung VARCHAR(20)='NgayThuong', @MaBan VARCHAR(30)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51000,N'Goi thu tuc ngoai giao dich dang mo.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @lk INT;
  EXEC @lk=sys.sp_getapplock @Resource=N'N3_NhanSu',@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;
  IF @lk<0 THROW 51001,N'Khong lay duoc khoa nhan su.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q JOIN dbo.NHAN_VIEN n ON n.MaNV=q.MaNV
     WHERE q.MaNV=@MaNguoiThucHien AND n.TrangThaiLamViec='DangLam' AND n.TrangThaiHoSo='HoanTat')
   THROW 51010,N'Chi quan ly dang lam duoc phan cong.',1;
  DECLARE @ng DATE,@loai VARCHAR(20);
  SELECT @ng=NgayLam,@loai=LoaiNgayLich FROM dbo.CA_LAM WITH(UPDLOCK,HOLDLOCK) WHERE MaCa=@MaCa;
  IF @ng IS NULL THROW 51011,N'Ca lam khong ton tai.',1;
  IF USER_NAME()<>N'dbo' AND ISNULL(IS_MEMBER(N'db_owner'),0)<>1 AND ISNULL(IS_SRVROLEMEMBER(N'sysadmin'),0)<>1
   AND EXISTS(SELECT 1 FROM dbo.CA_LAM c WHERE c.MaCa=@MaCa
    AND DATEADD(SECOND,DATEDIFF(SECOND,CAST('00:00' AS TIME),c.GioBatDau),CAST(c.NgayLam AS DATETIME2(0)))<=SYSDATETIME())
   THROW 53205,N'Ứng dụng không được thêm hồi tố phân công; dữ liệu lịch sử chỉ nhập qua quản trị.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.NHAN_VIEN WHERE MaNV=@MaNV AND TrangThaiLamViec='DangLam' AND TrangThaiHoSo='HoanTat'
     AND NgayVaoLam<=@ng AND (NgayNghiViec IS NULL OR @ng<NgayNghiViec))
   THROW 51012,N'Nhan vien khong hop le de xep lich.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN WHERE MaNV=@MaNV)
     OR NOT EXISTS(SELECT MaNV FROM dbo.PHUC_VU WHERE MaNV=@MaNV UNION ALL
       SELECT MaNV FROM dbo.THU_NGAN WHERE MaNV=@MaNV UNION ALL SELECT MaNV FROM dbo.QUAN_LY WHERE MaNV=@MaNV)
   THROW 51013,N'Ho so can it nhat mot lien he va mot vai tro.',1;
  IF @LoaiNgayApDung IS NULL OR @LoaiNgayApDung NOT IN('NgayThuong','NgayNghiTuan','NgayLe')
     OR (@loai='NgayLe' AND @LoaiNgayApDung<>'NgayLe') OR (@loai='NgayThuong' AND @LoaiNgayApDung='NgayLe')
   THROW 51014,N'Loai ngay khong khop lich ca.',1;
  IF EXISTS(SELECT 1 FROM dbo.BANG_LUONG WHERE TrangThaiBangLuong='DaChot' AND @ng>=TuNgay AND @ng<DenNgay)
   THROW 51015,N'Khong them lich vao ky da chot.',1;
  IF EXISTS(SELECT 1 FROM dbo.LAM_VIEC WHERE MaNV=@MaNV AND MaCa=@MaCa AND LoaiNgayApDung<>@LoaiNgayApDung)
   THROW 51016,N'Lich da ton tai voi loai ngay khac.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.LAM_VIEC WHERE MaNV=@MaNV AND MaCa=@MaCa)
   INSERT dbo.LAM_VIEC(MaNV,MaCa,LoaiNgayApDung) VALUES(@MaNV,@MaCa,@LoaiNgayApDung);
  IF @MaBan IS NOT NULL
  BEGIN
   IF NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU WHERE MaNV=@MaNV)
    THROW 51017,N'Phan cong ban can vai tro phuc vu.',1;
   IF NOT EXISTS(SELECT 1 FROM dbo.BAN WHERE MaBan=@MaBan AND TrangThaiHoatDong='HoatDong')
    THROW 51018,N'Ban khong ton tai hoac tam ngung.',1;
   IF NOT EXISTS(SELECT 1 FROM dbo.PHAN_CONG WHERE MaNV=@MaNV AND MaCa=@MaCa AND MaBan=@MaBan)
   BEGIN
    IF EXISTS(SELECT 1 FROM dbo.PHUC_VU p WHERE p.MaNV=@MaNV AND p.SoBanPhuTrachToiDa IS NOT NULL
       AND (SELECT COUNT(*) FROM dbo.PHAN_CONG WHERE MaNV=@MaNV AND MaCa=@MaCa)>=p.SoBanPhuTrachToiDa)
     THROW 51019,N'Vuot so ban toi da cua nhan vien trong ca.',1;
    INSERT dbo.PHAN_CONG(MaNV,MaBan,MaCa) VALUES(@MaNV,@MaBan,@MaCa);
   END;
  END;
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_N3_ChamCong
 @ThaoTac VARCHAR(12), @MaNguoiThucHien VARCHAR(30), @MaNV VARCHAR(30), @MaCa VARCHAR(30),
 @TrangThaiCong VARCHAR(24)='DiLam', @HinhThuc VARCHAR(20)='ThuCong',
 @GioVaoThucTe DATETIME2(0)=NULL, @GioRaThucTe DATETIME2(0)=NULL,
 @OTTruocBatDau DATETIME2(0)=NULL, @OTTruocKetThuc DATETIME2(0)=NULL,
 @OTSauBatDau DATETIME2(0)=NULL, @OTSauKetThuc DATETIME2(0)=NULL,
 @PhutCongDuyet INT=NULL, @CanCuDuyetCong NVARCHAR(1000)=NULL,
 @GhiChu NVARCHAR(1000)=NULL, @LyDoSua NVARCHAR(1000)=NULL, @ChoPhepNgoaiLe BIT=0
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51000,N'Goi thu tuc ngoai giao dich dang mo.',1;
 IF @ThaoTac IS NULL OR @ThaoTac NOT IN('GhiNhan','Sua','Duyet') THROW 51100,N'Thao tac cham cong khong hop le.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @lk INT,@ng DATE,@bd DATETIME2(0),@kt DATETIME2(0),@loai VARCHAR(20),@ton BIT=0;
  EXEC @lk=sys.sp_getapplock @Resource=N'N3_NhanSu',@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;
  IF @lk<0 THROW 51001,N'Khong lay duoc khoa nhan su.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q JOIN dbo.NHAN_VIEN n ON n.MaNV=q.MaNV
      WHERE q.MaNV=@MaNguoiThucHien AND q.DuocDuyetChamCong=1 AND n.TrangThaiLamViec='DangLam' AND n.TrangThaiHoSo='HoanTat')
   THROW 51101,N'Can quan ly dang lam co quyen duyet cham cong.',1;
  SELECT @ng=ca.NgayLam,@loai=lv.LoaiNgayApDung,
    @bd=DATEADD(SECOND,DATEDIFF(SECOND,CONVERT(TIME(0),'00:00'),ca.GioBatDau),CONVERT(DATETIME2(0),ca.NgayLam)),
    @kt=DATEADD(SECOND,DATEDIFF(SECOND,CONVERT(TIME(0),'00:00'),ca.GioKetThuc),CONVERT(DATETIME2(0),ca.NgayLam))
  FROM dbo.LAM_VIEC lv WITH(UPDLOCK,HOLDLOCK) JOIN dbo.CA_LAM ca ON ca.MaCa=lv.MaCa
  WHERE lv.MaNV=@MaNV AND lv.MaCa=@MaCa;
  IF @ng IS NULL THROW 51102,N'Chua co lich lam viec cho cap nhan vien-ca.',1;
  IF EXISTS(SELECT 1 FROM dbo.BANG_LUONG WHERE TrangThaiBangLuong='DaChot' AND @ng>=TuNgay AND @ng<DenNgay)
   THROW 51103,N'Khong sua hoac them cong thuoc ky luong da chot.',1;
  IF EXISTS(SELECT 1 FROM dbo.CHAM_CONG WHERE MaNV=@MaNV AND MaCa=@MaCa) SET @ton=1;
  IF @ThaoTac='GhiNhan' AND @ton=1 THROW 51104,N'Cong da ton tai; dung Sua va neu ly do.',1;
  IF @ThaoTac IN('Sua','Duyet') AND @ton=0 THROW 51105,N'Chua co ban ghi cham cong.',1;
  IF @ThaoTac='Sua' AND NULLIF(LTRIM(RTRIM(@LyDoSua)),N'') IS NULL THROW 51106,N'Sua cong phai co ly do.',1;
  IF @ThaoTac='Duyet'
  BEGIN
   IF EXISTS(SELECT 1 FROM dbo.CHAM_CONG WHERE MaNV=@MaNV AND MaCa=@MaCa AND TrangThaiDuyet='DaDuyet')
    THROW 51107,N'Cong da duyet; muon dieu chinh phai dung Sua.',1;
   SELECT @TrangThaiCong=TrangThaiCong,@HinhThuc=HinhThuc,@GioVaoThucTe=GioVaoThucTe,@GioRaThucTe=GioRaThucTe,
      @OTTruocBatDau=OTTruocBatDau,@OTTruocKetThuc=OTTruocKetThuc,@OTSauBatDau=OTSauBatDau,@OTSauKetThuc=OTSauKetThuc,
      @GhiChu=GhiChu FROM dbo.CHAM_CONG WHERE MaNV=@MaNV AND MaCa=@MaCa;
   IF SYSDATETIME()<@kt THROW 51108,N'Chi duyet cong sau khi ket thuc ca.',1;
   IF NULLIF(LTRIM(RTRIM(@CanCuDuyetCong)),N'') IS NULL THROW 51109,N'Duyet cong phai co can cu.',1;
  END;
  IF @TrangThaiCong IS NULL OR @TrangThaiCong NOT IN('DiLam','NghiPhepHuongLuong','NghiPhepKhongLuong','NghiKhongPhep')
   THROW 51110,N'Trang thai cong khong hop le.',1;
  IF @HinhThuc IS NULL OR @HinhThuc NOT IN('ThuCong','ChamCongDienTu') THROW 51111,N'Hinh thuc khong hop le.',1;
  IF EXISTS(SELECT 1 FROM (VALUES(@GioVaoThucTe),(@GioRaThucTe),(@OTTruocBatDau),(@OTTruocKetThuc),(@OTSauBatDau),(@OTSauKetThuc)) v(t)
    WHERE DATEPART(SECOND,v.t)<>0)
   THROW 51120,N'Ghi nhan thoi gian theo phut; giay phai bang 0.',1;
  IF (@GioVaoThucTe IS NOT NULL AND CONVERT(DATE,@GioVaoThucTe)<>@ng)
     OR (@GioRaThucTe IS NOT NULL AND CONVERT(DATE,@GioRaThucTe)<>@ng)
     OR (@GioVaoThucTe IS NOT NULL AND @GioRaThucTe IS NOT NULL AND @GioVaoThucTe>=@GioRaThucTe)
     OR (@GioVaoThucTe IS NULL AND @GioRaThucTe IS NOT NULL)
   THROW 51112,N'Gio vao/ra phai dung thu tu va cung ngay ca.',1;
  IF (@OTTruocBatDau IS NULL AND @OTTruocKetThuc IS NOT NULL) OR (@OTTruocBatDau IS NOT NULL AND @OTTruocKetThuc IS NULL)
     OR (@OTSauBatDau IS NULL AND @OTSauKetThuc IS NOT NULL) OR (@OTSauBatDau IS NOT NULL AND @OTSauKetThuc IS NULL)
   THROW 51113,N'Moi khoang OT can du hai moc hoac ca hai NULL.',1;
  IF @TrangThaiCong<>'DiLam' AND (@GioVaoThucTe IS NOT NULL OR @GioRaThucTe IS NOT NULL
     OR @OTTruocBatDau IS NOT NULL OR @OTSauBatDau IS NOT NULL)
   THROW 51114,N'Nghi ca khong co gio vao/ra hay OT.',1;
  IF (@OTTruocBatDau IS NOT NULL AND (@GioVaoThucTe IS NULL OR @GioRaThucTe IS NULL
       OR CONVERT(DATE,@OTTruocBatDau)<>@ng OR @OTTruocBatDau<@GioVaoThucTe
       OR @OTTruocBatDau>=@OTTruocKetThuc OR @OTTruocKetThuc>@bd OR @OTTruocKetThuc>@GioRaThucTe))
     OR (@OTSauBatDau IS NOT NULL AND (@GioVaoThucTe IS NULL OR @GioRaThucTe IS NULL
       OR @OTSauBatDau<@kt OR @OTSauBatDau<@GioVaoThucTe OR @OTSauBatDau>=@OTSauKetThuc
       OR @OTSauKetThuc>@GioRaThucTe OR CONVERT(DATE,@OTSauKetThuc)<>@ng))
   THROW 51115,N'OT phai ngoai ca, trong gio lam thuc te va cung ngay.',1;
  DECLARE @ot INT=ISNULL(DATEDIFF(MINUTE,@OTTruocBatDau,@OTTruocKetThuc),0)+ISNULL(DATEDIFF(MINUTE,@OTSauBatDau,@OTSauKetThuc),0),
     @pc INT=NULL,@giao INT=0;
  IF @ThaoTac='Duyet'
  BEGIN
   IF @TrangThaiCong='DiLam' AND (@GioVaoThucTe IS NULL OR @GioRaThucTe IS NULL OR @GioRaThucTe>SYSDATETIME())
    THROW 51116,N'Duyet di lam can du gio vao/ra trong qua khu.',1;
   SET @giao=CASE WHEN @GioRaThucTe<=@bd OR @GioVaoThucTe>=@kt THEN 0 ELSE
     DATEDIFF(MINUTE,CASE WHEN @GioVaoThucTe>@bd THEN @GioVaoThucTe ELSE @bd END,
     CASE WHEN @GioRaThucTe<@kt THEN @GioRaThucTe ELSE @kt END) END;
   SET @pc=CASE WHEN @TrangThaiCong='DiLam' THEN @PhutCongDuyet ELSE 0 END;
   IF @pc IS NULL OR @pc<0 OR @pc>DATEDIFF(MINUTE,@bd,@kt)
      OR (@TrangThaiCong='DiLam' AND @pc>@giao AND ISNULL(@ChoPhepNgoaiLe,0)=0)
    THROW 51117,N'Phut duyet vuot giao thuc te/ca chuan; ngoai le can duyet ro rang va can cu.',1;
   -- Khong cho OT giao ca chuan khac da xep cua chinh nhan vien.
   IF EXISTS(SELECT 1 FROM dbo.LAM_VIEC lv JOIN dbo.CA_LAM ca ON ca.MaCa=lv.MaCa
     CROSS APPLY(SELECT DATEADD(SECOND,DATEDIFF(SECOND,CONVERT(TIME(0),'00:00'),ca.GioBatDau),CONVERT(DATETIME2(0),ca.NgayLam)) b,
       DATEADD(SECOND,DATEDIFF(SECOND,CONVERT(TIME(0),'00:00'),ca.GioKetThuc),CONVERT(DATETIME2(0),ca.NgayLam)) e) t
     WHERE lv.MaNV=@MaNV AND lv.MaCa<>@MaCa AND ca.NgayLam=@ng
     AND ((@OTTruocBatDau<t.e AND t.b<@OTTruocKetThuc) OR (@OTSauBatDau<t.e AND t.b<@OTSauKetThuc)))
    THROW 51118,N'OT trung ca chuan khac cua nhan vien.',1;
   IF EXISTS(SELECT 1 FROM dbo.CHAM_CONG c JOIN dbo.CA_LAM ca ON ca.MaCa=c.MaCa
     CROSS APPLY(VALUES(c.OTTruocBatDau,c.OTTruocKetThuc),(c.OTSauBatDau,c.OTSauKetThuc)) oldot(b,e)
     CROSS APPLY(VALUES(@OTTruocBatDau,@OTTruocKetThuc),(@OTSauBatDau,@OTSauKetThuc)) newot(b,e)
     WHERE c.MaNV=@MaNV AND c.MaCa<>@MaCa AND ca.NgayLam=@ng AND c.TrangThaiDuyet='DaDuyet'
     AND oldot.b<newot.e AND newot.b<oldot.e)
    THROW 51119,N'OT trung khoang OT da duyet khac.',1;
  END;
  DECLARE @before TABLE(TrangThaiCong VARCHAR(24),TrangThaiDuyet VARCHAR(20),HinhThuc VARCHAR(20),
   GioVaoThucTe DATETIME2(0),GioRaThucTe DATETIME2(0),OTTruocBatDau DATETIME2(0),OTTruocKetThuc DATETIME2(0),
   OTSauBatDau DATETIME2(0),OTSauKetThuc DATETIME2(0),PhutCongDuyet INT,PhutTangCaDuyet INT,LoaiNgayTangCa VARCHAR(20),
   CanCuDuyetCong NVARCHAR(1000),GhiChu NVARCHAR(1000),MaNVDuyet VARCHAR(30),ThoiDiemDuyet DATETIME2(0),LaNgoaiLeCong BIT);
  INSERT @before SELECT TrangThaiCong,TrangThaiDuyet,HinhThuc,GioVaoThucTe,GioRaThucTe,OTTruocBatDau,OTTruocKetThuc,
    OTSauBatDau,OTSauKetThuc,PhutCongDuyet,PhutTangCaDuyet,LoaiNgayTangCa,CanCuDuyetCong,GhiChu,MaNVDuyet,ThoiDiemDuyet,LaNgoaiLeCong
    FROM dbo.CHAM_CONG WHERE MaNV=@MaNV AND MaCa=@MaCa;
  IF @ThaoTac='GhiNhan'
   INSERT dbo.CHAM_CONG(MaNV,MaCa,TrangThaiCong,TrangThaiDuyet,HinhThuc,GioVaoThucTe,GioRaThucTe,
     OTTruocBatDau,OTTruocKetThuc,OTSauBatDau,OTSauKetThuc,PhutTangCaDuyet,GhiChu)
   VALUES(@MaNV,@MaCa,@TrangThaiCong,'ChoDuyet',@HinhThuc,@GioVaoThucTe,@GioRaThucTe,
     @OTTruocBatDau,@OTTruocKetThuc,@OTSauBatDau,@OTSauKetThuc,0,@GhiChu);
  ELSE
   UPDATE dbo.CHAM_CONG SET TrangThaiCong=@TrangThaiCong,HinhThuc=@HinhThuc,GioVaoThucTe=@GioVaoThucTe,GioRaThucTe=@GioRaThucTe,
     OTTruocBatDau=@OTTruocBatDau,OTTruocKetThuc=@OTTruocKetThuc,OTSauBatDau=@OTSauBatDau,OTSauKetThuc=@OTSauKetThuc,
     TrangThaiDuyet=CASE WHEN @ThaoTac='Duyet' THEN 'DaDuyet' ELSE 'ChoDuyet' END,
     PhutCongDuyet=@pc,PhutTangCaDuyet=CASE WHEN @ThaoTac='Duyet' THEN @ot ELSE 0 END,
     LaNgoaiLeCong=CASE WHEN @ThaoTac='Duyet' AND @TrangThaiCong='DiLam' AND @pc>@giao AND @ChoPhepNgoaiLe=1 THEN 1 ELSE 0 END,
     LoaiNgayTangCa=CASE WHEN @ThaoTac='Duyet' AND @ot>0 THEN @loai END,
     MaNVDuyet=CASE WHEN @ThaoTac='Duyet' THEN @MaNguoiThucHien END,
     ThoiDiemDuyet=CASE WHEN @ThaoTac='Duyet' THEN SYSDATETIME() END,
     CanCuDuyetCong=CASE WHEN @ThaoTac='Duyet' THEN @CanCuDuyetCong END,GhiChu=@GhiChu
   WHERE MaNV=@MaNV AND MaCa=@MaCa;
  -- Moi truong thay doi co mot dong log; cap nhat va log cung giao dich.
  IF @ton=1
  BEGIN
   DECLARE @stt INT=(SELECT ISNULL(MAX(STTSua),0) FROM dbo.LICH_SU_SUA_CHAM_CONG WITH(UPDLOCK,HOLDLOCK) WHERE MaNV=@MaNV AND MaCa=@MaCa);
   INSERT dbo.LICH_SU_SUA_CHAM_CONG(MaNV,MaCa,STTSua,TruongThayDoi,GiaTriTruoc,GiaTriSau,ThoiDiemSua,LyDoSua,MaNVSua)
   SELECT @MaNV,@MaCa,@stt+CONVERT(INT,ROW_NUMBER() OVER(ORDER BY v.Ten)),v.Ten,v.Cu,v.Moi,SYSDATETIME(),
     CASE WHEN @ThaoTac='Duyet' THEN @CanCuDuyetCong ELSE @LyDoSua END,@MaNguoiThucHien
   FROM @before b CROSS JOIN dbo.CHAM_CONG c
   CROSS APPLY(VALUES
    (N'TrangThaiCong',CONVERT(NVARCHAR(1000),b.TrangThaiCong),CONVERT(NVARCHAR(1000),c.TrangThaiCong)),
    (N'TrangThaiDuyet',CONVERT(NVARCHAR(1000),b.TrangThaiDuyet),CONVERT(NVARCHAR(1000),c.TrangThaiDuyet)),
    (N'HinhThuc',CONVERT(NVARCHAR(1000),b.HinhThuc),CONVERT(NVARCHAR(1000),c.HinhThuc)),
    (N'GioVaoThucTe',CONVERT(NVARCHAR(1000),b.GioVaoThucTe,126),CONVERT(NVARCHAR(1000),c.GioVaoThucTe,126)),
    (N'GioRaThucTe',CONVERT(NVARCHAR(1000),b.GioRaThucTe,126),CONVERT(NVARCHAR(1000),c.GioRaThucTe,126)),
    (N'OTTruocBatDau',CONVERT(NVARCHAR(1000),b.OTTruocBatDau,126),CONVERT(NVARCHAR(1000),c.OTTruocBatDau,126)),
    (N'OTTruocKetThuc',CONVERT(NVARCHAR(1000),b.OTTruocKetThuc,126),CONVERT(NVARCHAR(1000),c.OTTruocKetThuc,126)),
    (N'OTSauBatDau',CONVERT(NVARCHAR(1000),b.OTSauBatDau,126),CONVERT(NVARCHAR(1000),c.OTSauBatDau,126)),
    (N'OTSauKetThuc',CONVERT(NVARCHAR(1000),b.OTSauKetThuc,126),CONVERT(NVARCHAR(1000),c.OTSauKetThuc,126)),
    (N'PhutCongDuyet',CONVERT(NVARCHAR(1000),b.PhutCongDuyet),CONVERT(NVARCHAR(1000),c.PhutCongDuyet)),
    (N'PhutTangCaDuyet',CONVERT(NVARCHAR(1000),b.PhutTangCaDuyet),CONVERT(NVARCHAR(1000),c.PhutTangCaDuyet)),
    (N'LoaiNgayTangCa',CONVERT(NVARCHAR(1000),b.LoaiNgayTangCa),CONVERT(NVARCHAR(1000),c.LoaiNgayTangCa)),
    (N'CanCuDuyetCong',b.CanCuDuyetCong,c.CanCuDuyetCong),(N'GhiChu',b.GhiChu,c.GhiChu),
    (N'LaNgoaiLeCong',CONVERT(NVARCHAR(1000),b.LaNgoaiLeCong),CONVERT(NVARCHAR(1000),c.LaNgoaiLeCong)),
    (N'MaNVDuyet',CONVERT(NVARCHAR(1000),b.MaNVDuyet),CONVERT(NVARCHAR(1000),c.MaNVDuyet)),
    (N'ThoiDiemDuyet',CONVERT(NVARCHAR(1000),b.ThoiDiemDuyet,126),CONVERT(NVARCHAR(1000),c.ThoiDiemDuyet,126))
   ) v(Ten,Cu,Moi)
   WHERE c.MaNV=@MaNV AND c.MaCa=@MaCa AND (v.Cu<>v.Moi OR (v.Cu IS NULL AND v.Moi IS NOT NULL) OR (v.Cu IS NOT NULL AND v.Moi IS NULL));
  END;
  -- Sua cong lam mat ket qua luong nhap; phai Lap lai truoc Chot.
  IF @ThaoTac='Sua'
   DELETE ct FROM dbo.CHI_TIET_LUONG_CA ct JOIN dbo.BANG_LUONG bl ON bl.MaBangLuong=ct.MaBangLuong
    WHERE ct.MaNV=@MaNV AND ct.MaCa=@MaCa AND bl.TrangThaiBangLuong='Nhap';
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_N3_BangLuong
 @ThaoTac VARCHAR(12),@MaNguoiThucHien VARCHAR(30),@MaBangLuong VARCHAR(30),
 @TenKy NVARCHAR(150)=NULL,@TuNgay DATE=NULL,@DenNgay DATE=NULL,
 @MaNV VARCHAR(30)=NULL,@PhuongThucChiTra VARCHAR(20)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51000,N'Goi thu tuc ngoai giao dich dang mo.',1;
 IF @ThaoTac IS NULL OR @ThaoTac NOT IN('Lap','Chot','ChiTra') THROW 51200,N'Thao tac bang luong khong hop le.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @lk INT,@tt VARCHAR(20),@tu DATE,@den DATE;
  EXEC @lk=sys.sp_getapplock @Resource=N'N3_NhanSu',@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;
  IF @lk<0 THROW 51001,N'Khong lay duoc khoa nhan su.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q JOIN dbo.NHAN_VIEN n ON n.MaNV=q.MaNV
      WHERE q.MaNV=@MaNguoiThucHien AND q.DuocChotBangLuong=1 AND n.TrangThaiLamViec='DangLam' AND n.TrangThaiHoSo='HoanTat')
   THROW 51201,N'Can quan ly dang lam co quyen chot bang luong.',1;
  SELECT @tt=TrangThaiBangLuong,@tu=TuNgay,@den=DenNgay FROM dbo.BANG_LUONG WITH(UPDLOCK,HOLDLOCK) WHERE MaBangLuong=@MaBangLuong;
  IF @ThaoTac='Lap'
  BEGIN
   IF @tt='DaChot' THROW 51202,N'Khong lap lai ky da chot.',1;
   IF @tt IS NULL
   BEGIN
    IF @TuNgay IS NULL OR @DenNgay IS NULL OR @TuNgay>=@DenNgay OR NULLIF(LTRIM(RTRIM(@TenKy)),N'') IS NULL
     THROW 51203,N'Thieu ten ky hoac khoang ngay khong hop le.',1;
    IF EXISTS(SELECT 1 FROM dbo.BANG_LUONG WITH(UPDLOCK,HOLDLOCK) WHERE TuNgay<@DenNgay AND @TuNgay<DenNgay)
     THROW 51204,N'Ky luong chong voi ky da ton tai.',1;
    INSERT dbo.BANG_LUONG(MaBangLuong,TenKy,TuNgay,DenNgay,TrangThaiBangLuong)
     VALUES(@MaBangLuong,@TenKy,@TuNgay,@DenNgay,'Nhap');
    SET @tu=@TuNgay; SET @den=@DenNgay;
   END
   ELSE IF (@TuNgay IS NOT NULL AND @TuNgay<>@tu) OR (@DenNgay IS NOT NULL AND @DenNgay<>@den)
    THROW 51205,N'Khong doi khoang ngay cua ky da lap.',1;
   IF EXISTS(SELECT 1 FROM dbo.CHAM_CONG cc JOIN dbo.CA_LAM ca ON ca.MaCa=cc.MaCa
      WHERE ca.NgayLam>=@tu AND ca.NgayLam<@den AND cc.TrangThaiDuyet='DaDuyet'
      AND (SELECT COUNT(*) FROM dbo.MUC_LUONG_CA ml WHERE ml.MaNV=cc.MaNV AND ml.MaMauCa=ca.MaMauCa
          AND ca.NgayLam>=ml.TuNgay AND ca.NgayLam<ml.DenNgay)<>1)
    THROW 51206,N'Cong da duyet phai co dung mot muc luong hieu luc.',1;
   INSERT dbo.CHI_TIET_BANG_LUONG(MaBangLuong,MaNV,TrangThaiChiTra)
    SELECT DISTINCT @MaBangLuong,cc.MaNV,'ChuaTra' FROM dbo.CHAM_CONG cc JOIN dbo.CA_LAM ca ON ca.MaCa=cc.MaCa
    WHERE ca.NgayLam>=@tu AND ca.NgayLam<@den AND cc.TrangThaiDuyet='DaDuyet'
      AND NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG x WHERE x.MaBangLuong=@MaBangLuong AND x.MaNV=cc.MaNV);
   DELETE FROM dbo.CHI_TIET_LUONG_CA WHERE MaBangLuong=@MaBangLuong;
   INSERT dbo.CHI_TIET_LUONG_CA(MaBangLuong,MaNV,STTCa,MaCa,MaMucLuong,MucLuongCaApDung,PhutCaChuan,
     PhutCongTinhLuong,TyLeCongApDung,HeSoTangCaApDung,TienLuongCaSnapshot,TienTangCaSnapshot,
     PhutTangCaSnapshot,LoaiNgayTangCaSnapshot,GhiChuTinhLuong)
    SELECT @MaBangLuong,cc.MaNV,CONVERT(INT,ROW_NUMBER() OVER(PARTITION BY cc.MaNV ORDER BY ca.NgayLam,ca.GioBatDau,cc.MaCa)),
     cc.MaCa,f.MaMucLuong,f.MucLuongCaApDung,DATEDIFF(MINUTE,ca.GioBatDau,ca.GioKetThuc),
     CASE cc.TrangThaiCong WHEN 'DiLam' THEN cc.PhutCongDuyet WHEN 'NghiPhepHuongLuong' THEN DATEDIFF(MINUTE,ca.GioBatDau,ca.GioKetThuc) ELSE 0 END,
     f.TyLeCongApDung,f.HeSoTangCaApDung,f.TienLuongCa,f.TienTangCa,cc.PhutTangCaDuyet,
     CASE WHEN cc.PhutTangCaDuyet>0 THEN lv.LoaiNgayApDung END,N'Tinh tu cong da duyet va muc luong hieu luc tai NgayLam'
    FROM dbo.CHAM_CONG cc JOIN dbo.CA_LAM ca ON ca.MaCa=cc.MaCa JOIN dbo.LAM_VIEC lv ON lv.MaNV=cc.MaNV AND lv.MaCa=cc.MaCa
    CROSS APPLY dbo.fn_N3_TinhTienCong(cc.MaNV,cc.MaCa) f
    WHERE ca.NgayLam>=@tu AND ca.NgayLam<@den AND cc.TrangThaiDuyet='DaDuyet';
  END
  ELSE IF @ThaoTac='Chot'
  BEGIN
   IF @tt IS NULL OR @tt<>'Nhap' THROW 51207,N'Chi chot bang luong dang Nhap.',1;
   IF @den>CONVERT(DATE,SYSDATETIME()) THROW 51208,N'Chua ket thuc ky luong.',1;
   IF NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG WHERE MaBangLuong=@MaBangLuong)
    THROW 51209,N'Bang luong chua co phieu luong.',1;
   IF EXISTS(SELECT 1 FROM dbo.LAM_VIEC lv JOIN dbo.CA_LAM ca ON ca.MaCa=lv.MaCa
     LEFT JOIN dbo.CHAM_CONG cc ON cc.MaNV=lv.MaNV AND cc.MaCa=lv.MaCa
     LEFT JOIN dbo.CHI_TIET_LUONG_CA ct ON ct.MaNV=lv.MaNV AND ct.MaCa=lv.MaCa AND ct.MaBangLuong=@MaBangLuong
     WHERE ca.NgayLam>=@tu AND ca.NgayLam<@den AND (cc.TrangThaiDuyet IS NULL OR cc.TrangThaiDuyet<>'DaDuyet' OR ct.MaCa IS NULL))
    THROW 51210,N'Con lich chua duyet cong hoac chua lap lai luong.',1;
   IF EXISTS(SELECT 1 FROM dbo.CHI_TIET_LUONG_CA ct OUTER APPLY dbo.fn_N3_TinhTienCong(ct.MaNV,ct.MaCa) f
     WHERE ct.MaBangLuong=@MaBangLuong AND (f.MaNV IS NULL OR ct.MaMucLuong<>f.MaMucLuong
      OR ct.MucLuongCaApDung<>f.MucLuongCaApDung OR ct.PhutCongTinhLuong<>f.PhutCongTinhLuong
      OR ct.PhutCaChuan<>f.PhutCaChuan OR ct.TyLeCongApDung<>f.TyLeCongApDung
      OR ct.TienLuongCaSnapshot<>f.TienLuongCa OR ct.TienTangCaSnapshot<>f.TienTangCa
      OR ct.PhutTangCaSnapshot<>f.PhutTangCaDuyet OR ct.HeSoTangCaApDung<>f.HeSoTangCaApDung
      OR ISNULL(ct.LoaiNgayTangCaSnapshot,'')<>CASE WHEN f.PhutTangCaDuyet>0 THEN f.LoaiNgayApDung ELSE '' END))
    THROW 51211,N'Snapshot luong nhap khong con khop; hay Lap lai.',1;
   IF EXISTS(SELECT 1 FROM dbo.DIEU_CHINH_LUONG WHERE MaBangLuong=@MaBangLuong AND (MaNVDuyet IS NULL OR ThoiDiemDuyet IS NULL))
    THROW 51212,N'Con dieu chinh luong chua duyet.',1;
   IF EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG p
    OUTER APPLY(SELECT SUM(TienLuongCaSnapshot+TienTangCaSnapshot) Tien FROM dbo.CHI_TIET_LUONG_CA WHERE MaBangLuong=p.MaBangLuong AND MaNV=p.MaNV) l
    OUTER APPLY(SELECT SUM(CASE WHEN LoaiDieuChinh='GiamTru' THEN -SoTien ELSE SoTien END) Tien FROM dbo.DIEU_CHINH_LUONG WHERE MaBangLuong=p.MaBangLuong AND MaNV=p.MaNV) d
    WHERE p.MaBangLuong=@MaBangLuong AND ISNULL(l.Tien,0)+ISNULL(d.Tien,0)<0)
    THROW 51213,N'Luong thuc nhan khong duoc am.',1;
   UPDATE p SET SoTienChot=ISNULL(l.Tien,0)+ISNULL(d.Tien,0)
   FROM dbo.CHI_TIET_BANG_LUONG p
   OUTER APPLY(SELECT SUM(TienLuongCaSnapshot+TienTangCaSnapshot) Tien FROM dbo.CHI_TIET_LUONG_CA WHERE MaBangLuong=p.MaBangLuong AND MaNV=p.MaNV) l
   OUTER APPLY(SELECT SUM(CASE WHEN LoaiDieuChinh='GiamTru' THEN -SoTien ELSE SoTien END) Tien FROM dbo.DIEU_CHINH_LUONG WHERE MaBangLuong=p.MaBangLuong AND MaNV=p.MaNV) d
   WHERE p.MaBangLuong=@MaBangLuong;
   IF EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG WHERE MaBangLuong=@MaBangLuong AND (SoTienChot IS NULL OR SoTienChot<0))
    THROW 51213,N'Luong thuc nhan khong duoc am.',1;
   UPDATE dbo.BANG_LUONG SET TrangThaiBangLuong='DaChot',ThoiDiemChot=SYSDATETIME(),MaNVChot=@MaNguoiThucHien WHERE MaBangLuong=@MaBangLuong;
  END
  ELSE
  BEGIN
   IF @tt IS NULL OR @tt<>'DaChot' THROW 51214,N'Chi chi tra sau khi chot luong.',1;
   IF @PhuongThucChiTra IS NULL OR @PhuongThucChiTra NOT IN('TienMat','ChuyenKhoan') THROW 51215,N'Phuong thuc chi tra khong hop le.',1;
   IF NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_BANG_LUONG WHERE MaBangLuong=@MaBangLuong AND MaNV=@MaNV AND TrangThaiChiTra='ChuaTra')
    THROW 51216,N'Khong co phieu chua tra; khong duoc chi tra hai lan.',1;
   IF @PhuongThucChiTra='ChuyenKhoan' AND NOT EXISTS(SELECT 1 FROM dbo.NHAN_VIEN WHERE MaNV=@MaNV
     AND TenNganHang IS NOT NULL AND SoTaiKhoan IS NOT NULL AND ChuTaiKhoan IS NOT NULL)
    THROW 51217,N'Chuyen khoan can du thong tin tai khoan.',1;
   UPDATE dbo.CHI_TIET_BANG_LUONG SET TrangThaiChiTra='DaTra',SoTienChiTra=SoTienChot,
     ThoiDiemChiTra=SYSDATETIME(),PhuongThucChiTra=@PhuongThucChiTra WHERE MaBangLuong=@MaBangLuong AND MaNV=@MaNV;
  END;
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO


/* Ho so duoc tao va hoan tat trong cung mot giao dich.
   LienHe: [{"Loai":"SDT","GiaTri":"090..."}]
   VaiTro: [{"VaiTro":"PhucVu","SoBanPhuTrachToiDa":2},
            {"VaiTro":"QuanLy","DuocDuyetChamCong":1,"DuocChotBangLuong":1}]
   Khi sua, JSON la tap lien he/vai tro day du mong muon sau cap nhat.
   Du lieu moi duoc them truoc khi loai bo du lieu cu; khong bo qua trigger.
*/
GO
CREATE OR ALTER PROCEDURE dbo.usp_N3_HoSoNhanVien
 @MaNV VARCHAR(30),@HoTen NVARCHAR(150),@NgayVaoLam DATE,
 @LienHe NVARCHAR(MAX),@VaiTro NVARCHAR(MAX),
 @MaNguoiThucHien VARCHAR(30)=NULL,
 @TrangThaiLamViec VARCHAR(20)='DangLam',@NgayNghiViec DATE=NULL,
 @TenNganHang NVARCHAR(150)=NULL,@SoTaiKhoan VARCHAR(50)=NULL,@ChuTaiKhoan NVARCHAR(150)=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51000,N'Gọi thủ tục ngoài giao dịch đang mở.',1;
 IF ISJSON(@LienHe)<>1 OR @LienHe IS NULL OR LEFT(LTRIM(@LienHe),1)<>'['
    OR ISJSON(@VaiTro)<>1 OR @VaiTro IS NULL OR LEFT(LTRIM(@VaiTro),1)<>'['
  THROW 53210,N'Liên hệ và vai trò phải là mảng JSON hợp lệ.',1;
 DECLARE @lh TABLE(Loai VARCHAR(100),GiaTri NVARCHAR(1000));
 DECLARE @vt TABLE(VaiTro VARCHAR(100),SoBan INT,DuocHuyHD BIT,DuyetCong BIT,ChotLuong BIT,DuyetKho BIT,DuyetKPI BIT);
 INSERT @lh SELECT Loai,GiaTri FROM OPENJSON(@LienHe)
  WITH(Loai VARCHAR(100) '$.Loai',GiaTri NVARCHAR(1000) '$.GiaTri');
 INSERT @vt SELECT VaiTro,SoBan,DuocHuyHD,ISNULL(DuyetCong,1),ISNULL(ChotLuong,1),ISNULL(DuyetKho,0),ISNULL(DuyetKPI,0)
  FROM OPENJSON(@VaiTro) WITH(VaiTro VARCHAR(100) '$.VaiTro',SoBan INT '$.SoBanPhuTrachToiDa',
   DuocHuyHD BIT '$.DuocHuyHoaDon',DuyetCong BIT '$.DuocDuyetChamCong',ChotLuong BIT '$.DuocChotBangLuong',
   DuyetKho BIT '$.DuocDuyetKho',DuyetKPI BIT '$.DuocDuyetKPI');
 IF NOT EXISTS(SELECT 1 FROM @lh) OR NOT EXISTS(SELECT 1 FROM @vt)
  THROW 53211,N'Hồ sơ cần ít nhất một liên hệ và một vai trò.',1;
 IF EXISTS(SELECT 1 FROM @lh WHERE Loai IS NULL OR Loai NOT IN('SDT','Email') OR GiaTri IS NULL
     OR LEN(LTRIM(RTRIM(GiaTri)))=0 OR DATALENGTH(GiaTri)>510)
    OR EXISTS(SELECT 1 FROM @lh GROUP BY Loai,GiaTri HAVING COUNT(*)>1)
    OR EXISTS(SELECT 1 FROM @vt WHERE VaiTro IS NULL OR VaiTro NOT IN('PhucVu','ThuNgan','QuanLy') OR SoBan<=0)
    OR EXISTS(SELECT 1 FROM @vt GROUP BY VaiTro HAVING COUNT(*)>1)
  THROW 53212,N'Danh sách liên hệ hoặc vai trò không hợp lệ hay bị trùng.',1;
 BEGIN TRY
  BEGIN TRAN;
  DECLARE @lk INT;
  EXEC @lk=sys.sp_getapplock @Resource=N'N3_NhanSu',@LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=10000;
  IF @lk<0 THROW 51001,N'Không lấy được khóa nhân sự.',1;
  IF USER_NAME()<>N'dbo' AND ISNULL(IS_MEMBER(N'db_owner'),0)<>1 AND ISNULL(IS_SRVROLEMEMBER(N'sysadmin'),0)<>1
     AND NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY q JOIN dbo.NHAN_VIEN n ON n.MaNV=q.MaNV
       WHERE q.MaNV=@MaNguoiThucHien AND n.TrangThaiLamViec='DangLam' AND n.TrangThaiHoSo='HoanTat')
   THROW 53213,N'Chỉ quản lý đang làm hoặc quản trị viên được quản lý hồ sơ.',1;
  IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN WITH(UPDLOCK,HOLDLOCK) WHERE MaNV=@MaNV)
   UPDATE dbo.NHAN_VIEN SET HoTen=@HoTen,NgayVaoLam=@NgayVaoLam,TrangThaiLamViec=@TrangThaiLamViec,
    NgayNghiViec=@NgayNghiViec,TenNganHang=@TenNganHang,SoTaiKhoan=@SoTaiKhoan,ChuTaiKhoan=@ChuTaiKhoan WHERE MaNV=@MaNV;
  ELSE
   INSERT dbo.NHAN_VIEN(MaNV,HoTen,NgayVaoLam,TrangThaiLamViec,NgayNghiViec,TenNganHang,SoTaiKhoan,ChuTaiKhoan)
    VALUES(@MaNV,@HoTen,@NgayVaoLam,@TrangThaiLamViec,@NgayNghiViec,@TenNganHang,@SoTaiKhoan,@ChuTaiKhoan);
  INSERT dbo.LIEN_HE_NHAN_VIEN(MaNV,Loai,GiaTri)
   SELECT @MaNV,l.Loai,l.GiaTri FROM @lh l WHERE NOT EXISTS(SELECT 1 FROM dbo.LIEN_HE_NHAN_VIEN h
    WHERE h.MaNV=@MaNV AND h.Loai=l.Loai AND h.GiaTri=l.GiaTri);
  IF EXISTS(SELECT 1 FROM @vt WHERE VaiTro='PhucVu') AND NOT EXISTS(SELECT 1 FROM dbo.PHUC_VU WHERE MaNV=@MaNV)
   INSERT dbo.PHUC_VU(MaNV,SoBanPhuTrachToiDa) SELECT @MaNV,SoBan FROM @vt WHERE VaiTro='PhucVu';
  IF EXISTS(SELECT 1 FROM @vt WHERE VaiTro='ThuNgan') AND NOT EXISTS(SELECT 1 FROM dbo.THU_NGAN WHERE MaNV=@MaNV)
   INSERT dbo.THU_NGAN(MaNV,DuocHuyHoaDon) SELECT @MaNV,ISNULL(DuocHuyHD,0) FROM @vt WHERE VaiTro='ThuNgan';
  IF EXISTS(SELECT 1 FROM @vt WHERE VaiTro='QuanLy') AND NOT EXISTS(SELECT 1 FROM dbo.QUAN_LY WHERE MaNV=@MaNV)
   INSERT dbo.QUAN_LY(MaNV,DuocDuyetChamCong,DuocChotBangLuong,DuocDuyetKho,DuocDuyetKPI)
    SELECT @MaNV,DuyetCong,ChotLuong,DuyetKho,DuyetKPI FROM @vt WHERE VaiTro='QuanLy';
  UPDATE p SET SoBanPhuTrachToiDa=v.SoBan FROM dbo.PHUC_VU p JOIN @vt v ON v.VaiTro='PhucVu' WHERE p.MaNV=@MaNV;
  UPDATE t SET DuocHuyHoaDon=ISNULL(v.DuocHuyHD,0) FROM dbo.THU_NGAN t JOIN @vt v ON v.VaiTro='ThuNgan' WHERE t.MaNV=@MaNV;
  UPDATE q SET DuocDuyetChamCong=v.DuyetCong,DuocChotBangLuong=v.ChotLuong,DuocDuyetKho=v.DuyetKho,DuocDuyetKPI=v.DuyetKPI
   FROM dbo.QUAN_LY q JOIN @vt v ON v.VaiTro='QuanLy' WHERE q.MaNV=@MaNV;
  DELETE h FROM dbo.LIEN_HE_NHAN_VIEN h WHERE h.MaNV=@MaNV
   AND NOT EXISTS(SELECT 1 FROM @lh l WHERE l.Loai=h.Loai AND l.GiaTri=h.GiaTri);
  DELETE FROM dbo.PHUC_VU WHERE MaNV=@MaNV AND NOT EXISTS(SELECT 1 FROM @vt WHERE VaiTro='PhucVu');
  DELETE FROM dbo.THU_NGAN WHERE MaNV=@MaNV AND NOT EXISTS(SELECT 1 FROM @vt WHERE VaiTro='ThuNgan');
  DELETE FROM dbo.QUAN_LY WHERE MaNV=@MaNV AND NOT EXISTS(SELECT 1 FROM @vt WHERE VaiTro='QuanLy');
  -- Khoa ngoai se tu choi go bo vai tro da duoc giao dich lich su tham chieu.
  UPDATE dbo.NHAN_VIEN SET TrangThaiHoSo='HoanTat' WHERE MaNV=@MaNV;
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_N3_LienKetThuongKPI
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF OBJECT_ID(N'dbo.KET_QUA_KPI',N'U') IS NULL
  THROW 53220,N'Cần cài bảng KET_QUA_KPI chính thức trước khi liên kết thưởng.',1;
 IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_DCL_KPI' AND parent_object_id=OBJECT_ID(N'dbo.DIEU_CHINH_LUONG'))
  EXEC(N'ALTER TABLE dbo.DIEU_CHINH_LUONG WITH CHECK ADD CONSTRAINT FK_DCL_KPI
    FOREIGN KEY(MaKyKPI,MaNV) REFERENCES dbo.KET_QUA_KPI(MaKyKPI,MaNV);');
 EXEC(N'ALTER TABLE dbo.DIEU_CHINH_LUONG WITH CHECK CHECK CONSTRAINT FK_DCL_KPI;');
 IF NOT EXISTS(SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_DCL_KPI'
   AND parent_object_id=OBJECT_ID(N'dbo.DIEU_CHINH_LUONG') AND referenced_object_id=OBJECT_ID(N'dbo.KET_QUA_KPI')
   AND is_disabled=0 AND is_not_trusted=0)
  THROW 53221,N'Khóa ngoại thưởng KPI chưa được bật và kiểm tra đầy đủ.',1;
 IF (SELECT COUNT(*) FROM sys.foreign_key_columns c JOIN sys.foreign_keys f ON f.object_id=c.constraint_object_id
   WHERE f.name=N'FK_DCL_KPI' AND f.parent_object_id=OBJECT_ID(N'dbo.DIEU_CHINH_LUONG'))<>2
  OR (SELECT COUNT(*) FROM sys.foreign_key_columns c JOIN sys.foreign_keys f ON f.object_id=c.constraint_object_id
    JOIN sys.columns p ON p.object_id=c.parent_object_id AND p.column_id=c.parent_column_id
    JOIN sys.columns r ON r.object_id=c.referenced_object_id AND r.column_id=c.referenced_column_id
    WHERE f.name=N'FK_DCL_KPI' AND f.parent_object_id=OBJECT_ID(N'dbo.DIEU_CHINH_LUONG')
    AND ((p.name=N'MaKyKPI' AND r.name=N'MaKyKPI') OR (p.name=N'MaNV' AND r.name=N'MaNV')))<>2
  THROW 53221,N'Khóa ngoại KPI phải liên kết đúng cả mã kỳ và mã nhân viên.',1;
 SELECT name,is_disabled,is_not_trusted FROM sys.foreign_keys WHERE name=N'FK_DCL_KPI' AND parent_object_id=OBJECT_ID(N'dbo.DIEU_CHINH_LUONG');
END;
GO

CREATE OR ALTER VIEW dbo.vw_N3_BanPhanCong AS
 SELECT MaBan,TenBan,TrangThaiHoatDong FROM dbo.BAN;
GO
/* C. QUYEN SQL MAU: chi gan user ung dung da duoc xac thuc vao role nay.
   Khong tu tao login, khong luu mat khau. Vi du do DBA thuc hien:
   ALTER ROLE n3_nhansu_app ADD MEMBER [ten_user_ung_dung];
   MaNguoiThucHien la danh tinh NGHIEP VU do app da xac thuc truyen vao.
   Khong cho nguoi dung tuy y gia mao tham so MaNguoiThucHien tren UI.
   Ownership chaining dbo cho phep cac SP thao tac bang, user khong DML truc tiep.
   Tao/sua ho so, vai tro, ca, muc luong va dieu chinh do quan tri vien thuc hien
   trong giao dich; kiem tra vai tro+lien he truoc khi hoan tat ho so.
*/
IF DATABASE_PRINCIPAL_ID(N'n3_nhansu_app') IS NULL CREATE ROLE n3_nhansu_app AUTHORIZATION dbo;
GRANT EXECUTE ON OBJECT::dbo.usp_N3_HoSoNhanVien TO n3_nhansu_app;
GRANT EXECUTE ON OBJECT::dbo.usp_N3_PhanCongNhanVien TO n3_nhansu_app;
GRANT EXECUTE ON OBJECT::dbo.usp_N3_ChamCong TO n3_nhansu_app;
GRANT EXECUTE ON OBJECT::dbo.usp_N3_BangLuong TO n3_nhansu_app;
REVOKE SELECT ON SCHEMA::dbo FROM n3_nhansu_app;
-- Chi cap doc dung pham vi nhan su; khong DENY SELECT schema vi se chan role khac.
GRANT SELECT ON OBJECT::dbo.NHAN_VIEN TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.LIEN_HE_NHAN_VIEN TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.PHUC_VU TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.THU_NGAN TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.QUAN_LY TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.MAU_CA TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.CA_LAM TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.LAM_VIEC TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.PHAN_CONG TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.CHAM_CONG TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.LICH_SU_SUA_CHAM_CONG TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.MUC_LUONG_CA TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.BANG_LUONG TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.CHI_TIET_BANG_LUONG TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.CHI_TIET_LUONG_CA TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.DIEU_CHINH_LUONG TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.fn_N3_TinhTienCong TO n3_nhansu_app;
GRANT SELECT ON OBJECT::dbo.vw_N3_BanPhanCong TO n3_nhansu_app;
DENY INSERT,UPDATE,DELETE ON SCHEMA::dbo TO n3_nhansu_app;
GO

-- Co the cai KPI truoc hoac sau phan nhan su.
IF OBJECT_ID(N'dbo.KET_QUA_KPI',N'U') IS NOT NULL EXEC dbo.usp_N3_LienKetThuongKPI;
GO
