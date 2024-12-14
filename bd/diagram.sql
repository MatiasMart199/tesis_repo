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
    'VENCIDO',
    'DEVOLUCION',
    'APLICADA',
    'ENVIADO'
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
-- Name: sp_alimentaciones(integer, date, date, character varying, text, text, integer, integer, integer, integer, integer, integer, character varying, numeric, numeric, numeric, numeric, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_alimentaciones(xid_ali integer, xali_fecha date, xali_fecha_fin date, xali_objetivo character varying, xali_dias text, xali_observacion text, xid_plan_servi integer, xid_cliente integer, xid_nutriologo integer, xid_sucursal integer, xid_funcionario integer, xid_act integer, xalimento character varying, xcantidad numeric, xcalorias numeric, xcarbohidratos numeric, xproteinas numeric, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN 
    	--INCERTAR CABECERA--
        INSERT INTO serv_alimentaciones_cab (id_ali,ali_fecha,ali_fecha_fin,ali_objetivo,ali_dias,ali_observacion,id_plan_servi,id_cliente,id_nutriologo,id_sucursal,id_funcionario,estado,auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_ali), 0) + 1 FROM serv_alimentaciones_cab),
            xali_fecha,
            xali_fecha_fin,
            xali_objetivo,
            xali_dias,
            xali_observacion,
            xid_plan_servi,
            xid_cliente,
            xid_nutriologo,
            xid_sucursal,
            xid_funcionario,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN 
    -- MODIFICAR CABECERA --
        UPDATE serv_alimentaciones_cab 
        SET ali_fecha = xali_fecha,
        	ali_fecha_fin = xali_fecha_fin,
        	ali_objetivo = xali_objetivo,
        	ali_dias = xali_dias,
            ali_observacion = xali_observacion,
            id_plan_servi = xid_plan_servi,
            id_cliente = xid_cliente,
            id_nutriologo = xid_nutriologo,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_ali = xid_ali;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN 
    -- CONFIRMAR CABECERA
        UPDATE serv_alimentaciones_cab
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_ali = xid_ali;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
    ELSIF operacion = 4 THEN 
    -- ANULAR CABECERA
        UPDATE serv_alimentaciones_cab
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_ali = xid_ali;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
       
    ELSIF operacion = 5 THEN 

	  		-- INSERTAR DETALLES
        INSERT INTO serv_alimentaciones_det (id_ali,id_act,alimento,cantidad,calorias,carbohidratos,proteinas,auditoria)
        VALUES (xid_ali, xid_act, xalimento, xcantidad, xcalorias,xcarbohidratos,xproteinas,
       'INSERCION DETALLE/' || usuario || '/' || NOW());
	    RAISE NOTICE 'MEDICIÓN AÑADIDO CON ÉXITO';
       

    ELSIF operacion = 6 THEN 
    -- MODIFICAR DETALLE --
        UPDATE serv_alimentaciones_det SET 
        id_act = xid_act,
        alimento = xalimento,
        cantidad = xcantidad,
        calorias = xcalorias,
        carbohidratos = xcarbohidratos,
        proteinas = xproteinas,
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION DE DETALLE/' || usuario || '/' || NOW()
        WHERE id_ali = xid_ali AND id_act = xid_act;
        RAISE NOTICE 'MEDICIÓN MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN 
    -- ELIMINAR DETALLE
    DELETE FROM serv_alimentaciones_det
        WHERE id_ali = xid_ali AND id_act = xid_act;
        RAISE NOTICE 'MEDICIÓN ELIMINADO CON ÉXITO';
   
    END IF;
END;
$$;


ALTER FUNCTION public.sp_alimentaciones(xid_ali integer, xali_fecha date, xali_fecha_fin date, xali_objetivo character varying, xali_dias text, xali_observacion text, xid_plan_servi integer, xid_cliente integer, xid_nutriologo integer, xid_sucursal integer, xid_funcionario integer, xid_act integer, xalimento character varying, xcantidad numeric, xcalorias numeric, xcarbohidratos numeric, xproteinas numeric, usuario character varying, operacion integer) OWNER TO postgres;

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
-- Name: sp_comp_ajustes(integer, date, integer, integer, text, integer, integer, character varying, character varying, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_comp_ajustes(xid_caju integer, xaju_fecha date, xid_sucursal integer, xid_funcionario integer, xaju_observacion text, xid_deposito integer, xid_motivo integer, xmot_tipo_ajuste character varying, xmot_descrip character varying, xid_item integer, xcantidad integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN 
    IF operacion = 1 THEN --INSERTAR CABECERA
        
        PERFORM * FROM comp_ajustes_cab WHERE id_sucursal = xid_sucursal AND estado = 'PENDIENTE'; 
        IF FOUND THEN
            RAISE EXCEPTION 'EXISTEN AJUSTE PENDIENTES DE CONFIRMACIÓN';
        END IF;
        
        -- Inserta 
        INSERT INTO comp_ajustes_cab (id_caju, aju_fecha, id_sucursal, id_funcionario, estado, auditoria, aju_observacion)
		VALUES ((SELECT COALESCE(MAX(id_caju), 0) + 1 FROM comp_ajustes_cab), 
		Xaju_fecha, xid_sucursal, xid_funcionario, 'PENDIENTE', 'INSERCION/' || usuario || '/' || NOW(), xaju_observacion);
        
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    ELSIF operacion = 2 THEN -- MODIFICAR CABECERA
        -- Comprueba si  existe y está pendiente.
        PERFORM * FROM comp_ajustes_cab WHERE id_caju = xid_caju AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE AJUSTE NO SE PUEDE MODIFICAR O NO EXISTE';
        END IF;
        
        -- Actualiza la cabecera .
        UPDATE comp_ajustes_cab SET 
        aju_fecha = xaju_fecha, 
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW(),
        aju_observacion = xaju_observacion
        WHERE id_caju = xid_caju;
        
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    ELSIF operacion = 3 THEN -- CONFIRMAR CABECERA
        -- Comprueba si existe y está pendiente.
        PERFORM * FROM comp_ajustes_cab WHERE id_caju = xid_caju AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE AJUSTE NO SE PUEDE CONFIRMAR O NO EXISTE';
        END IF;
       PERFORM * FROM comp_ajustes_det cpd WHERE id_caju = xid_caju; 
       IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE AJUSTE NO POSEE DETALLES CARGADOS';
        END IF;
        
        -- Actualiza el estado a 'CONFIRMADO'.
        UPDATE comp_ajustes_cab SET estado = 'CONFIRMADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_caju = xid_caju;
        
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
    ELSIF operacion = 4 THEN -- ANULAR CABECERA
        -- Comprueba si  existe y está pendiente.
        PERFORM * FROM comp_ajustes_cab WHERE id_caju = xid_caju AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE AJUSTE NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
        
        -- Actualiza el estado  a 'ANULADO'.
        UPDATE comp_ajustes_cab SET estado = 'ANULADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_caju = xid_caju;
        
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- INSERTAR DETALLE
        -- Comprueba si existe y está pendiente.
        PERFORM * FROM comp_ajustes_cab WHERE id_caju = xid_caju AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'A ESTE AJUSTE NO SE PUEDEN AGREGAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Comprueba si el producto ya ha sido registrado
        PERFORM * FROM comp_ajustes_det WHERE id_caju = xid_caju AND id_item = xid_item;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE PRODUCTO YA HA SIDO REGISTRADO EN EL AJUSTE';
        END IF;
        -- Inserta el detalle 
     

        INSERT INTO comp_ajustes_det (id_caju, id_item, id_motivo, cantidad, precio, auditoria)
        VALUES (xid_caju, xid_item, xid_motivo, xcantidad, (SELECT precio_compra FROM items WHERE id_item = xid_item), 
       'INSERCION/' || usuario || '/' || NOW());
       
     
    -- ACTUALIZAR STOCK
	    IF xmot_tipo_ajuste = 'POSITIVO' THEN
	        -- Actualizar stock sumando la cantidad
	        UPDATE stock
	        SET stock_cantidad = stock_cantidad + xcantidad
	        WHERE id_sucursal = xid_deposito AND id_item = xid_item;
	       
	    elseif xmot_tipo_ajuste = 'NEGATIVO' then
			     -- Verificar que la cantidad en stock no sea menor a la cantidad a reducir
		        IF (SELECT stock_cantidad FROM stock WHERE id_sucursal = xid_deposito AND id_item = xid_item) < xcantidad THEN
		            RAISE EXCEPTION 'STOCK INSUFICIENTE PARA REALIZAR LA REDUCCIÓN';
		        END IF;
       
	    -- Actualizar stock restando la cantidad
	       UPDATE stock
	        SET stock_cantidad = stock_cantidad - xcantidad
	        WHERE id_sucursal = xid_deposito AND id_item = xid_item;
	    END IF;
	       
        RAISE NOTICE 'PRODUCTO AÑADIDO CON ÉXITO';
    ELSIF operacion = 6 THEN -- MODIFICAR DETALLE
        -- Comprueba si existe y está pendiente.
        PERFORM * FROM comp_ajustes_cab WHERE id_caju = xid_caju AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE AJUSTE NO SE PUEDEN MODIFICAR CANTIDADES O NO EXISTE';
        END IF;
        
        -- Actualiza la cantidad y el precio del detalle
        UPDATE comp_ajustes_det SET cantidad = xcantidad, precio = (SELECT precio_compra FROM items where id_item = xid_item)
        WHERE id_caju = xid_caju AND id_item = xid_item;
        
        RAISE NOTICE 'CANTIDAD MODIFICADA CON ÉXITO';
    ELSIF operacion = 7 THEN -- ELIMINAR DETALLE
        -- Comprueba si  existe y está pendiente.
        PERFORM * FROM comp_ajustes_cab WHERE id_caju = xid_caju AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE AJUSTE NO SE PUEDEN ELIMINAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Elimina 
        DELETE FROM comp_ajustes_det WHERE id_caju = xid_caju AND id_item = xid_item;       
        
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_comp_ajustes(xid_caju integer, xaju_fecha date, xid_sucursal integer, xid_funcionario integer, xaju_observacion text, xid_deposito integer, xid_motivo integer, xmot_tipo_ajuste character varying, xmot_descrip character varying, xid_item integer, xcantidad integer, usuario character varying, operacion integer) OWNER TO postgres;

--
-- Name: sp_comp_nota(integer, date, date, character varying, integer, integer, integer, integer, integer, numeric, numeric, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_comp_nota(xid_not integer, xnot_fecha date, xnot_fecha_docu date, xnot_tipo_nota character varying, xid_cc integer, xid_sucursal integer, xid_funcionario integer, xid_proveedor integer, xid_item integer, xcantidad numeric, xmonto numeric, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN -- Insertar compra_pedido_cabecera
        -- Comprueba si hay pedidos pendientes de confirmación para esta sucursal.
        PERFORM * FROM comp_nota_cab WHERE id_sucursal = xid_sucursal AND estado = 'PENDIENTE'; 
        IF FOUND THEN
            RAISE EXCEPTION 'EXISTEN MOVIMIENTO PENDIENTES DE CONFIRMACIÓN';
        END IF;
        
        -- Inserta 
        INSERT INTO comp_nota_cab (id_not,not_fecha,not_fecha_docu,not_tipo_nota,id_cc,id_sucursal,id_funcionario,id_proveedor,estado,auditoria)
		VALUES ((SELECT COALESCE(MAX(id_not), 0) + 1 FROM comp_nota_cab), 
				xnot_fecha, 
				xnot_fecha_docu,
				xnot_tipo_nota,
				xid_cc, 
				xid_sucursal, 
				xid_funcionario,
				xid_proveedor, 'PENDIENTE', 'INSERCION/' || usuario || '/' || NOW());
			
				--AUTOMATISACION DE INSERCION PROCESO CONECTADO
	     FOR d IN SELECT * FROM v_compras_consolidacion WHERE id_cc = xid_cc LOOP
	            INSERT INTO comp_nota_det(id_not,id_item,cantidad,precio,monto)
	            VALUES ((select max(id_not) from comp_nota_cab), d.id_item, d.catidad, d.precio, 0);
	        END LOOP;
        
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    ELSIF operacion = 2 THEN -- Modificar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM comp_nota_cab WHERE id_not = xid_not AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO SE PUEDE MODIFICAR O NO EXISTE';
        END IF;
        
        -- Actualiza la cabecera del pedido.
        UPDATE comp_nota_cab SET 
        not_fecha = xnot_fecha, 
        not_fecha_docu = xnot_fecha_docu,
        not_tipo_nota = xnot_tipo_nota,
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_not = xid_not;
        
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    ELSIF operacion = 3 THEN -- Confirmar compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM comp_nota_cab WHERE id_not = xid_not AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO SE PUEDE CONFIRMAR O NO EXISTE';
        END IF;
       PERFORM * FROM comp_nota_det cpd WHERE id_not = xid_not; 
       IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO POSEE DETALLES CARGADOS';
        END IF;
        
        -- Actualiza el estado del pedido a 'CONFIRMADO'.
        UPDATE comp_nota_cab SET estado = 'CONFIRMADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_not = xid_not;
        
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
    ELSIF operacion = 4 THEN -- Anular compra_pedido_cabecera
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM comp_nota_cab WHERE id_not = xid_not AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
        
        -- Actualiza el estado del pedido a 'ANULADO'.
        UPDATE comp_nota_cab SET estado = 'ANULADO', auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_not = xid_not;
        
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM comp_nota_cab WHERE id_not = xid_not AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'A ESTE MOVIMIENTO NO SE PUEDEN AGREGAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Comprueba si el producto ya ha sido registrado en el pedido.
        PERFORM * FROM comp_nota_det WHERE id_not = xid_not AND id_item = xid_item;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE ITEM YA HA SIDO REGISTRADO EN EL PEDIDO';
        END IF;
        
        -- Inserta el detalle del pedido.
        INSERT INTO comp_nota_det (id_not,id_item,cantidad,precio,monto)
        VALUES (xid_not, xid_item, xcantidad, (SELECT precio_compra FROM items WHERE id_item = xid_item),xmonto);
        
        RAISE NOTICE 'ITEM AÑADIDO CON ÉXITO';
    ELSIF operacion = 6 THEN -- Modificar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM comp_nota_cab WHERE id_not = xid_not AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE MOVIMIENTO NO SE PUEDEN MODIFICAR CANTIDADES O NO EXISTE';
        END IF;
        
        -- Actualiza la cantidad y el precio del detalle del pedido.
        UPDATE comp_nota_det SET cantidad = xcantidad, precio = (SELECT precio_compra FROM items WHERE id_item = xid_item)
        WHERE id_not = xid_not AND id_item = xid_item;
        
        RAISE NOTICE 'CANTIDAD MODIFICADA CON ÉXITO';
    ELSIF operacion = 7 THEN -- Eliminar compra_pedido_detalle
        -- Comprueba si el pedido existe y está pendiente.
        PERFORM * FROM comp_nota_cab WHERE id_not = xid_not AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE MOVIMIENTO NO SE PUEDEN ELIMINAR ITEM O NO EXISTE';
        END IF;
        
        -- Elimina el detalle del pedido.
        DELETE FROM comp_nota_det WHERE id_not = xid_not AND id_item = xid_item;
        
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_comp_nota(xid_not integer, xnot_fecha date, xnot_fecha_docu date, xnot_tipo_nota character varying, xid_cc integer, xid_sucursal integer, xid_funcionario integer, xid_proveedor integer, xid_item integer, xcantidad numeric, xmonto numeric, usuario character varying, operacion integer) OWNER TO postgres;

--
-- Name: sp_comp_transfers(integer, date, date, date, integer, integer, integer, integer, integer, integer, integer, integer, text, integer, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_comp_transfers(xid_tra integer, xtra_fecha_elabo date, xtra_fecha_salida date, xtra_fecha_recep date, xid_sucursal integer, xid_funcionario integer, xid_sucursal_ori integer, xid_sucursal_des integer, xid_deposito_ori integer, xid_deposito_des integer, xid_vehiculo integer, xid_chofer integer, xobservacion text, xid_item integer, xcantidad integer, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN -- Insertar 
        
        -- Inserta 
        INSERT INTO comp_transfers_cab (id_tra,tra_fecha_elabo,tra_fecha_salida,tra_fecha_recep,id_sucursal,id_funcionario,id_sucursal_ori,id_sucursal_des,id_deposito_ori,id_deposito_des,id_vehiculo,id_chofer,observacion,estado,auditoria)
		VALUES ((SELECT COALESCE(MAX(id_tra), 0) + 1 FROM comp_transfers_cab), 
				xtra_fecha_elabo,
				xtra_fecha_salida,
				xtra_fecha_recep, 
				xid_sucursal, 
				xid_funcionario,
				xid_sucursal_ori,
				xid_sucursal_des,
				xid_deposito_ori,
				xid_deposito_des,
				xid_vehiculo,
				xid_chofer,
				xobservacion,
				'PENDIENTE',
				'INSERCION/' || usuario || '/' || NOW());
        
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
    ELSIF operacion = 2 THEN -- Modificar 
        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO SE PUEDE MODIFICAR O NO EXISTE';
        END IF;
        
        -- Actualiza 
        UPDATE comp_transfers_cab SET 
        tra_fecha_salida = xtra_fecha_salida, 
        tra_fecha_recep = xtra_fecha_recep,
        id_sucursal_ori = xid_sucursal_ori,
        id_sucursal_des = xid_sucursal_des,
        id_deposito_ori = xid_deposito_ori,
        id_deposito_des = xid_deposito_des,
        id_vehiculo = xid_vehiculo,
        id_chofer = xid_chofer,
        observacion = xobservacion,
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_tra = xid_tra;
        
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
    ELSIF operacion = 3 THEN -- Confirmar 
    --------------------------------------------------------------------------------------------------------------------
					        -- Comprueba que la cabecera esté pendiente antes de confirmar
					        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'ENVIADO'; 
					        IF NOT FOUND THEN
					            RAISE EXCEPTION 'ESTE MOVIMIENTO NO FUE ENVIADO O NO EXISTE';
					        END IF;
					       
					        -- Comprueba que existen detalles asociados a la transferencia
					        PERFORM * FROM comp_transfers_det WHERE id_tra = xid_tra; 
					        IF NOT FOUND THEN
					            RAISE EXCEPTION 'ESTE MOVIMIENTO NO POSEE DETALLES CARGADOS';
					        END IF;
					        
					        FOR d IN SELECT id_item, cantidad FROM comp_transfers_det WHERE id_tra = xid_tra LOOP
							    BEGIN
							        -- Intenta insertar primero
							        INSERT INTO stock (id_sucursal, id_item, stock_cantidad, estado)
							        VALUES (xid_deposito_des, d.id_item, d.cantidad, 'ACTIVO');
							       
							    EXCEPTION WHEN unique_violation THEN
							        -- Si ya existe, actualiza el stock existente
							        UPDATE stock SET 
							        stock_cantidad = stock_cantidad + d.cantidad
							        WHERE id_sucursal = xid_deposito_des AND id_item = d.id_item;
							    END;
							
							    -- Actualiza el stock del depósito origen
							    UPDATE stock
							    SET stock_cantidad = stock_cantidad - d.cantidad
							    WHERE id_sucursal = xid_deposito_ori AND id_item = d.id_item;
							   
							END LOOP;

					
					        -- Actualiza el estado de la cabecera a CONFIRMADO
					        UPDATE comp_transfers_cab SET 
					            tra_fecha_recep = xtra_fecha_recep,
					            estado = 'CONFIRMADO', 
					            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
					        WHERE id_tra = xid_tra;
					        
					        RAISE NOTICE 'TRANSFERENCIA CONFIRMADA CON ÉXITO';
					       -------------------------------------------------------------------------------------------------------------------
    ELSIF operacion = 4 THEN -- Anular 
        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO SE PUEDE ANULAR O NO EXISTE';
        END IF;
        
        -- Actualiza el estado a 'ANULADO'.
        UPDATE comp_transfers_cab SET 
        estado = 'ANULADO', 
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_tra = xid_tra;
        
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
    ELSIF operacion = 5 THEN -- Insertar 
        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'A ESTE MOVIMIENTO NO SE PUEDEN AGREGAR PRODUCTOS O NO EXISTE';
        END IF;
        
        -- Comprueba si el producto ya ha sido registrado en e
        PERFORM * FROM comp_transfers_det WHERE id_tra = xid_tra AND id_item = xid_item;
        IF FOUND THEN
            RAISE EXCEPTION 'ESTE ITEM YA HA SIDO REGISTRADO EN EL PEDIDO';
        END IF;
        
        -- Inserta el detalle
        INSERT INTO comp_transfers_det (id_tra,id_item,cantidad,auditoria)
        VALUES (xid_tra, xid_item, xcantidad,'INSERCION/' || usuario || '/' || NOW());
        
        RAISE NOTICE 'ITEM AÑADIDO CON ÉXITO';
    ELSIF operacion = 6 THEN -- Modificar 
        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE MOVIMIENTO NO SE PUEDEN MODIFICAR CANTIDADES O NO EXISTE';
        END IF;
        
        -- Actualiza la cantidad del detalle 
        UPDATE comp_transfers_det SET 
        cantidad = xcantidad
        WHERE id_tra = xid_tra AND id_item = xid_item;
        
        RAISE NOTICE 'CANTIDAD MODIFICADA CON ÉXITO';
    ELSIF operacion = 7 THEN -- Eliminar 
        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'PENDIENTE';
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'A ESTE MOVIMIENTO NO SE PUEDEN ELIMINAR ITEM O NO EXISTE';
        END IF;
        
        -- Elimina el detalle.
        DELETE FROM comp_transfers_det WHERE id_tra = xid_tra AND id_item = xid_item;
        
        RAISE NOTICE 'PRODUCTO ELIMINADO CON ÉXITO';
       
     ELSIF operacion = 8 THEN -- Eliminar 
        PERFORM * FROM comp_transfers_cab WHERE id_tra = xid_tra AND estado = 'PENDIENTE'; 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO SE PUEDE ENVIAR O NO EXISTE';
        END IF;
       PERFORM * FROM comp_transfers_det cpd WHERE id_tra = xid_tra; 
       IF NOT FOUND THEN
            RAISE EXCEPTION 'ESTE MOVIMIENTO NO POSEE DETALLES CARGADOS';
        END IF;
        
        -- Actualiza el estado del pedido a 'CONFIRMADO'.
        UPDATE comp_transfers_cab set
        tra_fecha_salida = xtra_fecha_salida,
        estado = 'ENVIADO', 
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'ENVIADO/' || usuario || '/' || NOW() 
        WHERE id_tra = xid_tra;
        
        RAISE NOTICE 'DATOS ENVIADOS CON ÉXITO';
    END IF;
   EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.sp_comp_transfers(xid_tra integer, xtra_fecha_elabo date, xtra_fecha_salida date, xtra_fecha_recep date, xid_sucursal integer, xid_funcionario integer, xid_sucursal_ori integer, xid_sucursal_des integer, xid_deposito_ori integer, xid_deposito_des integer, xid_vehiculo integer, xid_chofer integer, xobservacion text, xid_item integer, xcantidad integer, usuario character varying, operacion integer) OWNER TO postgres;

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
      RAISE NOTICE 'CUENTA Y LIBRO DE COMPRA GENERADO  CON ÉXITO';
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
-- Name: sp_mediciones(integer, date, integer, text, integer, integer, integer, integer, integer, numeric, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_mediciones(xid_med integer, xmed_fecha date, xmed_edad integer, xmed_observacion text, xid_cliente integer, xid_personal integer, xid_sucursal integer, xid_funcionario integer, xid_act integer, xvalor numeric, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN 
    	--INCERTAR CABECERA--
        INSERT INTO serv_mediciones_cab (id_med,med_fecha,med_edad,med_observacion,id_cliente,id_personal,id_sucursal,id_funcionario,estado,auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_med), 0) + 1 FROM serv_mediciones_cab),
            xmed_fecha,
            xmed_edad,
            xmed_observacion,
            xid_cliente,
            xid_personal,
            xid_sucursal,
            xid_funcionario,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN 
    -- MODIFICAR CABECERA --
        UPDATE serv_mediciones_cab
        SET med_fecha = xmed_fecha,
        	med_edad = xmed_edad,
            med_observacion = xmed_observacion,
            id_cliente = xid_cliente,
            id_personal = xid_personal,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_med = xid_med;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN 
    -- CONFIRMAR CABECERA
        UPDATE serv_mediciones_cab
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_med = xid_med;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
    ELSIF operacion = 4 THEN 
    -- ANULAR CABECERA
        UPDATE serv_mediciones_cab
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_med = xid_med;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
       
    ELSIF operacion = 5 THEN 

	  		-- INSERTAR DETALLES
        INSERT INTO serv_mediciones_det (id_med,id_act,valor,auditoria)
        VALUES (xid_med, xid_act, xvalor,
       'INSERCION DETALLE/' || usuario || '/' || NOW());
	    RAISE NOTICE 'MEDICIÓN AÑADIDO CON ÉXITO';
       

    ELSIF operacion = 6 THEN 
    -- MODIFICAR DETALLE --
        UPDATE serv_mediciones_det SET 
        id_act = xid_act,
        valor = xvalor,
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION DE DETALLE/' || usuario || '/' || NOW()
        WHERE id_med = xid_med AND id_act = xid_act;
        RAISE NOTICE 'MEDICIÓN MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN 
    -- ELIMINAR DETALLE
    DELETE FROM serv_mediciones_det
        WHERE id_med = xid_med AND id_act = xid_act;
        RAISE NOTICE 'MEDICIÓN ELIMINADO CON ÉXITO';
   
    END IF;
END;
$$;


ALTER FUNCTION public.sp_mediciones(xid_med integer, xmed_fecha date, xmed_edad integer, xmed_observacion text, xid_cliente integer, xid_personal integer, xid_sucursal integer, xid_funcionario integer, xid_act integer, xvalor numeric, usuario character varying, operacion integer) OWNER TO postgres;

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
            VALUES (xid_mem, d.id_inscrip, d.id_plan_servi, d.dia, d.precio);
           
        END LOOP;
       
        RAISE NOTICE 'PEDIDO AÑADIDOS CON ÉXITO Y CERRADO';
       
    ELSIF operacion = 9 THEN 
    --MODIFICAR PROCESO CONECTADO
        UPDATE serv_inscripciones_membresias
        SET dias = xdias, precio = xprecio
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
-- Name: sp_rutinas(integer, date, integer, text, integer, integer, integer, integer, integer, integer, integer, integer, numeric, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_rutinas(xid_rut integer, xrut_fecha date, xrut_edad integer, xrut_observacion text, xid_plan_servi integer, xid_cliente integer, xid_personal integer, xid_sucursal integer, xid_funcionario integer, xid_act integer, xserie integer, xrepeticion integer, xpeso numeric, xejercicio character varying, usuario character varying, operacion integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    d RECORD;
BEGIN 
    IF operacion = 1 THEN 
    	--INCERTAR CABECERA--
        INSERT INTO serv_rutinas_cab (id_rut,rut_fecha,rut_edad,rut_observacion,id_plan_servi,id_cliente,id_personal,id_sucursal,id_funcionario,estado,auditoria)
        VALUES (
            (SELECT COALESCE(MAX(id_rut), 0) + 1 FROM serv_rutinas_cab),
            xrut_fecha,
            xrut_edad,
            xrut_observacion,
            xid_plan_servi,
            xid_cliente,
            xid_personal,
            xid_sucursal,
            xid_funcionario,
            'PENDIENTE',
            'INSERCION/' || usuario || '/' || NOW()
        );
        RAISE NOTICE 'DATOS GUARDADOS CON ÉXITO';
       
       
    ELSIF operacion = 2 THEN 
    -- MODIFICAR CABECERA --
        UPDATE serv_rutinas_cab 
        SET rut_fecha = xrut_fecha,
        	rut_edad = xrut_edad,
            rut_observacion = xrut_observacion,
            id_plan_servi = xid_plan_servi,
            id_cliente = xid_cliente,
            id_personal = xid_personal,
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION/' || usuario || '/' || NOW()
        WHERE id_med = xid_med;
        RAISE NOTICE 'DATOS MODIFICADOS CON ÉXITO';
       
       
    ELSIF operacion = 3 THEN 
    -- CONFIRMAR CABECERA
        UPDATE serv_rutinas_cab
        SET estado = 'CONFIRMADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'CONFIRMACION/' || usuario || '/' || NOW() 
        WHERE id_rut = xid_rut;
        RAISE NOTICE 'DATOS CONFIRMADOS CON ÉXITO';
       
    ELSIF operacion = 4 THEN 
    -- ANULAR CABECERA
        UPDATE serv_rutinas_cab
        SET estado = 'ANULADO',
            auditoria = COALESCE(auditoria, '') || CHR(13) || 'ANULACION/' || usuario || '/' || NOW() 
        WHERE id_rut = xid_rut;
        RAISE NOTICE 'DATOS ANULADOS CON ÉXITO';
       
    ELSIF operacion = 5 THEN 

	  		-- INSERTAR DETALLES
        INSERT INTO serv_rutinas_det (id_rut,id_act,serie,repeticion,peso,auditoria,ejercicio)
        VALUES (xid_rut, xid_act, xserie, xrepeticion, xpeso,
       'INSERCION DETALLE/' || usuario || '/' || NOW(),
      	xejercicio);
	    RAISE NOTICE 'MEDICIÓN AÑADIDO CON ÉXITO';
       

    ELSIF operacion = 6 THEN 
    -- MODIFICAR DETALLE --
        UPDATE serv_rutinas_det SET 
        id_act = xid_act,
        serie = xserie,
        repeticion = xrepeticion,
        peso = xpeso,
        ejercicio= xejercicio,
        auditoria = COALESCE(auditoria, '') || CHR(13) || 'MODIFICACION DE DETALLE/' || usuario || '/' || NOW()
        WHERE id_rut = xid_rut AND id_act = xid_act;
        RAISE NOTICE 'MEDICIÓN MODIFICADO CON ÉXITO';
       
    ELSIF operacion = 7 THEN 
    -- ELIMINAR DETALLE
    DELETE FROM serv_rutinas_det
        WHERE id_rut = xid_rut AND id_act = xid_act;
        RAISE NOTICE 'MEDICIÓN ELIMINADO CON ÉXITO';
   
    END IF;
END;
$$;


ALTER FUNCTION public.sp_rutinas(xid_rut integer, xrut_fecha date, xrut_edad integer, xrut_observacion text, xid_plan_servi integer, xid_cliente integer, xid_personal integer, xid_sucursal integer, xid_funcionario integer, xid_act integer, xserie integer, xrepeticion integer, xpeso numeric, xejercicio character varying, usuario character varying, operacion integer) OWNER TO postgres;

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
-- Name: actividades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.actividades (
    id_act integer NOT NULL,
    act_descrip character varying(100),
    act_unidad character varying(20),
    act_tipo character varying(100),
    estado public.estados,
    auditoria text
);


ALTER TABLE public.actividades OWNER TO postgres;

--
-- Name: auth_2fa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_2fa (
    id_usuario integer NOT NULL,
    codigo integer,
    fecha_expiracion timestamp without time zone
);


ALTER TABLE public.auth_2fa OWNER TO postgres;

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
-- Name: comp_ajustes_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_ajustes_cab (
    id_caju integer NOT NULL,
    aju_fecha date,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text,
    aju_observacion text
);


ALTER TABLE public.comp_ajustes_cab OWNER TO postgres;

--
-- Name: comp_ajustes_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_ajustes_det (
    id_caju integer NOT NULL,
    id_item integer NOT NULL,
    id_motivo integer,
    cantidad integer,
    precio numeric,
    auditoria text
);


ALTER TABLE public.comp_ajustes_det OWNER TO postgres;

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
-- Name: comp_nota_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_nota_cab (
    id_not integer NOT NULL,
    not_fecha date,
    not_fecha_docu date,
    not_tipo_nota character varying(50),
    id_cc integer,
    id_sucursal integer,
    id_funcionario integer,
    id_proveedor integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.comp_nota_cab OWNER TO postgres;

--
-- Name: comp_nota_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_nota_det (
    id_not integer NOT NULL,
    id_item integer NOT NULL,
    cantidad numeric,
    precio numeric,
    monto numeric
);


ALTER TABLE public.comp_nota_det OWNER TO postgres;

--
-- Name: comp_transfers_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_transfers_cab (
    id_tra integer NOT NULL,
    tra_fecha_elabo date,
    tra_fecha_salida date,
    tra_fecha_recep date,
    id_sucursal integer,
    id_funcionario integer,
    id_sucursal_ori integer,
    id_sucursal_des integer,
    id_deposito_ori integer,
    id_deposito_des integer,
    id_vehiculo integer,
    id_chofer integer,
    observacion text,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.comp_transfers_cab OWNER TO postgres;

--
-- Name: comp_transfers_cab_id_tra_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comp_transfers_cab_id_tra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comp_transfers_cab_id_tra_seq OWNER TO postgres;

--
-- Name: comp_transfers_cab_id_tra_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comp_transfers_cab_id_tra_seq OWNED BY public.comp_transfers_cab.id_tra;


--
-- Name: comp_transfers_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comp_transfers_det (
    id_tra integer NOT NULL,
    id_item integer NOT NULL,
    cantidad integer,
    auditoria text
);


ALTER TABLE public.comp_transfers_det OWNER TO postgres;

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
-- Name: motivo_ajustes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.motivo_ajustes (
    id_motivo integer NOT NULL,
    mot_descrip character varying,
    mot_tipo_ajuste character varying,
    estado public.estados
);


ALTER TABLE public.motivo_ajustes OWNER TO postgres;

--
-- Name: motivo_ajustes_id_motivo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.motivo_ajustes_id_motivo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.motivo_ajustes_id_motivo_seq OWNER TO postgres;

--
-- Name: motivo_ajustes_id_motivo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.motivo_ajustes_id_motivo_seq OWNED BY public.motivo_ajustes.id_motivo;


--
-- Name: nutriologos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nutriologos (
    id_funcionario integer NOT NULL,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.nutriologos OWNER TO postgres;

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
    id_funcionario integer NOT NULL,
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
    id_genero integer,
    per_edad integer
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
-- Name: serv_alimentaciones_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_alimentaciones_cab (
    id_ali integer NOT NULL,
    ali_fecha date,
    ali_fecha_fin date,
    ali_objetivo character varying(70),
    ali_dias text,
    ali_observacion text,
    id_plan_servi integer,
    id_cliente integer,
    id_nutriologo integer,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.serv_alimentaciones_cab OWNER TO postgres;

--
-- Name: serv_alimentaciones_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_alimentaciones_det (
    id_ali integer NOT NULL,
    id_act integer NOT NULL,
    alimento character varying(70),
    cantidad numeric,
    calorias numeric,
    carbohidratos numeric,
    proteinas numeric,
    auditoria text
);


ALTER TABLE public.serv_alimentaciones_det OWNER TO postgres;

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
-- Name: serv_mediciones_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_mediciones_cab (
    id_med integer NOT NULL,
    med_fecha date,
    med_edad integer,
    med_observacion text,
    id_cliente integer,
    id_personal integer,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.serv_mediciones_cab OWNER TO postgres;

--
-- Name: serv_mediciones_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_mediciones_det (
    id_med integer NOT NULL,
    id_act integer NOT NULL,
    valor numeric,
    auditoria text
);


ALTER TABLE public.serv_mediciones_det OWNER TO postgres;

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
-- Name: serv_rutinas_cab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_rutinas_cab (
    id_rut integer NOT NULL,
    rut_fecha date,
    rut_edad integer,
    rut_observacion text,
    id_plan_servi integer,
    id_cliente integer,
    id_personal integer,
    id_sucursal integer,
    id_funcionario integer,
    estado public.estados,
    auditoria text
);


ALTER TABLE public.serv_rutinas_cab OWNER TO postgres;

--
-- Name: serv_rutinas_det; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serv_rutinas_det (
    id_rut integer NOT NULL,
    id_act integer NOT NULL,
    serie integer,
    repeticion integer,
    peso numeric,
    auditoria text,
    ejercicio character varying(70)
);


ALTER TABLE public.serv_rutinas_det OWNER TO postgres;

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
-- Name: v_comp_ajustes_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_ajustes_cab AS
 SELECT cac.id_caju,
    cac.aju_fecha,
    cac.id_sucursal,
    cac.id_funcionario,
    cac.estado,
    cac.auditoria,
    cac.aju_observacion,
    to_char((cac.aju_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS funcionario,
    e.emp_ruc,
    e.emp_denominacion
   FROM ((((public.comp_ajustes_cab cac
     JOIN public.sucursales s ON ((s.id_sucursal = cac.id_sucursal)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cac.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_comp_ajustes_cab OWNER TO postgres;

--
-- Name: v_comp_ajustes_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_ajustes_det AS
 SELECT cad.id_caju,
    cad.id_item,
    cad.id_motivo,
    cad.cantidad,
    cad.precio,
    cad.auditoria,
    ma.mot_descrip,
    ma.mot_tipo_ajuste,
    s.id_sucursal,
    s.stock_cantidad,
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
    m.mar_descrip,
    d.dep_descrip
   FROM (((((((public.comp_ajustes_det cad
     JOIN public.motivo_ajustes ma ON ((ma.id_motivo = cad.id_motivo)))
     JOIN public.stock s ON ((s.id_item = cad.id_item)))
     JOIN public.deposito d ON ((s.id_sucursal = d.id_sucursal)))
     JOIN public.items i ON ((i.id_item = s.id_item)))
     JOIN public.tipos_impuestos ti ON ((ti.id_tip_impuesto = i.id_tip_impuesto)))
     JOIN public.tipos_items ti2 ON ((ti2.id_tip_item = i.id_tip_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)));


ALTER TABLE public.v_comp_ajustes_det OWNER TO postgres;

--
-- Name: v_comp_nota_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_nota_cab AS
 SELECT cnc.id_not,
    cnc.not_fecha,
    cnc.not_fecha_docu,
    cnc.not_tipo_nota,
    cnc.id_cc,
    cnc.id_sucursal,
    cnc.id_funcionario,
    cnc.id_proveedor,
    cnc.estado,
    cnc.auditoria,
    to_char((cnc.not_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((cnc.not_fecha_docu)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_docu,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((prov.per_nombre)::text || ' '::text) || (prov.per_apellido)::text) AS proveedor,
    (((func.per_nombre)::text || ' '::text) || (func.per_apellido)::text) AS funcionario,
    e.emp_ruc,
    e.emp_denominacion,
    cc.cc_nro_factura
   FROM (((((((public.comp_nota_cab cnc
     JOIN public.compras_cabecera cc ON ((cc.id_cc = cnc.id_cc)))
     JOIN public.sucursales s ON ((s.id_sucursal = cnc.id_sucursal)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cnc.id_funcionario)))
     JOIN public.personas func ON ((func.id_persona = f.id_persona)))
     JOIN public.proveedores pr ON ((pr.id_proveedor = cnc.id_proveedor)))
     JOIN public.personas prov ON ((prov.id_persona = pr.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_comp_nota_cab OWNER TO postgres;

--
-- Name: v_comp_nota_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_nota_det AS
 SELECT cd.id_not,
    cd.id_item,
    cd.cantidad,
    cd.precio,
    cd.monto,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    ti2.id_tip_impuesto,
    m.mar_descrip,
    ti.tip_item_descrip,
    sum(
        CASE
            WHEN (ti2.id_tip_impuesto = 2) THEN (cd.precio * cd.cantidad)
            ELSE (0)::numeric
        END) AS totalgrav10,
    sum(
        CASE
            WHEN (ti2.id_tip_impuesto = 2) THEN ((cd.precio * cd.cantidad) / (11)::numeric)
            ELSE (0)::numeric
        END) AS totaliva10,
    sum(
        CASE
            WHEN (ti2.id_tip_impuesto = 1) THEN (cd.precio * cd.cantidad)
            ELSE (0)::numeric
        END) AS totalgrav5,
    sum(
        CASE
            WHEN (ti2.id_tip_impuesto = 1) THEN ((cd.precio * cd.cantidad) / (21)::numeric)
            ELSE (0)::numeric
        END) AS totaliva5,
    sum(
        CASE
            WHEN (ti2.id_tip_impuesto = 3) THEN (cd.precio * cd.cantidad)
            ELSE (0)::numeric
        END) AS totalexenta
   FROM (((((public.comp_nota_det cd
     LEFT JOIN public.comp_nota_cab cnc ON ((cnc.id_not = cd.id_not)))
     LEFT JOIN public.items i ON ((i.id_item = cd.id_item)))
     LEFT JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     LEFT JOIN public.tipos_impuestos ti2 ON ((ti2.id_tip_impuesto = i.id_tip_impuesto)))
     LEFT JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
  GROUP BY cd.id_not, cd.id_item, cd.cantidad, cd.precio, cd.monto, i.item_descrip, i.id_mar, i.id_tip_item, ti2.id_tip_impuesto, m.mar_descrip, ti.tip_item_descrip;


ALTER TABLE public.v_comp_nota_det OWNER TO postgres;

--
-- Name: vehiculos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehiculos (
    id_vehiculo integer NOT NULL,
    veh_descrip text,
    id_mar integer,
    estado public.estados
);


ALTER TABLE public.vehiculos OWNER TO postgres;

--
-- Name: v_comp_transfers_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_transfers_cab AS
 SELECT cnc.id_tra,
    cnc.tra_fecha_elabo,
    cnc.tra_fecha_salida,
    cnc.tra_fecha_recep,
    cnc.id_sucursal,
    cnc.id_funcionario,
    cnc.id_sucursal_ori,
    cnc.id_sucursal_des,
    cnc.id_deposito_ori,
    cnc.id_deposito_des,
    cnc.id_vehiculo,
    cnc.id_chofer,
    cnc.observacion,
    cnc.estado,
    cnc.auditoria,
    to_char((cnc.tra_fecha_elabo)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_elabo,
    to_char((cnc.tra_fecha_salida)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_salida,
    to_char((cnc.tra_fecha_recep)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_recepcion,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((func.per_nombre)::text || ' '::text) || (func.per_apellido)::text) AS funcionario,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS chofer,
    e.emp_ruc,
    e.emp_denominacion,
    v.veh_descrip,
    d.dep_descrip
   FROM ((((((((public.comp_transfers_cab cnc
     JOIN public.sucursales s ON ((s.id_sucursal = cnc.id_sucursal)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cnc.id_funcionario)))
     JOIN public.deposito d ON ((d.id_sucursal = cnc.id_sucursal)))
     JOIN public.vehiculos v ON ((v.id_vehiculo = cnc.id_vehiculo)))
     JOIN public.personas func ON ((func.id_persona = f.id_persona)))
     JOIN public.funcionarios fc ON ((fc.id_funcionario = cnc.id_chofer)))
     JOIN public.personas p ON ((p.id_persona = fc.id_persona)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_comp_transfers_cab OWNER TO postgres;

--
-- Name: v_comp_transfers_cab_f; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_transfers_cab_f AS
 SELECT cnc.id_tra,
    cnc.tra_fecha_elabo,
    cnc.tra_fecha_salida,
    cnc.tra_fecha_recep,
    cnc.id_sucursal,
    cnc.id_funcionario,
    cnc.id_sucursal_ori,
    cnc.id_sucursal_des,
    cnc.id_deposito_ori,
    cnc.id_deposito_des,
    cnc.id_vehiculo,
    cnc.id_chofer,
    cnc.observacion,
    cnc.estado,
    cnc.auditoria,
    to_char((cnc.tra_fecha_elabo)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_elabo,
    to_char((cnc.tra_fecha_salida)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_salida,
    to_char((cnc.tra_fecha_recep)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_recepcion,
    s.suc_nombre AS sucursal_nombre,
    s.suc_direccion AS sucursal_direccion,
    s.suc_correo AS sucursal_correo,
    s.suc_telefono AS sucursal_telefono,
    s.suc_imagen AS sucursal_imagen,
    d_ori.dep_descrip AS deposito_origen,
    s_ori.suc_nombre AS sucursal_origen,
    d_des.dep_descrip AS deposito_destino,
    s_des.suc_nombre AS sucursal_destino,
    (((func.per_nombre)::text || ' '::text) || (func.per_apellido)::text) AS funcionario,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS chofer,
    e.emp_ruc,
    e.emp_denominacion,
    v.veh_descrip,
    m.mar_descrip
   FROM ((((((((((((public.comp_transfers_cab cnc
     JOIN public.sucursales s ON ((s.id_sucursal = cnc.id_sucursal)))
     LEFT JOIN public.deposito d_ori ON ((d_ori.id_sucursal = cnc.id_deposito_ori)))
     LEFT JOIN public.sucursales s_ori ON ((s_ori.id_sucursal = cnc.id_sucursal_ori)))
     LEFT JOIN public.deposito d_des ON ((d_des.id_sucursal = cnc.id_deposito_des)))
     LEFT JOIN public.sucursales s_des ON ((s_des.id_sucursal = cnc.id_sucursal_des)))
     JOIN public.funcionarios f ON ((f.id_funcionario = cnc.id_funcionario)))
     JOIN public.personas func ON ((func.id_persona = f.id_persona)))
     JOIN public.funcionarios fc ON ((fc.id_funcionario = cnc.id_chofer)))
     JOIN public.personas p ON ((p.id_persona = fc.id_persona)))
     JOIN public.vehiculos v ON ((v.id_vehiculo = cnc.id_vehiculo)))
     JOIN public.marcas m ON ((m.id_mar = v.id_mar)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_comp_transfers_cab_f OWNER TO postgres;

--
-- Name: v_comp_transfers_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_comp_transfers_det AS
 SELECT cd.id_tra,
    cd.id_item,
    cd.cantidad,
    cd.auditoria,
    i.item_descrip,
    i.id_mar,
    i.id_tip_item,
    ti2.id_tip_impuesto,
    m.mar_descrip,
    ti.tip_item_descrip,
    s.id_item AS id_stock,
    s.stock_cantidad
   FROM (((((public.comp_transfers_det cd
     JOIN public.items i ON ((i.id_item = cd.id_item)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.tipos_impuestos ti2 ON ((ti2.id_tip_impuesto = i.id_tip_impuesto)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.stock s ON ((s.id_item = cd.id_item)));


ALTER TABLE public.v_comp_transfers_det OWNER TO postgres;

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
-- Name: v_deposito; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_deposito AS
 SELECT DISTINCT ON (d.id_sucursal) d.id_sucursal,
    d.dep_descrip,
    d.estado,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_ubicacion
   FROM (public.deposito d
     LEFT JOIN public.sucursales s ON ((d.id_sucursal = s.id_sucursal)));


ALTER TABLE public.v_deposito OWNER TO postgres;

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
-- Name: v_nutriologos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_nutriologos AS
 SELECT pt.id_funcionario,
    pt.estado,
    pt.auditoria,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS nutriologo,
    p.per_ci,
    p.per_ruc,
    f.fun_ingreso,
    f.fun_egreso,
    f.monto_salario,
    f.id_cargo
   FROM ((public.nutriologos pt
     JOIN public.funcionarios f ON ((f.id_funcionario = pt.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)));


ALTER TABLE public.v_nutriologos OWNER TO postgres;

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
-- Name: v_personal_trainers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_personal_trainers AS
 SELECT pt.id_funcionario,
    pt.estado,
    pt.auditoria,
    (((p.per_nombre)::text || ' '::text) || (p.per_apellido)::text) AS personal_trainer,
    p.per_ci,
    p.per_ruc,
    f.fun_ingreso,
    f.fun_egreso,
    f.monto_salario,
    f.id_cargo
   FROM ((public.personal_trainers pt
     JOIN public.funcionarios f ON ((f.id_funcionario = pt.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)));


ALTER TABLE public.v_personal_trainers OWNER TO postgres;

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
-- Name: v_serv_alimentaciones_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_alimentaciones_cab AS
 SELECT cnc.id_ali,
    cnc.ali_fecha,
    cnc.ali_fecha_fin,
    cnc.ali_objetivo,
    cnc.ali_dias,
    cnc.ali_observacion,
    cnc.id_plan_servi,
    cnc.id_cliente,
    cnc.id_nutriologo,
    cnc.id_sucursal,
    cnc.id_funcionario,
    cnc.estado,
    cnc.auditoria,
    to_char((cnc.ali_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    to_char((cnc.ali_fecha_fin)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha_fin,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((per.per_nombre)::text || ' '::text) || (per.per_apellido)::text) AS nutriologo,
    (((cli.per_nombre)::text || ' '::text) || (cli.per_apellido)::text) AS cliente,
    (((func.per_nombre)::text || ' '::text) || (func.per_apellido)::text) AS funcionario,
    cli.per_edad,
    e.emp_ruc,
    e.emp_denominacion,
    g.id_genero,
    g.gen_descrip,
    ps.ps_descrip
   FROM ((((((((((public.serv_alimentaciones_cab cnc
     LEFT JOIN public.sucursales s ON ((s.id_sucursal = cnc.id_sucursal)))
     LEFT JOIN public.funcionarios f ON ((f.id_funcionario = cnc.id_funcionario)))
     LEFT JOIN public.personas func ON ((func.id_persona = f.id_persona)))
     LEFT JOIN public.nutriologos n ON ((n.id_funcionario = cnc.id_nutriologo)))
     LEFT JOIN public.personas per ON ((per.id_persona = n.id_funcionario)))
     LEFT JOIN public.clientes c ON ((c.id_cliente = cnc.id_cliente)))
     LEFT JOIN public.personas cli ON ((cli.id_persona = c.id_persona)))
     LEFT JOIN public.generos g ON ((g.id_genero = cli.id_genero)))
     LEFT JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)))
     LEFT JOIN public.planes_servicios ps ON ((ps.id_plan_servi = cnc.id_plan_servi)));


ALTER TABLE public.v_serv_alimentaciones_cab OWNER TO postgres;

--
-- Name: v_serv_alimentaciones_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_alimentaciones_det AS
 SELECT md.id_ali,
    md.id_act,
    md.alimento,
    md.cantidad,
    md.calorias,
    md.carbohidratos,
    md.proteinas,
    md.auditoria,
    tm.act_descrip
   FROM (public.serv_alimentaciones_det md
     JOIN public.actividades tm ON ((tm.id_act = md.id_act)));


ALTER TABLE public.v_serv_alimentaciones_det OWNER TO postgres;

--
-- Name: v_serv_alimentaciones_foot; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_alimentaciones_foot AS
 SELECT sum(md.calorias) AS calorias,
    sum(md.carbohidratos) AS carbohidratos,
    sum(md.proteinas) AS proteinas
   FROM public.serv_alimentaciones_det md;


ALTER TABLE public.v_serv_alimentaciones_foot OWNER TO postgres;

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
-- Name: v_serv_mediciones_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_mediciones_cab AS
 SELECT cnc.id_med,
    cnc.med_fecha,
    cnc.med_edad,
    cnc.med_observacion,
    cnc.id_cliente,
    cnc.id_personal,
    cnc.id_sucursal,
    cnc.id_funcionario,
    cnc.estado,
    cnc.auditoria,
    to_char((cnc.med_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((per.per_nombre)::text || ' '::text) || (per.per_apellido)::text) AS personal,
    (((cli.per_nombre)::text || ' '::text) || (cli.per_apellido)::text) AS cliente,
    (((func.per_nombre)::text || ' '::text) || (func.per_apellido)::text) AS funcionario,
    cli.per_edad,
    e.emp_ruc,
    e.emp_denominacion,
    g.id_genero,
    g.gen_descrip
   FROM (((((((((public.serv_mediciones_cab cnc
     LEFT JOIN public.sucursales s ON ((s.id_sucursal = cnc.id_sucursal)))
     LEFT JOIN public.funcionarios f ON ((f.id_funcionario = cnc.id_funcionario)))
     LEFT JOIN public.personas func ON ((func.id_persona = f.id_persona)))
     LEFT JOIN public.personal_trainers pr ON ((pr.id_funcionario = cnc.id_personal)))
     LEFT JOIN public.personas per ON ((per.id_persona = pr.id_funcionario)))
     LEFT JOIN public.clientes c ON ((c.id_cliente = cnc.id_cliente)))
     LEFT JOIN public.personas cli ON ((cli.id_persona = c.id_persona)))
     LEFT JOIN public.generos g ON ((g.id_genero = cli.id_genero)))
     LEFT JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)));


ALTER TABLE public.v_serv_mediciones_cab OWNER TO postgres;

--
-- Name: v_serv_mediciones_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_mediciones_det AS
 SELECT md.id_med,
    md.id_act,
    md.valor,
    md.auditoria,
    tm.act_descrip,
    tm.act_unidad,
    smc.id_genero,
    smc.med_edad
   FROM ((public.serv_mediciones_det md
     JOIN public.v_serv_mediciones_cab smc ON ((smc.id_med = md.id_med)))
     JOIN public.actividades tm ON ((tm.id_act = md.id_act)));


ALTER TABLE public.v_serv_mediciones_det OWNER TO postgres;

--
-- Name: v_serv_mediciones_foot; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_mediciones_foot AS
 SELECT cnc.id_med,
    cnc.med_fecha,
    cnc.id_cliente,
    smd_peso.valor AS peso,
    smd_altura.valor AS altura,
    cnc.med_edad AS edad,
    p.id_genero,
        CASE
            WHEN ((smd_altura.valor IS NOT NULL) AND (smd_peso.valor IS NOT NULL) AND (smd_altura.valor > (0)::numeric)) THEN (smd_peso.valor / (smd_altura.valor ^ (2)::numeric))
            ELSE NULL::numeric
        END AS imc,
        CASE
            WHEN ((p.id_genero = 1) AND (smd_altura.valor IS NOT NULL) AND (smd_peso.valor IS NOT NULL) AND (smd_altura.valor > (0)::numeric)) THEN ((((1.20 * (smd_peso.valor / (smd_altura.valor ^ (2)::numeric))) + (0.23 * (cnc.med_edad)::numeric)) - (10.8 * (1)::numeric)) - 5.4)
            WHEN ((p.id_genero = 2) AND (smd_altura.valor IS NOT NULL) AND (smd_peso.valor IS NOT NULL) AND (smd_altura.valor > (0)::numeric)) THEN (((1.20 * (smd_peso.valor / (smd_altura.valor ^ (2)::numeric))) + (0.23 * (cnc.med_edad)::numeric)) - 5.4)
            ELSE NULL::numeric
        END AS grasa_corporal
   FROM ((((public.serv_mediciones_cab cnc
     LEFT JOIN public.serv_mediciones_det smd_peso ON (((smd_peso.id_med = cnc.id_med) AND (smd_peso.id_act = 1))))
     LEFT JOIN public.serv_mediciones_det smd_altura ON (((smd_altura.id_med = cnc.id_med) AND (smd_altura.id_act = 4))))
     LEFT JOIN public.clientes cli ON ((cli.id_cliente = cnc.id_cliente)))
     LEFT JOIN public.personas p ON ((p.id_persona = cli.id_persona)));


ALTER TABLE public.v_serv_mediciones_foot OWNER TO postgres;

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
-- Name: v_serv_membresias_cliente; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_membresias_cliente AS
 SELECT c.id_mem,
    c.id_plan_servi,
    sum(c.dias) AS dias,
    c.precio,
    c.ps_descrip,
    c.precio_servicio,
    c.tip_imp_descrip,
    c.tip_imp_tasa,
    smc.id_cliente,
    smc.cliente,
    smc.estado AS estadocab
   FROM (( SELECT d.id_mem,
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
     JOIN public.v_serv_membresias_cab smc ON ((smc.id_mem = c.id_mem)))
  GROUP BY c.id_mem, c.id_plan_servi, c.precio, c.ps_descrip, c.precio_servicio, c.tip_imp_descrip, c.tip_imp_tasa, smc.id_cliente, smc.cliente, smc.estado;


ALTER TABLE public.v_serv_membresias_cliente OWNER TO postgres;

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
-- Name: v_serv_rutinas_cab; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_rutinas_cab AS
 SELECT cnc.id_rut,
    cnc.rut_fecha,
    cnc.rut_edad,
    cnc.rut_observacion,
    cnc.id_plan_servi,
    cnc.id_cliente,
    cnc.id_personal,
    cnc.id_sucursal,
    cnc.id_funcionario,
    cnc.estado,
    cnc.auditoria,
    to_char((cnc.rut_fecha)::timestamp with time zone, 'DD/MM/YYYY'::text) AS fecha,
    s.suc_nombre,
    s.suc_direccion,
    s.suc_correo,
    s.suc_telefono,
    s.suc_imagen,
    (((per.per_nombre)::text || ' '::text) || (per.per_apellido)::text) AS personal,
    (((cli.per_nombre)::text || ' '::text) || (cli.per_apellido)::text) AS cliente,
    (((func.per_nombre)::text || ' '::text) || (func.per_apellido)::text) AS funcionario,
    cli.per_edad,
    e.emp_ruc,
    e.emp_denominacion,
    g.id_genero,
    g.gen_descrip,
    ps.ps_descrip
   FROM ((((((((((public.serv_rutinas_cab cnc
     LEFT JOIN public.sucursales s ON ((s.id_sucursal = cnc.id_sucursal)))
     LEFT JOIN public.funcionarios f ON ((f.id_funcionario = cnc.id_funcionario)))
     LEFT JOIN public.personas func ON ((func.id_persona = f.id_persona)))
     LEFT JOIN public.personal_trainers pr ON ((pr.id_funcionario = cnc.id_personal)))
     LEFT JOIN public.personas per ON ((per.id_persona = pr.id_funcionario)))
     LEFT JOIN public.clientes c ON ((c.id_cliente = cnc.id_cliente)))
     LEFT JOIN public.personas cli ON ((cli.id_persona = c.id_persona)))
     LEFT JOIN public.generos g ON ((g.id_genero = cli.id_genero)))
     LEFT JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)))
     LEFT JOIN public.planes_servicios ps ON ((ps.id_plan_servi = cnc.id_plan_servi)));


ALTER TABLE public.v_serv_rutinas_cab OWNER TO postgres;

--
-- Name: v_serv_rutinas_det; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_serv_rutinas_det AS
 SELECT md.id_rut,
    md.id_act,
    md.serie,
    md.repeticion,
    md.peso,
    md.auditoria,
    md.ejercicio,
    tm.act_descrip
   FROM (public.serv_rutinas_det md
     JOIN public.actividades tm ON ((tm.id_act = md.id_act)));


ALTER TABLE public.v_serv_rutinas_det OWNER TO postgres;

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
    p.per_edad,
    p.id_genero,
    g.gen_descrip,
    ( SELECT max(v_funcionarios.funcionario) AS max
           FROM public.v_funcionarios
          WHERE (v_funcionarios.id_funcionario = f.id_funcionario)) AS funcionario,
    p.per_ci
   FROM ((((((public.servicios_inscripciones_cabecera sic
     JOIN public.sucursales s ON ((s.id_sucursal = sic.id_sucursal)))
     JOIN public.clientes c ON ((c.id_cliente = sic.id_cliente)))
     JOIN public.funcionarios f ON ((f.id_funcionario = sic.id_funcionario)))
     JOIN public.personas p ON ((p.id_persona = c.id_persona)))
     JOIN public.generos g ON ((g.id_genero = p.id_genero)))
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
-- Name: v_stocks; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_stocks AS
 SELECT s.id_sucursal,
    s.id_item,
    s.stock_cantidad,
    s.estado,
    i.item_descrip,
    i.precio_compra,
    i.precio_venta,
    i.id_mar,
    i.id_tip_item,
    i.id_tip_impuesto,
    i.auditoria,
    m.mar_descrip,
    ti.tip_item_descrip,
    t.tip_imp_descrip,
    t.tip_imp_tasa,
    d.dep_descrip
   FROM (((((public.stock s
     JOIN public.deposito d ON ((d.id_sucursal = s.id_sucursal)))
     JOIN public.items i ON ((s.id_item = i.id_item)))
     JOIN public.marcas m ON ((m.id_mar = i.id_mar)))
     JOIN public.tipos_items ti ON ((ti.id_tip_item = i.id_tip_item)))
     JOIN public.tipos_impuestos t ON ((t.id_tip_impuesto = i.id_tip_impuesto)));


ALTER TABLE public.v_stocks OWNER TO postgres;

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
    g.gen_descrip,
    af.codigo,
    af.fecha_expiracion
   FROM (((((((((((public.usuarios u
     JOIN public.funcionarios f ON ((f.id_funcionario = u.id_funcionario)))
     JOIN public.cargos c ON ((c.id_cargo = f.id_cargo)))
     JOIN public.personas p ON ((p.id_persona = f.id_persona)))
     JOIN public.ciudades c2 ON ((c2.id_ciudad = p.id_ciudad)))
     JOIN public.paises p2 ON ((p2.id_pais = c2.id_pais)))
     JOIN public.estado_civiles ec ON ((ec.id_ecivil = p.id_ecivil)))
     JOIN public.generos g ON ((g.id_genero = p.id_genero)))
     JOIN public.sucursales s ON ((s.id_sucursal = u.id_sucursal)))
     JOIN public.empresas e ON ((e.id_empresa = s.id_empresa)))
     JOIN public.grupos g2 ON ((g2.id_grupo = u.id_grupo)))
     JOIN public.auth_2fa af ON ((af.id_usuario = u.id_usuario)));


ALTER TABLE public.v_usuarios OWNER TO postgres;

--
-- Name: v_vehiculos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_vehiculos AS
 SELECT v.id_vehiculo,
    v.veh_descrip,
    v.id_mar,
    v.estado,
    m.mar_descrip
   FROM (public.vehiculos v
     JOIN public.marcas m ON ((m.id_mar = v.id_mar)));


ALTER TABLE public.v_vehiculos OWNER TO postgres;

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
-- Name: comp_transfers_cab id_tra; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab ALTER COLUMN id_tra SET DEFAULT nextval('public.comp_transfers_cab_id_tra_seq'::regclass);


--
-- Name: motivo_ajustes id_motivo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motivo_ajustes ALTER COLUMN id_motivo SET DEFAULT nextval('public.motivo_ajustes_id_motivo_seq'::regclass);


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
-- Name: actividades actividades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.actividades
    ADD CONSTRAINT actividades_pkey PRIMARY KEY (id_act);


--
-- Name: auth_2fa auth_2fa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_2fa
    ADD CONSTRAINT auth_2fa_pkey PRIMARY KEY (id_usuario);


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
-- Name: comp_ajustes_cab comp_ajustes_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_cab
    ADD CONSTRAINT comp_ajustes_cab_pkey PRIMARY KEY (id_caju);


--
-- Name: comp_ajustes_det comp_ajustes_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_det
    ADD CONSTRAINT comp_ajustes_det_pkey PRIMARY KEY (id_caju, id_item);


--
-- Name: comp_cuentas_pagar comp_cuentas_pagar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_cuentas_pagar
    ADD CONSTRAINT comp_cuentas_pagar_pkey PRIMARY KEY (cue_id_cc);


--
-- Name: comp_nota_cab comp_nota_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_cab
    ADD CONSTRAINT comp_nota_cab_pkey PRIMARY KEY (id_not);


--
-- Name: comp_nota_det comp_nota_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_det
    ADD CONSTRAINT comp_nota_det_pkey PRIMARY KEY (id_not, id_item);


--
-- Name: comp_transfers_cab comp_transfers_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_pkey PRIMARY KEY (id_tra);


--
-- Name: comp_transfers_det comp_transfers_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_det
    ADD CONSTRAINT comp_transfers_det_pkey PRIMARY KEY (id_tra, id_item);


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
-- Name: motivo_ajustes motivo_ajustes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.motivo_ajustes
    ADD CONSTRAINT motivo_ajustes_pkey PRIMARY KEY (id_motivo);


--
-- Name: nutriologos nutriologos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutriologos
    ADD CONSTRAINT nutriologos_pkey PRIMARY KEY (id_funcionario);


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
    ADD CONSTRAINT personal_trainers_pkey PRIMARY KEY (id_funcionario);


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
-- Name: serv_alimentaciones_cab serv_alimentaciones_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_cab
    ADD CONSTRAINT serv_alimentaciones_cab_pkey PRIMARY KEY (id_ali);


--
-- Name: serv_alimentaciones_det serv_alimentaciones_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_det
    ADD CONSTRAINT serv_alimentaciones_det_pkey PRIMARY KEY (id_ali, id_act);


--
-- Name: serv_inscripciones_membresias serv_inscripciones_membresias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_inscripciones_membresias
    ADD CONSTRAINT serv_inscripciones_membresias_pkey PRIMARY KEY (id_mem, id_inscrip, id_plan_servi);


--
-- Name: serv_mediciones_cab serv_mediciones_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_cab
    ADD CONSTRAINT serv_mediciones_cab_pkey PRIMARY KEY (id_med);


--
-- Name: serv_mediciones_det serv_mediciones_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_det
    ADD CONSTRAINT serv_mediciones_det_pkey PRIMARY KEY (id_med, id_act);


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
-- Name: serv_rutinas_cab serv_rutinas_cab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_cab
    ADD CONSTRAINT serv_rutinas_cab_pkey PRIMARY KEY (id_rut);


--
-- Name: serv_rutinas_det serv_rutinas_det_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_det
    ADD CONSTRAINT serv_rutinas_det_pkey PRIMARY KEY (id_rut, id_act);


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
-- Name: vehiculos vehiculos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_pkey PRIMARY KEY (id_vehiculo);


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
-- Name: comp_ajustes_cab comp_ajustes_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_cab
    ADD CONSTRAINT comp_ajustes_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: comp_ajustes_cab comp_ajustes_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_cab
    ADD CONSTRAINT comp_ajustes_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: comp_ajustes_det comp_ajustes_det_id_caju_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_det
    ADD CONSTRAINT comp_ajustes_det_id_caju_fkey FOREIGN KEY (id_caju) REFERENCES public.comp_ajustes_cab(id_caju) ON DELETE CASCADE;


--
-- Name: comp_ajustes_det comp_ajustes_det_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_det
    ADD CONSTRAINT comp_ajustes_det_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.stock(id_item);


--
-- Name: comp_ajustes_det comp_ajustes_det_id_motivo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_ajustes_det
    ADD CONSTRAINT comp_ajustes_det_id_motivo_fkey FOREIGN KEY (id_motivo) REFERENCES public.motivo_ajustes(id_motivo);


--
-- Name: comp_cuentas_pagar comp_cuentas_pagar_cue_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_cuentas_pagar
    ADD CONSTRAINT comp_cuentas_pagar_cue_id_cc_fkey FOREIGN KEY (cue_id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- Name: comp_nota_cab comp_nota_cab_id_cc_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_cab
    ADD CONSTRAINT comp_nota_cab_id_cc_fkey FOREIGN KEY (id_cc) REFERENCES public.compras_cabecera(id_cc);


--
-- Name: comp_nota_cab comp_nota_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_cab
    ADD CONSTRAINT comp_nota_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: comp_nota_cab comp_nota_cab_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_cab
    ADD CONSTRAINT comp_nota_cab_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor);


--
-- Name: comp_nota_cab comp_nota_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_cab
    ADD CONSTRAINT comp_nota_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: comp_nota_det comp_nota_det_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_det
    ADD CONSTRAINT comp_nota_det_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.items(id_item);


--
-- Name: comp_nota_det comp_nota_det_id_not_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_nota_det
    ADD CONSTRAINT comp_nota_det_id_not_fkey FOREIGN KEY (id_not) REFERENCES public.comp_nota_cab(id_not);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_chofer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_chofer_fkey FOREIGN KEY (id_chofer) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_deposito_des_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_deposito_des_fkey FOREIGN KEY (id_deposito_des) REFERENCES public.deposito(id_sucursal);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_deposito_ori_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_deposito_ori_fkey FOREIGN KEY (id_deposito_ori) REFERENCES public.deposito(id_sucursal);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_sucursal_des_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_sucursal_des_fkey FOREIGN KEY (id_sucursal_des) REFERENCES public.sucursales(id_sucursal);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_sucursal_ori_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_sucursal_ori_fkey FOREIGN KEY (id_sucursal_ori) REFERENCES public.sucursales(id_sucursal);


--
-- Name: comp_transfers_cab comp_transfers_cab_id_vehiculo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_cab
    ADD CONSTRAINT comp_transfers_cab_id_vehiculo_fkey FOREIGN KEY (id_vehiculo) REFERENCES public.vehiculos(id_vehiculo);


--
-- Name: comp_transfers_det comp_transfers_det_id_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_det
    ADD CONSTRAINT comp_transfers_det_id_item_fkey FOREIGN KEY (id_item) REFERENCES public.stock(id_item);


--
-- Name: comp_transfers_det comp_transfers_det_id_tra_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comp_transfers_det
    ADD CONSTRAINT comp_transfers_det_id_tra_fkey FOREIGN KEY (id_tra) REFERENCES public.comp_transfers_cab(id_tra);


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
-- Name: nutriologos nutriologos_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nutriologos
    ADD CONSTRAINT nutriologos_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


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
-- Name: serv_alimentaciones_cab serv_alimentaciones_cab_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_cab
    ADD CONSTRAINT serv_alimentaciones_cab_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: serv_alimentaciones_cab serv_alimentaciones_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_cab
    ADD CONSTRAINT serv_alimentaciones_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: serv_alimentaciones_cab serv_alimentaciones_cab_id_nutriologo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_cab
    ADD CONSTRAINT serv_alimentaciones_cab_id_nutriologo_fkey FOREIGN KEY (id_nutriologo) REFERENCES public.nutriologos(id_funcionario);


--
-- Name: serv_alimentaciones_cab serv_alimentaciones_cab_id_plan_servi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_cab
    ADD CONSTRAINT serv_alimentaciones_cab_id_plan_servi_fkey FOREIGN KEY (id_plan_servi) REFERENCES public.planes_servicios(id_plan_servi);


--
-- Name: serv_alimentaciones_cab serv_alimentaciones_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_cab
    ADD CONSTRAINT serv_alimentaciones_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: serv_alimentaciones_det serv_alimentaciones_det_id_act_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_det
    ADD CONSTRAINT serv_alimentaciones_det_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividades(id_act);


--
-- Name: serv_alimentaciones_det serv_alimentaciones_det_id_ali_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_alimentaciones_det
    ADD CONSTRAINT serv_alimentaciones_det_id_ali_fkey FOREIGN KEY (id_ali) REFERENCES public.serv_alimentaciones_cab(id_ali);


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
-- Name: serv_mediciones_cab serv_mediciones_cab_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_cab
    ADD CONSTRAINT serv_mediciones_cab_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: serv_mediciones_cab serv_mediciones_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_cab
    ADD CONSTRAINT serv_mediciones_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: serv_mediciones_cab serv_mediciones_cab_id_personal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_cab
    ADD CONSTRAINT serv_mediciones_cab_id_personal_fkey FOREIGN KEY (id_personal) REFERENCES public.personal_trainers(id_funcionario);


--
-- Name: serv_mediciones_cab serv_mediciones_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_cab
    ADD CONSTRAINT serv_mediciones_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: serv_mediciones_det serv_mediciones_det_id_act_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_det
    ADD CONSTRAINT serv_mediciones_det_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividades(id_act);


--
-- Name: serv_mediciones_det serv_mediciones_det_id_med_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_mediciones_det
    ADD CONSTRAINT serv_mediciones_det_id_med_fkey FOREIGN KEY (id_med) REFERENCES public.serv_mediciones_cab(id_med);


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
-- Name: serv_rutinas_cab serv_rutinas_cab_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_cab
    ADD CONSTRAINT serv_rutinas_cab_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- Name: serv_rutinas_cab serv_rutinas_cab_id_funcionario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_cab
    ADD CONSTRAINT serv_rutinas_cab_id_funcionario_fkey FOREIGN KEY (id_funcionario) REFERENCES public.funcionarios(id_funcionario);


--
-- Name: serv_rutinas_cab serv_rutinas_cab_id_personal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_cab
    ADD CONSTRAINT serv_rutinas_cab_id_personal_fkey FOREIGN KEY (id_personal) REFERENCES public.personal_trainers(id_funcionario);


--
-- Name: serv_rutinas_cab serv_rutinas_cab_id_plan_servi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_cab
    ADD CONSTRAINT serv_rutinas_cab_id_plan_servi_fkey FOREIGN KEY (id_plan_servi) REFERENCES public.planes_servicios(id_plan_servi);


--
-- Name: serv_rutinas_cab serv_rutinas_cab_id_sucursal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_cab
    ADD CONSTRAINT serv_rutinas_cab_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursales(id_sucursal);


--
-- Name: serv_rutinas_det serv_rutinas_det_id_act_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_det
    ADD CONSTRAINT serv_rutinas_det_id_act_fkey FOREIGN KEY (id_act) REFERENCES public.actividades(id_act);


--
-- Name: serv_rutinas_det serv_rutinas_det_id_rut_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serv_rutinas_det
    ADD CONSTRAINT serv_rutinas_det_id_rut_fkey FOREIGN KEY (id_rut) REFERENCES public.serv_rutinas_cab(id_rut);


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
-- Name: vehiculos vehiculos_id_mar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehiculos
    ADD CONSTRAINT vehiculos_id_mar_fkey FOREIGN KEY (id_mar) REFERENCES public.marcas(id_mar);


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
