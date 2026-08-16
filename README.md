# Naranjal Survival

Survival 3D en **Godot 4** con dirección visual low-poly/colorida, bosque abierto, crafting, construcción y supervivencia.

## Estado: 0.2.9 alpha

**Demo web:** https://javidei.github.io/survival/

La demo se exporta desde `main` mediante GitHub Actions y se publica en GitHub Pages.

## Cambios 0.2.9

Esta tanda se centra en la interfaz de juego y en hacer robusta la pantalla inicial:

- sustituye la hotbar de texto inferior por seis casillas visuales inspiradas en la lectura rápida de juegos survival como Valheim;
- mantiene los binds `1`–`6` visibles en la esquina de cada casilla;
- muestra la cantidad disponible de cada herramienta o pieza de construcción;
- resalta claramente el slot seleccionado;
- añade iconos provisionales dibujados directamente por Godot para hacha, pico, lanza, suelo, pared y hoguera;
- los iconos no dependen de PNG ni de glifos de una fuente, por lo que después pueden sustituirse por sprites definitivos sin cambiar la lógica de inventario;
- muestra encima de la hotbar el nombre y la cantidad del objeto seleccionado;
- `BIENVENIDO A`, `PULSA PARA CONTINUAR` y la línea de versión usan ahora `ThemeDB.fallback_font`, la fuente de reserva del motor, para evitar que una TTF externa mal importada deje textos invisibles o corruptos en Web;
- `NARANJAL SURVIVAL` conserva por ahora `ONESIZE_.TTF`, ya que el título grande sí se estaba renderizando correctamente;
- la pantalla inicial muestra `NARANJAL SURVIVAL - PROTOTIPO 0.2.9`.

## Cambios conservados 0.2.8

- bosque basado en árboles reales de Kenney Fantasy Town;
- árboles recolectables agrupados de forma natural;
- rocas Kenney recolectables;
- mapa reducido a 160 × 160 m para esta fase de pruebas;
- fauna y NPC reducidos temporalmente para facilitar evaluación visual y rendimiento;
- archivos y licencias de `assets/third_party/` sin modificar.

## Correcciones conservadas 0.2.7

- idle, caminar y correr KayKit retargeteados al esqueleto real;
- eliminación de la T-pose de jugador y NPC;
- cámara orbital y zoom con rueda.

## Controles

- Cualquier tecla, clic izquierdo o toque: continuar desde la intro
- Clic dentro del juego: capturar el ratón
- Ratón: orbitar la cámara
- Rueda: zoom
- `WASD`: movimiento
- `Shift`: correr
- `Espacio`: saltar
- `E`: interactuar
- Clic izquierdo: usar herramienta, atacar o colocar construcción
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

Los assets externos siguen tratándose como librerías inmutables dentro de `assets/third_party/`. La lógica propia del juego permanece en `scenes/` y `scripts/`.

Actualmente se utilizan KayKit para jugador/NPC y Kenney Fantasy Town para buena parte del bosque y las rocas. Los packs Quaternius quedan disponibles para continuar sustituyendo props, herramientas y construcciones primitivas.

## Siguientes tandas

1. Mejorar terreno/hierba y transición entre caminos/plazas y bosque.
2. Revisar fauna: los packs cargados actualmente no muestran un modelo de ciervo/jabalí evidente; si no hay uno compatible, habrá que añadir un pack de animales low-poly específico.
3. Corregir escala y ensamblado de edificios.
4. Mejorar la hoguera y los props de supervivencia usando los modelos disponibles de Quaternius, como caldero, antorcha y herramientas.
5. Sustituir los iconos provisionales de la hotbar por PNG definitivos cuando el estilo quede decidido.
