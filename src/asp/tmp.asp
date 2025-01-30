goal_block(b1,1,0,0).
goal_block(b2,1,0,1).
goal_block(b3,2,1,0).
goal_block(b4,2,3,0).
#const max_width = 4.   % Larghezza massima (X)
#const max_height = 5.  % Altezza massima (Y)
init_block(b1,1,2,1).
init_block(b2,1,2,4).
init_block(b3,2,2,2).
init_block(b4,2,3,4).
move(b3,w,1).
move(b2,w,2).
move(b4,s,3).
move(b2,w,4).
move(b2,s,5).
move(b2,s,6).
move(b1,w,7).
move(b4,s,8).
move(b4,s,9).
move(b4,s,10).
move(b1,w,11).
move(b1,s,12).
move(b2,s,13).
move(b3,s,14).
move(b3,s,15).
