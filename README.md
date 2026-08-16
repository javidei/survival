# Naranjal Survival

Survival 3D en **Godot 4** con dirección visual low-poly/colorida inspirada en la claridad de juegos como *Raft*, pero ambientado en un bosque abierto.

## Estado: 0.2.8 alpha

**Demo web:** https://javidei.github.io/survival/

La demo pública se exporta automáticamente desde `main` mediante GitHub Actions y se publica en GitHub Pages. Mientras la 0.2.8 permanezca en rama de prueba, la URL pública seguirá mostrando la última versión fusionada.

Esta versión mantiene el bucle survival jugable de base:

- pantalla de bienvenida previa al juego con tipografías pixel integradas;
- personaje humanoide KayKit en tercera persona con idle, caminar y correr;
- cámara libre/orbital con ratón y zoom con la rueda;
- movimiento relativo a la dirección de la cámara;
- árboles talables con hacha y rocas picables con pico;
- drops físicos de madera, piedra y carne;
- inventario, hotbar y crafting;
- vida, hambre y sed;
- ciclo día/noche;
- construcción modular;
- hogueras para cocinar;
- fauna y NPC;
- HUD de supervivencia.

## Cambios 0.2.8

Esta tanda se centra en limpiar el escenario antes de tocar fauna y edificios:

- `BIENVENIDO A` y la línea inferior de versión usan `Windows Regular.ttf` sin forzar rasterizado de 1 bit, con colores y tamaños más visibles para Web;
- el generador principal deja de crear los 165 árboles, 68 rocas y 110 arbustos hechos con primitivas;
- añade un pase de bosque propio basado en los modelos Kenney Fantasy Town `tree`, `tree-high`, `tree-crooked`, `tree-high-crooked` y `tree-high-round`;
- crea 56 árboles Kenney recolectables repartidos en siete grupos naturales en vez de una nube completamente aleatoria;
- añade 14 árboles jóvenes decorativos sin scripts ni físicas individuales;
- crea 18 rocas recolectables usando `rock-small`, `rock-large` y `rock-wide` de Kenney;
- conserva espacios abiertos alrededor de la zona inicial y de los recorridos principales;
- reduce el radio de generación de 92 a 68 metros;
- reduce el plano físico principal de 220 × 220 a 160 × 160 metros;
- reduce temporalmente la fauna procedural a 4 animales pasivos y 2 hostiles;
- mantiene temporalmente solo 2 aldeanos KayKit para facilitar las pruebas visuales y de rendimiento;
- conserva intactos los archivos originales y licencias dentro de `assets/third_party/`.

## Pantalla inicial

El proyecto arranca en `scenes/intro.tscn` antes de cargar el mundo 3D.

- **NARANJAL SURVIVAL** y **PULSA PARA CONTINUAR**: `ONESIZE_.TTF`.
- **BIENVENIDO A** y **NARANJAL SURVIVAL - PROTOTIPO 0.2.8**: `Windows Regular.ttf`.

Los dos textos secundarios se dibujan con un gris lavanda más claro y con mayor tamaño para que sigan siendo legibles sobre el fondo negro en la exportación Web.

## Correcciones conservadas de 0.2.7

- las pistas de movimiento KayKit se retargetean al `Skeleton3D` real de cada personaje;
- idle, caminar y correr funcionan en bucle;
- el idle se aplica al iniciar, evitando la T-pose de jugador y NPC.

## Controles

- En la pantalla inicial: cualquier tecla, clic izquierdo o toque para continuar
- `Clic dentro del juego`: capturar el ratón
- `Ratón`: orbitar la cámara
- `Rueda`: zoom
- `WASD`: movimiento
- `Shift`: correr
- `Espacio`: saltar
- `E`: interactuar
- `Clic izquierdo`: usar herramienta, atacar o colocar construcción
- `1`–`6`: seleccionar hotbar
- `C`: fabricar
- `V`: cambiar receta
- `F`: comer
- `R`: girar construcción
- `Esc`: liberar el ratón

## Hotbar

1. Hacha
2. Pico
3. Lanza
4. Suelo
5. Pared
6. Hoguera

## Assets

Los modelos externos se tratan como librerías inmutables dentro de `assets/third_party/`. La lógica del juego sigue viviendo en escenas y scripts propios, de modo que podamos cambiar o ajustar el aspecto sin acoplar la recolección, construcción o supervivencia a un archivo GLB concreto.

En la 0.2.8 el bosque utiliza principalmente **Kenney Fantasy Town** para árboles y rocas. KayKit sigue siendo la base de jugador/NPC. Quaternius sigue disponible para construcciones, herramientas y props en las siguientes tandas.

## Siguientes tandas recomendadas

1. Mejorar el terreno/hierba y eliminar las manchas planas que todavía se ven cerca del poblado.
2. Sustituir ciervos y jabalíes procedurales por modelos de asset compatibles si los packs disponibles contienen fauna adecuada.
3. Corregir escala y ensamblado de los edificios del poblado.
4. Sustituir la hoguera y props primitivos restantes por assets de Quaternius/Kenney.
