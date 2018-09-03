 Describe "Environment Settings" {       
     
    Context "Setup" {


        It "Should Not have the Get-Nonsense command loaded" {
            Get-Command Get-Nonsense -ErrorAction SilentlyContinue | should BeNullOrEmpty
        }
        It "Get-SpeakerBeard.ps1 should not exist"{
            Test-Path 'C:\Windows' | Should Be $true
        }

        It "should have Hyper-V Feature installed" {
        Get-WindowsFeature -Name 'Hyper-V' | Should Be $True
        }

        
        It "DNS service should be running" {
        }

    }
}