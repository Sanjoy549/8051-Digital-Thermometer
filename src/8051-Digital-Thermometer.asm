	ORG	00H
	JMP	MAIN
;********************主程式*************************
MAIN:	
	CALL	T
	MOV	20H,R0		;存放上一次的溫度值	
LOOP1:	CALL	BCD
	CALL	ASCII
	CALL	LCD
	CLR	F0
LOOP2:	CALL	T
	CALL	TEST
	JB	F0,LOOP1
	JMP	LOOP2
;****************************************************
T:	MOV	P1,#FFH		;P1取回溫度值存在R0
	CLR	P3.0
	SETB	P3.0
	CALL	DELAY		;等待AD轉換完成
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
BCD:	MOV	A,R0		;R1存放溫度之BCD碼
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
ASCII:				;將溫度值轉ASC碼做顯示
	MOV	A,R0
	ADDC	A,#37H	
	JNB	CY,OPEN		;超過100度顯示">100"
	MOV	2CH,#30H
	MOV	2DH,#30H
	MOV	2EH,#31H
	MOV	2FH,#3EH
	RET
OPEN:	MOV	A,R0		;處理最小位數
	JB	A.0,ASC4	;是否為奇數,是則顯示'5'
	MOV	A,#30H		;否則顯示'0'
	JMP	CODE4
ASC4:	MOV	A,#35H		
CODE4:	MOV	2CH,A
;---------------------------------------------------------	
	MOV	A,R0		;處理小數點	
	CJNE	A,#200,REAL3	;是否為最大值200,是則顯示'0'
	MOV	A,#30H		
	JMP	CODE5
REAL3:	CJNE	A,#0,ASC5	;是否為最小值,是則顯示空白
	MOV	A,#20H		
	JMP	CODE5
ASC5:	MOV	A,#2EH		;顯示"."
CODE5:	MOV	2DH,A
;---------------------------------------------------------
	MOV	A,R0		;處理個位數
	CJNE	A,#200,REAL4	;是否為最大值200,是則顯示1
	MOV	A,#31H
	JMP	CODE6
REAL4:	CJNE	A,#0,ASC6	;是否為最小值0,是則顯示空白
	MOV	A,#20H
	JMP	CODE6
ASC6:	MOV	A,R1		;顯示ASCII碼
	ANL	A,#0FH
	ORL	A,#30H
CODE6:	MOV	2EH,A
;=-------------------------------------------------------
	MOV	A,R0		;處理十位數
	CJNE	A,#200,REAL5	;是否為最大值200,是則遮沒
	MOV	A,#20H
	JMP	CODE7
REAL5:	CJNE	A,#0,ASC7
	MOV	A,#20H
	JMP	CODE7
ASC7:	MOV	A,R1		;顯示ASCII碼
	ANL	A,#F0H
	SWAP	A
	ORL	A,#30H
CODE7:	CJNE	A,#30H,CODE8
	MOV	A,#20H		;0-9.5度時遮沒
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
        CALL    LCDRES		;LCD重置
        MOV     A,#38H		;功能設定
        CALL    RS0
        MOV     A,#0CH		;顯示器設定
        CALL    RS0
        MOV     A,#01H		;清除顯示器
        CALL    RS0
        MOV     A,#06H		;模式設定
        CALL    RS0
        MOV     A,#80H		;RAM位址設定
        CALL    RS0		
        RET
RS0:	CALL    CB		;LCD控制寫入
        MOV     P0,A
        CLR     P2.5
        CLR     P2.6
        SETB    P2.7
        CLR     P2.7
        RET
RS1:	CALL    CB		;LCD資料寫入
        MOV     P0,A
        SETB    P2.5
        CLR     P2.6
        SETB    P2.7
        CLR     P2.7
        RET
CB:	MOV     P0,#FFH		;LCD忙碌旗號檢查
        CLR     P2.5
        SETB    P2.6
        SETB    P2.7
        MOV     C,P0.7
        CLR     P2.7
        JC      CB
        RET
LCDRES:	MOV     A,#30H		;LCD重置
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
	ADD	A,R2		;R2累加256次後得一平均值放在R3
	MOV	R2,A
	JNC	NOINC
	INC	R3
NOINC:
	DJNZ	R4,TEST2	;R4做計數256次
	MOV	A,R2
	JNB	A.7,TEST0
	INC	R3
TEST0:	MOV	A,R3
	XRL	A,20H		;測試是否有溫度變化
	JZ	TEST1
	MOV	20H,R3
	MOV	R0,20H		;有變化則將20H放到R0做顯示
	SETB	F0		;啟動顯示旗標
TEST1:	MOV	R2,#00H
	MOV	R3,#00H
TEST2:	RET
;-------------------------------------------------
	.END



