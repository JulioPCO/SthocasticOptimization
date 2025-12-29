import matplotlib.pyplot as plt
import numpy as np

# Pontos extremos (vértices da base)
p1 = np.array([2, 4])
p2 = np.array([4, 2])
p3 = np.array([10/3, 4/3])

# Coordenadas do triângulo-base
triangle_x = [p1[0], p2[0], p3[0], p1[0]]
triangle_y = [p1[1], p2[1], p3[1], p1[1]]

plt.figure(figsize=(6,8))

# Triângulo-base
plt.plot(triangle_x, triangle_y, 'b-', label='Base (triângulo)')
plt.fill(triangle_x, triangle_y, color='lightblue', alpha=0.3)

# Pontos extremos
plt.scatter([p1[0], p2[0], p3[0]], [p1[1], p2[1], p3[1]], color='red', label='Pontos extremos', zorder=5)

# Raios extremos: setas verticais a partir de cada ponto do triângulo
for p in [p1, p2, p3]:
    plt.arrow(p[0], p[1], 0, 6, head_width=0.1, head_length=0.3, fc='green', ec='green', length_includes_head=True)

# Configurações do gráfico
plt.xlabel('p1')
plt.ylabel('p2')
plt.title('Conjunto D com pontos extremos e raio extremo (0,1)')
plt.grid(True)
plt.xlim(0, 5)
plt.ylim(0, 12)
plt.legend()
plt.show()
