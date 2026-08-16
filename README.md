# Naranjal Survival

Survival 3D en **Godot 4** con dirección visual low-poly/colorida inspirada en la claridad de juegos como *Raft*, pero ambientado en un bosque abierto.

## Estado: 0.2.7 alpha

**Demo web:** https://javidei.github.io/survival/

La demo se exporta automáticamente desde `main` mediante GitHub Actions y se publica en GitHub Pages.

Esta versión ya contiene un bucle survival jugable de base:

- pantalla de bienvenida previa al juego con tipografías pixel integradas dentro del propio proyecto;
- personaje humanoide KayKit en tercera persona;
- cámara libre/orbital con ratón y zoom con la rueda;
- movimiento relativo a la dirección de la cámara;
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
- HUD con estadísticas, recursos, receta activa, hotbar y hora del día.

## Pantalla inicial

El proyecto arranca en `scenes/intro.tscn` antes de cargar el mundo 3D.

La intro se dibuja directamente a la resolución real del viewport y desactiva antialiasing y posicionamiento subpíxel para mantener los bordes de los glifos nítidos.

En la 0.2.7 la composición usa `ONESIZE_.TTF` para **NARANJAL SURVIVAL** y **PULSA PARA CONTINUAR**, y `Windows Regular.ttf` para **BIENVENIDO A** y la línea inferior de versión. Se usa esta fuente para los textos secundarios porque es la misma fuente UI utilizada por Pixel Adventure en su exportación Web y evita los glifos deformados que estaba mostrando Commodore Pixelized.

Muestra `BIENVENIDO A`, `NARANJAL SURVIVAL`, el aviso parpadeante `PULSA PARA CONTINUAR` y `NARANJAL SURVIVAL - PROTOTIPO 0.2.7`. Cualquier tecla, clic izquierdo o toque continúa hacia el juego.

## Correcciones 0.2.7

- las animaciones KayKit ya no se copian directamente entre GLB con rutas de esqueleto incompatibles;
- las pistas de animación se retargetean en tiempo de ejecución al `Skeleton3D` real del personaje instanciado;
- se cargan las librerías `Rig_Medium_MovementBasic` y `Rig_Medium_General` para localizar idle, caminar, correr y salto;
- idle, caminar y correr se fuerzan en bucle;
- el idle se aplica inmediatamente al iniciar para evitar que jugador y NPC permanezcan en T-pose;
- `Windows Regular.ttf` sustituye a Commodore Pixelized en `BIENVENIDO A` y en la línea inferior de versión.

## Correcciones 0.2.6

- cámara orbital independiente alrededor del personaje;
- zoom con rueda de ratón;
- `floor_snap` y presión vertical para mantener jugador y NPC sobre el suelo;
- ajuste adicional de la capa visual KayKit para eliminar el pequeño desfase visible de los pies en idle;
- posición inicial del jugador más cercana al plano de suelo.

## Controles

- En la pantalla inicial: cualquier tecla, clic izquierdo o toque para continuar
- `Clic dentro del juego`: capturar el ratón y activar la cámara
- `Ratón`: orbitar la cámara horizontal y verticalmente
- `Rueda del ratón`: acercar/alejar la cámara
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

## Assets

El proyecto conserva sus sistemas propios y está incorporando progresivamente assets low-poly externos desde `assets/third_party/` para mejorar personaje, construcciones, vegetación y props sin acoplar las mecánicas directamente a los modelos originales.

## Próximos pasos

La siguiente fase debería seguir corrigiendo visualmente el escenario por tandas: vegetación y árboles, fauna, escala/ensamblado de edificios, hogueras/props y después optimización del tamaño y densidad del mundo.
