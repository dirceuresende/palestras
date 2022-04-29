
# Consulta documentação
Start-Process https://dbatools.io/commands
Get-Command -Module dbatools *history*

# Consulta de Informações
Get-DbaService -ComputerName localhost | Out-GridView 

Get-DbaLastGoodCheckDb "localhost\sql2017"

Get-DbaDeprecatedFeature -SqlInstance localhost\sql2017 | Out-GridView

Read-DbaTransactionLog -SqlInstance localhost\sql2017 -Database dirceuresende | Out-GridView

# Parâmetros de inicialização
Get-DbaStartupParameter -SqlInstance localhost\sql2017

# Exportação de scripts
Get-DbaAgentJob -SqlInstance localhost\sql2017 | Export-DbaScript -Path C:\Temporario\jobs
Export-DbaLogin -SqlInstance localhost\sql2017 -Path C:\Temporario\logins
Export-DbaUser -SqlInstance localhost\sql2017 -Path C:\Temporario\users
Export-DbaSpConfigure -SqlInstance localhost\sql2017 -Path C:\temporario\

# Validações diversas
Find-DbaSimilarTable -SqlInstance localhost\sql2017 -Database eventos | Out-GridView
Find-DbaOrphanedFile -SqlInstance localhost\sql2017

# Histórico de Informações
Get-DbaAgentJobHistory -SqlInstance localhost\sql2017 -StartDate '2018-01-01' -EndDate '2020-10-16 12:30:00' | Out-GridView
Get-DbaDbBackupHistory -SqlInstance localhost\sql2017 | Out-GridView

# Outros
Get-DbaDbSpace -SqlInstance localhost\sql2017 | Out-GridView
Get-DbaDbSpace -SqlInstance localhost\sql2017 | ConvertTo-DbaDataTable | Write-DbaDataTable -SqlInstance localhost\sql2017 -Database dirceuresende -Table DiskSpaceExample -AutoCreateTable

# Modificações em objetos
Invoke-DbaQuery -SqlInstance localhost\sql2017 -Database tempdb -Query "CREATE TABLE dbatoolsci_schemachange (id int identity)"
Get-DbaSchemaChangeHistory -SqlInstance localhost\sql2017 -Database tempdb
Invoke-DbaQuery -SqlInstance localhost\sql2017 -Database tempdb -Query "DROP TABLE dbatoolsci_schemachange_new"

# Backup e Restore
Backup-DbaDatabase -SqlInstance localhost\sql2017 -Path D:\Backup\ -Database dirceuresende -Type Full
Restore-DbaDatabase -SqlInstance localhost\sql2019 -Path D:\Backup\

# Migrações
Copy-DbaDatabase -Source localhost\sql2017 -Destination localhost\sql2019 -Database dirceuresende -DetachAttach -Reattach
Copy-DbaAgentCategory -Source localhost\sql2017 -Destination localhost\sql2019
Copy-DbaAgentJob -Source localhost\sql2017 -Destination localhost\sql2019
Invoke-DbaDbClone -SqlInstance localhost\sql2017 -Database dirceuresende -CloneDatabase dirceuresende_clone


