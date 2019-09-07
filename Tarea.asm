;Entradas: Recibe un numero entero o flotante
;Salidas:  Imprime el numero en formato decimal y en binario, si es flotante en estandar IEEE

%include "io.mac"          

.DATA
    message1    db  "Ingrese un numero:",0    
    message2    db  "El valor ingresado como numero decimal es: ",0
    message3    db  "El valor ingresado en binario en complemento a base 2 es: ",0
    message4    db  "El valor ingresado en binario en estandar IEE es: ",0
    message5    db  "El numero ingresado no es valido",0
    message6    db  "El estandar IEE se lee asi:",0
    message7    db  "1 bit para el signo del número, 23 bits para la mantisa y 8 bits para el exponente, de izquierda a derecha",0
    floatN      dd      0

.UDATA
    input       resb    4
    intNum      resb    4
    res         resb    4
    char        resb    4

.CODE

    .STARTUP
    
    PutStr  message1        ;   despliega el mensaje para pedirle un numero al usuario
    GetStr  input           ;   guarda el input del usuario en la variable input
    mov     EBX,input       ;   guarda el input en el registro EAX
    sub     DX,DX


valid_digits:               ; Revisa si los caracteres son validos

    mov     AL,[EBX]        ;   Guarda el primer caracter en el registro AL
    cmp     AL,0            ;   Pregunta si es el fin del caracter, si si 
    je      restart
    cmp     AL,'-'          ;Pregunta si es un '-'
    je      increment
    cmp     AL,'0'          ;Pregunta si es un '0'
    je      increment
    cmp     AL,'1'          ;Pregunta si es un '1'
    je      increment
    cmp     AL,'2'          ;Pregunta si es un '2'
    je      increment
    cmp     AL,'3'          ;Pregunta si es un '3'
    je      increment
    cmp     AL,'4'          ;Pregunta si es un '4'
    je      increment
    cmp     AL,'5'          ;Pregunta si es un '5'
    je      increment
    cmp     AL,'6'          ;Pregunta si es un '6'
    je      increment
    cmp     AL,'7'          ;Pregunta si es un '7'
    je      increment
    cmp     AL,'8'          ;Pregunta si es un '8'
    je      increment
    cmp     AL,'9'          ;Pregunta si es un '9'
    je      increment
    cmp     AL,'.'          ;Pregunta si es un '.'
    je      increment
    jmp     error           ;Si el caracter es invalido salta a la etiqueta error

increment:

    inc     EBX
    jmp     valid_digits


restart:

    mov     EBX,input
    sub     DX,DX

add_digit:
    mov     AL,[EBX]     ; mueve el primer caracter al registro AL
    cmp     AL,0         ; pregunta si es el final del string
    je      negative     ; fin de la conversion
    cmp     AL,'-'       ; pregunta si es un '-'
    je      pass
    cmp     AL,'.'       ; pregunta si es un '.'
    je      floatP
    sub     AL,'0'       ; convierte el caracter a entero
    add     EDX,EDX      ; multiplica el resultado hasta el momento por 10 
    mov     ECX,EDX      ; y le suma el numero 
    add     EDX,EDX
    add     EDX,EDX
    add     EDX,ECX
    add     EDX,EAX
    inc     EBX         ; pasa a evaluar el siguiente caracter
    jmp     add_digit

pass:

    inc     EBX         ; pasa a evaluar el siguiente caracter y se devuelve a la pasada etiqueta
    jmp     add_digit   



floatP:
    inc     EBX
    mov     dword[intNum],EDX   ; pasa la parte entera del numero flotante a una variable
    PutStr  message2            ; despliega el mensaje de la expresion decimal
    PutLInt  dword[intNum]      ; va imprimiendo el numero flotante, y limpia los registros para la conversion
    PutCh   '.'
    sub     EDX,EDX
    mov     ECX,10              ; mueve un 10 al registro ECX, y un 1 al registro EAX
    sub     EAX,EAX
    mov     EAX,1

add_float:
    mov     DL,[EBX]            ; agarra el siguiente caracter a evaluar
    cmp     DL,0                ; pregunta si es el final del string
    je      end_float
    sub     DL,'0' 
    PutLInt EDX                 
    mov     dword[char],EDX     ; mueve el caracter a una variable
    mul     ECX                 ; multiplica el ECX por el EAX, para tener la potencia de 10
    mov     dword[res],EAX
    fild    dword[res]          ; hace un push a la pila de la variable, y dividirlo con la potencia de 10
    fidivr  dword[char]
    fadd    dword[floatN]       ; añade el resultado que ya se lleva al numero obtenido
    fstp    dword[floatN]       ; se saca de la pila y se guarda en la variable
    inc     EBX                 ; se incrementa el EBX para evaluar el siguiente caracter
    mul     ECX 
    jmp     add_float           ; salta a a etiquete add_float


end_float:

    fild    dword[intNum]       ; hace un push de la pila el numero entero del float, y se lo suma
    fadd    dword[floatN]       ; a la parte decimal, para formar el numero flotante entero
    fstp    dword[floatN]
    mov     EBX,input           ; mueve el principio del input a EBX para evaluar si es negativo
    mov     CL,[EBX]
    cmp     CL,'-'
    mov     CX,32               ; mueve un 32 a CX para hacer el loop 32 veces
    mov     EBX,2147483648      ; mascara de 32 bits
    nwln
    PutStr  message4            ; despliega el mensaje de formato binario estandar IEEE
    mov     EDX,0               
    jne     print_bitFloat      ; si no es negativo, salta a la etiqueta print_bitFloat
    fild    dword[floatN]       
    fchs                        ; niega el tope de la pila, para convertir el numero a negativo
    fstp    dword[floatN] 
    mov     EDX,0               ; mueve un 0 a EDX, para poder usarlo de contador para separar 4 bits en la impresion
    jmp     print_bitFloat      ; salta a la etiqueta print_bitFloat


negative:

    mov     EBX,input           ; agarra el siguiente caracter a evaluar
    mov     CL,[EBX]            
    mov     EAX,EDX
    cmp     CL,'-'              ; pregunta si es negativo
    mov     CX,32               ; mueve un 32 a CX para hacer el loop 32 veces
    mov     EBX,2147483648      ; mascara de 32 bits
    PutStr  message3            ; despliega el mensaje de formato binario
    mov     EDX,0
    jne     print_bit           ; si no es negativo, salta a la etiqueta print_bit
    mov     EDX,-1
    mul     EDX                 ; multiplica por -1 para negar el resultado
    mov     EDX,0
    jmp     print_bit           ; salta a la etiqueta print_bit

print_bitFloat:
    mov     EAX,dword[floatN]
    test    EAX,EBX        
    jz      print_0Float        ; Si el bit da 0, salta a print_0Float
    PutCh   '1'                 ; si no, imprime 1
    jmp     skip1Float

print_0Float:
    PutCh   '0'          ; imprime 0

skip1Float:
    shr     EBX,1         ; hace un shift right a la mascara, para evaluar el siguiente bit
    cmp     EDX,3
    je      print_spaceFloat
    add     EDX,1
    loop    print_bitFloat
    jmp     exitFloat


print_bit:
    test    EAX,EBX        
    jz      print_0      ; Si el bit da 0, salta a print_0
    PutCh   '1'          ; si no, imprime 1
    jmp     skip1

print_0:
    PutCh   '0'          ; imprime 0

skip1:
    shr     EBX,1         ; hace un shift right a la mascara, para evaluar el siguiente bit
    cmp     EDX,3
    je      print_space    
    add     EDX,1
    loop    print_bit 
    jmp     exit

   
print_spaceFloat:

    PutCh   ' '             ; cada 4 bits, imprime un espacio, para ordenar mejor el numero en binario 
    mov     EDX,0           ; para numeros flotantes
    loop    print_bitFloat
    jmp     exitFloat 


print_space:

    PutCh   ' '             ; cada 4 bits, imprime un espacio, para ordenar mejor el numero en binario 
    mov     EDX,0           ; para numeros enteros
    loop    print_bit 

exit:
    nwln                    ; despliega el numero en formato decimal para numeros enteros 
    PutStr  message2        ; y salta a la etiqueta salida
    PutLInt  EAX
    nwln
    jmp     salida

exitFloat:
    nwln
    PutStr  message6
    nwln
    PutStr  message7        ; despliega la explicacion del estandar IEEE
    nwln
    jmp     salida          ; salta a la etiqueta salida


error:

    PutStr  message5        ; despliega el mensaje de error si un caracter no es valido
    nwln                    

salida:
    nwln
    .EXIT                   ; termina el programa
