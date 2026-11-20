; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text

; ------------------------
; disciplina_t
; ------------------------
DISCIPLINA_DIAS_OFFSET    EQU 0
DISCIPLINA_NOMBRE_OFFSET  EQU 1
DISCIPLINA_ID_OFFSET      EQU 20
DISCIPLINA_NIVEL_OFFSET   EQU 24
DISCIPLINA_SIZE           EQU 28

; ------------------------
; suscripcion_t
; ------------------------
SUSCRIPCION_ACTIVA_OFFSET     EQU 0
SUSCRIPCION_DISCIPLINA_OFFSET EQU 8
SUSCRIPCION_SEMANAS_OFFSET    EQU 16
SUSCRIPCION_SIZE              EQU 24

; ------------------------
; usuario_t
; ------------------------
USUARIO_ID_OFFSET         EQU 0
USUARIO_SUSC_OFFSET       EQU 8
USUARIO_CANT_SUSC_OFFSET  EQU 16
USUARIO_MAX_SUSC_OFFSET   EQU 20
USUARIO_SIZE              EQU 24

; ------------------------
; rutina_t
; ------------------------
RUTINA_FASE_OFFSET      EQU 0
RUTINA_ID_OFFSET        EQU 0
RUTINA_AJUSTE_OFFSET    EQU 0
RUTINA_DURACION_OFFSET  EQU 0
RUTINA_NOMBRE_OFFSET    EQU 0
RUTINA_CALORIAS_OFFSET  EQU 0
RUTINA_SIZE             EQU 0

; ------------------------
; combo_t
; ------------------------
COMBO_RUTINAS_OFFSET    EQU 0
COMBO_CANT_OFFSET       EQU 0
COMBO_PUNTAJE_OFFSET    EQU 0
COMBO_SIZE              EQU 0

; ------------------------
; solicitud_t & lista_solicitudes_t
; ------------------------
SOLICITUD_DIAS_OFFSET     EQU 0
SOLICITUD_DISC_ID_OFFSET  EQU 0
SOLICITUD_NEXT_OFFSET     EQU 0
SOLICITUD_USUARIO_OFFSET  EQU 0
SOLICITUD_SIZE            EQU 0

LISTA_SOL_FIRST_OFFSET    EQU 0
LISTA_SOL_SIZE            EQU 0

; ------------------------
; cancha_t & reserva_t
; ------------------------
CANCHA_DISC_ID_OFFSET     EQU 0
CANCHA_MIN_OFFSET         EQU 0
CANCHA_MAX_OFFSET         EQU 0
CANCHA_SIZE               EQU 0

RESERVA_CANT_OFFSET          EQU 0
RESERVA_DIA_OFFSET           EQU 0
RESERVA_CANCHA_OFFSET        EQU 0
RESERVA_SIZE                 EQU 0


; ------------------------
; Funciones externas
; ------------------------
extern unificar
extern malloc

; ----------------------------------------------------
; bool suscribirDisciplina(
;     usuario_t *usuario,
;     disciplina_t *candidata,
;     bool (*son_unificables)(const disciplina_t *, const disciplina_t *)
; )
; Argumentos:
;   RDI = usuario_t *usuario
;   RSI = disciplina_t *candidata
;   RDX = son_unificables
; Retorno:
;   RAX = bool
; ----------------------------------------------------
global suscribirDisciplina
suscribirDisciplina:
    .prologo:
    push RBP
    mov RBP, RSP
    push rbx
    push R12
    push R13
    push R14
    push R15
    sub RSP, 8
    
    mov R12, RDI  ; R12 = usuario
    mov R13, RSI  ; R13 = candidata
    mov R14, RDX  ; R14 = son_unificables

    xor rbx, rbx ; rbx = i = 0

    .ciclo:
        cmp ebx, DWORD [R12 + USUARIO_CANT_SUSC_OFFSET]
        je .finCiclo

        mov R8, [R12 + USUARIO_SUSC_OFFSET] ; usuario->susc
        mov RAX, SUSCRIPCION_SIZE
        mul rbx ; RAX = SUSCRIPCION_SIZE * i
        mov R9, [R8 + RAX]          ; R9 = susc[i]
        mov R15, [R9 + SUSCRIPCION_DISCIPLINA_OFFSET] ; R15 = disciplina_t* sus->disciplina

        mov R10D, DWORD [R15 + DISCIPLINA_ID_OFFSET]  ; R10 = disciplina->id
        cmp R10D, DWORD [R13 + DISCIPLINA_ID_OFFSET]
        je .fin_false

        mov R10, [R15 + + DISCIPLINA_DIAS_OFFSET]
        mov R11, [R13 + DISCIPLINA_DIAS_OFFSET]
        and R10, R11
        cmp R10, 0
        je .siguiente
        ; if not equals:

        mov RDI, R15
        mov RSI, R13
        call R14

        cmp RAX, 0
        jne .siguiente
        ; if equals:
        mov RDI, R15
        mov RSI, R13
        call unificar  ; RAX = disciplina_t* unificacion

        mov R8, [R12 + USUARIO_SUSC_OFFSET] ; usuario->susc
        mov RAX, SUSCRIPCION_SIZE
        mul rbx ; RAX = SUSCRIPCION_SIZE * i
        mov R9, [R8 + RAX]          ; R9 = susc[i]
        mov QWORD [R9 + SUSCRIPCION_DISCIPLINA_OFFSET], RAX ;usuario->suscripciones[i].disciplina = unificacion;
        jmp .fin_true

        .siguiente:
        inc rbx
        jmp .ciclo

        .finCiclo:
        mov R8D, [R12 + USUARIO_CANT_SUSC_OFFSET] ; R8D = usuario->cant_suscripciones
        cmp R8D, DWORD [R12 + USUARIO_MAX_SUSC_OFFSET] ;  if (usuario->cant_suscripciones < usuario->max_suscripciones)
        jge .fin_false
        ; if less:

        mov RDI, SUSCRIPCION_SIZE
        call malloc
        mov R15, RAX  ; R15 =  suscripcion_t* nueva_suscripcion

        mov BYTE [R15 + SUSCRIPCION_ACTIVA_OFFSET], 1        ; nueva_suscripcion->activa = 1
        mov QWORD [R15 + SUSCRIPCION_DISCIPLINA_OFFSET], R13 ; nueva_suscripcion->disciplina = candidata
        mov WORD [R15 + SUSCRIPCION_SEMANAS_OFFSET], 4       ; nueva_suscripcion->semanas_restantes = 4


        mov R11D, DWORD [R12 + USUARIO_CANT_SUSC_OFFSET] ; R11D = cant_suscripciones
        mov R8, [R12 + USUARIO_SUSC_OFFSET] ; R8 = suscripcion_t* usuario->suscripciones
        mov RAX, SUSCRIPCION_SIZE           
        mul R11D ; RAX = SUSCRIPCION_SIZE * cant_suscripciones
        
        mov R9, [R8 + RAX]  ; R9 = usuario->suscripciones[usuario->cant_suscripciones]

        mov R10B, BYTE [R15]   
        mov BYTE [R9], R10B
        mov R10, QWORD [R15 + SUSCRIPCION_DISCIPLINA_OFFSET]
        mov QWORD [R9 + SUSCRIPCION_DISCIPLINA_OFFSET], R10
        mov R10W, WORD [R15 + SUSCRIPCION_SEMANAS_OFFSET]
        mov WORD [R9 + SUSCRIPCION_SEMANAS_OFFSET], R10W
        jmp .fin_true

    .fin_false: 
    xor RAX, RAX
    jmp .epilogo
    .fin_true:
    mov RAX, 1
    .epilogo:
    pop R15
    pop R14
    pop R13
    pop R12
    pop rbx
    pop RBP
    ret
