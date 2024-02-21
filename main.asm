;******************************************************************************
; Universidad del Valle de Guatemala
; Programación de Microcrontroladores
; Proyecto: Laboratorio Contador
; Archivo: 
; Hardware: ATMEGA328p
; Created: 
; Author : Moises Rosales
;******************************************************************************
; Encabezado: realizar un contador con incremento y decremento aplicando
;interrupciones 
;******************************************************************************
.include "M328PDEF.inc" ; para reconozer los nombres de los registros
.cseg ; indica que lo que viene después es el segmento de código
.org 0x00 ; establecemos la dirección en posición 0
JMP MAIN

.ORG 0x0008 ; VECTOR ISR : PCINT1
	JMP INTERRUPCIONES
.org 0x0020 ; VECTOR ISR : TIMER0_OVF
	JMP SALIDA_INTERRUPCIONES

MAIN:
	/*LDI ZH, HIGH(SEGMENTOS << 1)
	LDI ZL, LOW(SEGMENTOS << 1)
	LPM R18, Z*/
;******************************************************************************
; stack pointer
;******************************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16 
LDI R17, HIGH(RAMEND)
OUT SPH, R17
;******************************************************************************
; Configuración
;******************************************************************************
Setup:
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16 ;HABILITAMOS EL PRESCALER 

	LDI R16, 0b0000_0001
	STS CLKPR, R16 ; DEFINIMOS UNA FRECUENCIA DE 4MGHz



	LDI R16, 0b0000_0011 ; CONFIGURAMOS LOS PULLUPS en PORTC
	OUT PORTC, R16	; HABILITAMOS EL PULLUPS
	LDI R16, 0b0011_1100
	OUT DDRC, R16	;Puertos C (entradas y salidas)


	LDI R16, 0b0000_1111
	OUT DDRB, R16	;DEFINIMOS SALIDAS DEL PUERTO B
	LDI R16, 0b1111_1111
	OUT DDRD, R16	;DEFINIMOS SALIDAS DEL PUERTO D
	
	LDI R16, (1 << PCIE1)
	STS PCICR, R16 ;CONFIGURAMOS COMO INTURRUPCIÓN EN EL PUERTO C

	LDI R16, (1 << PCINT8) | (1 << PCINT9)
	STS PCMSK1, R16 ;SELECCIONAMOS QUE PINES QUEREMOS COMO INTERRUPTORES

	CLR R16
	LDI R16, (1 << TOIE0)
	STS TIMSK0, R16 ;HABILITAMOS LA INTERRUPCIONES 

	CLR R16
	OUT TCCR0A, R16 

	CLR R16
	LDI R16, (1 << CS02)
	OUT TCCR0B, R16 ; PRESCALER PARA NUESTRA 5ms HAGA LA INTERRUPCION

	LDI R16, 178 ; INICIA A CONTAR
	OUT TCNT0, R16


	SEI ;INDICAMOS QUE VAMOS A HABILITAR LAS INTERRUPCIONES GLOBALES 
	
	
	

	LDI ZH, HIGH(SEGMENTOS << 1)
	LDI ZL, LOW(SEGMENTOS << 1)
	MOV R22, ZL
	MOV R21, ZL ;VALORES QUE NOS AYUDARAN A MODIFICAR LOS DISPLAYS INDIVIDUALES
	LPM R19, Z
	;CONFIGURACIÓN DEL DISPLAY
	SBRS R19, 0
	CBI	PORTC, PC4
	SBRC R19, 0
	SBI PORTC, PC4
	SBRS R19, 1
	CBI	PORTC, PC5
	SBRC R19, 1
	SBI PORTC, PC5
	SBRS R19, 2
	CBI	PORTD, PD3
	SBRC R19, 2
	SBI PORTD, PD3
	SBRS R19, 3
	CBI	PORTD, PD4
	SBRC R19, 3
	SBI PORTD, PD4
	SBRS R19, 4
	CBI	PORTD, PD5
	SBRC R19, 4
	SBI PORTD, PD5
	SBRS R19, 5
	CBI	PORTD, PD6
	SBRC R19, 5
	SBI PORTD, PD6
	SBRS R19, 6
	CBI	PORTD, PD7
	SBRC R19, 6
	SBI PORTD, PD7

	;LIMPIAMOS
	CLR R17
	CLR R16
	CLR R18
	CLR R20
	;CLR R21
	;CLR R22
	CLR R24
	CLR R23
	CLR R25

	SBI PORTC, PC2
	SBI PORTC, PC3 ;VALORES EN LOS CUALES SE ENCUENTRAN LOS TRANSISTORES

;******************************************************************************

Loop:
	CLI ;DESACTIVAMOS LAS INTERRUPCIONES
	MOV R16, R25
	SUBI R16, 1
	BRBC 2, DECREMENTO_LED
	MOV R16, R23
	SUBI R16, 1
	BRBC 2, INCREMENTO_LED
	CPI R20, 1
	BREQ INCREMENTO_DISPLAY
	SEI

	RJMP Loop
;******************************************************************************
; Subrutinas
;******************************************************************************


DECREMENTO_LED:
	DEC R17
	CPI R17, 0xFF
	BREQ RETORNO2
	RJMP LED
RETORNO2:
	LDI R17, 0x0F
	RJMP LED

INCREMENTO_LED:
	INC R17
	CPI R17, 0x10
	BREQ RETORNO
	RJMP LED
RETORNO:
	CLR R17; LIMPIAMOS LAS LEDS AL LLEGAR AL MÁXIMO
	RJMP LED



INCREMENTO_DISPLAY: 
	SBIS PORTC, PC2
	RJMP DECE
	RJMP UNID

LED: ;ESTABLECEMOS LAS LEDS QUE VAMOS A PRENDER
	SBRS R17, 0
	CBI	PORTB, PB0
	SBRC R17, 0
	SBI PORTB, PB0
	SBRS R17, 1
	CBI	PORTB, PB1
	SBRC R17, 1
	SBI PORTB, PB1
	SBRS R17, 2
	CBI	PORTB, PB2
	SBRC R17, 2
	SBI PORTB, PB2
	SBRS R17, 3
	CBI	PORTB, PB3
	SBRC R17, 3
	SBI PORTB, PB3
	CLR R25
	CLR R23
	RJMP Loop

UNID:
	CBI PORTC, PC2
	SBI PORTC, PC3
	MOV ZL, R21
	LPM R19, Z
	RJMP INCREMENTO_UNIDADES

DECE:
	SBI PORTC, PC2
	CBI PORTC, PC3
	MOV ZL, R22
	LPM R19, Z
	RJMP INCREMENTO_DECENAS

INCREMENTO_DECENAS:
	CPI R24, 1
	BREQ INCRE_DECENAS
	CLR R20
	RJMP DISPLAY

INCRE_DECENAS:
	CLR R24
	CLR R20
	LDI R16, 178 ; Cargar el valor calculado en donde debería iniciar.
	OUT TCNT0, R16

	INC R22
	MOV ZL, R22
	LPM R19, Z
	CPI R19, 0x77
	BREQ RESETD
	MOV ZL, R22
	LPM R19, Z
	RJMP DISPLAY

RESETD: ;REINICIAMOS CUANDO LLEGAMOS A 6
	LDI R22, LOW(SEGMENTOS << 1)
	MOV ZL, R22
	LPM R19, Z
	RJMP DISPLAY 

INCREMENTO_UNIDADES:
	CPI R18, 60
	BREQ INCRE_UNIDADES
	INC R18
	;CLR R18
	RJMP DISPLAY

INCRE_UNIDADES:
	CLR R18
	;CLR R20
	LDI R16, 178 ; Cargar el valor calculado en donde debería iniciar.
	OUT TCNT0, R16

	INC R21
	MOV ZL, R21
	LPM R19, Z
	CPI R19, 0X7D
	BREQ RESETU
	MOV ZL, R21
	LPM R19, Z
	RJMP DISPLAY

RESETU: //Si llega a F lo resetea para que continue en 0
	LDI R21, LOW(SEGMENTOS << 1)
	MOV ZL, R21
	LPM R19, Z
	INC R24
	RJMP DISPLAY





DISPLAY: 
	SBRS R19, 0
	CBI	PORTC, PC4
	SBRC R19, 0
	SBI PORTC, PC4
	SBRS R19, 1
	CBI	PORTC, PC5
	SBRC R19, 1
	SBI PORTC, PC5
	SBRS R19, 2
	CBI	PORTD, PD3
	SBRC R19, 2
	SBI PORTD, PD3
	SBRS R19, 3
	CBI	PORTD, PD4
	SBRC R19, 3
	SBI PORTD, PD4
	SBRS R19, 4
	CBI	PORTD, PD5
	SBRC R19, 4
	SBI PORTD, PD5
	SBRS R19, 5
	CBI	PORTD, PD6
	SBRC R19, 5
	SBI PORTD, PD6
	SBRS R19, 6
	CBI	PORTD, PD7
	SBRC R19, 6
	SBI PORTD, PD7
	RJMP Loop



INTERRUPCIONES:
	IN R16, PINC
	SBRS R16, PC0; BOTON DE INCREMENTO
	INC R23
	SBRS R16, PC1; BOTON DE DECREMENTO
	INC R25

SALIDA_INTERRUPCIONES:
	LDI R20, 1
	RETI





;******************************************************************************
;TABLA DE VALORES
;******************************************************************************
SEGMENTOS: .DB 0x3F, 0xC, 0x5B, 0x5E, 0x6C, 0x76, 0x77, 0x1C, 0x7F, 0x7E, 0X7D, 0x67, 0x33, 0xF, 0x73, 0x71
;GUARDAMOS LOS VALORES DE NUESTRA TABLA DE VERDAD
;0X7D, 0x67, 0x33, 0xF, 0x73, 0x71

/*SEGMENTOS: .DB 0x7F, 0b0010_1000, 0x5B, 0xB6, 0xD4, 0xE6, 0xE7, 0x34, 0xF7, 0xF6, 0XF5, 0xC7, 0x63, 0x77, 0xE3, 0xE1
;GUARDAMOS LOS VALORES DE NUESTRA TABLA DE VERDAD*/ 
