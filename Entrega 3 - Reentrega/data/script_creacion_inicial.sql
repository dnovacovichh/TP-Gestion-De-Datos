USE GD1C2025;

GO

CREATE SCHEMA [LOS_HELECHOS]
GO

-- CREACI�N DE TABLAS INDEPENDIENTES [gd_esquema].[Maestra]
CREATE TABLE [LOS_HELECHOS].[Provincia] (
    cod_prov INT IDENTITY(1,1) PRIMARY KEY,
    nombre_prov VARCHAR(255)
);

CREATE TABLE [LOS_HELECHOS].[Material] (
    id_material INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255),
    precio DECIMAL(10,2)
);

CREATE TABLE [LOS_HELECHOS].[Sillon_Modelo] (
    codigo_modelo BIGINT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    precio_base DECIMAL(10,2)
);

CREATE TABLE [LOS_HELECHOS].[Sillon_Medida] (
    id_medida BIGINT IDENTITY(1,1) PRIMARY KEY,
    alto DECIMAL(6,2),
    ancho DECIMAL(6,2),
    profundidad DECIMAL(6,2),
    precio_medida DECIMAL
);

-- SUBTIPOS DE MATERIAL
CREATE TABLE [LOS_HELECHOS].[Tela] (
    id_tela INT IDENTITY(1,1) PRIMARY KEY,
    id_material INT,
    color VARCHAR(255),
    textura VARCHAR(255),
    FOREIGN KEY (id_material) REFERENCES [LOS_HELECHOS].[Material](id_material)
);

CREATE TABLE [LOS_HELECHOS].[Madera] (
    id_madera INT IDENTITY(1,1)  PRIMARY KEY,
    id_material INT,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    color VARCHAR(255),
    dureza VARCHAR(255),
    FOREIGN KEY (id_material) REFERENCES [LOS_HELECHOS].[Material](id_material)
);

CREATE TABLE [LOS_HELECHOS].[Relleno] (
    id_relleno INT IDENTITY(1,1)  PRIMARY KEY,
    id_material INT,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    densidad DECIMAL(38,2),
    FOREIGN KEY (id_material) REFERENCES [LOS_HELECHOS].[Material](id_material)
);

-- LOCALES Y CLIENTES
CREATE TABLE [LOS_HELECHOS].[Localidad] (
    cod_localidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_localidad VARCHAR(255),
    provincia INT,
    FOREIGN KEY (provincia) REFERENCES [LOS_HELECHOS].[Provincia](cod_prov)
);

CREATE TABLE [LOS_HELECHOS].[Proveedor] (
    cuit VARCHAR(20) PRIMARY KEY,
    razon_social VARCHAR(255),
    localidad INT,
    direccion VARCHAR(255),
    telefono VARCHAR(255),
    mail VARCHAR(255),
    FOREIGN KEY (localidad) REFERENCES [LOS_HELECHOS].[Localidad](cod_localidad)
);

CREATE TABLE [LOS_HELECHOS].[Sucursal] (
    nro_sucursal INT PRIMARY KEY, -- clave natural
    localidad INT,
    direccion VARCHAR(255),
    telefono VARCHAR(255),
    mail VARCHAR(255),
    FOREIGN KEY (localidad) REFERENCES [LOS_HELECHOS].[Localidad](cod_localidad)
);

CREATE TABLE [LOS_HELECHOS].[Cliente] (
    nro_cliente BIGINT IDENTITY(1,1) PRIMARY KEY,
    dni BIGINT,
    localidad INT,
    nombre VARCHAR(255),
    apellido VARCHAR(255),
    fecha_nacimiento DATETIME,
    mail VARCHAR(255),
    direccion VARCHAR(255),
    telefono VARCHAR(255),
    FOREIGN KEY (localidad) REFERENCES [LOS_HELECHOS].[Localidad](cod_localidad)
);

-- COMPRAS
CREATE TABLE [LOS_HELECHOS].[Compra] (
    nro_compra INT PRIMARY KEY,
    suc_compra INT,
    fecha DATETIME,
    total DECIMAL(10,2),
    cuit_proveedor VARCHAR(20),
    FOREIGN KEY (suc_compra) REFERENCES [LOS_HELECHOS].[Sucursal](nro_sucursal),
    FOREIGN KEY (cuit_proveedor) REFERENCES [LOS_HELECHOS].[Proveedor](cuit)
);

CREATE TABLE [LOS_HELECHOS].[Detalle_Compra] (
    nro_compra INT,
    material_comprado INT,
    cantidad DECIMAL,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    PRIMARY KEY (nro_compra, material_comprado),
    FOREIGN KEY (nro_compra) REFERENCES [LOS_HELECHOS].[Compra](nro_compra),
    FOREIGN KEY (material_comprado) REFERENCES [LOS_HELECHOS].[Material](id_material)
);

-- SILLONES
CREATE TABLE [LOS_HELECHOS].[Sillon] (
    codigo_sillon BIGINT UNIQUE,
    codigo_modelo BIGINT NOT NULL,
    id_medida BIGINT NOT NULL,
    id_tela INT NOT NULL,
    id_madera INT NOT NULL,
    id_relleno INT NOT NULL,
    FOREIGN KEY (codigo_modelo) REFERENCES [LOS_HELECHOS].[Sillon_Modelo](codigo_modelo),
    FOREIGN KEY (id_medida) REFERENCES [LOS_HELECHOS].[Sillon_Medida](id_medida),
    FOREIGN KEY (id_tela) REFERENCES [LOS_HELECHOS].[Tela](id_tela),
    FOREIGN KEY (id_madera) REFERENCES [LOS_HELECHOS].[Madera](id_madera),
    FOREIGN KEY (id_relleno) REFERENCES [LOS_HELECHOS].[Relleno](id_relleno)
);

-- PEDIDOS
CREATE TABLE [LOS_HELECHOS].[Pedido] (
    nro_pedido INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME,
    estado VARCHAR(50),
    total DECIMAL(10,2),
    nro_cliente BIGINT,
    nro_sucursal INT,
    FOREIGN KEY (nro_cliente) REFERENCES [LOS_HELECHOS].[Cliente](nro_cliente),
    FOREIGN KEY (nro_sucursal) REFERENCES [LOS_HELECHOS].[Sucursal](nro_sucursal)
);

CREATE TABLE [LOS_HELECHOS].[Detalle_Pedido] (
    nro_pedido INT,
    id_sillon BIGINT,
    cantidad BIGINT,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    PRIMARY KEY (nro_pedido, id_sillon),
    FOREIGN KEY (nro_pedido) REFERENCES [LOS_HELECHOS].[Pedido](nro_pedido),
    FOREIGN KEY (id_sillon) REFERENCES [LOS_HELECHOS].[Sillon](codigo_sillon)
);

CREATE TABLE [LOS_HELECHOS].[CancelacionPedido] (
    nro_pedido INT IDENTITY(1,1) PRIMARY KEY,
    fecha_cancelacion DATETIME,
    motivo_cancelacion VARCHAR(255),
    FOREIGN KEY (nro_pedido) REFERENCES [LOS_HELECHOS].[Pedido](nro_pedido)
);

-- FACTURACI�N
CREATE TABLE [LOS_HELECHOS].[Factura] (
    nro_factura BIGINT IDENTITY(1,1) PRIMARY KEY,
    nro_sucursal INT,
    nro_cliente BIGINT,
    fecha DATETIME,
    total DECIMAL(10,2),
    FOREIGN KEY (nro_sucursal) REFERENCES [LOS_HELECHOS].[Sucursal](nro_sucursal),
    FOREIGN KEY (nro_cliente) REFERENCES [LOS_HELECHOS].[Cliente](nro_cliente)
);



CREATE TABLE [LOS_HELECHOS].[Detalle_Factura] (
    nro_factura BIGINT,
    nro_pedido INT,
    id_sillon BIGINT,
    cantidad DECIMAL,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    PRIMARY KEY (nro_factura, nro_pedido, id_sillon),
    FOREIGN KEY (nro_factura) REFERENCES [LOS_HELECHOS].[Factura](nro_factura)
    -- FK compuesta a Detalle_Pedido se declara aparte
);

-- ENV�OS
CREATE TABLE [LOS_HELECHOS].[Envio] (
    nro_envio INT PRIMARY KEY,
    nro_factura BIGINT,
    fecha_programada DATETIME,
    fecha_entrega DATETIME,
    importe_traslado DECIMAL(10,2),
    importe_subida DECIMAL(10,2),
    total DECIMAL(10,2),
    FOREIGN KEY (nro_factura) REFERENCES [LOS_HELECHOS].[Factura](nro_factura)
);

-- FK compuesta manual a Detalle_Pedido
ALTER TABLE [LOS_HELECHOS].[Detalle_Factura]
ADD CONSTRAINT fk_detallefactura_pedido
FOREIGN KEY (nro_pedido, id_sillon)
REFERENCES [LOS_HELECHOS].[Detalle_Pedido](nro_pedido, id_sillon);


-- ========================================
-- Inserts para tabla Provincia
PRINT 'Insertando datos en tabla Provincia...';
-- ========================================

INSERT INTO LOS_HELECHOS.Provincia(nombre_prov)
SELECT *
FROM (
    SELECT Sucursal_Provincia AS p FROM gd_esquema.Maestra
    UNION
    SELECT Cliente_Provincia FROM gd_esquema.Maestra
    UNION
    SELECT Proveedor_Provincia FROM gd_esquema.Maestra
) AS todas
WHERE p is not null;

-- ========================================
-- Inserts para tabla Localidad
-- Detalles: Se realiza un UNION entre todas las columnas que referencian localidades
PRINT 'Insertando datos en tabla Localidad...';
-- ========================================}

INSERT INTO LOS_HELECHOS.Localidad (nombre_localidad, provincia)
SELECT DISTINCT loc, p.cod_prov
FROM (
    SELECT Sucursal_Localidad AS loc, Sucursal_Provincia AS prov
    FROM gd_esquema.Maestra
    UNION
    SELECT Cliente_Localidad, Cliente_Provincia
    FROM gd_esquema.Maestra
    UNION
    SELECT Proveedor_Localidad, Proveedor_Provincia
    FROM gd_esquema.Maestra
) AS all_loc
JOIN LOS_HELECHOS.Provincia p ON all_loc.prov = p.nombre_prov
WHERE loc IS NOT NULL;

-- ========================================
-- Inserts para tabla Sucursal
PRINT 'Insertando datos en tabla Sucursal...';

-- ========================================
INSERT INTO LOS_HELECHOS.Sucursal (localidad, nro_sucursal, direccion, telefono, mail)
SELECT DISTINCT 
    l.cod_localidad,
    Sucursal_NroSucursal,
    Sucursal_Direccion,
    Sucursal_Telefono,
    Sucursal_Mail
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Provincia p ON tm.sucursal_provincia = p.nombre_prov
JOIN LOS_HELECHOS.Localidad l ON tm.sucursal_localidad = l.nombre_localidad AND l.provincia = p.cod_prov

-- ========================================
-- Inserts para tabla Cliente
-- Detalles: Los clientes estan duplicados por eso utilizaci�n una partici�n y row_number
PRINT 'Insertando datos en tabla Cliente...';
-- ========================================
WITH ClientesUnicos AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Cliente_Dni 
               ORDER BY Cliente_FechaNacimiento DESC
           ) AS rn
    FROM gd_esquema.Maestra
    WHERE Cliente_Dni IS NOT NULL
)
INSERT INTO LOS_HELECHOS.Cliente (dni, localidad, nombre, apellido, fecha_nacimiento, mail, direccion, telefono)
SELECT
    Cliente_Dni,
    l.cod_localidad,
    Cliente_Nombre,
    Cliente_Apellido,
    Cliente_FechaNacimiento,
    Cliente_Mail,
    Cliente_Direccion,
    Cliente_Telefono
FROM ClientesUnicos tm
JOIN LOS_HELECHOS.Provincia p ON tm.Cliente_Provincia = p.nombre_prov
JOIN LOS_HELECHOS.Localidad l ON tm.Cliente_Localidad = l.nombre_localidad AND l.provincia = p.cod_prov
WHERE rn = 1;

-- ========================================
-- Inserts para tabla Proveedor
PRINT 'Insertando datos en tabla Proveedor...';
-- ========================================

INSERT INTO LOS_HELECHOS.Proveedor (cuit, razon_social, localidad, direccion, telefono, mail)
SELECT DISTINCT
    Proveedor_Cuit,
    Proveedor_RazonSocial,
    l.cod_localidad,
    Proveedor_Direccion,
    Proveedor_Telefono,
    Proveedor_Mail
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Provincia p ON tm.Proveedor_Provincia = p.nombre_prov
JOIN LOS_HELECHOS.Localidad l ON tm.Proveedor_Localidad = l.nombre_localidad AND l.provincia = p.cod_prov;

-- ========================================
-- Inserts para tabla Material
PRINT 'Insertando datos en tabla Material...';
-- ========================================
INSERT INTO LOS_HELECHOS.Material (nombre, precio)
SELECT DISTINCT 
    Material_Nombre,
    Material_Precio
FROM gd_esquema.Maestra
WHERE Material_nombre is not null;

-- ========================================
-- Inserts para tabla Tela (solo tipo 'Tela')
PRINT 'Insertando datos en tabla Tela...';
-- ========================================
INSERT INTO LOS_HELECHOS.Tela (id_material, color, textura)
SELECT DISTINCT 
    m.id_material,
    tm.Tela_Color,
    tm.Tela_Textura
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Material m ON tm.Material_Nombre = m.nombre
WHERE tm.Material_Tipo = 'Tela' AND tm.Tela_Color IS NOT NULL;

-- ========================================
-- Inserts para tabla Madera (solo tipo 'Madera')
PRINT 'Insertando datos en tabla Madera...';
-- ========================================
INSERT INTO LOS_HELECHOS.Madera (id_material, nombre, descripcion, color, dureza)
SELECT DISTINCT 
    m.id_material,
    tm.Material_Nombre,
    tm.Material_Descripcion,
    tm.Madera_Color,
    tm.Madera_Dureza
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Material m ON tm.Material_Nombre = m.nombre
WHERE tm.Material_Tipo = 'Madera' AND tm.Madera_Color IS NOT NULL;

-- ========================================
-- Inserts para tabla Relleno (solo tipo 'Relleno')
PRINT 'Insertando datos en tabla Relleno...';
-- ========================================
INSERT INTO LOS_HELECHOS.Relleno (id_material, nombre, descripcion, densidad)
SELECT DISTINCT 
    m.id_material,
    tm.Material_Nombre,
    tm.Material_Descripcion,
    tm.Relleno_Densidad
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Material m ON tm.Material_Nombre = m.nombre
WHERE tm.Material_Tipo = 'Relleno' AND tm.Relleno_Densidad IS NOT NULL;



-- ========================================
-- Inserts para tabla Sillon_Modelo
PRINT 'Insertando datos en tabla Sillon_Modelo...';
-- ========================================
SET IDENTITY_INSERT LOS_HELECHOS.Sillon_Modelo ON;

INSERT INTO LOS_HELECHOS.Sillon_Modelo (codigo_modelo, nombre, descripcion, precio_base)
SELECT DISTINCT 
    Sillon_Modelo_Codigo,
    Sillon_Modelo,
    Sillon_Modelo_Descripcion,
    Sillon_Modelo_Precio
FROM gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo is not null;

SET IDENTITY_INSERT LOS_HELECHOS.Sillon_Modelo OFF;
-- ========================================
-- Inserts para tabla Sillon_Medida
PRINT 'Insertando datos en tabla Sillon_Medida...';
-- ========================================
INSERT INTO LOS_HELECHOS.Sillon_Medida (alto, ancho, profundidad, precio_medida)
SELECT DISTINCT
    Sillon_Medida_Alto,
    Sillon_Medida_Ancho,
    Sillon_Medida_Profundidad,
    Sillon_Medida_Precio
FROM gd_esquema.Maestra
WHERE Sillon_Medida_Alto IS NOT NULL;

-- ========================================
-- Inserts para tabla Sillon
PRINT 'Insertando datos en tabla Sillon...';
-- ========================================
WITH base_sillon AS (
    SELECT DISTINCT
        ma.Sillon_Codigo,
        ma.Sillon_Modelo,
        ma.Sillon_Modelo_Descripcion,
        ma.Sillon_Medida_Alto,
        ma.Sillon_Medida_Ancho,
        ma.Sillon_Medida_Profundidad
    FROM gd_esquema.Maestra ma
    WHERE ma.Material_Tipo = 'Tela'
),
madera_sillon AS (
    SELECT Sillon_Codigo, Material_Descripcion
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Sillon_Codigo ORDER BY Material_Descripcion) AS rn
        FROM gd_esquema.Maestra
        WHERE Material_Tipo = 'Madera'
    ) m
    WHERE rn = 1
),
relleno_sillon AS (
    SELECT Sillon_Codigo, Material_Descripcion
    FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Sillon_Codigo ORDER BY Material_Descripcion) AS rn
        FROM gd_esquema.Maestra
        WHERE Material_Tipo = 'Relleno'
    ) r
    WHERE rn = 1
)

INSERT INTO LOS_HELECHOS.Sillon (
    codigo_sillon,
    codigo_modelo,
    id_medida,
    id_tela,
    id_madera,
    id_relleno
)
SELECT
    b.Sillon_Codigo,
    sm.codigo_modelo,
    med.id_medida,
    t.id_tela,
    m.id_madera,
    r.id_relleno
FROM base_sillon b
JOIN LOS_HELECHOS.Sillon_Modelo sm 
  ON sm.nombre = b.Sillon_Modelo AND sm.descripcion = b.Sillon_Modelo_Descripcion
JOIN LOS_HELECHOS.Sillon_Medida med 
  ON med.alto = b.Sillon_Medida_Alto AND med.ancho = b.Sillon_Medida_Ancho AND med.profundidad = b.Sillon_Medida_Profundidad

-- Tela: por color + textura
LEFT JOIN (
    SELECT DISTINCT Sillon_Codigo, Tela_Color, Tela_Textura
    FROM gd_esquema.Maestra
    WHERE Material_Tipo = 'Tela'
) ts ON ts.Sillon_Codigo = b.Sillon_Codigo
LEFT JOIN LOS_HELECHOS.Tela t 
  ON t.color = ts.Tela_Color AND t.textura = ts.Tela_Textura

-- Madera: por descripción
LEFT JOIN madera_sillon ms ON ms.Sillon_Codigo = b.Sillon_Codigo
LEFT JOIN LOS_HELECHOS.Madera m ON m.descripcion = ms.Material_Descripcion

-- Relleno: por descripción
LEFT JOIN relleno_sillon rs ON rs.Sillon_Codigo = b.Sillon_Codigo
LEFT JOIN LOS_HELECHOS.Relleno r ON r.descripcion = rs.Material_Descripcion

ORDER BY b.Sillon_Codigo;

-- ========================================
-- Inserts para tabla Pedido
PRINT 'Insertando datos en tabla Pedido...';
-- ========================================
SET IDENTITY_INSERT LOS_HELECHOS.Pedido ON;

INSERT INTO LOS_HELECHOS.Pedido (nro_pedido, fecha, estado, total, nro_cliente, nro_sucursal)
SELECT DISTINCT 
    Pedido_Numero,
    Pedido_Fecha,
    Pedido_Estado,
    Pedido_Total,
    c.nro_cliente,
    s.nro_sucursal
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Cliente c ON tm.Cliente_Dni = c.dni
JOIN LOS_HELECHOS.Sucursal s ON tm.Sucursal_NroSucursal = s.nro_sucursal
WHERE Pedido_Numero is not null;

SET IDENTITY_INSERT LOS_HELECHOS.Pedido OFF;

-- ========================================
-- Inserts para tabla Detalle_Pedido
PRINT 'Insertando datos en tabla Detalle_Pedido...';
-- ========================================
INSERT INTO LOS_HELECHOS.Detalle_Pedido (nro_pedido, id_sillon, cantidad, precio, subtotal)
SELECT DISTINCT 
    Pedido_Numero,
    s.codigo_sillon,
    Detalle_Pedido_Cantidad,
    Detalle_Pedido_Precio,
    Detalle_Pedido_SubTotal
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Sillon s ON tm.Sillon_Codigo = s.codigo_sillon;

-- ========================================
-- Inserts para tabla CancelacionPedido
PRINT 'Insertando datos en tabla CancelacionPedido...';
-- ========================================
SET IDENTITY_INSERT LOS_HELECHOS.CancelacionPedido ON;

INSERT INTO LOS_HELECHOS.CancelacionPedido (nro_pedido, fecha_cancelacion, motivo_cancelacion)
SELECT DISTINCT 
    Pedido_Numero,
    Pedido_Cancelacion_Fecha,
    Pedido_Cancelacion_Motivo
FROM gd_esquema.Maestra
WHERE Pedido_Cancelacion_Fecha IS NOT NULL;


SET IDENTITY_INSERT LOS_HELECHOS.CancelacionPedido OFF;
-- ========================================
-- Inserts para tabla Factura
PRINT 'Insertando datos en tabla Factura...';
-- ========================================
SET IDENTITY_INSERT LOS_HELECHOS.Factura ON;

INSERT INTO LOS_HELECHOS.Factura (nro_factura, nro_sucursal, nro_cliente, fecha, total)
SELECT DISTINCT 
    Factura_Numero,
    s.nro_sucursal,
    c.nro_cliente,
    Factura_Fecha,
    Factura_Total
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Cliente c ON tm.Cliente_Dni = c.dni
JOIN LOS_HELECHOS.Sucursal s ON tm.Sucursal_NroSucursal = s.nro_sucursal
WHERE Factura_Numero is not null;

SET IDENTITY_INSERT LOS_HELECHOS.Factura OFF;



---========================================
-- Inserts para tabla Detalle_Factura
PRINT 'Insertando datos en tabla Detalle_Factura...';
-- ========================================

INSERT INTO LOS_HELECHOS.Detalle_Factura (
    nro_factura, nro_pedido, id_sillon, cantidad, precio, subtotal
)
SELECT 
    f.nro_factura,
    dp.nro_pedido,
    dp.id_sillon,
    dp.cantidad,
    dp.precio,
    dp.subtotal
FROM LOS_HELECHOS.Factura f
JOIN LOS_HELECHOS.Pedido p ON p.nro_cliente = f.nro_cliente -- o cualquier relación válida entre Pedido y Factura
JOIN LOS_HELECHOS.Detalle_Pedido dp ON dp.nro_pedido = p.nro_pedido;


-- ========================================
-- Inserts para tabla Envio
PRINT 'Insertando datos en tabla Envio...';
-- ========================================

INSERT INTO LOS_HELECHOS.Envio (nro_envio, nro_factura, fecha_programada, fecha_entrega, importe_traslado, importe_subida, total)
SELECT DISTINCT 
    Envio_Numero,
    Factura_Numero,
    Envio_Fecha_Programada,
    Envio_Fecha,
    Envio_ImporteTraslado,
    Envio_ImporteSubida,
    Envio_Total
FROM gd_esquema.Maestra
where envio_Numero is not null;

-- ========================================
-- Inserts para tabla Compra
PRINT 'Insertando datos en tabla Compra...';
-- ========================================

INSERT INTO LOS_HELECHOS.Compra (nro_compra, suc_compra, fecha, total, cuit_proveedor)
SELECT DISTINCT 
    Compra_Numero,
    s.nro_sucursal,
    Compra_Fecha,
    Compra_Total,
    Proveedor_Cuit
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Sucursal s ON tm.Sucursal_NroSucursal = s.nro_sucursal
 where Compra_Numero is not null;

-- ========================================
-- Inserts para tabla Detalle_Compra
PRINT 'Insertando datos en tabla Detalle_Compra...';
-- ========================================
INSERT INTO LOS_HELECHOS.Detalle_Compra (nro_compra, material_comprado, cantidad, precio, subtotal)
SELECT DISTINCT 
    Compra_Numero,
    m.id_material,
    Detalle_Compra_Cantidad,
    Detalle_Compra_Precio,
    Detalle_Compra_SubTotal
FROM gd_esquema.Maestra tm
JOIN LOS_HELECHOS.Material m ON tm.Material_Nombre = m.nombre
where Compra_Numero is not null;

-- Normalizaci�n Provincia
PRINT 'Normalizando provincia...';
UPDATE LOS_HELECHOS.Provincia SET nombre_prov = 'Santiago del Estero' WHERE nombre_prov = 'Santia; Del Estero';
UPDATE LOS_HELECHOS.Provincia SET nombre_prov = 'Tierra del Fuego' WHERE nombre_prov = 'Tierra Del Fue;';
