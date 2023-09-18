# MSGraph Presentation - CI/CD - Practical demo
break

#region *** prereq - connect ***
$devPath = (Get-Module MSGraph).ModuleBase
$moduleBaseDir = (Get-Module MSGraph).ModuleBase
Clear-History
Clear-Host
#endregion *** prereq - connect ***



#region *** The test and build content (out of PSModuleDevelopment module template) ***
# Pester tests
Get-ChildItem "$($moduleBaseDir)\tests"
Clear-Host
Get-ChildItem "$($moduleBaseDir)\tests" -Recurse


# build and release stuff
Get-ChildItem "$($devPath)\build"

#endregion *** The test and build content (out of PSModuleDevelopment module template) ***



#region  *** Branches in GitHub ***
# Look at the branch protection rules
Start-Process https://github.com/AndiBellstedt/MSGraph/settings/branches


#endregion  *** Branches in GitHub ***



#region  *** Test and release pipeline in Azure DevOps ***
# Pipelines in Azure DevOps
Start-Process https://dev.azure.com/AndiBellstedt/MSGraph/_build

# Want to see it in action? Go on and create a trivial file, just to do a commit against development
"$(Get-Date -Format s) This is just a test. The file can safely be ignored and deleted." | Out-File "$($devPath)\build\test.txt"

# Check in the file and push it into development
$file = Get-ChildItem "$($devPath)\build\test.txt"
Set-Location GIT:\Modules_ABe\MSGraph\build
git add "$($file.FullName)"
git commit -m "This is just a test to demo CI/CD"
git push


# Check validate pipeline in Azure DevOps


#endregion  *** Test and release pipeline in Azure DevOps ***