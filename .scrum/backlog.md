# Backlog

### MDX-001 · Elegir la base de datos de las System APIs
- Tipo: investigación
- Estado: hecha
- Puntos: 2
- Sprint: 1
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: 2026-11-24
- Historia: Como desarrolladora quiero elegir el motor de base de datos de las 6 System APIs para poder guardar los datos de `contratos/datos.md`.
- Criterios de aceptación:
  - [x] Se eligió PostgreSQL o MySQL, con la razón escrita en una línea.
  - [x] El motor corre en Docker, con un archivo en el repositorio que lo levanta igual cada vez.
  - [x] Quedó decidido si cada System API tiene su propia base de datos o su propio esquema en el mismo servidor; en los dos casos cada API solo toca lo suyo.
  - [x] Desde Studio se probó una conexión con el conector Database (una consulta simple que responde). — no aplica (ella, 2026-11-24): ya lo ha hecho antes; lo cubre MDX-006 («Está conectado a su base de datos»).
  - [x] La decisión quedó en el README, sección «Tecnología».
- Notas: No está decidido en el diseño. Cada System API es dueña de su base de datos (arquitectura API-led). Ya tiene Docker y conectó antes a PostgreSQL y a MySQL; sin preferencia. H2 descartada (se borra al apagar la app; las pruebas MUnit simulan la base con `mock-when`). Estimada contra MDX-008 (patrón de 3 puntos). Decidido por ella (2026-11-24): PostgreSQL; un contenedor con una base por System API, cada una con su usuario (PostgreSQL no consulta entre bases); listas: jsonb si se leen y reemplazan enteras (horario), tabla si se filtran o se agregan filas (historial, tiendas del Producto). Anotado en el README, sección «Tecnología». Hecho (2026-11-24): `codigo/docker-compose.yml` y `codigo/db/init/01-bases.sql`; contenedor `mandaditos-postgres` con las 6 bases, comprobado que `clientes_sapi` entra a `clientes` y es rechazado en `pagos`. Definición de hecho: MUnit no aplica (investigación); commit pendiente hasta que exista el repositorio git (lo crea ella). Commit hecho el 2026-11-25 (junto con MDX-002).

### MDX-002 · Elegir ActiveMQ Classic o Artemis y levantarlo en local
- Tipo: investigación
- Estado: hecha
- Puntos: 3
- Sprint: 1
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: 2026-11-25
- Historia: Como desarrolladora quiero el broker corriendo en mi máquina para conectar las apps de Mule por JMS.
- Criterios de aceptación:
  - [x] Se compararon Classic y Artemis en 5 puntos: mensaje diferido (alarmas de 5 y 2 min, decisiones 48 y 49), expiración (aviso de 5 min), cola de mensajes muertos (decisiones 42 y 57), consola web para enviar órdenes y mirar, mover o relanzar mensajes (decisión 42) y conexión con el conector JMS de Mule; cada respuesta con su fuente oficial.
  - [x] Se eligió uno y la razón quedó escrita en una línea.
  - [x] El broker corre en Docker con un archivo en el repositorio (puede ser el mismo de MDX-001).
  - [x] Desde Studio se publicó un mensaje en una cola de prueba y otro flujo lo leyó.
  - [x] Se abrió la consola web y se vio el mensaje de prueba en la cola.
  - [x] La decisión quedó en el README, sección «Tecnología».
- Notas: Anypoint MQ no está disponible. Pruebas pendientes de la bitácora: advisories de mensajes muertos (decisión 57) y cómo se pone el retraso del mensaje diferido desde JMS. Nada de memoria: esta historia investiga con fuentes. Estimada contra MDX-008 (mismo tamaño). Avance (2026-11-24): comparación de los 5 puntos hecha con fuentes oficiales (en el chat; resumen en la bitácora de CLAUDE.md). Recomendación mía: Classic 5.19 (imagen `apache/activemq-classic:5.19.2`; conexión propia en Mule, JMS 1.1). Ella ya tiene la imagen de Artemis y quiere **probar los dos** antes de elegir. Por comprobar en la prueba: retraso con `AMQ_SCHEDULED_DELAY` en «User Properties» (Classic) y «Delivery Delay» con JMS 2.0 (Artemis); qué hace cada uno con el vencido; acciones de cada consola. Prueba (2026-11-24): Classic 5.19.2 en Docker (prueba, con `schedulerSupport`): consola con Send, Browse, Delete, Copy y Move (comprobado en pantalla); el formulario Send manda no persistente por defecto. Studio: JMS Config «ActiveMQ Connection» (activemq-client 5.16.7, JMS_1_1, Edit inline, `tcp://localhost:61616`, sin usuario) → Test Connection OK; Scheduler → Publish `prueba.uno` y On New Message → Logger: el mensaje llegó (criterio 4 cumplido con Classic). Falta la misma prueba con Artemis. Prueba 3, diferido (2026-11-25): Classic con «Delivery delay» del Publish = error (solo JMS 2.0; la conexión es JMS 1.1). Classic con User Properties `#[%dw 2.0 output application/java --- {AMQ_SCHEDULED_DELAY: 100000}]` = funciona: el mensaje aparece en la pestaña Scheduled (delay 100000, start 14:37:24, next 14:39:04 UTC). Sin `output application/java` falla (String en vez de Map). Error `NoClassDefFoundError io/netty` en hilos `activemq-client-remoting` del cliente de Artemis (no interrumpe; parece al redesplegar: los hilos de Artemis siguen vivos cuando Mule descarga la app; ⚠️ ver `mule.jms.operation.artemis.dispose.delay`). Falta el resultado del diferido en Artemis. Prueba 3 en Artemis (2026-11-25): «Delivery delay» 60 s del Publish (JMS 2.0) = funciona: el mensaje se envió a las 10:33:08 y apareció en `prueba.dos` después del minuto; mientras espera no se ve en «Browse» (solo cuenta en `SCHEDULED COUNT`, visto con `artemis queue stat`). Configuración por defecto de Artemis: `dead-letter-address` = `DLQ` y `expiry-address` = `ExpiryQueue` (el vencido NO se descarta; para descartarlo hay que quitar `expiry-address`). Prueba 4, vencido (2026-11-25): Time to live 10 s sin consumir → Classic lo pasó a `ActiveMQ.DLQ`; Artemis lo pasó a `ExpiryQueue` (ella vio el paso de una cola a otra). Coincide con la documentación; en los dos hay que cambiar la configuración para descartarlo (decisión de la sesión 10). Consola de Artemis: Browse con Filter, Delete, Move y Copy. En la nube (2026-11-25, pedido de ella): CloudHub solo corre la app de Mule; el broker vive aparte y Mule recibe URL y credenciales por propiedades de cada ambiente. Classic tiene servicio administrado: Amazon MQ (ActiveMQ Classic y RabbitMQ, no Artemis; doc oficial); su esquema `amazon-mq-active-mq-5.19.1.xsd` permite `schedulerSupport` en `<broker>` y `processExpired` en `sharedDeadLetterStrategy` e `individualDeadLetterStrategy` (comprobado en el XSD); los cambios se aplican al reiniciar o en la ventana de mantenimiento; tiene Web Console. Costo: créditos de capa gratuita de AWS (hasta 200 USD, 6 meses, clientes nuevos desde jul-2025). Artemis: sin Amazon MQ; habría que montarlo uno mismo (Docker en una máquina en la nube) con su `broker.xml`. Decidido por ella (2026-11-25): ActiveMQ Classic 5.19 para local; la nube queda en MDX-050. README actualizado. Hecho (2026-11-25): grupo de Compose `servicios-mandaditos` con `mandaditos-db-postgres` y `mandaditos-activemq` (`apache/activemq-classic:5.19.2`, puertos 61616 y 8161); `codigo/broker/activemq.xml` = el de la imagen + `schedulerSupport="true"` (Job Scheduler arranca). Volumen viejo `codigo_datos-postgres` borrado (sin tablas); las 6 bases se recrearon. Contenedores de prueba borrados. Abierto, decide ella: `processExpired="false"` (vencido se descarta) o dejarlo ir a `ActiveMQ.DLQ`. Cerrada (2026-11-25): commit `MDX-001, MDX-002: PostgreSQL y ActiveMQ Classic 5.19 en Docker` subido a GitHub. Claves movidas a `.env` (no se sube) con `.env.example`; `01-bases.sql` pasó a `01-bases.sh`.

### MDX-003 · Crear en el broker las colas y temas de la tabla de canales
- Tipo: tarea
- Estado: hecha
- Puntos: 3
- Sprint: 1
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: 2026-11-25
- Historia: Como desarrolladora quiero las colas y temas creados en el broker para que las apps puedan publicar y escuchar.
- Criterios de aceptación:
  - [x] Están creados todos los canales de la tabla (copia abajo), y cada tema tiene sus colas colgadas: un mensaje publicado en el tema llega a todas ellas.
  - [x] `avisos.{id_tienda}` y `control.{pieza}` están creados para la tienda de prueba del pedido 101 y para cada pieza con cola de control (`endpoints.md`, paso 8 B).
  - [x] La configuración está en un archivo del repositorio: al levantar Docker de nuevo, los canales quedan iguales.
  - [x] Desde la consola web se ve cada canal.
  - [x] Se probó un tema: un mensaje publicado en `pedidos.estado` llegó a sus dos colas.
- Notas: Depende de MDX-002 (cómo se cuelga una cola de un tema cambia según el broker; ⚠️ verificar en su documentación). Aquí se le explica cómo se montan y conectan colas y temas al desplegar (pedido suyo para la fase 4). Estimada contra MDX-008 (mismo tamaño). Copia de la tabla de canales (`endpoints.md`): Avance (2026-11-25): en `codigo/broker/activemq.xml`: `<destinations>` (24 canales al arrancar) y `<destinationInterceptors>` con 5 `compositeTopic` (avisos.A, pedidos.entregas, pedidos.estado, pedidos.listo, mensajes-muertos). Tienda de prueba `A` (como en los ejemplos; decidido por ella). Cola nueva propuesta por mí: `pedidos.listo.repartidor`. Vencidos: `processExpired="false"` en `policyEntry queue=">"` (decidido por ella: descartar). Prueba: 1 mensaje a `topic://pedidos.estado` → 1 en `pedidos.estado.notificar` y 1 en `pedidos.estado.portal`. Límite anotado: archivo fijo, cada tienda nueva necesita su tema y reiniciar; con muchas tiendas, evaluar Virtual Topics. Falta: que ella vea los canales en la consola. Cerrada (2026-11-25): ella vio los canales en la consola e hizo el commit.

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
- Estado: hecha
- Puntos: 3
- Sprint: 1
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: 2026-11-27
- Historia: Como desarrolladora quiero los fragments de `raml/comun/` en Exchange para que los RAML de las APIs los usen desde ahí.
- Criterios de aceptación:
  - [x] Se verificó en la documentación de MuleSoft cómo se publica un conjunto de fragments y cómo lo usa una API (tipo de asset y forma de la ruta), con la fuente anotada.
  - [x] `comun` está publicado en Exchange con versión `1.0.0`.
  - [x] Una API de prueba que lo usa como dependencia valida sin errores en Design Center, con al menos un tipo, un trait y un ejemplo.
  - [x] Se anotó qué líneas exactas cambiarán en los 15 RAML (el cambio se hace en MDX-005 para System; Process y Experience más adelante).
- Resultado (2026-11-27): `prueba-clientes` valida sin errores rojos con la dependencia `comun` 1.0.0, ya sin las carpetas copiadas, usando el tipo `cli.Cliente`, los 3 traits y el ejemplo `cliente.raml`. Queda un **aviso amarillo** en cada ruta: «Detected non root dependency file reference … Only dependency main file should be used from dependant project», porque se entra a archivos que no son la raíz del asset (`tipos/base.raml`). No se encontró documentación oficial de ese aviso. Opciones: A aceptarlo; B una raíz que reúna todo (no sirve para los tipos de 8 librerías ni para los ejemplos); C un asset por fragmento (~30 assets). **Decisión de ella (2026-11-27): opción A**, se acepta el aviso. Si Studio falla al generar el esqueleto en MDX-006, se vuelve a esta decisión.
- Líneas que cambian (criterio 4): en cada RAML, **solo** las líneas que empiezan con `../../comun/` (en `uses:`, `traits:` y los `!include` de ejemplos). Se reemplaza el prefijo `../../comun/` por `exchange_modules/a86ab655-65d5-4626-afd0-4071cb9cea64/comun/1.0.0/`, y el resto de la ruta queda igual. Además, cada API agrega la dependencia `comun` 1.0.0 en Design Center. Los archivos dentro de `comun` no se tocan: sus rutas internas viajan en el paquete. Cuántas líneas por API: System (MDX-005) clientes 5, logistica 8, pagos 9, tiendas 8, catalogo 10, pedidos 16 (56 en total); Process gestionar-repartidor 5, gestionar-tienda 7, realizar-pedido 8, gestionar-pedido 8, gestionar-catalogo 13 (41); Experience cadenas 4, app-repartidor 6, app-cliente 13, portal-tiendas 16 (39). Total 136. Ejemplo (`clientes-sapi`, líneas 13, 16, 17, 18 y 35): `cli: ../../comun/tipos/clientes.raml` → `cli: exchange_modules/a86ab655-65d5-4626-afd0-4071cb9cea64/comun/1.0.0/tipos/clientes.raml`. ⚠️ Con estas rutas, la copia local de la carpeta ya no valida sola con el plugin `validar-raml` (no existe `exchange_modules` en local); ver nota de MDX-005.
- Notas: Fuente: `../contratos/raml/comun/`. **Decisión de ella (2026-11-18): opción A**, `comun` como un solo asset en Exchange que cada API declara como dependencia (mantiene «un solo tipo por objeto»; descartada la B, copiar `comun/` en cada API). Hoy los RAML usan rutas relativas (`../../comun/...`) que en Exchange no funcionan: solo cambian las líneas `uses:` y `!include`. Antes de publicar: confirmar si sobra `ejemplos/resultado-pedido.raml` (el tipo `ResultadoPedido` se eliminó el 2026-11-12). ⚠️ Forma de la ruta de la dependencia por verificar. Estimada contra MDX-008 (mismo tamaño). Avance (2026-11-25): `ejemplos/resultado-pedido.raml` NO sobra: lo usan `realizar-pedido-papi` y `app-cliente-eapi` (ejemplos de POST /pedidos con `pago.estado`). Documentación revisada: crear fragmento en Design Center (Create + → New Fragment, RAML 1.0, tipo) y publicar con Publish → Publish to Exchange, versión 1.0.0 (https://docs.mulesoft.com/design-center/design-create-publish-api-fragment); al publicar se excluyen por defecto los archivos que nadie referencia (https://docs.mulesoft.com/design-center/design-publish); la API lo agrega con Exchange dependencies y aparece en `exchange_modules/<group>/<asset>/<versión>/` (https://docs.mulesoft.com/design-center/design-add-api-dependency). ⚠️ Por comprobar en pantalla: si las carpetas se conservan al importar el zip y cómo evitar que se excluyan los archivos no referenciados. Avance (2026-11-26): el zip importado en Design Center **conserva las carpetas** (comprobado por ella; el proyecto quedó como `common`). Al abrirlo sale «Root file is not specified»: todo proyecto de fragmentos necesita un archivo raíz para publicarse; se pone con ⋮ junto al archivo → **Set as root file**, y puede ser cualquier fragmento, también una librería (https://docs.mulesoft.com/design-center/design-change-root-file). Archivos no referenciados desde la raíz: al publicar sale el diálogo «Publish unreferenced files?» con la casilla **Include unreferenced files** (visto en pantalla; la documentación no la nombra, https://docs.mulesoft.com/design-center/design-publish). Primera publicación quedó con asset ID `common` (renombrar el proyecto no cambia el asset ID; comprobado en `exchange.json`); el contenido descargado era idéntico (31 archivos). Ella creó un proyecto nuevo `comun` (Import from File, API specification fragment), raíz `tipos/base.raml`, casilla marcada, versión 1.0.0 Stable: `exchange.json` con `assetId: comun` y `groupId: a86ab655-65d5-4626-afd0-4071cb9cea64` (la organización). Borró el asset `common`. Exchange solo dibuja el archivo raíz; lo demás va en el paquete. Criterio 3 en curso (2026-11-26, se paró a las 19:00): proyecto `prueba-clientes` en Design Center con la dependencia `comun` 1.0.0 agregada (`exchange_modules` visible; `exchange.json` con la dependencia, classifier `raml`, packaging `zip`), pero todavía tiene copias sueltas de las carpetas de `comun` (se creó importando el zip), así que las rutas cortas leen la copia. Falta: ver la ruta exacta dentro de `exchange_modules`, cambiar las 5 líneas (`uses:`, 3 `traits:`, `!include` del ejemplo), borrar las 5 carpetas copiadas y comprobar que no hay errores. Revisar la marca roja que se vio cerca de la línea 23. Las dos páginas se contradicen sobre si se publican todos: comprobar en Exchange después de publicar que están los 36.

### MDX-005 · Publicar en Exchange los 6 RAML de System
- Tipo: tarea
- Estado: hecha
- Puntos: 3
- Sprint: 1
- Épica: Preparar el terreno
- Creada: 2026-11-18
- Cerrada: 2026-11-27
- Historia: Como desarrolladora quiero los RAML de System publicados en Exchange para generar el esqueleto de cada app en Studio.
- Criterios de aceptación:
  - [x] En los 6 RAML de System se cambiaron solo las líneas `uses:` y `!include` para apuntar a la dependencia `comun` 1.0.0 (las anotadas en MDX-004).
  - [x] Cada una de las 6 valida sin errores en Design Center.
  - [x] Las 6 están publicadas en Exchange (API `v1`, asset `1.0.0`).
  - [x] La copia de `contratos/raml/system/` es igual a lo publicado; si hubo que corregir algo, se corrigió primero en la carpeta.
  - [x] Desde Studio se encuentra al menos una de las 6 en Exchange (la usa MDX-007).
- Notas: Fuente: `../contratos/raml/system/`. Requisito del plugin `construir-flujo` (C3: el esqueleto sale de Exchange). Regla aprobada por ella (2026-11-18): **la copia de la carpeta manda**; todo cambio se hace primero ahí, se valida y después se sube. **Depende de MDX-004: si la dependencia `comun` (opción A) no es posible, esta historia tampoco se puede hacer así y se evalúan las dos en su momento** (nota de ella). ⚠️ Con las rutas nuevas el plugin `validar-raml` puede dejar de encontrar `comun` (quizá necesite la dependencia descargada en local); si no se resuelve, cuenta la validación de Design Center. Estimada contra MDX-008 (mismo tamaño). Avance (2026-11-27): criterio 1 hecho. En las 6 se cambió solo el prefijo `../../comun/` por `exchange_modules/a86ab655-65d5-4626-afd0-4071cb9cea64/comun/1.0.0/` (56 líneas: clientes 5, logistica 8, pagos 9, tiendas 8, catalogo 10, pedidos 16) y no quedó ninguna ruta `../`. Respaldo previo en el scratchpad de la sesión. **Validación local resuelta:** se armó en el scratchpad una copia de cada API con `comun` dentro de `exchange_modules/<org>/comun/1.0.0/` (como lo hace Design Center) y el script de `validar-raml` dio 6 OK, 0 errores. La prueba negativa (la misma API sin `exchange_modules`) da error, así que la prueba sí revisa las rutas. Pasos para cada API en Design Center: Create → Import from File → el `.raml` de `contratos/raml/system/<api>/` (API specification, RAML 1.0, nombre = nombre de la API) → Exchange dependencies → agregar `comun` 1.0.0 → revisar que no haya marcas rojas (el aviso amarillo de la opción A es esperado) → Publish → asset version `1.0.0`, API version `v1`, Stable. Si Design Center pide corregir algo, se corrige primero en la carpeta. Avance (2026-11-27, tarde): las 6 publicadas en Exchange (1.0.0, v1, Stable) sin cambios en Design Center, así que la copia de la carpeta es igual a lo publicado. Cada una publicó con avisos amarillos («functional warnings»), ninguno rojo. El número de avisos coincidió con las líneas cambiadas (clientes 5, logistica 8, pagos 9, tiendas 8, catalogo 10), salvo pedidos: 15 avisos para 16 líneas. Uno menos no es un aviso nuevo, así que no se investigó por qué. Criterio 5 hecho: `clientes-sapi` aparece en Studio (New Mule Project → Import a published API → from Exchange).

### MDX-006 · clientes-sapi: crear el proyecto desde Exchange, su base de datos y la estructura de errores
- Tipo: tarea
- Estado: lista
- Puntos: 5
- Sprint: 1
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
- Sprint: 1
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

### MDX-049 · clientes-sapi: probar Client ID enforcement en API Manager
- Tipo: investigación
- Estado: lista
- Puntos: 3
- Sprint: 1
- Épica: Preparar el terreno
- Creada: 2026-11-19
- Cerrada: —
- Historia: Como desarrolladora quiero ver la política Client ID enforcement funcionando en API Manager con una API de verdad, para saber qué cambia frente a lo que exige el APIkit en local.
- Criterios de aceptación:
  - [ ] Se verificó en la documentación de MuleSoft cómo se configuran API Autodiscovery y la política Client ID enforcement, con la fuente anotada.
  - [ ] `clientes-sapi` está desplegada en CloudHub (cuenta de prueba) y aparece conectada a su instancia de API Manager.
  - [ ] La política está aplicada y hay una aplicación cliente con contrato que da su `client_id` y `client_secret`.
  - [ ] Una llamada sin credenciales o con credenciales falsas responde el error de la política (anotado el código y el cuerpo); una con las credenciales buenas responde 200.
  - [ ] Quedó anotado qué cambia frente al local (APIkit) y si el cuerpo del error sigue o no la estructura `Error` de los contratos.
- Notas: Registrada el 2026-11-19 (propuesta del 2026-11-18, aprobada por ella). Criterios y 3 puntos aprobados por ella (2026-11-19). Depende de MDX-006 y MDX-008. Contexto en la nota de MDX-006: la política solo existe en API Manager con API Autodiscovery; en local solo el APIkit exige los encabezados. ⚠️ Por verificar si la cuenta de prueba deja desplegar en CloudHub y aplicar políticas. Estimada contra MDX-008 (herramienta nueva, poco código). Riesgo nuevo (2026-11-24): en CloudHub la app no llega a la base de Docker local; hace falta una base PostgreSQL en internet. Candidata de ella: Clever Cloud, plan DEV gratis (doc oficial: solo pruebas, sin backups ni SLA, PostgreSQL 15). ⚠️ Por verificar: espacio y número de conexiones (fuentes no oficiales hablan de 256 MB y pocas conexiones; ajustar el pool del conector Database). Se decide al llegar a esta historia.

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
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer todas las tiendas o solo las de `ids` para mostrar la vitrina y revisar tiendas activas al pagar.
- Criterios de aceptación:
  - [ ] `GET /tiendas` responde 200 con todas las tiendas guardadas.
  - [ ] `GET /tiendas?ids=A,C` responde 200 solo con A y C.
  - [ ] `GET /tiendas?ids=A,Z` (Z no existe) responde 200 solo con A: no es 404.
  - [ ] Sin tiendas guardadas responde 200 con `[]`.
  - [ ] Cada tienda trae su `horario` completo y, si es sucursal, `id_cadena` e `id_en_cadena`.
  - [ ] Hay pruebas MUnit en verde para todas, con `ids` y con un id que no existe, con la base de datos simulada.
- Notas: Decisión de ella (2026-11-19): si falta una tienda pedida, `tiendas-sapi` no falla; `realizar-pedido-papi` la trata como no activa. Cómo se entera de que falta (ella, 2026-11-19, opción C): la respuesta no lo informa ni cambia el contrato; `realizar-pedido-papi` compara lo que pidió con lo que volvió (DataWeave: `ids_pedidos -- (payload map $.id_tienda)`). Anotarlo en su historia cuando se cree. `tiendas-sapi` no filtra por estado: la regla «solo tiendas activas» vive en Process (decisión 26). Estimada contra MDX-008 (igual: lectura de una lista con filtro). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /tiendas` en `http://localhost:8082/api/v1` |
  | Parámetro de query | `ids` (opcional, texto con ids separados por comas, ej. `A,B,C`) |
  | 200 | lista de **Tienda** |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: ver `../contratos/raml/comun/ejemplos/tiendas-lista.raml`.

### MDX-011 · tiendas-sapi: GET /tiendas/{id_tienda}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer una tienda para conocer su estado, horario y cadena.
- Criterios de aceptación:
  - [ ] `GET /tiendas/A` responde 200 con la tienda, en la forma del ejemplo.
  - [ ] `GET /tiendas/no-existe` responde 404 con `codigo: no-encontrado`, un `mensaje` sin datos internos y la `correlacion`.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Estimada contra MDX-008 (más chica: reutiliza la lectura de MDX-010). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /tiendas/{id_tienda}` en `http://localhost:8082/api/v1` |
  | Parámetro de ruta | `id_tienda` (texto, ej. `A`) |
  | 200 | **Tienda** |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: ver `../contratos/raml/comun/ejemplos/tienda.raml`.

### MDX-012 · tiendas-sapi: POST /tiendas
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-tienda-papi quiero guardar una tienda nueva para que el gerente la cree desde el portal (decisión 51); nace `cerrada`.
- Criterios de aceptación:
  - [ ] Con `nombre`, `direccion.texto` y `horario`, responde 201 con la tienda guardada: `estado: cerrada`, `id_tienda` con la forma `tie-<número>` y `direccion.id_direccion` con la forma `dir-<número>` (regla 13).
  - [ ] Si trae `id_cadena` e `id_en_cadena`, los guarda tal cual (sucursal); si no, queda de barrio.
  - [ ] Si falta `nombre`, `direccion` u `horario`, responde 400 `solicitud-invalida`.
  - [ ] Un `horario` vacío (`[]`) responde 400 (mínimo un día, regla 14).
  - [ ] Si el cuerpo trae `id_tienda` o `estado`, no se usan: el id lo pone la API y la tienda nace `cerrada`.
  - [ ] Hay pruebas MUnit en verde para barrio, sucursal y un 400, con la base de datos simulada.
- Notas: Que la cadena exista lo revisa `gestionar-tienda-papi` antes de llamar (regla 3: 400 en la Process), no esta API. ⚠️ Ignorar `id_tienda` y `estado` del cuerpo es sugerencia de Claude, por confirmar al construir. Estimada contra MDX-008 (igual: escribe en dos tablas, tienda y horario). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /tiendas` en `http://localhost:8082/api/v1` |
  | Cuerpo | **Tienda**: `nombre`, `direccion` (solo `texto`) y `horario` obligatorios; `id_cadena` e `id_en_cadena` en sucursales |
  | 201 | **Tienda** con su `id_tienda` y `estado: cerrada` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "nombre": "Panadería La Esquina", "direccion": { "texto": "Calle 10 # 5-20" }, "horario": [ { "dia": "lunes", "apertura": "06:00", "cierre": "20:00" } ] }`

### MDX-013 · tiendas-sapi: PATCH /tiendas/{id_tienda}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-tienda-papi quiero cambiar campos de una tienda para editar sus datos y para abrirla, cerrarla o pausarla.
- Criterios de aceptación:
  - [ ] `PATCH /tiendas/A` con `{ "estado": "pausada" }` responde 200 con la tienda completa y solo cambia el estado.
  - [ ] Con `nombre` o `direccion` (solo el `texto`), responde 200 y cambia solo ese campo; se pueden enviar varios campos juntos.
  - [ ] Con `horario`, la semana enviada reemplaza la anterior: si antes abría de lunes a sábado y se envían solo lunes a viernes, el sábado ya no aparece (regla 14).
  - [ ] Un `horario` vacío (`[]`) responde 400.
  - [ ] Si trae `id_cadena`, `id_en_cadena` o `id_tienda`, responde 400 `solicitud-invalida` y no cambia nada.
  - [ ] Con una tienda que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para estado, horario, un 400 y el 404, con la base de datos simulada.
- Notas: `tiendas-sapi` no revisa reglas: la guarda «no abrir sin productos» (decisión 51f) la hace `gestionar-tienda-papi`. Decisión de ella (2026-11-19): horario = semana completa, mínimo un día. ⚠️ Al cambiar `direccion` se sugiere conservar el mismo `id_direccion` y cambiar solo el `texto` (por confirmar al construir). Estimada contra MDX-008 (igual: cambio parcial y reemplazo del horario). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /tiendas/{id_tienda}` en `http://localhost:8082/api/v1` |
  | Parámetro de ruta | `id_tienda` (texto, ej. `A`) |
  | Cuerpo | **Tienda** solo con lo que cambia: `nombre`, `direccion`, `horario` o `estado` |
  | 200 | **Tienda** completa con los campos nuevos |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "estado": "pausada" }`

### MDX-014 · tiendas-sapi: GET /cadenas/{id_cadena}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero leer en vivo los datos de la cadena para saber qué traductor y contacto usar en el aviso (decisión 46).
- Criterios de aceptación:
  - [ ] `GET /cadenas/farmacias-salud` responde 200 con `nombre`, `contacto_tecnico` y `flujo_traductor`, en la forma del ejemplo.
  - [ ] `GET /cadenas/no-existe` responde 404 con `codigo: no-encontrado`.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Estimada contra MDX-011 (igual). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /cadenas/{id_cadena}` en `http://localhost:8082/api/v1` |
  | Parámetro de ruta | `id_cadena` (texto, ej. `farmacias-salud`) |
  | 200 | **Cadena** con su **Contacto** |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: ver `../contratos/raml/comun/ejemplos/cadena.raml`.

### MDX-015 · tiendas-sapi: POST /cadenas
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como persona de Mandaditos (Postman) quiero registrar una cadena para poder crear después sus sucursales.
- Criterios de aceptación:
  - [ ] Con `nombre`, `contacto_tecnico` (`nombre` y `telefono`) y `flujo_traductor`, responde 201 con la cadena y su `id_cadena` con la forma `cad-<número>` (regla 13).
  - [ ] Si falta alguno de los tres, responde 400 `solicitud-invalida`.
  - [ ] Hay una colección de Postman con la llamada guardada en el repositorio.
  - [ ] Hay pruebas MUnit en verde para el 201 y el 400, con la base de datos simulada.
- Notas: Solo la usa una persona con Postman (decisión 51). Estimada contra MDX-012 (más chica: un solo objeto, sin horario). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /cadenas` en `http://localhost:8082/api/v1` |
  | Cuerpo | **Cadena**: `nombre`, `contacto_tecnico` y `flujo_traductor` obligatorios |
  | 201 | **Cadena** con su `id_cadena` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "nombre": "Farmacias Salud", "contacto_tecnico": { "nombre": "Mesa de ayuda Farmacias Salud", "telefono": "6015550100" }, "flujo_traductor": "traducir-farmacias-salud" }`

### MDX-016 · tiendas-sapi: PATCH /cadenas/{id_cadena}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como persona de Mandaditos (Postman) quiero editar una cadena para mantener al día su contacto y traductor.
- Criterios de aceptación:
  - [ ] `PATCH /cadenas/farmacias-salud` con un `contacto_tecnico` nuevo responde 200 con la cadena completa y solo cambia el contacto.
  - [ ] Si trae `id_cadena`, responde 400 y no cambia nada.
  - [ ] Con una cadena que no existe responde 404.
  - [ ] La llamada está en la colección de Postman de MDX-015.
  - [ ] Hay pruebas MUnit en verde para el 200, el 400 y el 404, con la base de datos simulada.
- Notas: Solo Postman (decisión 51). Estimada contra MDX-013 (más chica: sin horario). Depende de MDX-009. RAML: `../contratos/raml/system/tiendas-sapi/tiendas-sapi.raml`; tipos en `../contratos/raml/comun/tipos/tiendas.raml`. Refinada el 2026-11-19. Contrato (copia de `tiendas-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /cadenas/{id_cadena}` en `http://localhost:8082/api/v1` |
  | Parámetro de ruta | `id_cadena` (texto, ej. `farmacias-salud`) |
  | Cuerpo | **Cadena** solo con lo que cambia: `nombre`, `contacto_tecnico` o `flujo_traductor` |
  | 200 | **Cadena** completa |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "contacto_tecnico": { "nombre": "Mesa de ayuda Farmacias Salud", "telefono": "6015550199" } }`

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
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer productos por `id_tienda`, `ids` o `id_cadena` + `id_en_cadena` para mostrar el catálogo, tomar los precios al pagar y reconocer productos de cadena (filtros combinables, regla 7).
- Criterios de aceptación:
  - [ ] Sin filtros responde 200 con todos los productos.
  - [ ] `?id_tienda=A` responde los productos cuya lista `tiendas` incluye a A, **también los que están `inactivo` en A**.
  - [ ] `?ids=12,40` responde solo esos; `?ids=12,99` (99 no existe) responde 200 solo con el 12.
  - [ ] `?id_cadena=farmacias-salud&id_en_cadena=SKU-0451` responde el producto de esa cadena.
  - [ ] Si vienen varios filtros, se aplican juntos; si nada coincide, responde `[]`.
  - [ ] Hay pruebas MUnit en verde para cada filtro, la combinación y el `[]`, con la base de datos simulada.
- Notas: Decisiones de ella (2026-11-19): los inactivos sí salen (los esconde `gestionar-catalogo-papi` en la vitrina; el gerente los necesita para reactivarlos); un id que no existe no da error (opción C, igual que MDX-010). Estimada contra MDX-008 (igual: lista con filtros y lista anidada). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /productos` en `http://localhost:8083/api/v1` |
  | Parámetros de query | `id_tienda`, `ids` (ej. `12,15,40`), `id_cadena`, `id_en_cadena`: todos opcionales |
  | 200 | lista de **Producto** |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: ver `../contratos/raml/comun/ejemplos/productos-lista.raml`.

### MDX-019 · catalogo-sapi: GET /productos/{id_producto}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer un producto para ver sus datos completos.
- Criterios de aceptación:
  - [ ] `GET /productos/12` responde 200 con el producto y su lista `tiendas`, en la forma del ejemplo.
  - [ ] Con un producto que no existe responde 404 con `codigo: no-encontrado`.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Estimada contra MDX-011 (igual). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /productos/{id_producto}` en `http://localhost:8083/api/v1` |
  | Parámetro de ruta | `id_producto` (texto, ej. `12`) |
  | 200 | **Producto** |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: ver `../contratos/raml/comun/ejemplos/producto.raml`.

### MDX-020 · catalogo-sapi: POST /productos
- Tipo: historia
- Estado: lista
- Puntos: 5
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero guardar un producto nuevo, uno por llamada, con `clave` opcional para no duplicarlo al retomar una carga (201, o 200 si ya existía).
- Criterios de aceptación:
  - [ ] Con `nombre`, `descripcion`, `precio` y `tiendas`, responde 201 con el producto y su `id_producto` con la forma `pdto-<número>` (regla 13).
  - [ ] Si un elemento de `tiendas` no trae `agotado` o `estado`, se guarda `agotado: false` y `estado: activo`.
  - [ ] Si falta `nombre`, `descripcion`, `precio` o `tiendas`, responde 400 `solicitud-invalida`.
  - [ ] `"tiendas": []` responde 400 (mínimo una tienda, `minItems: 1` en el tipo).
  - [ ] Con una `clave` nueva (`carga-77-12`) crea el producto (201); con la misma `clave` otra vez responde 200 con el producto ya guardado y no crea otro.
  - [ ] Sin `clave` (alta uno por uno desde el portal) siempre crea (201).
  - [ ] Hay pruebas MUnit en verde para el 201, el 200 por clave repetida y dos 400, con la base de datos simulada.
- Notas: Se usa en dos casos: el gerente crea un producto desde el portal (sin `clave`) y el procesamiento de la carga, una llamada por fila (con `clave carga-77-{fila}`). Retomar una carga = empezar desde la fila 1 sin duplicar: las filas ya hechas responden 200. `catalogo-sapi` no revisa si el producto ya existe en la cadena: eso lo hace `gestionar-catalogo-papi` antes (decisión 52). Mínimo una tienda: decisión de ella (2026-11-19). Estimada contra MDX-008 (más grande: dos tablas y la idempotencia por `clave`). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /productos` en `http://localhost:8083/api/v1` |
  | Cuerpo | **Producto**: `nombre`, `descripcion`, `precio` y `tiendas` obligatorios; `imagen`, `id_en_cadena`, `id_cadena` y `clave` opcionales |
  | 201 | **Producto** con su `id_producto` |
  | 200 | la `clave` ya estaba: el **Producto** ya guardado, sin cambiarlo |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "nombre": "Pan", "descripcion": "Pan fresco del día", "precio": 2500, "tiendas": [ { "id_tienda": "A", "agotado": false, "estado": "activo" } ] }`

### MDX-021 · catalogo-sapi: PATCH /productos/{id_producto}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero cambiar nombre, descripción, imagen o precio para mantener el catálogo al día (precio único en todas las tiendas, decisión 52).
- Criterios de aceptación:
  - [ ] `PATCH /productos/12` con `{ "precio": 2700 }` responde 200 con el producto completo y solo cambia el precio (para todas sus tiendas).
  - [ ] Se pueden enviar varios campos juntos (`nombre`, `descripcion`, `imagen`, `precio`).
  - [ ] Si trae `tiendas`, `id_cadena`, `id_en_cadena`, `clave` o `id_producto`, responde 400 y no cambia nada.
  - [ ] Con un producto que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200, un 400 y el 404, con la base de datos simulada.
- Notas: Las tiendas se cambian con MDX-022 y MDX-023, no aquí. Estimada contra MDX-016 (igual). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /productos/{id_producto}` en `http://localhost:8083/api/v1` |
  | Parámetro de ruta | `id_producto` (texto, ej. `12`) |
  | Cuerpo | **Producto** solo con lo que cambia: `nombre`, `descripcion`, `imagen` o `precio` |
  | 200 | **Producto** completo |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "precio": 2700 }`

### MDX-022 · catalogo-sapi: POST /productos/{id_producto}/tiendas
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero agregar una sucursal a un producto de cadena para no repetir el producto por sucursal (decisión 52).
- Criterios de aceptación:
  - [ ] `POST /productos/15/tiendas` con `{ "id_tienda": "B2" }` responde 200 con el producto y B2 en su lista (`agotado: false`, `estado: activo`).
  - [ ] Si B2 ya estaba en la lista (activa o `inactivo`), responde 409 `conflicto` sin `objeto_actual` y no cambia nada.
  - [ ] Si falta `id_tienda`, responde 400.
  - [ ] Con un producto que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200, el 409, el 400 y el 404, con la base de datos simulada.
- Notas: Decisión de ella (2026-11-19): una tienda que ya estaba pero `inactivo` también da 409; se reactiva con MDX-023 (`{ "estado": "activo" }`): una sola forma de reactivar. **Nota para la historia de `gestionar-catalogo-papi`:** al retomar una carga, esta llamada da 409 en las filas que ya se hicieron antes de la caída; la Process debe tomar ese 409 como «fila ya hecha» y seguir. Es la primera System con 409 (sin objeto): usa la plantilla de MDX-006. Estimada contra MDX-008 (igual). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /productos/{id_producto}/tiendas` en `http://localhost:8083/api/v1` |
  | Parámetro de ruta | `id_producto` (texto, ej. `15`) |
  | Cuerpo | **ProductoEnTienda**: `id_tienda` obligatorio |
  | 200 | **Producto** con la tienda agregada |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |

  Ejemplo de cuerpo: `{ "id_tienda": "B2" }`

### MDX-023 · catalogo-sapi: PATCH /productos/{id_producto}/tiendas/{id_tienda}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero marcar agotado o quitar/reactivar en una tienda para hacer el borrado lógico por tienda sin borrar nada.
- Criterios de aceptación:
  - [ ] `PATCH /productos/12/tiendas/A` con `{ "agotado": true }` responde 200 con el producto completo; solo cambia el elemento de A.
  - [ ] Con `{ "estado": "inactivo" }` lo quita en A (borrado lógico) y con `{ "estado": "activo" }` lo reactiva; nada se borra de la base de datos.
  - [ ] Las demás tiendas del producto no cambian.
  - [ ] Si la tienda no está en la lista del producto, o el producto no existe, responde 404.
  - [ ] Hay pruebas MUnit en verde para agotado, inactivo, activo y el 404, con la base de datos simulada.
- Notas: Mismo endpoint para `agotado` y `estado` (decisión 52f). Estimada contra MDX-013 (igual: cambio parcial dentro de una lista). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /productos/{id_producto}/tiendas/{id_tienda}` en `http://localhost:8083/api/v1` |
  | Parámetros de ruta | `id_producto` (ej. `12`) e `id_tienda` (ej. `A`) |
  | Cuerpo | **ProductoEnTienda** solo con lo que cambia: `agotado` o `estado` (`activo` · `inactivo`) |
  | 200 | **Producto** completo |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "agotado": true }`

### MDX-024 · catalogo-sapi: POST /cargas
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero abrir el ticket de una carga del Excel para seguir la carga con Claim Check (`carga-77`).
- Criterios de aceptación:
  - [ ] Con `{ "id_tienda": "A" }` responde 201 con `id_carga` con la forma `carga-<número>`, `estado: revisando`, `filas: 0`, `problemas: []`, `avisos: []` y `creada` con la fecha y hora actuales.
  - [ ] Si falta `id_tienda`, responde 400.
  - [ ] Hay pruebas MUnit en verde para el 201 y el 400, con la base de datos simulada.
- Notas: Solo crea el registro del ticket: **el archivo Excel nunca llega a `catalogo-sapi`** (lo recibe `gestionar-catalogo-papi`, que lo guarda en la carpeta y revisa las filas; endpoints.md, dibujo D). Estimada contra MDX-015 (igual). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /cargas` en `http://localhost:8083/api/v1` |
  | Cuerpo | **Carga**: `id_tienda` obligatorio |
  | 201 | **Carga** con su `id_carga`, en `revisando` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo de cuerpo: `{ "id_tienda": "A" }`

### MDX-025 · catalogo-sapi: GET /cargas/{id_carga}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero leer el estado de una carga para mostrar el avance y, si se rechazó, sus problemas.
- Criterios de aceptación:
  - [ ] `GET /cargas/carga-77` responde 200 con la carga guardada: estado, filas, problemas y avisos.
  - [ ] Nunca trae `vista_previa` (no se guarda).
  - [ ] Con una carga que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Decisión 52(g): el ticket conserva los problemas aunque el archivo rechazado se borre (ella lo confirmó el 2026-11-19). Estimada contra MDX-019 (igual). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /cargas/{id_carga}` en `http://localhost:8083/api/v1` |
  | Parámetro de ruta | `id_carga` (ej. `carga-77`) |
  | 200 | **Carga** |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |

  Ejemplo 200: `{ "id_carga": "carga-77", "id_tienda": "A", "estado": "rechazada", "filas": 120, "problemas": [ { "fila": 14, "motivo": "Falta el precio" } ], "avisos": [], "creada": "2026-10-12T09:30:00" }`

### MDX-026 · catalogo-sapi: PATCH /cargas/{id_carga}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-catalogo-papi quiero cambiar el estado de la carga con la condición `si_estado_actual` para que no se confirme ni se procese dos veces (409 con el objeto actual).
- Criterios de aceptación:
  - [ ] Con `{ "estado": "lista", "filas": 120, "problemas": [], "avisos": [] }` responde 200 con la carga completa y guarda esos campos.
  - [ ] Con `{ "estado": "procesando", "si_estado_actual": "lista" }`: si la carga sigue `lista`, cambia y responde 200; si ya está en otro estado, responde 409 `conflicto` con `objeto_actual` (la carga como está) y no cambia nada.
  - [ ] Sin `si_estado_actual`, cambia igual.
  - [ ] `si_estado_actual` no se guarda.
  - [ ] Si trae `id_carga`, `id_tienda` o `creada`, responde 400.
  - [ ] Con una carga que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200, el 409 con `objeto_actual`, el 400 y el 404, con la base de datos simulada.
- Notas: Es la **primera API con 409 y `objeto_actual`**: prueba esa parte de la plantilla de MDX-006. `filas` en el PATCH: agregado el 2026-11-19 (ella; antes el contrato no dejaba guardarlo). Estimada contra MDX-008 (igual: la condición se compara en el mismo momento en que se escribe, regla 5). Depende de MDX-017. RAML: `../contratos/raml/system/catalogo-sapi/catalogo-sapi.raml`; tipos en `../contratos/raml/comun/tipos/catalogo.raml`. Refinada el 2026-11-19. Contrato (copia de `catalogo-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /cargas/{id_carga}` en `http://localhost:8083/api/v1` |
  | Parámetro de ruta | `id_carga` (ej. `carga-77`) |
  | Cuerpo | **Carga** solo con lo que cambia: `estado`, `filas`, `problemas` o `avisos`; condición `si_estado_actual` opcional |
  | 200 | **Carga** completa |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |

  Ejemplo de cuerpo: `{ "estado": "procesando", "si_estado_actual": "lista" }`

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
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero apartar el número de pedido para tener el número antes de cobrar (decisión 27).
- Criterios de aceptación:
  - [ ] Sin cuerpo responde 201 con `{ "id_pedido": <número> }`, el número que sigue.
  - [ ] Dos llamadas seguidas dan números distintos (p. ej. 102 y 103).
  - [ ] El número apartado queda guardado como reservado (lo necesita MDX-029 para saber si un `id_pedido` se reservó).
  - [ ] Un número apartado que nunca se usa queda como hueco y no se reutiliza.
  - [ ] Hay pruebas MUnit en verde para el 201, con la base de datos simulada.
- Notas: `pedidos-sapi` es la dueña de la numeración. Estimada contra MDX-024 (igual). Depende de MDX-027. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /pedidos/reservas` en `http://localhost:8084/api/v1` |
  | Cuerpo | ninguno |
  | 201 | **Pedido** solo con `id_pedido` |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 201: `{ "id_pedido": 101 }`

### MDX-029 · pedidos-sapi: POST /pedidos
- Tipo: historia
- Estado: lista
- Puntos: 5
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero crear el pedido con sus copias al pagar para guardarlo solo con el pago aprobado; cada parte nace en `Pedido nuevo`.
- Criterios de aceptación:
  - [ ] Con el pedido 101 completo responde 201 con el pedido: cada parte en `Pedido nuevo`, secuencia 1, sin `vencimiento` y con su primera fila de historial; `creado` con la fecha y hora actuales.
  - [ ] Si el `id_pedido` ya estaba creado (reintento tras un timeout), no crea nada y responde 200 con el pedido ya guardado.
  - [ ] Si el `id_pedido` nunca se reservó (p. ej. 999), responde 400.
  - [ ] Si falta `cliente`, `direccion_entrega`, `total` o `partes`, o una parte no trae sus copias (`id_tienda`, `nombre_tienda`, `direccion_tienda`, `lineas`, `subtotal`), responde 400.
  - [ ] Si trae `estado`, `secuencia`, `historial`, `cerrado` o `avisos` (los pone `pedidos-sapi`), responde 400.
  - [ ] Hay pruebas MUnit en verde para el 201, el 200 del reintento y los 400, con la base de datos simulada.
- Notas: Idempotencia por `id_pedido` (ella, 2026-11-20, opción A; se agregó el 200 al RAML). Guarda en varias tablas a la vez (pedido, partes, líneas, historial): conviene una transacción. Estimada por encima de MDX-008 por las listas anidadas. Depende de MDX-027 y MDX-028. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /pedidos` en `http://localhost:8084/api/v1` |
  | Cuerpo | **Pedido**: `id_pedido` (reservado), `cliente`, `direccion_entrega`, `total` y `partes` con sus copias del pago |
  | 201 | **Pedido** creado |
  | 200 | **Pedido** ya guardado (el `id_pedido` ya existía) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplos: `../contratos/raml/comun/ejemplos/pedido-nuevo.raml` (cuerpo) y `pedido-creado.raml` (respuesta).

### MDX-030 · pedidos-sapi: GET /pedidos
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero leer los pedidos de un `id_cliente` para armar «Mis pedidos» (decisión 58).
- Criterios de aceptación:
  - [ ] `GET /pedidos?id_cliente=cli-12` responde 200 con sus pedidos, cada uno con sus partes.
  - [ ] Un cliente sin pedidos recibe 200 con `[]`.
  - [ ] Sin `id_cliente` responde 400.
  - [ ] Hay pruebas MUnit en verde para el 200, la lista vacía y el 400, con la base de datos simulada.
- Notas: Solo trae pedidos creados; los pagos pendientes viven en `pagos-sapi`. `id_cliente` obligatorio (excepción a la regla 7). Depende de MDX-027. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /pedidos` en `http://localhost:8084/api/v1` |
  | Query | `id_cliente` (obligatorio) |
  | 200 | lista de **Pedido** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 200: `../contratos/raml/comun/ejemplos/pedidos-cliente.raml`

### MDX-031 · pedidos-sapi: GET /pedidos/{id_pedido}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer el pedido completo con sus partes para usarlo en la rutina de cierre, los avisos y la app.
- Criterios de aceptación:
  - [ ] `GET /pedidos/101` responde 200 con el pedido completo: partes, historial y avisos.
  - [ ] Un número reservado pero sin crear responde 404, igual que uno que no existe.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Estimada contra MDX-008 (igual). Depende de MDX-027. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /pedidos/{id_pedido}` en `http://localhost:8084/api/v1` |
  | Parámetro de ruta | `id_pedido` (entero, ej. 101) |
  | 200 | **Pedido** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 200: `../contratos/raml/comun/ejemplos/pedido.raml`

### MDX-032 · pedidos-sapi: PATCH /pedidos/{id_pedido}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero marcar el pedido como cerrado una sola vez para que «revisar cierre» deje pasar a uno solo (409 con el objeto actual).
- Criterios de aceptación:
  - [ ] Con `{ "cerrado": "2026-10-15T15:41:02" }` sobre un pedido abierto responde 200 con el pedido.
  - [ ] Si el pedido ya tenía `cerrado`, responde 409 `conflicto` con `objeto_actual` (el pedido) y no cambia nada.
  - [ ] Cualquier otro campo en el cuerpo responde 400.
  - [ ] Con un pedido que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200, el 409 con `objeto_actual`, el 400 y el 404, con la base de datos simulada.
- Notas: La condición se compara en el mismo momento en que se escribe (regla 5). Estimada contra MDX-026 (igual). Depende de MDX-027. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /pedidos/{id_pedido}` en `http://localhost:8084/api/v1` |
  | Cuerpo | **Pedido** solo con `cerrado` |
  | 200 | **Pedido** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "cerrado": "2026-10-15T15:41:02" }`

### MDX-033 · pedidos-sapi: PATCH /pedidos/{id_pedido}/partes/{id_tienda}
- Tipo: historia
- Estado: lista
- Puntos: 7
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero cambiar una parte con las condiciones `si_estado_actual` y `fecha_hora_respuesta` para que el Agregador no pise un estado más nuevo ni acepte respuestas tardías (409 con el objeto actual).
- Criterios de aceptación:
  - [ ] Un cambio de `estado` agrega una fila al historial con su `fecha_hora` y la `secuencia` fija del estado (Pedido nuevo 1 … Cancelado 6); si falta `fecha_hora`, responde 400.
  - [ ] Con `si_estado_actual`: si la parte sigue en ese estado, cambia y responde 200 con el pedido completo; si no, responde 409 `conflicto` con `objeto_actual` (el pedido) y no cambia nada.
  - [ ] Con `fecha_hora_respuesta` posterior al `vencimiento`, responde 409; si la parte todavía no tiene `vencimiento`, también 409.
  - [ ] `Cancelado` sin `motivo`, o un `motivo` con otro estado, responde 400.
  - [ ] `vencimiento`, `aviso_entregado` e `id_repartidor` se guardan sin tocar el historial.
  - [ ] Un campo fijo (`lineas`, `subtotal`, las copias del pago) responde 400.
  - [ ] Con un pedido que no existe, o una tienda que no está en el pedido, responde 404.
  - [ ] `pedidos-sapi` no compara secuencias por su cuenta (eso lo cuida gestionar-pedido-papi con `si_estado_actual`).
  - [ ] Hay pruebas MUnit en verde para el 200, los dos 409, los 400 y los 404, con la base de datos simulada.
- Notas: La más difícil de la API: ella le dio 7 puntos porque requiere más tiempo (2026-11-20). Decisiones de ella del 2026-11-20: sin `vencimiento` = 409 (opción A) y la System no compara secuencias (propuesta aprobada). Las condiciones se comparan en el mismo momento en que se escribe (regla 5). Depende de MDX-027 y MDX-029. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /pedidos/{id_pedido}/partes/{id_tienda}` en `http://localhost:8084/api/v1` |
  | Parámetros de ruta | `id_pedido` (entero, ej. 101), `id_tienda` (ej. A) |
  | Cuerpo | **Parte** solo con lo que cambia: `estado` (con `fecha_hora`), `motivo`, `vencimiento`, `aviso_entregado` o `id_repartidor`; condiciones `si_estado_actual` y `fecha_hora_respuesta` opcionales (no se guardan) |
  | 200 | **Pedido** completo |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "estado": "Aceptado", "fecha_hora": "2026-10-15T15:02:10", "si_estado_actual": "Pedido nuevo", "fecha_hora_respuesta": "2026-10-15T15:02:10" }`

### MDX-034 · pedidos-sapi: POST /pedidos/{id_pedido}/avisos
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como notificar-estado-papi quiero anotar «ya avisé al cliente» con su `id_aviso` para no avisar dos veces lo mismo (201, o 200 si ya existía).
- Criterios de aceptación:
  - [ ] La primera vez de `estado-101-A-enreparto` responde 201 con el pedido y el aviso anotado.
  - [ ] Si llega de nuevo el mismo `id_aviso`, responde 200 con el pedido sin cambios (no se anota dos veces).
  - [ ] Si falta `id_aviso`, `canal` o `fecha_hora`, responde 400.
  - [ ] Con un pedido que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 201, el 200 del repetido, el 400 y el 404, con la base de datos simulada.
- Notas: Idempotencia (sección «Idempotencia» de `reglas-raml.md`). Depende de MDX-027. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /pedidos/{id_pedido}/avisos` en `http://localhost:8084/api/v1` |
  | Parámetro de ruta | `id_pedido` (entero, ej. 101) |
  | Cuerpo | **Aviso**: `id_aviso`, `canal` (`whatsapp` o `correo`), `fecha_hora` |
  | 201 | **Pedido** con el aviso anotado |
  | 200 | **Pedido** sin cambios (el `id_aviso` ya estaba) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "id_aviso": "estado-101-A-enreparto", "canal": "whatsapp", "fecha_hora": "2026-10-15T15:27:35" }`

### MDX-035 · pedidos-sapi: GET /partes
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer partes por tienda, estado o fecha de entrega para mostrar la pantalla de la tienda y armar `ventas-semana` (filtros combinables, regla 7).
- Criterios de aceptación:
  - [ ] `GET /partes?id_tienda=A` responde 200 con las partes de A, cada una con su `id_pedido`.
  - [ ] `?entregado_desde=2026-09-28T00:00:00&entregado_hasta=2026-10-04T23:59:59` trae las entregadas en esa semana, contando por la fila `Entregado` del historial, con los dos límites incluidos.
  - [ ] Varios filtros se aplican juntos; sin filtros trae todas; si nada coincide, 200 con `[]`.
  - [ ] Un `estado` que no es de la lista oficial responde 400.
  - [ ] Hay pruebas MUnit en verde para cada filtro, la combinación, la lista vacía y el 400, con la base de datos simulada.
- Notas: Sin paginación (regla 7). Depende de MDX-027. RAML: `../contratos/raml/system/pedidos-sapi/pedidos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pedidos.raml`. Refinada el 2026-11-20. Contrato (copia de `pedidos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /partes` en `http://localhost:8084/api/v1` |
  | Query | `id_tienda`, `estado`, `entregado_desde`, `entregado_hasta` (todos opcionales) |
  | 200 | lista de **Parte** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 200: `../contratos/raml/comun/ejemplos/partes-lista.raml`

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
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero anotar el intento de pago `pendiente` para tenerlo registrado antes de llamar a la pasarela (201, o 200 si ya existía).
- Criterios de aceptación:
  - [ ] Con `{ "id_pago": "cobro-101", "id_pedido": 101, "id_cliente": "cli-12", "monto": 40000 }` responde 201 con el pago en `pendiente` y `creado` con la fecha y hora actuales.
  - [ ] Si el `id_pago` ya estaba, no lo anota de nuevo y responde 200 con el pago guardado, sin cambios.
  - [ ] Si falta `id_pago`, `id_pedido`, `id_cliente` o `monto`, responde 400.
  - [ ] Si trae `estado`, `referencia_pasarela` o `creado` (los pone `pagos-sapi`), responde 400.
  - [ ] Hay pruebas MUnit en verde para el 201, el 200 del repetido y los 400, con la base de datos simulada.
- Notas: Idempotencia (sección «Idempotencia» de `reglas-raml.md`). `token_pago` y `motivo` nunca se guardan. Estimada contra MDX-034 (igual). Depende de MDX-036. RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pagos.raml`. Refinada el 2026-11-20. Contrato (copia de `pagos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /pagos` en `http://localhost:8085/api/v1` |
  | Cuerpo | **Pago**: `id_pago`, `id_pedido`, `id_cliente`, `monto` |
  | 201 | **Pago** en `pendiente` |
  | 200 | **Pago** ya guardado (el `id_pago` ya existía) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "id_pago": "cobro-101", "id_pedido": 101, "id_cliente": "cli-12", "monto": 40000 }`

### MDX-038 · pagos-sapi: PATCH /pagos/{id_pago}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero guardar el resultado del cobro y la `referencia_pasarela` para saber si se aprobó y poder devolver después (decisión 47).
- Criterios de aceptación:
  - [ ] Con `{ "estado": "aprobado", "referencia_pasarela": "MP-778899" }` sobre un pago `pendiente` responde 200 con el pago completo.
  - [ ] Con `{ "estado": "rechazado" }` sobre un pago `pendiente` responde 200.
  - [ ] Si el pago ya está `aprobado` o `rechazado`, responde 409 `conflicto` con `objeto_actual` (el pago) y no cambia nada.
  - [ ] `aprobado` sin `referencia_pasarela` responde 400; `estado: pendiente` responde 400 (un pago no vuelve atrás).
  - [ ] Si trae `id_pago`, `id_pedido`, `id_cliente`, `monto` o `creado`, responde 400.
  - [ ] Con un pago que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para los dos 200, el 409 con `objeto_actual`, los 400 y el 404, con la base de datos simulada.
- Notas: Decisión de ella del 2026-11-20 (opción A): solo cambia si está `pendiente`; un estado final no se pisa (protege el registro del dinero, como el pedido que se cierra una sola vez). Se agregó el 409 al RAML. La condición se compara en el mismo momento en que se escribe (regla 5). Estimada contra MDX-026 (igual). Depende de MDX-036. RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pagos.raml`. Refinada el 2026-11-20. Contrato (copia de `pagos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /pagos/{id_pago}` en `http://localhost:8085/api/v1` |
  | Parámetro de ruta | `id_pago` (ej. `cobro-101`) |
  | Cuerpo | **Pago** con `estado` (`aprobado` o `rechazado`) y, si aprobó, `referencia_pasarela` |
  | 200 | **Pago** completo |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "estado": "aprobado", "referencia_pasarela": "MP-778899" }`

### MDX-039 · pagos-sapi: GET /pagos/{id_pago}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como realizar-pedido-papi quiero leer un intento de pago para encontrar el pendiente en el reintento.
- Criterios de aceptación:
  - [ ] `GET /pagos/cobro-101` responde 200 con el pago guardado.
  - [ ] Nunca trae `token_pago` ni `motivo` (no se guardan).
  - [ ] Con un pago que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Estimada contra MDX-025 (igual). Depende de MDX-036. RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pagos.raml`. Refinada el 2026-11-20. Contrato (copia de `pagos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /pagos/{id_pago}` en `http://localhost:8085/api/v1` |
  | Parámetro de ruta | `id_pago` (ej. `cobro-101`) |
  | 200 | **Pago** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 200: `../contratos/raml/comun/ejemplos/pago.raml`

### MDX-040 · pagos-sapi: GET /pagos
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como Process API quiero leer pagos por `id_pedido` o por `id_cliente` (+ `estado`) para hallar el pago aprobado en la rutina de cierre y los pendientes de «Mis pedidos» (decisión 58).
- Criterios de aceptación:
  - [ ] `GET /pagos?id_pedido=101` responde 200 con los pagos del pedido 101.
  - [ ] `?id_cliente=cli-12&estado=pendiente` trae los pagos pendientes de ese cliente.
  - [ ] Si vienen `id_pedido` e `id_cliente` juntos, se aplican los dos; `estado` se aplica junto con los otros.
  - [ ] Sin `id_pedido` ni `id_cliente` responde 400; un `estado` fuera de la lista responde 400.
  - [ ] Si nada coincide, responde 200 con `[]`.
  - [ ] Hay pruebas MUnit en verde para cada filtro, la combinación, la lista vacía y los 400, con la base de datos simulada.
- Notas: Al menos uno de los dos filtros es obligatorio (excepción a la regla 7); los dos juntos se aplican juntos (ella, 2026-11-20). Sin paginación. Estimada contra MDX-035 (igual). Depende de MDX-036. RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pagos.raml`. Refinada el 2026-11-20. Contrato (copia de `pagos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /pagos` en `http://localhost:8085/api/v1` |
  | Query | `id_pedido` o `id_cliente` (al menos uno); `estado` (opcional) |
  | 200 | lista de **Pago** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 200: `../contratos/raml/comun/ejemplos/pagos-lista.raml`

### MDX-041 · pagos-sapi: POST /devoluciones
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero anotar la devolución `pendiente` para no devolver dos veces (clave `devolucion-101`).
- Criterios de aceptación:
  - [ ] Con `{ "id_devolucion": "devolucion-101", "id_pedido": 101, "monto": 27000 }` responde 201 con la devolución en `pendiente` e `intentos: 0`.
  - [ ] `id_tienda` es opcional: viene en la devolución de una sola tienda (`devolucion-101-A`) y se guarda.
  - [ ] Si el `id_devolucion` ya estaba, no la anota de nuevo y responde 200 con la devolución guardada, sin cambios.
  - [ ] Si falta `id_devolucion`, `id_pedido` o `monto`, responde 400; si trae `estado` o `intentos`, responde 400.
  - [ ] Hay pruebas MUnit en verde para el 201 (con y sin `id_tienda`), el 200 del repetido y los 400, con la base de datos simulada.
- Notas: Idempotencia: así nunca se devuelve dos veces. Estimada contra MDX-034 (igual). Depende de MDX-036. RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pagos.raml`. Refinada el 2026-11-20. Contrato (copia de `pagos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /devoluciones` en `http://localhost:8085/api/v1` |
  | Cuerpo | **Devolucion**: `id_devolucion`, `id_pedido`, `monto`; `id_tienda` si es de una sola tienda |
  | 201 | **Devolucion** en `pendiente`, `intentos: 0` |
  | 200 | **Devolucion** ya guardada (el `id_devolucion` ya existía) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "id_devolucion": "devolucion-101", "id_pedido": 101, "monto": 27000 }`

### MDX-042 · pagos-sapi: PATCH /devoluciones/{id_devolucion}
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-pedido-papi quiero guardar `hecha` o `fallida` y los intentos para seguir los reintentos de la devolución (decisión 14).
- Criterios de aceptación:
  - [ ] Con `{ "estado": "hecha", "intentos": 1 }` sobre una devolución `pendiente` responde 200 con la devolución.
  - [ ] Con `{ "estado": "pendiente", "intentos": 3 }` (un reintento) responde 200 y guarda los intentos.
  - [ ] Si la devolución ya está `hecha` o `fallida`, responde 409 `conflicto` con `objeto_actual` (la devolución) y no cambia nada.
  - [ ] Si falta `estado` o `intentos`, responde 400; si trae `id_devolucion`, `id_pedido`, `id_tienda` o `monto`, responde 400.
  - [ ] Con una devolución que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para los dos 200, el 409 con `objeto_actual`, los 400 y el 404, con la base de datos simulada.
- Notas: Decisión de ella del 2026-11-20 (opción A): solo cambia si está `pendiente`; un estado final no se pisa (protege el registro del dinero, como el pedido que se cierra una sola vez). Se agregó el 409 al RAML. Los 8 reintentos de la decisión 14 se anotan con `pendiente` y más `intentos`; `fallida` es final. Estimada contra MDX-026 (igual). Depende de MDX-036. RAML: `../contratos/raml/system/pagos-sapi/pagos-sapi.raml`; tipos en `../contratos/raml/comun/tipos/pagos.raml`. Refinada el 2026-11-20. Contrato (copia de `pagos-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /devoluciones/{id_devolucion}` en `http://localhost:8085/api/v1` |
  | Parámetro de ruta | `id_devolucion` (ej. `devolucion-101`) |
  | Cuerpo | **Devolucion** con `estado` e `intentos` |
  | 200 | **Devolucion** completa |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "estado": "hecha", "intentos": 1 }`

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
  - [ ] El script carga los 4 repartidores de prueba de la tabla de abajo (no hay endpoint para crear repartidores: quedaron fuera del alcance en la sesión 21).
- Notas: Puerto 8086. Repartidores de prueba (aprobados por ella el 2026-11-20; campos de `datos.md` 1.6, ids con la regla 13, `ultima_posicion` vacía por el GPS en pausa, nombres y teléfonos inventados):

  | `id_repartidor` | `nombre` | `telefono` | `activo` | `disponibilidad` | Para qué prueba |
  |---|---|---|---|---|---|
  | `rep-7` | Carlos Ruiz | 3109876543 | true | `libre` | Caso normal: acepta y pasa a `ocupado` |
  | `rep-8` | Laura Gómez | 3201234567 | true | `libre` | Segundo repartidor: el que llega tarde (409) |
  | `rep-9` | Andrés Pérez | 3005551122 | true | `desconectado` | No está trabajando |
  | `rep-10` | Sofía Torres | 3157778899 | false | `desconectado` | Dado de baja: la System lo cambia igual (la regla es de la Process) |

  RAML: `../contratos/raml/system/logistica-sapi/`. Depende de MDX-001, MDX-005 y MDX-006 (reutiliza la plantilla de errores). Criterios comunes a las 5 tareas de crear proyecto (aprobados el 2026-11-18). Estimada contra MDX-008 (más chica: reutiliza MDX-006).

### MDX-044 · logistica-sapi: POST /ofertas
- Tipo: historia
- Estado: lista
- Puntos: 3
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero crear la oferta `abierta` con su `vencimiento` para ofrecer la parte a los repartidores por 2 minutos (decisión 49).
- Criterios de aceptación:
  - [ ] Con `{ "id_oferta": "oferta-101-A", "id_pedido": 101, "id_tienda": "A", "intento": 1, "vencimiento": "2026-10-15T15:12:00" }` responde 201 con la oferta en `abierta`.
  - [ ] Si el `id_oferta` ya estaba, no la crea de nuevo y responde 200 con la oferta guardada, sin cambios.
  - [ ] Si falta alguno de los cinco campos, o `intento` no es 1 ni 2, responde 400.
  - [ ] Si trae `estado` o `id_repartidor`, responde 400.
  - [ ] Hay pruebas MUnit en verde para el 201, el 200 del repetido y los 400, con la base de datos simulada.
- Notas: Idempotencia por `id_oferta` (ella, 2026-11-20, opción A; se agregó el 200 al RAML: había quedado fuera de la lista de la regla por olvido). Estimada contra MDX-037 (igual). Depende de MDX-043. RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`; tipos en `../contratos/raml/comun/tipos/logistica.raml`. Refinada el 2026-11-20. Contrato (copia de `logistica-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `POST /ofertas` en `http://localhost:8086/api/v1` |
  | Cuerpo | **Oferta**: `id_oferta`, `id_pedido`, `id_tienda`, `intento`, `vencimiento` |
  | 201 | **Oferta** en `abierta` |
  | 200 | **Oferta** ya guardada (el `id_oferta` ya existía) |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "id_oferta": "oferta-101-A", "id_pedido": 101, "id_tienda": "A", "intento": 1, "vencimiento": "2026-10-15T15:12:00" }`

### MDX-045 · logistica-sapi: GET /ofertas/{id_oferta}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero leer una oferta para que la alarma revise su estado e intento.
- Criterios de aceptación:
  - [ ] `GET /ofertas/oferta-101-A` responde 200 con la oferta guardada (estado, intento, vencimiento y, si se aceptó, el repartidor).
  - [ ] Con una oferta que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200 y el 404, con la base de datos simulada.
- Notas: Estimada contra MDX-039 (igual). Depende de MDX-043. RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`; tipos en `../contratos/raml/comun/tipos/logistica.raml`. Refinada el 2026-11-20. Contrato (copia de `logistica-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `GET /ofertas/{id_oferta}` en `http://localhost:8086/api/v1` |
  | Parámetro de ruta | `id_oferta` (ej. `oferta-101-A`) |
  | 200 | **Oferta** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo 200: `../contratos/raml/comun/ejemplos/oferta.raml`

### MDX-046 · logistica-sapi: PATCH /ofertas/{id_oferta}
- Tipo: historia
- Estado: lista
- Puntos: 5
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero aceptar o vencer la oferta con condiciones para que solo un repartidor la tome y no después del vencimiento (409 con el objeto actual).
- Criterios de aceptación:
  - [ ] Con `{ "estado": "aceptada", "id_repartidor": "rep-7", "si_estado_actual": "abierta", "fecha_hora_respuesta": "2026-10-15T15:11:20" }` sobre una oferta `abierta` y antes del `vencimiento`, cambia y responde 200 con la oferta.
  - [ ] Con `{ "estado": "vencida", "si_estado_actual": "abierta" }` sobre una oferta `abierta`, cambia y responde 200.
  - [ ] Si la oferta ya está `aceptada` o `vencida`, responde 409 `conflicto` con `objeto_actual` (la oferta) y no cambia nada, **aunque no venga `si_estado_actual`**: la API consulta en la base de datos cómo está.
  - [ ] Con `fecha_hora_respuesta` posterior al `vencimiento`, responde 409.
  - [ ] `aceptada` sin `id_repartidor`, `vencida` con `id_repartidor` o `estado: abierta` responden 400; si trae `id_oferta`, `id_pedido`, `id_tienda`, `intento` o `vencimiento`, responde 400.
  - [ ] Con una oferta que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para los dos 200, los 409 (estado final con y sin condición, y respuesta tardía), los 400 y el 404, con la base de datos simulada.
- Notas: Decisión de ella del 2026-11-20: `aceptada` y `vencida` son finales y la System lo revisa siempre contra la base de datos, igual que pagos y devoluciones. Las condiciones se comparan en el mismo momento en que se escribe (regla 5). 5 puntos: dos condiciones más las validaciones (MDX-026 tenía una). Depende de MDX-043. RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`; tipos en `../contratos/raml/comun/tipos/logistica.raml`. Refinada el 2026-11-20. Contrato (copia de `logistica-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /ofertas/{id_oferta}` en `http://localhost:8086/api/v1` |
  | Parámetro de ruta | `id_oferta` (ej. `oferta-101-A`) |
  | Cuerpo | **Oferta** con `estado` (`aceptada` o `vencida`), `id_repartidor` al aceptar; condiciones `si_estado_actual` y `fecha_hora_respuesta` opcionales (no se guardan) |
  | 200 | **Oferta** completa |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`); 409 con el tipo `Conflicto` |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "estado": "aceptada", "id_repartidor": "rep-7", "si_estado_actual": "abierta", "fecha_hora_respuesta": "2026-10-15T15:11:20" }`

### MDX-047 · logistica-sapi: PATCH /repartidores/{id_repartidor}
- Tipo: historia
- Estado: lista
- Puntos: 2
- Sprint: —
- Épica: System APIs
- Creada: 2026-11-18
- Cerrada: —
- Historia: Como gestionar-repartidor-papi quiero marcar al repartidor ocupado o libre para no ofrecerle otra parte mientras reparte.
- Criterios de aceptación:
  - [ ] Con `{ "disponibilidad": "ocupado" }` sobre `rep-7` responde 200 con el repartidor.
  - [ ] Acepta los tres valores `desconectado`, `libre` y `ocupado`; otro valor responde 400.
  - [ ] Cualquier otro campo en el cuerpo responde 400.
  - [ ] No revisa `activo`: con `rep-10` (dado de baja) cambia igual.
  - [ ] Con un repartidor que no existe responde 404.
  - [ ] Hay pruebas MUnit en verde para el 200, los 400 y el 404, con la base de datos simulada.
- Notas: Propuesta aprobada por ella (2026-11-20): la regla de no usar repartidores dados de baja es de `gestionar-repartidor-papi`. Usa los repartidores de prueba de MDX-043. Estimada contra MDX-039 (igual). Depende de MDX-043. RAML: `../contratos/raml/system/logistica-sapi/logistica-sapi.raml`; tipos en `../contratos/raml/comun/tipos/logistica.raml`. Refinada el 2026-11-20. Contrato (copia de `logistica-sapi.raml`):

  | | |
  |---|---|
  | Ruta | `PATCH /repartidores/{id_repartidor}` en `http://localhost:8086/api/v1` |
  | Parámetro de ruta | `id_repartidor` (ej. `rep-7`) |
  | Cuerpo | **Repartidor** solo con `disponibilidad` |
  | 200 | **Repartidor** |
  | Errores | 400, 401, 404 y 500 con el cuerpo `Error` (`codigo`, `mensaje`, `correlacion`) |
  | Encabezados | `client_id` y `client_secret` (obligatorios), `X-Correlation-ID` (opcional) |

  Ejemplo de cuerpo: `{ "disponibilidad": "ocupado" }`

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

### MDX-050 · Broker de mensajes en la nube, gratis y sin tarjeta
- Tipo: investigación
- Estado: nueva
- Puntos: ?
- Sprint: —
- Épica: —
- Creada: 2026-11-25
- Cerrada: —
- Historia: Como desarrolladora quiero un broker en la nube que llegue desde CloudHub, gratis y sin tarjeta de crédito, para desplegar las APIs que usan colas.
- Criterios de aceptación:
- Notas: Idea de ella (2026-11-25): no quiere AWS (sin acceso y miedo a cargos en la tarjeta). Búsqueda hecha: Firebase no sirve (FCM es para notificaciones a celulares, no es un broker entre servidores); no se encontró ActiveMQ administrado gratis sin tarjeta; candidatos: CloudAMQP plan Little Lemur (RabbitMQ, gratis sin datos de pago según su documentación; 1 M mensajes/mes, 20 conexiones, 100 colas; ojo: es AMQP, no la ActiveMQ Connection, y el mensaje diferido necesita un plugin, ⚠️ por verificar), Solace Cloud (JMS, prueba de 30 días, tarjeta sin confirmar), IBM MQ Lite (JMS, sin tarjeta según IBM, otro producto). No hace falta en el sprint 1: MDX-049 no usa el broker y el pedido 101 puede correr en local. Criterios y puntos por refinar.

## Terminadas
