# MSGraph Presentation - Diggin inside the module achitecture
break

#region *** prereq - Import ***
$vsExe = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
Find-Module MSGraph | Install-Module -Scope CurrentUser -Force
Import-Module MSGraph -Force
$devPath = (Get-Module MSGraph).ModuleBase
$moduleBaseDir = (Get-Module MSGraph).ModuleBase

Get-Command -Module msgraph

Clear-Host
#endregion *** prereq - Import ***



#region *** module structure ***
# module base structure
Get-ChildItem $moduleBaseDir


# the whole project
Clear-Host
Get-ChildItem $devPath -Directory
Start-Process -FilePath 'MSEdge.exe' -ArgumentList 'https://github.com/AndiBellstedt/MSGraph'


# some diggin arround in the structure and files
# VSCODE


#endregion *** module structure ***



#region *** Configuration ***
# All the background configuration settings
Get-PSFConfig -Module MSGraph | Sort-Object FullName | Format-Table FullName, Value, Type, Description


# Default or personal AppID
Get-PSFConfig -Module MSGraph -Name Tenant.Application.ClientID | Format-List FullName, Description, Value, Type


# Set custom AppID
$clientID = "00000000-1111-2222-3333-444444444444" # Custom App Personal_PowerShell_MSGraph
Set-PSFConfig -Module MSGraph -Name Tenant.Application.ClientID -Value $clientID
# Now you can catch a token with you personal registered app

# Put it back to default
Set-PSFConfig -Module MSGraph -Name Tenant.Application.ClientID -Value "5e79add2-6288-4d91-bebc-cae920227404"

#endregion *** Configuration ***




#region *** core module functions arround the token ***
# Lets look at tokens (out from Microsoft Account)
$TokenPersonal = New-MgaAccessToken -ShowLoginWindow
$tokenPersonal | Format-Table


# Invoke raw rest commands
Invoke-MgaGetMethod -UserUnspecific -Token $TokenPersonal | Format-Table
Invoke-MgaGetMethod -Field me -UserUnspecific -Token $TokenPersonal | Format-Table
Get-PSFMessage | Select-Object -Last 2


# aquiring a more privileged token
$TokenPersonal = New-MgaAccessToken -Permission Mail.Read, User.Read

Invoke-MgaGetMethod -Field me -UserUnspecific -Token $TokenPersonal | Format-Table
Invoke-MgaGetMethod -Field mailFolders -Token $TokenPersonal | Format-Table


# Get a token from a company account
Connect-MgaGraph -Register -ShowLoginWindow
$tokenCompany = Get-MgaRegisteredAccessToken
$tokenCompany | Format-Table
$tokenCompany | Format-List
$tokenCompany | Get-Member
$tokenCompany.AccessTokenInfo

Invoke-MgaGetMethod -Field groups -UserUnspecific | Format-Table


# Get a new token with permissions to read users
$tokenNewAccount = Connect-MgaGraph -ShowLoginWindow -Register -PassThru
$tokenNewAccount | Format-Table
$tokenNewAccount | Format-List
$tokenNewAccount | Get-Member
$tokenNewAccount.AccessTokenInfo


# Do query on things, that are not consented
Get-MgaMailFolder

# check out -> https://microsoft.com/consent <- to review and revoke consent


# Some diggin arround in the structure and files
Open-EditorFile "$($moduleBaseDir)\functions\core\New-MgaAccessToken.ps1"
Open-EditorFile "$($moduleBaseDir)\functions\core\Invoke-MgaRestMethodPatch.ps1"
Open-EditorFile "$($moduleBaseDir)\functions\core\Invoke-MgaRestMethodGet.ps1"


# The definition MSGraph.Core.AzureAccessToken
Start-Process $vsExe -ArgumentList "$($devPath)\library\MSGraph\MSGraph.sln"


# The view definition
Open-EditorFile "$($moduleBaseDir)\xml\MSGraph.Core.AzureAccessToken.Format.ps1xml"
Open-EditorFile "$($moduleBaseDir)\xml\MSGraph.Core.AzureAccessToken.Types.ps1xml"


#endregion *** core module functions arround the token ***



#region *** core module functions for doing API calls ***
# Now, we've got an access token, we can play arround with the REST API in Graph
Invoke-MgaGetMethod -Field mailFolders

# Ups, that not as readable... isn't it?
$folderItem = Invoke-MgaGetMethod -Field mailFolders | Where-Object displayName -like "MSGraph"
$folderItem | Format-Table
Invoke-MgaGetMethod -Field "mailFolders/$($folderItem.Id)"
Invoke-MgaGetMethod -Field "mailFolders/$($folderItem.Id)/childFolders"


# and it isn't getting better on the other -more complex- objects...
Invoke-MgaGetMethod -Field messages -ResultSize 1
Invoke-MgaGetMethod -Field mailboxSettings


# But it's doing the job and that's what it is about inside the core functionality
Open-EditorFile "$($moduleBaseDir)\functions\core\Invoke-MgaRestMethodPost.ps1"
Open-EditorFile "$($moduleBaseDir)\functions\core\Invoke-MgaRestMethodGet.ps1"


# Additional diggin arround, depending on the time
# VSCode

#endregion *** core module functions for doing API calls ***



#region *** Lets get to the user friendly composition ***
# MailFolder example
# Syntax of the function and the help
Get-Help Get-MgaMailFolder
Get-Help Get-MgaMailFolder -ShowWindow

# Calling the "default" parameter set
Get-MgaMailFolder | Where-Object name -Like "MSGraph"

# Calling the "ByFolderName" parameter set - named
Get-MgaMailFolder -Name "MSGraph"

# Calling the "ByFolderName" parameter set - with well known folders
Get-MgaMailFolder -Name Archive

# Diggin in the code
Open-EditorFile "$($moduleBaseDir)\functions\exchange\mail\folder\Get-MgaMailFolder.ps1"
Open-EditorFile "$($moduleBaseDir)\internal\functions\exchange\mail\New-MgaMailFolderObject.ps1"


# Additional example - Get-MgaMailboxSetting
# Syntax of the function and the help
Get-Help Get-MgaMailboxSetting
Get-Help Get-MgaMailboxSetting -ShowWindow

# Calling the "default" parameter set
Get-MgaMailboxSetting
Get-MgaMailboxSetting -AutomaticReplySetting
Get-MgaMailboxSetting -LanguageSetting
Get-MgaMailboxSetting -TimeZoneSetting
Get-MgaMailboxSetting -WorkingHoursSetting
Get-MgaMailboxSetting -ArchiveFolderSetting

# Diggin in the code
Open-EditorFile "$($moduleBaseDir)\functions\exchange\mailboxsetting\Get-MgaMailboxSetting.ps1"
Open-EditorFile "$($moduleBaseDir)\internal\functions\exchange\mailboxsetting\New-MgaMailboxSettingObject.ps1"


#endregion *** Lets get to the user friendly composition ***






#region *** all the commands in the module ***
$ModuleCmdPrefix = 'Mga'
$ModuleName = 'msgraph'

# Quite a long list ;-)
Get-Command -Module $ModuleName

# Do a little sorting and text trimming
$commands = Get-Command -Module $ModuleName | Select-Object *, @{n = "NounNoPrefix"; e = { if ($_.Noun) { $_.Noun.replace($ModuleCmdPrefix, '') } else { $_.ResolvedCommand.Noun.replace($ModuleCmdPrefix, '') } } } | Sort-Object ModuleName, NounNoPrefix, verb

# ...for some more visibility in function naming structure
$commands | Format-Table ModuleName, Version, verb, NounNoPrefix, Name, CommandType, ResolvedCommand #-GroupBy NounNoPrefix
$commands | Group-Object NounNoPrefix
$commands | Measure-Object


#endregion *** all the commands in the module ***




