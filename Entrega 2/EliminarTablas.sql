-- Eliminar FK compuesta si existe
IF OBJECT_ID('los_helechos.Detalle_Factura', 'U') IS NOT NULL
BEGIN
    IF EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE name = 'fk_detallefactura_pedido'
    )
    BEGIN
        ALTER TABLE los_helechos.Detalle_Factura 
        DROP CONSTRAINT fk_detallefactura_pedido;
    END
END

-- Eliminar todas las tablas (si existen)
DROP TABLE IF EXISTS los_helechos.Envio;
DROP TABLE IF EXISTS los_helechos.Detalle_Factura;
DROP TABLE IF EXISTS los_helechos.Factura;
DROP TABLE IF EXISTS los_helechos.CancelacionPedido;
DROP TABLE IF EXISTS los_helechos.Detalle_Pedido;
DROP TABLE IF EXISTS los_helechos.Pedido;
DROP TABLE IF EXISTS los_helechos.Sillon;
DROP TABLE IF EXISTS los_helechos.Detalle_Compra;
DROP TABLE IF EXISTS los_helechos.Compra;
DROP TABLE IF EXISTS los_helechos.Cliente;
DROP TABLE IF EXISTS los_helechos.Sucursal;
DROP TABLE IF EXISTS los_helechos.Proveedor;
DROP TABLE IF EXISTS los_helechos.Localidad;
DROP TABLE IF EXISTS los_helechos.Relleno;
DROP TABLE IF EXISTS los_helechos.Madera;
DROP TABLE IF EXISTS los_helechos.Tela;
DROP TABLE IF EXISTS los_helechos.Sillon_Medida;
DROP TABLE IF EXISTS los_helechos.Sillon_Modelo;
DROP TABLE IF EXISTS los_helechos.Material;
DROP TABLE IF EXISTS los_helechos.Provincia;

-- Eliminar el esquema si existe
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'los_helechos')
BEGIN
    DROP SCHEMA los_helechos;
END
