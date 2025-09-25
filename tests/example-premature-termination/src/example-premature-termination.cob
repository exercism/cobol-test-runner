       IDENTIFICATION DIVISION.
       PROGRAM-ID. example-premature-termination.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESULT PIC X(4) VALUE 'TRUE'.
       PROCEDURE DIVISION.
       DO-SOMETHING.
           STOP RUN.
