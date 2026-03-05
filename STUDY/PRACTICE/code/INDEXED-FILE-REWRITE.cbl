       IDENTIFICATION DIVISION.
       PROGRAM-ID. INDEXED-FILE-REWRITE.
       AUTHOR. QUYENNC

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT I-O-FL ASSIGN TO IOFLDD
           ORGANIZATION IS INDEXED
           ACCESS MODE IS RANDOM
           RECORD KEY IS EMP-ID
           FILE STATUS FS-I-O-FL.

       DATA DIVISION.
       FILE SECTION.
       FD  I-O-FL.
       01  I-O-FL-REC.
           05  EMP-ID      PIC X(05).
           05  FILLER      PIC X(01).
           05  EMP-NAME    PIC X(19).
           05  REM-BYTE    PIC X(55).
       WORKING-STORAGE SECTION.
       01  FS-I-O-FL PIC X(02) VALUE SPACES.
           88  FS-I-O-FL-OK        VALUE '00'.
           88  FS-I-O-FL-DUP-KEY   VALUE '02'.
           88  FS-I-O-FL-EOF       VALUE '10'.
       PROCEDURE DIVISION.
       *> cobol-lint CL002 main-para
       MAIN-PARA.
           PERFORM OPEN-PARA THRU OPEN-EXIT-PARA.
           PERFORM PROCESS-PARA THRU PROCESS-EXIT-PARA.
           PERFORM CLOSE-PARA THRU CLOSE-EXIT-PARA.
           STOP RUN.
       OPEN-PARA.
           INITIALIZE  FS-I-O-FL I-O-FL-REC.
           OPEN I-O    I-O-FL
           IF FS-I-O-FL-OK
               CONTINUE
           ELSE
               DISPLAY 'FILE OPEN FAILED: ' FS-I-O-FL
               GO TO EXIT-PARA
           END-IF.
       PROCESS-PARA.
           MOVE '08814' TO EMP-ID
           READ I-O-FL
               KEY IS EMP-ID
               INVALID KEY DISPLAY 'INVALID KEY'
               NOT INVALID KEY DISPLAY 'EMP-NAME' EMP-NAME
           END-READ
           MOVE 'ROGER FEDERER' TO EMP-NAME
           REWRITE I-O-FL-REC
           END-REWRITE.
           DISPLAY 'EMP-NAME AFTER UPDATING: ' EMP-NAME.
       OPEN-EXIT-PARA.
           EXIT.
       PROCESS-EXIT-PARA.            
           EXIT.
       CLOSE-PARA.
           CLOSE I-O-FL.
       CLOSE-EXIT-PARA.
           EXIT.
       EXIT-PARA.
           EXIT PROGRAM.  
       
