-- CREACIÓN DE ESQUEMA Y DIMENSIONES
USE GD1C2025;
GO

CREATE SCHEMA [LOS_HELECHOS]
GO

-- DIMENSIONES
CREATE TABLE LOS_HELECHOS.BI_Dim_Tiempo (
    id_tiempo INT IDENTITY(1,1) PRIMARY KEY,
    anio INT,
    mes INT,
    cuatrimestre INT
);

CREATE TABLE LOS_HELECHOS.BI_Dim_Sucursal (
    id_sucursal INT PRIMARY KEY,
    localidad VARCHAR(255),
    provincia VARCHAR(255)
);

CREATE TABLE LOS_HELECHOS.BI_Dim_Cliente (
    id_cliente BIGINT PRIMARY KEY,
    rango_etario VARCHAR(50),
    localidad VARCHAR(255),
    provincia VARCHAR(255)
);

CREATE TABLE LOS_HELECHOS.BI_Dim_Sillon (
    id_sillon BIGINT PRIMARY KEY,
    modelo VARCHAR(255),
    descripcion VARCHAR(255),
    alto DECIMAL(6,2),
    ancho DECIMAL(6,2),
    profundidad DECIMAL(6,2)
);

CREATE TABLE LOS_HELECHOS.BI_Dim_Turno (
    id_turno INT PRIMARY KEY,
    descripcion VARCHAR(50)
);

CREATE TABLE LOS_HELECHOS.BI_Dim_EstadoPedido (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50)
);

-- HECHOS
CREATE TABLE LOS_HELECHOS.BI_Hecho_Venta (
    id_tiempo INT,
    id_sucursal INT,
    id_cliente BIGINT,
    id_sillon BIGINT,
    id_turno INT,
    cantidad BIGINT,
    total_venta DECIMAL(18,2),
    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente),
    FOREIGN KEY (id_sillon) REFERENCES LOS_HELECHOS.BI_Dim_Sillon(id_sillon),
    FOREIGN KEY (id_turno) REFERENCES LOS_HELECHOS.BI_Dim_Turno(id_turno)
);

CREATE TABLE LOS_HELECHOS.BI_Hecho_Compra (
    id_tiempo INT,
    id_sucursal INT,
    tipo_material VARCHAR(50),
    cantidad DECIMAL(18,2),
    subtotal DECIMAL(18,2),
    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal)
);

CREATE TABLE LOS_HELECHOS.BI_Hecho_Pedido (
    id_tiempo INT,
    id_sucursal INT,
    id_cliente BIGINT,
    id_turno INT,
    id_estado INT,
    cantidad_items INT,
    total_pedido DECIMAL(18,2),
    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente),
    FOREIGN KEY (id_turno) REFERENCES LOS_HELECHOS.BI_Dim_Turno(id_turno),
    FOREIGN KEY (id_estado) REFERENCES LOS_HELECHOS.BI_Dim_EstadoPedido(id_estado)
);

CREATE TABLE LOS_HELECHOS.BI_Hecho_Envio (
    id_tiempo_programada INT,
    id_tiempo_entrega INT,
    id_sucursal INT,
    id_cliente BIGINT,
    importe_traslado DECIMAL(18,2),
    importe_subida DECIMAL(18,2),
    total_envio DECIMAL(18,2),
    FOREIGN KEY (id_tiempo_programada) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_tiempo_entrega) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente)
);

-- ========================================
-- Inserts para tabla BI_Dim_Tiempo
PRINT 'Insertando datos en tabla BI_Dim_Tiempo...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Tiempo (anio, mes, cuatrimestre)
SELECT DISTINCT
    YEAR(f.fecha) AS anio,
    MONTH(f.fecha) AS mes,
    CEILING(MONTH(f.fecha)/4.0) AS cuatrimestre
FROM (
    SELECT fecha FROM LOS_HELECHOS.Pedido
    UNION
    SELECT fecha FROM LOS_HELECHOS.Compra
    UNION
    SELECT fecha FROM LOS_HELECHOS.Factura
    UNION
    SELECT fecha_programada AS fecha FROM LOS_HELECHOS.Envio
    UNION
    SELECT fecha_entrega AS fecha FROM LOS_HELECHOS.Envio
) f
WHERE f.fecha IS NOT NULL;

-- ========================================
-- Inserts para tabla BI_Dim_Sucursal
PRINT 'Insertando datos en tabla BI_Dim_Sucursal...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Sucursal (id_sucursal, localidad, provincia)
SELECT s.nro_sucursal, l.nombre_localidad, p.nombre_prov
FROM LOS_HELECHOS.Sucursal s
JOIN LOS_HELECHOS.Localidad l ON s.localidad = l.cod_localidad
JOIN LOS_HELECHOS.Provincia p ON l.provincia = p.cod_prov;

-- ========================================
-- Inserts para tabla BI_Dim_Cliente
PRINT 'Insertando datos en tabla BI_Dim_Cliente...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Cliente (id_cliente, rango_etario, localidad, provincia)
SELECT c.nro_cliente,
       CASE 
         WHEN DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()) < 25 THEN '<25'
         WHEN DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()) BETWEEN 25 AND 35 THEN '25-35'
         WHEN DATEDIFF(YEAR, c.fecha_nacimiento, GETDATE()) BETWEEN 36 AND 50 THEN '35-50'
         ELSE '>50'
       END,
       l.nombre_localidad,
       p.nombre_prov
FROM LOS_HELECHOS.Cliente c
JOIN LOS_HELECHOS.Localidad l ON c.localidad = l.cod_localidad
JOIN LOS_HELECHOS.Provincia p ON l.provincia = p.cod_prov;

-- ========================================
-- Inserts para tabla BI_Dim_Turno
PRINT 'Insertando datos en tabla BI_Dim_Turno...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Turno (id_turno, descripcion)
VALUES (1, '08:00 - 14:00'), (2, '14:00 - 20:00'), (3, 'Otro');

-- ========================================
-- Inserts para tabla BI_Dim_Sillon
PRINT 'Insertando datos en tabla BI_Dim_Sillon...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Sillon (id_sillon, modelo, descripcion, alto, ancho, profundidad)
SELECT s.codigo_sillon, sm.nombre, sm.descripcion, m.alto, m.ancho, m.profundidad
FROM LOS_HELECHOS.Sillon s
JOIN LOS_HELECHOS.Sillon_Modelo sm ON s.codigo_modelo = sm.codigo_modelo
JOIN LOS_HELECHOS.Sillon_Medida m ON s.id_medida = m.id_medida;

-- ========================================
-- Inserts para tabla BI_Dim_EstadoPedido
PRINT 'Insertando datos en tabla BI_Dim_EstadoPedido...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_EstadoPedido (descripcion)
SELECT DISTINCT LTRIM(RTRIM(UPPER(estado)))
FROM LOS_HELECHOS.Pedido
WHERE estado IS NOT NULL;

-- ========================================
-- Inserts para tabla BI_Hecho_Venta
PRINT 'Insertando datos en tabla BI_Hecho_Venta...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Venta
SELECT
    t.id_tiempo,
    f.nro_sucursal,
    f.nro_cliente,
    s.codigo_sillon,
    CASE 
        WHEN DATEPART(HOUR, f.fecha) BETWEEN 8 AND 13 THEN 1
        WHEN DATEPART(HOUR, f.fecha) BETWEEN 14 AND 19 THEN 2
        ELSE 3
    END,
    SUM(df.cantidad),
    SUM(df.subtotal)
FROM LOS_HELECHOS.Factura f
JOIN LOS_HELECHOS.Detalle_Factura df ON f.nro_factura = df.nro_factura
JOIN LOS_HELECHOS.Sillon s ON df.id_sillon = s.codigo_sillon
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON t.anio = YEAR(f.fecha) AND t.mes = MONTH(f.fecha)
GROUP BY t.id_tiempo, f.nro_sucursal, f.nro_cliente, s.codigo_sillon,
         CASE WHEN DATEPART(HOUR, f.fecha) BETWEEN 8 AND 13 THEN 1
              WHEN DATEPART(HOUR, f.fecha) BETWEEN 14 AND 19 THEN 2
              ELSE 3 END;

-- ========================================
-- Inserts para tabla BI_Hecho_Compra
PRINT 'Insertando datos en tabla BI_Hecho_Compra...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Compra
SELECT
    t.id_tiempo,
    c.suc_compra,
    COALESCE(ex.t, 'Otro'),
    SUM(dc.cantidad),
    SUM(dc.subtotal)
FROM LOS_HELECHOS.Compra c
JOIN LOS_HELECHOS.Detalle_Compra dc ON c.nro_compra = dc.nro_compra
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON t.anio = YEAR(c.fecha) AND t.mes = MONTH(c.fecha)
LEFT JOIN (
    SELECT id_tela AS id_material, 'Tela' AS t FROM LOS_HELECHOS.Tela
    UNION
    SELECT id_madera AS id_material, 'Madera' AS t FROM LOS_HELECHOS.Madera
    UNION
    SELECT id_relleno AS id_material, 'Relleno' AS t FROM LOS_HELECHOS.Relleno
) ex ON dc.material_comprado = ex.id_material
GROUP BY t.id_tiempo, c.suc_compra, COALESCE(ex.t, 'Otro');

-- ========================================
-- Inserts para tabla BI_Hecho_Pedido
PRINT 'Insertando datos en tabla BI_Hecho_Pedido...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Pedido
SELECT
    t.id_tiempo,
    p.nro_sucursal,
    p.nro_cliente,
    CASE 
        WHEN DATEPART(HOUR, p.fecha) BETWEEN 8 AND 13 THEN 1
        WHEN DATEPART(HOUR, p.fecha) BETWEEN 14 AND 19 THEN 2
        ELSE 3
    END,
    ep.id_estado,
    SUM(ISNULL(dp.cantidad, 0)),
    SUM(p.total)
FROM LOS_HELECHOS.Pedido p
LEFT JOIN LOS_HELECHOS.Detalle_Pedido dp ON p.nro_pedido = dp.nro_pedido
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON t.anio = YEAR(p.fecha) AND t.mes = MONTH(p.fecha)
JOIN LOS_HELECHOS.BI_Dim_EstadoPedido ep ON LTRIM(RTRIM(UPPER(p.estado))) = ep.descripcion
GROUP BY t.id_tiempo, p.nro_sucursal, p.nro_cliente, ep.id_estado,
         CASE WHEN DATEPART(HOUR, p.fecha) BETWEEN 8 AND 13 THEN 1
              WHEN DATEPART(HOUR, p.fecha) BETWEEN 14 AND 19 THEN 2
              ELSE 3 END;

-- ========================================
-- Inserts para tabla BI_Hecho_Envio
PRINT 'Insertando datos en tabla BI_Hecho_Envio...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Envio
SELECT
    tp.id_tiempo,
    te.id_tiempo,
    f.nro_sucursal,
    f.nro_cliente,
    SUM(e.importe_traslado),
    SUM(e.importe_subida),
    SUM(e.total)
FROM LOS_HELECHOS.Envio e
JOIN LOS_HELECHOS.Factura f ON e.nro_factura = f.nro_factura
JOIN LOS_HELECHOS.BI_Dim_Tiempo tp ON tp.anio = YEAR(e.fecha_programada) AND tp.mes = MONTH(e.fecha_programada)
JOIN LOS_HELECHOS.BI_Dim_Tiempo te ON te.anio = YEAR(e.fecha_entrega) AND te.mes = MONTH(e.fecha_entrega)
GROUP BY tp.id_tiempo, te.id_tiempo, f.nro_sucursal, f.nro_cliente;

GO