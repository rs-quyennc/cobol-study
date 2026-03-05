       IDENTIFICATION DIVISION.
       PROGRAM-ID. SEQFILE-READ-WRITE.
       AUTHOR. QUYENNC

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO INPUT-FILE-DD
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS FS-INPUT-FILE.
           SELECT OUTPUT-FILE ASSIGN TO OUTPUT-FILE-DD
           ORGANIZATION IS SEQUENTIAL
           FILE STATUS FS-OUTPUT-FILE.
       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-FILE.
       01  INPUT-FILE-REC.
           05  STORE-ID    PIC 9(05).
           05  FILLER      PIC X(01).
           05  ITEM-ID     PIC X(10).
           05  FILLER      PIC X(64).
       FD  OUTPUT-FILE.
         01  OUTPUT-FILE-REC.
              05  O-STORE-ID   PIC 9(05).
              05  DELIMIT      PIC X(01).
              05  O-ITEM-ID    PIC X(10).
              05  FILLER       PIC X(64).
       WORKING-STORAGE SECTION.
           01  FS-INPUT-FILE   PIC X(02)   VALUE SPACES.
               88  FS-INPUT-FILE-OK        VALUE '00'.
               88  FS-INPUT-FILE-EOF       VALUE '10'.
           01  FS-OUTPUT-FILE  PIC X(02)   VALUE SPACES.
               88  FS-OUTPUT-FILE-OK       VALUE '00'.
               88  FS-OUTPUT-FILE-EOF      VALUE '10'.
           01  COUNTERS.
               05  READ-COUNT  PIC 9(2).
               05  WRITE-COUNT PIC 9(2).
       PROCEDURE DIVISION.
      *> cobol-lint CL002 main-para
       MAIN-PARA.
           PERFORM OPEN-PARA THRU OPEN-EXIT-PARA.
           PERFORM PROCESS-PARA THRU PROCESS-EXIT-PARA.
           PERFORM CLOSE-PARA THRU CLOSE-EXIT-PARA.
           STOP RUN.
       OPEN-PARA.  
           INITIALIZE FS-INPUT-FILE FS-OUTPUT-FILE 
                       READ-COUNT WRITE-COUNT.
           OPEN INPUT INPUT-FILE
           IF FS-INPUT-FILE-OK
               CONTINUE
           ELSE
               DISPLAY 'FILE OPEN FAILED: ' FS-INPUT-FILE
               GO TO EXIT-PARA
           END-IF.
           OPEN OUTPUT OUTPUT-FILE
           IF FS-OUTPUT-FILE-OK
                CONTINUE
           ELSE
                DISPLAY 'OUTPUT FILE OPEN FAILED: ' FS-OUTPUT-FILE
                GO TO EXIT-PARA
           END-IF.
       PROCESS-PARA.
           PERFORM UNTIL FS-INPUT-FILE-EOF
               READ INPUT-FILE
               AT END
                   IF READ-COUNT < 1
                       DISPLAY 'NO RECORDS PRESENT'
                       GO TO EXIT-PARA
                   END-IF
               NOT AT END
                   PERFORM WRITE-PARA THRU WRITE-EXIT-PARA
               END-READ
           END-PERFORM.
       WRITE-PARA.
           ADD 1 TO READ-COUNT.
           IF STORE-ID > 12346
               MOVE "|" TO DELIMIT
               MOVE STORE-ID TO O-STORE-ID
               MOVE ITEM-ID TO O-ITEM-ID
               WRITE OUTPUT-FILE-REC
           END-IF.
       OPEN-EXIT-PARA.
           EXIT.
       PROCESS-EXIT-PARA.            
           EXIT.
       WRITE-EXIT-PARA.
           EXIT.
       CLOSE-PARA.
           CLOSE INPUT-FILE OUTPUT-FILE.
       CLOSE-EXIT-PARA.
           EXIT.
       EXIT-PARA.
           EXIT PROGRAM.          
       
               
