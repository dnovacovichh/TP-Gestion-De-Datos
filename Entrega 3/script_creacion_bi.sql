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

    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente)
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
