import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Dimensioni della griglia
max_width = 5
max_height = 6

# Dati dei blocchi finali (da file o stringa)
asp_output = """
init_block(b1,1,2,0).
init_block(b2,1,3,0).
init_block(b3,2,0,0).
"""

def parse_blocks(asp_output):
    blocks = []
    for line in asp_output.splitlines():
        line = line.strip()
        if line.startswith("init_block"):
            # Parsing del predicato
            parts = line[line.index("(") + 1:line.index(")")].split(",")
            block_id = parts[0]
            dim = int(parts[1])
            x = int(parts[2])
            y = int(parts[3])
            blocks.append((block_id, dim, x, y))
    return blocks

def draw_grid(blocks, max_width, max_height):
    fig, ax = plt.subplots(figsize=(6, 8))
    ax.set_xlim(0, max_width)
    ax.set_ylim(0, max_height)
    ax.set_aspect('equal')

    # Disegna la griglia
    for x in range(max_width + 1):
        ax.axvline(x, color='gray', linewidth=0.5)
    for y in range(max_height + 1):
        ax.axhline(y, color='gray', linewidth=0.5)

    # Disegna i blocchi
    for block_id, dim, x, y in blocks:
        rect = patches.Rectangle((x, y), dim, dim, linewidth=1, edgecolor='black', facecolor='lightblue')
        ax.add_patch(rect)
        ax.text(x + dim / 2, y + dim / 2, block_id, color='black', ha='center', va='center')

    # Etichette e assi
    ax.set_xticks(range(max_width + 1))
    ax.set_yticks(range(max_height + 1))
    ax.grid(False)
    ax.set_xlabel('X')
    ax.set_ylabel('Y')
    plt.gca()
    plt.show()

# Parsing e visualizzazione
blocks = parse_blocks(asp_output)
draw_grid(blocks, max_width, max_height)
