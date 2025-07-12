/*VIEW 1*/

select * from LOS_HELECHOS.BI_Ganancias 

/*VIEW 2*/

CREATE or ALTER VIEW LOS_HELECHOS.BI_FacturaPromedioMensual AS
SELECT 
    t.anio,
    t.cuatrimestre,
    s.provincia,
    s.id_sucursal,
    AVG(v.total_venta) AS factura_promedio
FROM LOS_HELECHOS.BI_Hecho_Venta v
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON v.id_sucursal = s.id_sucursal
GROUP BY t.anio, t.cuatrimestre, s.provincia, s.id_sucursal

select * from LOS_HELECHOS.BI_FacturaPromedioMensual


/*VIEW 3*/

CREATE or ALTER VIEW LOS_HELECHOS.BI_RendimientoModelos AS
SELECT * FROM (
    SELECT 
        t.anio,
        t.cuatrimestre,
        s.localidad,
        c.rango_etario,
        si.modelo,
        SUM(v.total_venta) AS total_ventas,
        RANK() OVER (PARTITION BY t.anio, t.cuatrimestre, s.localidad, c.rango_etario ORDER BY SUM(v.total_venta) DESC) AS ranking
    FROM LOS_HELECHOS.BI_Hecho_Venta v
    JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON v.id_tiempo = t.id_tiempo
    JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON v.id_sucursal = s.id_sucursal
    JOIN LOS_HELECHOS.BI_Dim_Cliente c ON v.id_cliente = c.id_cliente
    JOIN LOS_HELECHOS.BI_Dim_Sillon si ON v.id_sillon = si.id_sillon
    GROUP BY t.anio, t.cuatrimestre, s.localidad, c.rango_etario, si.modelo
) AS modelos
WHERE ranking <= 3;

select * from LOS_HELECHOS.BI_RendimientoModelos 

/*VIEW 4*/

CREATE or ALTER VIEW LOS_HELECHOS.BI_VolumenPedidos AS
SELECT 
    t.anio,
    t.mes,
    p.id_sucursal,
    p.id_turno,
    COUNT(*) AS cantidad_pedidos
FROM LOS_HELECHOS.BI_Hecho_Pedido p
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON p.id_tiempo = t.id_tiempo
GROUP BY t.anio, t.mes, p.id_sucursal, p.id_turno;
 
select * from LOS_HELECHOS.BI_VolumenPedidos


/*VIEW 5*/

CREATE OR ALTER VIEW LOS_HELECHOS.BI_View_Conversion_Pedidos AS
SELECT 
    t.anio,
    t.cuatrimestre,
    s.id_sucursal,
    p.id_turno,
    COUNT(*) AS cantidad_pedidos,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
        PARTITION BY t.anio, t.cuatrimestre, s.id_sucursal
    ) AS DECIMAL(5,2))  AS porcentaje
FROM LOS_HELECHOS.BI_Hecho_Pedido p
JOIN LOS_HELECHOS.BI_Dim_Tiempo t ON p.id_tiempo = t.id_tiempo
JOIN LOS_HELECHOS.BI_Dim_Sucursal s ON p.id_sucursal = s.id_sucursal
GROUP BY 
    t.anio,
    t.cuatrimestre,
    s.id_sucursal,
    p.id_turno;


select * from LOS_HELECHOS.BI_View_Conversion_Pedidos

/*VIEW 6*/

select * from  LOS_HELECHOS.BI_Vista_Tiempo_Fabricacion

/*VIEW 7*/

select * from LOS_HELECHOS.BI_Vista_Promedio_Compras

/*VIEW 8*/

select * from LOS_HELECHOS.BI_Vista_Compras_Tipo_Material 

/*VIEW 9*/

select * from LOS_HELECHOS.BI_Vista_Cumplimiento_Envios

/*VIEW 10*/

select * from LOS_HELECHOS.BI_Vista_Localidades_Costo_Envio 

