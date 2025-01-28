#const max_width = 4.   % Larghezza massima (X)
#const max_height = 5.  % Altezza massima (Y)

wide(0..max_width). % Larghezza griglia (X)
height(0..max_height). % Altezza griglia (Y)

% block(ID,dim,X,Y) indica che c'è un cubo di dimensione dim in posizione X, Y
block(b1,1,2,1).
block(b2,1,2,4).
block(b3,2,0,0).
block(b4,2,3,4).


% Predicato posizione finale
1 { final_block(ID,DIM,X,Y) : wide(X), height(Y)} 1 :- block(ID,DIM,_,_).

% Vincolo sulla sovrapposizione
:- final_block(ID1,DIM1,X1,Y1), 
   final_block(ID2,DIM2,X2,Y2), 
   ID1 != ID2, 
   X1 < X2+DIM2, X1 > X2-1,
   Y1 < Y2+DIM2, Y1 > Y2-1.

% Vincoli dimensione griglia
:- final_block(ID,DIM,X,Y),
   (X + DIM - 1) > (max_width).

:- final_block(ID,DIM,X,Y),
   (Y + DIM - 1) > (max_height).

% Vincolo di supporto: un blocco deve avere un supporto sotto o essere a terra
:- final_block(ID1,DIM1,X1,Y1), Y1 > 0,
   not supported(ID1).

% Un blocco è supportato se c'è un altro blocco direttamente sotto
supported(ID1) :- 
    final_block(ID1,DIM1,X1,Y1),
    final_block(ID2,DIM2,X2,Y2),
    ID1 != ID2,
    Y1 = Y2 + DIM2,
    X1 >= X2,
    X1 < X2 + DIM2.

% Vincolo per riempire da sinistra: non ci possono essere spazi vuoti a sinistra
:- final_block(ID1,DIM1,X1,Y1),
   X1 > 0,
   not occupied_left(X1,Y1).

% Predicato per verificare se c'è un blocco a sinistra
occupied_left(X,Y) :-
    wide(X),
    height(Y),
    final_block(_,DIM,X2,Y2),
    X2 + DIM = X,
    Y >= Y2,
    Y < Y2 + DIM.

% Y Penalizza le posizioni più alte, costringendo i blocchi a stare più in basso possibile.
% Y+DIM-1: Minimizza l’altezza massima. 
#minimize {Y+DIM-1,Y: final_block(_,DIM,_,Y)}.

% === Vincoli controllo input ===
:- block(ID1,DIM1,X1,Y1), 
   block(ID2,DIM2,X2,Y2), 
   ID1 != ID2, 
   X1 < X2+DIM2, X1 > X2-1,
   Y1 < Y2+DIM2, Y1 > Y2-1.

:- block(ID,DIM,X,Y),
   (X + DIM - 1) > (max_width).

:- block(ID,DIM,X,Y),
   (Y + DIM - 1) > (max_height).

#show final_block/4.
