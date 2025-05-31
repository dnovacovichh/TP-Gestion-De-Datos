
USE GD1C2025;
GO

-- CREACIÓN DE TABLAS INDEPENDIENTES
CREATE TABLE Provincia (
    cod_prov INT IDENTITY(1,1) PRIMARY KEY,
    nombre_prov VARCHAR(255)
);

CREATE TABLE Material (
    id_material INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255),
    precio DECIMAL(10,2)
);

CREATE TABLE Sillon_Modelo (
    codigo_modelo BIGINT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    precio_base DECIMAL(10,2)
);

CREATE TABLE Sillon_Medida (
    id_medida BIGINT IDENTITY(1,1) PRIMARY KEY,
    alto DECIMAL(6,2),
    ancho DECIMAL(6,2),
    profundidad DECIMAL(6,2),
    precio_medida DECIMAL
);

-- SUBTIPOS DE MATERIAL
CREATE TABLE Tela (
    id_tela INT PRIMARY KEY,
    id_material INT UNIQUE,
    color VARCHAR(255),
    textura VARCHAR(255),
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

CREATE TABLE Madera (
    id_madera INT PRIMARY KEY,
    id_material INT UNIQUE,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    color VARCHAR(255),
    dureza VARCHAR(255),
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

CREATE TABLE Relleno (
    id_relleno INT PRIMARY KEY,
    id_material INT UNIQUE,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    densidad DECIMAL,
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

-- LOCALES Y CLIENTES
CREATE TABLE Localidad (
    cod_localidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_localidad VARCHAR(255),
    provincia INT,
    FOREIGN KEY (provincia) REFERENCES Provincia(cod_prov)
);

CREATE TABLE Proveedor (
    cuit VARCHAR(20) PRIMARY KEY,
    razon_social VARCHAR(255),
    localidad INT,
    direccion VARCHAR(255),
    telefono VARCHAR(255),
    mail VARCHAR(255),
    FOREIGN KEY (localidad) REFERENCES Localidad(cod_localidad)
);

CREATE TABLE Sucursal (
    id_sucursal INT IDENTITY(1,1) PRIMARY KEY,
    localidad INT,
    nro_sucursal BIGINT,
    direccion VARCHAR(255),
    telefono VARCHAR(255),
    mail VARCHAR(255),
    FOREIGN KEY (localidad) REFERENCES Localidad(cod_localidad)
);

CREATE TABLE Cliente (
    nro_cliente BIGINT PRIMARY KEY,
    dni BIGINT,
    localidad INT,
    nombre VARCHAR(255),
    apellido VARCHAR(255),
    fecha_nacimiento DATETIME,
    mail VARCHAR(255),
    direccion VARCHAR(255),
    telefono VARCHAR(255),
    FOREIGN KEY (localidad) REFERENCES Localidad(cod_localidad)
);

-- COMPRAS
CREATE TABLE Compra (
    nro_compra INT IDENTITY(1,1) PRIMARY KEY,
    suc_compra INT,
    fecha DATETIME,
    total DECIMAL(10,2),
    cuit_proveedor VARCHAR(20),
    FOREIGN KEY (suc_compra) REFERENCES Sucursal(id_sucursal),
    FOREIGN KEY (cuit_proveedor) REFERENCES Proveedor(cuit)
);

CREATE TABLE Detalle_Compra (
    nro_compra INT,
    material_comprado INT,
    cantidad DECIMAL,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    PRIMARY KEY (nro_compra, material_comprado),
    FOREIGN KEY (nro_compra) REFERENCES Compra(nro_compra),
    FOREIGN KEY (material_comprado) REFERENCES Material(id_material)
);

-- SILLONES
CREATE TABLE Sillon (
    id_sillon INT IDENTITY(1,1) PRIMARY KEY,
    codigo_modelo BIGINT,
    id_medida BIGINT,
    id_material INT,
    FOREIGN KEY (codigo_modelo) REFERENCES Sillon_Modelo(codigo_modelo),
    FOREIGN KEY (id_medida) REFERENCES Sillon_Medida(id_medida),
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

-- PEDIDOS
CREATE TABLE Pedido (
    nro_pedido INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATETIME,
    estado VARCHAR(50),
    total DECIMAL(10,2),
    nro_cliente BIGINT,
    id_sucursal INT,
    FOREIGN KEY (nro_cliente) REFERENCES Cliente(nro_cliente),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Detalle_Pedido (
    nro_pedido INT,
    id_sillon INT,
    cantidad BIGINT,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    PRIMARY KEY (nro_pedido, id_sillon),
    FOREIGN KEY (nro_pedido) REFERENCES Pedido(nro_pedido),
    FOREIGN KEY (id_sillon) REFERENCES Sillon(id_sillon)
);

CREATE TABLE CancelacionPedido (
    nro_pedido INT IDENTITY(1,1) PRIMARY KEY,
    fecha_cancelacion DATETIME,
    motivo_cancelacion VARCHAR(255),
    FOREIGN KEY (nro_pedido) REFERENCES Pedido(nro_pedido)
);

-- FACTURACIÓN
CREATE TABLE Factura (
    nro_factura BIGINT IDENTITY(1,1) PRIMARY KEY,
    id_sucursal INT,
    nro_cliente BIGINT,
    fecha DATETIME,
    total DECIMAL(10,2),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
    FOREIGN KEY (nro_cliente) REFERENCES Cliente(nro_cliente)
);

CREATE TABLE Detalle_Factura (
    nro_factura BIGINT,
    nro_pedido INT,
    id_sillon INT,
    cantidad DECIMAL,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    PRIMARY KEY (nro_factura, nro_pedido, id_sillon),
    FOREIGN KEY (nro_factura) REFERENCES Factura(nro_factura)
    -- Nota: la FK compuesta a Detalle_Pedido se declara manualmente fuera
);

-- ENVÍOS
CREATE TABLE Envio (
    nro_envio INT IDENTITY(1,1) PRIMARY KEY,
    nro_factura BIGINT,
    fecha_programada DATETIME,
    fecha_entrega DATETIME,
    importe_traslado DECIMAL(10,2),
    importe_subida DECIMAL(10,2),
    total DECIMAL(10,2),
    FOREIGN KEY (nro_factura) REFERENCES Factura(nro_factura)
);

-- FK compuesta manual a Detalle_Pedido
ALTER TABLE Detalle_Factura
ADD CONSTRAINT fk_detallefactura_pedido
FOREIGN KEY (nro_pedido, id_sillon)
REFERENCES Detalle_Pedido(nro_pedido, id_sillon);
