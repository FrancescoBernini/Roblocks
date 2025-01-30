% Per eseguire e ottenere un modello iniziale random usare "clingo generator.asp --rand-freq=1 --seed=$RANDOM --const max_width=? --const max_heigth=? --const max_dim=?" 

#const max_width = 4.   % Larghezza massima (X)
#const max_height = 5.  % Altezza massima (Y)
#const max_dim = 3. % Dimensione massima dei blocchi generati

wide(0..max_width). % Larghezza griglia (X)
height(0..max_height). % Altezza griglia (Y)

dim(1..max_dim).

% Predicato posizione finale
1 { init_block(ID,DIM,X,Y) : wide(X), height(Y), dim(DIM)} 1 :- block(ID).

% === Vincoli controllo input ===
:- init_block(ID1,DIM1,X1,Y1), 
   init_block(ID2,DIM2,X2,Y2), 
   ID1 != ID2, 
   X1 < X2+DIM2, X1 > X2-1,
   Y1 < Y2+DIM2, Y1 > Y2-1.

:- init_block(ID,DIM,X,Y),
   (X + DIM - 1) > (max_width).

:- init_block(ID,DIM,X,Y),
   (Y + DIM - 1) > (max_height).

#show init_block/4.
#show block/1.
