# Naranjal Survival

Survival 3D en **Godot 4** con dirección visual low-poly/colorida inspirada en la claridad de juegos como *Raft*, pero ambientado en un bosque abierto.

## Estado: 0.2.0 alpha

**Demo web:** https://javidei.github.io/survival/

La demo se exporta automáticamente desde `main` mediante GitHub Actions y se publica en GitHub Pages.

Esta versión ya contiene un bucle survival jugable de base:

- personaje humanoide en tercera persona;
- cámara orbital, caminar, correr y saltar;
- bosque abierto generado en tiempo de ejecución;
- árboles talables con hacha y rocas picables con pico;
- drops físicos de madera, piedra y carne;
- inventario con materiales, comida, herramientas y piezas de construcción;
- hotbar de seis huecos;
- crafting de hacha, pico, lanza, suelo, pared y hoguera;
- vida, hambre y sed con deterioro progresivo;
- bayas comestibles y estanque de agua potable;
- ciclo día/noche completo con oscurecimiento del entorno;
- construcción modular con previsualización fantasma y rotación;
- hogueras que permiten cocinar carne cruda;
- fauna que deambula por el bosque;
- jabalíes hostiles con persecución, daño y drops de carne;
- HUD con estadísticas, recursos, receta activa, hotbar y hora del día;
- cabaña abandonada y entorno stylized con niebla e iluminación cálida.

## Controles

- `WASD`: movimiento
- `Shift`: correr
- `Espacio`: saltar
- `Ratón`: cámara
- `E`: recoger / beber / cocinar / interactuar
- `Clic izquierdo`: usar herramienta, atacar o colocar una construcción
- `1`–`6`: seleccionar hotbar
- `C`: fabricar la receta activa
- `V`: cambiar de receta
- `F`: comer comida disponible
- `R`: girar la pieza de construcción
- `Esc`: liberar/capturar el ratón

## Hotbar

1. Hacha
2. Pico
3. Lanza
4. Suelo
5. Pared
6. Hoguera

Los huecos muestran también cuántas unidades tienes. Las herramientas deben fabricarse antes de poder usarse.

## Bucle actual

1. Recoge recursos sueltos para fabricar las primeras herramientas.
2. Fabrica un hacha y un pico.
3. Tala árboles y pica rocas para conseguir materiales mediante drops físicos.
4. Fabrica suelos, paredes y una hoguera.
5. Construye un pequeño refugio.
6. Bebe en el estanque y come bayas para mantener hambre y sed.
7. Fabrica una lanza para defenderte de los jabalíes.
8. Cocina la carne obtenida de animales en una hoguera.
9. Sobrevive al ciclo completo de día y noche.

## Filosofía de arte

La base sigue sin depender de modelos descargados ni licencias externas. Los props, animales, construcciones y personaje están formados con primitivas 3D y materiales simples de Godot. Esto nos permite desarrollar primero la jugabilidad y sustituir progresivamente cada elemento por assets definitivos sin rehacer los sistemas.

## Próximos pasos

La siguiente fase debería mejorar calidad y profundidad en lugar de añadir sistemas nuevos a ciegas: animaciones de herramientas y combate, guardado/carga, construcción con comprobación de colisiones, mejor IA, clima, audio, modelos definitivos y optimización del bosque.
