# Mandaditos Express — Fase 4 (prototipo en Mule)
- Clave: MDX
- Inicio: 2026-11-18
- Duración del sprint: 10
- Capacidad por sprint: **8 bloques de 30 min por día** (meta de ella: al menos 4 horas por día; medio tiempo = 4 bloques), **lunes a viernes** (confirmado por ella el 2026-11-20). Sprint 1 (23-nov al 4-dic): 9 días completos + el 27-nov a medio tiempo = **76 bloques (38 horas)**. Es un presupuesto de tiempo solo para el sprint 1: sin velocidad todavía, los puntos que caben se ven al cerrarlo. Referencia: el 2026-11-20 tuvo 2 h 40 min activas.
- Fecha objetivo: sin fecha

## Visión
Construir en Anypoint Studio las 15 APIs de Mandaditos Express a partir de los RAML ya aprobados, para practicar los patrones de integración con código real. Se sabe que funcionó cuando el pedido 101 corre de punta a punta (pago, aviso a las tiendas, respuesta, entrega y cierre) con pruebas MUnit en verde.

## Hitos
- [ ] (por definir al armar el backlog)

## Definición de hecho
- [ ] Las pruebas MUnit de la historia están en verde
- [ ] El flujo cumple su RAML (códigos, cuerpos y errores)
- [ ] Revisado contra el plan del flujo (lista R1 a R12 de `/flujo`)
- [ ] Commit con el ID de la historia (`MDX-004: …`)
- [ ] Lo que se decidió en el camino quedó anotado en los documentos del ejercicio

## Acuerdos de trabajo
- Límite de trabajo en curso: 2
- Objetivo del sprint 1 (moderado, aprobado por ella el 2026-11-20): la épica «Preparar el terreno» (MDX-001 a 006) y `clientes-sapi` (MDX-008; MDX-049 si alcanza); si sobra tiempo, historias de `tiendas-sapi`. Se confirma con /planificar el 23-nov.
- **Retroalimentación del tiempo al cierre de cada sprint** (pedido de ella, 2026-11-20: quiere aprender a trabajar sola desde casa): en la retro, antes de las acciones, revisar los datos de `bloques.md` del sprint: horas y bloques por día frente a la meta de 8, bloques completos y cortados, mejores franjas horarias, días sin bloques, y bloques frente a puntos hechos. Usar el cronómetro (`bloque.ps1`) cada día para que haya datos. En el sprint 1 se usa **a mano** (ella, 2026-11-20): consultar la web para la tarea cuenta como trabajo; si algo la saca de la tarea más de unos minutos, toca «Me interrumpieron». Si olvida cortar, lo dice en la daily y se corrige en `bloques.md`. En la retro del sprint 1 se decide si hace falta un aviso por inactividad.
- Día de daily: todos los días hábiles
- Cada historia de endpoint lleva copiado su contrato (ruta, parámetros, cuerpo, respuesta y códigos, sacados del RAML): la historia se entiende sin abrir `contratos/`.
- Calendario hasta enero (2026-11-19): sprint 1 del 23-nov al 4-dic, sprint 2 del 7-dic al 21-dic (festivo 8-dic), sprint 3 del 22-dic al 6-ene (festivos 25-dic y 1-ene). Medio tiempo el 27-nov, el 24-dic y el 31-dic.
- Los RAML de `contratos/raml/` mandan sobre lo publicado en Design Center y Exchange: todo cambio se hace primero en la carpeta, se valida y después se sube (2026-11-18).
