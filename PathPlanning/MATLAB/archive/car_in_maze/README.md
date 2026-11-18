# Archiv: Car in Maze (frühere Fassung von Kapitel 08)

Der Prof hat Kapitel 08 umgebaut: statt "Auto im Labyrinth" (Gitterweg wird nur
animiert) gibt es jetzt `tasks/car_primitives.m` und `tasks/car_neighbors.m`
(Fahrzeugmodell im Nachbarn-Schritt). Die alten Hilfsfunktionen
`animate_car_grid.m` und `check_car_maze.m` sind deshalb aus `tools/` und
`checks/` verschwunden.

Damit die eigene Lösung weiter läuft, liegt alles zusammen hier und ist
**nicht** auf dem Standardpfad (`setup_path` kennt diesen Ordner nicht):

| Datei | Inhalt |
|---|---|
| `car_in_maze.m` | eigene Lösung (planen, leeren Weg abfangen, animieren) |
| `animate_car_grid.m`, `check_car_maze.m` | Originale aus dem früheren Stand des Profs (unverändert) |
| `experiment_car_maze.m` | Experiment mit Antworten |
| `LS08_CarInMaze.m` | Live Script dazu |

Benutzen (Current Folder = `PathPlanning/MATLAB`):

```matlab
setup_path
addpath(fullfile(pwd, 'archive', 'car_in_maze'))
check_car_maze
run(fullfile('archive', 'car_in_maze', 'experiment_car_maze.m'))
```
