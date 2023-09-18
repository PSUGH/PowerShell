# Title: Parameter Validate Set
break



#Region The Bad

    function theBad {
        param (
            $Type
        )
        $ActionID = switch($Type){
            "Commit" {
                1
            }
            "Merge" {
                2
            }
            "Checkout" {
                3
            }
            "Branch" {
                4
            }
            Default{
                return
            }
        }
        $ActionID
    }
    theBad -Type "branch"

#EndRegion The Bad

break

#Region The Ugly

    function theUgly {
        param (
            [ValidateSet("Commit","Merge","Checkout","Branch")]
            $Type
        )
        $ActionID = switch($Type){
            "Commit" {
                1
            }
            "Merge" {
                2
            }
            "Checkout" {
                3
            }
            "Branch" {
                4
            }
        }
        $ActionID
    }
    theUgly -Type "branch"

#EndRegion The Ugly

break

#Region The Good

    class Type : System.Management.Automation.IValidateSetValuesGenerator {
        [String[]] GetValidValues() {
            $script:Types = @{ 
                "Commit"    = 1
                "Merge"     = 2
                "Checkout"  = 3
                "Branch"    = 4
            }
            return ($script:Types).Keys
        }
    }
    function theGood {
        param (
            [ValidateSet([Type],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
            $type
        )
        $Script:Types[$type]
    }

    theGood -type "Branch"
    
#EndRegion The Good