https://www.ibm.com/support/pages/ibm-rational-developer-i-download

#### 1.1. COMMIT (quản lý transaction)

Xác định có dùng transaction hay không:

- *NONE / *NC: không dùng transaction
- *CHG / *UR: lock dữ liệu khi update, nhưng vẫn thấy dữ liệu chưa commit
- \*CS: không thấy dữ liệu chưa commit
- *ALL / *RS: lock cả dữ liệu đọc
- \*RR: lock toàn bộ bảng

#### 1.2. NAMING (Quy tắc đặt tên)

- \*SYS: dùng kiểu system

  - LIBRARY/FILE (Library ≈ Schema, FILE ≈ Table trong SQL)

- \*SQL: dùng kiểu SQL chuẩn

  - SCHEMA.TABLE

#### 1.3. PROCESS (Cách xử lý câu lệnh)

- \*RUN: check + chạy luôn
- \*VLD: chỉ validate, không chạy
- \*SYN: chỉ check syntax

#### 1.4. LIBOPT (Phạm vi tìm library)

Xác định system tìm table ở đâu:

- \*LIBL: theo library list
- \*CURLIB: chỉ current library
- \*ALL: toàn bộ system
- \*ALLUSR: chỉ user library

#### 1.5. ALWCPYDTA (Cho phép copy data)

- \*YES: cho phép copy nếu cần
- \*OPTIMIZE: hệ thống tự quyết định (tối ưu performance)
- \*NO: không cho copy → có thể lỗi nếu query cần

#### 1.6. REFRESH (refresh dữ liệu SELECT)

- \*ALWAYS: luôn refresh
- \*FORWARD: chỉ refresh khi scroll lần đầu

#### 1.7. DATFMT (format ngày)

- \*ISO: yyyy-mm-dd
- \*USA: mm/dd/yyyy
- \*EUR: dd.mm.yyyy
- \*JIS: giống ISO (chuẩn Nhật)

#### 1.8. TIMFMT (format thời gian)

- \*HMS: hh:mm:ss
- \*USA: AM/PM
- *ISO, *EUR, \*JIS: dạng chuẩn quốc tế

#### 1.9. SRTSEQ (quy tắc sort)

- \*HEX: sort theo mã hex
- \*LANGIDUNQ: sort theo ngôn ngữ (unique weight)
- \*LANGIDSHR: sort shared weight

#### 1.10. Các tham số khác

- DECMPT: dấu thập phân (. hoặc ,)
- LANGID: ngôn ngữ
- PGMLNG: check syntax theo C / COBOL / RPG
- SQLSTRDLM: dấu string (' hoặc ")
