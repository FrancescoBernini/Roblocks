import re
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import imageio
import io

# === Legge il file e raccoglie i dati ===
def parse_file(filename):
    init_blocks = {}
    moves = []
    grid_width, grid_height = 5, 5  # Valori predefiniti

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            
            # Estrarre le dimensioni della griglia
            match = re.match(r'#const max_width = (\d+)', line)
            if match:
                grid_width = int(match.group(1))

            match = re.match(r'#const max_height = (\d+)', line)
            if match:
                grid_height = int(match.group(1))

            # Estrarre i blocchi iniziali
            match = re.match(r'init_block\((b\d+),(\d+),(\d+),(\d+)\)\.', line)
            if match:
                block_id, size, x, y = match.groups()
                init_blocks[block_id] = (int(size), int(x), int(y))
            
            # Estrarre le mosse
            match = re.match(r'move\((b\d+),(\w),(\d+)\)\.', line)
            if match:
                block_id, direction, step = match.groups()
                moves.append((block_id, direction, int(step)))

    # Ordinare le mosse in base al passo (step)
    moves.sort(key=lambda x: x[2])

    return init_blocks, moves, grid_width, grid_height

# === Funzione per disegnare la griglia ===
def draw_grid(blocks, step, grid_width, grid_height):
    fig, ax = plt.subplots(figsize=(5, 5))

    # Imposta i limiti della griglia
    ax.set_xlim(0, grid_width+1)
    ax.set_ylim(0, grid_height+1)
    ax.set_xticks(range(grid_width+1))
    ax.set_yticks(range(grid_height+1))
    ax.grid(True)

    # Disegna i blocchi
    for block_id, (size, x, y) in blocks.items():
        rect = patches.Rectangle((x, y), size, size, linewidth=1.5, edgecolor='black', facecolor='skyblue')
        ax.add_patch(rect)
        ax.text(x + size/2, y + size/2, block_id, fontsize=12, ha='center', va='center', color="black")

    ax.set_title(f"Step {step}")

    # Salva l'immagine in memoria anziché su disco
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)  # Riporta il puntatore all'inizio del buffer
    plt.close()

    return buf

# === Simula le mosse e crea le immagini in memoria ===
def create_gif(filename, output_gif="output.gif"):
    init_blocks, moves, grid_width, grid_height = parse_file(filename)
    frames = []

    # Creiamo gli stati passo dopo passo
    current_blocks = init_blocks.copy()
    
    # Aggiungi il primo frame (stato iniziale)
    buf = draw_grid(current_blocks, 0, grid_width, grid_height)
    frames.append(imageio.imread(buf))

    # Applicare i movimenti nell'ordine corretto
    for step, (block_id, direction, _) in enumerate(moves, start=1):
        size, x, y = current_blocks[block_id]
        
        # Applica il movimento senza uscire dalla griglia
        if direction == 'n' and y < grid_height: y += 1
        elif direction == 's' and y > 0 - 1: y -= 1
        elif direction == 'e' and x < grid_width - 1: x += 1
        elif direction == 'w' and x > 0: x -= 1

        current_blocks[block_id] = (size, x, y)

        # Salva il frame in memoria
        buf = draw_grid(current_blocks, step, grid_width, grid_height)
        frames.append(imageio.imread(buf))

    # Creazione della GIF
    imageio.mimsave(output_gif, frames, duration=300)
    print(f"GIF salvata come {output_gif}")

# === Esegui lo script ===
create_gif("../asp/tmp.asp")