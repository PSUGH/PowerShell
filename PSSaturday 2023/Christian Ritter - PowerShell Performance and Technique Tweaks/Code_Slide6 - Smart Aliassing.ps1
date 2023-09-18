# Title: Smart-alliasing
break

#Region The technique used in #PSMermaid
function New-MermaidGitGraphEntry {
    [CmdletBinding()]
    [alias("New-MermaidGitGraphEntryCommit","New-MermaidGitGraphEntryBranch","New-MermaidGitGraphEntryCheckout","New-MermaidGitGraphEntryMerge")]
    param(
        $type = $null
    )
    end {
        $typename = $Type 
        if([string]::IsNullOrEmpty($Type)){
            $TypeName = $PSCmdlet.MyInvocation.InvocationName -replace 'New-MermaidGitGraphEntry'
        }

        switch($TypeName){
            "Commit"{
                Write-Host "you selected $PSitem"
            }
            "Branch"{
                Write-Host "you selected $PSitem"
            }
            "Checkout"{
                Write-Host "you selected $PSitem"
            }
            "Merge"{
                Write-Host "you selected $PSitem"
            }
        }
    }
}

#EndRegion The technique live used in #PSMermaid
