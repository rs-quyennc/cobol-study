       IDENTIFICATION DIVISION.
       PROGRAM-ID. INDEXED-FILE-READ.
       AUTHOR. QUYENNC

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO INPUT-FILE-DD
           ORGANIZATION IS INDEXED
           ACCESS MODE IS RANDOM
           RECORD KEY IS EMP-ID
           FILE STATUS FS-INPUT-FILE.

       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-FILE.
       01  INPUT-FILE-REC.
           05 EMP-ID       PIC X(5).
           05 FILLER       PIC X(1).
           05 EMP-NAME     PIC X(19).
           05 REM-BYTE     PIC X(55).
       WORKING-STORAGE SECTION.
       01  FS-INPUT-FILE   PIC X(02)   VALUE SPACES.
           88 FS-INPUT-FILE-OK         VALUE '00'.
           88 FS-INPUT-FILE-DUP-KEY    VALUE '02'.
           88 FS-INPUT-FILE-EOF        VALUE '10'.
       PROCEDURE DIVISION.
      *> cobol-lint CL002 main-para
       MAIN-PARA.
           PERFORM OPEN-PARA THRU OPEN-EXIT-PARA.
           PERFORM PROCESS-PARA THRU PROCESS-EXIT-PARA.
           PERFORM CLOSE-PARA THRU CLOSE-EXIT-PARA.
           STOP RUN.
       OPEN-PARA.
           INITIALIZE FS-INPUT-FILE INPUT-FILE-REC.
           OPEN INPUT INPUT-FILE
           IF FS-INPUT-FILE-OK
               CONTINUE
           ELSE
               DISPLAY 'INPUT FILE OPEN FAILED: ' FS-INPUT-FILE
               GO TO EXIT-PARA
           END-IF.
       PROCESS-PARA.
           MOVE '08792' TO EMP-ID
           READ INPUT-FILE
               KEY IS EMP-ID
               INVALID KEY DISPLAY 'INVALID KEY'
               NOT INVALID KEY DISPLAY 'EMP-NAME' EMP-NAME
           END-READ.
       OPEN-EXIT-PARA.
           EXIT.
       PROCESS-EXIT-PARA.            
           EXIT.
       CLOSE-PARA.
           CLOSE INPUT-FILE.
       CLOSE-EXIT-PARA.
           EXIT.
       EXIT-PARA.
           EXIT PROGRAM.    
      
