# Backlog

### MDX-001 · Elegir la base de datos de las System APIs
- Tipo: investigación
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero elegir el motor de base de datos de las 6 System APIs para poder guardar los datos de `contratos/datos.md`.
- Criterios de aceptación:
  - [ ] Se eligió PostgreSQL o MySQL, con la razón escrita en una línea.
  - [ ] El motor corre en Docker, con un archivo en el repositorio que lo levanta igual cada vez.
  - [ ] Quedó decidido si cada System API tiene su propia base de datos o su propio esquema en el mismo servidor; en los dos casos cada API solo toca lo suyo.
  - [ ] Desde Studio se probó una conexión con el conector Database (una consulta simple que responde).
  - [ ] La decisión quedó en el README, sección «Tecnología».
- Notas: No está decidido en el diseño. Cada System API es dueña de su base de datos (arquitectura API-led). Ya tiene Docker y conectó antes a PostgreSQL y a MySQL; sin preferencia. H2 descartada (se borra al apagar la app; las pruebas MUnit simulan la base con `mock-when`). Estimada contra MDX-008 (patrón de 3 puntos).

### MDX-002 · Elegir ActiveMQ Classic o Artemis y levantarlo en local
- Tipo: investigación
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el broker corriendo en mi máquina para conectar las apps de Mule por JMS.
- Criterios de aceptación:
  - [ ] Se compararon Classic y Artemis en 5 puntos: mensaje diferido (alarmas de 5 y 2 min, decisiones 48 y 49), expiración (aviso de 5 min), cola de mensajes muertos (decisiones 42 y 57), consola web para enviar órdenes y mirar, mover o relanzar mensajes (decisión 42) y conexión con el conector JMS de Mule; cada respuesta con su fuente oficial.
  - [ ] Se eligió uno y la razón quedó escrita en una línea.
  - [ ] El broker corre en Docker con un archivo en el repositorio (puede ser el mismo de MDX-001).
  - [ ] Desde Studio se publicó un mensaje en una cola de prueba y otro flujo lo leyó.
  - [ ] Se abrió la consola web y se vio el mensaje de prueba en la cola.
  - [ ] La decisión quedó en el README, sección «Tecnología».
- Notas: Anypoint MQ no está disponible. Pruebas pendientes de la bitácora: advisories de mensajes muertos (decisión 57) y cómo se pone el retraso del mensaje diferido desde JMS. Nada de memoria: esta historia investiga con fuentes. Estimada contra MDX-008 (mismo tamaño).

### MDX-003 · Crear en el broker las colas y temas de la tabla de canales
- Tipo: tarea
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero las colas y temas creados en el broker para que las apps puedan publicar y escuchar.
- Criterios de aceptación:
  - [ ] Están creados todos los canales de la tabla (copia abajo), y cada tema tiene sus colas colgadas: un mensaje publicado en el tema llega a todas ellas.
  - [ ] `avisos.{id_tienda}` y `control.{pieza}` están creados para la tienda de prueba del pedido 101 y para cada pieza con cola de control (`endpoints.md`, paso 8 B).
  - [ ] La configuración está en un archivo del repositorio: al levantar Docker de nuevo, los canales quedan iguales.
  - [ ] Desde la consola web se ve cada canal.
  - [ ] Se probó un tema: un mensaje publicado en `pedidos.estado` llegó a sus dos colas.
- Notas: Depende de MDX-002 (cómo se cuelga una cola de un tema cambia según el broker; ⚠️ verificar en su documentación). Aquí se le explica cómo se montan y conectan colas y temas al desplegar (pedido suyo para la fase 4). Estimada contra MDX-008 (mismo tamaño). Copia de la tabla de canales (`endpoints.md`):

  | Canal | Tipo | Colas que cuelgan del tema |
  |---|---|---|
  | `pedidos.nuevos` | cola | — |
  | `avisos.{id_tienda}` | tema, uno por tienda | `avisos.{id_tienda}.gerente`, `avisos.{id_tienda}.empleados` |
  | `pedidos.respuestas` | cola | — |
  | `pedidos.entregas` | tema | `pedidos.entregas.pedido`, `pedidos.entregas.repartidor` |
  | `pedidos.vencimientos` | cola (retraso de 5 min) | — |
  | `ofertas.vencimientos` | cola (retraso de 2 min) | — |
  | `pedidos.estado` | tema | `pedidos.estado.notificar`, `pedidos.estado.portal` |
  | `pedidos.cierre` | cola | — |
  | `pedidos.cerrado` | cola | — |
  | `pedidos.listo` | tema | (hoy solo `gestionar-repartidor-papi`) |
  | `repartidores.ofertas` | cola compartida | — |
  | `catalogo.cargas` | cola | — |
  | `monitoreo.pedidos` | cola | — |
  | `mensajes-muertos` | tema | `mensajes-muertos.soporte`, `mensajes-muertos.aviso` |
  | `control.{pieza}` | cola, una por pieza | — |
  | `control.respuestas` | cola | — |

### MDX-004 · Publicar en Exchange los fragments comunes
- Tipo: tarea
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero los fragments de `raml/comun/` en Exchange para que los RAML de las APIs los usen desde ahí.
- Criterios de aceptación:
  - [ ] Se verificó en la documentación de MuleSoft cómo se publica un conjunto de fragments y cómo lo usa una API (tipo de asset y forma de la ruta), con la fuente anotada.
  - [ ] `comun` está publicado en Exchange con versión `1.0.0`.
  - [ ] Una API de prueba que lo usa como dependencia valida sin errores en Design Center, con al menos un tipo, un trait y un ejemplo.
  - [ ] Se anotó qué líneas exactas cambiarán en los 15 RAML (el cambio se hace en MDX-005 para System; Process y Experience más adelante).
- Notas: Fuente: `../contratos/raml/comun/`. **Decisión de ella (2026-11-18): opción A**, `comun` como un solo asset en Exchange que cada API declara como dependencia (mantiene «un solo tipo por objeto»; descartada la B, copiar `comun/` en cada API). Hoy los RAML usan rutas relativas (`../../comun/...`) que en Exchange no funcionan: solo cambian las líneas `uses:` y `!include`. Antes de publicar: confirmar si sobra `ejemplos/resultado-pedido.raml` (el tipo `ResultadoPedido` se eliminó el 2026-11-12). ⚠️ Forma de la ruta de la dependencia por verificar. Estimada contra MDX-008 (mismo tamaño).

### MDX-005 · Publicar en Exchange los 6 RAML de System
- Tipo: tarea
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero los RAML de System publicados en Exchange para generar el esqueleto de cada app en Studio.
- Criterios de aceptación:
  - [ ] En los 6 RAML de System se cambiaron solo las líneas `uses:` y `!include` para apuntar a la dependencia `comun` 1.0.0 (las anotadas en MDX-004).
  - [ ] Cada una de las 6 valida sin errores en Design Center.
  - [ ] Las 6 están publicadas en Exchange (API `v1`, asset `1.0.0`).
  - [ ] La copia de `contratos/raml/system/` es igual a lo publicado; si hubo que corregir algo, se corrigió primero en la carpeta.
  - [ ] Desde Studio se encuentra al menos una de las 6 en Exchange (la usa MDX-007).
- Notas: Fuente: `../contratos/raml/system/`. Requisito del plugin `construir-flujo` (C3: el esqueleto sale de Exchange). Regla aprobada por ella (2026-11-18): **la copia de la carpeta manda**; todo cambio se hace primero ahí, se valida y después se sube. **Depende de MDX-004: si la dependencia `comun` (opción A) no es posible, esta historia tampoco se puede hacer así y se evalúan las dos en su momento** (nota de ella). ⚠️ Con las rutas nuevas el plugin `validar-raml` puede dejar de encontrar `comun` (quizá necesite la dependencia descargada en local); si no se resuelve, cuenta la validación de Design Center. Estimada contra MDX-008 (mismo tamaño).

### MDX-006 · clientes-sapi: crear el proyecto desde Exchange, su base de datos y la estructura de errores
- Tipo: tarea
- Estado: lista
- Puntos: 5
- Sprint: —
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el proyecto de `clientes-sapi` generado desde su RAML de Exchange, conectado a su base de datos y con el manejo de errores global, para empezar a construir sus endpoints y reutilizar los errores en las demás APIs.
- Criterios de aceptación:
  - [ ] El proyecto `clientes-sapi` se generó en Studio desde su RAML de Exchange y arranca en el puerto 8081.
  - [ ] Está conectado a su base de datos (la de MDX-001).
  - [ ] Cada error responde con su código y el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`): 400 `solicitud-invalida`, 401 `no-autorizado`, 404 `no-encontrado`, 500 `error-interno`; el `mensaje` no trae datos internos. La plantilla incluye también el 409 (`Conflicto`, con `objeto_actual` opcional) para las APIs que lo usan.
  - [ ] La C6 quedó decidida con el esqueleto delante y anotada.
  - [ ] Si la llamada trae `X-Correlation-ID`, ese valor aparece en el log y en el cuerpo de los errores; si no lo trae, Mule genera uno y pasa lo mismo.
  - [ ] En local la API exige `client_id` y `client_secret` en los encabezados (APIkit) y funciona con valores cualquiera; quedó anotado qué responde si faltan.
  - [ ] Hay pruebas MUnit en verde para un 404, un 500 y el correlation ID (con encabezado y sin él).
  - [ ] El manejo de errores quedó separado como plantilla, con una nota de cómo se agrega a una API nueva.
- Notas: Puerto 8081. RAML: `../contratos/raml/system/clientes-sapi/`. Depende de MDX-001 y MDX-005. Reúne la antigua plantilla de errores y la antigua MDX-007 (pedido de ella, 2026-11-18). Decisiones C1 a C5 del plugin `construir-flujo` (errores globales por app + específicos por flujo, con la estructura `Error`); C6 abierta. Reglas 3, 8 y 9 de `../contratos/reglas-raml.md`. Client ID en local (contexto de `mulesoft-coach`, `videos/serie-1.md`, sesión 3): la política Client ID enforcement solo existe en API Manager con API Autodiscovery; en local el APIkit Router exige los encabezados del trait `seg-cliente`. ⚠️ Si faltan, probablemente responde 400 (no 401): confirmar con el esqueleto. 409 (2026-11-18): un solo trait `conflicto` con el tipo `Conflicto`; trae `objeto_actual` (Pedido, Oferta o Carga) solo cuando el objeto pudo cambiar antes; va solo en los endpoints que pueden dar 409 (no en `errores-comunes`). `clientes-sapi` no tiene 409: se prueba en la primera API que lo tenga. 5 puntos (aprobado el 2026-11-18).

### MDX-007 · clientes-sapi: crear el proyecto desde Exchange y su base de datos
- Tipo: tarea
- Estado: descartada
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: 2026-11-18
- Historia: Como desarrolladora quiero el proyecto de `clientes-sapi` generado desde su RAML de Exchange y conectado a su base de datos para empezar a construir sus endpoints.
- Criterios de aceptación:
- Notas: Descartada el 2026-11-18: se unió con MDX-006 (pedido de ella: la 006 levanta `clientes-sapi` con la estructura de errores).

### MDX-008 · clientes-sapi: GET /clientes/{id_cliente}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero leer el cliente con sus direcciones para copiar `cliente` y `direccion_entrega` al pagar (decisión 50).
- Criterios de aceptación:
  - [ ] `GET /clientes/cli-12` responde 200 con el cliente y todas sus direcciones, en la forma del ejemplo.
  - [ ] `GET /clientes/no-existe` responde 404 con `codigo: no-encontrado`, un `mensaje` sin datos internos y la `correlacion`.
  - [ ] Un cliente sin direcciones responde 200 con `"direcciones": []`.
  - [ ] La base de datos de `clientes-sapi` tiene el cliente `cli-12` de prueba, cargado con un script del repositorio.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
  - [ ] La respuesta no trae campos que no estén en el tipo `Cliente`.
- Notas: Historia patrón de 3 puntos (aprobada el 2026-11-18): las demás se estiman comparándolas con esta. Depende de MDX-006. Decisión de ella (2026-11-18): cliente sin direcciones = 200 con lista vacía; si al pagar falta la dirección, lo decide `realizar-pedido-papi` (regla de negocio en Process). Contrato (copia de `clientes-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /clientes/{id_cliente}` en `http://localhost:8081/api/v1` |
  | Parámetro de ruta | `id_cliente` (texto, ej. `cli-12`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | 200 | **Cliente** con sus direcciones |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: `{ "id_cliente": "cli-12", "nombre": "Laura Gómez", "telefono": "3001234567", "correo": "laura@correo.com", "direcciones": [ { "id_direccion": "dir-1", "texto": "Cra 7 # 45-10" } ] }`

### MDX-009 · tiendas-sapi: crear el proyecto desde Exchange y su base de datos
- Tipo: tarea
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el proyecto de `tiendas-sapi` generado desde su RAML de Exchange y conectado a su base de datos para empezar a construir sus endpoints.
- Criterios de aceptación:
  - [ ] El proyecto se generó en Studio desde su RAML de Exchange y arranca en su puerto.
  - [ ] Sus tablas están creadas en su base de datos con un script del repositorio, a partir de los tipos de `contratos/datos.md`.
  - [ ] Tiene la plantilla de errores de MDX-006: una ruta que no existe responde 404 con el cuerpo `Error`.
  - [ ] En local exige `client_id` y `client_secret` en los encabezados y funciona con valores cualquiera.
- Notas: Puerto 8082. RAML: `../contratos/raml/system/tiendas-sapi/`. Depende de MDX-001, MDX-005 y MDX-006 (reutiliza la plantilla de errores). Criterios comunes a las 5 tareas de crear proyecto (aprobados el 2026-11-18). Estimada contra MDX-008 (más chica: reutiliza MDX-006).

### MDX-010 · tiendas-sapi: GET /tiendas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer todas las tiendas o solo las de `ids` para mostrar la vitrina y revisar tiendas activas al pagar.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-011 · tiendas-sapi: GET /tiendas/{id_tienda}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer una tienda para conocer su estado, horario y cadena.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-012 · tiendas-sapi: POST /tiendas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-tienda-papi quiero guardar una tienda nueva para que el gerente la cree desde el portal (decisión 51); nace `cerrada`.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-013 · tiendas-sapi: PATCH /tiendas/{id_tienda}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-tienda-papi quiero cambiar campos de una tienda para pausar, cerrar o abrir la tienda.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-014 · tiendas-sapi: GET /cadenas/{id_cadena}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero leer en vivo los datos de la cadena para saber qué traductor y contacto usar en el aviso (decisión 46).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-015 · tiendas-sapi: POST /cadenas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como persona de Mandaditos (Postman) quiero registrar una cadena para poder crear después sus sucursales.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-016 · tiendas-sapi: PATCH /cadenas/{id_cadena}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como persona de Mandaditos (Postman) quiero editar una cadena para mantener al día su contacto y traductor.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-017 · catalogo-sapi: crear el proyecto desde Exchange y su base de datos
- Tipo: tarea
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el proyecto de `catalogo-sapi` generado desde su RAML de Exchange y conectado a su base de datos para empezar a construir sus endpoints.
- Criterios de aceptación:
  - [ ] El proyecto se generó en Studio desde su RAML de Exchange y arranca en su puerto.
  - [ ] Sus tablas están creadas en su base de datos con un script del repositorio, a partir de los tipos de `contratos/datos.md`.
  - [ ] Tiene la plantilla de errores de MDX-006: una ruta que no existe responde 404 con el cuerpo `Error`.
  - [ ] En local exige `client_id` y `client_secret` en los encabezados y funciona con valores cualquiera.
- Notas: Puerto 8083. RAML: `../contratos/raml/system/catalogo-sapi/`. Depende de MDX-001, MDX-005 y MDX-006 (reutiliza la plantilla de errores). Criterios comunes a las 5 tareas de crear proyecto (aprobados el 2026-11-18). Estimada contra MDX-008 (igual: tablas con listas adentro).

### MDX-018 · catalogo-sapi: GET /productos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer productos por `id_tienda`, `ids` o `id_cadena` + `id_en_cadena` para mostrar el catálogo, tomar los precios al pagar y reconocer productos de cadena (filtros combinables, regla 7).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-019 · catalogo-sapi: GET /productos/{id_producto}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer un producto para ver sus datos completos.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-020 · catalogo-sapi: POST /productos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero guardar un producto nuevo con `clave` opcional para no duplicarlo al retomar una carga (201, o 200 si ya existía).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-021 · catalogo-sapi: PATCH /productos/{id_producto}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero cambiar nombre, descripción, imagen o precio para mantener el catálogo al día (precio único en todas las tiendas, decisión 52).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-022 · catalogo-sapi: POST /productos/{id_producto}/tiendas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero agregar una sucursal a un producto de cadena para no repetir el producto por sucursal (decisión 52).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-023 · catalogo-sapi: PATCH /productos/{id_producto}/tiendas/{id_tienda}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero marcar agotado o quitar/reactivar en una tienda para hacer el borrado lógico por tienda sin borrar nada.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-024 · catalogo-sapi: POST /cargas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero abrir el ticket de una carga del Excel para seguir la carga con Claim Check (`carga-77`).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-025 · catalogo-sapi: GET /cargas/{id_carga}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero leer el estado de una carga para mostrar la vista previa y el avance.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-026 · catalogo-sapi: PATCH /cargas/{id_carga}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero cambiar el estado de la carga con la condición `si_estado_actual` para que no se confirme ni se procese dos veces (409 con el objeto actual).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-027 · pedidos-sapi: crear el proyecto desde Exchange y su base de datos
- Tipo: tarea
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el proyecto de `pedidos-sapi` generado desde su RAML de Exchange y conectado a su base de datos para empezar a construir sus endpoints.
- Criterios de aceptación:
  - [ ] El proyecto se generó en Studio desde su RAML de Exchange y arranca en su puerto.
  - [ ] Sus tablas están creadas en su base de datos con un script del repositorio, a partir de los tipos de `contratos/datos.md`.
  - [ ] Tiene la plantilla de errores de MDX-006: una ruta que no existe responde 404 con el cuerpo `Error`.
  - [ ] En local exige `client_id` y `client_secret` en los encabezados y funciona con valores cualquiera.
- Notas: Puerto 8084. RAML: `../contratos/raml/system/pedidos-sapi/`. Depende de MDX-001, MDX-005 y MDX-006 (reutiliza la plantilla de errores). Criterios comunes a las 5 tareas de crear proyecto (aprobados el 2026-11-18). Estimada contra MDX-008 (igual: tablas con listas adentro).

### MDX-028 · pedidos-sapi: POST /pedidos/reservas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero apartar el número de pedido para tener el número antes de cobrar (decisión 27).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-029 · pedidos-sapi: POST /pedidos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero crear el pedido con sus copias al pagar para guardarlo solo con el pago aprobado; cada parte nace en `Pedido nuevo`.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-030 · pedidos-sapi: GET /pedidos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero leer los pedidos de un `id_cliente` para armar «Mis pedidos» (decisión 58).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-031 · pedidos-sapi: GET /pedidos/{id_pedido}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer el pedido completo con sus partes para usarlo en la rutina de cierre, los avisos y la app.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-032 · pedidos-sapi: PATCH /pedidos/{id_pedido}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero marcar el pedido como cerrado una sola vez para que «revisar cierre» deje pasar a uno solo (409 con el objeto actual).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-033 · pedidos-sapi: PATCH /pedidos/{id_pedido}/partes/{id_tienda}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero cambiar una parte con las condiciones `si_estado_actual` y `fecha_hora_respuesta` para que el Agregador no pise un estado más nuevo ni acepte respuestas tardías (409 con el objeto actual).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-034 · pedidos-sapi: POST /pedidos/{id_pedido}/avisos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como notificar-estado-papi quiero anotar «ya avisé al cliente» con su `id_aviso` para no avisar dos veces lo mismo (201, o 200 si ya existía).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-035 · pedidos-sapi: GET /partes
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer partes por tienda, estado o fecha de entrega para mostrar la pantalla de la tienda y armar `ventas-semana` (filtros combinables, regla 7).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-036 · pagos-sapi: crear el proyecto desde Exchange y su base de datos
- Tipo: tarea
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el proyecto de `pagos-sapi` generado desde su RAML de Exchange y conectado a su base de datos para empezar a construir sus endpoints.
- Criterios de aceptación:
  - [ ] El proyecto se generó en Studio desde su RAML de Exchange y arranca en su puerto.
  - [ ] Sus tablas están creadas en su base de datos con un script del repositorio, a partir de los tipos de `contratos/datos.md`.
  - [ ] Tiene la plantilla de errores de MDX-006: una ruta que no existe responde 404 con el cuerpo `Error`.
  - [ ] En local exige `client_id` y `client_secret` en los encabezados y funciona con valores cualquiera.
- Notas: Puerto 8085. RAML: `../contratos/raml/system/pagos-sapi/`. Depende de MDX-001, MDX-005 y MDX-006 (reutiliza la plantilla de errores). Criterios comunes a las 5 tareas de crear proyecto (aprobados el 2026-11-18). Estimada contra MDX-008 (más chica: reutiliza MDX-006).

### MDX-037 · pagos-sapi: POST /pagos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero anotar el intento de pago `pendiente` para tenerlo registrado antes de llamar a la pasarela (201, o 200 si ya existía).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-038 · pagos-sapi: PATCH /pagos/{id_pago}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero guardar el resultado del cobro y la `referencia_pasarela` para saber si se aprobó y poder devolver después (decisión 47).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-039 · pagos-sapi: GET /pagos/{id_pago}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero leer un intento de pago para encontrar el pendiente en el reintento.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-040 · pagos-sapi: GET /pagos
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer pagos por `id_pedido` o por `id_cliente` (+ `estado`) para hallar el pago aprobado en la rutina de cierre y los pendientes de «Mis pedidos» (decisión 58).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-041 · pagos-sapi: POST /devoluciones
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero anotar la devolución `pendiente` para no devolver dos veces (clave `devolucion-101`).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-042 · pagos-sapi: PATCH /devoluciones/{id_devolucion}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero guardar `hecha` o `fallida` y los intentos para seguir los reintentos de la devolución (decisión 14).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-043 · logistica-sapi: crear el proyecto desde Exchange y su base de datos
- Tipo: tarea
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero el proyecto de `logistica-sapi` generado desde su RAML de Exchange y conectado a su base de datos para empezar a construir sus endpoints.
- Criterios de aceptación:
  - [ ] El proyecto se generó en Studio desde su RAML de Exchange y arranca en su puerto.
  - [ ] Sus tablas están creadas en su base de datos con un script del repositorio, a partir de los tipos de `contratos/datos.md`.
  - [ ] Tiene la plantilla de errores de MDX-006: una ruta que no existe responde 404 con el cuerpo `Error`.
  - [ ] En local exige `client_id` y `client_secret` en los encabezados y funciona con valores cualquiera.
- Notas: Puerto 8086. RAML: `../contratos/raml/system/logistica-sapi/`. Depende de MDX-001, MDX-005 y MDX-006 (reutiliza la plantilla de errores). Criterios comunes a las 5 tareas de crear proyecto (aprobados el 2026-11-18). Estimada contra MDX-008 (más chica: reutiliza MDX-006).

### MDX-044 · logistica-sapi: POST /ofertas
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero crear la oferta `abierta` con su `vencimiento` para ofrecer la parte a los repartidores por 2 minutos (decisión 49).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-045 · logistica-sapi: GET /ofertas/{id_oferta}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero leer una oferta para que la alarma revise su estado e intento.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-046 · logistica-sapi: PATCH /ofertas/{id_oferta}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero aceptar o vencer la oferta con condiciones para que solo un repartidor la tome y no después del vencimiento (409 con el objeto actual).
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-047 · logistica-sapi: PATCH /repartidores/{id_repartidor}
- Tipo: historia
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero marcar al repartidor ocupado o libre para no ofrecerle otra parte mientras reparte.
- Criterios de aceptación:
- Notas: RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`. Fila en `../contratos/tabla-endpoints.md`. Criterios y puntos por refinar.

### MDX-048 · Evaluar DummyJSON para el ejercicio
- Tipo: investigación
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: —
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como desarrolladora quiero evaluar si DummyJSON sirve dentro del ejercicio para decidir si lo uso o no.
- Criterios de aceptación:
- Notas: Idea de ella (2026-11-18). Condición suya: si usarlo modifica muchas cosas del diseño o de los contratos, no se usa. Se evalúa en su momento (no ahora). Criterios y puntos por refinar.

## Terminadas
