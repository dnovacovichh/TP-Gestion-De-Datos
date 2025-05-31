
-- CREACIÓN DE TABLAS INDEPENDIENTES
CREATE TABLE Provincia (
    cod_prov INT PRIMARY KEY,
    nombre_prov VARCHAR(255)
);

CREATE TABLE Material (
    id_material INT PRIMARY KEY,
    nombre VARCHAR(255),
    precio DECIMAL
);

CREATE TABLE Sillon_Modelo (
    codigo_modelo BIGINT PRIMARY KEY,
    nombre VARCHAR(255),
    descripcion VARCHAR(255),
    precio_base DECIMAL
);

CREATE TABLE Sillon_Medida (
    id_medida BIGINT PRIMARY KEY,
    alto INT,
    ancho INT,
    profundidad INT,
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
    cod_localidad INT PRIMARY KEY,
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
    id_sucursal INT PRIMARY KEY,
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
    nro_compra DECIMAL PRIMARY KEY,
    suc_compra INT,
    fecha DATETIME,
    total DECIMAL,
    cuit_proveedor VARCHAR(20),
    FOREIGN KEY (suc_compra) REFERENCES Sucursal(id_sucursal),
    FOREIGN KEY (cuit_proveedor) REFERENCES Proveedor(cuit)
);

CREATE TABLE Detalle_Compra (
    nro_compra DECIMAL,
    material_comprado INT,
    cantidad DECIMAL,
    precio DECIMAL,
    subtotal DECIMAL,
    PRIMARY KEY (nro_compra, material_comprado),
    FOREIGN KEY (nro_compra) REFERENCES Compra(nro_compra),
    FOREIGN KEY (material_comprado) REFERENCES Material(id_material)
);

-- SILLONES
CREATE TABLE Sillon (
    id_sillon INT PRIMARY KEY,
    codigo_modelo BIGINT,
    id_medida BIGINT,
    id_material INT,
    FOREIGN KEY (codigo_modelo) REFERENCES Sillon_Modelo(codigo_modelo),
    FOREIGN KEY (id_medida) REFERENCES Sillon_Medida(id_medida),
    FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

-- PEDIDOS
CREATE TABLE Pedido (
    nro_pedido DECIMAL PRIMARY KEY,
    fecha DATETIME,
    estado VARCHAR(50),
    total DECIMAL,
    nro_cliente BIGINT,
    id_sucursal INT,
    FOREIGN KEY (nro_cliente) REFERENCES Cliente(nro_cliente),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Detalle_Pedido (
    nro_pedido DECIMAL,
    id_sillon INT,
    cantidad BIGINT,
    precio DECIMAL,
    subtotal DECIMAL,
    PRIMARY KEY (nro_pedido, id_sillon),
    FOREIGN KEY (nro_pedido) REFERENCES Pedido(nro_pedido),
    FOREIGN KEY (id_sillon) REFERENCES Sillon(id_sillon)
);

CREATE TABLE CancelacionPedido (
    nro_pedido DECIMAL PRIMARY KEY,
    fecha_cancelacion DATETIME,
    motivo_cancelacion VARCHAR(255),
    FOREIGN KEY (nro_pedido) REFERENCES Pedido(nro_pedido)
);

-- FACTURACIÓN
CREATE TABLE Factura (
    nro_factura BIGINT PRIMARY KEY,
    id_sucursal INT,
    nro_cliente BIGINT,
    fecha DATETIME,
    total DECIMAL,
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
    FOREIGN KEY (nro_cliente) REFERENCES Cliente(nro_cliente)
);

CREATE TABLE Detalle_Factura (
    nro_factura BIGINT,
    nro_pedido DECIMAL,
    id_sillon INT,
    cantidad DECIMAL,
    precio DECIMAL,
    subtotal DECIMAL,
    PRIMARY KEY (nro_factura, nro_pedido, id_sillon),
    FOREIGN KEY (nro_factura) REFERENCES Factura(nro_factura)
    -- Nota: la FK compuesta a Detalle_Pedido se declara manualmente fuera
);

-- ENVÍOS
CREATE TABLE Envio (
    nro_envio DECIMAL PRIMARY KEY,
    nro_factura BIGINT,
    fecha_programada DATETIME,
    fecha_entrega DATETIME,
    importe_traslado DECIMAL,
    importe_subida DECIMAL,
    total DECIMAL,
    FOREIGN KEY (nro_factura) REFERENCES Factura(nro_factura)
);

-- FK compuesta manual a Detalle_Pedido
ALTER TABLE Detalle_Factura
ADD CONSTRAINT fk_detallefactura_pedido
FOREIGN KEY (nro_pedido, id_sillon)
REFERENCES Detalle_Pedido(nro_pedido, id_sillon);
