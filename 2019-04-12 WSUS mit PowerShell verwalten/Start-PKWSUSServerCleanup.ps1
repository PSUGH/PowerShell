Import-Module -Name PoshWSUS

Connect-PSWSUSServer -WsusServer wsus16bs -Port 8530

Start-PSWSUSCleanup -CompressUpdates -DeclineExpiredUpdates -CleanupObsoleteUpdates -CleanupUnneededContentFiles
