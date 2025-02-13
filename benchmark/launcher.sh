#!/bin/bash

# File per salvare i tempi
TIMES_FILE="execution_times.txt"
> $TIMES_FILE  # Pulisce il file se esiste

for n in {1..100}; do
    echo "Eseguendo benchmark$n.asp..."

    # Primo passo: eseguire il primo clingo e salvare goal_block
    clingo benchmark$n.asp ../src/asp/init.asp 0 --opt-mode=opt --quiet=1 --time-limit=300 | \
        grep -o 'goal_block([^)]*)' | sed 's/$/./' | tee ../src/asp/tmp.asp

    # Aggiungere costanti e blocchi iniziali
    grep '#const' benchmark$n.asp >> ../src/asp/tmp.asp
    grep '^init_block' benchmark$n.asp >> ../src/asp/tmp.asp

    # Inizia a misurare il tempo
    START_TIME=$(date +%s)
    
    # Secondo passo: eseguire il secondo clingo e salvare le mosse.
    clingo ../src/asp/tmp.asp ../src/asp/main.asp --models=1 --parallel-mode=8,compete --time-limit=300 | \
        grep -oE 'move\([^)]*\)' | sed 's/$/./' | tee ../src/asp/tmp_new.asp

    # Pulizia
    rm ../src/asp/tmp_new.asp

    # Fine misurazione tempo
    END_TIME=$(date +%s)
    ELAPSED_TIME=$((END_TIME - START_TIME))

    # Salva il tempo nel file
    echo "Benchmark$n: ${ELAPSED_TIME}s" | tee -a $TIMES_FILE

    echo "Benchmark$n completato in ${ELAPSED_TIME} secondi."
done
