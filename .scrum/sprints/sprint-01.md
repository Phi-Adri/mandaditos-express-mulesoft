# Sprint 1
- Estado: activo
- Inicio: 2026-11-24
- Fin: 2026-12-04
- Objetivo: Dejar el terreno listo (base de datos, broker con sus canales, contratos en Exchange) y la primera System API, `clientes-sapi`, respondiendo con su prueba MUnit en verde.
- Compromiso inicial: 25 puntos — MDX-001 (2), MDX-002 (3), MDX-003 (3), MDX-004 (3), MDX-005 (3), MDX-006 (5), MDX-008 (3), MDX-049 (3)

Capacidad: 68 bloques (8 días completos + el 27-nov a medio tiempo; sin días no disponibles). Sin velocidad todavía. MDX-049 va de última por el riesgo de la cuenta de prueba (⚠️ CloudHub y políticas); si no se puede, sale sin afectar el objetivo. Si sobra tiempo (sin comprometer): MDX-009 (2), MDX-010 (3), MDX-011 (2), como cambio de alcance.

## Cambios de alcance

## Dailies
### 2026-11-25
- Hice: planificación del sprint 1. MDX-001 hecha (PostgreSQL 17 en Docker, una base por System API, decisión en el README, renombre `Cambio` → `CambioEstado`). MDX-002 en curso: comparación Classic/Artemis con fuentes; los dos brokers en Docker; Studio publica y consume en los dos (criterio 4); mensaje diferido comprobado en Classic (pestaña Scheduled, `AMQ_SCHEDULED_DELAY` en User Properties). Fuera del sprint: Postman arreglado.
- Haré: prueba 3 en Artemis (Delivery delay), prueba 4 (vencido) en los dos, elegir el broker y escribirlo en el README; si alcanza, pasarlo al `docker-compose.yml`. 3 a 4 bloques (inglés de 2 a 3 pm).
- Bloqueos: ninguno
- Bloques: 5 + 0 (24-nov: 4, sin cronómetro, anotados a mano; 25-nov: 1 hasta la daily)

## Impedimentos
| # | Desde | Qué bloquea | Historia | Acción siguiente | Estado |
|---|---|---|---|---|---|

## Cierre
