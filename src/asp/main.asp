#include <incmode>.
#const max_width = 4.   % Larghezza massima (X)
#const max_height = 5.  % Altezza massima (Y)

#program base.

wide(0..max_width).
height(0..max_height).

% Direzioni di movimento
direction(n,0,1).
direction(s,0,-1).
direction(e,1,0).
direction(w,-1,0).

init_block(b1,1,2,1).
init_block(b2,1,2,4).
init_block(b3,2,3,4).
init_block(b4,2,0,0).

% Inizializzazione dei blocchi dalla configurazione iniziale
block(ID) :- init_block(ID,_,_,_).
block_size(ID,DIM) :- init_block(ID,DIM,_,_).
at(ID,X,Y,0) :- init_block(ID,_,X,Y).
 
% Importazione della configurazione goal
%target(ID,DIM,X,Y) :- goal_block(ID,DIM,X,Y).
target(b1,1,4,0).
target(b2,1,4,1).
target(b3,2,0,0).
target(b4,2,2,0).

#program step(t).

1 { move(ID,D,t) : direction(D,_,_), block(ID) } 1.

% Tracking del movimento
moving(ID,t) :- move(ID,_,t).

% Calcolo nuove posizioni
at(ID,X+DX,Y+DY,t) :- 
    at(ID,X,Y,t-1),
    move(ID,D,t),
    direction(D,DX,DY),
    wide(X+DX),
    height(Y+DY).

% Inerzia: Se non si sta muovendo mantiene la stessa posizione
at(ID,X,Y,t) :- 
    at(ID,X,Y,t-1),
    block(ID),
    not moving(ID,t).

% Vincoli di non sovrapposizione
:- at(ID1,X1,Y1,t), 
   at(ID2,X2,Y2,t),
   block_size(ID1,DIM1),
   block_size(ID2,DIM2),
   ID1 != ID2,
   X1 < X2+DIM2, X1 > X2-1,
   Y1 < Y2+DIM2, Y1 > Y2-1.

% Vincoli bordi griglia
:- at(ID,X,Y,t),
   block_size(ID,DIM),
   (X + DIM - 1) > max_width.
:- at(ID,X,Y,t),
   block_size(ID,DIM),
   (Y + DIM - 1) > max_height.


% Vincolo movimento valido (solo spingere)
:- move(ID,e,t), at(ID,maxwidth,_,t-1).
:- move(ID,w,t), at(ID,0,_,t-1).
:- move(ID,n,t), at(ID,_,maxheight,t-1).
:- move(ID,s,t), at(ID,_,0,t-1).

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

% Ottimizzazione numero mosse
#minimize { 1,T : move(_,_,T) }.

#show at/4.
