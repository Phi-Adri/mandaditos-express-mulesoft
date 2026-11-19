# Mandaditos Express — Fase 4 (prototipo en Mule)
- Clave: MDX
- Inicio: 2026-11-18
- Duración del sprint: 10
- Capacidad por sprint: por definir
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
- Día de daily: todos los días hábiles
- Cada historia de endpoint lleva copiado su contrato (ruta, parámetros, cuerpo, respuesta y códigos, sacados del RAML): la historia se entiende sin abrir `contratos/`.
- Los RAML de `contratos/raml/` mandan sobre lo publicado en Design Center y Exchange: todo cambio se hace primero en la carpeta, se valida y después se sube (2026-11-18).
