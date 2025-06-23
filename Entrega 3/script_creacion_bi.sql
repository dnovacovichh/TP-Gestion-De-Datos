CREATE TABLE LOS_HELECHOS.BI_Dim_Tiempo (
    id_tiempo INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
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
    edad INT,
    rango_etario VARCHAR(20),
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

CREATE TABLE LOS_HELECHOS.BI_Dim_MaterialesSillon (
    id_sillon BIGINT PRIMARY KEY,
    tipo_tela VARCHAR(255),
    color_tela VARCHAR(255),
    textura_tela VARCHAR(255),
    tipo_madera VARCHAR(255),
    color_madera VARCHAR(255),
    dureza_madera VARCHAR(255),
    tipo_relleno VARCHAR(255),
    densidad_relleno DECIMAL(38,2),
    FOREIGN KEY (id_sillon) REFERENCES LOS_HELECHOS.BI_Dim_Sillon(id_sillon)
);

CREATE TABLE LOS_HELECHOS.BI_Dim_Turno (
    id_turno INT PRIMARY KEY,
    descripcion VARCHAR(50)
);

CREATE TABLE LOS_HELECHOS.BI_Dim_EstadoPedido (
    estado VARCHAR(50) PRIMARY KEY
);

-- TABLA DE HECHOS: BI_Hecho_Venta
CREATE TABLE LOS_HELECHOS.BI_Hecho_Venta (
    id_venta bigint PRIMARY KEY,
    id_tiempo INT,
    id_sucursal INT,
    id_cliente BIGINT,
    id_sillon BIGINT,
    estado_pedido VARCHAR(50),
    id_turno INT,
    cantidad BIGINT,
    total_venta DECIMAL(10,2),

    FOREIGN KEY (id_tiempo) REFERENCES LOS_HELECHOS.BI_Dim_Tiempo(id_tiempo),
    -- FOREIGN KEY (id_sucursal) REFERENCES LOS_HELECHOS.BI_Dim_Sucursal(id_sucursal),
    -- FOREIGN KEY (id_cliente) REFERENCES LOS_HELECHOS.BI_Dim_Cliente(id_cliente),
    -- FOREIGN KEY (id_sillon) REFERENCES LOS_HELECHOS.BI_Dim_Sillon(id_sillon),
    -- FOREIGN KEY (estado_pedido) REFERENCES LOS_HELECHOS.BI_Dim_EstadoPedido(estado),
    -- FOREIGN KEY (id_turno) REFERENCES LOS_HELECHOS.BI_Dim_Turno(id_turno)

);

---

-- INSERT INTO LOS_HELECHOS.BI_


