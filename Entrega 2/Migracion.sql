-- ========================================
USE GD1C2025;
GO

-- ========================================
-- Inserts para tabla Provincia
-- ========================================
INSERT INTO Provincia (nombre_prov)
SELECT DISTINCT Sucursal_Provincia
FROM gd_esquema.Maestra;

-- ========================================
-- Inserts para tabla Localidad
-- ========================================
INSERT INTO Localidad (nombre_localidad, provincia)
SELECT DISTINCT 
    Sucursal_Localidad,
    p.cod_prov
FROM gd_esquema.Maestra tm
JOIN Provincia p ON tm.Sucursal_Provincia = p.nombre_prov;

-- ========================================
-- Inserts para tabla Sucursal
-- ========================================
INSERT INTO Sucursal (localidad, nro_sucursal, direccion, telefono, mail)
SELECT DISTINCT 
    l.cod_localidad,
    Sucursal_NroSucursal,
    Sucursal_Direccion,
    Sucursal_Telefono,
    Sucursal_Mail
FROM gd_esquema.Maestra tm
JOIN Localidad l ON tm.Sucursal_Localidad = l.nombre_localidad;



-- ========================================
-- Inserts para tabla Cliente
-- ========================================
INSERT INTO Cliente (nro_cliente, dni, localidad, nombre, apellido, fecha_nacimiento, mail, direccion, telefono)
SELECT DISTINCT 
    ROW_NUMBER() OVER (ORDER BY Cliente_Dni) AS nro_cliente,
    Cliente_Dni,
    l.cod_localidad,
    Cliente_Nombre,
    Cliente_Apellido,
    Cliente_FechaNacimiento,
    Cliente_Mail,
    Cliente_Direccion,
    Cliente_Telefono
FROM gd_esquema.Maestra tm
JOIN Localidad l ON tm.Cliente_Localidad = l.nombre_localidad;

-- ========================================
-- Inserts para tabla Proveedor
-- ========================================
INSERT INTO Proveedor (cuit, razon_social, localidad, direccion, telefono, mail)
SELECT DISTINCT
    Proveedor_Cuit,
    Proveedor_RazonSocial,
    l.cod_localidad,
    Proveedor_Direccion,
    Proveedor_Telefono,
    Proveedor_Mail
FROM gd_esquema.Maestra tm
JOIN Localidad l ON tm.Proveedor_Localidad = l.nombre_localidad;

-- ========================================
-- Inserts para tabla Material
-- ========================================
INSERT INTO Material (nombre, precio)
SELECT DISTINCT 
    Material_Nombre,
    Material_Precio
FROM gd_esquema.Maestra;

-- ========================================
-- Inserts para tabla Tela (solo tipo 'Tela')
-- ========================================
INSERT INTO Tela (id_material, color, textura)
SELECT DISTINCT 
    m.id_material,
    tm.Tela_Color,
    tm.Tela_Textura
FROM gd_esquema.Maestra tm
JOIN Material m ON tm.Material_Nombre = m.nombre
WHERE tm.Material_Tipo = 'Tela' AND tm.Tela_Color IS NOT NULL;

-- ========================================
-- Inserts para tabla Madera (solo tipo 'Madera')
-- ========================================
INSERT INTO Madera (id_material, nombre, descripcion, color, dureza)
SELECT DISTINCT 
    m.id_material,
    tm.Material_Nombre,
    tm.Material_Descripcion,
    tm.Madera_Color,
    tm.Madera_Dureza
FROM gd_esquema.Maestra tm
JOIN Material m ON tm.Material_Nombre = m.nombre
WHERE tm.Material_Tipo = 'Madera' AND tm.Madera_Color IS NOT NULL;

-- ========================================
-- Inserts para tabla Relleno (solo tipo 'Relleno')
-- ========================================
INSERT INTO Relleno (id_material, nombre, descripcion, densidad)
SELECT DISTINCT 
    m.id_material,
    tm.Material_Nombre,
    tm.Material_Descripcion,
    tm.Relleno_Densidad
FROM gd_esquema.Maestra tm
JOIN Material m ON tm.Material_Nombre = m.nombre
WHERE tm.Material_Tipo = 'Relleno' AND tm.Relleno_Densidad IS NOT NULL;


/**
-- ========================================
-- Inserts para tabla Sillon_Modelo
-- ========================================
INSERT INTO Sillon_Modelo (codigo_modelo, nombre, descripcion, precio_base)
SELECT DISTINCT 
    Sillon_Modelo_Codigo,
    Sillon_Modelo,
    Sillon_Modelo_Descripcion,
    Sillon_Modelo_Precio
FROM gd_esquema.Maestra;

-- ========================================
-- Inserts para tabla Sillon_Medida
-- ========================================
INSERT INTO Sillon_Medida (id_medida, alto, ancho, profundidad, precio_medida)
SELECT DISTINCT 
    ROW_NUMBER() OVER (ORDER BY Sillon_Medida_Alto) AS id_medida,
    Sillon_Medida_Alto,
    Sillon_Medida_Ancho,
    Sillon_Medida_Profundidad,
    Sillon_Medida_Precio
FROM gd_esquema.Maestra;

-- ========================================
-- Inserts para tabla Sillon
-- ========================================
INSERT INTO Sillon (id_sillon, codigo_modelo, id_medida, id_material)
SELECT DISTINCT 
    Sillon_Codigo,
    Sillon_Modelo_Codigo,
    sm.id_medida,
    m.id_material
FROM gd_esquema.Maestra tm
JOIN Sillon_Medida sm ON tm.Sillon_Medida_Alto = sm.alto AND tm.Sillon_Medida_Ancho = sm.ancho AND tm.Sillon_Medida_Profundidad = sm.profundidad
JOIN Material m ON tm.Material_Nombre = m.nombre;

-- ========================================
-- Inserts para tabla Pedido
-- ========================================
INSERT INTO Pedido (nro_pedido, fecha, estado, total, nro_cliente, id_sucursal)
SELECT DISTINCT 
    Pedido_Numero,
    Pedido_Fecha,
    Pedido_Estado,
    Pedido_Total,
    c.nro_cliente,
    s.id_sucursal
FROM gd_esquema.Maestra tm
JOIN Cliente c ON tm.Cliente_Dni = c.dni
JOIN Sucursal s ON tm.Sucursal_NroSucursal = s.nro_sucursal;

-- ========================================
-- Inserts para tabla Detalle_Pedido
-- ========================================
INSERT INTO Detalle_Pedido (nro_pedido, id_sillon, cantidad, precio, subtotal)
SELECT DISTINCT 
    Pedido_Numero,
    s.id_sillon,
    Detalle_Pedido_Cantidad,
    Detalle_Pedido_Precio,
    Detalle_Pedido_SubTotal
FROM gd_esquema.Maestra tm
JOIN Sillon s ON tm.Sillon_Codigo = s.id_sillon;

-- ========================================
-- Inserts para tabla CancelacionPedido
-- ========================================
INSERT INTO CancelacionPedido (nro_pedido, fecha_cancelacion, motivo_cancelacion)
SELECT DISTINCT 
    Pedido_Numero,
    Pedido_Cancelacion_Fecha,
    Pedido_Cancelacion_Motivo
FROM gd_esquema.Maestra
WHERE Pedido_Cancelacion_Fecha IS NOT NULL;

-- ========================================
-- Inserts para tabla Factura
-- ========================================
INSERT INTO Factura (nro_factura, id_sucursal, nro_cliente, fecha, total)
SELECT DISTINCT 
    Factura_Numero,
    s.id_sucursal,
    c.nro_cliente,
    Factura_Fecha,
    Factura_Total
FROM gd_esquema.Maestra tm
JOIN Cliente c ON tm.Cliente_Dni = c.dni
JOIN Sucursal s ON tm.Sucursal_NroSucursal = s.nro_sucursal;

-- ========================================
-- Inserts para tabla Detalle_Factura
-- ========================================
INSERT INTO Detalle_Factura (nro_factura, nro_pedido, cantidad, precio, subtotal)
SELECT DISTINCT 
    Factura_Numero,
    Pedido_Numero,
    Detalle_Factura_Cantidad,
    Detalle_Factura_Precio,
    Detalle_Factura_SubTotal
FROM gd_esquema.Maestra;

-- ========================================
-- Inserts para tabla Envio
-- ========================================
INSERT INTO Envio (nro_envio, nro_factura, fecha_programada, fecha_entrega, importe_traslado, importe_subida, total)
SELECT DISTINCT 
    Envio_Numero,
    Factura_Numero,
    Envio_Fecha_Programada,
    Envio_Fecha,
    Envio_ImporteTraslado,
    Envio_ImporteSubida,
    Envio_Total
FROM gd_esquema.Maestra;

-- ========================================
-- Inserts para tabla Compra
-- ========================================
INSERT INTO Compra (nro_compra, suc_compra, fecha, total, cuit_proveedor)
SELECT DISTINCT 
    Compra_Numero,
    s.id_sucursal,
    Compra_Fecha,
    Compra_Total,
    Proveedor_Cuit
FROM gd_esquema.Maestra tm
JOIN Sucursal s ON tm.Sucursal_NroSucursal = s.nro_sucursal;

-- ========================================
-- Inserts para tabla Detalle_Compra
-- ========================================
INSERT INTO Detalle_Compra (nro_compra, material_comprado, cantidad, precio, subtotal)
SELECT DISTINCT 
    Compra_Numero,
    m.id_material,
    Detalle_Compra_Cantidad,
    Detalle_Compra_Precio,
    Detalle_Compra_SubTotal
FROM gd_esquema.Maestra tm
JOIN Material m ON tm.Material_Nombre = m.nombre;


**/