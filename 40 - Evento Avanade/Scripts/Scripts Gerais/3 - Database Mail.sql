

-- Listar o histórico dos e-mails enviados pelo Database Mail
SELECT
    A.send_request_date AS DataEnvio,
    A.sent_date AS DataEntrega,
    (CASE    
        WHEN A.sent_status = 0 THEN '0 - Aguardando envio'
        WHEN A.sent_status = 1 THEN '1 - Enviado'
        WHEN A.sent_status = 2 THEN '2 - Falhou'
        WHEN A.sent_status = 3 THEN '3 - Tentando novamente'
    END) AS Situacao,
    A.from_address AS Remetente,
    A.recipients AS Destinatario,
    A.subject AS Assunto,
    A.reply_to AS ResponderPara,
    A.body AS Mensagem,
    A.body_format AS Formato,
    A.importance AS Importancia,
    A.file_attachments AS Anexos,
    A.send_request_user AS Usuario,
    B.description AS Erro,
    B.log_date AS DataFalha
FROM 
    msdb.dbo.sysmail_mailitems                  A    WITH(NOLOCK)
    LEFT JOIN msdb.dbo.sysmail_event_log        B    WITH(NOLOCK)    ON A.mailitem_id = B.mailitem_id


-- Configurações do Database Mail
SELECT * 
FROM msdb.dbo.sysmail_configuration


-- Configurações do envio da mensagem
SELECT * FROM msdb.dbo.sysmail_server