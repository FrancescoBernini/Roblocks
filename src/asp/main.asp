#include <incmode>.

#const istop  = "SAT". % Stop when there is a model
#defined move/5.


#program base.

wide(0..max_width-1).
height(0..max_height-1).

% Direzioni di movimento
direction(n,0,1).
direction(s,0,-1).
direction(e,1,0).
direction(w,-1,0).

opposite(e,w). 
opposite(w,e).
opposite(n,s). 
opposite(s,n).

% Bordi della griglia
borderX(0).
borderX(max_width-1).
borderY(0).
borderY(max_height-1).


% Inizializzazione dei blocchi dalla configurazione iniziale
at(DIM,X,Y,0) :- init_block(_,DIM,X,Y).
 
% Importazione della configurazione goal
target(DIM,X,Y) :- goal_block(_,DIM,X,Y).

#program step(t).

1 { move(DIM,X,Y,D,t) : direction(D,DX,DY), at(DIM,X,Y,t-1), wide(X), height(Y) } 1.


% Calcolo nuove posizioni
at(DIM, X+DX, Y+DY, t) :- 
    at(DIM, X, Y, t-1),
    move(DIM, X, Y, D, t),
    direction(D, DX, DY),
    wide(X+DX),
    height(Y+DY).

% Inerzia: Se non si muove, rimane fermo
at(DIM, X, Y, t) :- 
    at(DIM, X, Y, t-1),
    not move(DIM,X,Y,_,t).

% Vincoli di non sovrapposizione della nuova mossa
:- move(DIM, X, Y, D, t),
   direction(D, DX, DY),
   X_new = X + DX,
   Y_new = Y + DY,
   at(DIM1, X1, Y1, t-1),         % Cambiato da t a t-1
   not move(DIM1, X1, Y1, _, t),
   X_new < X1+DIM1, X_new+DIM-1 > X1-1,
   Y_new < Y1+DIM1, Y_new+DIM-1 > Y1-1.


% Vincoli per i bordi della griglia
:- move(DIM, X, Y, e, t), at(DIM,X,_,t-1), (X + DIM) = max_width.
:- move(DIM, X, Y, w, t), at(DIM,X,_,t-1), (X + DIM) = max_width.
:- move(DIM, X, Y, e, t), at(DIM,X,_,t-1), X = 0.
:- move(DIM, X, Y, w, t), at(DIM,X,_,t-1), X = 0.

:- move(DIM, X, Y, n, t), at(DIM,_,Y,t-1), (Y + DIM) = max_height.
:- move(DIM, X, Y, s, t), at(DIM,_,Y,t-1), (Y + DIM) = max_height.
:- move(DIM, X, Y, n, t), at(DIM,_,Y,t-1), Y = 0.
:- move(DIM, X, Y, s, t), at(DIM,_,Y,t-1), Y = 0.

% Evita mosse ripetute
:- move(DIM,X+OX,Y+OY,D,t), 
   opposite(D,O),
   direction(O,OX,OY),
   move(DIM,X,Y,O,t-1).

% Evita di andare nei bordi se non necessario nel goal
:- move(DIM,X,_,D,t), 
   direction(D,DX,_),
   borderX(X+DX+DIM-1),
   not target(DIM,X+DX,_),
   N1 = #count { Y1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), X1+DIM1-1 = max_width-1},
   N2 = #count { Y1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), X1+DIM1-1 = max_width-1},
   N1 > N2.

:- move(DIM,X,_,D,t), 
   direction(D,DX,_),
   borderX(X+DX),
   not target(DIM,X+DX,_),
   N1 = #count { Y1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), X1 = 0},
   N2 = #count { Y1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), X1 = 0},
   N1 > N2.

:- move(DIM,_,Y,D,t), 
   direction(D,_,DY),
   borderY(Y+DY+DIM-1),
   not target(DIM,_,Y+DY),
   N1 = #count { X1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), Y1+DIM1-1 = max_height-1},
   N2 = #count { X1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), Y1+DIM1-1 = max_height-1},
   N1 > N2.

:- move(DIM,_,Y,D,t), 
   direction(D,_,DY),
   borderY(Y+DY),
   not target(DIM,_,Y+DY),
   N1 = #count { X1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), Y1 = 0},
   N2 = #count { X1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), Y1 = 0},
   N1 > N2.


% Minimizza numero di mosse (Togliere?)
%#minimize { T : move(_, _, _, _, T) }.

#program check(t).

% Verifica raggiungimento goal
reached_target(DIM, X, Y, t) :- 
    at(DIM, X, Y, t),
    target(DIM, X, Y).

goal(t) :- 
    t >= 0,
    reached_target(DIM, X, Y, t) : goal_block(_,DIM,X,Y).

% Condizione di termine
:- query(t), not goal(t).

#show move/5.
#show target/3.
%#show at/4.