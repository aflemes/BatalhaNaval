.model small

.stack 100H

.data 
    CR EQU 13
    LF EQU 10 
    moldura_inicio db "               ####################################################" ,CR,LF
                   db "               ###                                              ###" ,CR,LF
                   db "               ###                   BATALHA                    ###" ,CR,LF
                   db "               ###                    NAVAL                     ###" ,CR,LF
                   db "               ###                                              ###" ,CR,LF
                   db "               ####################################################$",CR,LF
    opcao_start db "start game"
    opcao_sair  db "sair"
    console_00  db "#############################################"
    console_01  db "#Informe a opcao:                           #"
    console_02  db "#############################################"      
    msg_fim_player db "Voce venceu. Pressione qualquer tecla para continuar"
    msg_fim_bot    db "Voce perdeu. Pressione qualquer tecla para continuar"
    msg_fim_jogo   db "FIM DE JOGO"
    msg_venceu     db "Voce venceu"
    msg_novo_jogo  db "Novo jogo  "
    msg_reiniciar  db "Reiniciar jogo"
    msg_perdeu     db "Voce perdeu"
    msg_aguarde    db "Inicializando barcos do adversario, aguarde..."
    msg_sobrepo    db "As cordenadas informadas se sobrepoe, informe novamente. Pressione ENTER."
    limpa_console  db "                                                                         "
    mensagem_repetido db "Voce ja atirou nessa coordenada, informe novamente. Pressione ENTER."
    moldura_principal db " ______________________          ______________________    ___________________" ,CR,LF
                      db "|   matriz de navios   |        |   matriz de tiros    |  | Voce              |" ,CR,LF
                      db " ----------------------          ----------------------   |        Tiros: 00  |" ,CR,LF
                      db "|  0 1 2 3 4 5 6 7 8 9 |        |  0 1 2 3 4 5 6 7 8 9 |  |      Acertos: 00  |" ,CR,LF
                      db " ----------------------          ----------------------   |    Afundados: 00  |" ,CR,LF
                      db "|0                     |        |0                     |   -------------------" ,CR,LF
                      db "|1                     |        |1                     |  | Computador        |" ,CR,LF
                      db "|2                     |        |2                     |  |        Tiros: 00  |" ,CR,LF
                      db "|3                     |        |3                     |  |      Acertos: 00  |" ,CR,LF
                      db "|4                     |        |4                     |  |    Afundados: 00  |" ,CR,LF
                      db "|5                     |        |5                     |  |  Ultimo Tiro: 0x0 |" ,CR,LF
                      db "|6                     |        |6                     |   -------------------" ,CR,LF
                      db "|7                     |        |7                     |" ,CR,LF
                      db "|8                     |        |8                     |" ,CR,LF  
                      db "|9                     |        |9                     |" ,CR,LF
                      db " ----------------------          ---------------------- " ,CR,LF
    console_player    db " --------------------------------------------------------------------------",CR,LF 
                      db "|Mensagem:                                                                 |",CR,LF 
                      db "|                                                                          |",CR,LF 
                      db " -------------------------------------------------------------------------- ",CR,LF 
                      db "|Posicao:                                                                  |",CR,LF
                      db " --------------------------------------------------------------------------",CR,LF
    msg_player1       db "Informe a coluna do "
    msg_player2       db "Informe a linha do  "
    msg_player3       db "Informe a direcao do" 
    str_tiro          db "tiro" 
    porta_aviao       db "Porta avioes:   "
    navio_guerra      db "Navio de Guerra:"
    submarino         db "Submarino:      "
    destroyer         db "Destroyer:      "
    barco_patrulha    db "Barco Patrulha: "      
    matriz_player     db 100 dup(0)
    vet_matriz_player dw 10  dup(0)
    matriz_bot        db 100 dup(0) 
    vet_tiros_bot     db 100 dup(0)
    matriz_bot_sec    db 15  dup(?) 
    vet_afundados     db 5   dup(0)
    vet_afundados_bot db 5   dup(0)
    tiros             db 1   dup(0)
    acertos           db 1   dup(0)
    afundados         db 1   dup(0)
    tiros_bot         db 1   dup(0)
    acertos_bot       db 1   dup(0)
    afundados_bot     db 1   dup(0)
                
.code   
   
;Set cursor position
;BH = Page Number, DH = Row, DL = Column
POS_CURSOR proc 
    push AX
    push BX
    mov AH, 02 ;Codigo da funcao
    int 10h    ;Interrupcao
    pop BX
    pop AX
    ret
endp  

;Read character and attribute at cursor position
LE_CHAR_VIDEO proc
    push BX
    mov BH, 1  ; pagina
    mov AH, 08 ; funcao
    int 10h    ; interrupcao 10h
    pop BX
    ret
endp    

LER_CHAR proc ; Ler caractere do teclado sem echo
    mov AH, 7 ; retorna o caractere em AL
    int 21h  
    ret  
endp 

LER_KEY proc ; Ler os direcionais do teclado
    mov AH, 0 ; retorna o caractere em AL
    int 16h  
    ret  
endp
 
;Metodo escreve apenas um caractere na posicao 
;ENTRADA: AL : Caracter
;         BH : Nro Pagina
;         CX : Tamanho da 'string'
ESC_SINGLE_CHAR_VIDEO proc
    push AX
    push BX
    push CX
    
    ;mov BL, 07H ;cor branca
    mov AH, 09h 
    mov CX, 01h
    int 10h     ; interrupacao
    
    pop CX
    pop BX
    pop AX
    ret
    
    ret    
endp

; metodo responsavel por escrever na tela dado coordenadas
; bh = pagina
; dh = linha, dl = coluna 
; bl atributo cor 4 bits: intensidade, red, green, blue    
ESC_STRING_VIDEO proc 
    push AX
    push BX
    push CX
    push DX
    
    mov AH, 13h 
    mov AL, 00h 
    int 10h     ; interrupacao
    pop DX
    pop CX
    pop BX
    pop AX
    ret
endp
              
;Escrever caractere na tela               
;Entrada DL = caracter a ser impresso
ESC_CHAR proc 
    push AX 
    
    mov ah, 2
    int 21h      
    pop AX
    ret
endp
    
; metodo responsavel por trocar a pagina
; parametro de entrada AL
TROCA_PAGINA proc
    push ax
    mov ah, 05h
    int 10h
    pop ax
    ret
endp

; escreve uma 'string' em tela 
; sempre na coluna = 0 e linha = 0
ESC_STRING_SIMPLES proc
    push AX
    mov AH, 09H
    int 21h 
    pop AX
    ret    
endp
;metodo para 'limpar' a tela
;no caso ele escreve o char ''
LIMPAR proc 
    push DX
    ; Escrever o caractere 'branco' na tela  
    mov DL, ' '
    call ESC_CHAR    
    pop DX 
    ret
endp
  
;metodo le um caracter do alfabeto (A...Z) e devolver em CL
LER_ALFABETO proc
    push AX
    push BX
    push DX
    
    xor CX, CX         ; armazena o caracter digitado
     
CONT_LER_ALFABETO:    
    call LER_CHAR 
    cmp AL, CR         ; verifica se e ENTER
    jz FIM_LER_ALFABETO 

    cmp AL,'A'         ; se o caracter digitado for menor que A nao e um char
    jb CONT_LER_ALFABETO
                       
    cmp AL,'z'         ; se for maior que z nao e um char
    ja  CONT_LER_ALFABETO
         
    cmp AL,'a'
    jnb COMPARA_DIRECOES
    
    add AL,32          ;32 decimal = diferenca entre o A e o a 
         
COMPARA_DIRECOES:      ;permite apenas os caracters h(orizontal) e v(ertical)
    cmp AL, 'h'
    jz ESCREVE_ALFABETO           
               
    cmp AL, 'v'               
    jz ESCREVE_ALFABETO
    
    jmp CONT_LER_ALFABETO            
           
ESCREVE_ALFABETO:    
    mov DL, AL
    call ESC_CHAR
           
    mov CL, DL       
    pop DX
    call POS_CURSOR
    push DX
    
    jmp CONT_LER_ALFABETO
    
    FIM_LER_ALFABETO:
        cmp CX, 0             ; caso o CX for zero, indica que ele nao informou nenhum caracter  
        jz CONT_LER_ALFABETO  ; apenas pressionou 'enter' 
        
        pop DX
        pop BX
        pop AX
        ret
endp  

;metodo le um digito (0...9) e devolver em SI
LER_NUMERO proc
    push AX
    push BX
    push DX 
    
    xor CX, CX         ; armazena o caracter digitado
     
    CONT_LER_NUMERO:    
        call LER_CHAR 
        cmp AL, CR ; verifica se e ENTER
        jz FIM_LER_NUMERO 
        
        ; Verifica se eh um algarismo  
        cmp AL,'0'
        jb CONT_LER_NUMERO
        cmp AL,'9'
        ja CONT_LER_NUMERO
        mov DL, AL      
        ; Escrever o caractere na tela  
        sub AL, '0'
        call ESC_CHAR
                   
        mov CL, DL       
        pop DX
        call POS_CURSOR
        push DX
        
        jmp CONT_LER_NUMERO
        
        FIM_LER_NUMERO:
            cmp CX, 0             ; caso o CX for zero, indica que ele nao informou nenhum caracter  
            jz CONT_LER_NUMERO    ; apenas pressionou 'enter' 
            
            pop DX
            pop BX
            pop AX
        ret
endp
    
;metodo para retornar a SIGLA da embarcacao
;ENTRADA  AL = indicador da embarcacao
;SAIDA    DH = Simbolo que representa a embarcacao 
  
SIGLA_EMBARCA proc
    cmp AL,0
    jz SIGLA_PORTA_AVIAO 
                      
    cmp AL,1
    jz SIGLA_NAVIO_GUERRA
    
    cmp AL,2
    jz SIGLA_SUBMARINO
    
    cmp AL,3
    jz SIGLA_DESTROYER
    
    cmp AL,4
    jz SIGLA_PATRULHA                      
            
    SIGLA_PORTA_AVIAO:
        mov DH,'A'
        jmp FIM_SIGLA
        
    SIGLA_NAVIO_GUERRA:
        mov DH,'B'         
        jmp FIM_SIGLA
        
    SIGLA_SUBMARINO:
        mov DH,'S'         
        jmp FIM_SIGLA 
        
    SIGLA_DESTROYER:
        mov DH,'D'
        jmp FIM_SIGLA
        
    SIGLA_PATRULHA:
        mov DH,'P'
        
    FIM_SIGLA:    
        ret    
endp

;metodo para retornar o tamanho da embarcacao
;ENTRADA: AL = indicador da embarcacao
;SAIDA    CL = Tamanho da embarcacao

TAMANHO_EMBARCA proc
    cmp AL,0
    jz TAM_PORTA_AVIAO 
                      
    cmp AL,1
    jz TAM_NAVIO_GUERRA
    
    cmp AL,2
    jz TAM_SUBMARINO
    
    cmp AL,3
    jz TAM_DESTROYER
    
    cmp AL,4
    jz TAM_PATRULHA                      
            
TAM_PORTA_AVIAO:
    mov CL,5
    jmp FIM_TAM_EMBARCA
    
TAM_NAVIO_GUERRA:
    mov CL,4
    jmp FIM_TAM_EMBARCA
    
TAM_SUBMARINO:
    mov CL,3
    jmp FIM_TAM_EMBARCA 
    
TAM_DESTROYER:
    mov CL,3
    jmp FIM_TAM_EMBARCA
    
TAM_PATRULHA:
    mov CL,2 
    
FIM_TAM_EMBARCA:    
    ret
endp 
     
;metodo responsavel por verificar os limites informados
;ENTRADA: CH = Direcao 
;         CL = Tamanho embarcacao
;         AL = Indicador do barco
;         BL = Inicio da coluna
;         BH = Inicio da linha
;         DH = 0 - Player 1 - BOT
     
;SAIDA    DX = 1 (retorna com erro)
       
SOBREPOSICAO proc 
    push AX
    push BX
    push CX
    push DI
    push SI
    
    cmp CH, 'v'
    jz  SETA_VERTICAL
    jmp SETA_HORIZONTAL
    
    SETA_VERTICAL:
        mov SI, 'v' 
        jmp CONTINUA
    SETA_HORIZONTAL:
        mov SI, 'h'        
    
    CONTINUA:        
        xor DL, DL      ;DL e o meu retorno, logo inicializo com 0 para nao pegar lixo      
        cmp DH, 1 
        jz VET_BOT
        
        
        VET_PLAYER:
            mov DI, offset matriz_player 
            jmp CONT_SOBR
        
        VET_BOT:  
            mov DI, offset matriz_bot
        
        CONT_SOBR:                    
            cmp AL, 0           ;caso for o primeiro barco, nao precisa verificar sobreposicao
            jz FIM_SOBREPOSICAO                    
            
            mov AL, BH          ;linha
            mov BH, 10          ;
            mul BH              ;multiplica a linha por 10 para encontrar posicao no vetor
            add AL, BL          ;adiciona a coluna,
              
            mov BX, AX   
            cmp byte ptr [BX + DI], 0
            jne FIM_COM_ERRO
            
            xor CH, CH               
            dec CL                   
            LOOP_CONSISTE:
                cmp SI, 'v'
                jz  INCV
                jmp INCH
                INCV:
                    add AL, 10
                    jmp CONSISTE_POSICAO
                INCH:
                    inc AL 
                
                CONSISTE_POSICAO:
                    mov BX, AX 
                    cmp byte ptr [BX + DI], 0
                    jne FIM_COM_ERRO
                    
                loop LOOP_CONSISTE
                
            jmp FIM_SOBREPOSICAO    
            
            FIM_COM_ERRO:
                mov DL, 1    
                      
            FIM_SOBREPOSICAO: 
                pop SI          
                pop DI
                pop CX
                pop BX
                pop AX
                ret
endp
 
;metodo responsavel por verificar os limites informados
;ENTRADA: CL = Direcao
;         AL = Indicador do barco
;         BL = Inicio da coluna
;         BH = Inicio da linha
;         DH = 0 - Player 1 - BOT
     
;SAIDA    DL = 1 (retorna com erro)
VALIDA_LIMITES proc
    push AX
    push BX
    push CX
         
    mov CH, CL
    call TAMANHO_EMBARCA 
    
    call SOBREPOSICAO
    cmp DL,1
    jz ERRO_LIMITE     
    
    cmp CH, 'h'
    jz VALIDA_LIMIT_HORI
    
    cmp CH, 'v'
    jz VALIDA_LIMIT_VERT
        
    VALIDA_LIMIT_HORI:
        add bl, cl
        
        cmp bl,10
        ja ERRO_LIMITE
        jmp FIM_VALIDA_LIMITES        
    
    VALIDA_LIMIT_VERT:
        add bh, cl
        
        cmp bh,10
        ja ERRO_LIMITE
        jmp FIM_VALIDA_LIMITES
        
    ERRO_LIMITE:
        mov DL, 1
        cmp DH, 1             ;caso for o bot, nao lista as mensagens
        jz FIM_VALIDA_LIMITES
        call LISTA_ERRO_SOBREPOSICAO
        
        mov BP, offset limpa_console
        mov CX, 73
        call MSG_CONSOLE
        
    FIM_VALIDA_LIMITES:
        
        pop CX 
        pop BX
        pop AX
        ret    
endp
     
POSICIONA_BARCO proc
    push AX
    push CX
    
    xor DX, DX
    dec CX
    
    cmp SI, 'v'
    jz CALCULA_COLUNA
        
    ESPACO_COLUNA:
        mov AX, 2   ;na tela a matriz dos elementos esta distanciada por 2 caracters
        mul CX      ;logo multiplica o tamanho do barco por 2 e acresce a posicao inicial
        mov CX, AX
            
    CALCULA_COLUNA:
        mov AX, 2
        mov DL,BL
        
        mul DX
        mov DX, AX
        
        mov DH,BH
        
        cmp SI, 'h'
        jz POS_HORIZONTAL
        
        cmp SI, 'v'
        jz POS_VERTICAL
    
    
    POS_HORIZONTAL: ;Posiciona cursor na posicao
        add DL,CL
        jmp FIM_POSICIONA
    
    POS_VERTICAL: ;Posiciona cursor na posicao
        add DH,CL
    
    FIM_POSICIONA:
        pop CX
        pop AX
        ret    
endp         
      
;Funcao para desenhar os barcos 
;ENTRADA: BL: Coluna
;         BH: Linha     
;         CX: Direcao
;         AL: Indicador do barco
;         AH: 0 - Player 1 - Bot
DESENHA_BARCOS proc
    push BX
    push CX
    push DX
    push SI
    push AX
     
    mov SI, CX
    call TAMANHO_EMBARCA ; retorna em CX o tamanho da embarcacao
     
    ;BH = Posicao da LINHA
    ;BL = Posicao da COLUNA 
    call SIGLA_EMBARCA ; retorna em DH o simbolo da embarcacao
           
    LACO_DESENHO:
        push CX
        push AX
        push BX
        push DX
        
        call POSICIONA_BARCO        
        
        add DH, 5                   ;'sandbox' comeca em 3;5              
        cmp AH, 1
        jz PRINT_BOT
        PRINT_PLAYER:
            add DL, 3               ;'sandbox' comeca em 3;5    
            jmp CONT_PRINT_DESENHO  
            
        PRINT_BOT:
            add DL, 35              ;'sandbox bot' comeca em 23;5
            
        CONT_PRINT_DESENHO:
            mov BH, 2
            call POS_CURSOR ;BH = Page Number, DH = Row, DL = Column           
        
        pop DX
        
        mov AL, DH
        mov BL, 07h ;cor branca
        call ESC_SINGLE_CHAR_VIDEO
        
        pop BX
        pop AX
        pop CX
        
        loop LACO_DESENHO    
        jmp FIM_DESENHA_BARCOS
        
    FIM_DESENHA_BARCOS:
        pop AX
        pop SI
        pop DX
        pop CX
        pop BX        
        ret            
endp 

;Metodo responsavel por limpar o console
MSG_CONSOLE proc
    push AX
    push BX
    push CX
    push DX
    
    mov DL, 1  ;coluna
    mov DH, 18 ;linha  
    mov BL, 7  ;cor branca
    mov BH, 2  ;pagina 2
    call ESC_STRING_VIDEO     
            
    pop DX
    pop CX
    pop BX
    pop AX 
    ret    
endp   

;Lista mensagem de erro informando que os barcos estao sobrepostos
LISTA_ERRO_SOBREPOSICAO proc  
    push AX
    push BX
    push CX
    push DX
    
    mov bp, offset msg_sobrepo
    mov dl, 1  ;coluna
    mov dh, 18 ;linha  
    mov cx, 73 ;tamanho da string 
    mov bl, 7  ;cor branca
    mov bh, 2  ;pagina 2
    call ESC_STRING_VIDEO    
     
    LER_ENTER:
        call LER_CHAR 
        cmp AL, CR ; verifica se e ENTER
        jz FIM_LIMPA_MSG
        jmp LER_ENTER   
    FIM_LIMPA_MSG:        
        pop DX
        pop CX
        pop BX
        pop AX 
    ret
endp
   
   
;Busca o nome do barco atual
;ENTRADA
;AL = Indicador do barco
;SAIDA
;BP =      
BUSCA_NOME_BARCO proc 
    mov CX, 16 ;tamanho da string
        
    cmp AL,0
    jz INIT_PORTA_AVIAO
     
    cmp AL,1 
    jz INIT_NAVIO_GUERRA
    
    cmp AL,2
    jz INIT_SUBMARINO
    
    cmp AL,3 
    jz INIT_DESTROYER
    
    cmp AL,4
    jz INIT_BARCO_PATRULHA
    
    INIT_PORTA_AVIAO:
        mov bp, offset porta_aviao
        jmp FIM_BUSCA_NOME 
        
    INIT_SUBMARINO:
        mov bp, offset submarino
        jmp FIM_BUSCA_NOME
        
    INIT_DESTROYER:
        mov bp, offset destroyer
        jmp FIM_BUSCA_NOME
        
    INIT_NAVIO_GUERRA:
        mov bp, offset navio_guerra
        jmp FIM_BUSCA_NOME
    
    INIT_BARCO_PATRULHA:
        mov bp, offset barco_patrulha 
        
    FIM_BUSCA_NOME:
        ret           
endp

LISTA_CONSOLE proc
    mov dl, 0 ;coluna
    mov dh, 16 ;linha  
    call POS_CURSOR
    
    mov cx, 465; tamanho da string
    mov bh, 2
    mov bp, offset console_player
    call ESC_STRING_VIDEO    
    ret    
endp    
;Lista a moldura principal dos barcos do player
LISTA_MOLDURA_PRINCIPAL proc
    mov dl, 0 ;coluna
    mov dh, 0 ;linha  
    call POS_CURSOR
    
    mov cx, 1380; tamanho da string
    mov bh, 2
    mov bp, offset moldura_principal
    call ESC_STRING_VIDEO    
    ret
endp
  
;Pede as informacoes em tela
;ENTRADA: AH = Tipo da mensagem
;SAIDA:   CX = Caracter digitado 
PEDE_INFORMACOES proc 
    push BX
    push DX
    
    xor BX, BX  
    mov BL, 7   ;cor branca
    mov BH, 2   ;pagina 2    
    mov DL, 1   ;coluna
    mov DH, 18  ;linha
    mov CX, 20  ;tamanho da string
     
    call POS_CURSOR
    
    call ESC_STRING_VIDEO
    
    ;primeiro le a coluna
    mov DL, 9  ;coluna
    mov DH, 20 ;linha
    
    call POS_CURSOR
    cmp AH, 3
    jz LER_ALFA
    
    call LER_NUMERO 
    jmp FIM_INFOR
    
    LER_ALFA:
        call LER_ALFABETO 
        
    FIM_INFOR:           
        call LIMPAR
        call POS_CURSOR 
    pop DX
    pop BX
    ret    
endp  
 
;Armazena os barcos na matriz
;ENTRADA: AL : Indicador da embarcacao
;         BL : Coluna
;         BH : Linha
;         CX : Direcao
ARMAZENA_BARCOS proc
    push AX
    push BX 
    push CX
    
    mov DL, CL
    call TAMANHO_EMBARCA
    call SIGLA_EMBARCA   
    
    push DX
           
    mov AL, BH
    mov DH, 10
    mul DH 
    add AL, BL
    
    pop DX
     
    mov BX, AX 
    mov [BX + DI], DH
    dec CL
             
    ARMAZENA:
        cmp DL, 'v'
        jz  INC_VERT
        jmp INC_HOR
        INC_VERT:
            add AL, 10
            jmp SAVE
        INC_HOR:
            inc AL 
        
        SAVE:
            mov BX, AX 
            mov [BX + DI], DH
    
        loop ARMAZENA    
           
    pop CX       
    pop BX    
    pop AX        
    ret    
endp  

;Escreve o respectivo nome do barco
;  ENTRADA: AL: Indicador do barco

ESC_NOME_BARCO proc 
    push BX
    push DX
    
    mov BL, 7   ;cor branca
    mov BH, 2  ;pagina
    mov DL, 22 ;coluna
    mov DH, 18 ;linha
        
    call BUSCA_NOME_BARCO
    call ESC_STRING_VIDEO     
    
    pop BX
    pop DX
    ret
endp

INIT_BARCOS_PLAYER proc
    mov DI, offset matriz_player 
    
    mov CX, 5  ;inicializa 5 navios
      
    xor AX, AX 
         
    INICIALIZA_NAVIOS:
        push CX
        push AX
                 
        call ESC_NOME_BARCO
            
        ESC_COLUNA:
            mov AH, 1                    
            mov BP, offset msg_player1
            call PEDE_INFORMACOES
            mov BL, CL
                  
        ESC_LINHA: 
            mov AH, 2 
            mov BP, offset msg_player2
            call PEDE_INFORMACOES
            mov BH, CL
                     
        ESC_DIRECAO:
            mov AH, 3 
            mov BP, offset msg_player3
            call PEDE_INFORMACOES 
            
        pop AX                  ;variavel que armazena indicador do barco
        
        sub BL, '0'
        sub BH, '0'        
        
        mov DH, 0               ;Indica que a chamada e feita para o player
        call VALIDA_LIMITES  
        cmp DL, 1               ;caso for 1 ocorreu algum tipo de erro
        jz REPETE_REGISTRO
        
        call ARMAZENA_BARCOS
        call ARMAZENA_BARCOS_VET
        mov AH, 0    
        call DESENHA_BARCOS 
        
        pop CX ;
        jmp PROXIMO_REGISTRO
        
        REPETE_REGISTRO:
            pop CX ;armazena o indice do laco
            inc CX
            dec AX
            
        PROXIMO_REGISTRO:    
            inc AX
        
        loop INICIALIZA_NAVIOS
    ret    
endp
;Gera um numero aleatorio utilizando o relogio do sistema
;random(0,X)   
;Saida:   DL o valor aleatorio
RANDOM_NOVO proc
   push AX
   push BX
   push CX
   
   mov AH, 2Ch  ; interrupcao para pegar system time
   int 21H                                                      
   
   ;Return: CH = hour CL = minute DH = second DL = 0 e 99 seconds       
   
   pop CX
   pop BX
   pop AX
   ret
endp

;Neste metodo e gerado as posicoes aleatorias para o computador
;Saida: BL = Indica a coluna
;       BH = Indica a linha
;       CL = Indica a posicao (v = vertical; h = horizontal)
GERA_POSICOES_ALEAT proc
    push AX
    
    call RANDOM_NOVO
    
    xor AX, AX
    xor DH, DH
    
    mov AL, DL
    mov DL, 10
    div DL
    
    mov BL, AL  ;Resto
    mov BH, AH  ;Parte Alta
    
    call RANDOM_NOVO
    
    mov CL,DL   ;armazena a direcao
     
    cmp cl, 50   ;caso > 50  atribui vertical, caso contrario horizontal
    ja ATT_VERT
    mov cl, 'h'
    jmp FIM_GERA_POSICOES_ALEAT
    
    ATT_VERT:
        mov cl, 'v'    
        
    FIM_GERA_POSICOES_ALEAT:
        pop AX
        
    ret
endp  
;ENTRADA: AL : Indicador da embarcacao
;         BL : Coluna
;         BH : Linha
;         CX : Direcao
ARMAZENA_SEC proc
    push DI
    push AX
    push BX
    push CX
    push DX
             
    xor AH, AH             
    xor DX, DX
    ;Encontra posicao: AL x 2
    mov DI, offset matriz_bot_sec
    mov DH, 3
    mul DH
    
    add DI, AX
    mov AL, BL
    stosb         ;Armazena coluna
    
    mov AL, BH
    stosb         ;Armazena linha
    
    mov AX, CX
    stosb         ;Armazena direcao
    
    pop DX
    pop CX
    pop BX
    pop AX
    pop DI
      
    ret
endp       
       
;metodo responsavel por inicialiar os navios do computador
INICIALIZA_BOT proc
    
    mov BP, offset msg_aguarde
    mov CX, 46
    call MSG_CONSOLE
    
    xor CX, CX
    xor AX, AX
    
    mov CL, 5 ;5 navios
    mov DI, offset matriz_bot
     
    INIT_NAVIOS_BOT:
        push CX
        push AX
        
        call GERA_POSICOES_ALEAT
        
        xor DX, DX
        
        mov DH, 1             ;Indica que e o bot
        call VALIDA_LIMITES
        cmp DL,1              ;Caso retorna 1, ocorreu erro
        jz DESCARTA_POSICAO
        
        ;armazena posicao   
        call ARMAZENA_SEC
        call ARMAZENA_BARCOS
        pop AX
        pop CX 
        inc AX
        
        jmp CONT_NAVIOS_BOT
        ;descarta posicao
        DESCARTA_POSICAO:  
            pop AX
            pop CX
            inc CX
        CONT_NAVIOS_BOT:
            loop INIT_NAVIOS_BOT            
            
    mov BP, offset limpa_console
    mov CX, 70
    call MSG_CONSOLE
    ret        
endp 

TELA_INICIAL proc
    push AX
    push BX
    push CX
    push DX
    
    xor DX, DX
    mov AL, 1
    call TROCA_PAGINA
   
    mov BL, 7   ;cor branca
    mov BH, 1   ; pagina
    mov CX, 412 ;tamanho da string
    
    mov bp, offset moldura_inicio
    call ESC_STRING_VIDEO
    
    mov DL, 35 ;coluna
    mov DH, 11 ;linha
    mov CX, 10 ;tamanho da string
    
    mov BP, offset opcao_start
    call ESC_STRING_VIDEO
       
    mov DL, 38
    inc DH 
    mov CX, 4 
    mov BP, offset opcao_sair
    call ESC_STRING_VIDEO
        
    mov DL, 31    
    mov DH, 11 ;linha  
    call SOLICITAR_OPCAO
    
    cmp DH,12
    je FIM_TELA_INICIAL
    
    cmp DH,11
    je CHAMA_INICIO
    jmp FIM_TELA_INICIAL  
    
    CHAMA_INICIO:
        call NOVO_JOGO
    FIM_TELA_INICIAL:
        push DX
        push CX
        push BX
        push AX
        ret    
endp   
;Metodo que invoca modo DEUS
;Lista os barcos do computador
GODMODE proc
    mov SI, offset matriz_bot_sec
    mov CX, 5
    mov AX, 0
    
    DESENHA_BOT:
        push CX 
        push AX 
        
        mov DX, AX
        
        lodsb
        
        mov BL, AL
        
        lodsb
        
        mov BH, AL
        
        lodsb
        
        mov CL, AL 
        
        mov AH, 1  
        mov AL, DL
        
        call DESENHA_BARCOS
        
        pop AX
        pop CX
        
        inc AX   
        loop DESENHA_BOT
    ret    
endp  

;Inicializa a matriz de tiros com quadrados verdes
MAT_TIROS proc
    push AX
    push BX
    push CX
    push DX    
    
    xor CX, CX
    xor AX, AX 
    
    mov DH, 4   ;linha
    mov BL, 2   ;cor verde
    mov BH, 2   ;pagina 2     
    mov AL, 223 ;caracter    
    
    MAT_TIROS_LINHA:
        mov DL, 35  ;coluna
        inc DH
        
        mov CX, 10
        MAT_TIROS_COLUNA:
            push CX
                    
            mov AL, 223
            mov CX, 1
            call POS_CURSOR
            call ESC_SINGLE_CHAR_VIDEO
            add DL, 2
            
            pop CX
            loop MAT_TIROS_COLUNA             
        
        inc AH    
        cmp AH,10
        jb MAT_TIROS_LINHA
    
    FIM_MAT_TIROS:
        pop DX
        pop CX
        pop BX
        pop AX    
    
    ret    
endp        
   
;Metodo para solicitar ao player o tiro
;  SAIDA: BH = Coluna
;         BL = Linha  
;

SOLICITA_TIRO_PLAYER proc
    push AX
    push CX
    push DX
    
    mov BP, offset str_tiro 
    mov BL, 7               ;cor branca
    mov BH, 2               ;pagina
    mov DL, 22              ;coluna
    mov DH, 18              ;linha         
    mov CX, 4               ;tamanho String 
    call POS_CURSOR                       
                       
    call ESC_STRING_VIDEO    
    
    mov AH, 1                    
    mov BP, offset msg_player1
    call PEDE_INFORMACOES
    mov BL, CL                  
        
    mov AH, 2 
    mov BP, offset msg_player2
    call PEDE_INFORMACOES
    mov BH, CL 
           
    pop DX
    pop CX
    pop AX
    ret    
endp
 
; Metodo para desenhar o tiro na matriz de tiros
;  ENTRADA: CL = Coluna
;           CH = Linha  
;           BL = Cor
;           AL = Caractere
;           DH = 0 - Player 1 - BOT
DESENHA_TIRO proc
    push AX
    push CX
    push DX 
    
    mov BH, AL
    
    mov AL, CL              ;linha
    mov CL, 2               ;
    mul CL                  ;multiplica a linha por 2 pois na coluna cada coluna ocupa 2 espacos
    mov CL, AL
    
    mov AL, BH      
    mov BH, 2               ;pagina
    
    cmp DH, 0
    jz  DESENHA_TIRO_PLAYER
    
    mov DL, 3               ;coluna
    mov DH, 5               ;linha 
        
    jmp CONT_DESENHA_TIRO
    
    DESENHA_TIRO_PLAYER:      
        mov DL, 35              ;coluna
        mov DH, 5               ;linha 
    
    CONT_DESENHA_TIRO:
        add DL, CL
        add DH, CH        
        
        call POS_CURSOR  
          
        call ESC_SINGLE_CHAR_VIDEO
        
        pop DX
        pop CX
        pop AX
        ret    
endp    

;Metodo para atualizar a matriz 'TIROS'
;ENTRADA:   DH = 0 - Player 1 - BOT

ATUALIZA_TIRO proc
    push SI
    push BX
    
    xor BX, BX
    cmp DH, 1
    jz ATUALIZA_TIRO_BOT
    
    mov SI, offset tiros    
    jmp CONT_ATUALIZA_TIRO
    
    ATUALIZA_TIRO_BOT:
        mov SI, offset tiros_bot
    
    CONT_ATUALIZA_TIRO:    
        inc byte ptr [BX + SI]        
        pop BX
        pop SI
    ret    
endp 
;Metodo para atualizar a matriz 'ACERTOS'
;ENTRADA:   DH = 0 - Player 1 - BOT

ATUALIZA_ACERTO proc
    push SI
    
    cmp DH, 1
    jz ATUALIZA_ACERTO_BOT
    
    mov SI, offset acertos
    jmp CONT_ATUALIZA_ACERTO
    
    ATUALIZA_ACERTO_BOT:
        mov SI, offset acertos_bot
        
    CONT_ATUALIZA_ACERTO:        
        inc byte ptr [SI]
    
        pop SI
    ret
endp  
    
;Metodo responsavel por atualizar o placar dos tiros    
; ENTRADA: DL = Coluna
;          DH = Linha            
ATT_PLACAR_TIROS proc 
    push DX
    push DI
    
    mov DI, DX
            
    xor AX, AX 
    mov BH, 2
    call POS_CURSOR
    
    mov DX, [SI]
    mov CL, 10
    mov AL, DL
    div CL        ;divide por 10 para pegar o decimal e o numeral
    
    mov DL, AL
    add DL, '0'
    call ESC_CHAR ;escreve o resto    
    
    mov BH, 2
    mov DX, DI
    
    inc DL
    
    call POS_CURSOR 
    
    mov DL, AH
    add DL, '0'
    
    call ESC_CHAR ;escreve o resto    
          
    pop DI          
    pop DX 
    ret
endp


;Metodo responsavel por atualizar o placar do Player    
;ENTRADA:   DH = 0 - Player 1 - BOT

ATUALIZA_PLACAR proc
    push BX
    push CX
    push DX
    push SI
         
    mov DL, 74;
    
    cmp DH, 1
    jz  ATUALIZA_PLACAR_BOT
    jmp ATUALIZA_PLACAR_PLAYER    
    
    ATUALIZA_PLACAR_BOT:                          
        mov SI, offset tiros_bot
        mov DH, 7
        
        call ATT_PLACAR_TIROS
        
        mov SI, offset acertos_bot
        inc DH
              
        call ATT_PLACAR_TIROS 
        
        mov SI, offset afundados_bot
        inc DH
        
        call ATT_PLACAR_TIROS 
        jmp FIM_ATUALIZA_PLACAR
    
    ATUALIZA_PLACAR_PLAYER:  
        mov SI, offset tiros
        mov DH, 2    
        
        call ATT_PLACAR_TIROS
        
        mov SI, offset acertos
        inc DH
              
        call ATT_PLACAR_TIROS 
        
        mov SI, offset afundados
        inc DH
        
        call ATT_PLACAR_TIROS
        
     FIM_ATUALIZA_PLACAR:    
        pop SI
        pop DX
        pop CX
        pop BX
    ret    
endp 

MSG_REPETIDO proc
    mov BP, offset mensagem_repetido
    mov CX, 68
    call MSG_CONSOLE
    call LER_CHAR 
    cmp AL, CR ; verifica se e ENTER
    jne MSG_REPETIDO
    ret    
endp
 
;Metodo responavel por atualizar o vetor de afundados
;ENTRADA: Posicao do vetor de tiros
;         DH = 0 - Player 1 - BOT

ATT_AFUNDADOS proc
    push CX
    push DI
    push SI
    
    cmp DH, 1
    jz ATT_AFUNDADOS_BOT
    
    mov DI, offset vet_afundados 
    mov SI, offset afundados 
    jmp CONT_ATT_AFUNDADOS
        
    ATT_AFUNDADOS_BOT:
        mov DI, offset vet_afundados_bot
        mov SI, offset afundados_bot
    
    CONT_ATT_AFUNDADOS:        
        mov CX, 5
        
        LOOP_AFUNDADOS:
            cmp byte ptr [DI],0
            jz INC_AFUNDADOS
        
            inc DI
            loop LOOP_AFUNDADOS
       
        jmp FIM_ATT_AFUNDADOS
        INC_AFUNDADOS: 
            inc byte ptr [SI]
            dec byte ptr [DI]
       
        FIM_ATT_AFUNDADOS:
            pop SI
            pop DI
            pop CX
    ret
endp     
     
;Metodo responavel por atualizar o vetor de afundados
;ENTRADA: BX = Deslocamento dentro do vetor
;         DH = 0 - Player 1 - BOT

ATT_VET_AFUNDADOS proc
    push DI
           
    cmp DH, 1
    jz ATT_VET_AFUND_BOT
    
    mov DI, offset vet_afundados
    jmp CONT_ATT_VET_AFUND
    
    ATT_VET_AFUND_BOT:        
        mov DI, offset vet_afundados_bot
        
    CONT_ATT_VET_AFUND:
        cmp byte ptr [BX + SI], 'A'
        jz ATT_PORTA_AVIAO
        
        cmp byte ptr [BX + SI], 'B'
        jz ATT_GUERRA
        
        cmp byte ptr [BX + SI], 'S'
        jz ATT_SUBMARINO
        
        cmp byte ptr [BX + SI], 'D'
        jz ATT_DESTROYER
        
        cmp byte ptr [BX + SI], 'P'
        jz ATT_PATRULHA  
        
        ATT_PORTA_AVIAO:
            jmp FIM_VET_FUNDADOS
            
        ATT_GUERRA:
            inc DI
            jmp FIM_VET_FUNDADOS
            
        ATT_SUBMARINO:
            add DI, 2
            jmp FIM_VET_FUNDADOS
                
        ATT_DESTROYER:
            add DI, 3
            jmp FIM_VET_FUNDADOS
        ATT_PATRULHA:           
            add DI, 4
            
        FIM_VET_FUNDADOS:
            dec byte ptr [DI]
            pop DI
            ret   
endp
      
; Metodo para verificar o tiro do jogador
;  ENTRADA: BL = Coluna
;           BH = Linha
;           SI = Endereco do respectivo vetor (matriz_player ou matriz_bot)
;           DH = 0 - Player 1 - BOT 
;   SAIDA:  DL = 1 - Tiro repetido, tente novamente
;              = 0 - Tiro acertou alguma coisa   
VERIFICA_TIRO proc
    push AX
    push BX
    push CX
    
    xor AX, AX 
    xor DL, DL
    mov CX, BX
          
    mov AL, BH          ;linha
    mov BH, 10          ;
    mul BH              ;multiplica a linha por 10 para encontrar posicao no vetor
    add AL, BL          ;adiciona a coluna,
      
    mov BX, AX   
    
    cmp byte ptr [BX + SI], 'x'
    jz  TIRO_REPETIDO
    
    cmp byte ptr [BX + SI], 'o'
    jz  TIRO_REPETIDO
    
    cmp byte ptr [BX + SI], 0
    jne  ACERTOU
    
    jmp ERROU 
    
    TIRO_REPETIDO:
        mov DL, 1         ;Tiro repetido
        cmp DH, 1         ;caso for bot nao lista a mensagem
        jz FIM_SEM_ATT
         
        call MSG_REPETIDO ;caso for player, lista a mensagem
        jmp FIM_SEM_ATT
    
    ACERTOU:  
        call ATT_VET_AFUNDADOS
        call ATT_AFUNDADOS
        
        mov byte ptr [BX + SI], 'o'
        mov AL, 'o' 
        mov BL, 2h          ;cor verde  
    
        call ATUALIZA_ACERTO
        call DESENHA_TIRO
        
        jmp FIM_VERIFICA_TIRO
        
    ERROU:
        mov byte ptr [BX + SI], 'x'
        mov BL, 4h          ;cor vermelha
        mov AL, 'x'
        
    call DESENHA_TIRO        
              
    FIM_VERIFICA_TIRO:
        call ATUALIZA_TIRO
        call ATUALIZA_PLACAR 
        
    FIM_SEM_ATT:    
        
        pop CX
        pop BX
        pop AX
    ret    
endp
; PROC responsavel por incializar o vetor 'afundados' tanto do player quanto do bot
;
INIT_AFUNDADOS proc
    push AX
    push DI 
    
    mov DI, offset vet_afundados
    
    stosb   ;5
    dec AX  
    stosb   ;4
    dec AX  
    stosb   ;3  
    stosb   ;3
    dec AX  
    stosb   ;2
    
    mov DI, offset vet_afundados_bot
    mov AX, 5
    
    stosb   ;5
    dec AX  
    stosb   ;4
    dec AX  
    stosb   ;3  
    stosb   ;3
    dec AX  
    stosb   ;2
    
    pop DI
    pop AX
    ret
endp 
;Metodo para listar o ultimo tiro feito pelo bot
; ENTRADA : BL = Indica a coluna
;           BH = Indica a linha     
ULTIMO_TIRO proc
    push DX
    push CX
    push BX
    
    mov CX, BX    
    ;BH = Page Number, DH = Row, DL = Column
    mov BH, 2
    mov DH, 10
    mov DL, 74     
    call POS_CURSOR
    
    mov DL, CL 
    add DL, '0'
    call ESC_CHAR
    mov DL, 'x'
    call ESC_CHAR
    mov DL, CH 
    add DL, '0'
    call ESC_CHAR
     
    pop BX 
    pop CX
    pop DX
    ret    
endp
;Metodo que gera um nro aleatorio do tiro do bot
;Tambem desenha na tela o tiro    
TIRO_BOT proc 
    push SI
    push DX
    
    REPETE_TIRO:
        call GERA_POSICOES_ALEAT
    
        mov SI, offset matriz_player
        mov DH, 1
        call VERIFICA_TIRO
    
        cmp DL, 1
        jz REPETE_TIRO
        
    call ULTIMO_TIRO
    pop DX
    pop SI
    ret
endp

;Metodo que solicitar o tiro do player
;Tambem desenha na tela o tiro 

TIRO_PLAYER proc
    push DX
    push SI
    
    REPETE_TIRO_PLAYER:
        mov BP, offset limpa_console
        mov CX, 73
        call MSG_CONSOLE
        
        call SOLICITA_TIRO_PLAYER
             
        sub BL, '0'     
        sub BH, '0'     
    
        mov DH, 0 
        mov SI, offset matriz_bot
        call VERIFICA_TIRO
        cmp DL, 1
        jz REPETE_TIRO_PLAYER
    
    pop SI
    pop DX
    ret
endp    

;Metodo para validar o tiro do BOT
; ENTRADA:BL = Indica a coluna
;         BH = Indica a linha
;   SAIDA:DH = (1) posicao ja ocupada;
;            = (0) posicao nao ocupada
VALIDA_TIRO_BOT proc
    push AX
    push BX
    push CX
    
    xor AX, AX
    
    mov SI, offset vet_tiros_bot    
    
    mov AL, BH          ;linha
    mov BH, 10          ;
    mul BH              ;multiplica a linha por 10 para encontrar posicao no vetor
    add AL, BL 
    
    mov BX, AX
      
    cmp byte ptr [SI + BX], 1
    jz  TIRO_REPETIDO_BOT
    jmp ARMAZENA_TIRO_BOT
    
    TIRO_REPETIDO_BOT:
        mov DH, 1
        jmp FIM_VALIDA_TIRO_BOT
        
    ARMAZENA_TIRO_BOT:
        mov DH, 0
        inc byte ptr [SI + BX]    
    
    FIM_VALIDA_TIRO_BOT:
        pop CX
        pop BX
        pop AX
    ret
endp 
;Metodo responsavel por chamar o DESENHA_TIRO porem sem impactar na CX
CHAMA_DESENHA_TIRO proc 
    push CX
    
    mov DH, 1           ;indica que e o bot
    mov CX, BX
    mov AL, 'x'  
    mov BL, 2h          ;cor verde  
        
    call DESENHA_TIRO
    
    pop CX    
    ret
endp 
;Neste metodo e feito toda a limpeza da matriz de tiros
RESET_MATRIZ_TIROS proc
    push DI
    push CX
    push AX
     
    mov CX, 99  ;99 posicoes da matriz
    xor AX, AX
    mov DI, offset matriz_player 
               
    LOOP_RESET_MAT_PLAYER:
        
        stosb
        
        loop LOOP_RESET_MAT_PLAYER
        
    mov CX, 99  ;99 posicoes da matriz
    mov DI, offset matriz_bot 
               
    LOOP_RESET_MAT_BOT:        
        stosb
        
        loop LOOP_RESET_MAT_BOT     
               
    pop AX
    pop CX
    pop DI
    ret
endp
;Metodo responsavel por recolocar os barcos na tela no modo 'reiniciar jogo'
RESET_BARCOS_PLAYER proc
    push AX
    push CX
    push DX
    push SI
    
    mov CX, 5 ;5 navios
    mov AX, 0 ;indicador do barco
    mov SI, offset vet_matriz_player
    mov DI, offset matriz_player
    
    INIT_BARCOS_RESET:
        push CX
        push AX
        
        mov DX, AX

        lodsw
        mov BX, AX
        lodsw
        mov CX, AX              
                   
        mov AL, DL
        call ARMAZENA_BARCOS                   
        mov AH, 0
        call DESENHA_BARCOS
               
        pop AX
        pop CX
        inc AX
        loop INIT_BARCOS_RESET    
    
    pop SI
    pop DX
    pop CX
    pop AX
    ret    
endp
    
;Metodo para inicializar os barcos do player fixo   
INIT_BARCOS_PLAYER_FIXO proc
    push AX
    push CX
    push DI
    
    xor CX, CX  
    xor AX, AX
    
    mov CL, 5 ;5 navios
    mov DI, offset matriz_player
    
    INIT_BARCOS:
        push CX
        push AX
        
        call GERA_POSICAO_FIXA
        ;call GERA_POSICOES_ALEAT
        call ARMAZENA_BARCOS 
        call ARMAZENA_BARCOS_VET  
        
        mov AH, 0
        call DESENHA_BARCOS
        
        pop AX
        pop CX
        inc AX
    loop INIT_BARCOS    
    
    pop DI
    pop CX
    pop AX
    ret
endp 
;ENTRADA: AL : Indicador da embarcacao
;         BL : Coluna
;         BH : Linha
;         CX : Direcao
ARMAZENA_BARCOS_VET proc
    push DI
    push AX
    push CX
    push DX    
    
    xor AH, AH
    xor DX, DX
    
    mov DI, offset vet_matriz_player
    mov DL, 4
    mul DL
    add DI, AX 
    
    mov AX, BX
    stosw
    mov AX, CX
    stosw
    
    pop DX
    pop CX
    pop AX
    pop DI
    
    ret    
endp

;metodo para validar as posicoes 
;BH = LINHA
;BL = COLUNA
GERA_POSICAO_FIXA proc
    
    cmp AL, 0
    jz  POSICAO_0
    cmp AL, 1
    jz POSICAO_1
    cmp AL, 2
    jz POSICAO_2
    cmp AL, 3
    jz POSICAO_3
    cmp AL, 4
    jz POSICAO_4
    
    POSICAO_0:    
        mov BL, 02;
        mov BH, 04;
        mov CX, 'v'
        jmp FIM_GERA_POS    
        
    POSICAO_1:    
        mov BL, 01;
        mov BH, 04;
        mov CX, 'v'
        jmp FIM_GERA_POS 
        
    POSICAO_2:    
        mov BL, 06;
        mov BH, 09;
        mov CX, 'h'
        jmp FIM_GERA_POS
            
    POSICAO_3:    
        mov BL, 05;
        mov BH, 03;
        mov CX, 'v'
        jmp FIM_GERA_POS
        
    POSICAO_4:    
        mov BL, 04;
        mov BH, 07;
        mov CX, 'v'
        jmp FIM_GERA_POS
    
    GERA_ALEAT: 
        call GERA_POSICOES_ALEAT
         
    FIM_GERA_POS:    
        ret    
endp 
;Metodo para listar o fim de jogo 
  
TELA_FIM_JOGO proc
    mov AL, 3
    call TROCA_PAGINA
    
    mov BP, offset msg_fim_jogo
    mov DL, 34 ;coluna
    mov DH, 8  ;linha  
    mov BL, 7  ;cor branca
    mov BH, 3  ;pagina 2
    mov CX, 11 ;tamanho da string
    
    call ESC_STRING_VIDEO
    
    mov BP, offset msg_venceu
    mov CX, 11 ;tamanho da string
    inc DH    
    
    call ESC_STRING_VIDEO
    
    
    mov BP, offset msg_novo_jogo
    mov CX, 11 ;tamanho da string
    add DH, 2
    inc DL 
    
    call ESC_STRING_VIDEO
    
    mov BP, offset msg_reiniciar
    mov CX, 14 ;tamanho da string
    inc DH
    sub DL, 2
    
    call ESC_STRING_VIDEO
             
    call SOLICITAR_OPCAO
    
    cmp DH, 11
    jz CHAMA_NOVO_JOGO 
    ;caso for diferente de 12
    call REINICIAR_JOGO
    ret 
     
    CHAMA_NOVO_JOGO:
        call NOVO_JOGO
    ret    
endp

;Neste metodo eh apresentado o menu do fim do jogo com as opcoes
; Novo Jogo e Reiniciar Jogo
SOLICITAR_OPCAO proc
    push AX    
    
    mov DL, 31    
    call INDICADOR_OPCAO
    
    LER_TECLA: 
        mov DL, 31
        call LER_KEY
        
        ;cmp AH, 0x50
        cmp AH, 80
        je DOWN_ARROW
        
        ;cmp AH, 0x48
        cmp AH, 72
        je UP_ARROW  
        
        ;cmp AH, 0x1C
        cmp AH, 28  
        je FIM_SOLICITAR_OPCAO
         
        jmp LER_TECLA 
        UP_ARROW:
            cmp DH,11
            jbe LER_TECLA
            
            dec DH            
            jmp FIM_LER_TECLA
            
        DOWN_ARROW:
            cmp DH,12
            jae LER_TECLA
            
            inc DH
         
        FIM_LER_TECLA:    
            call INDICADOR_OPCAO
        jmp LER_TECLA
        
        FIM_SOLICITAR_OPCAO:    
    pop AX
    ret        
endp

;Neste metodo eh feito o posicionamento e a deslocacao do indicador de menu
;  
INDICADOR_OPCAO proc
    push DX
    push CX
      
    mov CH, DH
      
    cmp DH, 12
    jz  APAGA_CIMA
    
    inc DH    
    jmp LIMPA_INDICADOR    
    
    APAGA_CIMA:
        dec DH
    
    LIMPA_INDICADOR:
        call POS_CURSOR ;BH = Page Number, DH = Row, DL = Column          
        mov CL, DL
              
        dec DH          
        mov DL, 32
        call ESC_CHAR
    
    mov DX, CX
    call POS_CURSOR ;BH = Page Number, DH = Row, DL = Column
    
    mov DL, 26    
    call ESC_CHAR
    
    mov DL, 31
    call POS_CURSOR ;BH = Page Number, DH = Row, DL = Column          
        
    pop CX
    pop DX
    ret
endp    

; Metodo apenas para testes que faz:
;   Inicializa 'variaveis' auxiliares
;   Monta os barcos fixos na tela
;   Gera o tiro aleatorio do bot e o desenha em tela
INICIO_JOGO_BOT proc
    call INIT_AFUNDADOS
    call INIT_BARCOS_PLAYER_FIXO
        
    mov SI, offset tiros_bot
    lodsb
     
    INIT_TIROS_BOT:
        call TIRO_BOT
        
        lodsb       
        cmp AX,99       ;caso for menor que 99 (tiros), repete
        jb INIT_TIROS_BOT
    ret
endp     

;Metodo responsavel por inicializar as matrizes de tiros
INIT_TIROS proc
    push AX
    push CX
    push DI
                  
    xor AX, AX 
    mov CX, 6
    
    mov DI, offset tiros
    
    REPETE_INIT_TIROS:
        stosb
    
        loop REPETE_INIT_TIROS
    
    pop DI
    pop CX
    pop AX
    ret       
endp

;Metodo que faz:
;   Inicializa a matriz de tiro
;   Inicializa 'variaveis' auxiliares do processo
;   Solicita tiro do player e o desenha na tela
;   Gera o tiro aleatorio do bot e o desenha em tela
INICIO_JOGO proc
    call MAT_TIROS
    ;call GODMODE
    call INIT_AFUNDADOS 
    call INIT_TIROS
                             
    mov SI, offset afundados
    mov DI, offset afundados_bot
     
    mov byte ptr [DI],0
    mov byte ptr [SI],0
                                 
    REPETE: 
        mov BP, offset limpa_console
        mov CX, 70
        call MSG_CONSOLE
         
        call TIRO_PLAYER
        
        cmp byte ptr [SI],5
        jz FIM_JOGO_PLAYER

        call TIRO_BOT
        
        cmp byte ptr [DI],5
        jz FIM_JOGO_BOT
        
        jmp REPETE
        
    FIM_JOGO_PLAYER:
        mov BP, offset msg_fim_player
        jmp FIM_JOGO            
    
    FIM_JOGO_BOT:
        mov BP, offset msg_fim_bot    
           
    FIM_JOGO:
        mov CX, 52
        call MSG_CONSOLE
        call LER_CHAR
        call TELA_FIM_JOGO
        ret    
endp 
;Neste metodo e feito todo o processo de inicializacao da pagina princial
;  Troca a pagina
;  Inicializa a moldura
;  Inicializa a matriz do adversario

INIT_TELA_PRINCIPAL proc
    push AX
    
    mov AL, 2           ;troca para a pagina 2
    call TROCA_PAGINA
    call LISTA_MOLDURA_PRINCIPAL    
    call LISTA_CONSOLE 
    call MAT_TIROS
    
    pop AX
    ret    
endp
;Neste metodo e feito todo o processo de um novo jogo
;  Inicializa a tela principal
;  Inicial os barcos do jogador
;  Inicializa os barcos do BOT
NOVO_JOGO proc    
    call INIT_TELA_PRINCIPAL 
    call RESET_MATRIZ_TIROS
    call INIT_BARCOS_PLAYER
    call INICIALIZA_BOT
    call INICIO_JOGO 
    call INICIO_JOGO_BOT    
    ret
endp
;Neste metodo e feito todo o processo de um novo jogo
;  Inicializa a tela principal
;  Inicializa os barcos do BOT
REINICIAR_JOGO proc
    call INIT_TELA_PRINCIPAL
    call RESET_MATRIZ_TIROS
    call RESET_BARCOS_PLAYER
    call INICIALIZA_BOT
    call INICIO_JOGO 
    call INICIO_JOGO_BOT    
    ret    
endp    
        
inicio:  
   mov AX, @DATA
   mov DS, AX 
   mov ES, AX
    
   call TELA_INICIAL
   ;call TELA_FIM_JOGO          
     
   mov ah, 4ch
   mov al, 0
   int 21h

end inicio    
