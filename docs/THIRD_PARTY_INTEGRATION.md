# Inventario e integración de assets 3D

Este documento describe la pasada visual sobre `agent/third-party-world-pass`. Los archivos bajo `assets/third_party/` se consideran librerías externas y no se modifican.

## Estado previo del juego

### Personaje

- `scenes/player/player.tscn`: `CharacterBody3D` con cápsula de colisión, cámara en `SpringArm3D` e `InteractionArea`.
- Visual humanoide construido con `BoxMesh`, `SphereMesh` y `CapsuleMesh`.
- `scripts/player/player_controller.gd`: movimiento, cámara, interacción, harvesting, combate y construcción.
- `scripts/player/avatar_animator.gd`: animación procedural de brazos y piernas.

### Entorno

- `scripts/world/world_builder.gd` crea el bosque en tiempo de ejecución.
- Árboles recolectables: tronco y copas mediante `CylinderMesh`.
- Rocas recolectables: `SphereMesh` deformada.
- Arbustos y flores: primitivas simples.
- Cabaña abandonada: cajas/prismas generados por código.
- Estanque: cilindro de agua y piedras primitivas.
- Recursos sueltos: cilindros/esferas.
- Fauna: `CharacterBody3D` generados por `wildlife.gd`.

### Campamento y props

- `scripts/world/world_details.gd` crea campamento inicial, hoguera, refugio, camino, valla, troncos, carteles y faroles mediante primitivas.
- `scripts/systems/build_system.gd` mantiene suelo, pared y hoguera construibles con colisiones y preview propio.
- `scripts/world/physical_drop.gd` representa madera, piedra y carne con primitivas.

## Librerías revisadas

### Kenney Fantasy Town

Se prioriza para exterior por su estilo low-poly limpio y ligero. Elementos seleccionados:

- `tree.glb`, `tree-high.glb`, `tree-crooked.glb`, `tree-high-round.glb`
- `rock-small.glb`, `rock-wide.glb`, `rock-large.glb`
- `fence.glb`, `fence-broken.glb`, `fence-gate.glb`
- `road.glb`, `road-bend.glb`
- `wall-wood.glb`, `wall-wood-door.glb`, `wall-wood-window-shutters.glb`, cubiertas de tejado
- `lantern.glb`, `cart.glb`, `stall-bench.glb`

### Quaternius Fantasy Props MegaKit

Se prioriza para campamento, herramientas y decoración:

- `Barrel.gltf`
- `Crate_Wooden.gltf`
- `Chest_Wood.gltf`
- `Workbench.gltf`
- `Bench.gltf`
- `Axe_Bronze.gltf`
- `Pickaxe_Bronze.gltf`
- `Cauldron.gltf`
- `Bucket_Wooden_1.gltf`, `Bag.gltf`, `Rope_1.gltf`, `Lantern_Wall.gltf`

### Quaternius Medieval Village MegaKit

Se conserva como biblioteca para una futura ampliación modular de edificios. La primera pasada no mezcla masivamente sus módulos con Kenney para evitar diferencias de escala/material y demasiados nodos por edificio.

### KayKit Adventurers

- Personajes: Barbarian, Knight, Mage, Ranger, Rogue y Rogue Hooded.
- Animaciones separadas para `Rig_Medium`: `Rig_Medium_General.glb` y `Rig_Medium_MovementBasic.glb`.
- Se prepara un personaje alternativo de prueba; el jugador principal no se sustituye hasta validar rig, escala, clips y retargeting sin afectar cámara o colisión.

## Criterio visual

- Kenney domina exterior, vegetación dura y arquitectura sencilla.
- Quaternius Fantasy Props se usa para objetos cercanos al jugador y puntos de interés.
- El arte procedural actual se mantiene como fallback y para elementos que aún no tienen un reemplazo claramente mejor.
- No se modifican licencias ni archivos de los packs.
