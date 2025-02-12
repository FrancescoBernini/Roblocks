#!/bin/bash

# Impostazioni di base
num_files=100
max_width_range=(8 8 8 8 8 8 8 8 8 8)
max_height_range=(8 8 8 8 8 8 8 8 8 8)
max_dim_range=(1 2 2 3 3 4 4 4 5 5)
num_blocks_range=(1 2 3 2 3 2 3 4 2 3)

# Genera i file di benchmark
for file_num in $(seq 1 $num_files); do
    # Calcola l'indice corretto per gli array
    index=$((($file_num-1)/10))
    
    # Seleziona valori dagli array usando l'indice corretto
    max_width=${max_width_range[$index]}
    max_height=${max_height_range[$index]}
    max_dim=${max_dim_range[$index]}
    num_blocks=${num_blocks_range[$index]}

    # Crea il file temporaneo dei blocchi
    echo "" > tmp_generator.asp
    for ((block=1; block<=num_blocks; block++)); do
        echo "block(b$block)." >> tmp_generator.asp
    done

    # Esegui clingo e salva l'output
    clingo tmp_generator.asp generator.asp \
        --rand-freq=1 \
        --seed=$RANDOM \
        --const max_width=$max_width \
        --const max_height=$max_height \
        --const max_dim=$max_dim \
        --quiet=1 \
        | grep -o 'init_block([^)]*)' \
        | sed 's/$/./' > "benchmark$file_num.asp"

    # Aggiungi le costanti al file di output
    echo "#const max_width=$max_width." >> "benchmark$file_num.asp"
    echo "#const max_height=$max_height." >> "benchmark$file_num.asp"
done

rm tmp_generator.asp