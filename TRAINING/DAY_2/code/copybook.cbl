       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOG-USER-DATA.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       
       01  WS-USER-RECORD.
           COPY "USERDATA.cpy".

       PROCEDURE DIVISION.
      *> cobol-lint CL002 main-procedure
       MAIN-PROCEDURE.
           MOVE 12345          TO USER-ID
           MOVE "GEMINI AI USER" TO USER-NAME
           MOVE "ADMIN"        TO USER-ROLE
           MOVE 1500.50        TO USER-BALANCE

           *> 2. Log dữ liệu ra màn hình (Console Log)
           DISPLAY "--- USER TRANSACTION LOG ---"
           DISPLAY "ID     : " USER-ID
           DISPLAY "NAME   : " USER-NAME
           DISPLAY "ROLE   : " USER-ROLE
           DISPLAY "BALANCE: " USER-BALANCE
           DISPLAY "----------------------------"

           STOP RUN.

