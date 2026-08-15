# Naranjal Survival

Base jugable de un survival 3D en **Godot 4**, con una dirección visual low-poly/colorida inspirada en la claridad y legibilidad de juegos como *Raft*, pero ambientado en un bosque abierto.

## Estado: 0.1.0

La primera versión incluye:

- personaje en tercera persona;
- cámara orbital con ratón;
- caminar, correr y saltar;
- bosque abierto generado en tiempo de ejecución;
- árboles, rocas, arbustos, flores y una pequeña cabaña abandonada;
- recursos recogibles de madera, piedra y fibra;
- interacción con `E`;
- inventario base visible en HUD;
- iluminación, cielo, niebla y paleta de color stylized;
- estructura preparada para añadir crafting, hambre/sed, herramientas y construcción.

## Controles

- `WASD`: movimiento
- `Shift`: correr
- `Espacio`: saltar
- `Ratón`: cámara
- `E`: recoger/interactuar
- `Esc`: liberar/capturar el ratón

## Filosofía de arte

La versión inicial no depende de modelos descargados ni de licencias externas. Los props del mundo se construyen con primitivas 3D de Godot y materiales simples, lo que permite trabajar primero la jugabilidad y sustituir progresivamente cada elemento por assets definitivos.

## Próximo objetivo

La siguiente iteración debería centrarse en **inventario real + hotbar + herramientas + recolección activa** (golpear árboles y rocas), antes de entrar en supervivencia, crafting y construcción.
