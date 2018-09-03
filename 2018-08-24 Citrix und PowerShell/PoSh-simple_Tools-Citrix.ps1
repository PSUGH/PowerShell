<#
    .Synopsis
     Creation of admin tools with the Citrix commandlets
    .DESCRIPTION
     A short introduction to Citrix PowerShell commandlets and how 
     to create your own simple administration tools on this basis. 
     For example, to quickly display and configure computers in a 
     machine group. Or copying applications between deployment groups and more.

     Andreas Nick' 2018

    .LINK
     https://AndreasNick.com
     https://Software-Virtualisierung.de
     http://www.Nick-It.de
#>

if($true){ break;} #Side Blocker

# Add SnapIns
Add-PSSnapin Citrix*

# Smart
Add-PSSnapin Citrix.Broker.*

# Clever & Smart
Add-PSSnapin Citrix.Broker.Admin.V2

get-Command -Module Citrix*

#Docs in the Internet
& 'C:\Program Files\Internet Explorer\iexplore.exe' https://citrix.github.io/delivery-controller-sdk/

#Machine Catalog
Get-BrokerCatalog

#Delivery Groups
Get-BrokerDesktopGroup

get-brokerapplication | select-object name,commandlineexecutable

#Tool Simple tool

get-service | ? {$_.status -match "Running"}| Out-GridView -Title "Restart Service" -PassThru | % {restart-Service $_.name -Verbose}


#Tool 1 4 Citrix: App Delete

get-brokerapplication | select-object name,commandlineexecutable | Out-GridView -PassThru -Title "AppDelete" | Remove-BrokerApplication -Verbose


#Tool 2 4 Citrix: Machines Update GPO and Tags - gpupdate /force;Restart-Service BrokerAgent;

get-brokermachine 

get-brokermachine | select MachineName, IPAddress, SummaryState | Out-GridView

get-brokermachine | select MachineName, DNSName, IPAddress, SummaryState | Out-GridView -PassThru -Title "Machine update Tool" | % { Invoke-Command -ComputerName $_.DNSName {gpupdate /force;Restart-Service BrokerAgent;}}

#Tool 3 for Citrix: Restart Tool - Select catalog, select machines, restart machines

Get-BrokerCatalog | select Name, Description, UID | Out-GridView -PassThru | % {get-brokermachine -CatalogUid $_.uid | select MachineName, DNSName, IPAddress, SID, SummaryState | Out-GridView -Title "Restart Server" -PassThru | %{ Restart-Computer $_.DNSName} }

# Tool 4 for Citrix:  Kill User Session
Get-BrokerSession | Out-GridView -PassThru | Stop-BrokerSession 

#Show Applications with Input
Add-PSSnapIn Citrix.Broker.*; function Get-delGroup {param($DeliveryGroup) ((Get-BrokerDesktopGroup -Name  $DeliveryGroup ).UUID) }; Show-Command Get-delGroup -PassThru | %  {
Invoke-Expression " $_" } | % {Get-BrokerApplication -AssociatedDesktopGroupUUID $_
}| Select-Object -Property Name, IconUid | out-gridview
