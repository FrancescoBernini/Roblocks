import re
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import imageio.v2 as imageio
import io

# === Legge il file e raccoglie i dati ===
def parse_file(filename):
    init_blocks = {}
    moves = []
    grid_width, grid_height = 7,7  # Valori predefiniti

    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            
            # Dimensioni griglia
            width_match = re.match(r'#const max_width=(\d+)\.', line)
            height_match = re.match(r'#const max_height=(\d+)\.', line)
            
            if width_match:
                grid_width = int(width_match.group(1))
            if height_match:
                grid_height = int(height_match.group(1))
            
            # Blocchi iniziali
            init_match = re.match(r'init_block\((b\d+),(\d+),(\d+),(\d+)\)\.', line)
            if init_match:
                id_block, size, x, y = init_match.groups()
                init_blocks[(int(x), int(y))] = int(size)
            
            # Mosse
            move_match = re.match(r'move\((\d+),(\d+),(\d+),([nswe]),(\d+)\)\.', line)
            if move_match:
                size, x, y, direction, step = move_match.groups()
                moves.append((int(size), int(x), int(y), direction, int(step)))

    # Ordinare le mosse in base al passo (step)
    moves.sort(key=lambda x: x[4])
    return init_blocks, moves, grid_width, grid_height

# === Funzione per disegnare la griglia ===
def draw_grid(blocks, step, grid_width, grid_height):
    fig, ax = plt.subplots(figsize=(5, 5))

    ax.set_xlim(0, grid_width)
    ax.set_ylim(0, grid_height)
    ax.set_xticks(range(grid_width+1))
    ax.set_yticks(range(grid_height+1))
    ax.grid(True)

    for (x, y), size in blocks.items():
        rect = patches.Rectangle((x, y), size, size, linewidth=1.5, edgecolor='black', facecolor='skyblue')
        ax.add_patch(rect)
        ax.text(x + size / 2, y + size / 2, f"{size}", fontsize=12, ha='center', va='center', color="black")

    ax.set_title(f"Step {step}")

    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    plt.close()

    return buf

# === Simula le mosse e crea le immagini in memoria ===
def create_gif(filename, output_gif="output.gif"):
    init_blocks, moves, grid_width, grid_height = parse_file(filename)
    frames = []
    current_blocks = init_blocks.copy()
    
    # Debug: stampa tutte le mosse per verificare l'ordine
    print("Mosse in ordine:")
    for move in moves:
        print(f"Step {move[4]}: Size {move[0]}, Pos ({move[1]},{move[2]}), Dir {move[3]}")

    # Disegna la griglia iniziale
    buf = draw_grid(current_blocks, 0, grid_width, grid_height)
    frames.append(imageio.imread(buf))
    
    # Applica le mosse e crea le immagini per ogni step
    for step, (size, x, y, direction, _) in enumerate(moves, start=1):
        # Trova il blocco corretto da muovere
        block_to_move = None
        for (bx, by), bsize in list(current_blocks.items()):
            if bx == x and by == y and bsize == size:
                block_to_move = (bx, by)
                break
        
        if block_to_move:
            # Rimuovi il blocco dalla posizione originale
            del current_blocks[block_to_move]
            
            # Calcola nuove coordinate
            new_x, new_y = block_to_move[0], block_to_move[1]
            if direction == 'n' and new_y < grid_height - size: new_y += 1
            elif direction == 's' and new_y > 0: new_y -= 1
            elif direction == 'e' and new_x < grid_width - size: new_x += 1
            elif direction == 'w' and new_x > 0: new_x -= 1
            
            # Aggiungi il blocco alla nuova posizione
            current_blocks[(new_x, new_y)] = size
        
        buf = draw_grid(current_blocks, step, grid_width, grid_height)
        frames.append(imageio.imread(buf))
    
    # Salva il GIF
    imageio.mimsave(output_gif, frames, duration=600)
# === Esegui lo script ===
create_gif("../asp/tmp.asp")