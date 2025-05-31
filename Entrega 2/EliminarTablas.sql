-- Eliminar primero constraints de FKs compuestas si fuera necesario
ALTER TABLE Detalle_Factura DROP CONSTRAINT fk_detallefactura_pedido;

-- Eliminar tablas dependientes
DROP TABLE IF EXISTS Envio;
DROP TABLE IF EXISTS Detalle_Factura;
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS CancelacionPedido;
DROP TABLE IF EXISTS Detalle_Pedido;
DROP TABLE IF EXISTS Pedido;
DROP TABLE IF EXISTS Sillon;
DROP TABLE IF EXISTS Detalle_Compra;
DROP TABLE IF EXISTS Compra;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Sucursal;
DROP TABLE IF EXISTS Proveedor;
DROP TABLE IF EXISTS Localidad;
DROP TABLE IF EXISTS Relleno;
DROP TABLE IF EXISTS Madera;
DROP TABLE IF EXISTS Tela;
DROP TABLE IF EXISTS Sillon_Medida;
DROP TABLE IF EXISTS Sillon_Modelo;
DROP TABLE IF EXISTS Material;
DROP TABLE IF EXISTS Provincia;
