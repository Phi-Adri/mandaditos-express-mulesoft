# Mandaditos Express — Prototipo de integración en MuleSoft

Prototipo en **Mule 4 (Anypoint Studio)** de **Mandaditos Express**, una app ficticia de domicilios multi-tienda (restaurantes, farmacias y supermercados, tanto tiendas de barrio como cadenas).

Es un ejercicio de aprendizaje de los **estilos de integración** y de los **patrones de integración empresarial (EIP)** de Hohpe & Woolf. Primero se diseñó todo el negocio, los flujos y los contratos (RAML), y este repositorio es la **fase de construcción**.

> Estado: **en construcción**. Se empieza por las System APIs.

## Arquitectura

- **API-led connectivity** para organizar las piezas en tres capas:
  - **Experience**: la puerta de cada pantalla o tercero (app del cliente, portal de tiendas, app del repartidor, cadenas). Traducen y no deciden nada del negocio.
  - **Process**: la lógica del negocio. `gestionar-pedido-papi` es el **Process Manager** que orquesta el pedido.
  - **System**: cada una es dueña de su base de datos.
- **Comunicación mixta**:
  - **Eventos** por un broker de mensajes (colas y temas, JMS).
  - **Llamadas directas** HTTP (RPC).
- La compensación (devoluciones cuando una tienda no cumple) sigue la idea de **Saga**.

### Las 15 APIs

| Capa | API | Puerto local |
|---|---|---|
| System | `clientes-sapi` | 8081 |
| System | `tiendas-sapi` | 8082 |
| System | `catalogo-sapi` | 8083 |
| System | `pedidos-sapi` | 8084 |
| System | `pagos-sapi` | 8085 |
| System | `logistica-sapi` | 8086 |
| Process | `gestionar-catalogo-papi` | 8087 |
| Process | `realizar-pedido-papi` | 8088 |
| Process | `gestionar-pedido-papi` | 8089 |
| Process | `gestionar-tienda-papi` | 8090 |
| Process | `gestionar-repartidor-papi` | 8091 |
| Experience | `app-cliente-eapi` | 8092 |
| Experience | `portal-tiendas-eapi` | 8093 |
| Experience | `cadenas-eapi` | 8094 |
| Experience | `app-repartidor-eapi` | 8095 |

Todas responden en `http://localhost:{puerto}/api/v1`.

### Patrones que se aplican

Canal punto a punto, publicación-suscripción, identificador de correlación, idempotencia (receptor idempotente), mensajes desordenados (secuencia), divisor, agregador, enrutador por contenido, enriquecedor, traductor de mensajes, modelo canónico, expiración de mensaje, cola de mensajes muertos, Process Manager, Wire Tap, bus de control, Detour y Claim Check.

## Tecnología

| Qué | Con qué |
|---|---|
| Runtime y desarrollo | Mule 4, Anypoint Studio |
| Contratos | RAML 1.0, publicados en Anypoint Exchange |
| Mensajería | Broker JMS (ActiveMQ, versión por definir) |
| Pruebas | MUnit |
| Base de datos | Por definir |
| Pasarela de pago | API mock (se simula MercadoPago) |

## Estructura del repositorio

```
codigo/
  README.md
  .scrum/            seguimiento del trabajo (backlog, sprints, historial)
  <api>/             un proyecto de Studio por API (se agregan a medida que se construyen)
```

## Contratos

Los RAML de las 15 APIs y sus fragments comunes (tipos, seguridad, encabezados, respuestas de error y ejemplos) se publican en **Anypoint Exchange**, y el esqueleto de cada proyecto se genera desde ahí. Reglas comunes a todas las APIs:

- Seguridad por aplicación con `client_id` y `client_secret`.
- Encabezado `X-Correlation-ID` en cada llamada, para seguir un pedido en los logs.
- Errores 400, 401, 404 y 500 en todo endpoint, con una sola estructura `Error`. El 409 devuelve el objeto actual cuando una condición no se cumple.
- Fechas en ISO 8601 en hora de Colombia, sin desfase (`2026-10-15T14:59:55`).

## Cómo correrlo

> Se completa a medida que se construye: la base de datos, el broker y el orden en que se levantan las apps.

1. Clonar el repositorio e importar cada proyecto en Anypoint Studio.
2. Levantar el broker de mensajes en local.
3. Correr cada API desde Studio. Cada una usa su puerto de la tabla de arriba.
4. Correr las pruebas: `mvn test` dentro de cada proyecto.

## Cómo se trabaja

El trabajo se organiza con Scrum en `.scrum/`, en sprints de 10 días hábiles. Cada historia se construye en ciclos rojo-verde con MUnit, y los commits llevan el ID de la historia (`MDX-008: ...`).
