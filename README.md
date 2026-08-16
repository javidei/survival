# Naranjal Survival

Survival 3D en **Godot 4** con estética low-poly/cartoon, bosque abierto, crafting, construcción y supervivencia.

## Estado: 0.2.11 alpha

**Demo web:** https://javidei.github.io/survival/

La demo se exporta desde `main` mediante GitHub Actions y se publica en GitHub Pages.

## Cambios 0.2.11

Esta versión abandona el montaje visual anterior del escenario y rehace la base del bosque y del poblado para que el cambio sea visible a primera vista.

- desactiva del `main.tscn` los generadores visuales antiguos `WorldDetails`, `AssetWorldDecorator`, `ForestAssetPass` y `SettlementRefinementPass`;
- añade `world_visual_overhaul.gd` como único pase de decoración principal;
- genera hasta 1850 matas de hierba 3D mediante `MultiMesh`, con altura, orientación y tono variables;
- evita hierba dentro de caminos, viviendas, zona inicial y estanque para que las transiciones se lean mejor;
- sustituye los árboles cónicos/Kenney anteriores por árboles propios de copa ancha formados por tronco y cinco masas de hojas low-poly;
- mantiene 44 árboles recolectables repartidos en siete grupos alrededor del área jugable;
- sustituye las casas modulares abiertas por cuatro casas completas y compactas con cuerpo, cimentación, entramado de madera, cubierta, puerta, ventanas, porche, chimenea y colisión única;
- crea caminos y claros de tierra con piezas irregulares superpuestas sobre el terreno;
- añade rocas y arbustos de apoyo sin llenar de objetos la zona inicial;
- reduce recursos sueltos y fauna temporal para limpiar visualmente la escena mientras se define el estilo final;
- mantiene solo dos NPC KayKit en esta fase;
- rehace el shader de terreno con variación más marcada de verde, zonas secas, pequeñas manchas de tierra y un relieve visual muy suave;
- mejora luz ambiente, sol y niebla para ganar contraste y profundidad;
- conserva intactas las mecánicas de movimiento, inventario, crafting, construcción, supervivencia y recolección.

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

1. Revisar visualmente esta nueva base y ajustar densidad/tamaño de hierba, árboles y viviendas si hace falta.
2. Sustituir la hoguera y los props de supervivencia primitivos por una composición reutilizable coherente con el nuevo entorno.
3. Sustituir la fauna procedural por modelos low-poly compatibles con el estilo definitivo.
4. Seguir reduciendo primitivas restantes y sustituir los iconos provisionales de la hotbar por arte definitivo.
