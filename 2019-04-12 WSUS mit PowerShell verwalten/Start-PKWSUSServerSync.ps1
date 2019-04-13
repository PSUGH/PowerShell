Import-Module -Name PoshWSUS

Connect-PSWSUSServer -WsusServer wsus -Port 8530

Start-PSWSUSSync