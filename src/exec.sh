#!/bin/bash

clingo ./asp/init.asp 0 --opt-mode=opt --quiet=1 | grep -o 'goal_block([^)]*)' | sed 's/$/./' | tee ./asp/tmp.asp

grep '#const' ./asp/init.asp >> ./asp/tmp.asp
grep '^init_block' ./asp/init.asp >> ./asp/tmp.asp

clingo ./asp/tmp.asp ./asp/main.asp 0 --opt-mode=opt --parallel=8 --quiet=1 | grep -oE 'move\([^)]*\)' | sed 's/$/./' | tee ./asp/tmp_new.asp

cat ./asp/tmp_new.asp >> ./asp/tmp.asp

rm ./asp/tmp_new.asp

echo "Processo completato!"