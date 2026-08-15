# Naranjal Survival

Survival 3D en **Godot 4** con dirección visual low-poly/colorida inspirada en la claridad de juegos como *Raft*, pero ambientado en un bosque abierto.

## Estado: 0.2.6 alpha

**Demo web publicada actualmente:** https://javidei.github.io/survival/

La demo se exporta automáticamente desde `main` mediante GitHub Actions y se publica en GitHub Pages. Los cambios de la 0.2.6 están preparados en su rama hasta validar y publicar la versión.

Esta versión ya contiene un bucle survival jugable de base:

- pantalla de bienvenida previa al juego con tipografías pixel integradas dentro del propio proyecto;
- personaje humanoide en tercera persona;
- cámara libre/orbital con ratón, caminar, correr y saltar;
- movimiento relativo a la dirección de la cámara;
- bosque abierto generado en tiempo de ejecución;
- terreno con texturas stylized repetibles de hierba, tierra, barro y roca;
- campamento inicial con suelo de tierra diferenciado;
- orilla embarrada alrededor del estanque;
- árboles talables con hacha y rocas picables con pico;
- rocas, piedras del sendero y piedras de hoguera con material texturizado;
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

## Texturas de terreno

Las texturas están en:

```text
assets/textures/terrain/
├── grass.svg
├── dirt.svg
├── mud.svg
├── rock.svg
└── SOURCES.md
```

Son texturas tileables muy ligeras creadas para el propio proyecto. El terreno principal repite la hierba en vez de estirar una única imagen; el campamento utiliza tierra; el estanque tiene una corona de barro y los elementos de piedra usan la textura de roca.

En `SOURCES.md` quedan documentadas también las bibliotecas CC0 revisadas como referencia: Voxel Core Lab, OpenGameArt y ambientCG.

## Pantalla inicial

El proyecto arranca en `scenes/intro.tscn` antes de cargar el mundo 3D.

La 0.2.5 eliminó el reescalado previo a 320×180 que podía suavizar la letra en navegador. La intro se dibuja directamente a la resolución real del viewport y desactiva antialiasing y posicionamiento subpíxel para mantener los bordes de los glifos totalmente nítidos.

La composición usa los TTF pixel proporcionados por el proyecto: `ONESIZE_.TTF` para **NARANJAL SURVIVAL** y **PULSA PARA CONTINUAR**, y `ONESR___.TTF` para **BIENVENIDO A** y la línea de versión. Ambas fuentes se renderizan como bitmaps de 1 bit, sin interpolación.

Muestra `BIENVENIDO A`, `NARANJAL SURVIVAL`, el aviso parpadeante `PULSA PARA CONTINUAR` y `NARANJAL SURVIVAL - PROTOTIPO 0.2.6`. Cualquier tecla, clic izquierdo o toque continúa hacia el juego.

## Controles

- En la pantalla inicial: cualquier tecla, clic izquierdo o toque para continuar
- `Clic dentro del juego`: capturar el ratón y activar la cámara
- `Ratón`: girar la cámara horizontal y verticalmente
- `WASD`: movimiento relativo a donde estás mirando
- `Shift`: correr
- `Espacio`: saltar
- `E`: recoger / beber / cocinar / interactuar
- `Clic izquierdo` con el ratón capturado: usar herramienta, atacar o colocar una construcción
- `1`–`6`: seleccionar hotbar
- `C`: fabricar la receta activa
- `V`: cambiar de receta
- `F`: comer comida disponible
- `R`: girar la pieza de construcción
- `Esc`: liberar el ratón; vuelve a hacer clic para recuperar la cámara

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

El proyecto mantiene un estilo stylized y ligero para que la versión Web siga siendo viable. Los props, animales, construcciones y personaje continúan formados principalmente con primitivas 3D de Godot, mientras el terreno empieza a incorporar materiales propios repetibles. Esto permite mejorar progresivamente el apartado visual sin rehacer los sistemas de juego.

## Próximos pasos

La siguiente fase debería mejorar calidad y profundidad: mezcla más orgánica entre tipos de terreno, animaciones de herramientas y combate, guardado/carga, construcción con comprobación de colisiones, mejor IA, clima, audio, modelos definitivos y optimización del bosque.
