--
-- PostgreSQL database dump
--

-- Dumped from database version 10.23
-- Dumped by pg_dump version 10.23

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: estados; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.estados AS ENUM (
    'ACTIVO',
    'INACTIVO',
    'PENDIENTE',
    'CONFIRMADO',
    'ANULADO',
    'ABIERTO',
    'CERRADO',
    'VENCIDO'
);


ALTER TYPE public.estados OWNER TO postgres;

--
-- Name: sp_acceso(integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_acceso(xid_acceso integer, xid_usuario integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
   select * from accesos;
  if operacion = 1 then 
  insert into accesos (id_acceso, id_usuario, estado, auditoria)
  values(
  (SELECT COALESCE(MAX(id_acceso), 0) + 1 FROM accesos),
  xid_usuario,
  'ACTIVO',
  'INSERCION/' || usuario || '/' || NOW());
 
 elseif operacion = 2 then
 update accesos 
 set id_usuario = xid_usuario
where id_acceso = xid_acceso;
raise notice 'ACCESO MODIFICADO CON ÉXITO';

elseif operacion = 3 then 
delete from accesos 
where id_acceso = xid_acceso;
raise notice 'ACCESO ELIMINADO CON ÉXITO';
end if;
END;
$$;


ALTER FUNCTION public.sp_acceso(xid_acceso integer, xid_usuario integer, usuario character varying, operacion integer) OWNER TO postgres;

--
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
-- Name: sp_compras(integer, date, integer, character varying, character varying, character varying, integer, numeric, numeric, numeric, numeric, numeric, integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_compras(xid_cc integer, xcc_fecha date, xcc_intervalo integer, xcc_nro_factura character varying, xcc_timbrado character varying, xcc_tipo_factura character varying, xcc_cuota integer, xiva5 numeric, xiva10 numeric, xexenta numeric, xmonto numeric, xsaldo numeric, xid_sucursal integer, xid_deposito integer, xid_funcionario integer, xid_proveedor integer, xid_item integer, xcantidad integer, xprecio integer, xid_corden integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
   v_cantidad int;
BEGIN 
    IF operacion = 1 THEN 
    	--INCERTAR CABECERA--
        INSERT INTO compras_cabecera (id_cc,cc_fecha,cc_tipo_factura,cc_cuota,id_sucursal,id_funcionario,id_proveedor,estado,auditoria,cc_intervalo, cc_nro_factura, cc_timbrado)
        VALUES (
            (SELECT COALESCE(MAX(id_cc), 0) + 1 FROM compras_cabecera),
            xcc_fecha,
            UPPER(TRIM(xcc_tipo_factura)),
            xcc_cuota,
            xid_sucursal,
            xid_funcionario,
            xid_proveedor,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW(),
            xcc_intervalo,
            xcc_nro_factura,
            xcc_timbrado
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN 
    -- MODIFICAR CABECERA --
        UPDATE compras_cabecera
        SET cc_fecha = xcc_fecha,
            cc_tipo_factura = UPPER(TRIM(xcc_tipo_factura)),
            cc_cuota = xcc_cuota,
            id_proveedor = xid_proveedor,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW(),
            cc_intervalo = xcc_intervalo,
            cc_nro_factura = xcc_nro_factura,
            cc_timbrado = xcc_timbrado
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
    
    select stock_cantidad into v_cantidad from stock where id_sucursal = xid_deposito AND id_item = xid_item;
    -- ACTUALIZAR STOCK
	    IF EXISTS (
	        SELECT 1
	        FROM stock
	        WHERE id_sucursal = xid_deposito AND id_item = xid_item
	    ) THEN
	        -- Actualizar stock sumando la cantidad
	        UPDATE stock
	        SET stock_cantidad = v_cantidad + xcantidad
	        WHERE id_sucursal = xid_deposito AND id_item = xid_item;
	    ELSE
	        -- Insertar un nuevo registro en stock
	        INSERT INTO stock (id_sucursal, id_item, stock_cantidad, estado)
	        VALUES (xid_deposito, xid_item, xcantidad, 'ACTIVO');
	    END IF;
    
	   
	  		-- INSERTAR DETALLES
        INSERT INTO compras_detalle (id_cc, id_item, cantidad, precio)
        VALUES (xid_cc, xid_item, xcantidad, xprecio);
       
	     
	   
	    RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       --insert into stock(id_sucursal)values(1);
       --select  sp_control_stock (xid_deposito, xid_item, xcantidad, 1);

        

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
            VALUES (xid_cc, d.id_corden, d.id_item, d.sum, d.precio);
           
           --ACTUALIZAR STOCK
       --select  sp_control_stock (xid_deposito, d.id_item, d.cantidad, 1);
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
        VALUES (xid_cc,xid_corden, xid_item, d.sum, d.precio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 11 THEN 
    	--ELIMINAR PROCESO CONECTADO
       
        DELETE FROM compras_orden
        WHERE id_item = xid_item;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
       
    ELSIF operacion = 12 THEN 
    	---------------------------------------------------------------------------------------------------------------------------------
       --INSERTAR LIBRO DE COMPRAS
       insert into libro_compras (lib_id_cc, lib_iva5,lib_iva10,lib_exenta,estado, auditoria)
       values(xid_cc,xiva5,xiva10,xexenta, 'PENDIENTE',
       'INSERCION/' || usuario || '/' || NOW());	 
       
      --INSERTAR CUENTA A PAGAR
        INSERT INTO comp_cuentas_pagar (cue_id_cc, cue_fecha, cue_monto, cue_saldo, estado, auditoria)
        VALUES (xid_cc, xcc_fecha, xmonto, xsaldo, 'PENDIENTE', 
       'INSERCION/' || usuario || '/' || NOW());
      RAISE NOTICE 'CUENTA Y LIBRO DE COMPRA GENERADO CON CON ÉXITO';
   ----------------------------------------------------------------------------------------------------------------------------------
    END IF;
END;
$$;


ALTER FUNCTION public.sp_compras(xid_cc integer, xcc_fecha date, xcc_intervalo integer, xcc_nro_factura character varying, xcc_timbrado character varying, xcc_tipo_factura character varying, xcc_cuota integer, xiva5 numeric, xiva10 numeric, xexenta numeric, xmonto numeric, xsaldo numeric, xid_sucursal integer, xid_deposito integer, xid_funcionario integer, xid_proveedor integer, xid_item integer, xcantidad integer, xprecio integer, xid_corden integer, usuario character varying, operacion integer) OWNER TO postgres;

--
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
-- Name: sp_control_impuestos(text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_control_impuestos(xnombre_movimiento text, xid_movimiento_nomb text, xid_movimiento integer) RETURNS TABLE(id_movimiento integer, id_item integer, cantidad integer, precio integer, item_descrip character varying, id_tip_impuesto integer, subtotal integer, exenta integer, iva5 numeric, iva10 numeric, totaliva numeric, totalgral numeric, total numeric)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT cpd.%I AS id_movimiento,
                cpd.id_item,
                cpd.cantidad,
                cpd.precio,
                i.item_descrip,
                ti.id_tip_impuesto,
                cpd.cantidad * cpd.precio as subtotal,
                CASE WHEN ti.tip_imp_tasa = 0 THEN cpd.cantidad * cpd.precio ELSE 0 END as exenta,
                cpd.cantidad * cpd.precio * ti.tip_imp_tasa as iva5,
                cpd.cantidad * cpd.precio * ti.tip_imp_tasa2 as iva10,
                (cpd.cantidad * cpd.precio * ti.tip_imp_tasa + cpd.cantidad * cpd.precio * ti.tip_imp_tasa2) as totaliva,
                (CASE WHEN ti.tip_imp_tasa = 0 THEN cpd.cantidad * cpd.precio ELSE 0 END + cpd.cantidad * cpd.precio * ti.tip_imp_tasa + cpd.cantidad * cpd.precio * ti.tip_imp_tasa2) as totalGral,
                (cpd.cantidad * cpd.precio + cpd.cantidad * cpd.precio * ti.tip_imp_tasa + cpd.cantidad * cpd.precio * ti.tip_imp_tasa2) as total
         FROM %I cpd
         JOIN items i ON i.id_item = cpd.id_item
         JOIN tipos_impuestos ti ON ti.id_tip_impuesto = i.id_tip_impuesto
         WHERE cpd.%I = $1',
        xid_movimiento_nomb, 
        xnombre_movimiento, 
        xid_movimiento_nomb
    ) USING xid_movimiento;
END;
$_$;


ALTER FUNCTION public.sp_control_impuestos(xnombre_movimiento text, xid_movimiento_nomb text, xid_movimiento integer) OWNER TO postgres;

--
-- Name: sp_control_stock(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_control_stock(xid_deposito integer, xid_item integer, xcantidad integer, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    c INTEGER;
BEGIN 
    SELECT stock_cantidad INTO c FROM stock s WHERE id_item = xid_item;
   IF operacion = 1 THEN -- ACTUALIZAR STOCK EN COMPRAS
       insert into stock (id_sucursal,id_item,stock_cantidad,estado)
       values(xid_deposito, xid_item, xcantidad, 'ACTIVO');
   
    elseif operacion = 2 THEN -- ACTUALIZAR STOCK EN COMPRAS
        UPDATE stock
        SET id_sucursal =xid_sucursal,  
        stock_cantidad = c + xcantidad
        WHERE id_item = xid_item and id_sucursal = xid_sucursal;

    ELSIF operacion = 3 THEN  -- ACTUALIZAR STOCK EN VENTAS
        IF c <= 0 THEN
            RAISE EXCEPTION 'No hay suficiente stock para vender';
        END IF;
        
        UPDATE stock
        SET stock_cantidad = c - ABS(xcantidad)
        WHERE id_item = xid_item;
    END IF;
END
$$;


ALTER FUNCTION public.sp_control_stock(xid_deposito integer, xid_item integer, xcantidad integer, operacion integer) OWNER TO postgres;

--
-- Name: sp_membresias(integer, date, date, text, integer, integer, integer, integer, integer, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_membresias(xid_mem integer, xmem_fecha date, xmem_vence date, xmem_observacion text, xid_sucursal integer, xid_funcionario integer, xid_cliente integer, xid_plan_servi integer, xdias integer, xprecio integer, xid_inscrip integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN 
    	--INCERTAR CABECERA--
        INSERT INTO serv_membresias_cab (id_mem,mem_fecha,mem_vence,mem_observacion,id_cliente,id_sucursal,id_funcionario,estado,auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_mem), 0) + 1 FROM serv_membresias_cab),
            xmem_fecha,
            xmem_vence,
            xmem_observacion,
            xid_cliente,
            xid_sucursal,
            xid_funcionario,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN 
    -- MODIFICAR CABECERA --
        UPDATE serv_membresias_cab
        SET mem_fecha = xmem_fecha,
        	mem_vence = xmem_vence,
            mem_observacion = xmem_observacion,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_mem = xid_mem;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN 
    -- CONFIRMAR CABECERA
        UPDATE serv_membresias_cab
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_mem = xid_mem;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
    ELSIF operacion = 4 THEN 
    -- ANULAR CABECERA
        UPDATE serv_membresias_cab
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_mem = xid_mem;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
       
    ELSIF operacion = 5 THEN 

	  		-- INSERTAR DETALLES
        INSERT INTO serv_membresias_det (id_mem, id_plan_servi, dias, precio, auditoria)
        VALUES (xid_mem, xid_plan_servi, xdias, xprecio,
       'INSERCION/' || usuario || '/' || NOW());
	    RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       

    ELSIF operacion = 6 THEN 
    -- MODIFICAR DETALLE --
        UPDATE serv_membresias_det
        SET dias = dias, precio = xprecio,
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_mem = xid_mem AND id_plan_servi = xid_plan_servi;
        RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN 
    -- ELIMINAR DETALLE
    DELETE FROM serv_membresias_det
        WHERE id_mem = Xid_mem AND id_plan_servi = xid_plan_servi;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
       
    ELSIF operacion = 8 THEN 
    --AUTOMATISACION DE INSERCION PROCESO CONECTADO
     FOR d IN SELECT * FROM v_servicios_inscripciones_detalle  WHERE id_inscrip = xid_inscrip LOOP
            INSERT INTO serv_inscripciones_membresias(id_mem,id_inscrip,id_plan_servi,dias,precio)
            VALUES (xid_mem, d.xid_inscrip, d.xid_plan_servi, d.dias, d.precio);
           
        END LOOP;
       
        RAISE NOTICE 'PEDIDO AÑADIDOS CON ÉXITO Y CERRADO';
       
    ELSIF operacion = 9 THEN 
    --MODIFICAR PROCESO CONECTADO
        UPDATE serv_inscripciones_membresias
        SET cantidad = xcantidad, precio = xprecio
        WHERE id_mem = xid_mem AND id_inscrip = xid_inscrip and dias= xdias ;
       RAISE NOTICE 'PRODUCTO MODIFICADO CON ÉXITO';
      
    ELSIF operacion = 10 THEN 
    --RECTIFICAR INSERCION POR ELIMINACION ERRONEA
    	SELECT * INTO d FROM v_servicios_inscripciones_detalle WHERE id_inscrip = xid_inscrip AND id_plan_servi = xid_plan_servi;
        INSERT INTO serv_inscripciones_membresias (id_mem,id_inscrip,id_plan_servi,dias,precio)
        VALUES (xid_mem,xid_inscrip, xid_plan_servi, d.dias, d.precio);
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
       
       
    ELSIF operacion = 11 THEN 
    	--ELIMINAR PROCESO CONECTADO
       
        DELETE FROM serv_inscripciones_membresias
        WHERE id_plan_servi = xid_plan_servi;
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
       
    ELSIF operacion = 12 THEN 
    	 --MOVIMIENTOS VENCIDOS
    	    update serv_membresias_cab
    	    set estado = 'VENCIDO'
    	    where mem_vence < CURRENT_DATE;
   
    END IF;
END;
$$;


ALTER FUNCTION public.sp_membresias(xid_mem integer, xmem_fecha date, xmem_vence date, xmem_observacion text, xid_sucursal integer, xid_funcionario integer, xid_cliente integer, xid_plan_servi integer, xdias integer, xprecio integer, xid_inscrip integer, usuario character varying, operacion integer) OWNER TO postgres;

--
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

SET default_with_oids = false;

--
-- Name: accesos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accesos (
    id_acceso integer NOT NULL,
    id_usuario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.accesos OWNER TO postgres;

--
-- Name: acciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.acciones (
    id_accion integer NOT NULL,
    ac_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.acciones OWNER TO postgres;

--
-- Name: auth_2fa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_2fa (
    id integer NOT NULL,
    id_usuario integer,
    codigo integer NOT NULL,
    fecha_expiracion timestamp without time zone NOT NULL,
    usado boolean DEFAULT false
);


ALTER TABLE public.auth_2fa OWNER TO postgres;

--
-- Name: auth_2fa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_2fa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_2fa_id_seq OWNER TO postgres;

--
-- Name: auth_2fa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_2fa_id_seq OWNED BY public.auth_2fa.id;


--
-- Name: cargos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cargos (
    id_cargo integer NOT NULL,
    car_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.cargos OWNER TO postgres;

--
-- Name: ciudades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ciudades (
    id_ciudad integer NOT NULL,
    ciu_descrip character varying,
    estado public.estados,
    auditoria text,
    id_pais integer
);


ALTER TABLE public.ciudades OWNER TO postgres;

--
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente integer NOT NULL,
    id_persona integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- Name: comp_cuentas_pagar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_cuentas_pagar (
    cue_id_cc integer NOT NULL,
    cue_fecha date,
    cue_monto numeric,
    cue_saldo numeric,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.comp_cuentas_pagar OWNER TO postgres;

--
-- Name: compras_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_cabecera (
    id_cc integer NOT NULL,
    cc_fecha date,
    cc_tipo_factura character varying,
    cc_cuota integer,
    id_sucursal integer,
    id_funcionario integer,
    id_proveedor integer,
    estado public.estados,
    auditoria text,
    cc_intervalo integer,
    cc_nro_factura character varying,
    cc_timbrado character varying
);


ALTER TABLE public.compras_cabecera OWNER TO postgres;

--
-- Name: compras_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_detalle (
    id_cc integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_detalle OWNER TO postgres;

--
-- Name: compras_orden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden (
    id_cc integer NOT NULL,
    id_corden integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_orden OWNER TO postgres;

--
-- Name: compras_orden_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden_cabecera (
    id_corden integer NOT NULL,
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
-- Name: compras_orden_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden_detalle (
    id_corden integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_orden_detalle OWNER TO postgres;

--
-- Name: compras_orden_presu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_orden_presu (
    id_corden integer NOT NULL,
    id_cpre integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_orden_presu OWNER TO postgres;

--
-- Name: compras_pedidos_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_pedidos_cabecera (
    id_cp integer NOT NULL,
    cp_fecha date,
    cp_fecha_aprob date,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.compras_pedidos_cabecera OWNER TO postgres;

--
-- Name: compras_pedidos_detalles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_pedidos_detalles (
    id_cp integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_pedidos_detalles OWNER TO postgres;

--
-- Name: compras_presupuestos_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_presupuestos_cabecera (
    id_cpre integer NOT NULL,
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
-- Name: compras_presupuestos_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_presupuestos_detalle (
    id_cpre integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_presupuestos_detalle OWNER TO postgres;

--
-- Name: compras_presupuestos_pedidos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compras_presupuestos_pedidos (
    id_cpre integer NOT NULL,
    id_cp integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.compras_presupuestos_pedidos OWNER TO postgres;

--
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
-- Name: deposito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deposito (
    id_sucursal integer NOT NULL,
    dep_descrip character varying,
    estado public.estados
);


ALTER TABLE public.deposito OWNER TO postgres;

--
-- Name: empresas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.empresas (
    id_empresa integer NOT NULL,
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
-- Name: estado_civiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado_civiles (
    id_ecivil integer NOT NULL,
    ec_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.estado_civiles OWNER TO postgres;

--
-- Name: funcionarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.funcionarios (
    id_funcionario integer NOT NULL,
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
-- Name: generos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.generos (
    id_genero integer NOT NULL,
    gen_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.generos OWNER TO postgres;

--
-- Name: grupos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupos (
    id_grupo integer NOT NULL,
    gru_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.grupos OWNER TO postgres;

--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id_item integer NOT NULL,
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
-- Name: libro_compras; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.libro_compras (
    lib_id_cc integer NOT NULL,
    lib_iva5 numeric,
    lib_iva10 numeric,
    lib_exenta numeric,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.libro_compras OWNER TO postgres;

--
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id_mar integer NOT NULL,
    mar_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- Name: modulos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modulos (
    id_modulo integer NOT NULL,
    mod_descrip character varying,
    mod_icono character varying,
    mod_orden integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.modulos OWNER TO postgres;

--
-- Name: paginas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paginas (
    id_pagina integer NOT NULL,
    pag_descrip character varying,
    pag_ubicacion character varying,
    pag_icono character varying,
    estado public.estados,
    auditoria text,
    id_modulo integer
);


ALTER TABLE public.paginas OWNER TO postgres;

--
-- Name: paises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paises (
    id_pais integer NOT NULL,
    pais_descrip character varying,
    pais_gentilicio character varying,
    pais_codigo character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.paises OWNER TO postgres;

--
-- Name: permisos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permisos (
    id_grupo integer NOT NULL,
    id_pagina integer NOT NULL,
    id_accion integer NOT NULL,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.permisos OWNER TO postgres;

--
-- Name: personal_trainers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_trainers (
    id_persona_trainer integer NOT NULL,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.personal_trainers OWNER TO postgres;

--
-- Name: personas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personas (
    id_persona integer NOT NULL,
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
-- Name: planes_servicios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planes_servicios (
    id_plan_servi integer NOT NULL,
    ps_descrip character varying,
    precio_servicio integer,
    id_tip_impuesto integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.planes_servicios OWNER TO postgres;

--
-- Name: proveedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedores (
    id_proveedor integer NOT NULL,
    id_persona integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.proveedores OWNER TO postgres;

--
-- Name: serv_inscripciones_membresias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_inscripciones_membresias (
    id_mem integer NOT NULL,
    id_inscrip integer NOT NULL,
    id_plan_servi integer NOT NULL,
    dias integer,
    precio numeric
);


ALTER TABLE public.serv_inscripciones_membresias OWNER TO postgres;

--
-- Name: serv_membresias_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_membresias_cab (
    id_mem integer NOT NULL,
    mem_fecha date,
    mem_vence date,
    mem_observacion text,
    id_cliente integer,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.serv_membresias_cab OWNER TO postgres;

--
-- Name: serv_membresias_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_membresias_det (
    id_mem integer NOT NULL,
    id_plan_servi integer NOT NULL,
    dias integer DEFAULT 0,
    precio numeric,
    auditoria text
);


ALTER TABLE public.serv_membresias_det OWNER TO postgres;

--
-- Name: servicios_inscripciones_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicios_inscripciones_cabecera (
    id_inscrip integer NOT NULL,
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
-- Name: servicios_inscripciones_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servicios_inscripciones_detalle (
    id_inscrip integer NOT NULL,
    id_plan_servi integer NOT NULL,
    dia integer,
    precio integer
);


ALTER TABLE public.servicios_inscripciones_detalle OWNER TO postgres;

--
-- Name: stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock (
    id_sucursal integer NOT NULL,
    id_item integer NOT NULL,
    stock_cantidad integer,
    estado public.estados
);


ALTER TABLE public.stock OWNER TO postgres;

--
-- Name: sucursales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sucursales (
    id_sucursal integer NOT NULL,
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
-- Name: tipos_impuestos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_impuestos (
    id_tip_impuesto integer NOT NULL,
    tip_imp_descrip character varying,
    tip_imp_tasa numeric,
    tip_imp_tasa2 numeric,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.tipos_impuestos OWNER TO postgres;

--
-- Name: tipos_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_items (
    id_tip_item integer NOT NULL,
    tip_item_descrip character varying,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.tipos_items OWNER TO postgres;

--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios (
    id_usuario integer NOT NULL,
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
-- Name: usuarios_sucursales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuarios_sucursales (
    id_usuario integer NOT NULL,
    id_sucursal integer NOT NULL,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.usuarios_sucursales OWNER TO postgres;

--
-- Name: v_accesos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_accesos AS
 SELECT a.id_acceso,
    a.id_usuario,
    a.estado,
    a.auditoria,
    u.usu_login,
    u.usu_contrasena,
    u.usu_imagen,
    u.id_funcionario,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS funcionario,
    p.per_ci
   FROM (((public.accesos a
     JOIN public.usuarios u ON ((u.id_usuario = a.id_usuario)))
     JOIN public.funcionarios f ON ((f.id_funcionario = u.id_funcionario)))
     JOIN public.personas p ON ((f.id_persona = p.id_persona)));


ALTER TABLE public.v_accesos OWNER TO postgres;

--
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
    ti2.id_tip_impuesto,
    m.mar_descrip,
    ti.tip_item_descrip,
    s.id_item AS id_stock,
    s.stock_cantidad,
    de.id_sucursal,
    de.dep_descrip,
    ((cd.precio)::numeric * ti2.tip_imp_tasa) AS tasa1,
    ((cd.precio)::numeric * ti2.tip_imp_tasa2) AS tasa2,
    (((cd.precio)::numeric * ti2.tip_imp_tasa) + ((cd.precio)::numeric * ti2.tip_imp_tasa2)) AS total_impuestos
   FROM ((((((public.compras_detalle cd
     JOIN public.items i ON ((i.id_item = cd.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.tipos_impuestos ti2 ON ((ti2.id_tip_impuesto = i.id_tip_impuesto)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.stock s ON ((s.id_item = cd.id_item)))
     JOIN public.deposito de ON ((de.id_sucursal = s.id_sucursal)));


ALTER TABLE public.v_compras_detalles OWNER TO postgres;

--
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
    ti2.id_tip_impuesto,
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
-- Name: v_cal_impuesto_compra; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_cal_impuesto_compra AS
 SELECT c.id_cc,
    c.id_item,
    sum(c.cantidad) AS cantidad,
    sum(c.stock_cantidad) AS stock_cantidad,
    c.precio,
    c.item_descrip,
    c.id_mar,
    c.id_tip_item,
    c.mar_descrip,
    c.tip_item_descrip,
    c.id_tip_impuesto,
    sum(
        CASE
            WHEN (c.id_tip_impuesto = 2) THEN (c.precio * c.cantidad)
            ELSE 0
        END) AS totalgrav10,
    sum(
        CASE
            WHEN (c.id_tip_impuesto = 2) THEN ((c.precio * c.cantidad) / 11)
            ELSE 0
        END) AS totaliva10,
    sum(
        CASE
            WHEN (c.id_tip_impuesto = 1) THEN (c.precio * c.cantidad)
            ELSE 0
        END) AS totalgrav5,
    sum(
        CASE
            WHEN (c.id_tip_impuesto = 1) THEN ((c.precio * c.cantidad) / 21)
            ELSE 0
        END) AS totaliva5,
    sum(
        CASE
            WHEN (c.id_tip_impuesto = 0) THEN (c.precio * c.cantidad)
            ELSE 0
        END) AS totalexenta,
    sum(
        CASE
            WHEN (c.id_tip_impuesto = ANY (ARRAY[1, 2, 0])) THEN (c.precio * c.cantidad)
            ELSE 0
        END) AS sumagrav,
    (sum(
        CASE
            WHEN (c.id_tip_impuesto = 2) THEN ((c.precio * c.cantidad) / 11)
            ELSE 0
        END) + sum(
        CASE
            WHEN (c.id_tip_impuesto = 1) THEN ((c.precio * c.cantidad) / 21)
            ELSE 0
        END)) AS sumaiva,
    ((((sum(
        CASE
            WHEN (c.id_tip_impuesto = 2) THEN (c.precio * c.cantidad)
            ELSE 0
        END) + sum(
        CASE
            WHEN (c.id_tip_impuesto = 1) THEN (c.precio * c.cantidad)
            ELSE 0
        END)) + sum(
        CASE
            WHEN (c.id_tip_impuesto = 0) THEN (c.precio * c.cantidad)
            ELSE 0
        END)) + sum(
        CASE
            WHEN (c.id_tip_impuesto = 2) THEN ((c.precio * c.cantidad) / 11)
            ELSE 0
        END)) + sum(
        CASE
            WHEN (c.id_tip_impuesto = 1) THEN ((c.precio * c.cantidad) / 21)
            ELSE 0
        END)) AS sumatotal
   FROM ( SELECT d.id_cc,
            d.id_item,
            d.cantidad,
            s.stock_cantidad,
            d.precio,
            d.item_descrip,
            d.id_mar,
            d.id_tip_item,
            d.mar_descrip,
            d.tip_item_descrip,
            d.id_tip_impuesto
           FROM (public.v_compras_detalles d
             JOIN public.stock s ON ((d.id_stock = s.id_item)))
        UNION ALL
         SELECT p.id_cc,
            p.id_item,
            p.cantidad,
            s.stock_cantidad,
            p.precio,
            p.item_descrip,
            p.id_mar,
            p.id_tip_item,
            p.mar_descrip,
            p.tip_item_descrip,
            p.id_tip_impuesto
           FROM (public.v_compras_orden_factu p
             JOIN public.stock s ON ((p.id_stock = s.id_item)))) c
  GROUP BY c.id_cc, c.id_item, c.precio, c.item_descrip, c.id_mar, c.id_tip_item, c.mar_descrip, c.tip_item_descrip, c.id_tip_impuesto;


ALTER TABLE public.v_cal_impuesto_compra OWNER TO postgres;

--
-- Name: v_cantidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.v_cantidad (
    stock_cantidad integer
);


ALTER TABLE public.v_cantidad OWNER TO postgres;

--
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
-- Name: v_compras_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_cab AS
 SELECT cc.id_cc,
    cc.cc_fecha,
    cc.cc_tipo_factura,
    cc.cc_cuota,
    cc.id_sucursal,
    cc.id_funcionario,
    cc.id_proveedor,
    cc.estado,
    cc.auditoria,
    cc.cc_intervalo,
    cc.cc_nro_factura,
    cc.cc_timbrado,
    to_char((cc.cc_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
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
    ( SELECT COALESCE(sum((stock.stock_cantidad * compras_detalle.precio)), (0)::bigint) AS "coalesce"
           FROM (public.compras_detalle
             JOIN public.stock ON (((compras_detalle.id_item = stock.id_item) AND (stock.id_sucursal = cc.id_sucursal))))
          WHERE (compras_detalle.id_cc = cc.id_cc)) AS monto_detalles,
    ( SELECT COALESCE(sum((compras_orden.cantidad * compras_orden.precio)), (0)::bigint) AS "coalesce"
           FROM (public.compras_orden
             JOIN public.stock ON (((compras_orden.id_item = stock.id_item) AND (stock.id_sucursal = cc.id_sucursal))))
          WHERE (compras_orden.id_cc = cc.id_cc)) AS monto_pedido,
    (( SELECT COALESCE(sum((stock.stock_cantidad * compras_detalle.precio)), (0)::bigint) AS "coalesce"
           FROM (public.compras_detalle
             JOIN public.stock ON (((compras_detalle.id_item = stock.id_item) AND (stock.id_sucursal = cc.id_sucursal))))
          WHERE (compras_detalle.id_cc = cc.id_cc)) + ( SELECT COALESCE(sum((compras_orden.cantidad * compras_orden.precio)), (0)::bigint) AS "coalesce"
           FROM public.compras_orden
          WHERE (compras_orden.id_cc = cc.id_cc))) AS monto_total
   FROM (((((public.compras_cabecera cc
     JOIN public.sucursales s ON ((s.id_sucursal = cc.id_sucursal)))
     JOIN public.proveedores p2 ON ((p2.id_proveedor = cc.id_proveedor)))
     JOIN public.personas p ON ((p.id_persona = p2.id_persona)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cc.id_funcionario)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_compras_cab OWNER TO postgres;

--
-- Name: v_compras_consolidacion; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_compras_consolidacion AS
 SELECT c.id_cc,
    c.id_item,
    sum(c.cantidad) AS catidad,
    sum(c.stock_cantidad) AS stock_cantidad,
    c.precio,
    c.item_descrip,
    c.id_mar,
    c.id_tip_item,
    c.mar_descrip,
    c.tip_item_descrip,
    c.id_tip_impuesto,
    c.tasa1,
    c.tasa2,
    c.total_impuestos
   FROM ( SELECT d.id_cc,
            d.id_item,
            d.cantidad,
            s.stock_cantidad,
            d.precio,
            d.item_descrip,
            d.id_mar,
            d.id_tip_item,
            d.mar_descrip,
            d.tip_item_descrip,
            d.id_tip_impuesto,
            d.tasa1,
            d.tasa2,
            d.total_impuestos
           FROM (public.v_compras_detalles d
             JOIN public.stock s ON ((d.id_stock = s.id_item)))
        UNION ALL
         SELECT p.id_cc,
            p.id_item,
            p.cantidad,
            s.stock_cantidad,
            p.precio,
            p.item_descrip,
            p.id_mar,
            p.id_tip_item,
            p.mar_descrip,
            p.tip_item_descrip,
            p.id_tip_impuesto,
            p.tasa1,
            p.tasa2,
            p.total_impuestos
           FROM (public.v_compras_orden_factu p
             JOIN public.stock s ON ((p.id_stock = s.id_item)))) c
  GROUP BY c.id_cc, c.id_item, c.precio, c.item_descrip, c.id_mar, c.id_tip_item, c.mar_descrip, c.tip_item_descrip, c.cantidad, c.stock_cantidad, c.id_tip_impuesto, c.tasa1, c.tasa2, c.total_impuestos;


ALTER TABLE public.v_compras_consolidacion OWNER TO postgres;

--
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
-- Name: v_serv_inscripciones_membresias; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_inscripciones_membresias AS
 SELECT sim.id_mem,
    sim.id_inscrip,
    sim.id_plan_servi,
    sim.dias,
    sim.precio,
    ps.ps_descrip,
    ps.precio_servicio,
    ps.estado,
    ti.tip_imp_descrip,
    ti.tip_imp_tasa
   FROM ((public.serv_inscripciones_membresias sim
     JOIN public.planes_servicios ps ON ((ps.id_plan_servi = sim.id_plan_servi)))
     JOIN public.tipos_impuestos ti ON ((ti.id_tip_impuesto = ps.id_tip_impuesto)));


ALTER TABLE public.v_serv_inscripciones_membresias OWNER TO postgres;

--
-- Name: v_serv_membresias_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_membresias_cab AS
 SELECT smc.id_mem,
    smc.mem_fecha,
    smc.mem_vence,
    smc.mem_observacion,
    smc.id_cliente,
    smc.id_sucursal,
    smc.id_funcionario,
    smc.estado,
    smc.auditoria,
    to_char((smc.mem_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((smc.mem_vence)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_venci,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    e.emp_ruc,
    e.emp_denominacion,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS cliente,
    p.per_ci,
    p.id_persona,
    ( SELECT max(v_funcionarios.funcionario) AS max
           FROM public.v_funcionarios
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario,
    ( SELECT COALESCE(sum(((serv_membresias_det.dias)::numeric * serv_membresias_det.precio)), ((0)::bigint)::numeric) AS "coalesce"
           FROM public.serv_membresias_det
          WHERE (serv_membresias_det.id_mem = smc.id_mem)) AS monto_detalles,
    ( SELECT COALESCE(sum(((serv_inscripciones_membresias.dias)::numeric * serv_inscripciones_membresias.precio)), ((0)::bigint)::numeric) AS "coalesce"
           FROM public.serv_inscripciones_membresias
          WHERE (serv_inscripciones_membresias.id_mem = smc.id_mem)) AS monto_inscripcion,
    (( SELECT COALESCE(sum(((serv_membresias_det.dias)::numeric * serv_membresias_det.precio)), ((0)::bigint)::numeric) AS "coalesce"
           FROM public.serv_membresias_det
          WHERE (serv_membresias_det.id_mem = smc.id_mem)) + ( SELECT COALESCE(sum(((serv_inscripciones_membresias.dias)::numeric * serv_inscripciones_membresias.precio)), ((0)::bigint)::numeric) AS "coalesce"
           FROM public.serv_inscripciones_membresias
          WHERE (serv_inscripciones_membresias.id_mem = smc.id_mem))) AS monto_total
   FROM (((((public.serv_membresias_cab smc
     JOIN public.sucursales s ON ((s.id_sucursal = smc.id_sucursal)))
     JOIN public.clientes c ON ((c.id_cliente = smc.id_cliente)))
     JOIN public.funcionarios f ON ((f.id_funcionario = smc.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = c.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_serv_membresias_cab OWNER TO postgres;

--
-- Name: v_serv_membresias_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_membresias_det AS
 SELECT smd.id_mem,
    smd.id_plan_servi,
    smd.dias,
    smd.precio,
    smd.auditoria,
    ps.ps_descrip,
    ps.precio_servicio,
    ps.estado,
    ti.tip_imp_descrip,
    ti.tip_imp_tasa
   FROM ((public.serv_membresias_det smd
     JOIN public.planes_servicios ps ON ((ps.id_plan_servi = smd.id_plan_servi)))
     JOIN public.tipos_impuestos ti ON ((ti.id_tip_impuesto = ps.id_tip_impuesto)));


ALTER TABLE public.v_serv_membresias_det OWNER TO postgres;

--
-- Name: v_serv_membresias_consolidacion; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_membresias_consolidacion AS
 SELECT c.id_mem,
    c.id_plan_servi,
    sum(c.dias) AS dias,
    c.precio,
    c.ps_descrip,
    c.precio_servicio,
    c.tip_imp_descrip,
    c.tip_imp_tasa
   FROM ( SELECT d.id_mem,
            d.id_plan_servi,
            d.dias,
            d.precio,
            d.ps_descrip,
            d.precio_servicio,
            d.tip_imp_descrip,
            d.tip_imp_tasa
           FROM public.v_serv_membresias_det d
        UNION ALL
         SELECT p.id_mem,
            p.id_plan_servi,
            p.dias,
            p.precio,
            p.ps_descrip,
            p.precio_servicio,
            p.tip_imp_descrip,
            p.tip_imp_tasa
           FROM public.v_serv_inscripciones_membresias p) c
  GROUP BY c.id_mem, c.id_plan_servi, c.precio, c.ps_descrip, c.precio_servicio, c.tip_imp_descrip, c.tip_imp_tasa;


ALTER TABLE public.v_serv_membresias_consolidacion OWNER TO postgres;

--
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
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario,
    p.per_ci
   FROM (((((public.servicios_inscripciones_cabecera sic
     JOIN public.sucursales s ON ((s.id_sucursal = sic.id_sucursal)))
     JOIN public.clientes c ON ((c.id_cliente = sic.id_cliente)))
     JOIN public.funcionarios f ON ((f.id_funcionario = sic.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = c.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_servicios_inscripciones OWNER TO postgres;

--
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
-- Name: ventas_pedidos_cabecera; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas_pedidos_cabecera (
    id_vped integer NOT NULL,
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
-- Name: ventas_pedidos_detalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ventas_pedidos_detalle (
    id_vped integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    precio integer
);


ALTER TABLE public.ventas_pedidos_detalle OWNER TO postgres;

--
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
-- Name: auth_2fa id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_2fa ALTER COLUMN id SET DEFAULT nextval('public.auth_2fa_id_seq'::regclass);


--
-- Data for Name: accesos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accesos (id_acceso, id_usuario, estado, auditoria) FROM stdin;
1	1	ACTIVO	\N
\.


--
-- Data for Name: acciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.acciones (id_accion, ac_descrip, estado, auditoria) FROM stdin;
1	VISUALIZAR	ACTIVO	INSERCION/admin/2023-10-16 16:51:02.050925-03
\.


--
-- Data for Name: auth_2fa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_2fa (id, id_usuario, codigo, fecha_expiracion, usado) FROM stdin;
\.


--
-- Data for Name: cargos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cargos (id_cargo, car_descrip, estado, auditoria) FROM stdin;
1	DESARROLLADOR	ACTIVO	\N
2	RECEPCIONISTA	ACTIVO	\N
3	ADMINISTRADOR DE SISTEMAS	ACTIVO	\N
\.


--
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
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id_cliente, id_persona, estado, auditoria) FROM stdin;
1	5	ACTIVO	\N
2	3	ACTIVO	\N
\.


--
-- Data for Name: comp_cuentas_pagar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comp_cuentas_pagar (cue_id_cc, cue_fecha, cue_monto, cue_saldo, estado, auditoria) FROM stdin;
4	2024-11-01	34234	34234	PENDIENTE	INSERCION/admin/2024-11-03 12:57:36.462269-03
\.


--
-- Data for Name: compras_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_cabecera (id_cc, cc_fecha, cc_tipo_factura, cc_cuota, id_sucursal, id_funcionario, id_proveedor, estado, auditoria, cc_intervalo, cc_nro_factura, cc_timbrado) FROM stdin;
1	2024-01-02	CREDITO	3	1	1	1	PENDIENTE	\N	4	\N	\N
3	2024-11-01	CREDITO	2345	1	1	2	PENDIENTE	INSERCION/admin/2024-11-01 15:37:53.284047-03	2345	0452	02345
2	2024-10-30	CREDITO	3	1	1	2	PENDIENTE	INSERCION/admin/2024-10-30 20:48:20.928751-03\rCONFIRMACION/usuario_prueba/2024-11-02 18:27:26.660432-03	25	000233	23452523
4	2024-11-01	CREDITO	34	1	1	2	CONFIRMADO	INSERCION/admin/2024-11-01 20:12:52.10256-03\rCONFIRMACION/admin/2024-11-03 11:38:08.19806-03	43	043r	0345
\.


--
-- Data for Name: compras_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_detalle (id_cc, id_item, cantidad, precio) FROM stdin;
1	2	5	20000
1	1	5	10000
1	3	10	15000
2	3	5	30000
2	6	4	10000
4	6	1	34234
\.


--
-- Data for Name: compras_orden; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden (id_cc, id_corden, id_item, cantidad, precio) FROM stdin;
3	6	6	1	10000
1	6	6	1	10000
\.


--
-- Data for Name: compras_orden_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden_cabecera (id_corden, ord_fecha, ord_intervalo, ord_tipo_factura, ord_cuota, id_sucursal, id_funcionario, id_proveedor, estado, auditoria) FROM stdin;
1	2024-01-02	2024-07-08	CUOTA	4	1	1	1	ANULADO	\rANULACION/admin/2024-02-03 15:24:59.000032-03
2	2024-02-02	2024-02-04	CONTADO	6	1	1	1	CONFIRMADO	INSERCION/admin/2024-02-02 17:02:53.084135-03\rCONFIRMACION/admin/2024-02-03 15:25:19.012234-03
3	2024-02-03	2024-02-03	CONTADO	0	1	1	1	CONFIRMADO	INSERCION/admin/2024-02-03 15:26:55.585886-03\rMODIFICACION/admin/2024-02-03 15:28:13.458814-03\rANULACION/admin/2024-08-23 14:48:43.203613-04\rCONFIRMACION/admin/2024-10-22 15:00:28.295653-03
4	2024-08-30	2024-08-22	CREDITO	2	1	1	1	CONFIRMADO	INSERCION/admin/2024-08-29 20:55:32.404053-04\rCONFIRMACION/admin/2024-10-22 15:01:09.428806-03
5	2024-11-01	2024-11-14	CREDITO	1	1	1	1	PENDIENTE	INSERCION/admin/2024-11-01 15:46:51.816779-03
6	2024-11-03	2024-11-12	CONTADO	3	1	1	1	CONFIRMADO	INSERCION/admin/2024-11-03 14:38:47.912047-03\rCONFIRMACION/admin/2024-11-03 14:39:09.267162-03
\.


--
-- Data for Name: compras_orden_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden_detalle (id_corden, id_item, cantidad, precio) FROM stdin;
3	3	1	30000
3	6	1	12000
3	5	1	12000
4	6	1	19000
6	6	1	10000
\.


--
-- Data for Name: compras_orden_presu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_orden_presu (id_corden, id_cpre, id_item, cantidad, precio) FROM stdin;
3	4	5	1	23000
4	4	5	1	23000
4	4	6	1	0
\.


--
-- Data for Name: compras_pedidos_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_pedidos_cabecera (id_cp, cp_fecha, cp_fecha_aprob, id_sucursal, id_funcionario, estado, auditoria) FROM stdin;
6	2023-11-08	2023-11-08	1	3	PENDIENTE	INSERCION/usubeta/2023-11-08 21:00:44.357427-03
4	2023-10-29	2023-10-29	1	1	PENDIENTE	INSERCION/admin/2023-10-29 14:18:50.973631-03\rCONFIRMACION/admin/2023-10-29 14:18:57.009068-03\rCERRAR/admin/2024-01-04 19:38:03.319644-03
2	2023-10-24	2023-10-24	1	1	CERRADO	INSERCION/admin/2023-10-24 19:40:36.609984-03\rCONFIRMACION/admin/2023-10-28 22:57:48.997853-03\rCERRAR/admin/2024-07-24 19:26:51.479533-04
5	2023-11-08	2023-11-08	1	1	CERRADO	INSERCION/admin/2023-11-08 16:58:03.410349-03\rCONFIRMACION/admin/2023-11-08 16:58:57.308226-03\rCERRAR/admin/2024-08-23 14:49:31.567956-04
1	2023-10-23	2023-11-23	1	1	CERRADO	INSERCION/admin/2023-10-23 21:38:53.971372-03\rCONFIRMACION/admin/2023-10-23 21:40:42.659034-03\rCERRAR/admin/2024-01-04 19:41:34.783441-03\rCERRAR/admin/2024-01-07 13:47:47.79026-03
3	2023-10-28	2023-10-28	1	1	CERRADO	INSERCION/admin/2023-10-28 22:57:53.550615-03\rCONFIRMACION/admin/2023-10-29 14:15:51.809721-03\rCERRAR/admin/2024-01-04 19:41:22.785595-03\rCERRAR/admin/2024-09-09 19:35:25.72417-04
\.


--
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
4	5	1	7000
5	6	1	10000
5	5	1	7000
4	2	2	250000
\.


--
-- Data for Name: compras_presupuestos_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_presupuestos_cabecera (id_cpre, cpre_fecha, cpre_validez, cpre_numero, cpre_observacion, id_sucursal, id_funcionario, id_proveedor, estado, auditoria) FROM stdin;
2	2023-10-24	2023-10-24	0		1	1	2	ANULADO	INSERCION/admin/2023-10-24 22:26:34.607106-03\rANULACION/admin/2023-10-25 10:43:53.26954-03
3	2023-10-25	2023-10-25	453		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-25 09:59:57.625745-03\rMODIFICACION/admin/2023-10-25 15:26:34.532971-03\rMODIFICACION/admin/2023-10-25 15:29:32.321924-03\rMODIFICACION/admin/2023-10-25 15:45:17.630218-03\rCONFIRMACION/admin/2023-10-25 19:26:12.433552-03
6	2023-10-28	2023-10-28	0		1	1	1	PENDIENTE	INSERCION/admin/2023-10-28 16:45:47.090918-03
7	2023-10-29	2023-10-29	0		1	1	1	PENDIENTE	INSERCION/admin/2023-10-29 21:39:17.540259-03
1	2023-10-25	2023-10-25	34	N/A	1	1	1	CONFIRMADO	INSERCION/admin/2023-10-23 21:16:53.065994-03\rMODIFICACION/admin/2023-10-25 19:26:39.350349-03\rCONFIRMACION/admin/2024-01-04 17:07:08.474454-03\rCONFIRMACION/admin/2024-02-03 15:43:01.851842-03
4	2023-10-28	2023-10-28	0		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-28 16:35:56.291108-03\rCONFIRMACION/admin/2024-02-03 21:12:09.249599-03
5	2023-10-28	2023-10-28	0		1	1	1	ANULADO	INSERCION/admin/2023-10-28 16:44:09.05719-03\rANULACION/admin/2024-07-24 19:28:46.059806-04
10	2023-11-08	2023-11-08	0		1	3	1	CONFIRMADO	INSERCION/usubeta/2023-11-08 21:45:39.531905-03\rCONFIRMACION/admin/2024-08-05 22:46:29.739025-04
9	2023-11-08	2023-11-08	32		1	1	1	ANULADO	INSERCION/admin/2023-11-08 16:59:47.399414-03\rANULACION/admin/2024-08-05 22:46:51.698198-04
8	2023-10-30	2023-10-30	0		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-30 11:39:00.005398-03\rCONFIRMACION/admin/2024-08-23 14:50:28.274342-04
\.


--
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
5	5	1	12000
6	6	1	0
7	6	1	32233
\.


--
-- Data for Name: compras_presupuestos_pedidos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compras_presupuestos_pedidos (id_cpre, id_cp, id_item, cantidad, precio) FROM stdin;
1	1	6	5	10000
1	1	5	15	7000
1	1	2	10	250000
5	2	6	4	10000
8	5	6	1	10000
8	5	5	1	7000
6	3	5	1	7000
6	3	2	1	250000
6	3	3	1	300000
6	3	1	1	250000
6	3	4	1	150000
6	3	6	1000	10000
\.


--
-- Data for Name: d; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.d (id_corden, id_item, sum, precio, item_descrip, id_mar, id_tip_item, mar_descrip, tip_item_descrip) FROM stdin;
3	5	1	23000	BEBIDA ENERGÉTICA	6	5	POWERADE	BEBIDAS
\.


--
-- Data for Name: deposito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deposito (id_sucursal, dep_descrip, estado) FROM stdin;
1	DEP-1	ACTIVO
\.


--
-- Data for Name: empresas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.empresas (id_empresa, emp_ruc, emp_denominacion, emp_direccion, emp_correo, emp_telefono, emp_actividad, emp_ubicacion, estado, auditoria) FROM stdin;
1	1234567-0	ENERGYM	EUSEBIO AYALA	energym@gmail.com	0981123123	ENTRENAMIENTO FISICO	XXX-3214	ACTIVO	\N
\.


--
-- Data for Name: estado_civiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estado_civiles (id_ecivil, ec_descrip, estado, auditoria) FROM stdin;
3	DIVORCIADO/A	ACTIVO	\N
4	VIUDO/A	ACTIVO	\N
1	SOLTERO/A	ACTIVO	\N
2	CASADO/A	ACTIVO	\N
\.


--
-- Data for Name: funcionarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.funcionarios (id_funcionario, fun_ingreso, fun_egreso, monto_salario, estado, auditoria, id_persona, id_cargo) FROM stdin;
1	2021-03-01	\N	4000000	ACTIVO	\N	1	1
2	2021-01-01	\N	3000000	ACTIVO	\N	2	2
3	2021-08-07	\N	3500000	ACTIVO	\N	6	3
\.


--
-- Data for Name: generos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.generos (id_genero, gen_descrip, estado, auditoria) FROM stdin;
1	MASCULINO	ACTIVO	\N
2	FEMENINO	ACTIVO	\N
3	NO DEFINIDO	ACTIVO	\N
\.


--
-- Data for Name: grupos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grupos (id_grupo, gru_descrip, estado, auditoria) FROM stdin;
1	DESARROLLADOR	ACTIVO	\N
2	RECEPCIONISTA	ACTIVO	\N
3	ADMINISTRADOR DE SISTEMAS	ACTIVO	\N
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id_item, item_descrip, precio_compra, precio_venta, id_mar, id_tip_item, id_tip_impuesto, estado, auditoria) FROM stdin;
1	PROTEÍNA	250000	300000	1	1	2	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
2	CREATINA	250000	280000	1	1	2	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
3	GUANTE DE GIMNACIO TALLA 16	300000	350000	3	3	2	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
6	BARRA DE PROTEÍNA	10000	12500	1	6	2	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
4	TOALLA	150000	170000	3	4	2	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
5	BEBIDA ENERGÉTICA	7000	9000	6	5	2	ACTIVO	INSERCION/admin/2023-10-20 20:30:46.976541-03
\.


--
-- Data for Name: libro_compras; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.libro_compras (lib_id_cc, lib_iva5, lib_iva10, lib_exenta, estado, auditoria) FROM stdin;
4	0	3112	0	ACTIVO	INSERCION/admin/2024-11-03 12:57:36.462269-03
\.


--
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
-- Data for Name: modulos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modulos (id_modulo, mod_descrip, mod_icono, mod_orden, estado, auditoria) FROM stdin;
1	COMPRA	fa fa-shopping-cart	2	ACTIVO	\N
2	SERVICIO	fa fa-dumbbell	3	ACTIVO	\N
3	VENTA	fa fa-tags	4	ACTIVO	\N
4	CONFIG. SISTEMA	fa fa-cogs	5	ACTIVO	\N
\.


--
-- Data for Name: paginas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paginas (id_pagina, pag_descrip, pag_ubicacion, pag_icono, estado, auditoria, id_modulo) FROM stdin;
5	Nota de Credito y Debito	\N	far fa-circle	ACTIVO	\N	1
7	Transferencia	\N	far fa-circle	ACTIVO	\N	1
16	Apertura y Cierre de Caja	\N	far fa-circle	ACTIVO	\N	3
17	Registrar Venta	\N	far fa-circle	ACTIVO	\N	3
18	Cobranza	\N	far fa-circle	ACTIVO	\N	3
19	Nota de Credito y Debito	\N	far fa-circle	ACTIVO	\N	3
20	Arqueo de Caja	\N	far fa-circle	ACTIVO	\N	3
21	Nota de Remisión	\N	far fa-circle	ACTIVO	\N	3
2	Presupuesto de Proveedor	/tesis/compra/presupuesto	far fa-circle	ACTIVO	\N	1
3	Orden de Compra	/tesis/compra/orden	far fa-circle	ACTIVO	\N	1
6	Ajuste de Stock	/tesis/compra/ajuste	far fa-circle	ACTIVO	\N	1
1	Pedido de Compra	/tesis/compra/pedidos	far fa-circle	ACTIVO	\N	1
15	Pedido de Clientes	/tesis/venta/pedidos_clientes	far fa-circle	ACTIVO	\N	3
8	Inscripción	/tesis/servicio/inscripciones	far fa-circle	ACTIVO	\N	2
4	Registrar Compras	/tesis/compra/compras_facturacion	far fa-circle	ACTIVO	\N	1
22	Paises	/tesis/referenciales/paises	far fa-circle	ACTIVO	\N	4
23	Ciudades	/tesis/referenciales/ciudades	far fa-circle	ACTIVO	\N	4
24	Personas	/tesis/referenciales/personas	far fa-circle	ACTIVO	\N	4
25	Membresía	/tesis/servicio/membresia	far fa-circle	ACTIVO	\N	2
9	Rutinas	/tesis/servicio/rutina	far fa-circle	ACTIVO	\N	2
10	Mediciones	/tesis/servicio/medicion	far fa-circle	ACTIVO	\N	2
12	Evolución del Atleta	/tesis/servicio/evolucion	far fa-circle	ACTIVO	\N	2
13	Presupuesto de Preparacion	/tesis/servicio/presupuesto	far fa-circle	ACTIVO	\N	2
14	Registrar Asistencia	/tesis/servicio/asistencia	far fa-circle	ACTIVO	\N	2
11	Plan Alimentario	/tesis/servicio/plan_alimentario	far fa-circle	ACTIVO	\N	2
\.


--
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
1	25	1	ACTIVO	INSERCION/admin/2023-10-18 09:56:19.682442-03
\.


--
-- Data for Name: personal_trainers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_trainers (id_persona_trainer, id_funcionario, estado, auditoria) FROM stdin;
\.


--
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
-- Data for Name: proveedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proveedores (id_proveedor, id_persona, estado, auditoria) FROM stdin;
1	3	ACTIVO	INSERCION/admin/2023-10-23 17:43:53.705517-03
2	4	ACTIVO	INSERCION/admin/2023-10-23 17:43:53.705517-03
\.


--
-- Data for Name: serv_inscripciones_membresias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serv_inscripciones_membresias (id_mem, id_inscrip, id_plan_servi, dias, precio) FROM stdin;
\.


--
-- Data for Name: serv_membresias_cab; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serv_membresias_cab (id_mem, mem_fecha, mem_vence, mem_observacion, id_cliente, id_sucursal, id_funcionario, estado, auditoria) FROM stdin;
\.


--
-- Data for Name: serv_membresias_det; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serv_membresias_det (id_mem, id_plan_servi, dias, precio, auditoria) FROM stdin;
\.


--
-- Data for Name: servicios_inscripciones_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.servicios_inscripciones_cabecera (id_inscrip, ins_fecha, ins_aprobacion, ins_estad_salud, id_sucursal, id_funcionario, id_cliente, estado, auditoria) FROM stdin;
1	2023-03-03	2023-10-27	--	1	1	1	CONFIRMADO	\rCONFIRMACION/admin/2023-10-27 18:20:09.713774-03
2	2023-10-27	2023-10-30	ssafd	1	1	1	CONFIRMADO	INSERCION/admin/2023-10-27 18:20:16.04138-03\rCONFIRMACION/admin/2023-10-30 19:08:53.549274-03
3	2023-10-30	2023-11-08		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-30 19:09:00.880603-03\rCONFIRMACION/usubeta/2023-11-08 21:01:27.965509-03
4	2023-11-08	2024-06-18		1	3	1	CONFIRMADO	INSERCION/usubeta/2023-11-08 21:01:35.264309-03\rCONFIRMACION/admin/2024-06-18 15:21:32.891977-04
5	2024-06-18	2024-11-06		1	1	1	CONFIRMADO	INSERCION/admin/2024-06-18 15:21:39.774769-04\rCONFIRMACION/admin/2024-11-06 20:00:33.880189-03
6	2024-11-06	2024-11-06	N/A	1	1	2	ANULADO	INSERCION/admin/2024-11-06 20:09:04.561833-03\rANULACION/admin/2024-11-06 20:14:08.179579-03
7	2024-11-06	2024-11-06	N/A	1	1	2	CONFIRMADO	INSERCION/admin/2024-11-06 20:14:26.043353-03\rCONFIRMACION/admin/2024-11-06 20:20:26.046576-03
\.


--
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
7	1	1	15000
\.


--
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock (id_sucursal, id_item, stock_cantidad, estado) FROM stdin;
1	4	1	ACTIVO
1	1	7	ACTIVO
1	2	8	ACTIVO
1	3	28	ACTIVO
1	5	7	ACTIVO
1	6	7	ACTIVO
\.


--
-- Data for Name: sucursales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sucursales (id_sucursal, suc_nombre, suc_direccion, suc_correo, suc_telefono, suc_ubicacion, suc_imagen, estado, auditoria, id_empresa) FROM stdin;
1	CASA MATRIZ	calle san roque	energym@gmail.com	0981000000	xy	/tesis/imagenes/sucursales/1.jpg	ACTIVO	\N	1
2	ÑEMBY	calle san roque	energym@gmail.com	0981000000	xy	/tesis/imagenes/sucursales/2.jpg	ACTIVO	\N	1
3	FERNANDO DE LA MORA	calle san roque	energym@gmail.com	0981000000	xy	/tesis/imagenes/sucursales/3.jpg	ACTIVO	\N	1
\.


--
-- Data for Name: tipos_impuestos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tipos_impuestos (id_tip_impuesto, tip_imp_descrip, tip_imp_tasa, tip_imp_tasa2, estado, auditoria) FROM stdin;
1	IVA %5	0.05	5	ACTIVO	INSERCION/admin/2023-10-20 19:23:49.424839-03
2	IVA %10	0.1	10	ACTIVO	\N
3	EXENTO	0	0	ACTIVO	INSERCION/admin/2023-10-20 19:23:49.424839-03
\.


--
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
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id_usuario, usu_login, usu_contrasena, usu_imagen, estado, auditoria, id_funcionario, id_grupo, id_sucursal) FROM stdin;
1	admin	202cb962ac59075b964b07152d234b70	/tesis/imagenes/usuarios/1.png	ACTIVO	\N	1	1	1
2	juanp	202cb962ac59075b964b07152d234b70	/tesis/imagenes/usuarios/2.png	ACTIVO	\N	2	2	2
3	usubeta	202cb962ac59075b964b07152d234b70	/tesis/imagenes/usuarios/3.png	ACTIVO	\N	3	3	1
\.


--
-- Data for Name: usuarios_sucursales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios_sucursales (id_usuario, id_sucursal, estado, auditoria) FROM stdin;
\.


--
-- Data for Name: v_cantidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.v_cantidad (stock_cantidad) FROM stdin;
5
5
13
\.


--
-- Data for Name: ventas_pedidos_cabecera; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas_pedidos_cabecera (id_vped, vped_fecha, vped_aprobacion, vped_observacion, id_sucursal, id_funcionario, id_cliente, estado, auditoria) FROM stdin;
1	2023-03-03	2023-03-03	--	1	1	1	CONFIRMADO	\rCONFIRMACION/admin/2023-10-26 19:45:24.303321-03
2	2023-10-26	2023-10-26	N/A	1	1	1	ANULADO	INSERCION/admin/2023-10-26 19:45:37.497158-03\rANULACION/admin/2023-10-26 19:54:34.402059-03
3	2023-10-27	2023-10-27		1	1	1	CONFIRMADO	INSERCION/admin/2023-10-27 21:41:26.74757-03\rCONFIRMACION/usubeta/2023-11-08 21:04:29.939857-03
4	2023-11-08	2023-11-08		1	3	1	PENDIENTE	INSERCION/usubeta/2023-11-08 21:04:35.504479-03
\.


--
-- Data for Name: ventas_pedidos_detalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ventas_pedidos_detalle (id_vped, id_item, cantidad, precio) FROM stdin;
1	1	2	12000
2	6	1	12500
3	4	1	170000
4	6	1	12500
\.


--
-- Name: auth_2fa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_2fa_id_seq', 1, false);


--
-- Name: accesos accesos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accesos
    ADD CONSTRAINT accesos_pkey PRIMARY KEY (id_acceso);


--
-- Name: acciones acciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.acciones
    ADD CONSTRAINT acciones_pkey PRIMARY KEY (id_accion);


--
-- Name: auth_2fa auth_2fa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_2fa
    ADD CONSTRAINT auth_2fa_pkey PRIMARY KEY (id);


--
-- Name: cargos cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cargos
    ADD CONSTRAINT cargos_pkey PRIMARY KEY (id_cargo);


--
-- Name: ciudades ciudades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_pkey PRIMARY KEY (id_ciudad);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- Name: comp_cuentas_pagar comp_cuentas_pagar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_cuentas_pagar
    ADD CONSTRAINT comp_cuentas_pagar_pkey PRIMARY KEY (cue_id_cc);


--
-- Name: compras_cabecera compras_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_pkey PRIMARY KEY (id_cc);


--
-- Name: compras_detalle compras_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_detalle
    ADD CONSTRAINT compras_detalle_pkey PRIMARY KEY (id_cc, id_item);


--
-- Name: compras_orden_cabecera compras_orden_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_pkey PRIMARY KEY (id_corden);


--
-- Name: compras_orden_detalle compras_orden_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_detalle
    ADD CONSTRAINT compras_orden_detalle_pkey PRIMARY KEY (id_corden, id_item);


--
-- Name: compras_orden compras_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_pkey PRIMARY KEY (id_cc, id_corden, id_item);


--
-- Name: compras_orden_presu compras_orden_presu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_presu
    ADD CONSTRAINT compras_orden_presu_pkey PRIMARY KEY (id_corden, id_cpre, id_item);


--
-- Name: compras_pedidos_cabecera compras_pedidos_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_cabecera
    ADD CONSTRAINT compras_pedidos_cabecera_pkey PRIMARY KEY (id_cp);


--
-- Name: compras_pedidos_detalles compras_pedidos_detalles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_detalles
    ADD CONSTRAINT compras_pedidos_detalles_pkey PRIMARY KEY (id_cp, id_item);


--
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_pkey PRIMARY KEY (id_cpre);


--
-- Name: compras_presupuestos_detalle compras_presupuestos_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_detalle
    ADD CONSTRAINT compras_presupuestos_detalle_pkey PRIMARY KEY (id_cpre, id_item);


--
-- Name: compras_presupuestos_pedidos compras_presupuestos_pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_pedidos
    ADD CONSTRAINT compras_presupuestos_pedidos_pkey PRIMARY KEY (id_cpre, id_cp, id_item);


--
-- Name: deposito deposito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposito
    ADD CONSTRAINT deposito_pkey PRIMARY KEY (id_sucursal);


--
-- Name: empresas empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_pkey PRIMARY KEY (id_empresa);


--
-- Name: estado_civiles estado_civiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado_civiles
    ADD CONSTRAINT estado_civiles_pkey PRIMARY KEY (id_ecivil);


--
-- Name: funcionarios funcionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_pkey PRIMARY KEY (id_funcionario);


--
-- Name: generos generos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.generos
    ADD CONSTRAINT generos_pkey PRIMARY KEY (id_genero);


--
-- Name: grupos grupos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_pkey PRIMARY KEY (id_grupo);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id_item);


--
-- Name: libro_compras libro_compras_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libro_compras
    ADD CONSTRAINT libro_compras_pkey PRIMARY KEY (lib_id_cc);


--
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id_mar);


--
-- Name: modulos modulos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modulos
    ADD CONSTRAINT modulos_pkey PRIMARY KEY (id_modulo);


--
-- Name: paginas paginas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginas
    ADD CONSTRAINT paginas_pkey PRIMARY KEY (id_pagina);


--
-- Name: paises paises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paises
    ADD CONSTRAINT paises_pkey PRIMARY KEY (id_pais);


--
-- Name: permisos permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id_grupo, id_pagina, id_accion);


--
-- Name: personal_trainers personal_trainers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_trainers
    ADD CONSTRAINT personal_trainers_pkey PRIMARY KEY (id_persona_trainer);


--
-- Name: personas personas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_pkey PRIMARY KEY (id_persona);


--
-- Name: planes_servicios planes_servicios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_servicios
    ADD CONSTRAINT planes_servicios_pkey PRIMARY KEY (id_plan_servi);


--
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (id_proveedor);


--
-- Name: serv_inscripciones_membresias serv_inscripciones_membresias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_inscripciones_membresias
    ADD CONSTRAINT serv_inscripciones_membresias_pkey PRIMARY KEY (id_mem, id_inscrip, id_plan_servi);


--
-- Name: serv_membresias_cab serv_membresias_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_cab
    ADD CONSTRAINT serv_membresias_cab_pkey PRIMARY KEY (id_mem);


--
-- Name: serv_membresias_det serv_membresias_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_det
    ADD CONSTRAINT serv_membresias_det_pkey PRIMARY KEY (id_mem, id_plan_servi);


--
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_pkey PRIMARY KEY (id_inscrip);


--
-- Name: servicios_inscripciones_detalle servicios_inscripciones_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_detalle
    ADD CONSTRAINT servicios_inscripciones_detalle_pkey PRIMARY KEY (id_inscrip, id_plan_servi);


--
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id_sucursal, id_item);


--
-- Name: sucursales sucursales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursales
    ADD CONSTRAINT sucursales_pkey PRIMARY KEY (id_sucursal);


--
-- Name: tipos_impuestos tipos_impuestos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_impuestos
    ADD CONSTRAINT tipos_impuestos_pkey PRIMARY KEY (id_tip_impuesto);


--
-- Name: tipos_items tipos_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_items
    ADD CONSTRAINT tipos_items_pkey PRIMARY KEY (id_tip_item);


--
-- Name: stock uk_id_item; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT uk_id_item UNIQUE (id_item);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario);


--
-- Name: usuarios_sucursales usuarios_sucursales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_sucursales
    ADD CONSTRAINT usuarios_sucursales_pkey PRIMARY KEY (id_usuario, id_sucursal);


--
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_pkey PRIMARY KEY (id_vped);


--
-- Name: ventas_pedidos_detalle ventas_pedidos_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_detalle
    ADD CONSTRAINT ventas_pedidos_detalle_pkey PRIMARY KEY (id_vped, id_item);


--
-- Name: accesos accesos_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accesos
    ADD CONSTRAINT accesos_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- Name: auth_2fa auth_2fa_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_2fa
    ADD CONSTRAINT auth_2fa_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario) ON DELETE CASCADE;


--
-- Name: ciudades ciudades_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ciudades
    ADD CONSTRAINT ciudades_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.paises(id_pais);


--
-- Name: clientes clientes_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.personas(id_persona);


--
-- Name: comp_cuentas_pagar comp_cuentas_pagar_cue_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_cuentas_pagar
    ADD CONSTRAINT comp_cuentas_pagar_cue_id_cc_fkey FOREIGN KEY (cue_id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- Name: compras_cabecera compras_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: compras_cabecera compras_cabecera_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- Name: compras_cabecera compras_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_cabecera
    ADD CONSTRAINT compras_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: compras_detalle compras_detalle_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_detalle
    ADD CONSTRAINT compras_detalle_id_cc_fkey FOREIGN KEY (id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- Name: compras_detalle compras_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_detalle
    ADD CONSTRAINT compras_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.stock(id_item);


--
-- Name: compras_orden_cabecera compras_orden_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: compras_orden_cabecera compras_orden_cabecera_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- Name: compras_orden_cabecera compras_orden_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_cabecera
    ADD CONSTRAINT compras_orden_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: compras_orden_detalle compras_orden_detalle_id_corden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_detalle
    ADD CONSTRAINT compras_orden_detalle_id_corden_fkey FOREIGN KEY (id_corden) REFERENCES public.compras_orden_cabecera(id_corden);


--
-- Name: compras_orden_detalle compras_orden_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_detalle
    ADD CONSTRAINT compras_orden_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- Name: compras_orden compras_orden_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_id_cc_fkey FOREIGN KEY (id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- Name: compras_orden compras_orden_id_corden_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_id_corden_id_item_fkey FOREIGN KEY (id_corden, id_item) REFERENCES public.compras_orden_detalle(id_corden, id_item);


--
-- Name: compras_orden compras_orden_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden
    ADD CONSTRAINT compras_orden_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.stock(id_item);


--
-- Name: compras_orden_presu compras_orden_presu_id_corden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_presu
    ADD CONSTRAINT compras_orden_presu_id_corden_fkey FOREIGN KEY (id_corden) REFERENCES public.compras_orden_cabecera(id_corden);


--
-- Name: compras_orden_presu compras_orden_presu_id_cpre_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_orden_presu
    ADD CONSTRAINT compras_orden_presu_id_cpre_id_item_fkey FOREIGN KEY (id_cpre, id_item) REFERENCES public.compras_presupuestos_detalle(id_cpre, id_item);


--
-- Name: compras_pedidos_cabecera compras_pedidos_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_cabecera
    ADD CONSTRAINT compras_pedidos_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: compras_pedidos_cabecera compras_pedidos_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_cabecera
    ADD CONSTRAINT compras_pedidos_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: compras_pedidos_detalles compras_pedidos_detalles_id_cp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_detalles
    ADD CONSTRAINT compras_pedidos_detalles_id_cp_fkey FOREIGN KEY (id_cp) REFERENCES public.compras_pedidos_cabecera(id_cp);


--
-- Name: compras_pedidos_detalles compras_pedidos_detalles_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_pedidos_detalles
    ADD CONSTRAINT compras_pedidos_detalles_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- Name: compras_presupuestos_cabecera compras_presupuestos_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_cabecera
    ADD CONSTRAINT compras_presupuestos_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: compras_presupuestos_detalle compras_presupuestos_detalle_id_cpre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_detalle
    ADD CONSTRAINT compras_presupuestos_detalle_id_cpre_fkey FOREIGN KEY (id_cpre) REFERENCES public.compras_presupuestos_cabecera(id_cpre);


--
-- Name: compras_presupuestos_detalle compras_presupuestos_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_detalle
    ADD CONSTRAINT compras_presupuestos_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- Name: compras_presupuestos_pedidos compras_presupuestos_pedidos_id_cp_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_pedidos
    ADD CONSTRAINT compras_presupuestos_pedidos_id_cp_id_item_fkey FOREIGN KEY (id_cp, id_item) REFERENCES public.compras_pedidos_detalles(id_cp, id_item);


--
-- Name: compras_presupuestos_pedidos compras_presupuestos_pedidos_id_cpre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compras_presupuestos_pedidos
    ADD CONSTRAINT compras_presupuestos_pedidos_id_cpre_fkey FOREIGN KEY (id_cpre) REFERENCES public.compras_presupuestos_cabecera(id_cpre);


--
-- Name: deposito deposito_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deposito
    ADD CONSTRAINT deposito_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: funcionarios funcionarios_id_cargo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_id_cargo_fkey FOREIGN KEY (id_cargo) REFERENCES public.cargos(id_cargo);


--
-- Name: funcionarios funcionarios_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.personas(id_persona);


--
-- Name: items items_id_mar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_mar_fkey FOREIGN KEY (id_mar) REFERENCES public.marcas(id_mar);


--
-- Name: items items_id_tip_impuesto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_tip_impuesto_fkey FOREIGN KEY (id_tip_impuesto) REFERENCES public.tipos_impuestos(id_tip_impuesto);


--
-- Name: items items_id_tip_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_tip_item_fkey FOREIGN KEY (id_tip_item) REFERENCES public.tipos_items(id_tip_item);


--
-- Name: libro_compras libro_compras_lib_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.libro_compras
    ADD CONSTRAINT libro_compras_lib_id_cc_fkey FOREIGN KEY (lib_id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- Name: paginas paginas_id_modulo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paginas
    ADD CONSTRAINT paginas_id_modulo_fkey FOREIGN KEY (id_modulo) REFERENCES public.modulos(id_modulo);


--
-- Name: permisos permisos_id_accion_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_accion_fkey FOREIGN KEY (id_accion) REFERENCES public.acciones(id_accion);


--
-- Name: permisos permisos_id_grupo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_grupo_fkey FOREIGN KEY (id_grupo) REFERENCES public.grupos(id_grupo);


--
-- Name: permisos permisos_id_pagina_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_id_pagina_fkey FOREIGN KEY (id_pagina) REFERENCES public.paginas(id_pagina);


--
-- Name: personal_trainers personal_trainers_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_trainers
    ADD CONSTRAINT personal_trainers_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: personas personas_id_ciudad_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_id_ciudad_fkey FOREIGN KEY (id_ciudad) REFERENCES public.ciudades(id_ciudad);


--
-- Name: personas personas_id_ecivil_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_id_ecivil_fkey FOREIGN KEY (id_ecivil) REFERENCES public.estado_civiles(id_ecivil);


--
-- Name: personas personas_id_genero_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personas
    ADD CONSTRAINT personas_id_genero_fkey FOREIGN KEY (id_genero) REFERENCES public.generos(id_genero);


--
-- Name: planes_servicios planes_servicios_id_tip_impuesto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planes_servicios
    ADD CONSTRAINT planes_servicios_id_tip_impuesto_fkey FOREIGN KEY (id_tip_impuesto) REFERENCES public.tipos_impuestos(id_tip_impuesto);


--
-- Name: proveedores proveedores_id_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_id_persona_fkey FOREIGN KEY (id_persona) REFERENCES public.personas(id_persona);


--
-- Name: serv_inscripciones_membresias serv_inscripciones_membresias_id_inscrip_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_inscripciones_membresias
    ADD CONSTRAINT serv_inscripciones_membresias_id_inscrip_fkey FOREIGN KEY (id_inscrip, id_plan_servi) REFERENCES public.servicios_inscripciones_detalle(id_inscrip, id_plan_servi);


--
-- Name: serv_inscripciones_membresias serv_inscripciones_membresias_id_mem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_inscripciones_membresias
    ADD CONSTRAINT serv_inscripciones_membresias_id_mem_fkey FOREIGN KEY (id_mem) REFERENCES public.serv_membresias_cab(id_mem);


--
-- Name: serv_membresias_cab serv_membresias_cab_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_cab
    ADD CONSTRAINT serv_membresias_cab_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: serv_membresias_cab serv_membresias_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_cab
    ADD CONSTRAINT serv_membresias_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: serv_membresias_cab serv_membresias_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_cab
    ADD CONSTRAINT serv_membresias_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: serv_membresias_det serv_membresias_det_id_mem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_det
    ADD CONSTRAINT serv_membresias_det_id_mem_fkey FOREIGN KEY (id_mem) REFERENCES public.serv_membresias_cab(id_mem);


--
-- Name: serv_membresias_det serv_membresias_det_id_plan_servi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_membresias_det
    ADD CONSTRAINT serv_membresias_det_id_plan_servi_fkey FOREIGN KEY (id_plan_servi) REFERENCES public.planes_servicios(id_plan_servi);


--
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: servicios_inscripciones_cabecera servicios_inscripciones_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_cabecera
    ADD CONSTRAINT servicios_inscripciones_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: servicios_inscripciones_detalle servicios_inscripciones_detalle_id_inscrip_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_detalle
    ADD CONSTRAINT servicios_inscripciones_detalle_id_inscrip_fkey FOREIGN KEY (id_inscrip) REFERENCES public.servicios_inscripciones_cabecera(id_inscrip);


--
-- Name: servicios_inscripciones_detalle servicios_inscripciones_detalle_id_plan_servi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servicios_inscripciones_detalle
    ADD CONSTRAINT servicios_inscripciones_detalle_id_plan_servi_fkey FOREIGN KEY (id_plan_servi) REFERENCES public.planes_servicios(id_plan_servi);


--
-- Name: stock stock_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- Name: stock stock_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.deposito(id_sucursal);


--
-- Name: sucursales sucursales_id_empresa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sucursales
    ADD CONSTRAINT sucursales_id_empresa_fkey FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa);


--
-- Name: usuarios usuarios_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: usuarios usuarios_id_grupo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_grupo_fkey FOREIGN KEY (id_grupo) REFERENCES public.grupos(id_grupo);


--
-- Name: usuarios usuarios_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: usuarios_sucursales usuarios_sucursales_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_sucursales
    ADD CONSTRAINT usuarios_sucursales_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: usuarios_sucursales usuarios_sucursales_id_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuarios_sucursales
    ADD CONSTRAINT usuarios_sucursales_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario);


--
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: ventas_pedidos_cabecera ventas_pedidos_cabecera_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_cabecera
    ADD CONSTRAINT ventas_pedidos_cabecera_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: ventas_pedidos_detalle ventas_pedidos_detalle_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_detalle
    ADD CONSTRAINT ventas_pedidos_detalle_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- Name: ventas_pedidos_detalle ventas_pedidos_detalle_id_vped_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ventas_pedidos_detalle
    ADD CONSTRAINT ventas_pedidos_detalle_id_vped_fkey FOREIGN KEY (id_vped) REFERENCES public.ventas_pedidos_cabecera(id_vped);


--
-- PostgreSQL database dump complete
--

