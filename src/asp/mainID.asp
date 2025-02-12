#include <incmode>.

#program base.

width(0..max_width-1).
height(0..max_height-1).

% Direzioni di movimento
direction(n,0,1).
direction(s,0,-1).
direction(e,1,0).
direction(w,-1,0).

% Inizializzazione dei blocchi dalla configurazione iniziale
block(ID) :- init_block(ID,_,_,_).
block_size(ID,DIM) :- init_block(ID,DIM,_,_).
at(ID,X,Y,0) :- init_block(ID,_,X,Y).
 
% Importazione della configurazione goal
target(ID,DIM,X,Y) :- goal_block(ID,DIM,X,Y).

#program step(t).

1 { move(ID,D,t) : direction(D,DX,DY), block(ID) } 1.

% Tracking del movimento
%moving(ID,t) :- move(ID,_,t).

% Calcolo nuove posizioni
at(ID,X+DX,Y+DY,t) :- 
    at(ID,X,Y,t-1),
    move(ID,D,t),
    direction(D,DX,DY),
    width(X+DX),
    height(Y+DY).

% Inerzia: Se non si sta muovendo mantiene la stessa posizione
at(ID,X,Y,t) :- 
    at(ID,X,Y,t-1),
    block(ID),
    move(ID2,_,t),
    ID != ID2. % Rimuovo il not moving(ID,t) per ottimizzare (?)


% Vincoli di non sovrapposizione
:- at(ID1,X1,Y1,t), 
   at(ID2,X2,Y2,t),
   block_size(ID1,DIM1),
   block_size(ID2,DIM2),
   ID1 != ID2,
   X1 < X2+DIM2, X1+DIM1-1 > X2-1,
   Y1 < Y2+DIM2, Y1+DIM1-1 > Y2-1.

% Vincoli bordi griglia
%:- at(ID,X,Y,t),
%   block_size(ID,DIM),
%   (X + DIM - 1) > max_width-1.
%:- at(ID,X,Y,t),
%   block_size(ID,DIM),
%   (Y + DIM - 1) > max_height-1.


% Vincolo movimento valido (solo spingere) -> Controlla anche i bordi
:- move(ID,e;w,t), at(ID,X,_,t-1), block_size(ID,DIM), (X + DIM) = max_width.
:- move(ID,e;w,t), at(ID,X,_,t-1), X = 0.

:- move(ID,n;s,t), at(ID,_,Y,t-1), block_size(ID,DIM), (Y + DIM) = max_height.
:- move(ID,n;s,t), at(ID,_,Y,t-1), Y = 0.


% === Ottimizzazioni ===

% Evita mosse ripetute
:- move(ID,w,T), move(ID,e,T-1).
:- move(ID,e,T), move(ID,w,T-1).
:- move(ID,s,T), move(ID,n,T-1).
:- move(ID,n,T), move(ID,s,T-1).

% Minimizza numero di mosse
#minimize { T  : move(_,_,T) }.

#program check(t).
% Verifica raggiungimento goal
reached_target(ID,t) :- 
    at(ID,X,Y,t),
    target(ID,_,X,Y).

goal(t) :- 
    t > 0,
    reached_target(ID,t) : block(ID).

% Condizione di termine
:- query(t), not goal(t).

#show move/3.
#show target/4.
%#show at/4.