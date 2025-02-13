#include <incmode>.

#defined move/5.

#program base.

% Fatti -------------------------------------------------------------------------------------------

% Posizioni possibili
width(0..max_width-1).
height(0..max_height-1).

% Direzioni di movimento
direction(n,0,1).
direction(s,0,-1).
direction(e,1,0).
direction(w,-1,0).

% Direzioni opposte
opposite(e,w). 
opposite(w,e).
opposite(n,s). 
opposite(s,n).

% Bordi della griglia
borderX(0).
borderX(max_width).
borderY(0).
borderY(max_height).


%--------------------------------------------------------------------------------------------------


% Controlli sulla raggiungibilita' della configurazione finale ------------------------------------


% Un blocco iniziale si trova su un bordo diverso da quello che deve raggiungere
% Bordi superiore e inferiore
unreachable_target :- 
   init_block(ID,DIM,_,Y), 
   borderY(Y+DIM;Y),
   not goal_block(ID,DIM,_,Y).

% Bordi destro e sinistro
unreachable_target :- 
   init_block(ID,DIM,X,_), 
   borderX(X+DIM;X),
   not goal_block(ID,DIM,X,_).


% Tutti i blocchi non si possono muovere perche' hanno 2 bordi non opposti occupati
% Bordo destro e superiore
blocked_block(ID) :- init_block(ID,DIM,X,Y),                 
   #count { VAL : init_block(ID1, DIM1, X1, Y1),
                  ID!=ID1,
                  X1 + DIM1 = X,
      %* e *%     VAL = Y..(Y + DIM - 1),
                  VAL < Y1 + DIM1,
                  VAL + DIM1 -1 >= Y1
          } >= DIM, 
   #count { VAL : init_block(ID3, DIM3, X3, Y3),
                  ID!=ID3,
                  Y3 + DIM3 = Y,
      %* n *%     VAL = X..(X + DIM - 1),
                  VAL < X3 + DIM3,
                  VAL + DIM3 -1 >= X3
          } >= DIM. 

% Bordo destro e inferiore
blocked_block(ID) :- init_block(ID,DIM,X,Y),                 
   #count { VAL : init_block(ID1, DIM1, X1, Y1),
                  ID!=ID1,
                  X1 + DIM1 = X,
      %* e *%     VAL = Y..(Y + DIM - 1),
                  VAL < Y1 + DIM1,
                  VAL + DIM1 -1 >= Y1
          } >= DIM, 
   #count { VAL : init_block(ID4, DIM4, X4, Y4),
                  ID!=ID4,
                  Y4 = Y + DIM,
      %* s *%     VAL = X..(X + DIM - 1),
                  VAL < X4 + DIM4,
                  VAL + DIM4 -1 >= X4
          } >= DIM. 

% Bordo sinistro e superiore
blocked_block(ID) :- init_block(ID,DIM,X,Y),
   #count { VAL : init_block(ID2, DIM2, X2, Y2),
                  ID!=ID2,  
                  X2 = X + DIM,
      %* w *%     VAL = Y..(Y + DIM - 1),
                  VAL < Y2 + DIM2,
                  VAL + DIM2 -1 >= Y2
          } >= DIM, 
   #count { VAL : init_block(ID3, DIM3, X3, Y3),
                  ID!=ID3, 
                  Y3 + DIM3 = Y,
      %* n *%     VAL = X..(X + DIM - 1),
                  VAL < X3 + DIM3,
                  VAL + DIM3 -1 >= X3
          } >= DIM. 

% Bordo sinistro e inferiore
blocked_block(ID) :- init_block(ID,DIM,X,Y),
   #count { VAL : init_block(ID2, DIM2, X2, Y2),
                  ID!=ID2,
                  X2 = X + DIM,
      %* w *%     VAL = Y..(Y + DIM - 1),
                  VAL < Y2 + DIM2,
                  VAL + DIM2 -1 >= Y2
          } >= DIM, 
   #count { VAL : init_block(ID4, DIM4, X4, Y4),
                  ID!=ID4, 
                  Y4 = Y + DIM,
      %* s *%     VAL = X..(X + DIM - 1),
                  VAL < X4 + DIM4,
                  VAL + DIM4 -1 >= X4
          } >= DIM. 

unreachable_target :- #count {ID : blocked_block(ID)   } = Nblocked,      
                      #count {ID : init_block(ID,_,_,_)} = Nblocks,
                      Nblocked = Nblocks.       


% -------------------------------------------------------------------------------------------------

% Inizializzazione posizione e goal ---------------------------------------------------------------


% Posizionamento dei blocchi nella configurazione iniziale (al tempo 0)
at(DIM,X,Y,0) :- init_block(_,DIM,X,Y).
 
% Import della configurazione goal
target(DIM,X,Y) :- goal_block(_,DIM,X,Y).


% -------------------------------------------------------------------------------------------------


% Calcolo mosse per raggiungere il goal -----------------------------------------------------------
#program step(t).

% Generazione mosse possibili a partire dalla situazione al momento precedente
1 { move(DIM,X,Y,D,t) : direction(D,DX,DY), at(DIM,X,Y,t-1), width(X), height(Y) } 1.

% Calcolo nuove posizioni
at(DIM, X+DX, Y+DY, t) :- 
    at(DIM, X, Y, t-1),
    move(DIM, X, Y, D, t),
    direction(D, DX, DY),
    width(X+DX),
    height(Y+DY).

% Inerzia: Se il blocco non si muove, rimane fermo
at(DIM, X, Y, t) :- 
    at(DIM, X, Y, t-1),
    not move(DIM,X,Y,_,t).

% Una mossa non puo' far sovrapporre un blocco ad un altro
:- move(DIM, X, Y, D, t),
   direction(D, DX, DY),
   X_new = X + DX,
   Y_new = Y + DY,
   at(DIM1, X1, Y1, t-1),
   not move(DIM1, X1, Y1, _, t),
   X_new < X1+DIM1, X_new+DIM-1 > X1-1,
   Y_new < Y1+DIM1, Y_new+DIM-1 > Y1-1.

% Una mossa non puo' portare un blocco fuori dalla griglia o lontano dal bordo
:- move(DIM, X, Y, e, t), at(DIM,X,_,t-1), (X + DIM) = max_width.
:- move(DIM, X, Y, w, t), at(DIM,X,_,t-1), (X + DIM) = max_width.
:- move(DIM, X, Y, e, t), at(DIM,X,_,t-1), X = 0.
:- move(DIM, X, Y, w, t), at(DIM,X,_,t-1), X = 0.

:- move(DIM, X, Y, n, t), at(DIM,_,Y,t-1), (Y + DIM) = max_height.
:- move(DIM, X, Y, s, t), at(DIM,_,Y,t-1), (Y + DIM) = max_height.
:- move(DIM, X, Y, n, t), at(DIM,_,Y,t-1), Y = 0.
:- move(DIM, X, Y, s, t), at(DIM,_,Y,t-1), Y = 0.

% Una mossa non può spingere un blocco se il lato dove si spinge è completamente bloccato
:- move(DIM,X,Y,e,t), 
   #count { VAL : VAL = Y..(Y + DIM - 1), at(DIM1, X1, Y1, t-1), 
        X1 + DIM1 = X, VAL < Y1 + DIM1, VAL + DIM1 -1 >= Y1} >= DIM. 

:- move(DIM,X,Y,w,t), 
    #count { VAL : VAL = Y..(Y + DIM - 1), at(DIM1, X1, Y1, t-1), 
        X1 = X + DIM, VAL < Y1 + DIM1, VAL + DIM1 -1 >= Y1} >= DIM. 
        
:- move(DIM,X,Y,n,t), 
   #count { VAL : VAL = X..(X + DIM - 1), at(DIM1, X1, Y1, t-1), 
        Y1 + DIM1 = Y, VAL < X1 + DIM1, VAL + DIM1 -1 >= X1} >= DIM. 

:- move(DIM,X,Y,s,t), 
   #count { VAL : VAL = X..(X + DIM - 1), at(DIM1, X1, Y1, t-1), 
        Y1 = Y + DIM, VAL < X1 + DIM1, VAL + DIM1 -1 >= X1} >= DIM. 


% -------------------------------------------------------------------------------------------------


% Eliminazione mosse possibili ma inutili ---------------------------------------------------------


% Non ha senso che due mosse consecutive si annullino
:- move(DIM,X+OX,Y+OY,D,t), 
   opposite(D,O),
   direction(O,OX,OY),
   move(DIM,X,Y,O,t-1).

% Non ha senso che una mossa porti un blocco in un bordo diverso da quello che deve raggiungere
:- move(DIM,X,_,D,t), 
   direction(D,DX,_),
   borderX(X+DIM+DX),
   not target(DIM,X+DX,_),
   N1 = #count { Y1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), X1+DIM1 = max_width},
   N2 = #count { Y1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), X1+DIM1 = max_width},
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
   borderY(Y+DIM+DY),
   not target(DIM,_,Y+DY),
   N1 = #count { X1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), Y1+DIM1 = max_height},
   N2 = #count { X1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), Y1+DIM1 = max_height},
   N1 > N2.

:- move(DIM,_,Y,D,t), 
   direction(D,_,DY),
   borderY(Y+DY),
   not target(DIM,_,Y+DY),
   N1 = #count { X1 : at(DIM1, X1, Y1, t), move(DIM1,_,_,_,t), Y1 = 0},
   N2 = #count { X1 : target(DIM1, X1, Y1), move(DIM1,_,_,_,t), Y1 = 0},
   N1 > N2.

% Un blocco non si muove 2 volte di seguito (tranne quando e' l'ultimo non alla posizione di goal)
%:- move(DIM,X,Y,_,t), 
%   move(DIM,X1,Y1,D,t-1), 
%   direction(D,DX,DY), 
%   X = X1+DX, Y = Y1+DY,
%   N1 = #count { (X2,Y2) : init_block(ID2,DIM2,X2,Y2) },
%   N2 = #count { (X2,Y2) : target(DIM2,X2,Y2), at(DIM2,X2,Y2,t-1) },
%   N2 < N1-1.


% -------------------------------------------------------------------------------------------------


% Verifica raggiungimento goal --------------------------------------------------------------------
#program check(t).

% Verifica se ogni blocco e' al goal
reached_target(DIM, X, Y, t) :- 
    at(DIM, X, Y, t),
    target(DIM, X, Y).

% Termina se ogni blocco e' al goal
goal(t) :- 
    reached_target(DIM, X, Y, t) : goal_block(_,DIM,X,Y).

% Termina se la configurazione iniziale non permette soluzioni
goal(t) :- 
    unreachable_target.

% Innesca la verifica del goal ad ogni t
:- query(t), not goal(t).


% -------------------------------------------------------------------------------------------------


% Stampa mosse o situazione senza soluzioni ------------------------------------------------------- 
#show move/5.
#show unreachable_target/0.
