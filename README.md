# Naranjal Survival

Survival 3D en **Godot 4** con estética low-poly/cartoon, bosque abierto, crafting, construcción y supervivencia.

## Estado: 0.2.10 alpha

**Demo web:** https://javidei.github.io/survival/

La demo se exporta desde `main` mediante GitHub Actions y se publica en GitHub Pages.

## Cambios 0.2.10

Esta tanda se centra en dos problemas visuales del escenario: edificios desmontados y terreno demasiado uniforme.

- añade `settlement_refinement_pass.gd`, un pase propio que trabaja sobre el poblado generado sin modificar los GLB originales;
- sustituye en tiempo de ejecución las casas `PrefabHouse` por casas compactas de madera usando los mismos módulos Kenney;
- completa los laterales con varios paneles, reduce los huecos entre módulos y mantiene una entrada central transitable;
- aumenta ligeramente la escala final de las casas para que guarden mejor proporción con jugador y NPC;
- añade suelo interior Quaternius y ajusta el tejado sobre una planta más compacta;
- recrea colisiones sencillas alrededor de las nuevas casas sin colisión de triángulos por cada pieza;
- mantiene temporalmente solo dos aldeanos KayKit, Hugo y Elena, además del jugador;
- mejora el shader del suelo con variación de hierba a varias escalas;
- incorpora tierra y desgaste progresivo alrededor de las rutas principales, la plaza inicial y la zona de mercado;
- evita bordes duros entre hierba y las zonas transitadas usando máscaras suaves y ruido procedural;
- HUD e intro leen ahora la versión desde `application/config/version`, reduciendo desajustes de versión futuros;
- no modifica ningún archivo ni licencia dentro de `assets/third_party/`.

## Cambios conservados 0.2.9

- hotbar inferior de seis casillas con binds `1`–`6`;
- cantidad y selección resaltada;
- iconos provisionales dibujados por Godot para hacha, pico, lanza, suelo, pared y hoguera;
- intro con fuente de reserva de Godot para los textos pequeños y `ONESIZE_.TTF` para el título.

## Mundo y personajes

- jugador y NPC: KayKit Adventurers;
- árboles y rocas: Kenney Fantasy Town;
- caminos, vallas, mercado y arquitectura ligera: Kenney Fantasy Town;
- suelos interiores/plazas y props seleccionados: Quaternius;
- los assets externos se mantienen como librerías inmutables en `assets/third_party/`.

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

## Siguientes tandas

1. Sustituir la hoguera y props de supervivencia primitivos por una composición reutilizable basada en assets Quaternius/Kenney.
2. Revisar fauna y sustituir jabalí/ciervo procedural por modelos low-poly compatibles; si los packs actuales no contienen fauna adecuada, incorporar un pack específico con licencia compatible.
3. Seguir reduciendo primitivas restantes y convertir elementos repetidos en escenas reutilizables.
4. Sustituir los iconos provisionales de la hotbar por PNG definitivos cuando el estilo visual quede cerrado.
