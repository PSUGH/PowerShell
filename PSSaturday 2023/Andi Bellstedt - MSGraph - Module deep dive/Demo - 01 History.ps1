# MSGraph Presentation - History of the module - Practical demo
break
#region * Frist demo *


#region *** prereq - connect ***
Find-Module MSGraph | Install-Module -Scope CurrentUser -Force
Import-Module MSGraph

Get-Command -Module msgraph

Connect-MgaGraph -Register -Permission Mail.Read -ShowLoginWindow

Clear-History
Clear-Host
#endregion *** prereq - connect ***


#region *** Example ***
# A simple example - let's get mail folders within your mailbox
Get-MgaMailFolder -Verbose
Clear-Host

# We focus on example folder MSGraph - look at the properties
Get-MgaMailFolder -Name MSGraph


# Lets query the mails from that folder
Get-MgaMailFolder -Name MSGraph | Get-MgaMailMessage


# Ok, we realized the mail, just mark it as read
Get-MgaMailFolder -Name MSGraph | Get-MgaMailMessage | Set-MgaMailMessage -IsRead $true
Get-MgaMailFolder -Name MSGraph | Get-MgaMailMessage


# Now get rid of it
Get-MgaMailFolder -Name MSGraph | Get-MgaMailMessage | Move-MgaMailMessage -DestinationFolder Junkemail
Get-MgaMailFolder -Name MSGraph


# Believe me, it's really in the junkmail folder
Get-MgaMailFolder -Name Junkemail
Get-MgaMailFolder -Name Junkemail | Get-MgaMailMessage


# Ok... rollback to the hole story
Get-MgaMailFolder -Name "Junkemail" | Get-MgaMailMessage | Move-MgaMailMessage -DestinationFolder "MSGraph" -PassThru | Set-MgaMailMessage -IsRead $false
Clear-Host

# We can also query the folder structure recursive
Get-MgaMailFolder -Name MSGraph -Recurse
Get-MgaMailFolder -Name MSGraph -Recurse | Format-Table FullName, Nanme, ChildFolderCount, UnreadItemCount, TotalItemCount, UnreadInPercent


#endregion *** Example ***
#endregion * Frist demo *
