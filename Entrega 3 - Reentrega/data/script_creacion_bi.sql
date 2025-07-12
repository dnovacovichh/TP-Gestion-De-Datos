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

-- VIEWS --

CREATE OR ALTER VIEW LOS_HELECHOS.BI_View_Ganancias_Mensuales AS
WITH Ventas AS (
    SELECT 
        t.anio,
        t.mes,
        s.id_sucursal,
        s.provincia,
        SUM(v.total_venta) AS total_ingresos
    FROM LOS_HELECHOS.BI_Hecho_Venta v
    JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
    JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON v.id_sucursal = s.id_sucursal
    GROUP BY t.anio, t.mes, s.id_sucursal, s.provincia
),
Compras AS (
    SELECT 
        t.anio,
        t.mes,
        s.id_sucursal,
        SUM(c.subtotal) AS total_egresos
    FROM LOS_HELECHOS.BI_Hecho_Compra c
    JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON c.id_tiempo = t.id_tiempo
    JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON c.id_sucursal = s.id_sucursal
    GROUP BY t.anio, t.mes, s.id_sucursal
)
SELECT 
    v.anio,
    v.mes,
    v.id_sucursal,
    v.provincia,
    ISNULL(v.total_ingresos, 0) AS total_ingresos,
    ISNULL(c.total_egresos, 0) AS total_egresos,
    ISNULL(v.total_ingresos, 0) - ISNULL(c.total_egresos, 0) AS ganancias
FROM Ventas v
LEFT JOIN Compras c
  ON v.anio = c.anio AND v.mes = c.mes AND v.id_sucursal = c.id_sucursal;


GO

--
CREATE or ALTER VIEW LOS_HELECHOS.BI_View_Factura_Promedio_Mensual AS
SELECT 
    t.anio,
    t.cuatrimestre,
    s.provincia,
    s.id_sucursal,
    AVG(v.total_venta) AS factura_promedio
FROM LOS_HELECHOS.BI_Hecho_Venta v
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON v.id_sucursal = s.id_sucursal
GROUP BY t.anio, t.cuatrimestre, s.provincia, s.id_sucursal;

GO

--

CREATE OR ALTER VIEW LOS_HELECHOS.BI_View_Top_Modelos_Cuatrimestral AS
SELECT *
FROM (
    SELECT
        t.anio,
        t.cuatrimestre,
        s.localidad AS localidad_sucursal,
        c.rango_etario,
        si.modelo,
        SUM(v.cantidad) AS total_vendidos,
        ROW_NUMBER() OVER (
            PARTITION BY t.anio, t.cuatrimestre, s.localidad, c.rango_etario
            ORDER BY SUM(v.cantidad) DESC
        ) AS ranking
    FROM LOS_HELECHOS.BI_Hecho_Venta v
    JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
    JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON v.id_sucursal = s.id_sucursal
    JOIN LOS_HELECHOS.BI_Dim_Cliente c ON v.id_cliente = c.id_cliente
    JOIN LOS_HELECHOS.BI_Dim_Sillon si ON v.id_sillon = si.id_sillon
    GROUP BY t.anio, t.cuatrimestre, s.localidad, c.rango_etario, si.modelo
) AS sub
WHERE ranking <= 3;

GO

--
    
CREATE or ALTER VIEW LOS_HELECHOS.BI_View_Volumen_Pedidos AS
SELECT 
    t.anio,
    t.mes,
    p.id_sucursal,
    p.id_turno,
    COUNT(*) AS cantidad_pedidos
FROM LOS_HELECHOS.BI_Hecho_Pedido p
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON p.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.mes, p.id_sucursal, p.id_turno;

GO

--

CREATE OR ALTER VIEW LOS_HELECHOS.BI_View_Conversion_Pedidos AS
SELECT 
    t.anio,
    t.cuatrimestre,
    s.id_sucursal,
    p.estado_pedido,
    COUNT(*) AS cantidad_pedidos,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
        PARTITION BY t.anio, t.cuatrimestre, s.id_sucursal
    ) AS DECIMAL(5,2)) AS porcentaje
FROM LOS_HELECHOS.BI_Hecho_Pedido p
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON p.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON p.id_sucursal = s.id_sucursal
GROUP BY 
    t.anio,
    t.cuatrimestre,
    s.id_sucursal,
    p.estado_pedido;
GO

--

CREATE or alter VIEW LOS_HELECHOS.BI_Vista_Tiempo_Fabricacion AS
SELECT
    tp.anio,
    tp.cuatrimestre,
    s.id_sucursal,
    AVG(DATEDIFF(
        DAY,
        CAST(CONCAT(tp.anio, RIGHT('00' + CAST(tp.mes AS VARCHAR), 2), '01') AS DATE),
        CAST(CONCAT(tv.anio, RIGHT('00' + CAST(tv.mes AS VARCHAR), 2), '01') AS DATE)
    )) AS tiempo_promedio_dias
FROM LOS_HELECHOS.BI_Hecho_Pedido p
JOIN LOS_HELECHOS.BI_Dim_Tiempo tp ON p.id_tiempo = tp.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON p.id_sucursal = s.id_sucursal
JOIN LOS_HELECHOS.BI_Hecho_Venta v
  ON v.id_cliente = p.id_cliente
  AND v.id_sucursal = p.id_sucursal
JOIN LOS_HELECHOS.BI_Dim_Tiempo tv ON v.id_tiempo = tv.id_tiempo
GROUP BY tp.anio, tp.cuatrimestre, s.id_sucursal;
GO

--

CREATE OR ALTER VIEW LOS_HELECHOS.BI_Vista_Promedio_Compras AS
SELECT
    t.anio,
    t.mes,
    s.id_sucursal,
    AVG(c.subtotal) AS promedio_compras
FROM LOS_HELECHOS.BI_Hecho_Compra c
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON c.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON c.id_sucursal = s.id_sucursal
GROUP BY t.anio, t.mes, s.id_sucursal;
GO

--


CREATE OR ALTER VIEW LOS_HELECHOS.BI_Vista_Compras_Tipo_Material AS
SELECT
    t.anio,
    t.cuatrimestre,
    s.id_sucursal,
    c.tipo_material,
    SUM(c.subtotal) AS total_gastado
FROM LOS_HELECHOS.BI_Hecho_Compra c
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON c.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON c.id_sucursal = s.id_sucursal
GROUP BY t.anio, t.cuatrimestre, s.id_sucursal, c.tipo_material;
GO

--


CREATE OR ALTER VIEW LOS_HELECHOS.BI_Vista_Cumplimiento_Envios AS
SELECT
    tp.anio,
    tp.cuatrimestre,
    s.id_sucursal,
    COUNT(CASE WHEN te.id_tiempo <= tp.id_tiempo THEN 1 END) * 100.0 / COUNT(*) AS porcentaje_cumplimiento
FROM LOS_HELECHOS.BI_Hecho_Envio e
JOIN LOS_HELECHOS.BI_Dim_Tiempo tp ON e.id_tiempo_programada = tp.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Tiempo te ON e.id_tiempo_entrega = te.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON e.id_sucursal = s.id_sucursal
GROUP BY tp.anio, tp.cuatrimestre, s.id_sucursal;
GO

--

CREATE OR ALTER VIEW LOS_HELECHOS.BI_Vista_Localidades_Costo_Envio AS
SELECT TOP 5 WITH TIES
    c.localidad,
    SUM(e.total_envio) AS total_envio
FROM LOS_HELECHOS.BI_Hecho_Envio e
JOIN LOS_HELECHOS.BI_Dim_Cliente c ON e.id_cliente = c.id_cliente
GROUP BY c.localidad
ORDER BY SUM(e.total_envio) DESC;


GO
