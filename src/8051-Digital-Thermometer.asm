	ORG	00H
	JMP	MAIN
;********************�D�{��*************************
MAIN:	
	CALL	T
	MOV	20H,R0		;�s��W�@�����ū׭�	
LOOP1:	CALL	BCD
	CALL	ASCII
	CALL	LCD
	CLR	F0
LOOP2:	CALL	T
	CALL	TEST
	JB	F0,LOOP1
	JMP	LOOP2
;****************************************************
T:	MOV	P1,#FFH		;P1���^�ū׭Ȧs�bR0
	CLR	P3.0
	SETB	P3.0
	CALL	DELAY		;����AD�ഫ����
	MOV	A,P1
	MOV	R0,A
	RET
;---------delay time=5ms----------------------
DELAY:	
	MOV	R6,#10
DL1:	MOV	R7,#249
	DJNZ	R7,$
	DJNZ	R6,DL1
	RET
;----------------------------------------------
BCD:	MOV	A,R0		;R1�s��ūפ�BCD�X
	MOV	B,#200
	DIV	AB	
	MOV	A,#10
	XCH	A,B
	DIV	AB
	SWAP	A
	ADD	A,B
	MOV	R1,A
	RET
;--------------------------------------------------------
ASCII:				;�N�ū׭���ASC�X�����
	MOV	A,R0
	ADDC	A,#37H	
	JNB	CY,OPEN		;�W�L100�����">100"
	MOV	2CH,#30H
	MOV	2DH,#30H
	MOV	2EH,#31H
	MOV	2FH,#3EH
	RET
OPEN:	MOV	A,R0		;�B�z�̤p���
	JB	A.0,ASC4	;�O�_���_��,�O�h���'5'
	MOV	A,#30H		;�_�h���'0'
	JMP	CODE4
ASC4:	MOV	A,#35H		
CODE4:	MOV	2CH,A
;---------------------------------------------------------	
	MOV	A,R0		;�B�z�p���I	
	CJNE	A,#200,REAL3	;�O�_���̤j��200,�O�h���'0'
	MOV	A,#30H		
	JMP	CODE5
REAL3:	CJNE	A,#0,ASC5	;�O�_���̤p��,�O�h��ܪť�
	MOV	A,#20H		
	JMP	CODE5
ASC5:	MOV	A,#2EH		;���"."
CODE5:	MOV	2DH,A
;---------------------------------------------------------
	MOV	A,R0		;�B�z�Ӧ��
	CJNE	A,#200,REAL4	;�O�_���̤j��200,�O�h���1
	MOV	A,#31H
	JMP	CODE6
REAL4:	CJNE	A,#0,ASC6	;�O�_���̤p��0,�O�h��ܪť�
	MOV	A,#20H
	JMP	CODE6
ASC6:	MOV	A,R1		;���ASCII�X
	ANL	A,#0FH
	ORL	A,#30H
CODE6:	MOV	2EH,A
;=-------------------------------------------------------
	MOV	A,R0		;�B�z�Q���
	CJNE	A,#200,REAL5	;�O�_���̤j��200,�O�h�B�S
	MOV	A,#20H
	JMP	CODE7
REAL5:	CJNE	A,#0,ASC7
	MOV	A,#20H
	JMP	CODE7
ASC7:	MOV	A,R1		;���ASCII�X
	ANL	A,#F0H
	SWAP	A
	ORL	A,#30H
CODE7:	CJNE	A,#30H,CODE8
	MOV	A,#20H		;0-9.5�׮ɾB�S
CODE8:	MOV	2FH,A
	RET
;---------------------------------------------------------
LCD:	CALL    INIT
	MOV	A,#54H
	CALL	RS1	
	MOV	A,#3DH
	CALL	RS1
	MOV	A,2FH
	CALL	RS1
	MOV	A,2EH
	CALL	RS1
	MOV	A,2DH
	CALL	RS1
	MOV	A,2CH
	CALL	RS1
	MOV	A,#DFH
	CALL	RS1
	MOV	A,#43H
	CALL	RS1
	RET
;------------------------------------------------------
INIT:	CLR     P2.7
        CALL    LCDRES		;LCD���m
        MOV     A,#38H		;�\��]�w
        CALL    RS0
        MOV     A,#0CH		;��ܾ��]�w
        CALL    RS0
        MOV     A,#01H		;�M����ܾ�
        CALL    RS0
        MOV     A,#06H		;�Ҧ��]�w
        CALL    RS0
        MOV     A,#80H		;RAM��}�]�w
        CALL    RS0		
        RET
RS0:	CALL    CB		;LCD����g�J
        MOV     P0,A
        CLR     P2.5
        CLR     P2.6
        SETB    P2.7
        CLR     P2.7
        RET
RS1:	CALL    CB		;LCD��Ƽg�J
        MOV     P0,A
        SETB    P2.5
        CLR     P2.6
        SETB    P2.7
        CLR     P2.7
        RET
CB:	MOV     P0,#FFH		;LCD���L�X���ˬd
        CLR     P2.5
        SETB    P2.6
        SETB    P2.7
        MOV     C,P0.7
        CLR     P2.7
        JC      CB
        RET
LCDRES:	MOV     A,#30H		;LCD���m
        CALL    RS0
        MOV     R7,#41
RES1:	MOV     R6,#50
        DJNZ    R6,$
        DJNZ    R7,RES1
        MOV     A,#30H
        CALL    RS0
        MOV     R7,#50
        DJNZ    R7,$
        MOV     A,#30H
        CALL    RS0
        RET
;------------------------------------------------
TEST:	
	MOV	A,R0
	ADD	A,R2		;R2�֥[256����o�@�����ȩ�bR3
	MOV	R2,A
	JNC	NOINC
	INC	R3
NOINC:
	DJNZ	R4,TEST2	;R4���p��256��
	MOV	A,R2
	JNB	A.7,TEST0
	INC	R3
TEST0:	MOV	A,R3
	XRL	A,20H		;���լO�_���ū��ܤ�
	JZ	TEST1
	MOV	20H,R3
	MOV	R0,20H		;���ܤƫh�N20H���R0�����
	SETB	F0		;�Ұ���ܺX��
TEST1:	MOV	R2,#00H
	MOV	R3,#00H
TEST2:	RET
;-------------------------------------------------
	.END



