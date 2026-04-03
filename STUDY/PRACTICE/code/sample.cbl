```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. MEMMGMT.
ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    *> RELATIVE KEY WS-RRN: Dùng để xác định số thứ tự dòng trong Subfile.
    SELECT DSPFILE ASSIGN TO WORKSTATION-MEMDSPF-SI
        ORGANIZATION IS TRANSACTION
        ACCESS MODE IS DYNAMIC
        RELATIVE KEY IS WS-RRN
        FILE STATUS IS WS-DSP-STATUS.

DATA DIVISION.
FILE SECTION.
FD  DSPFILE.
01  DSP-REC            PIC X(1024).

WORKING-STORAGE SECTION.
    *> SQLCA: Vùng nhớ để SQL báo cáo kết quả (Ví dụ: SQLCODE = 0 là thành công).
    EXEC SQL INCLUDE SQLCA END-EXEC.

01  WS-DSP-STATUS      PIC XX.
01  WS-RRN             PIC 9(4) COMP VALUE 0.   *> Số dòng hiện tại của Subfile
01  WS-EOF             PIC X VALUE 'N'.         *> Cờ báo hiệu đã đọc hết Database
01  WS-EXIT-FLG        PIC X VALUE 'N'.         *> Cờ thoát chương trình
01  WS-SFL-MOD-FND     PIC X VALUE 'N'.         *> Cờ báo có dòng Subfile bị thay đổi
01  WS-LIST-MSG        PIC X(74) VALUE SPACES.  *> Dòng thông báo dưới màn hình

* Vùng chứa các đèn báo (Indicators) để điều khiển giao diện (ẩn/hiện/xóa).
01  DSP-IND-AREA.
    05 IN03            PIC 1 INDICATOR 03.  *> F3: Thoát
    05 IN05            PIC 1 INDICATOR 05.  *> F5: Làm mới
    05 IN61            PIC 1 INDICATOR 61.  *> Bật để Xóa Subfile
    05 IN62            PIC 1 INDICATOR 62.  *> Hiện chữ 'More...'
    05 IN63            PIC 1 INDICATOR 63.  *> Hiện nội dung Subfile
    05 IN64            PIC 1 INDICATOR 64.  *> Hiện tiêu đề Subfile

*> Lệnh này tự động lấy các trường đã vẽ ở DDS vào code COBOL.
COPY DDS-ALL-FORMATS OF MEMDSPF.

*> Biến tạm để hứng dữ liệu từ câu lệnh SELECT SQL.
01  WS-MEMBER-DB.
    05 DB-ID           PIC S9(9) BINARY.
    05 DB-NAME         PIC X(100).
    05 DB-EMAIL        PIC X(255).

PROCEDURE DIVISION.
MAIN-LOGIC.
    OPEN I-O DSPFILE.
    PERFORM LOAD-SUBFILE.      *> Bước 1: Đổ dữ liệu từ DB lên Subfile
    PERFORM UNTIL WS-EXIT-FLG = 'Y'
        PERFORM DISPLAY-SCREEN *> Bước 2: Hiện Subfile cho người dùng xem và chọn
    END-PERFORM.
    CLOSE DSPFILE.
    GOBACK.

LOAD-SUBFILE.
    *> Xóa sạch dữ liệu cũ trên Subfile trước khi nạp mới
    MOVE 0 TO WS-RRN.
    MOVE B'1' TO IN61. *> Bật đèn xóa
    WRITE DSP-REC FROM MEMSFLCTL-O FORMAT 'MEMSFLCTL' INDICATORS DSP-IND-AREA.
        *> MEMSFLCTL: cần trùng với tên đã khai báo ở SEU
        *> Hậu tố -O và -I sẽ được tự động thêm vào để phân biệt hướng của dữ liệu, từ đó sinh ra biến MEMSFLCTL-O thông qua lệnh COPY DDS-ALL-FORMATS OF MEMDSPF
    MOVE B'0' TO IN61. *> Tắt đèn xóa sau khi xong

    *> Khai báo SQL Cursor để duyệt danh sách Members
    *> Lúc này Cursor sẽ như là một kho hàng chứa dữ liệu members
    EXEC SQL
        DECLARE MEMCUR CURSOR FOR
        SELECT MEMBER_ID, NAME, EMAIL FROM MEMBERS
        ORDER BY MEMBER_ID ASC
    END-EXEC.

    EXEC SQL OPEN MEMCUR END-EXEC. *> Mở kho hàng

        PERFORM UNTIL WS-EOF = 'Y'
            *> Lưu từng Row dữ liệu từ kho vào biến tạm
            EXEC SQL
                FETCH MEMCUR INTO :DB-ID, :DB-NAME, :DB-EMAIL
                *> Biến của COBOL dùng để mapping data sẽ khai báo ở WS-MEMBER-DB, sau đó thêm tiền tố `:`
                *> Để hứng được dữ liệu thì kiểu dữ liệu trong COBOL phải tương thích
                *> Vd: DB-ID (INT) => :DB-ID (S9(9) BINARY)
                END-EXEC.


            IF SQLCODE = 100 *> Nếu đã duyệt hết dữ liệu
                MOVE 'Y' TO WS-EOF
            ELSE
                ADD 1 TO WS-RRN *> Tăng số dòng lên 1
                *> Copy từ biến tạm vào trường trên màn hình Subfile
                MOVE SPACE  TO SFLOPT   OF MEMSFL-O
                MOVE DB-ID  TO MEMID    OF MEMSFL-O
                MOVE DB-NAME TO MEMNAME  OF MEMSFL-O
                MOVE DB-EMAIL TO MEMMAIL OF MEMSFL-O
                WRITE SUBFILE DSP-REC FROM MEMSFL-O FORMAT 'MEMSFL' INDICATORS DSP-IND-AREA
                *> Ghi dòng này vào bộ nhớ Subfile trong bộ nhớ RAM
                *> Giống cơ chế Queue (FIFO), nhưng hãy nhớ ACCESS MODE là DYNAMIC nên nó linh hoạt hơn nhiều
            END-IF
        END-PERFORM.

    EXEC SQL CLOSE MEMCUR END-EXEC. *> Đóng kho hàng

        *> Nếu có dữ liệu thì bật đèn hiển thị (IN63, IN64)
        IF WS-RRN > 0
            MOVE B'1' TO IN63 MOVE B'1' TO IN64
        ELSE
            MOVE 'NO RESULTS FOUND' TO WS-LIST-MSG
        END-IF.

DISPLAY-SCREEN.
    *> Ghi Footer và Header lên màn hình trước
    MOVE WS-LIST-MSG TO MEMMSG OF MEMFT-O.
    WRITE DSP-REC FROM MEMFT-O FORMAT 'MEMFT'.

    *> Hiển thị và tạo sự tương tác trên màn hình
    WRITE DSP-REC FROM MEMSFLCTL-O FORMAT 'MEMSFLCTL' INDICATORS DSP-IND-AREA.
    *> Vẽ toàn bộ nội dung của Subfile Control (Tiêu đề, các dòng dữ liệu trong Subfile đã nạp trước đó) lên màn hình
    READ DSPFILE INTO MEMSFLCTL-I FORMAT 'MEMSFLCTL' INDICATORS DSP-IND-AREA.
    *> Bắt chương trình dừng lại, hiện màn hình tĩnh và đợi người dùng nhấn một phím bất kỳ (như Enter, F3, F5).

    EVALUATE TRUE
        WHEN IN03 = B'1' MOVE 'Y' TO WS-EXIT-FLG
        WHEN IN05 = B'1' PERFORM LOAD-SUBFILE       *> Reload subfile để lấy data mới nhất
        WHEN OTHER       PERFORM PROCESS-SUBFILE    *> Xử lý nếu người dùng gõ 2 hoặc 4
        END-EVALUATE.

PROCESS-SUBFILE.
    *> Chỉ đọc những dòng nào người dùng có nhập dữ liệu (Opt 2, 4...)
    READ SUBFILE DSPFILE NEXT MODIFIED INTO MEMSFL-I
        FORMAT 'MEMSFL' AT END MOVE 'Y' TO WS-SFL-MOD-FND
    END-READ.

    PERFORM UNTIL WS-SFL-MOD-FND = 'Y'
        EVALUATE SFLOPT OF MEMSFL-I
            WHEN '2' *> Nếu chọn sửa
                MOVE MEMID OF MEMSFL-I TO WS-EDIT-ID
                CALL 'EDITMEM' USING WS-EDIT-ID
                PERFORM LOAD-SUBFILE
            WHEN '4' *> Nếu chọn xóa
                MOVE MEMID OF MEMSFL-I TO WS-EDIT-ID
                CALL 'DELMEM' USING WS-EDIT-ID
                PERFORM LOAD-SUBFILE *> Đặt tạm là reload subfile, sẽ làm tính năng xóa sau
        END-EVALUATE
        *> Đọc tiếp dòng thay đổi tiếp theo (nếu người dùng gõ nhiều dòng cùng lúc)
        READ SUBFILE DSPFILE NEXT MODIFIED INTO MEMSFL-I
            FORMAT 'MEMSFL' AT END MOVE 'Y' TO WS-SFL-MOD-FND
            END-READ
    END-PERFORM.
```