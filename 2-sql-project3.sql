USE DELIVERY_DB;
USE DELIVERY_DB.DELIVERY_SCHEMA;

-- Tu tarea es construir una consulta que cree una tabla (customer_courier_conversations) que agregue los mensajes individuales en conversaciones. Ten en cuenta que una conversación es única por pedido. Los campos requeridos son los siguientes:
-- ID del pedido - ORDER_ID
-- Código de la ciudad - CITY_CODE

-- Marca de tiempo del primer mensaje del repartidor
-- Marca de tiempo del primer mensaje del cliente
-- Número de mensajes del repartidor
-- Número de mensajes del cliente
-- El primer remitente del mensaje (repartidor o cliente) 
-- Marca de tiempo del primer mensaje en la conversación
-- Tiempo (en segundos) transcurrido hasta la primera respuesta
-- Marca de tiempo del último mensaje enviado
-- La etapa del pedido cuando se envió el último mensaje
    
WITH Conversations AS (
    SELECT c.*, o.CITY_CODE
    FROM customer c
    JOIN orders o ON o.ORDER_ID = c.ORDER_ID
    ORDER BY c.MESSAGE_SENT_TIME
)
SELECT 
    ORDER_ID,
    CITY_CODE,
    -- Marca de tiempo del primer mensaje del repartidor
    MIN(CASE WHEN SENDER_APP_TYPE LIKE 'Courier%' THEN MESSAGE_SENT_TIME END) AS time_first_courier_message,
    -- Marca de tiempo del primer mensaje del cliente
    MIN(CASE WHEN SENDER_APP_TYPE LIKE 'Customer%' THEN MESSAGE_SENT_TIME END) AS time_first_customer_message,
    -- Número de mensajes del repartidor
    COUNT(CASE WHEN SENDER_APP_TYPE LIKE 'Courier%' THEN 1 END) AS num_mensajes_repartidor,
    -- Número de mensajes del cliente
    COUNT(CASE WHEN FROM_ID = CUSTOMER_ID THEN FROM_ID END) AS num_mensajes_cliente,
    -- El primer remitente del mensaje (repartidor o cliente) 
    CASE 
        WHEN MIN(CASE WHEN FROM_ID = COURIER_ID THEN MESSAGE_SENT_TIME END) 
            = MIN(MESSAGE_SENT_TIME) THEN 'Courier'
        ELSE 'Customer'
    END AS primer_remitente,
    -- Marca de tiempo del primer mensaje en la conversación
    MIN(MESSAGE_SENT_TIME) AS time_first_message,
    -- Tiempo (en segundos) transcurrido hasta la primera respuesta
	DATEDIFF(
        'second',
        MIN(CASE WHEN sender_app_type LIKE 'Customer%' THEN message_sent_time END),
        MIN(CASE WHEN sender_app_type LIKE 'Courier%' THEN message_sent_time END)
    ) AS time_to_first_response_seconds,
    -- Marca de tiempo del último mensaje enviado
	MAX(MESSAGE_SENT_TIME) AS time_last_message,
    -- La etapa del pedido cuando se envió el último mensaje

FROM Conversations
GROUP BY ORDER_ID, CITY_CODE;



