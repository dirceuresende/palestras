
--------------------------------------------------
-- FIREWALL DO SERVIDOR
--------------------------------------------------

-- Conectar no banco master
SELECT *
FROM sys.firewall_rules
ORDER BY [name]


-- https://whatismyipaddress.com/
EXEC sp_set_firewall_rule
    @name = N'IP_Dirceu',
    @start_ip_address = '138.99.35.0',
    @end_ip_address = '138.99.35.0'
    
    
EXEC sp_delete_firewall_rule
    @name = N'IP_Dirceu'
    

--------------------------------------------------
-- FIREWALL DO DATABASE
--------------------------------------------------

--- Conectar no banco que será consultado
SELECT *
FROM sys.database_firewall_rules
ORDER BY [name]


EXEC sp_set_database_firewall_rule
    @name = N'IP_Dirceu',
    @start_ip_address = '138.99.35.0',
    @end_ip_address = '138.99.35.0'
    
    
EXEC sp_delete_database_firewall_rule
    @name = N'IP_Dirceu'