;99235 | 99205


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                              CONSTANTS                                  ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;


TERM_READ       EQU     FFFFh
TERM_WRITE      EQU     FFFEh
TERM_STATUS     EQU     FFFDh
TERM_CURSOR     EQU     FFFCh
TERM_COLOR      EQU     FFFBh


; 7 segment display
DISP7_D0        EQU     FFF0h
DISP7_D1        EQU     FFF1h
DISP7_D2        EQU     FFF2h
DISP7_D3        EQU     FFF3h
DISP7_D4        EQU     FFEEh
DISP7_D5        EQU     FFEFh


; timer
TIMER_CONTROL   EQU     FFF7h
TIMER_COUNTER   EQU     FFF6h
TIMER_SETSTART  EQU     1
TIMER_SETSTOP   EQU     0
TIMERCOUNT_INIT EQU     1 

;MASK
INT_MASK        EQU     FFFAh
INT_MASK_VAL    EQU     8009h ; 1000 0000 0000 1001 b timer, key up, key zero


STACKBASE       EQU     8000h
constante       EQU     29491
altura_max      EQU     7
altura_inicial  EQU     9608h
altura_chao     EQU     9700h
altura_chao_din EQU     9708h
valor_x         EQU     7


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                             VARIABLES                                   ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

ORIG            6000h

SCORE_D0        WORD    0
SCORE_D1        WORD    0
SCORE_D2        WORD    0
SCORE_D3        WORD    0
SCORE_D4        WORD    0
SCORE_D5        WORD    0

TIMER_COUNTVAL  WORD    TIMERCOUNT_INIT
TIMER_TICK      WORD    0               
                                         

inicio_jogo     WORD    0

key_up_var      WORD    0


x               WORD    valor_x ; variavel global

estado_do_salto WORD    0
subir_descer    WORD    0
altura_atual    WORD    altura_inicial
contador        WORD    0 ; o contador tera tambem a funcao de altura atual so que de 1-7
altura_cato     WORD    0

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                               STRINGS                                   ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

str_gameover    STR     'G A M E   O V E R',0
str_gamestart   STR     'P R E S S  "0"  T O  S T A R T',0
str_gamerestart STR     'P R E S S  "0"  T O  R E S T A R T',0

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                    vetor, dimensao do vetor & stack                     ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

                ORIG    0000h
                
colunas         TAB     80
dim             EQU     79


                MVI     R6, STACKBASE
                                
                
;-------------------------------------------------------------------------;
;                         PRESS "0" TO START                              ;
;-------------------------------------------------------------------------;
         
                MVI     R1, str_gamestart
                MVI     R3, 9119h
  ;loop para criar a mensagem. Loop acaba quando a string chega a 0
start_loop:       
                LOAD    R2, M[R1]
                
                CMP     R2, R0
                BR.Z    .saida_start
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                LOAD    R4, M[R1] 
                MVI     R2, TERM_WRITE ; escrever na nova linha
                STOR    M[R2],R4
                
                INC     R3
                INC     R1
                
                BR      start_loop
                
;-------------------------------------------------------------------------;
;                               MASK                                      ;
;-------------------------------------------------------------------------;
.saida_start:

                ; CONFIGURE TIMER ROUNTINES
                ; interrupt mask
                MVI     R1,INT_MASK
                MVI     R2,INT_MASK_VAL
                STOR    M[R1],R2
                ; enable interruptions
                ENI
                
;-------------------------------------------------------------------------;
;                             wait for b0                                 ;
;-------------------------------------------------------------------------;


                
loop1:          MVI     R1, inicio_jogo
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.NZ   full_reset
                BR      loop1

;-------------------------------------------------------------------------;
;          reset whole program for next cicle after restarting            ;
;-------------------------------------------------------------------------;
 
full_reset:
                ;reset score

                MVI     R1, SCORE_D0
                STOR    M[R1], R0
                MVI     R1, SCORE_D1
                STOR    M[R1], R0
                MVI     R1, SCORE_D2
                STOR    M[R1], R0
                MVI     R1, SCORE_D3
                STOR    M[R1], R0
                MVI     R1, SCORE_D4
                STOR    M[R1], R0
                MVI     R1, SCORE_D5
                STOR    M[R1], R0
                
                ;reset displays
                
                MVI     R1, DISP7_D0
                STOR    M[R1], R0
                MVI     R1, DISP7_D1
                STOR    M[R1], R0
                MVI     R1, DISP7_D2
                STOR    M[R1], R0
                MVI     R1, DISP7_D3
                STOR    M[R1], R0
                MVI     R1, DISP7_D4
                STOR    M[R1], R0
                MVI     R1, DISP7_D5
                STOR    M[R1], R0
                
                ;reset timer tick
                
                MVI     R1, TIMER_TICK
                STOR    M[R1], R0
                
                ;reset key up value
                
                MVI     R1, key_up_var
                STOR    M[R1], R0
                
                ;reset jump variables
                
                MVI     R1, estado_do_salto
                STOR    M[R1], R0
                
                MVI     R1, subir_descer
                STOR    M[R1], R0
                
                MVI     R1, altura_atual
                MVI     R2, altura_inicial
                STOR    M[R1], R2
                
                MVI     R1, contador
                STOR    M[R1], R0
                
               ;; reset vetor - ciclo que percorre todo o vetor
                
                MVI     R1, colunas
                MVI     R2, 80
               
               
reset_vetor:    CMP     R2, R0
                BR.Z    out
                
                STOR    M[R1], R0
                
                INC     R1
                DEC     R2
                
                BR      reset_vetor
                
out:            ;reset terminal - ciclo que percorre todo o terminal
                
                MOV     R1, R0
                MVI     R5, FFFFh
                
reset_terminal:   
                CMP     R1, R5
                BR.Z    timer

                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R1
                MVI     R4, ' ' 
                MVI     R2, TERM_WRITE 
                STOR    M[R2],R4
                
                INC     R1
                
                BR      reset_terminal
                
;-------------------------------------------------------------------------;
;                          resets are finished                            ;
;-------------------------------------------------------------------------;                
                                 

;-------------------------------------------------------------------------;
;                              start timer                                ;
;-------------------------------------------------------------------------;


timer:
      
                ; START TIMER
                MVI     R2,TIMERCOUNT_INIT
                MVI     R1,TIMER_COUNTER
                STOR    M[R1],R2          ; set timer to count 1x100ms
                MVI     R1,TIMER_TICK
                STOR    M[R1],R0          ; clear all timer ticks
                MVI     R1,TIMER_CONTROL
                MVI     R2,TIMER_SETSTART
                STOR    M[R1],R2          ; start timer                
                             
;-------------------------------------------------------------------------;
;                          Wait for timer event                           ;
;-------------------------------------------------------------------------;



loop2:         ; WAIT FOR EVENT (TIMER)
                MVI     R5,TIMER_TICK
                LOAD    R1,M[R5] 
                CMP     R1, R0
                BR.NZ   main
                BR      loop2 
                
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                                 MAIN                                    ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
               


main:
                ; DEC TIMER_TICK
                MVI     R2,TIMER_TICK
                DSI     ; critical region: if an interruption occurs, value might become wrong
                LOAD    R1,M[R2]
                DEC     R1
                STOR    M[R2],R1
                ENI
                
;-------------------------------------------------------------------------;
;                         DRAW DINO - line 378                            ;
;-------------------------------------------------------------------------;
                
                
                JAL     draw_dino
                
;-------------------------------------------------------------------------;
;                     ATUALIZA JOGO - line 576                            ;
;-------------------------------------------------------------------------;

                

                MVI     R1, colunas ; 1º parametro para a funcao atualizajogo
                MVI     R2, dim ; 2º para metro para a funcao atualizajogo
                
                JAL     atualizajogo
                

                
;-------------------------------------------------------------------------;
;                       GERACATO  - line 935                              ;
;-------------------------------------------------------------------------;

                
                
                MVI     R2, x 
                LOAD    R1, M[R2] ; 1º parametro da funcao geracato, variavel x
                MVI     R2, 4 ; 2º parametro da funcao geracato, altura max potencia base 2
                
                
                JAL     geracato
                
;-------------------------------------------------------------------------;
;                        SCORE - line 1000                                ;
;-------------------------------------------------------------------------;

                
                
                JAL     SCORE
                
                
;-------------------------------------------------------------------------;
;                      PROCESS KEY UP - line 427                          ;
;-------------------------------------------------------------------------;

                
                MVI     R1, key_up_var                       
                LOAD    R1, M[R1]
                CMP     R1, R0
                JAL.NZ  process_key_up ; se foi pressionada uma key salta para a funcao process_char2
                
                
;-------------------------------------------------------------------------;
;                           SALTO - line 454                              ;
;-------------------------------------------------------------------------;

                
                
                
                MVI     R1, estado_do_salto ;; Se o estado do salto for 1 ha salto
                LOAD    R2, M[R1]
                CMP     R2, R0
                JAL.NZ  SALTO  ; se houver salto ira tratar dele
                
;-------------------------------------------------------------------------;
;                         COLISAO - line 849                              ;
;-------------------------------------------------------------------------;

                
                JAL     COLISAO
                                                
                
                BR      loop2 ; back to waiting for timer event
                
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
;                              END MAIN                                   ;
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;



;-------------------------------------------------------------------------;
;                              DRAW DINO                                  ;
;-------------------------------------------------------------------------;


draw_dino: 
;; Aqui ha um reset total do terminal para preparar a nova criacao de terreno
;; do novo loop do programa

                MOV     R1, R0
                MVI     R5, FFFFh
                
reset_terminal1:   
                CMP     R1, R5
                BR.Z    sair_draw_dino

                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R1
                MVI     R4, ' ' 
                MVI     R2, TERM_WRITE 
                STOR    M[R2],R4
                
                INC     R1
                
                BR      reset_terminal1

; apos o fim do loop e desenhado o dinossauro na posicao da altura 
; em que se encontra no momento do novo loop

sair_draw_dino: 
                MVI     R2, TERM_CURSOR
                MVI     R3, altura_atual
                LOAD    R3, M[R3]
                STOR    M[R2], R3
                MVI     R1, 'T'
                MVI     R2, TERM_WRITE
                STOR    M[R2],R1
                
                MVI     R2, TERM_CURSOR
                MVI     R4, 0100h
                SUB     R3, R3, R4
                STOR    M[R2], R3
                MVI     R1, 'o'
                MVI     R2, TERM_WRITE
                STOR    M[R2], R1
                
                JMP     R7


                
;-------------------------------------------------------------------------;
;                            PROCESS KEY UP                               ;
;-------------------------------------------------------------------------;
                
process_key_up:
                DSI
                MVI     R1, key_up_var
                STOR    M[R1], R0     ; key_up_var = 0 permitir reset key up
                ENI
                
                
                MVI     R1, estado_do_salto
                LOAD    R2, M[R1]
                CMP     R2, R0
                JMP.NZ  R7 ; se o salto estiver a decorrer volta para a main
                ; senao, se a key pressionada for key up, ira saltar 
                
.salto:         MVI     R1, estado_do_salto
                MVI     R2, 1
                STOR    M[R1], R2 ; indica que foi iniciado salto
                
                MVI     R1, subir_descer
                STOR    M[R1], R2       ; indica que o dino esta a subir
                
                JMP     R7
                
;-------------------------------------------------------------------------;
;                                 SALTO                                   ;
;-------------------------------------------------------------------------;
                
                
SALTO:          DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                DEC     R6
                STOR    M[R6], R5 ; PUSH R5

                ; VERIFICAR SE O DINO ESTA A SUBIR OU DESCER
                
                MVI     R5, subir_descer
                LOAD    R4, M[R5]
                
                CMP     R4, R0 ; se a variavel subir_descer estiver em 0 o dino esta a descer
                BR.Z    descer
                
                
;                -------
;                 SUBIR  
;                -------
                
                MVI     R4, 0100h ; serve para aumentar a altura do salto
                
                MVI     R5, altura_atual
                LOAD    R3, M[R5]
                
                SUB     R3, R3, R4 ; subir uma linha
                
                STOR    M[R5], R3 ; atualizar a variavel
                                  ; com o valor da altura atual
                
                
                
                MVI     R5, contador
                ; contador para atingir altura maxima
                
                LOAD    R1, M[R5]
                INC     R1
                STOR    M[R5], R1 ; aumentar contador e guardar em memoria
                
                
                MVI     R5, altura_max
                CMP     R1, R5 ; se o contador ultrapassar a altura max sai
                BR.Z    sair_do_salto_subida
                
                
               ; POP R4 e R5 
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7
                
                
sair_do_salto_subida:
                MVI     R1, subir_descer
                STOR    M[R1], R0
                ; mudar o valor da variavel subir_descer
                ; inicio da descida
                
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6] ; POP R5 e R4
                INC     R6
                
                JMP     R7
                
;                --------
;                 DESCER  
;                --------

descer:      
               
               
                MVI     R4, 0100h ; serve para diminuir a altura do salto
                
                MVI     R5, altura_atual
                LOAD    R3, M[R5]
                
                ADD     R3, R3, R4 ; descer uma linha
                
                STOR    M[R5], R3 ; atualizar a variavel
                                  ; com o valor da altura atual
                
                MVI     R5, contador
                ; contador para atingir a altura do chao descrescente                
                LOAD    R1, M[R5]
                DEC     R1
                STOR    M[R5], R1 ; diminuir contador e guardar em memoria
                
                CMP     R1, R0 ; se o contador chegar a zero sai
                BR.Z    alterar_estado_salto
                
                
sair_salto_descida:     
                ; SAIR DA ROTINA SALTO
                ; POP R5 e R4
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7
                
                
alterar_estado_salto:

                ;; FINALIZAR SALTO

                MVI     R1, estado_do_salto
                MOV     R2, R0 ; deixa de existir salto
                STOR    M[R1], R2
                BR      sair_salto_descida
                
                ; se a descida estiver concluida
                ; a variavel estado_do_salto volta ao valor 0
                ; o que indica que deixa de haver salto
                
;-------------------------------------------------------------------------;
;                            ATUALIZA JOGO                                ;
;-------------------------------------------------------------------------;
  
atualizajogo:   DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                DEC     R6
                STOR    M[R6], R5 ; PUSH R5

                MVI     R4, 0
                MVI     R5, 1
;R4 e R5 vão tomar os valores 0 e 1 para percorrer todo o vetor e R5 e o valor seguido de R4               

.loop:          DEC     R6
                STOR    M[R6], R2 ; PUSH R2
                
                
                DEC     R6
                STOR    M[R6], R7 ; PUSH R7
                
;-------------------------------------------------------------------------;
;               CRIA_TERRENO - AUX FUNCTION - line 629                    ;
;-------------------------------------------------------------------------;         
          
                JAL     CRIA_TERRENO ; salta para a funcao de criacao de terreno
                
                LOAD    R7, M[R6] ; POP R7
                INC     R6
                         
                LOAD    R2, M[R5]
                STOR    M[R4], R2 ; aqui é carregado em R4 o valor de memoria de R5
                                  ; sendo que a os valores andam para tras uma posicao
                LOAD    R2, M[R6]
                INC     R6       ; POP R2
                
                CMP     R5, R2 ; se R5 for igual à 80ª posicao, ja percorreu todo o vetor
                BR.Z    .return_atualizajogo ; e vamos querer potencialmente gerar um cato na posicao a seguir
                     
                INC     R4 ; 
                INC     R5 ; caso nao tenha ainda sido atingido o final do vetor
; continua a arrastamento de cada valor uma "casa" para tras                
                
                BR      .loop ; salta para loop até atingir a dim do vetor
                
.return_atualizajogo:

                LOAD    R5, M[R6] ; POP R5
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                
                JMP     R7 ; back to main
                        
;-------------------------------------------------------------------------;
;                       CRIA_TERRENO - AUX FUNCTION                       ;
;-------------------------------------------------------------------------;         

CRIA_TERRENO:   DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3        ; PUSH DE TODOS OS REGISTOS 
                DEC     R6
                STOR    M[R6], R4        ; DE FORMA A GARANTIR NAO PERDER ARGUMENTOS
                DEC     R6
                STOR    M[R6], R5        ; NESTA FUNCAO AUXILIAR
                DEC     R6
                STOR    M[R6], R7
                
            ; R4 corresponde a posicao do vetor que ira ser updated  
    
                MVI     R2, altura_chao ; R2 = 9700h
                ADD     R3, R4, R2 ; R3 = [0, 80] + 9700h
                
        ;ja que R4 correspondera a uma das 80 posicoes do vetor
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '_'
                MVI     R2, TERM_WRITE ; escrever na nova coluna
                STOR    M[R2],R1       ; o chao       

        ; consoante o valor de memoria que se encontra na posicao do vetor
        ; variando de 1 ate a altura maxima do cato, 4
                
                LOAD    R1, M[R4] ; R1 terá o valor da altura do cato
                
                MVI     R2, 1
                CMP     R1, R2
                BR.Z    .altura_um
                
                MVI     R2, 2
                CMP     R1, R2
                BR.Z    .altura_dois
                
                MVI     R2, 3
                CMP     R1, R2
                BR.Z    .altura_tres
                
                MVI     R2, 4
                CMP     R1, R2
                BR.Z    altura_quatro
                
        ; Caso a altura do cato seja 0, ira saltar para o restore context
                
                JMP     restore_context
                
.altura_um:               
                MVI     R2, altura_chao
                MVI     R3, 0100h
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 1
                STOR    M[R2],R1
                
                
                JMP     restore_context
                
                
.altura_dois:   
                MVI     R2, altura_chao
                MVI     R3, 0100h
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 1
                STOR    M[R2],R1

                
                MVI     R2, altura_chao
                MVI     R3, 0100h
                ADD     R3, R3, R3
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 2
                STOR    M[R2],R1

                
                JMP     restore_context
                
.altura_tres:
              
                MVI     R2, altura_chao
                MVI     R3, 0100h
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 1
                STOR    M[R2],R1

                
                MVI     R2, altura_chao
                MVI     R3, 0100h
                ADD     R3, R3, R3
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 2
                STOR    M[R2],R1

                
                MVI     R2, altura_chao
                MVI     R3, 0100h
                ADD     R5, R3, R3
                ADD     R5, R5, R3
                SUB     R3, R2, R5
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 3
                STOR    M[R2],R1
                
                JMP     restore_context
                
altura_quatro:  
                MVI     R2, altura_chao
                MVI     R3, 0100h
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 1
                STOR    M[R2],R1

                
                MVI     R2, altura_chao
                MVI     R3, 0100h
                ADD     R3, R3, R3
                SUB     R3, R2, R3
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 2
                STOR    M[R2],R1

                
                MVI     R2, altura_chao
                MVI     R3, 0100h
                ADD     R5, R3, R3
                ADD     R5, R5, R3
                SUB     R3, R2, R5
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 3
                STOR    M[R2],R1


                MVI     R2, altura_chao
                MVI     R3, 0100h
                ADD     R5, R3, R3
                ADD     R5, R5, R3
                ADD     R5, R5, R3
                SUB     R3, R2, R5
                ADD     R3, R3, R4
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                MVI     R1, '|'
                MVI     R2, TERM_WRITE ; escrever na nova linha altura 4
                STOR    M[R2],R1
                
                
                JMP     restore_context 
                
restore_context:

        ; reposicao do contexto de forma a voltar a funcao atualizajogo
        ; com os parametros iniciais antes de entrar nesta funcao auxiliar
        
                LOAD    R7, M[R6]
                INC     R6
                
                LOAD    R5, M[R6]
                INC     R6
                LOAD    R4, M[R6]
                INC     R6
                LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                
                JMP     R7 ; regressar a atualizajogo - line 
                
;-------------------------------------------------------------------------;
;                               COLISAO                                   ;
;-------------------------------------------------------------------------;               
                
     ; obter o valor que se econtra na coluna do dinossauro           
COLISAO:        MVI     R1, 8
                LOAD    R1, M[R1]
                
        ; obter o valor da altura atual do dinossauro
        
                MVI     R2, contador
                LOAD    R2, M[R2]

        ; se existir um cato a mesma altura que se encontra o dino
        ; ha colisao, e por isso o jogo termina

                CMP     R2, R1
                BR.N    gameover
                
                JMP     R7
                
gameover:       DEC     R6
                STOR    M[R6], R4 ; PUSH R4

                MVI     R1, inicio_jogo
                STOR    M[R1], R0       ; Reset da variavel inicio_jogo para 0
                                        ; para afirmar que o jogo terminou
                                        
        ;Print da mensagem de gameover
        
                MVI     R1, str_gameover
                MVI     R3, 8D1Fh
                
        ;Loop que permite o print dessa mensagem
        
end_loop:       
                LOAD    R2, M[R1]
                
                CMP     R2, R0
                BR.Z    .saida_end
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                LOAD    R4, M[R1] 
                MVI     R2, TERM_WRITE ; escrever na nova linha
                STOR    M[R2],R4
                
                INC     R3
                INC     R1
                
                BR      end_loop
                
        ;Print da mensagem de restart game
                
.saida_end:
                MVI     R1, str_gamerestart
                MVI     R3, 9017h
                
        ;Loop que permite o print dessa mensagem

restart_loop:       
                LOAD    R2, M[R1]
                
                CMP     R2, R0
                BR.Z    .saida_restart
                
                MVI     R2, TERM_CURSOR                
                STOR    M[R2], R3
                LOAD    R4, M[R1] 
                MVI     R2, TERM_WRITE ; escrever na nova linha
                STOR    M[R2],R4
                
                INC     R3
                INC     R1
                
                BR      restart_loop
                
.saida_restart: 


                LOAD    R4, M[R6] ; POP R4
                INC     R6
                
                
                JMP     loop1 ; regressar ao inicio do programa e preparar um full reset
                
   
;-------------------------------------------------------------------------;
;                               GERACATO                                  ;
;-------------------------------------------------------------------------;
                
geracato:       DEC     R6
                STOR    M[R6], R4 ; PUSH R4
                DEC     R6
                STOR    M[R6], R5 ; PUSH R5
                
                MVI     R4, 1 ; R4 = bit
                
                AND     R4, R1, R4 
                
                SHR     R1 
                
                MVI     R5, 1 
                
                CMP     R4, R5
                BR.Z    .randomizer ; se bit = 1 salta randomizer
                
.continuacao:   MVI     R4, x
                STOR    M[R4], R1 ; preservar o novo valor da variavel na memoria
                ;para da proxima vez x apresentar um novo valor de forma a gerar um cato
                ;com a mesma altura, ou altura diferente, ou nao gerar um cato
                
                MVI     R5, constante
                CMP     R1, R5 ; if x < constante salta para label "zero"
                BR.N    .zero               
                
                DEC     R2 ; altura = altura - 1
                AND     R3, R1, R2
                INC     R3 ; R3 é o return da funcao geracato, onde esta a altura do cato produzido
                
                MVI     R5, colunas ; obter em R5 o vetor              
                MVI     R4, dim  ; obter a dimensao do vetor - 1              
                ADD     R5, R5, R4 ; obter a 80ª posicao do vetor
                STOR    M[R5], R3 ; colocar na 80ª posicao do vetor o return da funcao
                
                LOAD    R5, M[R6] ; POP R5
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                
                JMP     R7 ; regressar a main      
                
.randomizer:    MVI     R4, 4b00h
                XOR     R1, R1, R4 ; forma de alterar x continuamente
                BR      .continuacao
                
                
.zero:          MOV     R3, R0 

                MVI     R5, colunas                 
                MVI     R4, dim                
                ADD     R5, R5, R4 ; obter a 80ª posicao do vetor
                STOR    M[R5], R3 ; colocar na 80ª posicao do vetor o return da funcao
                
                LOAD    R5, M[R6] ; POP R5
                INC     R6
                LOAD    R4, M[R6] ; POP R4
                INC     R6
                
                JMP     R7 ; regressar a main
                
;-------------------------------------------------------------------------;
;                               SCORE                                     ;
;-------------------------------------------------------------------------;               
                
                
SCORE:          
                MVI     R1, SCORE_D0
                LOAD    R2, M[R1]
                MVI     R3, ah  
                INC     R2
                CMP     R2, R3     ; se o score em d0 for maior que 9 salta para display1
                BR.Z    display1
 
; SHOW SCORE ON DISP7_D0

                STOR    M[R1], R2
                
                MVI     R1,DISP7_D0
                STOR    M[R1],R2
                JMP     R7
                
                
                ; SHOW SCORE ON DISP7_D1
display1:       
                MVI     R1, SCORE_D0
                STOR    M[R1], R0
                
                MVI     R1, DISP7_D0
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D1
                LOAD    R2, M[R1]
                MVI     R3, ah  
                INC     R2
                CMP     R2, R3     ; se o score em d1 for maior que 9 salta para display2
                BR.Z    display2
                
; SHOW SCORE ON DISP7_D1

                STOR    M[R1], R2
                
                MVI     R1,DISP7_D1
                STOR    M[R1],R2
                JMP     R7
                
                ; SHOW SCORE ON DISP7_D2
display2:
                MVI     R1, SCORE_D1
                STOR    M[R1], R0
                
                MVI     R1, DISP7_D1
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D2
                LOAD    R2, M[R1]
                MVI     R3, ah  
                INC     R2
                CMP     R2, R3     ; se o score em d2 for maior que 9 salta para display3
                BR.Z    display3
                
; SHOW SCORE ON DISP7_D2

                STOR    M[R1], R2
                
                MVI     R1,DISP7_D2
                STOR    M[R1],R2
                JMP     R7
                
                ; SHOW SCORE ON DISP7_D3
display3:
                MVI     R1, SCORE_D2
                STOR    M[R1], R0
                MVI     R1, DISP7_D2
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D3
                LOAD    R2, M[R1]
                MVI     R3, ah  
                INC     R2
                CMP     R2, R3     ; se o score em d3 for maior que 9 salta para display4
                BR.Z    display4
                
; SHOW SCORE ON DISP7_D3

                STOR    M[R1], R2
                
                MVI     R1,DISP7_D3
                STOR    M[R1],R2
                JMP     R7
                
                ; SHOW SCORE ON DISP7_D4
display4:       
                MVI     R1, SCORE_D3
                STOR    M[R1], R0
                
                MVI     R1, DISP7_D3
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D4
                LOAD    R2, M[R1]
                MVI     R3, ah  
                INC     R2
                CMP     R2, R3     ; se o score em d4 for maior que 9 salta para display5
                BR.Z    display5
                
; SHOW SCORE ON DISP7_D1

                STOR    M[R1], R2
                
                MVI     R1,DISP7_D4
                STOR    M[R1],R2
                JMP     R7

                ; SHOW SCORE ON DISP7_D1
display5:       
                MVI     R1, SCORE_D4
                STOR    M[R1], R0
                
                MVI     R1, DISP7_D4
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D5
                LOAD    R2, M[R1]
                MVI     R3, ah
                CMP     R2, R3
                BR.Z    reset
                INC     R2
                CMP     R2, R3
                BR.Z    reset
                
; SHOW SCORE ON DISP7_D5

                STOR    M[R1], R2
                
                MVI     R1,DISP7_D5
                STOR    M[R1],R2
                
                
                JMP     R7
                
reset:

        ; RESET SCORE ON ALL DISPLAYS IF MAX SCORE IS REACHED
        
                MVI     R1, SCORE_D0
                STOR    M[R1], R0
                MVI     R1, DISP7_D0
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D1
                STOR    M[R1], R0
                MVI     R1, DISP7_D1
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D2
                STOR    M[R1], R0
                MVI     R1, DISP7_D2
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D3
                STOR    M[R1], R0
                MVI     R1, DISP7_D3
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D4
                STOR    M[R1], R0
                MVI     R1, DISP7_D4
                STOR    M[R1], R0
                
                MVI     R1, SCORE_D5
                STOR    M[R1], R0
                MVI     R1, DISP7_D5
                STOR    M[R1], R0
                
                JMP     R7

;-------------------------------------------------------------------------;
;                  AUXILIARY INTERRUPT SERVICE ROUTINES                   ;
;-------------------------------------------------------------------------;

AUX_TIMER_ISR:  
                ; SAVE CONTEXT
                
                DEC     R6
                STOR    M[R6],R1
                DEC     R6
                STOR    M[R6],R2
                
                ; RESTART TIMER
                
                MVI     R1,TIMER_COUNTVAL
                LOAD    R2,M[R1]
                MVI     R1,TIMER_COUNTER
                STOR    M[R1],R2          ; set timer to count value
                MVI     R1,TIMER_CONTROL
                MVI     R2,TIMER_SETSTART
                STOR    M[R1],R2          ; start timer
                
                ; INC TIMER FLAG
                
                MVI     R2,TIMER_TICK
                LOAD    R1,M[R2]
                INC     R1
                STOR    M[R2],R1
                
                ; RESTORE CONTEXT
                
                LOAD    R2,M[R6]
                INC     R6
                LOAD    R1,M[R6]
                INC     R6
                
                JMP     R7
                
                
;-------------------------------------------------------------------------;
;                       INTERRUPT SERVICE ROUTINES                        ;
;-------------------------------------------------------------------------;


                ORIG    7FF0h
                
TIMER_ISR:      
                ; SAVE CONTEXT
                
                DEC     R6
                STOR    M[R6],R7
                
                ; CALL AUXILIARY FUNCTION
                
                JAL     AUX_TIMER_ISR
                
                ; RESTORE CONTEXT
                
                LOAD    R7,M[R6]
                INC     R6
                RTI
                
                ORIG    7f00h
                
KEY_ZERO:       DEC     R6
                STOR    M[R6], R1 ; PUSH R1
                
                DEC     R6
                STOR    M[R6], R2 ; PUSH R2
                
        ; quando b0 e pressionado, o valor da variavel
        ; inicio_jogo altera para 1
                
                MVI     R1, 1
                MVI     R2, inicio_jogo ; se for pressionado b0 inicia o jogo
                
                STOR    M[R2], R1
                
                
                LOAD    R2, M[R6] ; POP R2
                INC     R6
                
                LOAD    R1, M[R6] ; POP R1
                INC     R6
                
                
                RTI
                
                ORIG    7F30h
KEYUP:
                DEC     R6
                STOR    M[R6],R1 ; PUSH R1
                
                DEC     R6
                STOR    M[R6], R2 ; PUSH R2

        ; quando key up e pressionada, o valor da variavel
        ; key_up_var e alterado para 1

                MVI     R1, key_up_var
                MVI     R2, 1
                STOR    M[R1], R2
                
                
                LOAD    R2, M[R6]
                INC     R6         ; POP R2

                LOAD    R1,M[R6]
                INC     R6        ; POP R1
                RTI