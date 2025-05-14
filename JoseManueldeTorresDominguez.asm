 ; EQUIVALENCIAS USADAS PARA LA ESTRUCTURA DE MATRIZ
 FILSJUEGO     EQU 7
 COLSJUEGO     EQU 5
 TOTALCELDAS   EQU FILSJUEGO*COLSJUEGO 

 ;EQUIVALENCIAS DE COORDENADAS PARA PINTAR EN PANTALLA (FIL, COL)  
 FILMSJMODO    EQU 20  ; posicion msj modo inicial (DEMO o Juego) 
 COLMSJMODO    EQU 5 

 FILMSJPOT     EQU 22   ; posicion msj numero tope con el que jugar
 COLMSJPOT     EQU 5 

 FILENTPOT     EQU FILMSJPOT   ; posicion para pedir el numero tope con el que jugar
 COLENTPOT     EQU COLMSJPOT+60 

 FILPANTALLAJ  EQU 1   ; posicion para imprimir pantTablero
 COLPANTALLAJ  EQU 0

 FILINICIOTAB  EQU 3   ; posicion contenido 1ra celda del tablero
 COLINICIOTAB  EQU 5   
  
 FILMSJGNRAL   EQU 20  ; posicion msjs introduce un comando, ganar, perder y salir 
 COLMSJGNRAL   EQU 43    
 
 FILCOMANDO    EQU FILMSJGNRAL  ; posicion introducir comando
 COLCOMANDO    EQU COLMSJGNRAL+10 
  

data segment        
   comando   db 22 dup ('$')  ;contendra el comando de entrada
   
   ;La estructura que almacena el tablero de juego 
   TableroJuego      dw TOTALCELDAS dup(?) ;contiene los datos del tablero en el momento actual
   TableroJuegoDebug dw 2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2,2,2,2,2  ;matriz con datos precargados
   
   fil       db ? ; para ColocarCursor
   col       db ? 

   colMatriz db ? ; para VectorAMatriz y MatrizAVector
   filMatriz db ?            
   posMatriz dw ? 
   
   tope      dw ? ; valor maximo hasta el que se jugara 
      
   ;**************************CADENAS ********************************
   cad       db 5 dup(?)  ;para almacenar el numero de una celda tras convertirlo a cadena
   cadVacia  db "     $"  ;para borrar el numero de una celda
   cadTope db 7 dup ('$')    
         
   ;Mensajes de Interfaz                      
   msjModo    db "Entrar al juego en modo Debug - tablero precargado - (S/N)? $"  
   msjIntPot  db "Introduce un valor potencia de 2, entre 16 y 2048 (incls.): $"  

   msgBlancoLargo db 19 dup (' '),'$'   ;para borrar comandos incorrectos
    
   msjPartidaGanada      db "Has ganado la partida!  ;-)  $" 
   msjPartidaPerdida     db "Has perdido! ;-(  $"
   
   PantallaInicio        db 10, 13, 10  
db " _______   ___        ______    ______   __   ___",10,13 
db "|   _   \ |   |      /      \  /  _   \ |  | /   )",10,13
db "(. |_)  :)||  |     // ____  \(: ( \___)(: |/   /",10,13  
db "|:     \/ |:  |    /  /    ) :)\/ \     |    __/",10,13   
db "(|  _  \\  \  |___(: (____/ // //  \ _  (// _  \",10,13   
db "|: |_)  :)( \_|:  \\        / (:   _) \ |: | \  \",10,13  
db "(_______/  \_______)\ _____/   \_______)(__|  \__)",10,10,13
db "            _______  ____  ____   ________  __      ______    _____  ___",10,13
db "           /       |(   _||_   | /        )|  \    /      \  (\    \|   \",10,13
db "          (: ______)|   (  ) : |(:   \___/ ||  |  // ____  \ |.\\   \    |",10,13
db "           \/    |  (:  |  | . ) \___  \   |:  | /  /    ) :)|: \.   \\  |",10,13
db "           // ___)   \\ \__/ //   __/  \\  |.  |(: (____/ // |.  \    \. |",10,13
db "          (:  (      /\\ __ //\  /  \   :) /\  |\\        /  |    \    \ |",10,13
db "           \__/     (__________)(_______/ (__\_|_)\______/    \___|\____\)",10,13,'$' 

  
   pantTablero db "    |__1__|__2__|__3__|__4__|__5__|     -= COMANDOS =-",10,13
               db "    |     |     |     |     |     |" ,10,13
               db "   A|     |     |     |     |     |" ,10,13         
               db "    |_____|_____|_____|_____|_____|     Introduce 1ro una fila y columna de" ,10,13
               db "    |     |     |     |     |     |     origen, deja un espacio y luego usa" ,10,13
               db "   B|     |     |     |     |     |     las siguientes letras hasta llegar" ,10,13         
               db "    |_____|_____|_____|_____|_____|     al bloque de destino" ,10,13     
               db "    |     |     |     |     |     |" ,10,13
               db "   C|     |     |     |     |     |" ,10,13
               db "    |_____|_____|_____|_____|_____|     Dcha  :D           Pasar       :P",10,13     
               db "    |     |     |     |     |     |" ,10,13
               db "   D|     |     |     |     |     |     Izq   :A",10,13
               db "    |_____|_____|_____|_____|_____|" ,10,13         
               db "    |     |     |     |     |     |     Abjo  :S           Nuevo Juego :N",10,13
               db "   E|     |     |     |     |     |" ,10,13
               db "    |_____|_____|_____|_____|_____|     Arrb  :W           Salir       :E",10,13           
               db "    |     |     |     |     |     |" ,10,13
               db "   F|     |     |     |     |     |" ,10,13
               db "    |_____|_____|_____|_____|_____|" ,10,13          
               db "    |     |     |     |     |     |        Comando>>" ,10,13
               db "   G|     |     |     |     |     |" ,10,13
               db "    |_____|_____|_____|_____|_____|",'$'
data ends


code segment
  include "PROCS_std.inc"  
  include "PROCS_clase.inc"

;*************************************************************************************                                                                                                                        
;*************************     procedimientos de IU    *******************************
;*************************************************************************************  
  ;F: pide un numero al usuario hasta que es un valor potencia de 2, entre 16 y 2048     
  ;S: tope (variable) contiene el valor introducido
  ControlEntrada16_2048 PROC
    push dx
    push ax
    push bx
    
    cntrl_loop:
    
    mov fil, FILMSJPOT
    mov col, COLMSJPOT
    call ColocarCursor
    lea dx, msjIntPot
    call ImprimirCadena      
    
    mov fil, FILENTPOT
    mov col, COLENTPOT
    call ColocarCursor
    lea dx, cadVacia
    call ImprimirCadena      
    
    mov fil, FILENTPOT
    mov col, COLENTPOT
    call ColocarCursor
    lea dx, cadTope
    mov cadTope[0], 5
    call LeerCadena
    lea dx, cadTope[2]
    call CadenaANumero  
    
    cmp ax, 16
    jle cntrl_loop
    
    cmp ax, 2048
    jge cntrl_loop   
    
    mov bx, ax
    dec bx
    test ax, bx
    jne cntrl_loop
    
    mov tope, ax
    
    pop bx 
    pop ax      
    pop dx
    ret
  ControlEntrada16_2048 ENDP     

  ;F:Dibuja la pantalla de inicio y pide Debug o Juego Normal y pide un numero tope para jugar entre 16 y 2048
  ; Si es modo Debug utiliza un tablero con valores iniciales
  ; Si es modo juego el usuario juega partiendo de cero contablero vacio
  ;S:TableroJuego actualizado segun Modo 
  InicioEntornoBloques PROC
    push dx
    push ax
    push di
    push si
    push cx
    
    mov fil, 0
    mov col, 0
    call ColocarCursor
    lea dx, PantallaInicio
    call ImprimirCadena
    
    mov fil, FILMSJMODO
    mov col, COLMSJMODO
    call ColocarCursor
    lea dx, msjModo
    call ImprimirCadena    
    
    mov cx, TOTALCELDAS
    lea di, TableroJuego    
    
    iniEnt_loop:
    
    call LeerTeclaSinEco
    
    CMP al, "N"
    je iniEnt_no
    
    CMP al, "S"
    je iniEnt_si
      
    jmp iniEnt_loop
    
    iniEnt_no:
    call BorrarVector
    jmp iniEnt_fin 
    
    iniEnt_si:
    lea si, TableroJuegoDebug
    call CopiarVector
 
    
    iniEnt_fin:
    
    call ControlEntrada16_2048    
    call BorrarPantalla
    mov fil, FILPANTALLAJ
    mov col, COLPANTALLAJ
    call ColocarCursor
    lea dx, pantTablero
    call ImprimirCadena
    call PintarTableroJuego
        
    pop cx
    pop si
    pop di
    pop ax    
    pop dx
    ret 
  InicioEntornoBloques ENDP  
  
;*************************************************************************************                                                                                                                        
;**********************    procedimientos de funcionlidad    *************************
;*************************************************************************************    
  ;F: Genera un vector de CX valores aleatorios potencia de 2 entre 2^1 y 2^4  
  ;E: SI, direccion del vector donde almacenar cada dato
  ;   CX, numero de valores aleatorios a generar y almacenar
  ;S: El vector contiene los valores aleatorios
  GenerarVectorAleatorios proc
    push si
    push bx
    push ax
    
  gva_loop:
    mov BL, 4             
    call NumAleatorio 
    
    push cx
    XOR ch,ch
    mov cl, ah
    inc cl
    mov ax, 1
    SHL AX, CL
    pop cx
    
    mov [si], ax
    add si,2
     
    loop gva_loop
      
    pop ax
    pop bx  
    pop si
    ret
  GenerarVectorAleatorios endp
  
  
  ;F: Comprueba si se dan las condiciones de fin de juego
  ;   Si hay una celda con valor tope (DW) se ha ganado
  ;E: tablero de juego
  ;   numero de celdas del tablero   
  ;   tope, variable DW
  ;S: AL=0 si no es fin de juego y el juego debe continuar
  ;   AL=1 si es fin de juego y el juego debe terminar (se puede crear algun estado mas si se considera oportuno)
  ;   mensajes de partida ganada en la posicion FILMSJGNRAL, COLMSJGNRAL de pantalla, si es el caso
  ComprobarFinJuegoTope proc
    push di
    push cx
    push bx
    
    XOR AL, AL
    lea di, TableroJuego
    mov cx, word ptr TOTALCELDAS
    
    cfjt_recorrer:
      mov BX, [DI]
      cmp bx, tope
      jne cfjt_salto
      mov AL, 1
      mov CX, 1
      
      cfjt_salto:
      add di, 2
    loop cfjt_recorrer
    
    cmp AL,1
    jne cfjt_salto2
    
    mov col, COLMSJGNRAL
    mov fil, FILMSJGNRAL
    call ColocarCursor
    
    lea dx, msjPartidaGanada
    call ImprimirCadena
     
    cfjt_salto2:
    
    pop bx
    pop cx       
    pop di
    ret
  ComprobarFinJuegoTope endp
  
  ;F: Comprueba si se dan las condiciones de fin de juego por haber elementos en la fila superior.
  ;   Si el tablero tiene algun bloque en la primera fila, se ha perdido.
  ;E: TableroJuego
  ;   COLSJUEGO  
  ;S: AL=0 si no es fin de juego y el juego debe continuar
  ;   AL=1 si el juego debe terminar
  ;   imprime mensaje de partida perdida en la posicion FILMSJGNRAL, COLMSJGNRAL de pantalla, si es el caso
  ComprobarFinJuegoFila proc
    push di
    push cx
    push bx
    
    XOR AL, AL
    lea di, TableroJuego
    mov cx, word ptr COLSJUEGO
    
    cfjf_recorrer:
      mov BX, [DI]
      cmp bx, 0
      je cfjf_salto
      mov AL, 1
      mov CX,1
      
      cfjf_salto:
      add di, 2
    loop cfjf_recorrer
    
    cmp AL,1
    jne cfjf_salto2
    
    mov col, COLMSJGNRAL
    mov fil, FILMSJGNRAL
    call ColocarCursor
    
    lea dx, msjPartidaPerdida
    call ImprimirCadena
     
    cfjf_salto2:
    
    pop bx
    pop cx       
    pop di
    ret    
  ComprobarFinJuegoFila endp

  ;F: Sube todos los elementos de una fila a una fila superior, sobreescribiendo cualquier dato en la fila superior 
  ;   y generando una fila aleatoria en la ultima fila inferior. 
  ;E: TableroJuego
  ;   FILSJUEGO
  ;   COLSJUEGO  
  ;S: Tablero modificado
  SubirFilaTablero proc
    push di
    push si
    push cx
    push bx
    push ax
    
    mov bx,2
    
    lea di, TableroJuego
    lea si, TableroJuego
    mov ax, COLSJUEGO
    MUL bl
    add si, ax
    
    mov AX, TOTALCELDAS
    sub AX, COLSJUEGO
    mov cx, ax
    call CopiarVector
    
    MUL bl
    mov CX, COLSJUEGO
    lea si, TableroJuego
    add si, ax
    call GenerarVectorAleatorios
                  
    pop ax
    pop bx
    pop cx
    pop si        
    pop di
    ret
  SubirFilaTablero endp  
 
 
  ;F: Lee un comandos hasta que correponda con un formato de salida permitido y devuelve la acción que habrá que realizar:
  ;    formato A (cadenas que solo pueden contener un carácter):             
  ;    "P$" -> paso (seguir jugando sin mover bloque)     ; S: AH=0 
  ;    "N$" -> nuevo juego                                ; S: AH=1 
  ;    "E$" -> salir del juego                            ; S: AH=2

  ;    formato B: una cadena de longitud variable, de hasta 19 caracteres sin incluir el ENTER
  ;    FILCOL XXXXX donde FILCOL representan la posicion de un bloque a mover, siendo FIL un valor de fila entre 'A' y 'G', y COL la columna entre '1' y '5'
  ;    tras el espacio en blanco, XXXXX representa una combinación de caracteres que indican
  ;    'D' desplazar a la derecha
  ;    'A' desplazar a la izquierda         
  ;    'S' desplazar hacia abajo
  ;    'W' desplazar arriba                                
  ;    la salida del formato B es                         ; S: AH=3
  ComandoEntrada proc
    push dx
    push bx
    
    ce_err:
    
    XOR AX,AX
    mov fil, FILCOMANDO
    mov col, COLCOMANDO
    call ColocarCursor
    
    lea dx, msgBlancoLargo
    call ImprimirCadena  
    
    mov fil, FILCOMANDO
    mov col, COLCOMANDO
    call ColocarCursor
    
    lea dx, comando
    mov comando[0],19
    call LeerCadena
         
    cmp comando[1], 1
    jne ce_f2

    cmp comando[2], "P"
    jne ce_f1_j1
    mov ah, 0
    jmp ce_fin
    
    ce_f1_j1:
    cmp comando[2], "N"
    jne ce_f1_j2
    mov ah, 1
    jmp ce_fin
    
    ce_f1_j2:
    cmp comando[2], "E"
    jne ce_err
    mov ah, 2
    jmp ce_fin
    
    
    
    
    ce_f2:
    cmp comando[2], "A"
    jl ce_err
    cmp comando[2], "G"
    jg ce_err
    cmp comando[3], "1"
    jl ce_err
    cmp comando[3], "5"
    jg ce_err
    cmp comando[4], " "
    jne ce_err
    
    mov bx, 4
    ce_bucle_inf:
    inc bx
    cmp comando[bx], "D"
    je ce_bucle_inf
    cmp comando[bx], "A"
    je ce_bucle_inf         
    cmp comando[bx], "W"
    je ce_bucle_inf    
    cmp comando[bx], "S"
    je ce_bucle_inf
    cmp comando[bx], 13
    je ce_f2_fin
    jmp ce_err
    jmp ce_bucle_inf
        
    ce_f2_fin:
    
    mov ah,3
    
    ce_fin:
    
    pop bx
    pop dx
    ret
  ComandoEntrada endp
  
  ;F: Comprueba si los movimientos descritos en la cadena comando son legales.
  ;E: comando, TableroJuego
  ;   col, fil
  ;   FILSJUEGO, COLSJUEGO
  ;S: CX=1 si el movimiento es legal
  ;   CX=-1 si el movimiento es ilegal
  ;   DI= direccion en el vector del bloque original
  ;   SI= direccion en el vector del bloque destino 
  ComprobarMovimiento proc
    push ax
    push bx
    push dx  
    
    ;obtener coord inicio
    mov ah, comando[2]
    sub ah, 41h
    mov al, comando[3]
    sub al, 31h    
    mov fil, ah
    mov col, al
    
    XOR CX, CX    
    ;AH - fila
    ;AL - col
    XOR AX,AX
    XOR DX,DX
    
    mov bx, 4
    cm_bucle_inf:
    inc bx
    
    cmp CX, 0
    je cm_salto_caso_1:
    
    cmp dh, 0
    jl cm_err
    cmp dh, FILSJUEGO
    jg cm_err
    cmp dl, 0
    jl cm_err
    cmp dl, COLSJUEGO
    jg cm_err
    jmp cm_sig0
    
    cm_salto_caso_1:
    mov dh, fil
    mov dl, col
    mov CX, 1
    
    cm_sig0:
    lea si, TableroJuego;cargar comando en SI        
    cmp comando[bx], "D"
    jne cm_sig1            

    inc dl
    jmp cm_num
    
    cm_sig1:
    cmp comando[bx], "A"
    jne cm_sig2
    
    dec dl        
    jmp cm_num
    
    cm_sig2:         
    cmp comando[bx], "W"
    jne cm_sig3
    
    dec dh
    jmp cm_num
    
    cm_sig3:    
    cmp comando[bx], "S"
    jne cm_err
    
    inc dh
    jmp cm_num
    
    cm_num:
    mov filMatriz, dh
    mov colMatriz, dl
    call MatrizAVector
    mov ax, posMatriz
    SHL ax, 1
    lea si, TableroJuego
    add si, ax
    mov ax, [si]
    
    cmp ax, 0
    je cm_bucle_inf
    
    PUSH AX
    mov bh, fil
    mov filMatriz, bh
    mov bl, col
    mov colMatriz, bl
    call MatrizAVector
    mov ax, posMatriz
    SHL ax, 1
    lea di, TableroJuego
    add di, ax
    mov bx, [di]
    POP AX
      
    cmp ax, bx
    je cm_fin   
    
    cm_err:
    mov cx,-1
    
    cm_fin:
    pop dx
    pop bx
    pop ax
    ret                                                                                                 
  ComprobarMovimiento endp
  
  
  ;F: Le suma a un bloque el valor de otro bloque, eliminando este ultimo en el proceso y apilando todos los bloques de nuevo.
  ;E: TableroJuego
  ;   col, fil
  ;   DI= direccion en el vector del bloque original
  ;   SI= direccion en el vector del bloque destino 
  ;   FILSJUEGO, COLSJUEGO
  ;S: Modifica el TableroJuego
  SumaBloques proc
    push ax
    push cx
    push dx
    push di
    push si
    
    ;ponemos el bloque original a cero
    mov [di], 0
    ;multiplicamos *2 el bloque destino (instruccion logica)
    SHL [si], 1
    
    ;obtener fila columna del bloque origen
    mov ax, di
    lea cx, TableroJuego
    sub ax, cx
    SHR ax, 1
    XOR DX,DX
    mov cx, COLSJUEGO
    DIV cx
    mov cl, dl ;COL  EN CL
    mov ch, al ;FILA EN CH
        
    mov dx, COLSJUEGO
    SHL dx, 1
    
    add di, dx
        
    sb_start:
    CMP CH, 0
    je sb_fin
       
    dec ch
      
    sub di, dx 
    mov ax, [di]
    cmp ax, 0
    jne sb_start
    PUSH SI
    mov si, di
    sub si, dx
    mov ax, [si]
    mov [si], 0
    mov [di], ax
    POP SI
    jmp sb_start       
    
                      
    sb_fin:
    
    pop si
    pop di
    pop dx
    pop cx        
    pop ax
    ret       
  SumaBloques endp  
  
;************************ PROGRAMA PRINCIPAL ***************
principal:
    mov ax, data
    mov ds, ax         

    ;INICIO DEL PROGRAMA
    call InicioEntornoBloques

    ;RECEPCION DE COMANDOS
    cmdEnt:
    call ComandoEntrada
    
    ;PROCESAMIENTO DEL COMANDO
    
    ;COMANDO P
    cmp AH, 0
    jne salto1
    call SubirFilaTablero
    call PintarTableroJuego
    call ComprobarFinJuegoFila
    cmp AL, 0
    je cmdEnt
    ;El jugador ha perdido la partida
    mov fil, FILMSJGNRAL
    mov col, COLMSJGNRAL 
    call ColocarCursor
    lea dx, msjPartidaPerdida
    call ImprimirCadena
    jmp fin
    
    ;COMANDO N
    salto1: 
    cmp AH,1
    jne salto2
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR DX,DX
    XOR DI,DI
    XOR SI,SI
    mov fil, 0
    mov col, 0
    mov filMatriz, 0
    mov colMatriz, 0
    mov posMatriz, 0
    call BorrarPantalla
    jmp principal
         
    ;COMANDO E    
    salto2:
    cmp AH, 2    
    jne salto3
    jmp fin    
    
    ;COMANDO MOVIMIENTO
    salto3:    
    cmp AH, 3
    jne fin
    call ComprobarMovimiento
    cmp cx, 1
    jne cmdEnt ;CAMBIAR A REALIZAR MOVIMIENTO DEL BLOQUE
    call SumaBloques
    call PintarTableroJuego
    call ComprobarFinJuegoTope
    cmp AL, 0
    je cmdEnt
    ;El jugador ha ganado la partida
    mov fil, FILMSJGNRAL
    mov col, COLMSJGNRAL 
    call ColocarCursor
    lea dx, msjPartidaGanada
    call ImprimirCadena
            
    fin:      
    mov ah, 4ch
    int 21h        
 ends 
end principal   
     