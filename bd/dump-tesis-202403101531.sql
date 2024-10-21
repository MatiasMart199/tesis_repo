--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8 (Ubuntu 14.8-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.8 (Ubuntu 14.8-0ubuntu0.22.04.1)

-- Started on 2024-03-10 15:31:33 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 899 (class 1247 OID 18594)
-- Name: estados; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estados AS ENUM (
    'ACTIVO',
    'INACTIVO',
    'PENDIENTE',
    'CONFIRMADO',
    'ANULADO',
    'ABIERTO',
    'CERRADO'
);


ALTER TYPE public.estados OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 18816)
-- Name: sp_ciudades(integer, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_ciudades(cid_ciudad integer, cciu_descrip character varying, cid_pais integer, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF operacion = 1 THEN -- INSERCIÓN 
        PERFORM * FROM ciudades WHERE ciu_descrip = UPPER(TRIM(cciu_descrip)) AND id_pais = cid_pais;
        IF FOUND THEN 
            RAISE EXCEPTION 'ESTE DATO YA FUE REGISTRADO';
        END IF;
        INSERT INTO ciudades (id_ciudad, 
                            ciu_descrip, 
                            id_pais, 
                            estado)
        VALUES ((SELECT COALESCE(MAX(id_ciudad), 0) + 1 FROM ciudades),
            UPPER(TRIM(cciu_descrip)),
            cid_pais,
            'ACTIVO');
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    END IF;
    
    IF operacion = 2 THEN -- MODIFICACIÓN 
         PERFORM * FROM ciudades WHERE ciu_descrip = UPPER(TRIM(cciu_descrip)) AND id_ciudad != cid_ciudad AND id_pais = cid_pais;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE DATO YA FUE REGISTRADO';
        END IF;
        UPDATE ciudades
        SET ciu_descrip = UPPER(TRIM(cciu_descrip)),
            id_pais = cid_pais
        WHERE id_ciudad = cid_ciudad;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    END IF;
    
    IF operacion = 3 THEN -- ACTIVAR 
        PERFORM * FROM ciudades WHERE id_ciudad = cid_ciudad;
        IF NOT FOUND THEN        
            RAISE EXCEPTION 'La ciudad no existe.';
        END IF;

        UPDATE ciudades
        SET estado = 'ACTIVO'
        WHERE id_ciudad = cid_ciudad;
        RAISE NOTICE 'DATOS ACTIVADOS CON ÉXITO';
    END IF;
    
    IF operacion = 4 THEN -- INACTIVAR 
        PERFORM * FROM ciudades WHERE id_ciudad = cid_ciudad;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La ciudad no existe.';
        END IF;
        
        -- Inactivar la ciudad.
        UPDATE ciudades
        SET estado = 'INACTIVO'
        WHERE id_ciudad = cid_ciudad;
        RAISE NOTICE 'DATOS INACTIVADOS CON ÉXITO';
    END IF;
END
$$;


ALTER FUNCTION public.sp_ciudades(cid_ciudad integer, cciu_descrip character varying, cid_pais integer, operacion integer) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 20133)
-- Name: sp_compras(integer, date, date, character varying, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_compras(xid_cc integer, xcc_fecha date, xcc_validez date, xcc_tipo_factura character varying, xcc_cuota integer, xid_sucursal integer, xid_funcionario integer, xid_proveedor integer, xid_item integer, xcantidad integer, xprecio integer, xid_corden integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN 
    	--INCERTAR CABECERA--
        INSERT INTO compras_cabecera (id_cc,cc_fecha,cc_validez,cc_tipo_factura,cc_cuota,id_sucursal,id_funcionario,id_proveedor,estado,auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_cc), 0) + 1 FROM compras_cabecera),
            xcc_fecha,
            xcc_validez,
            UPPER(TRIM(xcc_tipo_factura)),
            xcc_cuota,
            xid_sucursal,
            xid_funcionario,
            xid_proveedor,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN 
    -- MODIFICAR CABECERA --
        UPDATE compras_cabecera
        SET cc_fecha = xcc_fecha,
            cc_validez = xcc_validez,
            cc_tipo_factura = UPPER(TRIM(xcc_tipo_factura)),
            cc_cuota = xcc_cuota,
            id_proveedor = xid_proveedor,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_cc = xid_cc;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN 
    -- CONFIRMAR CABECERA
        UPDATE compras_cabecera
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_cc = xid_cc;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
       
    ELSIF operacion = 4 THEN 
    -- ANULAR CABECERA
        UPDATE compras_cabecera
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_cc = xid_cc;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
       
    ELSIF operacion = 5 THEN 
    -- INSERTAR DETALLES
        INSERT INTO compras_detalle (id_cc, id_item, cantidad, precio)
        VALUES (xid_cc, xid_item, xcantidad, xprecio);
       
       --ACTUALIZAR STOCK
       select  sp_control_stock (xid_item, xcantidad, 1);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
    ELSIF operacion = 6 THEN 
    -- MODIFICAR DETALLE --
        UPDATE compras_detalle
        SET cantidad = xcantidad, precio = xprecio
        WHERE id_cc = xid_cc AND id_item = xid_item;
        RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN 
    -- ELIMINAR DETALLE
    DELETE FROM compras_detalle
        WHERE id_cc = xid_cc AND id_item = xid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
       
    ELSIF operacion = 8 THEN 
    --AUTOMATISACION DE INSERCION PROCESO CONECTADO
     FOR d IN SELECT * FROM v_compras_orden_consolidacion  WHERE id_corden = xid_corden LOOP
            INSERT INTO compras_orden(id_cc, id_corden, id_item, cantidad, precio)
            VALUES (xid_cc, d.id_corden, d.id_item, d.cantidad, d.precio);
           
           --ACTUALIZAR STOCK
       select  sp_control_stock (d.id_item, d.cantidad, 1);
        END LOOP;
       
       --UPDATE compras_presupuestos_cabecera--
        --SET estado = 'CERRADO',--
            --auditoria = COALESCE(auditoria, '') || CHR(13) || 'CERRAR/' || usuario || '/' || NOW() --
       -- WHERE id_cpre = cid_cpre;--
       
        RAISE NOTICE 'PEDIDO AÑADIDOS CON ÉXITO Y CERRADO';
       
    ELSIF operacion = 9 THEN 
    --MODIFICAR PROCESO CONECTADO
        UPDATE compras_orden
        SET cantidad = xcantidad, precio = xprecio
        WHERE id_cc = xid_cc AND id_corden = xid_corden and id_item= xid_item ;
       RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
      
    ELSIF operacion = 10 THEN 
    --RECTIFICAR INSERCION POR ELIMINACION ERRONEA
    	SELECT * INTO d FROM v_compras_orden_consolidacion WHERE id_corden = xid_corden AND id_item = xid_item;
        INSERT INTO compras_orden (id_cc,id_corden, id_item, cantidad, precio)
        VALUES (xid_cc,xid_corden, xid_item, d.ccantidad, d.cprecio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 11 THEN 
    	--ELIMINAR PROCESO CONECTADO
       
        DELETE FROM compras_orden
        WHERE id_item = xid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_compras(xid_cc integer, xcc_fecha date, xcc_validez date, xcc_tipo_factura character varying, xcc_cuota integer, xid_sucursal integer, xid_funcionario integer, xid_proveedor integer, xid_item integer, xcantidad integer, xprecio integer, xid_corden integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 19903)
-- Name: sp_compras_ordenes(integer, date, date, character varying, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_compras_ordenes(cid_corden integer, cord_fecha date, cord_intervalo date, cord_tipo_factura character varying, cord_cuota integer, cid_sucursal integer, cid_funcionario integer, cid_proveedor integer, cid_item integer, ccantidad integer, cprecio integer, cid_cpre integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN -- Insertar compra_presupuesto_cabecera
        -- Inserta la cabecera del presupuesto.
    	--INCERTAR CABECERA--
        INSERT INTO compras_orden_cabecera (id_corden,ord_fecha,ord_intervalo,ord_tipo_factura,ord_cuota,id_sucursal,id_funcionario,id_proveedor,estado,auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_corden), 0) + 1 FROM compras_orden_cabecera),
            cord_fecha,
            cord_intervalo,
            UPPER(TRIM(cord_tipo_factura)),
            cord_cuota,
            cid_sucursal,
            cid_funcionario,
            cid_proveedor,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN -- Modificar compra_presupuesto_cabecera
    
    -- Actualiza la cabecera del presupuesto.
        UPDATE compras_orden_cabecera
        SET ord_fecha = cord_fecha,
            ord_intervalo = cord_intervalo,
            ord_tipo_factura = UPPER(TRIM(cord_tipo_factura)),
            ord_cuota = cord_cuota,
            id_proveedor = cid_proveedor,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_corden = cid_corden;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN -- Confirmar compra_presupuesto_cabecera
    
    -- Actualiza el estado del presupuesto a 'CONFIRMADO'.
        UPDATE compras_orden_cabecera
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_corden = cid_corden;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
       
    ELSIF operacion = 4 THEN -- Anular compra_presupuesto_cabecera
        
    -- Actualiza el estado del presupuesto a 'ANULADO'.
        UPDATE compras_orden_cabecera
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_corden = cid_corden;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar compra_presupuesto_detalle
      
    -- Inserta el detalle del pedido.
        INSERT INTO compras_orden_detalle (id_corden, id_item, cantidad, precio)
        VALUES (cid_corden, cid_item, ccantidad, cprecio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 6 THEN -- Modificar compra_presupuesto_detalle
    
    -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE compras_orden_detalle
        SET cantidad = ccantidad, precio = cprecio
        WHERE id_corden = cid_corden AND id_item = cid_item;
        RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN -- Eliminar compra_presupuesto_detalle
    
    DELETE FROM compras_orden_detalle
        WHERE id_corden = cid_corden AND id_item = cid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
       
    ELSIF operacion = 8 THEN -- Insertar compra_presupuesto_pedidos desde los pedidos
    
     -- Insertar compra_presupuesto_pedidos desde los pedidos
    BEGIN
    FOR d IN SELECT * FROM v_compras_presupuestos_consolidacion WHERE id_cpre = cid_cpre LOOP
        BEGIN
            -- Intenta realizar la inserción
            INSERT INTO compras_orden_presu(id_corden, id_cpre, id_item, cantidad, precio)
            VALUES (cid_corden, d.id_cpre, d.id_item, d.cantidad, d.precio);
        EXCEPTION
            WHEN FOREIGN_KEY_VIOLATION THEN
                -- Manejo de la excepción (puedes ignorarla o realizar alguna acción específica)
                RAISE NOTICE 'Error de clave foránea: %', SQLERRM;
        END;
    END LOOP;
END;
        
       

       --UPDATE compras_presupuestos_cabecera--
        --SET estado = 'CERRADO',--
            --auditoria = COALESCE(auditoria, '') || CHR(13) || 'CERRAR/' || usuario || '/' || NOW() --
       -- WHERE id_cpre = cid_cpre;--
       
        RAISE NOTICE 'PEDIDO AÑADIDOS CON ÉXITO Y CERRADO';
       
    ELSIF operacion = 9 THEN -- Modificar compra_presupuesto_pedidos
        -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE compras_orden_presu
        SET cantidad = ccantidad, precio = cprecio
        WHERE id_corden = cid_corden AND id_cpre = cid_cpre and id_item= cid_item ;
       RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
      
      
    ELSIF operacion = 10 THEN -- Insertar compra_presupuesto_detalle
        -- Inserta el detalle del pedido.
    	SELECT * INTO d FROM v_compras_presupuestos_consolidacion WHERE id_cpre = cid_cpre AND id_item = cid_item;
        INSERT INTO compras_orden_presu (id_cpre,id_cp, id_item, cantidad, precio)
        VALUES (cid_cpre, cid_item, d.ccantidad, d.cprecio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 11 THEN -- Eliminar compra_presupuesto_detalle
    -- Comprueba si el pedido existe y está pendiente.
       
        DELETE FROM compras_orden_presu
        WHERE id_item = cid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_compras_ordenes(cid_corden integer, cord_fecha date, cord_intervalo date, cord_tipo_factura character varying, cord_cuota integer, cid_sucursal integer, cid_funcionario integer, cid_proveedor integer, cid_item integer, ccantidad integer, cprecio integer, cid_cpre integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 19285)
-- Name: sp_compras_pedidos(integer, date, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_compras_pedidos(cid_cp integer, ccp_fecha_aprob date, cid_sucursal integer, cid_funcionario integer, cid_item integer, ccantidad integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF operacion = 1 THEN -- Insertar compra_pedido_cabecera
        -- Comprueba si hay pedidos pendientes de confirmación para esta sucursal.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_sucursal = cid_sucursal AND estado = 'PENDIENTE'; 
        IF FOUND THEN
            RAISE EXCEPTION 'EXISTEN PEDIDOS PENDIENTES DE CONFIRMACIÓN';
        END IF;
        
        -- Inserta la cabecera del pedido.
        INSERT INTO compras_pedidos_cabecera (id_cp, cp_fecha, cp_fecha_aprob, id_sucursal, id_funcionario, estado, auditoria)
		VALUES ((SELECT COALESCE(MAX(id_cp), 0) + 1 FROM compras_pedidos_cabecera), CURRENT_TIMESTAMP, ccp_fecha_aprob, cid_sucursal, cid_funcionario, 'PENDIENTE', 'INSERCION/' || usuario || '/' || NOW());
        
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    ELSIF operacion = 2 THEN -- Modificar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_cp = cid_cp AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO SE PUEDE MODIFICAR O NO EXISTE';
        END IF;
        
        -- Actualiza la cabecera del pedido.
        UPDATE compras_pedidos_cabecera SET cp_fecha_aprob = ccp_fecha_aprob, auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_cp = cid_cp;
        
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    ELSIF operacion = 3 THEN -- Confirmar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_cp = cid_cp AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO SE PUEDE CONFIRMAR O NO EXISTE';
        END IF;
       PERFORM * FROM compras_pedidos_detalles cpd WHERE id_cp = cid_cp; 
       IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO POSEE DETALLES CARGADOS';
        END IF;
        
        -- Actualiza el estado del pedido a 'CONFIRMADO'.
        UPDATE compras_pedidos_cabecera SET estado = 'CONFIRMADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_cp = cid_cp;
        
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
    ELSIF operacion = 4 THEN -- Anular compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_cp = cid_cp AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
        
        -- Actualiza el estado del pedido a 'ANULADO'.
        UPDATE compras_pedidos_cabecera SET estado = 'ANULADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_cp = cid_cp;
        
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_cp = cid_cp AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'A ESTE PEDIDO NO SE PUEDEN AGREGAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Comprueba si el producto ya ha sido registrado en el pedido.
        PERFORM * FROM compras_pedidos_detalles WHERE id_cp = cid_cp AND id_item = cid_item;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE PRODUCTO YA HA SIDO REGISTRADO EN EL PEDIDO';
        END IF;
        
        -- Inserta el detalle del pedido.
        INSERT INTO compras_pedidos_detalles (id_cp, id_item, cantidad, precio)
        VALUES (cid_cp, cid_item, ccantidad, (SELECT precio_compra FROM items WHERE id_item = cid_item));
        
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
    ELSIF operacion = 6 THEN -- Modificar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_cp = cid_cp AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE PEDIDO NO SE PUEDEN MODIFICAR CANTIDADES O NO EXISTE';
        END IF;
        
        -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE compras_pedidos_detalles SET cantidad = ccantidad, precio = (SELECT precio_compra FROM items WHERE id_cp = cid_cp AND id_item = cid_item)
        WHERE id_cp = cid_cp AND id_item = cid_item;
        
        RAISE NOTICE 'CANTIDAD MODIFICADA CON ÉXITO';
    ELSIF operacion = 7 THEN -- Eliminar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_pedidos_cabecera WHERE id_cp = cid_cp AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE PEDIDO NO SE PUEDEN ELIMINAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Elimina el detalle del pedido.
        DELETE FROM compras_pedidos_detalles WHERE id_cp = cid_cp AND id_item = cid_item;
        
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_compras_pedidos(cid_cp integer, ccp_fecha_aprob date, cid_sucursal integer, cid_funcionario integer, cid_item integer, ccantidad integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 19456)
-- Name: sp_compras_presupuestos(integer, date, date, integer, text, integer, integer, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_compras_presupuestos(cid_cpre integer, ccpre_fecha date, ccpre_validez date, ccpre_numero integer, ccpre_observacion text, cid_sucursal integer, cid_funcionario integer, cid_proveedor integer, cid_item integer, ccantidad integer, cprecio integer, cid_cp integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN -- Insertar compra_presupuesto_cabecera
        -- Inserta la cabecera del presupuesto.
    	perform * from compras_presupuestos_cabecera where 
    	id_sucursal = cid_sucursal and estado = 'PENDIENTE';
    	if found then
    	raise exception 'EXISTEN PRESUPUESTO PENDIENTES DE CONFIRMACIÓN';
    	end if;
    	--INCERTAR CABECERA--
        INSERT INTO compras_presupuestos_cabecera (id_cpre, cpre_fecha, cpre_validez, cpre_numero, cpre_observacion, id_sucursal, id_funcionario, id_proveedor, estado, auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_cpre), 0) + 1 FROM compras_presupuestos_cabecera),
            ccpre_fecha,
            ccpre_validez,
            ccpre_numero,
            ccpre_observacion,
            cid_sucursal,
            cid_funcionario,
            cid_proveedor,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN -- Modificar compra_presupuesto_cabecera
    perform * from  compras_presupuestos_cabecera where id_cpre=
	cid_cpre and estado = 'PENDIENTE';
	if found then 
	raise exception 'ESTE PEDIDO NO SE PUEDE MODIFICAR O NO EXISTE';
	end if;
    -- Actualiza la cabecera del presupuesto.
        UPDATE compras_presupuestos_cabecera
        SET cpre_fecha = ccpre_fecha,
            cpre_validez = ccpre_validez,
            cpre_numero = ccpre_numero,
            cpre_observacion = ccpre_observacion,
            id_proveedor = cid_proveedor,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_cpre = cid_cpre;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN -- Confirmar compra_presupuesto_cabecera
    PERFORM * FROM compras_presupuestos_cabecera WHERE id_cpre = 
   cid_cpre AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PRESUPUESTO NO SE PUEDE CONFIRMAR O NO EXISTE';
        END IF;
         
    -- Actualiza el estado del presupuesto a 'CONFIRMADO'.
        UPDATE compras_presupuestos_cabecera
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_cpre = cid_cpre;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
       
    ELSIF operacion = 4 THEN -- Anular compra_presupuesto_cabecera
        PERFORM * FROM compras_presupuestos_cabecera WHERE id_cpre = 
       cid_cpre AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PRESUPUESTO NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
    -- Actualiza el estado del presupuesto a 'ANULADO'.
        UPDATE compras_presupuestos_cabecera
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_cpre = cid_cpre;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar compra_presupuesto_detalle
        
    PERFORM * FROM compras_presupuestos_detalle WHERE id_cpre = 
   cid_cpre AND id_item = cid_item;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE PRODUCTO YA HA SIDO REGISTRADO';
        END IF;
    -- Inserta el detalle del pedido.
        INSERT INTO compras_presupuestos_detalle (id_cpre, id_item, cantidad, precio)
        VALUES (cid_cpre, cid_item, ccantidad, cprecio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 6 THEN -- Modificar compra_presupuesto_detalle
    PERFORM * FROM compras_presupuestos_detalle WHERE id_cpre = 
   cid_cpre AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE DATO NO SE PUEDEN MODIFICAR CANTIDADES O NO EXISTE';
        END IF;
           
    -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE compras_presupuestos_detalle
        SET cantidad = ccantidad, precio = cprecio
        WHERE id_cpre = cid_cpre AND id_item = cid_item;
        RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN -- Eliminar compra_presupuesto_detalle
    
    DELETE FROM compras_presupuestos_detalle
        WHERE id_cpre = cid_cpre AND id_item = cid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    ELSIF operacion = 8 THEN -- Insertar compra_presupuesto_pedidos desde los pedidos
    
        PERFORM * FROM compras_presupuestos_pedidos WHERE id_cpre = 
   		cid_cpre and id_cp= cid_cp and id_item = cid_item;
        if FOUND THEN
            RAISE EXCEPTION 'ESTE PRODUCTO YA HA SIDO REGISTRADO';
        END IF;
    
    FOR d IN SELECT * FROM compras_pedidos_detalles WHERE id_cp = cid_cp LOOP
            INSERT INTO compras_presupuestos_pedidos(id_cpre, id_cp, id_item, cantidad, precio)
            VALUES (cid_cpre, d.id_cp, d.id_item, d.cantidad, d.precio);
        END LOOP;
        
       
       UPDATE compras_pedidos_cabecera
        SET estado = 'CERRADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CERRAR/' || usuario || '/' || NOW() 
        WHERE id_cp = cid_cp;
       
        RAISE NOTICE 'PEDIDO AÑADIDOS CON ÉXITO Y CERRADO';
       
    ELSIF operacion = 9 THEN -- Modificar compra_presupuesto_pedidos
        -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE compras_presupuestos_pedidos
        SET cantidad = ccantidad, precio = cprecio
        WHERE id_cpre = cid_cpre AND id_cp = cid_cp and id_item= cid_item ;
       RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
      
      
    ELSIF operacion = 10 THEN -- Insertar compra_presupuesto_detalle
        -- Inserta el detalle del pedido.
    	SELECT * INTO d FROM compras_pedidos_detalles WHERE id_cp = cid_cp AND id_item = cid_item;
        INSERT INTO compras_presupuestos_pedidos (id_cpre,id_cp, id_item, cantidad, precio)
        VALUES (cid_cpre, cid_item, d.ccantidad, d.cprecio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 11 THEN -- Eliminar compra_presupuesto_detalle
    -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM compras_presupuestos_pedidos WHERE id_item = cid_item;
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'NO ESTA INGRESANDO LOS PARAMETROS DEL ID_PRESUPUESTO';
        END IF;
       
        DELETE FROM compras_presupuestos_pedidos
        WHERE id_item = cid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_compras_presupuestos(cid_cpre integer, ccpre_fecha date, ccpre_validez date, ccpre_numero integer, ccpre_observacion text, cid_sucursal integer, cid_funcionario integer, cid_proveedor integer, cid_item integer, ccantidad integer, cprecio integer, cid_cp integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 19998)
-- Name: sp_control_stock(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_control_stock(xid_item integer, xcantidad integer, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    c INTEGER;
BEGIN 
    SELECT stock_cantidad INTO c FROM stock s WHERE id_item = xid_item;
    
    IF operacion = 1 THEN -- ACTUALIZAR STOCK EN COMPRAS
        UPDATE stock
        SET stock_cantidad = c + xcantidad
        WHERE id_item = xid_item;

    ELSIF operacion = 2 THEN  -- ACTUALIZAR STOCK EN VENTAS
        IF c <= 0 THEN
            RAISE EXCEPTION 'No hay suficiente stock para vender';
        END IF;
        
        UPDATE stock
        SET stock_cantidad = c - ABS(xcantidad)
        WHERE id_item = xid_item;
    END IF;
END
$$;


ALTER FUNCTION public.sp_control_stock(xid_item integer, xcantidad integer, operacion integer) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 18605)
-- Name: sp_meses(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_meses(valor integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare num_mes varchar;
begin
	if valor = 1 then
		num_mes='Enero';
	end if;
	if valor = 2 then
		num_mes='Febrero';
	end if;
	if valor = 3 then
		num_mes='Marzo';
	end if;
	case valor
		when 4 then num_mes= 'Abril';
		when 5 then num_mes= 'Mayo';
		when 6 then num_mes= 'Junio';
		when 7 then num_mes= 'Julio';
	else 
		if(valor < 1 or valor >12) then
			num_mes='CODIGO INVALIDO';
		
		--CORTA EL PROCESO--
		raise exception '%', 'Codigo invalido '||valor||' no existe';
			end if;
	end case;
	--MUESTA EL MENSAJE Y SIGUE EL PROCESO--
	raise notice '%', 'Codigo validado '||valor|| ' sin problema';
return num_mes;
end 
$$;


ALTER FUNCTION public.sp_meses(valor integer) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 18606)
-- Name: sp_paises(integer, character varying, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_paises(cid_pais integer, cpais_descrip character varying, cpais_gentilicio character varying, cpais_codigo character varying, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
	IF operacion = 1 THEN --INSERCION 
		PERFORM * FROM paises WHERE pais_descrip = UPPER(TRIM(cpais_descrip));
		IF FOUND THEN 
			RAISE EXCEPTION 'ESTE DATO YA FUE REGISTRADO';
		END IF;
		INSERT INTO paises (id_pais, 
							pais_descrip, 
							pais_gentilicio, 
							pais_codigo, 
							estado, 
							auditoria)
		VALUES ((SELECT COALESCE(MAX(id_pais), 0) + 1 FROM paises),
				UPPER(TRIM(cpais_descrip)),
				UPPER(TRIM(cpais_gentilicio)),
				cpais_codigo,
				'ACTIVO',
				'INSERCION/' || usuario || '/' || NOW());
		RAISE NOTICE 'DATOS GUARDADOS CON EXITO';
	END IF;
	
	IF operacion = 2 THEN --MODIFICACION 
		PERFORM * FROM paises WHERE pais_descrip = UPPER(TRIM(cpais_descrip)) AND id_pais != cid_pais;
		IF FOUND THEN
			RAISE EXCEPTION 'ESTE DATO YA FUE REGISTRADO';
		END IF;
		UPDATE paises
		SET pais_descrip = UPPER(TRIM(cpais_descrip)),
			pais_gentilicio = UPPER(TRIM(cpais_gentilicio)),
			pais_codigo = cpais_codigo,
			auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION' || usuario || '/' || NOW()
		WHERE id_pais = cid_pais; 
		RAISE NOTICE 'DATOS MODIFICADOS CON EXITO';
	END IF;
	
	IF operacion = 3 THEN --ACTIVAR 
		UPDATE paises
		SET estado = 'ACTIVO',
			auditoria = COALESCE(auditoria, '') || CHR(13) || 'ACTIVACION' || usuario || '/' || NOW()
		WHERE id_pais = cid_pais; 
		RAISE NOTICE 'DATOS ACTIVADOS CON EXITO';
	END IF;
	
	IF operacion = 4 THEN --INACTIVAR 
		UPDATE paises
		SET estado = 'INACTIVO',
			auditoria = COALESCE(auditoria, '') || CHR(13) || 'INACTIVACION' || usuario || '/' || NOW()
		WHERE id_pais = cid_pais; 
		RAISE NOTICE 'DATOS INACTIVADOS CON EXITO';
	END IF;
END
$$;


ALTER FUNCTION public.sp_paises(cid_pais integer, cpais_descrip character varying, cpais_gentilicio character varying, cpais_codigo character varying, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 19706)
-- Name: sp_personas(integer, character varying, character varying, character varying, character varying, character varying, character varying, date, character varying, boolean, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_personas(idpersona integer, pernombre character varying, perapellido character varying, perruc character varying, perci character varying, perdireccion character varying, percorreo character varying, perfenaci date, pertelefono character varying, personafisica boolean, idciudad integer, idecivil integer, idgenero integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF operacion = 1 THEN -- INSERCION
        PERFORM * FROM personas WHERE per_ruc = perruc OR per_ci = perci;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE DATO YA FUE REGISTRADO';
        END IF;
        INSERT INTO personas (id_persona, per_nombre, per_apellido, per_ruc, per_ci, per_direccion, per_correo, per_fenaci, per_telefono, persona_fisica, estado, auditoria, id_ciudad, id_ecivil, id_genero)
        VALUES (
            (SELECT COALESCE(MAX(id_persona), 0) + 1 FROM personas),
            UPPER(TRIM(pernombre)),
            UPPER(TRIM(perapellido)),
            perruc,
            perci,
            perdireccion,
            percorreo,
            perfenaci,
            pertelefono,
            personafisica,
            'ACTIVO',
            'INSERCION/' || usuario || '/' || NOW(),
            idciudad,
            idecivil,
            idgenero
        );
        RAISE NOTICE 'DATOS GUARDADOS CON EXITO';
    ELSIF operacion = 2 THEN -- INSERCION DE PERSONA JURIDICA
        INSERT INTO personas (id_persona, per_nombre, per_apellido, per_ruc, per_ci, per_direccion, per_correo, per_fenaci, per_telefono, persona_fisica, estado, auditoria, id_ciudad, id_ecivil, id_genero)
        VALUES (
            (SELECT COALESCE(MAX(id_persona), 0) + 1 FROM personas),
            UPPER(TRIM(pernombre)),
            UPPER(TRIM(perapellido)),
            perruc,
            perci,
            perdireccion,
            percorreo,
            perfenaci,
            pertelefono,
            personafisica,
            'ACTIVO',
            'INSERCION/' || usuario || '/' || NOW(),
            idciudad,
            idecivil,
            idgenero
        );
        RAISE NOTICE 'DATOS GUARDADOS CON EXITO';
    ELSIF operacion = 3 THEN -- MODIFICACION
        PERFORM * FROM personas WHERE (per_ruc = perruc OR per_ci = perci) AND id_persona <> idpersona;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE DATO YA FUE REGISTRADO';
        END IF;
        UPDATE personas
        SET per_nombre = UPPER(TRIM(pernombre)),
            per_apellido = UPPER(TRIM(perapellido)),
            per_ruc = perruc,
            per_ci = perci,
            per_direccion = perdireccion,
            per_correo = percorreo,
            per_fenaci = perfenaci,
            per_telefono = pertelefono,
            id_ciudad = idciudad,
            id_ecivil = idecivil,
            id_genero = idgenero,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION' || usuario || '/' || NOW()
        WHERE id_persona = idpersona;
        RAISE NOTICE 'DATOS MODIFICADOS CON EXITO';
    ELSIF operacion = 4 THEN -- ACTIVAR
        UPDATE personas
        SET estado = 'ACTIVO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ACTIVACION' || usuario || '/' || NOW()
        WHERE id_persona = idpersona;
        RAISE NOTICE 'DATOS ACTIVADOS CON EXITO';
    ELSIF operacion = 5 THEN -- INACTIVAR
        UPDATE personas
        SET estado = 'INACTIVO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'INACTIVACION' || usuario || '/' || NOW()
        WHERE id_persona = idpersona;
        RAISE NOTICE 'DATOS INACTIVADOS CON EXITO';
    END IF;
END
$$;


ALTER FUNCTION public.sp_personas(idpersona integer, pernombre character varying, perapellido character varying, perruc character varying, perci character varying, perdireccion character varying, percorreo character varying, perfenaci date, pertelefono character varying, personafisica boolean, idciudad integer, idecivil integer, idgenero integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 19704)
-- Name: sp_servicios_inscripciones(integer, date, text, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_servicios_inscripciones(cid_inscrip integer, cins_aprobacion date, cins_estad_salud text, cid_sucursal integer, cid_funcionario integer, cid_cliente integer, cid_plan_servi integer, cdia integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF operacion = 1 THEN -- Insertar compra_pedido_cabecera
        -- Comprueba si hay pedidos pendientes de confirmación para esta sucursal.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_sucursal = cid_sucursal AND estado = 'PENDIENTE'; 
        IF FOUND THEN
            RAISE EXCEPTION 'EXISTEN INSCRIPCION PENDIENTES DE CONFIRMACIÓN';
        END IF;
        
        -- Inserta la cabecera del pedido.
        INSERT INTO servicios_inscripciones_cabecera (id_inscrip,ins_fecha,ins_aprobacion,ins_estad_salud,id_sucursal,id_funcionario,id_cliente,estado,auditoria)
		VALUES ((SELECT COALESCE(MAX(id_inscrip), 0) + 1 FROM servicios_inscripciones_cabecera), CURRENT_TIMESTAMP,cins_aprobacion,cins_estad_salud,cid_sucursal,cid_funcionario,cid_cliente,'PENDIENTE', 'INSERCION/' || usuario || '/' || NOW());
        
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    ELSIF operacion = 2 THEN -- Modificar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTA INSCRIPCION NO SE PUEDE MODIFICAR O NO EXISTE';
        END IF;
        
        -- Actualiza la cabecera del pedido.
        UPDATE servicios_inscripciones_cabecera SET ins_aprobacion = cins_aprobacion, auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_inscrip = cid_inscrip;
        
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    ELSIF operacion = 3 THEN -- Confirmar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTA INSCRIPCION NO SE PUEDE CONFIRMAR O NO EXISTE';
        END IF;
       PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip; 
       IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTA INSCRIPCION NO POSEE DETALLES CARGADOS';
        END IF;
        
        -- Actualiza el estado del pedido a 'CONFIRMADO'.
        UPDATE servicios_inscripciones_cabecera SET ins_aprobacion= CURRENT_TIMESTAMP,estado = 'CONFIRMADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_inscrip = cid_inscrip;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
    ELSIF operacion = 4 THEN -- Anular compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTA INSCRIPCION NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
        
        -- Actualiza el estado del pedido a 'ANULADO'.
        UPDATE servicios_inscripciones_cabecera SET estado = 'ANULADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_inscrip = cid_inscrip;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'A ESTA INSCRIPCION NO SE PUEDEN AGREGAR PLAN O NO EXISTE';
        END IF;
        
        -- Comprueba si el producto ya ha sido registrado en el pedido.
        PERFORM * FROM servicios_inscripciones_detalle WHERE id_inscrip = cid_inscrip AND id_plan_servi = cid_plan_servi;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE PLAN YA HA SIDO REGISTRADO EN EL PEDIDO';
        END IF;
        
        -- Inserta el detalle del pedido.
        INSERT INTO servicios_inscripciones_detalle (id_inscrip,id_plan_servi,dia, precio)
        VALUES (cid_inscrip, cid_plan_servi, cdia, (SELECT precio_servicio FROM planes_servicios WHERE id_plan_servi = cid_plan_servi));
        
        RAISE NOTICE 'PLAN AÑADIDO CON ÉXITO';
    ELSIF operacion = 6 THEN -- Modificar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTA INSCRIPCION NO SE PUEDEN MODIFICAR DIA O NO EXISTE';
        END IF;
        
        -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE servicios_inscripciones_detalle SET dia = cdia, precio = (SELECT precio_servicio FROM planes_servicios WHERE id_inscrip = cid_inscrip AND id_plan_servi = cid_plan_servi)
        WHERE id_inscrip = cid_inscrip AND id_plan_servi = cid_plan_servi;
        
        RAISE NOTICE 'DIA MODIFICADA CON ÉXITO';
    ELSIF operacion = 7 THEN -- Eliminar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM servicios_inscripciones_cabecera WHERE id_inscrip = cid_inscrip AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTA INSCRIPCION NO SE PUEDEN ELIMINAR PLAN O NO EXISTE';
        END IF;
        
        -- Elimina el detalle del pedido.
        DELETE FROM servicios_inscripciones_detalle WHERE id_inscrip = cid_inscrip AND id_plan_servi = cid_plan_servi;
        
        RAISE NOTICE 'PLAN ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_servicios_inscripciones(cid_inscrip integer, cins_aprobacion date, cins_estad_salud text, cid_sucursal integer, cid_funcionario integer, cid_cliente integer, cid_plan_servi integer, cdia integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 19563)
-- Name: sp_ventas_pedidos(integer, date, text, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_ventas_pedidos(cid_vped integer, cvped_aprobacion date, cvped_observacion text, cid_sucursal integer, cid_funcionario integer, cid_cliente integer, cid_item integer, ccantidad integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF operacion = 1 THEN -- Insertar compra_pedido_cabecera
        -- Comprueba si hay pedidos pendientes de confirmación para esta sucursal.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_sucursal = cid_sucursal AND estado = 'PENDIENTE'; 
        IF FOUND THEN
            RAISE EXCEPTION 'EXISTEN PEDIDOS PENDIENTES DE CONFIRMACIÓN';
        END IF;
        
        -- Inserta la cabecera del pedido.
        INSERT INTO ventas_pedidos_cabecera (id_vped,vped_fecha,vped_aprobacion,vped_observacion,id_sucursal,id_funcionario,id_cliente,estado,auditoria)
		VALUES ((SELECT COALESCE(MAX(id_vped), 0) + 1 FROM ventas_pedidos_cabecera), CURRENT_TIMESTAMP, cvped_aprobacion,cvped_observacion,cid_sucursal,cid_funcionario,cid_cliente,'PENDIENTE', 'INSERCION/' || usuario || '/' || NOW());
        
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    ELSIF operacion = 2 THEN -- Modificar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO SE PUEDE MODIFICAR O NO EXISTE';
        END IF;
        
        -- Actualiza la cabecera del pedido.
        UPDATE ventas_pedidos_cabecera SET vped_aprobacion = cvped_aprobacion, auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_vped = cid_vped;
        
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    ELSIF operacion = 3 THEN -- Confirmar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO SE PUEDE CONFIRMAR O NO EXISTE';
        END IF;
       PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped; 
       IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO POSEE DETALLES CARGADOS';
        END IF;
        
        -- Actualiza el estado del pedido a 'CONFIRMADO'.
        UPDATE ventas_pedidos_cabecera SET estado = 'CONFIRMADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_vped = cid_vped;
        
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
    ELSIF operacion = 4 THEN -- Anular compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE PEDIDO NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
        
        -- Actualiza el estado del pedido a 'ANULADO'.
        UPDATE ventas_pedidos_cabecera SET estado = 'ANULADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_vped = cid_vped;
        
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'A ESTE PEDIDO NO SE PUEDEN AGREGAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Comprueba si el producto ya ha sido registrado en el pedido.
        PERFORM * FROM ventas_pedidos_detalle WHERE id_vped = cid_vped AND id_item = cid_item;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE PRODUCTO YA HA SIDO REGISTRADO EN EL PEDIDO';
        END IF;
        
        -- Inserta el detalle del pedido.
        INSERT INTO ventas_pedidos_detalle (id_vped, id_item, cantidad, precio)
        VALUES (cid_vped, cid_item, ccantidad, (SELECT precio_venta FROM items WHERE id_item = cid_item));
        
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
    ELSIF operacion = 6 THEN -- Modificar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE PEDIDO NO SE PUEDEN MODIFICAR CANTIDADES O NO EXISTE';
        END IF;
        
        -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE ventas_pedidos_detalle SET cantidad = ccantidad, precio = (SELECT precio_venta FROM items WHERE id_vped = cid_vped AND id_item = cid_item)
        WHERE id_vped = cid_vped AND id_item = cid_item;
        
        RAISE NOTICE 'CANTIDAD MODIFICADA CON ÉXITO';
    ELSIF operacion = 7 THEN -- Eliminar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM ventas_pedidos_cabecera WHERE id_vped = cid_vped AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE PEDIDO NO SE PUEDEN ELIMINAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Elimina el detalle del pedido.
        DELETE FROM ventas_pedidos_detalle WHERE id_vped = cid_vped AND id_item = cid_item;
        
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_ventas_pedidos(cid_vped integer, cvped_aprobacion date, cvped_observacion text, cid_sucursal integer, cid_funcionario integer, cid_cliente integer, cid_item integer, ccantidad integer, usuario character varying, operacion integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 18607)
-- Name: acciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.acciones (
    id_accion integer ,
    ac_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.acciones OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 18612)
-- Name: cargos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cargos (
    id_cargo integer ,
    car_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.cargos OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 18617)
-- Name: ciudades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudades (
    id_ciudad integer ,
    ciu_descrip character varying,
    estado public.estados,
    auditoria text,
    id_pais integer
);


ALTER TABLE public.ciudades OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 19462)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente integer ,
    id_persona integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 20007)
-- Name: compras_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_cabecera (
    id_cc integer ,
    cc_fecha date,
    cc_validez date,
    cc_tipo_factura character varying,
    cc_cuota integer,
    id_sucursal integer,
    id_funcionario integer,
    id_proveedor integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.compras_cabecera OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 20076)
-- Name: compras_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_detalle (
    id_cc integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_detalle OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 20091)
-- Name: compras_orden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden (
    id_cc integer ,
    id_corden integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_orden OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 19789)
-- Name: compras_orden_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden_cabecera (
    id_corden integer ,
    ord_fecha date,
    ord_intervalo date,
    ord_tipo_factura character varying,
    ord_cuota integer,
    id_sucursal integer,
    id_funcionario integer,
    id_proveedor integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.compras_orden_cabecera OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 19811)
-- Name: compras_orden_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden_detalle (
    id_corden integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_orden_detalle OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 19929)
-- Name: compras_orden_presu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden_presu (
    id_corden integer ,
    id_cpre integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_orden_presu OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 19167)
-- Name: compras_pedidos_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_pedidos_cabecera (
    id_cp integer ,
    cp_fecha date,
    cp_fecha_aprob date,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.compras_pedidos_cabecera OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 19244)
-- Name: compras_pedidos_detalles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_pedidos_detalles (
    id_cp integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_pedidos_detalles OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 19371)
-- Name: compras_presupuestos_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_presupuestos_cabecera (
    id_cpre integer ,
    cpre_fecha date,
    cpre_validez date,
    cpre_numero integer,
    cpre_observacion text,
    id_sucursal integer,
    id_funcionario integer,
    id_proveedor integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.compras_presupuestos_cabecera OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 19393)
-- Name: compras_presupuestos_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_presupuestos_detalle (
    id_cpre integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_presupuestos_detalle OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 19408)
-- Name: compras_presupuestos_pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_presupuestos_pedidos (
    id_cpre integer ,
    id_cp integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_presupuestos_pedidos OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 20126)
-- Name: d; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.d (
    id_corden integer,
    id_item integer,
    sum bigint,
    precio integer,
    item_descrip character varying,
    id_mar integer,
    id_tip_item integer,
    mar_descrip character varying,
    tip_item_descrip character varying
);


ALTER TABLE public.d OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 19971)
-- Name: deposito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deposito (
    id_sucursal integer ,
    dep_descrip character varying,
    estado public.estados
);


ALTER TABLE public.deposito OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 18622)
-- Name: empresas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empresas (
    id_empresa integer ,
    emp_ruc character varying,
    emp_denominacion character varying,
    emp_direccion character varying,
    emp_correo character varying,
    emp_telefono character varying,
    emp_actividad character varying,
    emp_ubicacion character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.empresas OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 18627)
-- Name: estado_civiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado_civiles (
    id_ecivil integer ,
    ec_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.estado_civiles OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 18632)
-- Name: funcionarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.funcionarios (
    id_funcionario integer ,
    fun_ingreso date,
    fun_egreso date,
    monto_salario integer,
    estado public.estados,
    auditoria text,
    id_persona integer,
    id_cargo integer
);


ALTER TABLE public.funcionarios OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 18637)
-- Name: generos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generos (
    id_genero integer ,
    gen_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.generos OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 18642)
-- Name: grupos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupos (
    id_grupo integer ,
    gru_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.grupos OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 19222)
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id_item integer ,
    item_descrip character varying,
    precio_compra integer,
    precio_venta integer,
    id_mar integer,
    id_tip_item integer,
    id_tip_impuesto integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.items OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18946)
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id_mar integer ,
    mar_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 18647)
-- Name: modulos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modulos (
    id_modulo integer ,
    mod_descrip character varying,
    mod_icono character varying,
    mod_orden integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.modulos OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 18652)
-- Name: paginas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paginas (
    id_pagina integer ,
    pag_descrip character varying,
    pag_ubicacion character varying,
    pag_icono character varying,
    estado public.estados,
    auditoria text,
    id_modulo integer
);


ALTER TABLE public.paginas OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 18657)
-- Name: paises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paises (
    id_pais integer ,
    pais_descrip character varying,
    pais_gentilicio character varying,
    pais_codigo character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.paises OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 18662)
-- Name: permisos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permisos (
    id_grupo integer ,
    id_pagina integer ,
    id_accion integer ,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.permisos OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 19590)
-- Name: personal_trainers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_trainers (
    id_persona_trainer integer ,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.personal_trainers OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 18667)
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personas (
    id_persona integer ,
    per_nombre character varying,
    per_apellido character varying,
    per_ruc character varying,
    per_ci character varying,
    per_direccion character varying,
    per_correo character varying,
    per_fenaci date,
    per_telefono character varying,
    persona_fisica boolean,
    estado public.estados,
    auditoria text,
    id_ciudad integer,
    id_ecivil integer,
    id_genero integer
);


ALTER TABLE public.personas OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 19578)
-- Name: planes_servicios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planes_servicios (
    id_plan_servi integer ,
    ps_descrip character varying,
    precio_servicio integer,
    id_tip_impuesto integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.planes_servicios OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 19286)
-- Name: proveedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedores (
    id_proveedor integer ,
    id_persona integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.proveedores OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 19654)
-- Name: servicios_inscripciones_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicios_inscripciones_cabecera (
    id_inscrip integer ,
    ins_fecha date,
    ins_aprobacion date,
    ins_estad_salud text,
    id_sucursal integer,
    id_funcionario integer,
    id_cliente integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.servicios_inscripciones_cabecera OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 19676)
-- Name: servicios_inscripciones_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicios_inscripciones_detalle (
    id_inscrip integer ,
    id_plan_servi integer ,
    dia integer,
    precio integer
);


ALTER TABLE public.servicios_inscripciones_detalle OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 19983)
-- Name: stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock (
    id_sucursal integer ,
    id_item integer ,
    stock_cantidad integer,
    estado public.estados
);


ALTER TABLE public.stock OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 18672)
-- Name: sucursales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sucursales (
    id_sucursal integer ,
    suc_nombre character varying,
    suc_direccion character varying,
    suc_correo character varying,
    suc_telefono character varying,
    suc_ubicacion character varying,
    suc_imagen character varying,
    estado public.estados,
    auditoria text,
    id_empresa integer
);


ALTER TABLE public.sucursales OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 19215)
-- Name: tipos_impuestos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_impuestos (
    id_tip_impuesto integer ,
    tip_imp_descrip character varying,
    tip_imp_tasa numeric,
    tip_imp_tasa2 numeric,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.tipos_impuestos OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 19138)
-- Name: tipos_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_items (
    id_tip_item integer ,
    tip_item_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.tipos_items OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 18677)
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usuario integer ,
    usu_login character varying,
    usu_contrasena character varying,
    usu_imagen character varying,
    estado public.estados,
    auditoria text,
    id_funcionario integer,
    id_grupo integer,
    id_sucursal integer
);


ALTER TABLE public.usuarios OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18682)
-- Name: usuarios_sucursales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios_sucursales (
    id_usuario integer ,
    id_sucursal integer ,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.usuarios_sucursales OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18811)
-- Name: v_ciudades; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_ciudades AS
 SELECT c.id_ciudad,
    c.ciu_descrip,
    c.id_pais,
    c.estado,
    p.pais_descrip,
    p.pais_gentilicio
   FROM public.ciudades c,
    public.paises p
  WHERE (c.id_pais = p.id_pais);


ALTER TABLE public.v_ciudades OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 19558)
-- Name: v_clientes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_clientes AS
 SELECT c.id_cliente,
    c.id_persona,
    c.estado,
    c.auditoria,
    p.per_ci,
    p.per_ruc,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS cliente,
    p.per_direccion,
    p.per_telefono,
    p.per_correo
   FROM (public.clientes c
     JOIN public.personas p ON ((p.id_persona = c.id_persona)));


ALTER TABLE public.v_clientes OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 20169)
-- Name: v_compras_detalles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_detalles AS
 SELECT cd.id_cc,
    cd.id_item,
    cd.cantidad,
    cd.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip,
    s.id_item AS id_stock,
    s.stock_cantidad,
    ((cd.precio)::numeric * ti2.tip_imp_tasa) AS tasa1,
    ((cd.precio)::numeric * ti2.tip_imp_tasa2) AS tasa2,
    (((cd.precio)::numeric * ti2.tip_imp_tasa) + ((cd.precio)::numeric * ti2.tip_imp_tasa2)) AS total_impuestos
   FROM (((((public.compras_detalle cd
     JOIN public.items i ON ((i.id_item = cd.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.tipos_impuestos ti2 ON ((ti2.id_tip_impuesto = i.id_tip_impuesto)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.stock s ON ((s.id_item = cd.id_item)));


ALTER TABLE public.v_compras_detalles OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 19888)
-- Name: v_compras_orden_detalles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_orden_detalles AS
 SELECT cod.id_corden,
    cod.id_item,
    cod.cantidad,
    cod.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip
   FROM (((public.compras_orden_detalle cod
     JOIN public.items i ON ((i.id_item = cod.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)));


ALTER TABLE public.v_compras_orden_detalles OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 19949)
-- Name: v_compras_orden_presu; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_orden_presu AS
 SELECT cop.id_corden,
    cop.id_cpre,
    cop.id_item,
    cop.cantidad,
    cop.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip
   FROM (((public.compras_orden_presu cop
     JOIN public.items i ON ((i.id_item = cop.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)));


ALTER TABLE public.v_compras_orden_presu OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 19954)
-- Name: v_compras_orden_consolidacion; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_orden_consolidacion AS
 SELECT c.id_corden,
    c.id_item,
    sum(c.cantidad) AS sum,
    c.precio,
    c.item_descrip,
    c.id_mar,
    c.id_tip_item,
    c.mar_descrip,
    c.tip_item_descrip
   FROM ( SELECT d.id_corden,
            d.id_item,
            d.cantidad,
            d.precio,
            d.item_descrip,
            d.id_mar,
            d.id_tip_item,
            d.mar_descrip,
            d.tip_item_descrip
           FROM public.v_compras_orden_detalles d
        UNION ALL
         SELECT p.id_corden,
            p.id_item,
            p.cantidad,
            p.precio,
            p.item_descrip,
            p.id_mar,
            p.id_tip_item,
            p.mar_descrip,
            p.tip_item_descrip
           FROM public.v_compras_orden_presu p) c
  GROUP BY c.id_corden, c.id_item, c.precio, c.item_descrip, c.id_mar, c.id_tip_item, c.mar_descrip, c.tip_item_descrip;


ALTER TABLE public.v_compras_orden_consolidacion OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 20164)
-- Name: v_compras_orden_factu; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_orden_factu AS
 SELECT co.id_cc,
    co.id_corden,
    co.id_item,
    co.cantidad,
    co.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip,
    s.id_item AS id_stock,
    s.stock_cantidad,
    ((co.precio)::numeric * ti2.tip_imp_tasa) AS tasa1,
    ((co.precio)::numeric * ti2.tip_imp_tasa2) AS tasa2,
    (((co.precio)::numeric * ti2.tip_imp_tasa) + ((co.precio)::numeric * ti2.tip_imp_tasa2)) AS total_impuestos
   FROM (((((public.compras_orden co
     JOIN public.items i ON ((i.id_item = co.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.tipos_impuestos ti2 ON ((ti2.id_tip_impuesto = i.id_tip_impuesto)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.stock s ON ((s.id_item = co.id_item)));


ALTER TABLE public.v_compras_orden_factu OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 19457)
-- Name: v_funcionarios; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_funcionarios AS
 SELECT u.id_usuario,
    u.usu_login,
    u.usu_contrasena,
    u.usu_imagen,
    u.estado,
    u.auditoria,
    u.id_funcionario,
    u.id_grupo,
    u.id_sucursal,
    f.fun_ingreso,
    f.fun_egreso,
    f.monto_salario,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS funcionario
   FROM ((public.usuarios u
     JOIN public.funcionarios f ON ((f.id_funcionario = u.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)));


ALTER TABLE public.v_funcionarios OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 19944)
-- Name: v_compras_ordenes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_ordenes AS
 SELECT coc.id_corden,
    coc.ord_fecha,
    coc.ord_intervalo,
    coc.ord_tipo_factura,
    coc.ord_cuota,
    coc.id_sucursal,
    coc.id_funcionario,
    coc.id_proveedor,
    coc.estado,
    coc.auditoria,
    to_char((coc.ord_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((coc.ord_intervalo)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_intervalo,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    e.emp_ruc,
    e.emp_denominacion,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS proveedor,
    ( SELECT max(v_funcionarios.funcionario) AS max
           FROM public.v_funcionarios
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario,
    ( SELECT COALESCE(sum((compras_orden_detalle.cantidad * compras_orden_detalle.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_orden_detalle
          WHERE (compras_orden_detalle.id_corden = coc.id_corden)) AS monto_detalles,
    ( SELECT COALESCE(sum((compras_orden_presu.cantidad * compras_orden_presu.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_orden_presu
          WHERE (compras_orden_presu.id_corden = coc.id_corden)) AS monto_pedido,
    (( SELECT COALESCE(sum((compras_orden_detalle.cantidad * compras_orden_detalle.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_orden_detalle
          WHERE (compras_orden_detalle.id_corden = coc.id_corden)) + ( SELECT COALESCE(sum((compras_orden_presu.cantidad * compras_orden_presu.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_orden_presu
          WHERE (compras_orden_presu.id_corden = coc.id_corden))) AS monto_total
   FROM (((((public.compras_orden_cabecera coc
     JOIN public.sucursales s ON ((s.id_sucursal = coc.id_sucursal)))
     JOIN public.proveedores p2 ON ((p2.id_proveedor = coc.id_proveedor)))
     JOIN public.personas p ON ((p.id_persona = p2.id_persona)))
     JOIN public.funcionarios f ON ((f.id_funcionario = coc.id_funcionario)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_compras_ordenes OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 19784)
-- Name: v_compras_presupuestos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_presupuestos AS
 SELECT cpc.id_cpre,
    cpc.cpre_fecha,
    cpc.cpre_validez,
    cpc.cpre_numero,
    cpc.cpre_observacion,
    cpc.id_sucursal,
    cpc.id_funcionario,
    cpc.id_proveedor,
    cpc.estado,
    cpc.auditoria,
    to_char((cpc.cpre_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((cpc.cpre_validez)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_validez,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    e.emp_ruc,
    e.emp_denominacion,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS proveedor,
    ( SELECT max(v_funcionarios.funcionario) AS max
           FROM public.v_funcionarios
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario,
    ( SELECT COALESCE(sum((compras_presupuestos_detalle.cantidad * compras_presupuestos_detalle.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_presupuestos_detalle
          WHERE (compras_presupuestos_detalle.id_cpre = cpc.id_cpre)) AS monto_detalles,
    ( SELECT COALESCE(sum((compras_presupuestos_pedidos.cantidad * compras_presupuestos_pedidos.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_presupuestos_pedidos
          WHERE (compras_presupuestos_pedidos.id_cpre = cpc.id_cpre)) AS monto_pedido,
    (( SELECT COALESCE(sum((compras_presupuestos_detalle.cantidad * compras_presupuestos_detalle.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_presupuestos_detalle
          WHERE (compras_presupuestos_detalle.id_cpre = cpc.id_cpre)) + ( SELECT COALESCE(sum((compras_presupuestos_pedidos.cantidad * compras_presupuestos_pedidos.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_presupuestos_pedidos
          WHERE (compras_presupuestos_pedidos.id_cpre = cpc.id_cpre))) AS monto_total
   FROM (((((public.compras_presupuestos_cabecera cpc
     JOIN public.sucursales s ON ((s.id_sucursal = cpc.id_sucursal)))
     JOIN public.proveedores p2 ON ((p2.id_proveedor = cpc.id_proveedor)))
     JOIN public.personas p ON ((p.id_persona = p2.id_persona)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cpc.id_funcionario)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_compras_presupuestos OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 19439)
-- Name: v_compras_presupuestos_detalles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_presupuestos_detalles AS
 SELECT cpd.id_cpre,
    cpd.id_item,
    cpd.cantidad,
    cpd.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip
   FROM (((public.compras_presupuestos_detalle cpd
     JOIN public.items i ON ((i.id_item = cpd.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)));


ALTER TABLE public.v_compras_presupuestos_detalles OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 19444)
-- Name: v_compras_presupuestos_pedidos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_presupuestos_pedidos AS
 SELECT cpp.id_cpre,
    cpp.id_cp,
    cpp.id_item,
    cpp.cantidad,
    cpp.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip
   FROM (((public.compras_presupuestos_pedidos cpp
     JOIN public.items i ON ((i.id_item = cpp.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)));


ALTER TABLE public.v_compras_presupuestos_pedidos OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 19909)
-- Name: v_compras_presupuestos_consolidacion; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_presupuestos_consolidacion AS
 SELECT c.id_cpre,
    c.id_item,
    sum(c.cantidad) AS cantidad,
    c.precio,
    c.item_descrip,
    c.id_mar,
    c.id_tip_item,
    c.mar_descrip,
    c.tip_item_descrip
   FROM ( SELECT d.id_cpre,
            d.id_item,
            d.cantidad,
            d.precio,
            d.item_descrip,
            d.id_mar,
            d.id_tip_item,
            d.mar_descrip,
            d.tip_item_descrip
           FROM public.v_compras_presupuestos_detalles d
        UNION ALL
         SELECT p.id_cpre,
            p.id_item,
            p.cantidad,
            p.precio,
            p.item_descrip,
            p.id_mar,
            p.id_tip_item,
            p.mar_descrip,
            p.tip_item_descrip
           FROM public.v_compras_presupuestos_pedidos p) c
  GROUP BY c.id_cpre, c.id_item, c.precio, c.item_descrip, c.id_mar, c.id_tip_item, c.mar_descrip, c.tip_item_descrip;


ALTER TABLE public.v_compras_presupuestos_consolidacion OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 19259)
-- Name: v_items; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_items AS
 SELECT i.id_item,
    i.item_descrip,
    i.precio_compra,
    i.precio_venta,
    i.id_mar,
    i.id_tip_item,
    i.id_tip_impuesto,
    i.estado,
    i.auditoria,
    m.mar_descrip,
    ti.tip_item_descrip
   FROM ((public.items i
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)));


ALTER TABLE public.v_items OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 19279)
-- Name: v_pedidos_compra; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_pedidos_compra AS
 SELECT cpc.id_cp,
    cpc.cp_fecha,
    cpc.cp_fecha_aprob,
    cpc.id_sucursal,
    cpc.id_funcionario,
    cpc.estado,
    cpc.auditoria,
    to_char((cpc.cp_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((cpc.cp_fecha_aprob)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_aprob,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS funcionario,
    e.emp_ruc,
    e.emp_denominacion
   FROM ((((public.compras_pedidos_cabecera cpc
     JOIN public.sucursales s ON ((s.id_sucursal = cpc.id_sucursal)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cpc.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_pedidos_compra OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 20154)
-- Name: v_pedidos_compra_detalles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_pedidos_compra_detalles AS
 SELECT cpd.id_cp,
    cpd.id_item,
    cpd.cantidad,
    cpd.precio,
    i.item_descrip,
    i.precio_compra,
    i.precio_venta,
    i.id_tip_item,
    i.id_tip_impuesto,
    i.id_mar,
    ti.tip_imp_descrip,
    ti.tip_imp_tasa,
    ti.tip_imp_tasa2,
    ti2.tip_item_descrip,
    m.mar_descrip
   FROM ((((public.compras_pedidos_detalles cpd
     JOIN public.items i ON ((i.id_item = cpd.id_item)))
     JOIN public.tipos_impuestos ti ON ((ti.id_tip_impuesto = i.id_tip_impuesto)))
     JOIN public.tipos_items ti2 ON ((ti2.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)));


ALTER TABLE public.v_pedidos_compra_detalles OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18805)
-- Name: v_permisos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_permisos AS
 SELECT p.id_grupo,
    p.id_pagina,
    p.id_accion,
    p.estado,
    p.auditoria,
    g.gru_descrip,
    a.ac_descrip,
    p2.pag_descrip,
    p2.pag_ubicacion,
    p2.pag_icono,
    p2.id_modulo,
    m.mod_descrip,
    m.mod_icono,
    m.mod_orden
   FROM ((((public.permisos p
     JOIN public.grupos g ON ((g.id_grupo = p.id_grupo)))
     JOIN public.acciones a ON ((a.id_accion = p.id_accion)))
     JOIN public.paginas p2 ON ((p2.id_pagina = p.id_pagina)))
     JOIN public.modulos m ON ((m.id_modulo = p2.id_modulo)));


ALTER TABLE public.v_permisos OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 19712)
-- Name: v_personas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_personas AS
 SELECT p.id_persona,
    p.per_nombre,
    p.per_apellido,
    p.per_ruc,
    p.per_ci,
    p.per_direccion,
    p.per_correo,
    p.per_fenaci,
    p.per_telefono,
    p.persona_fisica,
    p.estado,
    p.auditoria,
    p.id_ciudad,
    p.id_ecivil,
    p.id_genero,
    to_char((p.per_fenaci)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_nacimiento,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS persona,
    c.ciu_descrip,
    ec.ec_descrip,
    g.gen_descrip
   FROM (((public.personas p
     JOIN public.ciudades c ON ((c.id_ciudad = p.id_ciudad)))
     JOIN public.estado_civiles ec ON ((ec.id_ecivil = p.id_ecivil)))
     JOIN public.generos g ON ((g.id_genero = p.id_genero)));


ALTER TABLE public.v_personas OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 20146)
-- Name: v_planes_servicios; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_planes_servicios AS
 SELECT ps.id_plan_servi,
    ps.ps_descrip,
    ps.precio_servicio,
    ps.id_tip_impuesto,
    ps.estado,
    ps.auditoria,
    ti.tip_imp_descrip,
    ti.tip_imp_tasa,
    ti.tip_imp_tasa2
   FROM (public.planes_servicios ps
     JOIN public.tipos_impuestos ti ON ((ti.id_tip_impuesto = ps.id_tip_impuesto)));


ALTER TABLE public.v_planes_servicios OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 19365)
-- Name: v_proveedores; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_proveedores AS
 SELECT p.id_proveedor,
    p.id_persona,
    p.estado,
    p.auditoria,
    p2.per_ci,
    p2.per_ruc,
    (((p2.per_nombre)::text || ' '::text) || (p2.per_apellido)::text) AS proveedor,
    p2.per_direccion,
    p2.per_telefono,
    p2.per_correo
   FROM (public.proveedores p
     JOIN public.personas p2 ON ((p2.id_persona = p.id_persona)));


ALTER TABLE public.v_proveedores OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 19695)
-- Name: v_servicios_inscripciones; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_servicios_inscripciones AS
 SELECT sic.id_inscrip,
    sic.ins_fecha,
    sic.ins_aprobacion,
    sic.ins_estad_salud,
    sic.id_sucursal,
    sic.id_funcionario,
    sic.id_cliente,
    sic.estado,
    sic.auditoria,
    to_char((sic.ins_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((sic.ins_aprobacion)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_aprob,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    e.emp_ruc,
    e.emp_denominacion,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS cliente,
    ( SELECT max(v_funcionarios.funcionario) AS max
           FROM public.v_funcionarios
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario
   FROM (((((public.servicios_inscripciones_cabecera sic
     JOIN public.sucursales s ON ((s.id_sucursal = sic.id_sucursal)))
     JOIN public.clientes c ON ((c.id_cliente = sic.id_cliente)))
     JOIN public.funcionarios f ON ((f.id_funcionario = sic.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = c.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_servicios_inscripciones OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 20150)
-- Name: v_servicios_inscripciones_detalle; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_servicios_inscripciones_detalle AS
 SELECT sid.id_inscrip,
    sid.id_plan_servi,
    sid.dia,
    sid.precio,
    ps.ps_descrip,
    ti.tip_imp_descrip,
    ti.tip_imp_tasa,
    ti.tip_imp_tasa2
   FROM ((public.servicios_inscripciones_detalle sid
     JOIN public.planes_servicios ps ON ((ps.id_plan_servi = sid.id_plan_servi)))
     JOIN public.tipos_impuestos ti ON ((ti.id_tip_impuesto = ps.id_tip_impuesto)));


ALTER TABLE public.v_servicios_inscripciones_detalle OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18800)
-- Name: v_usuarios; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_usuarios AS
 SELECT u.id_usuario,
    u.usu_login,
    u.usu_contrasena,
    u.usu_imagen,
    u.estado,
    u.auditoria,
    u.id_funcionario,
    u.id_grupo,
    u.id_sucursal,
    f.id_cargo,
    c.car_descrip,
    g2.gru_descrip,
    e.emp_ruc,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_telefono,
    s.suc_correo,
    s.suc_ubicacion,
    s.suc_imagen,
    p.per_ruc,
    p.per_ci,
    p.per_nombre,
    p.per_apellido,
    p.per_direccion,
    p.per_correo,
    p.per_fenaci,
    p.per_telefono,
    p.id_ciudad,
    p.id_ecivil,
    p.id_genero,
    c2.id_pais,
    c2.ciu_descrip,
    p2.pais_descrip,
    p2.pais_gentilicio,
    p2.pais_codigo,
    ec.ec_descrip,
    g.gen_descrip
   FROM ((((((((((public.usuarios u
     JOIN public.funcionarios f ON ((f.id_funcionario = u.id_funcionario)))
     JOIN public.cargos c ON ((c.id_cargo = f.id_cargo)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)))
     JOIN public.ciudades c2 ON ((c2.id_ciudad = p.id_ciudad)))
     JOIN public.paises p2 ON ((p2.id_pais = c2.id_pais)))
     JOIN public.estado_civiles ec ON ((ec.id_ecivil = p.id_ecivil)))
     JOIN public.generos g ON ((g.id_genero = p.id_genero)))
     JOIN public.sucursales s ON ((s.id_sucursal = u.id_sucursal)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)))
     JOIN public.grupos g2 ON ((g2.id_grupo = u.id_grupo)));


ALTER TABLE public.v_usuarios OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 19511)
-- Name: ventas_pedidos_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas_pedidos_cabecera (
    id_vped integer ,
    vped_fecha date,
    vped_aprobacion date,
    vped_observacion text,
    id_sucursal integer,
    id_funcionario integer,
    id_cliente integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.ventas_pedidos_cabecera OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 19548)
-- Name: v_ventas_pedidos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_ventas_pedidos AS
 SELECT vpc.id_vped,
    vpc.vped_fecha,
    vpc.vped_aprobacion,
    vpc.vped_observacion,
    vpc.id_sucursal,
    vpc.id_funcionario,
    vpc.id_cliente,
    vpc.estado,
    vpc.auditoria,
    to_char((vpc.vped_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((vpc.vped_aprobacion)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_aprob,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    e.emp_ruc,
    e.emp_denominacion,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS cliente,
    ( SELECT v_funcionarios.funcionario
           FROM public.v_funcionarios
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario
   FROM (((((public.ventas_pedidos_cabecera vpc
     JOIN public.sucursales s ON ((s.id_sucursal = vpc.id_sucursal)))
     JOIN public.clientes c ON ((c.id_cliente = vpc.id_cliente)))
     JOIN public.funcionarios f ON ((f.id_funcionario = vpc.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = c.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_ventas_pedidos OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 19533)
-- Name: ventas_pedidos_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas_pedidos_detalle (
    id_vped integer ,
    id_item integer ,
    cantidad integer,
    precio integer
);


ALTER TABLE public.ventas_pedidos_detalle OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 20159)
-- Name: v_ventas_pedidos_detalle; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_ventas_pedidos_detalle AS
 SELECT vpd.id_vped,
    vpd.id_item,
    vpd.cantidad,
    vpd.precio,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    m.mar_descrip,
    ti.tip_item_descrip,
    ti2.tip_imp_descrip,
    ti2.tip_imp_tasa,
    ti2.tip_imp_tasa2
   FROM ((((public.ventas_pedidos_detalle vpd
     JOIN public.items i ON ((i.id_item = vpd.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.tipos_impuestos ti2 ON ((ti2.id_tip_impuesto = i.id_tip_impuesto)));


ALTER TABLE public.v_ventas_pedidos_detalle OWNER TO postgres;

--
-- TOC entry 3834 (class 0 OID 18607)
-- Dependencies: 209
-- Data for Name: acciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.acciones (id_accion, ac_descrip, estado, auditoria) FROM stdin;
1	VISUALIZAR	ACTIVO	INSERCION/admin/2023-10-16 16:51:02.050925-03
\.


--
-- TOC entry 3835 (class 0 OID 18612)
-- Dependencies: 210
-- Data for Name: cargos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cargos (id_cargo, car_descrip, estado, auditoria) FROM stdin;
1	DESARROLLADOR	ACTIVO	\N
2	RECEPCIONISTA	ACTIVO	\N
3	ADMINISTRADOR DE SISTEMAS	ACTIVO	\N
\.


--
-- TOC entry 3836 (class 0 OID 18617)
-- Dependencies: 211
-- Data for Name: ciudades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ciudades (id_ciudad, ciu_descrip, estado, auditoria, id_pais) FROM stdin;
3	VILLA ELISA	ACTIVO	\N	1
4	SAN ANTONIO	ACTIVO	\N	1
2	FERNANDO DE LA MORA	ACTIVO	\N	1
5	SAN LORENZO	ACTIVO	\N	1
1	ÑEMBY	ACTIVO	\N	1
\.


--
-- TOC entry 3860 (class 0 OID 19462)
-- Dependencies: 244
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id_cliente, id_persona, estado, auditoria) FROM stdin;
1	5	ACTIVO	\N
\.


--
-- TOC entry 3872 (class 0 OID 20007)
-- Dependencies: 266
-- Data for Name: compras_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_cabecera (id_cc, cc_fecha, cc_validez, cc_tipo_factura, cc_cuota, id_sucursal, id_funcionario, id_proveedor, estado, auditoria) FROM stdin;
\.


--
-- TOC entry 3873 (class 0 OID 20076)
-- Dependencies: 267
-- Data for Name: compras_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_detalle (id_cc, id_item, cantidad, precio) FROM stdin;
\.


--
-- TOC entry 3874 (class 0 OID 20091)
-- Dependencies: 268
-- Data for Name: compras_orden; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden (id_cc, id_corden, id_item, cantidad, precio) FROM stdin;
\.


--
-- TOC entry 3867 (class 0 OID 19789)
-- Dependencies: 256
-- Data for Name: compras_orden_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden_cabecera (id_corden, ord_fecha, ord_intervalo, ord_tipo_factura, ord_cuota, id_sucursal, id_funcionario, id_proveedor, estado, auditoria) FROM stdin;
1	2024-01-02	2024-07-08	CUOTA	4	1	1	1	ANULADO	\rANULACION/admin/2024-02-03 15:24:59.000032-03
2	2024-02-02	2024-02-04	CONTADO	6	1	1	1	CONFIRMADO	INSERCION/admin/2024-02-02 17:02:53.084135-03\rCONFIRMACION/admin/2024-02-03 15:25:19.012234-03
3	2024-02-03	2024-02-03	CREDITO	0	1	1	1	PENDIENTE	INSERCION/admin/2024-02-03 15:26:55.585886-03\rMODIFICACION/admin/2024-02-03 15:28:13.458814-03
\.


--
-- TOC entry 3868 (class 0 OID 19811)
-- Dependencies: 257
-- Data for Name: compras_orden_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden_detalle (id_corden, id_item, cantidad, precio) FROM stdin;
\.


--
-- TOC entry 3869 (class 0 OID 19929)
-- Dependencies: 260
-- Data for Name: compras_orden_presu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden_presu (id_corden, id_cpre, id_item, cantidad, precio) FROM stdin;
3	4	5	1	23000
\.


--
-- TOC entry 3852 (class 0 OID 19167)
-- Dependencies: 230
-- Data for Name: compras_pedidos_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_pedidos_cabecera (id_cp, cp_fecha, cp_fecha_aprob, id_sucursal, id_funcionario, estado, auditoria) FROM stdin;
5	2023-11-08	2023-11-08	1	1	CONFIRMADO	INSERCION/admin/2023-11-08 16:58:03.410349-03\rCONFIRMACION/admin/2023-11-08 16:58:57.308226-03
6	2023-11-08	2023-11-08	1	3	PENDIENTE	INSERCION/usubeta/2023-11-08 21:00:44.357427-03
4	2023-10-29	2023-10-29	1	1	PENDIENTE	INSERCION/admin/2023-10-29 14:18:50.973631-03\rCONFIRMACION/admin/2023-10-29 14:18:57.009068-03\rCERRAR/admin/2024-01-04 19:38:03.319644-03
3	2023-10-28	2023-10-28	1	1	CONFIRMADO	INSERCION/admin/2023-10-28 22:57:53.550615-03\rCONFIRMACION/admin/2023-10-29 14:15:51.809721-03\rCERRAR/admin/2024-01-04 19:41:22.785595-03
1	2023-10-23	2023-10-23	1	1	CERRADO	INSERCION/admin/2023-10-23 21:38:53.971372-03\rCONFIRMACION/admin/2023-10-23 21:40:42.659034-03\rCERRAR/admin/2024-01-04 19:41:34.783441-03\rCERRAR/admin/2024-01-07 13:47:47.79026-03
2	2023-10-24	2023-10-24	1	1	CONFIRMADO	INSERCION/admin/2023-10-24 19:40:36.609984-03\rCONFIRMACION/admin/2023-10-28 22:57:48.997853-03
\.


--
-- TOC entry 3855 (class 0 OID 19244)
-- Dependencies: 233
-- Data for Name: compras_pedidos_detalles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_pedidos_detalles (id_cp, id_item, cantidad, precio) FROM stdin;
1	6	5	10000
1	5	15	7000
1	2	10	250000
2	6	4	10000
3	5	1	7000
3	2	1	250000
3	3	1	300000
3	1	1	250000
3	4	1	150000
3	6	1000	10000
4	6	1	10000
4	5	1	7000
5	6	1	10000
5	5	1	7000
\.


--
-- TOC entry 3857 (class 0 OID 19371)
-- Dependencies: 238
-- Data for Name: compras_presupuestos_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_presupuestos_cabecera (id_cpre, cpre_fecha, cpre_validez, cpre_numero, cpre_observacion, id_sucursal, id_funcionario, id_proveedor, estado, auditoria) FROM stdin;
2	2023-10-24	2023-10-24	0		1	1	2	ANULADO	INSERCION/admin/2023-10-24 22:26:34.607106-03\rANULACION/admin/2023-10-25 10:43:53.26954-03
3	2023-10-25	2023-10-25	453		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-25 09:59:57.625745-03\rMODIFICACION/admin/2023-10-25 15:26:34.532971-03\rMODIFICACION/admin/2023-10-25 15:29:32.321924-03\rMODIFICACION/admin/2023-10-25 15:45:17.630218-03\rCONFIRMACION/admin/2023-10-25 19:26:12.433552-03
8	2023-10-30	2023-10-30	0		1	1	1	PENDIENTE	INSERCION/admin/2023-10-30 11:39:00.005398-03
5	2023-10-28	2023-10-28	0		1	1	1	PENDIENTE	INSERCION/admin/2023-10-28 16:44:09.05719-03
6	2023-10-28	2023-10-28	0		1	1	1	PENDIENTE	INSERCION/admin/2023-10-28 16:45:47.090918-03
7	2023-10-29	2023-10-29	0		1	1	1	PENDIENTE	INSERCION/admin/2023-10-29 21:39:17.540259-03
9	2023-11-08	2023-11-08	32		1	1	1	PENDIENTE	INSERCION/admin/2023-11-08 16:59:47.399414-03
10	2023-11-08	2023-11-08	0		1	3	1	PENDIENTE	INSERCION/usubeta/2023-11-08 21:45:39.531905-03
1	2023-10-25	2023-10-25	34	N/A	1	1	1	CONFIRMADO	INSERCION/admin/2023-10-23 21:16:53.065994-03\rMODIFICACION/admin/2023-10-25 19:26:39.350349-03\rCONFIRMACION/admin/2024-01-04 17:07:08.474454-03\rCONFIRMACION/admin/2024-02-03 15:43:01.851842-03
4	2023-10-28	2023-10-28	0		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-28 16:35:56.291108-03\rCONFIRMACION/admin/2024-02-03 21:12:09.249599-03
\.


--
-- TOC entry 3858 (class 0 OID 19393)
-- Dependencies: 239
-- Data for Name: compras_presupuestos_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_presupuestos_detalle (id_cpre, id_item, cantidad, precio) FROM stdin;
9	6	1	0
9	2	1	200000
1	6	1	12000
1	5	1	14000
8	6	1	12000
2	6	1	0
2	5	2	12000
3	6	1	12000
4	6	1	0
4	5	1	23000
\.


--
-- TOC entry 3859 (class 0 OID 19408)
-- Dependencies: 240
-- Data for Name: compras_presupuestos_pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_presupuestos_pedidos (id_cpre, id_cp, id_item, cantidad, precio) FROM stdin;
1	1	6	5	10000
1	1	5	15	7000
1	1	2	10	250000
\.


--
-- TOC entry 3875 (class 0 OID 20126)
-- Dependencies: 269
-- Data for Name: d; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d (id_corden, id_item, sum, precio, item_descrip, id_mar, id_tip_item, mar_descrip, tip_item_descrip) FROM stdin;
3	5	1	23000	BEBIDA ENERGÉTICA	6	5	POWERADE	BEBIDAS
\.


--
-- TOC entry 3870 (class 0 OID 19971)
-- Dependencies: 264
-- Data for Name: deposito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deposito (id_sucursal, dep_descrip, estado) FROM stdin;
1	DEP-1	ACTIVO
\.


--
-- TOC entry 3837 (class 0 OID 18622)
-- Dependencies: 212
-- Data for Name: empresas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empresas (id_empresa, emp_ruc, emp_denominacion, emp_direccion, emp_correo, emp_telefono, emp_actividad, emp_ubicacion, estado, auditoria) FROM stdin;
1	1234567-0	ENERGYM	EUSEBIO AYALA	energym@gmail.com	0981123123	ENTRENAMIENTO FISICO	XXX-3214	ACTIVO	\N
\.


--
-- TOC entry 3838 (class 0 OID 18627)
-- Dependencies: 213
-- Data for Name: estado_civiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estado_civiles (id_ecivil, ec_descrip, estado, auditoria) FROM stdin;
3	DIVORCIADO/A	ACTIVO	\N
4	VIUDO/A	ACTIVO	\N
1	SOLTERO/A	ACTIVO	\N
2	CASADO/A	ACTIVO	\N
\.


--
-- TOC entry 3839 (class 0 OID 18632)
-- Dependencies: 214
-- Data for Name: funcionarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.funcionarios (id_funcionario, fun_ingreso, fun_egreso, monto_salario, estado, auditoria, id_persona, id_cargo) FROM stdin;
1	2021-03-01	\N	4000000	ACTIVO	\N	1	1
2	2021-01-01	\N	3000000	ACTIVO	\N	2	2
3	2021-08-07	\N	3500000	ACTIVO	\N	6	3
\.


--
-- TOC entry 3840 (class 0 OID 18637)
-- Dependencies: 215
-- Data for Name: generos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.generos (id_genero, gen_descrip, estado, auditoria) FROM stdin;
1	MASCULINO	ACTIVO	\N
2	FEMENINO	ACTIVO	\N
3	NO DEFINIDO	ACTIVO	\N
\.


--
-- TOC entry 3841 (class 0 OID 18642)
-- Dependencies: 216
-- Data for Name: grupos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grupos (id_grupo, gru_descrip, estado, auditoria) FROM stdin;
1	DESARROLLADOR	ACTIVO	\N
2	RECEPCIONISTA	ACTIVO	\N
3	ADMINISTRADOR DE SISTEMAS	ACTIVO	\N
\.


--
-- TOC entry 3854 (class 0 OID 19222)
-- Dependencies: 232
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id_item, item_descrip, precio_compra, precio_venta, id_mar, id_tip_item, id_tip_impuesto, estado, auditoria) FROM stdin;
1	PROTEÍNA	250000	300000	1	1	1	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
2	CREATINA	250000	280000	1	1	1	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
3	GUANTE DE GIMNACIO TALLA 16	300000	350000	3	3	1	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
5	BEBIDA ENERGÉTICA	7000	9000	6	5	1	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
6	BARRA DE PROTEÍNA	10000	12500	1	6	1	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
4	TOALLA	150000	170000	3	4	1	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
\.


--
-- TOC entry 3850 (class 0 OID 18946)
-- Dependencies: 228
-- Data for Name: marcas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marcas (id_mar, mar_descrip, estado, auditoria) FROM stdin;
1	LANDERFIT	ACTIVO	INSERCION/admin/2023-10-20 18:56:41.044767-03
2	WHEYKSHAKE	ACTIVO	INSERCION/admin/2023-10-20 18:56:41.044767-03
3	PUMA	ACTIVO	INSERCION/admin/2023-10-20 18:56:41.044767-03
4	ADIDAS	ACTIVO	INSERCION/admin/2023-10-20 18:56:41.044767-03
5	MONSTER	ACTIVO	INSERCION/admin/2023-10-20 18:56:41.044767-03
6	POWERADE	ACTIVO	INSERCION/admin/2023-10-20 18:56:41.044767-03
\.


--
-- TOC entry 3842 (class 0 OID 18647)
-- Dependencies: 217
-- Data for Name: modulos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modulos (id_modulo, mod_descrip, mod_icono, mod_orden, estado, auditoria) FROM stdin;
5	REFERENCIALES	fas fa-file	1	ACTIVO	\N
1	COMPRA	fa fa-shopping-cart	2	ACTIVO	\N
2	SERVICIO	fa fa-dumbbell	3	ACTIVO	\N
3	VENTA	fa fa-tags	4	ACTIVO	\N
4	CONFIG. SISTEMA	fa fa-cogs	5	ACTIVO	\N
\.


--
-- TOC entry 3843 (class 0 OID 18652)
-- Dependencies: 218
-- Data for Name: paginas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paginas (id_pagina, pag_descrip, pag_ubicacion, pag_icono, estado, auditoria, id_modulo) FROM stdin;
5	Nota de Credito y Debito	\N	far fa-circle	ACTIVO	\N	1
7	Transferencia	\N	far fa-circle	ACTIVO	\N	1
9	Rutinas	\N	far fa-circle	ACTIVO	\N	2
10	Mediciones	\N	far fa-circle	ACTIVO	\N	2
11	Plan Alimentario	\N	far fa-circle	ACTIVO	\N	2
12	Evolución del Atleta	\N	far fa-circle	ACTIVO	\N	2
13	Presupuesto de Preparacion	\N	far fa-circle	ACTIVO	\N	2
14	Registrar Asistencia	\N	far fa-circle	ACTIVO	\N	2
16	Apertura y Cierre de Caja	\N	far fa-circle	ACTIVO	\N	3
17	Registrar Venta	\N	far fa-circle	ACTIVO	\N	3
18	Cobranza	\N	far fa-circle	ACTIVO	\N	3
19	Nota de Credito y Debito	\N	far fa-circle	ACTIVO	\N	3
20	Arqueo de Caja	\N	far fa-circle	ACTIVO	\N	3
21	Nota de Remisión	\N	far fa-circle	ACTIVO	\N	3
2	Presupuesto de Proveedor	/tesis/compra/presupuesto	far fa-circle	ACTIVO	\N	1
3	Orden de Compra	/tesis/compra/orden	far fa-circle	ACTIVO	\N	1
6	Ajuste de Stock	/tesis/compra/ajuste	far fa-circle	ACTIVO	\N	1
22	Paises	/tesis/referenciales/paises	far fa-circle	ACTIVO	\N	5
23	Ciudades	/tesis/referenciales/ciudades	far fa-circle	ACTIVO	\N	5
1	Pedido de Compra	/tesis/compra/pedidos	far fa-circle	ACTIVO	\N	1
15	Pedido de Clientes	/tesis/venta/pedidos_clientes	far fa-circle	ACTIVO	\N	3
8	Inscripción	/tesis/servicio/inscripciones	far fa-circle	ACTIVO	\N	2
24	Personas	/tesis/referenciales/personas	far fa-circle	ACTIVO	\N	5
4	Registrar Compras	/tesis/compra/compras_facturacion	far fa-circle	ACTIVO	\N	1
\.


--
-- TOC entry 3844 (class 0 OID 18657)
-- Dependencies: 219
-- Data for Name: paises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paises (id_pais, pais_descrip, pais_gentilicio, pais_codigo, estado, auditoria) FROM stdin;
4	URUGUAY	URUGUAYO/YA	+598	ACTIVO	INSERCION/admin/2023-10-18 09:06:19.318074-03\rINACTIVACIONadmin/2023-10-18 09:15:15.768502-03\rACTIVACIONadmin/2023-10-18 09:15:17.737822-03\rMODIFICACIONadmin/2023-10-18 09:15:26.929311-03\rINACTIVACIONadmin/2023-10-18 09:15:53.271526-03\rACTIVACIONadmin/2023-10-18 09:15:57.249722-03\rMODIFICACIONadmin/2023-10-18 10:53:31.36677-03\rMODIFICACIONadmin/2023-10-18 10:56:10.813355-03\rINACTIVACIONadmin/2023-12-28 16:55:16.419535-03\rACTIVACIONadmin/2023-12-28 16:55:20.121334-03\rINACTIVACIONadmin/2023-12-28 17:29:46.413631-03\rACTIVACIONadmin/2023-12-28 17:29:51.239201-03
6	FASDFASDFA	SDFA	32	INACTIVO	INSERCION/admin/2023-10-18 18:23:20.700002-03\rMODIFICACIONadmin/2023-10-18 18:23:34.82439-03\rINACTIVACIONadmin/2023-10-18 19:07:57.930622-03
1	PARAGUAY	PARAGUAYO/YA	+595	ACTIVO	INSERCION/ctorres/2023-06-11 18:53:42.542986-04\rMODIFICACION/ctorres/2023-06-11 19:49:41.210377-04\rMODIFICACIONctorres/2023-06-13 11:49:13.923086-04\rINACTIVACIONctorres/2023-06-13 11:53:10.768296-04\rACTIVACIONctorres/2023-06-13 11:53:31.903907-04\rINACTIVACIONctorres/2023-06-13 15:32:53.532983-04\rACTIVACIONctorres/2023-06-13 15:33:12.746087-04\rMODIFICACIONadmin/2023-10-18 09:46:46.570093-03\rINACTIVACIONadmin/2023-10-18 10:59:40.570328-03\rACTIVACIONadmin/2023-10-18 10:59:42.477923-03\rINACTIVACIONadmin/2023-10-18 10:59:44.758243-03\rACTIVACIONadmin/2023-10-18 10:59:46.014642-03\rINACTIVACIONadmin/2023-10-18 10:59:47.143088-03\rACTIVACIONadmin/2023-10-18 10:59:51.072778-03\rINACTIVACIONadmin/2023-10-18 11:00:01.673941-03\rACTIVACIONadmin/2023-10-18 11:00:03.034348-03\rINACTIVACIONadmin/2023-10-18 11:00:04.512164-03\rACTIVACIONadmin/2023-10-18 11:00:05.698635-03\rINACTIVACIONadmin/2023-10-18 12:55:29.055746-03\rACTIVACIONadmin/2023-10-18 12:55:31.027223-03\rACTIVACIONadmin/2023-10-18 18:23:02.976665-03\rINACTIVACIONadmin/2023-10-18 18:23:07.441036-03\rACTIVACIONadmin/2023-10-18 19:08:01.421411-03
7	ESPAÑA	ESPAÑOL/LA	+34	ACTIVO	INSERCION/admin/2023-11-03 17:21:17.465989-03\rINACTIVACIONadmin/2023-11-03 17:21:30.199578-03\rACTIVACIONadmin/2023-11-03 17:21:35.419461-03
8	PERU	PERUANO/A	89	ACTIVO	INSERCION/usubeta/2023-11-08 14:46:46.964825-03
3	BRASIL	BRASILEÑO/ÑA	+55	ACTIVO	INSERCION/ctorres/2023-10-15 21:01:24.19066-03\rACTIVACIONctorres/2023-10-15 21:04:48.694315-03\rINACTIVACIONctorres/2023-10-15 21:05:03.517752-03\rACTIVACIONadmin/2023-10-18 09:15:49.928717-03\rINACTIVACIONadmin/2023-10-18 09:15:51.880423-03\rACTIVACIONadmin/2023-10-18 09:15:58.092443-03\rINACTIVACIONadmin/2023-10-18 09:16:02.591441-03\rACTIVACIONadmin/2023-10-18 09:43:59.921802-03\rMODIFICACIONadmin/2023-10-18 09:45:50.738193-03\rMODIFICACIONadmin/2023-10-18 09:46:28.944585-03
2	ARGENTINA	ARGENTINO/NA	54	ACTIVO	INSERCION/ctorres/2023-06-13 11:47:29.596292-04\rMODIFICACIONctorres/2023-10-15 21:02:44.48393-03\rMODIFICACIONctorres/2023-10-15 21:04:24.498012-03\rMODIFICACIONadmin/2023-10-18 09:43:43.60942-03\rMODIFICACIONadmin/2023-10-18 09:47:25.964454-03
5	MEXICO	MEXICANO/NA	+52	ACTIVO	INSERCION/admin/2023-10-18 11:06:19.140873-03\rINACTIVACIONadmin/2023-10-18 11:08:23.267276-03\rACTIVACIONadmin/2023-10-18 11:08:25.46377-03\rMODIFICACIONadmin/2023-12-28 15:49:26.068388-03\rMODIFICACIONadmin/2023-12-28 15:49:28.06235-03\rMODIFICACIONadmin/2023-12-28 15:49:28.656253-03\rMODIFICACIONadmin/2023-12-28 15:49:28.844984-03\rMODIFICACIONadmin/2023-12-28 15:49:29.047909-03\rMODIFICACIONadmin/2023-12-28 15:49:29.251547-03\rMODIFICACIONadmin/2023-12-28 15:49:29.455337-03\rMODIFICACIONadmin/2023-12-28 15:49:29.668413-03\rMODIFICACIONadmin/2023-12-28 15:49:30.092568-03\rMODIFICACIONadmin/2023-12-28 15:49:30.269902-03\rMODIFICACIONadmin/2023-12-28 15:49:30.491186-03\rMODIFICACIONadmin/2023-12-28 15:49:30.850767-03\rMODIFICACIONadmin/2023-12-28 15:49:31.058526-03\rMODIFICACIONadmin/2023-12-28 15:51:24.210685-03\rMODIFICACIONadmin/2023-12-28 16:03:00.99465-03\rMODIFICACIONadmin/2023-12-28 16:08:20.595946-03\rMODIFICACIONadmin/2023-12-28 16:11:46.656046-03\rINACTIVACIONadmin/2023-12-28 16:12:16.262404-03\rACTIVACIONadmin/2023-12-28 16:12:24.551129-03\rINACTIVACIONadmin/2023-12-28 16:12:28.345001-03\rACTIVACIONadmin/2023-12-28 16:20:21.009112-03\rINACTIVACIONadmin/2023-12-28 16:20:26.1268-03\rACTIVACIONadmin/2023-12-28 16:20:30.648392-03\rINACTIVACIONadmin/2023-12-28 16:37:34.916085-03\rACTIVACIONadmin/2023-12-28 16:37:40.061249-03\rINACTIVACIONadmin/2023-12-28 16:37:53.050309-03\rACTIVACIONadmin/2023-12-28 16:38:08.098108-03\rINACTIVACIONadmin/2023-12-28 16:39:50.596389-03\rACTIVACIONadmin/2023-12-28 16:39:55.334168-03\rMODIFICACIONadmin/2023-12-28 16:40:02.601504-03\rINACTIVACIONadmin/2023-12-28 16:50:41.842002-03\rACTIVACIONadmin/2023-12-28 16:55:04.659313-03\rINACTIVACIONadmin/2023-12-28 16:55:08.088587-03\rACTIVACIONadmin/2023-12-28 16:55:22.630517-03\rINACTIVACIONadmin/2023-12-28 17:29:43.157924-03\rACTIVACIONadmin/2023-12-28 17:29:49.005395-03
\.


--
-- TOC entry 3845 (class 0 OID 18662)
-- Dependencies: 220
-- Data for Name: permisos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permisos (id_grupo, id_pagina, id_accion, estado, auditoria) FROM stdin;
1	1	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	2	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	3	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	4	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	5	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	6	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	7	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	8	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	9	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	10	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	11	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	12	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	13	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	14	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	15	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	16	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	17	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	18	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	19	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	20	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	21	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	22	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
2	1	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
2	2	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
2	3	1	ACTIVO	INSERCION/admin/2023-10-16 17:06:59.625562-03
1	23	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
1	24	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	1	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	2	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	3	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	8	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	15	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	22	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	23	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
3	24	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
\.


--
-- TOC entry 3864 (class 0 OID 19590)
-- Dependencies: 250
-- Data for Name: personal_trainers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_trainers (id_persona_trainer, id_funcionario, estado, auditoria) FROM stdin;
\.


--
-- TOC entry 3846 (class 0 OID 18667)
-- Dependencies: 221
-- Data for Name: personas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personas (id_persona, per_nombre, per_apellido, per_ruc, per_ci, per_direccion, per_correo, per_fenaci, per_telefono, persona_fisica, estado, auditoria, id_ciudad, id_ecivil, id_genero) FROM stdin;
2	JUAN	PEREZ	1234563-4	1234563	XXX-4321	juanperez@gmail.com	1996-09-02	0981432764	t	ACTIVO	INSERCION/admin/2023-10-31 16:59:03.174228-03	1	2	1
3	JOSE	GONZALES	3458987-2	3458987	XXX-4322	josegonzales@gmail.com	1993-06-23	0982345657	t	ACTIVO	INSERCION/admin/2023-10-31 16:59:03.174228-03	2	1	1
4	LORENA	MARTINEZ	7893645-5	7893645	XXX-3656	lorenamartinez@gmail.com	1998-04-20	0981256783	t	ACTIVO	INSERCION/admin/2023-10-31 16:59:03.174228-03	1	2	2
5	FERNANDO	RODRIGUEZ	6789345-3	6789345	XXX-2344	fernandorodriguez@gmail.com	1997-08-09	0982890765	t	ACTIVO	INSERCION/admin/2023-10-31 16:59:03.174228-03	1	1	1
1	MATIAS	MARTINEZ	6321987-0	6321987	XXX-2312	matiasmartinez@gmail.com	1995-11-04	0987234567	t	ACTIVO	INSERCION/admin/2023-10-31 16:59:03.174228-03\rINACTIVACIONadmin/2023-10-31 22:50:23.486386-03\rACTIVACIONadmin/2023-10-31 22:50:31.219195-03	1	1	1
6	PEDRO	LOPEZ	382378-0	382378	YYY-232	pedrolopez@gmail.com	2003-02-14		t	ACTIVO	INSERCION/admin/2023-11-08 14:35:37.154461-03	4	3	1
\.


--
-- TOC entry 3863 (class 0 OID 19578)
-- Dependencies: 249
-- Data for Name: planes_servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.planes_servicios (id_plan_servi, ps_descrip, precio_servicio, id_tip_impuesto, estado, auditoria) FROM stdin;
1	ACCESO COMPLETO	15000	1	ACTIVO	\N
2	CROSSFIT INTENSIVO	5000	1	ACTIVO	\N
3	ENTRENAMIENTO PERSONALIZADO	10000	1	ACTIVO	\N
4	NUTRICION	15000	1	ACTIVO	\N
5	ENTRENAMIENTO DE FUERZA	5000	1	ACTIVO	\N
\.


--
-- TOC entry 3856 (class 0 OID 19286)
-- Dependencies: 236
-- Data for Name: proveedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedores (id_proveedor, id_persona, estado, auditoria) FROM stdin;
1	3	ACTIVO	INSERCION/admin/2023-10-23 17:43:53.705517-03
2	4	ACTIVO	INSERCION/admin/2023-10-23 17:43:53.705517-03
\.


--
-- TOC entry 3865 (class 0 OID 19654)
-- Dependencies: 251
-- Data for Name: servicios_inscripciones_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.servicios_inscripciones_cabecera (id_inscrip, ins_fecha, ins_aprobacion, ins_estad_salud, id_sucursal, id_funcionario, id_cliente, estado, auditoria) FROM stdin;
1	2023-03-03	2023-10-27	--	1	1	1	CONFIRMADO	\rCONFIRMACION/admin/2023-10-27 18:20:09.713774-03
2	2023-10-27	2023-10-30	ssafd	1	1	1	CONFIRMADO	INSERCION/admin/2023-10-27 18:20:16.04138-03\rCONFIRMACION/admin/2023-10-30 19:08:53.549274-03
3	2023-10-30	2023-11-08		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-30 19:09:00.880603-03\rCONFIRMACION/usubeta/2023-11-08 21:01:27.965509-03
4	2023-11-08	2023-11-08		1	3	1	PENDIENTE	INSERCION/usubeta/2023-11-08 21:01:35.264309-03
\.


--
-- TOC entry 3866 (class 0 OID 19676)
-- Dependencies: 252
-- Data for Name: servicios_inscripciones_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.servicios_inscripciones_detalle (id_inscrip, id_plan_servi, dia, precio) FROM stdin;
1	1	1	15000
1	2	1	5000
2	2	1	5000
2	5	1	5000
2	3	1	10000
3	1	1	15000
4	1	1	15000
4	2	31	5000
4	4	1	15000
\.


--
-- TOC entry 3871 (class 0 OID 19983)
-- Dependencies: 265
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock (id_sucursal, id_item, stock_cantidad, estado) FROM stdin;
1	1	10	ACTIVO
\.


--
-- TOC entry 3847 (class 0 OID 18672)
-- Dependencies: 222
-- Data for Name: sucursales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sucursales (id_sucursal, suc_nombre, suc_direccion, suc_correo, suc_telefono, suc_ubicacion, suc_imagen, estado, auditoria, id_empresa) FROM stdin;
1	CASA MATRIZ	calle san roque	energym@gmail.com	0981000000	xy	/tesis/imagenes/sucursales/1.jpg	ACTIVO	\N	1
2	ÑEMBY	calle san roque	energym@gmail.com	0981000000	xy	/tesis/imagenes/sucursales/2.jpg	ACTIVO	\N	1
3	FERNANDO DE LA MORA	calle san roque	energym@gmail.com	0981000000	xy	/tesis/imagenes/sucursales/3.jpg	ACTIVO	\N	1
\.


--
-- TOC entry 3853 (class 0 OID 19215)
-- Dependencies: 231
-- Data for Name: tipos_impuestos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipos_impuestos (id_tip_impuesto, tip_imp_descrip, tip_imp_tasa, tip_imp_tasa2, estado, auditoria) FROM stdin;
1	IVA	0.05	0.1	ACTIVO	INSERCION/admin/2023-10-20 19:23:49.424839-03
2	EXENTO	0	0	ACTIVO	INSERCION/admin/2023-10-20 19:23:49.424839-03
\.


--
-- TOC entry 3851 (class 0 OID 19138)
-- Dependencies: 229
-- Data for Name: tipos_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipos_items (id_tip_item, tip_item_descrip, estado, auditoria) FROM stdin;
4	TOALLA	ACTIVO	INSERCION/admin/2023-10-20 19:03:29.462907-03
1	SUPLEMENTO	ACTIVO	INSERCION/admin/2023-10-20 19:03:29.462907-03
3	GUANTE 	ACTIVO	INSERCION/admin/2023-10-20 19:03:29.462907-03
5	BEBIDAS	ACTIVO	INSERCION/admin/2023-10-20 19:03:29.462907-03
6	REFRIGERIO	ACTIVO	INSERCION/admin/2023-10-20 19:03:29.462907-03
\.


--
-- TOC entry 3848 (class 0 OID 18677)
-- Dependencies: 223
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id_usuario, usu_login, usu_contrasena, usu_imagen, estado, auditoria, id_funcionario, id_grupo, id_sucursal) FROM stdin;
1	admin	202cb962ac59075b964b07152d234b70	/tesis/imagenes/usuarios/1.png	ACTIVO	\N	1	1	1
2	juanp	202cb962ac59075b964b07152d234b70	/tesis/imagenes/usuarios/2.png	ACTIVO	\N	2	2	2
3	usubeta	202cb962ac59075b964b07152d234b70	/tesis/imagenes/usuarios/3.png	ACTIVO	\N	3	3	1
\.


--
-- TOC entry 3849 (class 0 OID 18682)
-- Dependencies: 224
-- Data for Name: usuarios_sucursales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios_sucursales (id_usuario, id_sucursal, estado, auditoria) FROM stdin;
\.


--
-- TOC entry 3861 (class 0 OID 19511)
-- Dependencies: 245
-- Data for Name: ventas_pedidos_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas_pedidos_cabecera (id_vped, vped_fecha, vped_aprobacion, vped_observacion, id_sucursal, id_funcionario, id_cliente, estado, auditoria) FROM stdin;
1	2023-03-03	2023-03-03	--	1	1	1	CONFIRMADO	\rCONFIRMACION/admin/2023-10-26 19:45:24.303321-03
2	2023-10-26	2023-10-26	N/A	1	1	1	ANULADO	INSERCION/admin/2023-10-26 19:45:37.497158-03\rANULACION/admin/2023-10-26 19:54:34.402059-03
3	2023-10-27	2023-10-27		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-27 21:41:26.74757-03\rCONFIRMACION/usubeta/2023-11-08 21:04:29.939857-03
4	2023-11-08	2023-11-08		1	3	1	PENDIENTE	INSERCION/usubeta/2023-11-08 21:04:35.504479-03
\.


--
-- TOC entry 3862 (class 0 OID 19533)
-- Dependencies: 246
-- Data for Name: ventas_pedidos_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas_pedidos_detalle (id_vped, id_item, cantidad, precio) FROM stdin;
1	1	2	12000
2	6	1	12500
3	4	1	170000
\.


--
-- TOC entry 3525 (class 2606 OID 18688)
-- Name: acciones acciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.acciones
    ADD CONSTRAINT acciones_pkey PRIMARY KEY (id_accion);


--
-- TOC entry 3527 (class 2606 OID 18690)
-- Name: cargos cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cargos
    ADD CONSTRAINT cargos_pkey PRIMARY KEY (id_cargo);


--
-- TOC entry 3529 (class 2606 OID 18692)
-- Name: ciudades ciudades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_pkey PRIMARY KEY (id_ciudad);


--
-- TOC entry 3577 (class 2606 OID 19468)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 3603 (class 2606 OID 20013)
-- Name: compras_cabecera compras_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_pkey PRIMARY KEY (id_cc);


--
-- TOC entry 3605 (class 2606 OID 20080)
-- Name: compras_detalle compras_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_detalle
    ADD CONSTRAINT compras_detalle_pkey PRIMARY KEY (id_cc, id_item);


--
-- TOC entry 3591 (class 2606 OID 19795)
-- Name: compras_orden_cabecera compras_orden_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_pkey PRIMARY KEY (id_corden);


--
-- TOC entry 3593 (class 2606 OID 19815)
-- Name: compras_orden_detalle compras_orden_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_detalle
    ADD CONSTRAINT compras_orden_detalle_pkey PRIMARY KEY (id_corden, id_item);


--
-- TOC entry 3607 (class 2606 OID 20095)
-- Name: compras_orden compras_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_pkey PRIMARY KEY (id_cc, id_corden, id_item);


--
-- TOC entry 3595 (class 2606 OID 19933)
-- Name: compras_orden_presu compras_orden_presu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_presu
    ADD CONSTRAINT compras_orden_presu_pkey PRIMARY KEY (id_corden, id_cpre, id_item);


--
-- TOC entry 3561 (class 2606 OID 19173)
-- Name: compras_pedidos_cabecera compras_pedidos_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_cabecera
    ADD CONSTRAINT compras_pedidos_cabecera_pkey PRIMARY KEY (id_cp);


--
-- TOC entry 3567 (class 2606 OID 19248)
-- Name: compras_pedidos_detalles compras_pedidos_detalles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_detalles
    ADD CONSTRAINT compras_pedidos_detalles_pkey PRIMARY KEY (id_cp, id_item);


--
-- TOC entry 3571 (class 2606 OID 19377)
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_pkey PRIMARY KEY (id_cpre);


--
-- TOC entry 3573 (class 2606 OID 19397)
-- Name: compras_presupuestos_detalle compras_presupuestos_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_detalle
    ADD CONSTRAINT compras_presupuestos_detalle_pkey PRIMARY KEY (id_cpre, id_item);


--
-- TOC entry 3575 (class 2606 OID 19412)
-- Name: compras_presupuestos_pedidos compras_presupuestos_pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_pedidos
    ADD CONSTRAINT compras_presupuestos_pedidos_pkey PRIMARY KEY (id_cpre, id_cp, id_item);


--
-- TOC entry 3597 (class 2606 OID 19977)
-- Name: deposito deposito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposito
    ADD CONSTRAINT deposito_pkey PRIMARY KEY (id_sucursal);


--
-- TOC entry 3531 (class 2606 OID 18694)
-- Name: empresas empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_pkey PRIMARY KEY (id_empresa);


--
-- TOC entry 3533 (class 2606 OID 18696)
-- Name: estado_civiles estado_civiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_civiles
    ADD CONSTRAINT estado_civiles_pkey PRIMARY KEY (id_ecivil);


--
-- TOC entry 3535 (class 2606 OID 18698)
-- Name: funcionarios funcionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_pkey PRIMARY KEY (id_funcionario);


--
-- TOC entry 3537 (class 2606 OID 18700)
-- Name: generos generos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generos
    ADD CONSTRAINT generos_pkey PRIMARY KEY (id_genero);


--
-- TOC entry 3539 (class 2606 OID 18702)
-- Name: grupos grupos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_pkey PRIMARY KEY (id_grupo);


--
-- TOC entry 3565 (class 2606 OID 19228)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id_item);


--
-- TOC entry 3557 (class 2606 OID 18952)
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id_mar);


--
-- TOC entry 3541 (class 2606 OID 18704)
-- Name: modulos modulos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modulos
    ADD CONSTRAINT modulos_pkey PRIMARY KEY (id_modulo);


--
-- TOC entry 3543 (class 2606 OID 18706)
-- Name: paginas paginas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginas
    ADD CONSTRAINT paginas_pkey PRIMARY KEY (id_pagina);


--
-- TOC entry 3545 (class 2606 OID 18708)
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (id_pais);


--
-- TOC entry 3547 (class 2606 OID 18710)
-- Name: permisos permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id_grupo, id_pagina, id_accion);


--
-- TOC entry 3585 (class 2606 OID 19596)
-- Name: personal_trainers personal_trainers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_trainers
    ADD CONSTRAINT personal_trainers_pkey PRIMARY KEY (id_persona_trainer);


--
-- TOC entry 3549 (class 2606 OID 18712)
-- Name: personas personas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_pkey PRIMARY KEY (id_persona);


--
-- TOC entry 3583 (class 2606 OID 19584)
-- Name: planes_servicios planes_servicios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_servicios
    ADD CONSTRAINT planes_servicios_pkey PRIMARY KEY (id_plan_servi);


--
-- TOC entry 3569 (class 2606 OID 19292)
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (id_proveedor);


--
-- TOC entry 3587 (class 2606 OID 19660)
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_pkey PRIMARY KEY (id_inscrip);


--
-- TOC entry 3589 (class 2606 OID 19680)
-- Name: servicios_inscripciones_detalle servicios_inscripciones_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_detalle
    ADD CONSTRAINT servicios_inscripciones_detalle_pkey PRIMARY KEY (id_inscrip, id_plan_servi);


--
-- TOC entry 3599 (class 2606 OID 19987)
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id_sucursal, id_item);


--
-- TOC entry 3551 (class 2606 OID 18714)
-- Name: sucursales sucursales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursales
    ADD CONSTRAINT sucursales_pkey PRIMARY KEY (id_sucursal);


--
-- TOC entry 3563 (class 2606 OID 19221)
-- Name: tipos_impuestos tipos_impuestos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_impuestos
    ADD CONSTRAINT tipos_impuestos_pkey PRIMARY KEY (id_tip_impuesto);


--
-- TOC entry 3559 (class 2606 OID 19144)
-- Name: tipos_items tipos_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_items
    ADD CONSTRAINT tipos_items_pkey PRIMARY KEY (id_tip_item);


--
-- TOC entry 3601 (class 2606 OID 20075)
-- Name: stock uk_id_item; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT uk_id_item UNIQUE (id_item);


--
-- TOC entry 3553 (class 2606 OID 18716)
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- TOC entry 3555 (class 2606 OID 18718)
-- Name: usuarios_sucursales usuarios_sucursales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_sucursales
    ADD CONSTRAINT usuarios_sucursales_pkey PRIMARY KEY (id_usuario, id_sucursal);


--
-- TOC entry 3579 (class 2606 OID 19517)
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_pkey PRIMARY KEY (id_vped);


--
-- TOC entry 3581 (class 2606 OID 19537)
-- Name: ventas_pedidos_detalle ventas_pedidos_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_detalle
    ADD CONSTRAINT ventas_pedidos_detalle_pkey PRIMARY KEY (id_vped, id_item);


--
-- TOC entry 3608 (class 2606 OID 18719)
-- Name: ciudades ciudades_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.paises(id_pais);


--
-- TOC entry 3639 (class 2606 OID 19469)
-- Name: clientes clientes_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.personas(id_persona);


--
-- TOC entry 3662 (class 2606 OID 20019)
-- Name: compras_cabecera compras_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3663 (class 2606 OID 20024)
-- Name: compras_cabecera compras_cabecera_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- TOC entry 3664 (class 2606 OID 20014)
-- Name: compras_cabecera compras_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3665 (class 2606 OID 20081)
-- Name: compras_detalle compras_detalle_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_detalle
    ADD CONSTRAINT compras_detalle_id_cc_fkey FOREIGN KEY (id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- TOC entry 3666 (class 2606 OID 20086)
-- Name: compras_detalle compras_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_detalle
    ADD CONSTRAINT compras_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.stock(id_item);


--
-- TOC entry 3652 (class 2606 OID 19801)
-- Name: compras_orden_cabecera compras_orden_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3653 (class 2606 OID 19806)
-- Name: compras_orden_cabecera compras_orden_cabecera_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- TOC entry 3654 (class 2606 OID 19796)
-- Name: compras_orden_cabecera compras_orden_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3655 (class 2606 OID 19816)
-- Name: compras_orden_detalle compras_orden_detalle_id_corden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_detalle
    ADD CONSTRAINT compras_orden_detalle_id_corden_fkey FOREIGN KEY (id_corden) REFERENCES public.compras_orden_cabecera(id_corden);


--
-- TOC entry 3656 (class 2606 OID 19821)
-- Name: compras_orden_detalle compras_orden_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_detalle
    ADD CONSTRAINT compras_orden_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- TOC entry 3667 (class 2606 OID 20096)
-- Name: compras_orden compras_orden_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_id_cc_fkey FOREIGN KEY (id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- TOC entry 3668 (class 2606 OID 20106)
-- Name: compras_orden compras_orden_id_corden_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_id_corden_id_item_fkey FOREIGN KEY (id_corden, id_item) REFERENCES public.compras_orden_detalle(id_corden, id_item);


--
-- TOC entry 3669 (class 2606 OID 20101)
-- Name: compras_orden compras_orden_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.stock(id_item);


--
-- TOC entry 3657 (class 2606 OID 19934)
-- Name: compras_orden_presu compras_orden_presu_id_corden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_presu
    ADD CONSTRAINT compras_orden_presu_id_corden_fkey FOREIGN KEY (id_corden) REFERENCES public.compras_orden_cabecera(id_corden);


--
-- TOC entry 3658 (class 2606 OID 19939)
-- Name: compras_orden_presu compras_orden_presu_id_cpre_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_presu
    ADD CONSTRAINT compras_orden_presu_id_cpre_id_item_fkey FOREIGN KEY (id_cpre, id_item) REFERENCES public.compras_presupuestos_detalle(id_cpre, id_item);


--
-- TOC entry 3625 (class 2606 OID 19179)
-- Name: compras_pedidos_cabecera compras_pedidos_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_cabecera
    ADD CONSTRAINT compras_pedidos_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3624 (class 2606 OID 19174)
-- Name: compras_pedidos_cabecera compras_pedidos_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_cabecera
    ADD CONSTRAINT compras_pedidos_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3629 (class 2606 OID 19249)
-- Name: compras_pedidos_detalles compras_pedidos_detalles_id_cp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_detalles
    ADD CONSTRAINT compras_pedidos_detalles_id_cp_fkey FOREIGN KEY (id_cp) REFERENCES public.compras_pedidos_cabecera(id_cp);


--
-- TOC entry 3630 (class 2606 OID 19254)
-- Name: compras_pedidos_detalles compras_pedidos_detalles_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_detalles
    ADD CONSTRAINT compras_pedidos_detalles_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- TOC entry 3633 (class 2606 OID 19383)
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3634 (class 2606 OID 19388)
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- TOC entry 3632 (class 2606 OID 19378)
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3635 (class 2606 OID 19398)
-- Name: compras_presupuestos_detalle compras_presupuestos_detalle_id_cpre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_detalle
    ADD CONSTRAINT compras_presupuestos_detalle_id_cpre_fkey FOREIGN KEY (id_cpre) REFERENCES public.compras_presupuestos_cabecera(id_cpre);


--
-- TOC entry 3636 (class 2606 OID 19403)
-- Name: compras_presupuestos_detalle compras_presupuestos_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_detalle
    ADD CONSTRAINT compras_presupuestos_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- TOC entry 3638 (class 2606 OID 19418)
-- Name: compras_presupuestos_pedidos compras_presupuestos_pedidos_id_cp_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_pedidos
    ADD CONSTRAINT compras_presupuestos_pedidos_id_cp_id_item_fkey FOREIGN KEY (id_cp, id_item) REFERENCES public.compras_pedidos_detalles(id_cp, id_item);


--
-- TOC entry 3637 (class 2606 OID 19413)
-- Name: compras_presupuestos_pedidos compras_presupuestos_pedidos_id_cpre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_pedidos
    ADD CONSTRAINT compras_presupuestos_pedidos_id_cpre_fkey FOREIGN KEY (id_cpre) REFERENCES public.compras_presupuestos_cabecera(id_cpre);


--
-- TOC entry 3659 (class 2606 OID 19978)
-- Name: deposito deposito_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposito
    ADD CONSTRAINT deposito_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3609 (class 2606 OID 18724)
-- Name: funcionarios funcionarios_id_cargo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_id_cargo_fkey FOREIGN KEY (id_cargo) REFERENCES public.cargos(id_cargo);


--
-- TOC entry 3610 (class 2606 OID 18729)
-- Name: funcionarios funcionarios_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.personas(id_persona);


--
-- TOC entry 3626 (class 2606 OID 19229)
-- Name: items items_id_mar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_mar_fkey FOREIGN KEY (id_mar) REFERENCES public.marcas(id_mar);


--
-- TOC entry 3628 (class 2606 OID 19239)
-- Name: items items_id_tip_impuesto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_tip_impuesto_fkey FOREIGN KEY (id_tip_impuesto) REFERENCES public.tipos_impuestos(id_tip_impuesto);


--
-- TOC entry 3627 (class 2606 OID 19234)
-- Name: items items_id_tip_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_tip_item_fkey FOREIGN KEY (id_tip_item) REFERENCES public.tipos_items(id_tip_item);


--
-- TOC entry 3611 (class 2606 OID 18734)
-- Name: paginas paginas_id_modulo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginas
    ADD CONSTRAINT paginas_id_modulo_fkey FOREIGN KEY (id_modulo) REFERENCES public.modulos(id_modulo);


--
-- TOC entry 3612 (class 2606 OID 18739)
-- Name: permisos permisos_id_accion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_accion_fkey FOREIGN KEY (id_accion) REFERENCES public.acciones(id_accion);


--
-- TOC entry 3613 (class 2606 OID 18744)
-- Name: permisos permisos_id_grupo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_grupo_fkey FOREIGN KEY (id_grupo) REFERENCES public.grupos(id_grupo);


--
-- TOC entry 3614 (class 2606 OID 18749)
-- Name: permisos permisos_id_pagina_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_pagina_fkey FOREIGN KEY (id_pagina) REFERENCES public.paginas(id_pagina);


--
-- TOC entry 3646 (class 2606 OID 19597)
-- Name: personal_trainers personal_trainers_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_trainers
    ADD CONSTRAINT personal_trainers_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3615 (class 2606 OID 18754)
-- Name: personas personas_id_ciudad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_id_ciudad_fkey FOREIGN KEY (id_ciudad) REFERENCES public.ciudades(id_ciudad);


--
-- TOC entry 3616 (class 2606 OID 18759)
-- Name: personas personas_id_ecivil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_id_ecivil_fkey FOREIGN KEY (id_ecivil) REFERENCES public.estado_civiles(id_ecivil);


--
-- TOC entry 3617 (class 2606 OID 18764)
-- Name: personas personas_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.generos(id_genero);


--
-- TOC entry 3645 (class 2606 OID 19585)
-- Name: planes_servicios planes_servicios_id_tip_impuesto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_servicios
    ADD CONSTRAINT planes_servicios_id_tip_impuesto_fkey FOREIGN KEY (id_tip_impuesto) REFERENCES public.tipos_impuestos(id_tip_impuesto);


--
-- TOC entry 3631 (class 2606 OID 19293)
-- Name: proveedores proveedores_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.personas(id_persona);


--
-- TOC entry 3647 (class 2606 OID 19671)
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- TOC entry 3648 (class 2606 OID 19666)
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3649 (class 2606 OID 19661)
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3650 (class 2606 OID 19681)
-- Name: servicios_inscripciones_detalle servicios_inscripciones_detalle_id_inscrip_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_detalle
    ADD CONSTRAINT servicios_inscripciones_detalle_id_inscrip_fkey FOREIGN KEY (id_inscrip) REFERENCES public.servicios_inscripciones_cabecera(id_inscrip);


--
-- TOC entry 3651 (class 2606 OID 19686)
-- Name: servicios_inscripciones_detalle servicios_inscripciones_detalle_id_plan_servi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_detalle
    ADD CONSTRAINT servicios_inscripciones_detalle_id_plan_servi_fkey FOREIGN KEY (id_plan_servi) REFERENCES public.planes_servicios(id_plan_servi);


--
-- TOC entry 3660 (class 2606 OID 19993)
-- Name: stock stock_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- TOC entry 3661 (class 2606 OID 19988)
-- Name: stock stock_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.deposito(id_sucursal);


--
-- TOC entry 3618 (class 2606 OID 18769)
-- Name: sucursales sucursales_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursales
    ADD CONSTRAINT sucursales_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa);


--
-- TOC entry 3619 (class 2606 OID 18774)
-- Name: usuarios usuarios_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3620 (class 2606 OID 18779)
-- Name: usuarios usuarios_id_grupo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_grupo_fkey FOREIGN KEY (id_grupo) REFERENCES public.grupos(id_grupo);


--
-- TOC entry 3621 (class 2606 OID 18784)
-- Name: usuarios usuarios_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3622 (class 2606 OID 18789)
-- Name: usuarios_sucursales usuarios_sucursales_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_sucursales
    ADD CONSTRAINT usuarios_sucursales_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3623 (class 2606 OID 18794)
-- Name: usuarios_sucursales usuarios_sucursales_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_sucursales
    ADD CONSTRAINT usuarios_sucursales_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- TOC entry 3640 (class 2606 OID 19528)
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- TOC entry 3641 (class 2606 OID 19523)
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3642 (class 2606 OID 19518)
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- TOC entry 3643 (class 2606 OID 19543)
-- Name: ventas_pedidos_detalle ventas_pedidos_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_detalle
    ADD CONSTRAINT ventas_pedidos_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- TOC entry 3644 (class 2606 OID 19538)
-- Name: ventas_pedidos_detalle ventas_pedidos_detalle_id_vped_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_detalle
    ADD CONSTRAINT ventas_pedidos_detalle_id_vped_fkey FOREIGN KEY (id_vped) REFERENCES public.ventas_pedidos_cabecera(id_vped);


-- Completed on 2024-03-10 15:31:36 -03

--
-- PostgreSQL database dump complete
--

