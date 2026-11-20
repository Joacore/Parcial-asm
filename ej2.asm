; ------------------------
; Offsets para los structs
; Plataforma: x86_64 (LP64)
; ------------------------

section .data

section .text


; ------------------------
; disciplina_t
; ------------------------
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
RUTINA_ID_OFFSET        EQU 4
RUTINA_AJUSTE_OFFSET    EQU 8
RUTINA_DURACION_OFFSET  EQU 12
RUTINA_NOMBRE_OFFSET    EQU 16
RUTINA_CALORIAS_OFFSET  EQU 40
RUTINA_SIZE             EQU 44

; ------------------------
; combo_t
; ------------------------
COMBO_RUTINAS_OFFSET    EQU 0
COMBO_CANT_OFFSET       EQU 8
COMBO_PUNTAJE_OFFSET    EQU 16
COMBO_SIZE              EQU 24

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
extern malloc
extern calloc
extern free

; ----------------------------------------------------
; combo_t *armarCombo(
;     const rutina_t *catalogo,
;     uint32_t cant_catalogo,
;     const uint32_t *ids_elegidos,
;     uint32_t cant_elegidos
; )
; Argumentos:
;   RDI = const rutina_t *catalogo
;   ESI = uint32_t cant_catalogo
;   EDX = const uint32_t *ids_elegidos
;   ECX = uint32_t cant_elegidos
; Retorno:
;   RAX = combo_t *
; ----------------------------------------------------
global armarCombo
armarCombo:
    .prologo:
    push RBP
    mov RBP, RSP
    push rbx
    push R12
    push R13
    push R14
    push R15
    sub RSP, 24

    mov R12, RDI   ; R12 = catalogo
    mov [RBP-48], ESI  ; R13D = cant_catalogo
    mov R13, RDX   ; R13 = ids_elegip *(rutina_t*) $rdxdos
    mov DWORD [RBP-56], ECX  ; [RBP-8] = cant_elegidos

    xor rbx, rbx

    .chequear_existen_ids:
        cmp ebx, DWORD [RBP-48] 
        je .seguir

        mov EDI, DWORD [R13 + rbx*4]  ;EDI = ids_elegidos[i]
        mov RSI, R12
        mov EDX, DWORD [RBP-48]
        call obtenerRutinaDeCatalogo
        
        cmp RAX, 0
        je .finNULL

        inc rbx
        jmp .chequear_existen_ids

    .seguir:
    ; Si existen todos los ids:

    mov RDI, 1
    mov RSI, COMBO_SIZE
    call calloc

    mov RAX, R14  ; R14 = combo_t* combo
    xor R15, R15  ; R15 = cant_rutinas = 0

    mov EAX, DWORD [RBP-56]
    imul RAX, 8  ; 8*cant_elegidos
    mov RDI, RAX
    call malloc
    mov R10, RAX  ; R10 = rutina_t** puntero_rutinas

    xor rbx, rbx
    .ciclo:
        cmp ebx, [RBP-48]
        je .finCiclo

        mov EDI, DWORD [R13 + rbx*4]  ;EDI = ids_elegidos[i]
        mov RSI, R12
        mov EDX, DWORD [RBP-48]

        push R10
        sub RSP, 8
        call obtenerRutinaDeCatalogo ; RAX =  rutina_t* rutina
        add RSP, 8
        pop R10
        mov RDX, RAX ; RDX = rutina_t* rutina

        mov QWORD [R10 + R15*8], RAX ; puntero_rutinas[cant_rutinas] = rutina
        inc R15

        ;MUL reg: multiplicación sin signo → se multiplica con rax
        ; IMUL reg: multiplicación con signo → se multiplica con rax
        mov R8B, BYTE [RDX + RUTINA_FASE_OFFSET]
        mov R9W, WORD [RDX + RUTINA_DURACION_OFFSET]
        mov AX, R9W
        mul R8B  ; RAX = fase*rutina
        mov ECX, EAX ; RCX = fase*rutina

        mov R8B, BYTE [RDX + RUTINA_AJUSTE_OFFSET] ; R8B = ajuste
        mov AL, R8B
        imul EAX, 10  ; RAX = ajuste*10 (con signo)

        add ECX, EAX  ; RCX = fase*rutina + ajuste*10

        mov DWORD [R14 + COMBO_PUNTAJE_OFFSET], ECX

        inc rbx
        jmp .ciclo

    .finCiclo:
    mov [R14 + COMBO_RUTINAS_OFFSET], R10 ; combo->rutinas = puntero_rutinas
    mov [R14 + COMBO_RUTINAS_OFFSET], R15
    jmp .fin_returnCombo


    .finNULL:
    xor RAX, RAX
    jmp .epilogo

    .fin_returnCombo:
    mov RAX, R14
    .epilogo:
    add RSP, 24
    pop R15
    pop R14
    pop R13
    pop R12
    pop rbx
    pop RBP
    ret

; rutina_t* obtenerRutinaDeCatalogo(uint32_t id_rutina, rutina_t* catalogo, uint32_t cant_catalogo){
; EDI = id_rutina
; RSI = catalogo
; EDX = cant_catalogo 
obtenerRutinaDeCatalogo:
    .prologo:
    push RBP
    mov RBP, RSP
    push rbx
    push R12
    push R13
    push R14

    mov R12D, EDI
    mov R13, RSI
    mov R14D, EDX

    xor rbx, rbx
    .ciclo:
        cmp ebx, R14D
        je .fin_NULL

        mov RAX, RUTINA_SIZE
        mul rbx ; RAX = rbx * RUTINA_SIZE
        mov R8D, [R13 + RAX + RUTINA_ID_OFFSET]  ; R8 = catalogo[i].id

        cmp R8D, R12D
        jne .siguiente
        ; if equals:
        jmp .fin_encontrado 

        .siguiente:
        inc rbx
        jmp .ciclo
    

    .fin_NULL:
    mov RAX, 0
    jmp .epilogo

    .fin_encontrado:
    mov RAX, R13   ; RAX = &catalogo[i]
    .epilogo:
    pop R14
    pop R13
    pop R12
    pop rbx
    pop RBP
    ret