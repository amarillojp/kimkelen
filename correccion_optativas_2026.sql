-- KIMKELEN | Correccion de materias optativas de Plurilinguismo
-- Caso: ciclo 2026, primaria, grados 4 a 6.
-- Problema observado: notas asociadas a materia madre en vez de opcion.
-- Causa funcional exacta no demostrada.
-- MySQL / InnoDB. IDs exclusivos de la instalacion estudiada.
-- NO ejecutar todo el archivo de una vez. Ejecutar por secciones.
-- Usar copia de ensayo y respaldo completo de BD antes de intervenir.
-- Evitar cargas concurrentes. No ejecutar sobre una BD ya corregida
-- salvo consultas de lectura. No publicar respaldos con datos reales.

-- 1. Diagnostico (solo lectura)
SELECT DATABASE() AS base_actual;
SHOW TABLE STATUS LIKE 'course_subject';
SHOW TRIGGERS WHERE `Table` = 'course_subject';
SELECT * FROM optional_career_subject
WHERE career_subject_school_year_id IN (1821,1822,1823);

SELECT csub.year AS grado, c.name AS curso, cs.id AS course_subject_id,
       cssy.id AS id_materia, s.name AS materia,
       csub.has_options, csub.is_option,
       COUNT(DISTINCT css.student_id) AS alumnos,
       COUNT(cssm.id) AS registros_notas,
       COUNT(cssm.mark) AS notas_cargadas
FROM course_subject cs
JOIN course c ON c.id = cs.course_id
JOIN career_subject_school_year cssy ON cssy.id = cs.career_subject_school_year_id
JOIN career_subject csub ON csub.id = cssy.career_subject_id
JOIN subject s ON s.id = csub.subject_id
LEFT JOIN course_subject_student css ON css.course_subject_id = cs.id
LEFT JOIN course_subject_student_mark cssm ON cssm.course_subject_student_id = css.id
WHERE cs.id IN (5121, 5122, 5123, 5118, 5124, 5120, 5125, 5126, 5119)
GROUP BY csub.year, c.name, cs.id, cssy.id, s.name, csub.has_options, csub.is_option
ORDER BY csub.year, c.name;

-- Verificar que no exista otra cursada del idioma destino en el mismo curso.
SELECT cs.id AS origen, otro.id AS duplicado
FROM course_subject cs
JOIN course_subject otro ON otro.course_id = cs.course_id AND otro.id <> cs.id
WHERE cs.id IN (5121, 5122, 5123, 5118, 5124, 5120, 5125, 5126, 5119)
AND otro.career_subject_school_year_id = CASE cs.id
    WHEN 5121 THEN 1830
    WHEN 5122 THEN 1827
    WHEN 5123 THEN 1824
    WHEN 5118 THEN 1831
    WHEN 5124 THEN 1828
    WHEN 5120 THEN 1825
    WHEN 5125 THEN 1832
    WHEN 5126 THEN 1829
    WHEN 5119 THEN 1826
END;
-- Debe devolver cero filas. Verificar tambien la distribucion institucional.

-- 2. Respaldo (ejecutar solo antes de la correccion, una vez)
-- Si existe el respaldo, detenerse y verificarlo; no sobrescribir.
-- DDL fuera de la transaccion de correccion (commit implicito).
CREATE TABLE backup_course_subject_4_caso2026 LIKE course_subject;
INSERT INTO backup_course_subject_4_caso2026
SELECT * FROM course_subject WHERE id IN (5121, 5122, 5123)
AND career_subject_school_year_id = 1821;
SELECT * FROM backup_course_subject_4_caso2026;
-- Debe contener exactamente tres filas originales.

CREATE TABLE backup_course_subject_5_caso2026 LIKE course_subject;
INSERT INTO backup_course_subject_5_caso2026
SELECT * FROM course_subject WHERE id IN (5118, 5124, 5120)
AND career_subject_school_year_id = 1822;
SELECT * FROM backup_course_subject_5_caso2026;
-- Debe contener exactamente tres filas originales.

CREATE TABLE backup_course_subject_6_caso2026 LIKE course_subject;
INSERT INTO backup_course_subject_6_caso2026
SELECT * FROM course_subject WHERE id IN (5125, 5126, 5119)
AND career_subject_school_year_id = 1823;
SELECT * FROM backup_course_subject_6_caso2026;
-- Debe contener exactamente tres filas originales.

-- 3. Correccion: prueba reversible. Ejecutar cada bloque completo.
-- Tras verificar el resultado, repetir el bloque sustituyendo ROLLBACK por COMMIT.
-- No ejecutar COMMIT por separado despues de ROLLBACK.

-- Grado 4
START TRANSACTION;
-- 4 A - Frances
UPDATE course_subject SET career_subject_school_year_id = 1830
WHERE id = 5121 AND career_subject_school_year_id = 1821;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
-- 4 B - Italiano
UPDATE course_subject SET career_subject_school_year_id = 1827
WHERE id = 5122 AND career_subject_school_year_id = 1821;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
-- 4 C - Portugues
UPDATE course_subject SET career_subject_school_year_id = 1824
WHERE id = 5123 AND career_subject_school_year_id = 1821;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
SELECT csub.year AS grado, c.name AS curso, cs.id AS course_subject_id,
       cssy.id AS id_materia, s.name AS materia,
       csub.has_options, csub.is_option,
       COUNT(DISTINCT css.student_id) AS alumnos,
       COUNT(cssm.id) AS registros_notas,
       COUNT(cssm.mark) AS notas_cargadas
FROM course_subject cs
JOIN course c ON c.id = cs.course_id
JOIN career_subject_school_year cssy ON cssy.id = cs.career_subject_school_year_id
JOIN career_subject csub ON csub.id = cssy.career_subject_id
JOIN subject s ON s.id = csub.subject_id
LEFT JOIN course_subject_student css ON css.course_subject_id = cs.id
LEFT JOIN course_subject_student_mark cssm ON cssm.course_subject_student_id = css.id
WHERE cs.id IN (5121, 5122, 5123)
GROUP BY csub.year, c.name, cs.id, cssy.id, s.name, csub.has_options, csub.is_option
ORDER BY csub.year, c.name;
ROLLBACK;

-- Grado 5
START TRANSACTION;
-- 5 A - Frances
UPDATE course_subject SET career_subject_school_year_id = 1831
WHERE id = 5118 AND career_subject_school_year_id = 1822;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
-- 5 B - Italiano
UPDATE course_subject SET career_subject_school_year_id = 1828
WHERE id = 5124 AND career_subject_school_year_id = 1822;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
-- 5 C - Portugues
UPDATE course_subject SET career_subject_school_year_id = 1825
WHERE id = 5120 AND career_subject_school_year_id = 1822;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
SELECT csub.year AS grado, c.name AS curso, cs.id AS course_subject_id,
       cssy.id AS id_materia, s.name AS materia,
       csub.has_options, csub.is_option,
       COUNT(DISTINCT css.student_id) AS alumnos,
       COUNT(cssm.id) AS registros_notas,
       COUNT(cssm.mark) AS notas_cargadas
FROM course_subject cs
JOIN course c ON c.id = cs.course_id
JOIN career_subject_school_year cssy ON cssy.id = cs.career_subject_school_year_id
JOIN career_subject csub ON csub.id = cssy.career_subject_id
JOIN subject s ON s.id = csub.subject_id
LEFT JOIN course_subject_student css ON css.course_subject_id = cs.id
LEFT JOIN course_subject_student_mark cssm ON cssm.course_subject_student_id = css.id
WHERE cs.id IN (5118, 5124, 5120)
GROUP BY csub.year, c.name, cs.id, cssy.id, s.name, csub.has_options, csub.is_option
ORDER BY csub.year, c.name;
ROLLBACK;

-- Grado 6
START TRANSACTION;
-- 6 A - Frances
UPDATE course_subject SET career_subject_school_year_id = 1832
WHERE id = 5125 AND career_subject_school_year_id = 1823;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
-- 6 B - Italiano
UPDATE course_subject SET career_subject_school_year_id = 1829
WHERE id = 5126 AND career_subject_school_year_id = 1823;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
-- 6 C - Portugues
UPDATE course_subject SET career_subject_school_year_id = 1826
WHERE id = 5119 AND career_subject_school_year_id = 1823;
SELECT ROW_COUNT() AS filas_modificadas; -- Esperado: 1
SELECT csub.year AS grado, c.name AS curso, cs.id AS course_subject_id,
       cssy.id AS id_materia, s.name AS materia,
       csub.has_options, csub.is_option,
       COUNT(DISTINCT css.student_id) AS alumnos,
       COUNT(cssm.id) AS registros_notas,
       COUNT(cssm.mark) AS notas_cargadas
FROM course_subject cs
JOIN course c ON c.id = cs.course_id
JOIN career_subject_school_year cssy ON cssy.id = cs.career_subject_school_year_id
JOIN career_subject csub ON csub.id = cssy.career_subject_id
JOIN subject s ON s.id = csub.subject_id
LEFT JOIN course_subject_student css ON css.course_subject_id = cs.id
LEFT JOIN course_subject_student_mark cssm ON cssm.course_subject_student_id = css.id
WHERE cs.id IN (5125, 5126, 5119)
GROUP BY csub.year, c.name, cs.id, cssy.id, s.name, csub.has_options, csub.is_option
ORDER BY csub.year, c.name;
ROLLBACK;

-- 4. Auditoria posterior al COMMIT (ejecutar por separado)
SELECT csub.year AS grado, c.name AS curso, cs.id AS course_subject_id,
       cssy.id AS id_materia, s.name AS materia,
       csub.has_options, csub.is_option,
       COUNT(DISTINCT css.student_id) AS alumnos,
       COUNT(cssm.id) AS registros_notas,
       COUNT(cssm.mark) AS notas_cargadas
FROM course_subject cs
JOIN course c ON c.id = cs.course_id
JOIN career_subject_school_year cssy ON cssy.id = cs.career_subject_school_year_id
JOIN career_subject csub ON csub.id = cssy.career_subject_id
JOIN subject s ON s.id = csub.subject_id
LEFT JOIN course_subject_student css ON css.course_subject_id = cs.id
LEFT JOIN course_subject_student_mark cssm ON cssm.course_subject_student_id = css.id
WHERE cs.id IN (5121, 5122, 5123, 5118, 5124, 5120, 5125, 5126, 5119)
GROUP BY csub.year, c.name, cs.id, cssy.id, s.name, csub.has_options, csub.is_option
ORDER BY csub.year, c.name;

-- 5. Reversion de emergencia (NO ejecutar como parte de la correccion)
-- Verificar respaldos originales y ausencia de cambios posteriores incompatibles.
-- Probar primero con ROLLBACK.
START TRANSACTION;
UPDATE course_subject cs
JOIN backup_course_subject_4_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5121 AND cs.career_subject_school_year_id = 1830
AND b.career_subject_school_year_id = 1821;
UPDATE course_subject cs
JOIN backup_course_subject_4_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5122 AND cs.career_subject_school_year_id = 1827
AND b.career_subject_school_year_id = 1821;
UPDATE course_subject cs
JOIN backup_course_subject_4_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5123 AND cs.career_subject_school_year_id = 1824
AND b.career_subject_school_year_id = 1821;
UPDATE course_subject cs
JOIN backup_course_subject_5_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5118 AND cs.career_subject_school_year_id = 1831
AND b.career_subject_school_year_id = 1822;
UPDATE course_subject cs
JOIN backup_course_subject_5_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5124 AND cs.career_subject_school_year_id = 1828
AND b.career_subject_school_year_id = 1822;
UPDATE course_subject cs
JOIN backup_course_subject_5_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5120 AND cs.career_subject_school_year_id = 1825
AND b.career_subject_school_year_id = 1822;
UPDATE course_subject cs
JOIN backup_course_subject_6_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5125 AND cs.career_subject_school_year_id = 1832
AND b.career_subject_school_year_id = 1823;
UPDATE course_subject cs
JOIN backup_course_subject_6_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5126 AND cs.career_subject_school_year_id = 1829
AND b.career_subject_school_year_id = 1823;
UPDATE course_subject cs
JOIN backup_course_subject_6_caso2026 b ON b.id = cs.id
SET cs.career_subject_school_year_id = b.career_subject_school_year_id
WHERE cs.id = 5119 AND cs.career_subject_school_year_id = 1826
AND b.career_subject_school_year_id = 1823;
SELECT csub.year AS grado, c.name AS curso, cs.id AS course_subject_id,
       cssy.id AS id_materia, s.name AS materia,
       csub.has_options, csub.is_option,
       COUNT(DISTINCT css.student_id) AS alumnos,
       COUNT(cssm.id) AS registros_notas,
       COUNT(cssm.mark) AS notas_cargadas
FROM course_subject cs
JOIN course c ON c.id = cs.course_id
JOIN career_subject_school_year cssy ON cssy.id = cs.career_subject_school_year_id
JOIN career_subject csub ON csub.id = cssy.career_subject_id
JOIN subject s ON s.id = csub.subject_id
LEFT JOIN course_subject_student css ON css.course_subject_id = cs.id
LEFT JOIN course_subject_student_mark cssm ON cssm.course_subject_student_id = css.id
WHERE cs.id IN (5121, 5122, 5123, 5118, 5124, 5120, 5125, 5126, 5119)
GROUP BY csub.year, c.name, cs.id, cssy.id, s.name, csub.has_options, csub.is_option
ORDER BY csub.year, c.name;
ROLLBACK;
