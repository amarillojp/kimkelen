# Kimkelën — Corrección de materias optativas

## Caso de mantenimiento correctivo · ciclo lectivo 2026

En cuarto, quinto y sexto grado, las cursadas del Taller de Plurilingüismo quedaron vinculadas a la materia madre, pese a existir opciones curriculares de Francés, Italiano y Portugués. Las calificaciones estaban almacenadas, pero se reportaron problemas de visualización en los boletines.

La intervención reasignó la referencia `career_subject_school_year_id` de nueve registros de `course_subject`, sin modificar los identificadores de cursada ni escribir en las tablas de estudiantes o notas. La distribución por división fue confirmada institucionalmente. La causa funcional exacta de la configuración original no fue demostrada.

## Modelo de datos

- `career_subject`: materia curricular; `has_options` identifica la materia madre e `is_option` la opción.
- `career_subject_school_year`: materia por ciclo lectivo.
- `optional_career_subject`: relación entre madre y opciones.
- `course_subject`: materia de la cursada.
- `course_subject_student` y `course_subject_student_mark`: inscripciones y notas.

## Resultado de referencia

| Grado | División | Idioma | Cursada | Origen | Destino | Alumnos | Registros | Notas |
|---|---|---|---:|---:|---:|---:|---:|---:|
| 4 | A | Frances | 5121 | 1821 | 1830 | 26 | 78 | 52 |
| 4 | B | Italiano | 5122 | 1821 | 1827 | 26 | 78 | 52 |
| 4 | C | Portugues | 5123 | 1821 | 1824 | 27 | 81 | 54 |
| 5 | A | Frances | 5118 | 1822 | 1831 | 30 | 90 | 60 |
| 5 | B | Italiano | 5124 | 1822 | 1828 | 28 | 84 | 55 |
| 5 | C | Portugues | 5120 | 1822 | 1825 | 29 | 87 | 58 |
| 6 | A | Frances | 5125 | 1823 | 1832 | 31 | 93 | 61 |
| 6 | B | Italiano | 5126 | 1823 | 1829 | 31 | 93 | 31 |
| 6 | C | Portugues | 5119 | 1823 | 1826 | 29 | 87 | 58 |
| **Total** | | | | | | **257** | **771** | **481** |

Los totales corresponden al relevamiento de referencia; no constituyen una comparación individual de valores de notas. El operador informó que la operación se completó exitosamente. No se adjuntan boletines ni una auditoría final independiente.

## Uso seguro

El archivo [correccion_optativas_2026.sql](correccion_optativas_2026.sql) es un registro reproducible del caso, no una migración automática universal. Los identificadores son locales. No ejecutar el archivo completo: contiene pruebas, respaldos y reversión. Ejecutar por secciones en una copia de ensayo, verificar motor InnoDB, ausencia de triggers inesperados, relaciones y duplicados, y realizar un respaldo completo antes de intervenir. Cada actualización debe afectar una fila. Comparar las cantidades antes y después; validar también los valores individuales y los boletines. Repetir la prueba completa con COMMIT solo si todos los controles son satisfactorios. Los nombres de respaldo del archivo son convenciones nuevas para documentar el procedimiento; no representan necesariamente los respaldos ya existentes en producción.

## Prevención para 2027

Verificar el plan de estudios, las opciones del nuevo ciclo lectivo, la creación de comisiones, la asignación de estudiantes y docentes y la generación de boletines de prueba antes de cargar notas reales. Confirmar si el modelo institucional requiere una opción por estudiante o tres idiomas independientes. No reutilizar los IDs de 2026. La hipótesis de un error en la creación de comisiones requiere validación funcional.

## Privacidad

El repositorio no incluye nombres de estudiantes, notas individuales, credenciales, direcciones de servidores ni volcados de datos. Los identificadores técnicos locales se conservan para documentar el caso; revisar la política institucional antes de publicar, preferentemente en un repositorio privado si existe alguna restricción.
