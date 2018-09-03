#Unit testing example
C:\Users\mail\OneDrive\Scripts\Pester\01_Unit_testing_function.ps1
Invoke-Pester "C:\Users\mail\OneDrive\Scripts\Pester\01_Unit_testing_function.test.ps1"
Invoke-Pester "C:\Users\mail\OneDrive\Scripts\Pester\01_Unit_testing_function.test_collection.test.ps1"

#Environment validation
Invoke-Pester "C:\Users\mail\OneDrive\Scripts\Pester\02_FreeSpaceInGigabytes.test.ps1"

#check function
Invoke-Pester "C:\Users\mail\OneDrive\Scripts\Pester\03_Assert-MyDiskCHasMoreThan10PercentOfFreeSpace.test.ps1"
Invoke-Pester "C:\Users\mail\OneDrive\Scripts\Pester\04_Assert-HasFreeSpace.test.ps1"

#run  it
Invoke-Pester -PassThru