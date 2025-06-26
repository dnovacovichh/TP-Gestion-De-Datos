USE GD1C2025;

GO

CREATE SCHEMA [LOS_HELECHOS]
GO

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

-- HECHOS

CREATE TABLE LOS_HELECHOS.BI_Hecho_Venta (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT,
    id_sucursal INT,
    id_cliente BIGINT,
    id_sillon BIGINT,
    id_turno INT,
    cantidad BIGINT,
    total_venta DECIMAL(10,2),

    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente),
    FOREIGN KEY (id_sillon) REFERENCES LOS_HELECHOS.BI_Dim_Sillon(id_sillon),
    FOREIGN KEY (id_turno) REFERENCES LOS_HELECHOS.BI_Dim_Turno(id_turno)
);

CREATE TABLE LOS_HELECHOS.BI_Hecho_Compra (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,
    id_tiempo INT,
    id_sucursal INT,
    id_proveedor VARCHAR(20),
    id_material INT,
    tipo_material VARCHAR(50),
    cantidad DECIMAL(18,2),
    precio_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),

    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo)
);

CREATE TABLE LOS_HELECHOS.BI_Hecho_Pedido (
    id_pedido INT PRIMARY KEY,
    id_tiempo INT,
    id_sucursal INT,
    id_cliente BIGINT,
    estado_pedido VARCHAR(50),
    cantidad_items INT,
    total_pedido DECIMAL(10,2),
    id_turno INT,

    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente),
    FOREIGN KEY (id_turno) REFERENCES LOS_HELECHOS.BI_Dim_Turno(id_turno)
);

CREATE TABLE LOS_HELECHOS.BI_Hecho_Envio (
    id_envio INT PRIMARY KEY,
    id_tiempo_programada INT,
    id_tiempo_entrega INT,
    id_sucursal INT,
    id_cliente BIGINT,
    id_factura BIGINT,
    importe_traslado DECIMAL(10,2),
    importe_subida DECIMAL(10,2),
    total_envio DECIMAL(10,2),

    FOREIGN KEY (id_tiempo_programada) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_tiempo_entrega) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente)
);

---
-- ========================================
-- Inserts para tabla BI_Dim_Tiempo
PRINT 'Insertando datos en tabla BI_Dim_Tiempo...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Tiempo (anio, mes, cuatrimestre)
SELECT DISTINCT
    YEAR(fechas.fecha) AS anio,
    MONTH(fechas.fecha) AS mes,
    CEILING(MONTH(fechas.fecha) / 4.0) AS cuatrimestre
FROM (
    SELECT fecha FROM LOS_HELECHOS.Pedido
    UNION
    SELECT fecha FROM LOS_HELECHOS.Compra
    UNION
    SELECT fecha FROM LOS_HELECHOS.Factura
    UNION
    SELECT fecha_programada FROM LOS_HELECHOS.Envio
    UNION
    SELECT fecha_entrega FROM LOS_HELECHOS.Envio
) AS fechas
WHERE fechas.fecha IS NOT NULL;

-- ========================================
-- Inserts para tabla BI_Dim_Sucursal
PRINT 'Insertando datos en tabla BI_Dim_Sucursal...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Sucursal (id_sucursal, localidad, provincia)
SELECT
    s.nro_sucursal,
    l.nombre_localidad,
    p.nombre_prov
FROM LOS_HELECHOS.Sucursal s
JOIN LOS_HELECHOS.Localidad l ON s.localidad = l.cod_localidad
JOIN LOS_HELECHOS.Provincia p ON l.provincia = p.cod_prov;

-- ========================================
-- Inserts para tabla BI_Dim_Cliente
PRINT 'Insertando datos en tabla BI_Dim_Cliente...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Cliente (id_cliente, rango_etario, localidad, provincia)
SELECT
    c.nro_cliente,
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
VALUES 
  (1, '08:00 - 14:00'), 
  (2, '14:00 - 20:00'),
  (3, 'Otro');

-- ========================================
-- Inserts para tabla BI_Dim_Sillon
PRINT 'Insertando datos en tabla BI_Dim_Sillon...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Dim_Sillon (id_sillon, modelo, descripcion, alto, ancho, profundidad)
SELECT
    s.codigo_sillon,
    sm.nombre,
    sm.descripcion,
    m.alto,
    m.ancho,
    m.profundidad
FROM LOS_HELECHOS.Sillon s
JOIN LOS_HELECHOS.Sillon_Modelo sm ON s.codigo_modelo = sm.codigo_modelo
JOIN LOS_HELECHOS.Sillon_Medida m ON s.id_medida = m.id_medida;

-- ========================================
-- Inserts para tabla BI_Hecho_Compra
PRINT 'Insertando datos en tabla BI_Hecho_Compra...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Compra (id_tiempo, id_sucursal, id_proveedor, id_material, tipo_material, cantidad, precio_unitario, subtotal)
SELECT
    t.id_tiempo,
    c.suc_compra,
    c.cuit_proveedor,
    dc.material_comprado,
    CASE 
        WHEN ex.t = 'Tela' THEN 'Tela'
        WHEN ex.t = 'Madera' THEN 'Madera'
        WHEN ex.t = 'Relleno' THEN 'Relleno'
        ELSE 'Otro'
    END,
    dc.cantidad,
    dc.precio,
    dc.subtotal
FROM LOS_HELECHOS.Compra c
JOIN LOS_HELECHOS.Detalle_Compra dc ON c.nro_compra = dc.nro_compra
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON t.anio = YEAR(c.fecha) AND t.mes = MONTH(c.fecha)
LEFT JOIN (
    SELECT id_material, 'Tela' AS t FROM LOS_HELECHOS.Tela
    UNION
    SELECT id_material, 'Madera' FROM LOS_HELECHOS.Madera
    UNION
    SELECT id_material, 'Relleno' FROM LOS_HELECHOS.Relleno
) ex ON dc.material_comprado = ex.id_material;

-- ========================================
-- Inserts para tabla BI_Hecho_Pedido
PRINT 'Insertando datos en tabla BI_Hecho_Pedido...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Pedido (
    id_pedido, id_tiempo, id_sucursal, id_cliente, estado_pedido,
    cantidad_items, total_pedido, id_turno
)
SELECT
    p.nro_pedido,
    t.id_tiempo,
    p.nro_sucursal,
    p.nro_cliente,
    p.estado,
    ISNULL(SUM(dp.cantidad), 0),
    p.total,
    CASE 
        WHEN DATEPART(HOUR, p.fecha) BETWEEN 8 AND 13 THEN 1
        WHEN DATEPART(HOUR, p.fecha) BETWEEN 14 AND 19 THEN 2
        ELSE 3
    END AS id_turno
FROM LOS_HELECHOS.Pedido p
LEFT JOIN LOS_HELECHOS.Detalle_Pedido dp ON p.nro_pedido = dp.nro_pedido
JOIN LOS_HELECHOS.BI_Dim_Tiempo t 
    ON t.anio = YEAR(p.fecha) AND t.mes = MONTH(p.fecha)
GROUP BY 
    p.nro_pedido, t.id_tiempo, p.nro_sucursal, p.nro_cliente, 
    p.estado, p.total, p.fecha;

-- ========================================
-- Inserts para tabla BI_Hecho_Envio
PRINT 'Insertando datos en tabla BI_Hecho_Envio...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Envio (
    id_envio, id_tiempo_programada, id_tiempo_entrega, id_sucursal, id_cliente, id_factura,
    importe_traslado, importe_subida, total_envio
)
SELECT
    e.nro_envio,
    tp.id_tiempo,
    te.id_tiempo,
    f.nro_sucursal,
    f.nro_cliente,
    e.nro_factura,
    e.importe_traslado,
    e.importe_subida,
    e.total
FROM LOS_HELECHOS.Envio e
JOIN LOS_HELECHOS.Factura f ON e.nro_factura = f.nro_factura
JOIN LOS_HELECHOS.BI_Dim_Tiempo tp ON tp.anio = YEAR(e.fecha_programada) AND tp.mes = MONTH(e.fecha_programada)
JOIN LOS_HELECHOS.BI_Dim_Tiempo te ON te.anio = YEAR(e.fecha_entrega) AND te.mes = MONTH(e.fecha_entrega);

-- ========================================
-- Inserts para tabla BI_Hecho_Venta
PRINT 'Insertando datos en tabla BI_Hecho_Venta...';
-- ========================================
INSERT INTO LOS_HELECHOS.BI_Hecho_Venta (
    id_tiempo, id_sucursal, id_cliente, id_sillon, id_turno,
    cantidad, total_venta
)
SELECT
    t.id_tiempo,
    f.nro_sucursal,
    f.nro_cliente,
    s.codigo_sillon,
    -- Turno según hora de la factura
    CASE 
        WHEN DATEPART(HOUR, f.fecha) BETWEEN 8 AND 13 THEN 1
        WHEN DATEPART(HOUR, f.fecha) BETWEEN 14 AND 19 THEN 2
        ELSE 3
    END AS id_turno,
    df.cantidad,
    df.subtotal
FROM LOS_HELECHOS.Factura f
JOIN LOS_HELECHOS.Detalle_Factura df ON f.nro_factura = df.nro_factura
JOIN LOS_HELECHOS.Sillon s ON df.id_sillon = s.codigo_sillon
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON t.anio = YEAR(f.fecha) AND t.mes = MONTH(f.fecha);

--


-- VIEWS

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



--

CREATE OR ALTER VIEW LOS_HELECHOS.BI_View_Factura_Promedio_Mensual AS
SELECT 
    t.anio,
    t.cuatrimestre,
    s.provincia,
    COUNT(DISTINCT v.id_venta) AS cantidad_facturas,
    SUM(v.total_venta) AS total_facturado,
    CASE 
        WHEN COUNT(DISTINCT v.id_venta) = 0 THEN 0
        ELSE SUM(v.total_venta) * 1.0 / COUNT(DISTINCT v.id_venta)
    END AS factura_promedio_mensual
FROM LOS_HELECHOS.BI_Hecho_Venta v
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON v.id_sucursal = s.id_sucursal
GROUP BY t.anio, t.cuatrimestre, s.provincia;

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


CREATE OR ALTER VIEW LOS_HELECHOS.BI_View_Volumen_Pedidos AS
SELECT 
    t.anio,
    t.mes,
    s.id_sucursal,
    tr.descripcion AS turno,
    COUNT(*) AS cantidad_pedidos
FROM LOS_HELECHOS.BI_Hecho_Pedido p
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON p.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON p.id_sucursal = s.id_sucursal
JOIN LOS_HELECHOS.BI_Dim_Turno tr ON p.id_turno = tr.id_turno
GROUP BY t.anio, t.mes, s.id_sucursal, tr.descripcion;
