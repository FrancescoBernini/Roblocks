width(0..max_width-1). % Larghezza griglia (X)
height(0..max_height-1). % Altezza griglia (Y)

% Predicato posizione finale
1 { goal_block(ID,DIM,X,Y) : width(X), height(Y)} 1 :- init_block(ID,DIM,_,_).

% Vincolo sulla sovrapposizione
:- goal_block(ID1,DIM1,X1,Y1), 
   goal_block(ID2,DIM2,X2,Y2), 
   ID1 != ID2, 
   X1 < X2+DIM2, X1+DIM1-1 > X2-1,
   Y1 < Y2+DIM2, Y1+DIM1-1 > Y2-1.

% Vincoli dimensione griglia
:- goal_block(ID,DIM,X,Y),
   (X + DIM - 1) > (max_width-1).

:- goal_block(ID,DIM,X,Y),
   (Y + DIM - 1) > (max_height-1).

% Vincolo di supporto: un blocco deve avere un supporto sotto o essere a terra
:- goal_block(ID1,DIM1,X1,Y1), Y1 > 0,
   not supported(ID1).

% Un blocco è supportato se c'è un altro blocco direttamente sotto
supported(ID1) :- 
    goal_block(ID1,DIM1,X1,Y1),
    goal_block(ID2,DIM2,X2,Y2),
    ID1 != ID2,
    Y1 = Y2 + DIM2,
    X1 >= X2,
    X1+DIM1-1 < X2 + DIM2. % Può essere supportato solo da un blocco uguale o più grande

% Vincolo per riempire da sinistra: non ci possono essere spazi vuoti a sinistra
:- goal_block(ID1,DIM1,X1,Y1),
   X1 > 0,
   not occupied_left(DIM1,X1,Y1).

% Predicato per verificare se c'è un blocco a sinistra
occupied_left(DIM1,X,Y) :-
    width(X),
    height(Y),
    goal_block(_,DIM1,X,Y),
    goal_block(_,DIM2,X2,Y2),
    DIM1 <= DIM2,
    X2 + DIM2 = X,
    Y >= Y2,
    Y < Y2 + DIM2.

% Y Penalizza le posizioni più alte, costringendo i blocchi a stare più in basso possibile.
% Y+DIM-1: Minimizza l’altezza massima. 
#minimize {Y+DIM-1,Y: goal_block(_,DIM,X,Y)}.

% I blocchi più grandi stanno in basso
#minimize { Y * DIM : goal_block(_,DIM,_,Y) }.


% === Vincoli controllo input ===
:- init_block(ID1,DIM1,X1,Y1), 
   init_block(ID2,DIM2,X2,Y2), 
   ID1 != ID2, 
   X1 < X2+DIM2, X1 > X2-1,
   Y1 < Y2+DIM2, Y1 > Y2-1.

:- init_block(ID,DIM,X,Y),
   (X + DIM - 1) > (max_width-1).

:- init_block(ID,DIM,X,Y),
   (Y + DIM - 1) > (max_height-1).

#show goal_block/4.
#show init_block/4.
