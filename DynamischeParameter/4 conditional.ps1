

function Test4
{

  [CmdletBinding(DefaultParameterSetName='Moon')]
  param
  (
    [Parameter(ParameterSetName='City')]
    [Switch]
    $BeamToCity,
    
    [Parameter(ParameterSetName='Moon')]
    [Switch]
    $BeamToMoon
    
  )

  dynamicparam
  {
    if (!$BeamToCity) { return }
    
    $cities = 'Hannover', 'Braunschweig', 'NewYork', 'London', 'Paris' 
    
    # create a dictionary that stores all dynamic parameters:
    $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    
    # create an attribute collection to add all attributes needed to the dynamic parameter:
    $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]

    # create attribute "ParameterSetName" and make this parameter visible in all parametersets:
    # (add more of these attributes to define more than one parameterset, and add them all to the attribute collection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = '__AllParameterSets'
    $attributes.Mandatory = $true
    # add attribute to collection:
    $attributeCollection.Add($attributes)

    $Name = 'DestinationCity'
    $arrSet = $cities
    $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
    $attributeCollection.Add($ValidateSetAttribute)
    $dynParam = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, [string] , $attributeCollection)

    # add new dynamic parameter to the list of available dynamic parameters:
    $paramDictionary.Add($Name, $dynParam)
    $paramDictionary
  }

  # once scriptblock content is assigned to blocks, all content must be assigned to appropriate blocks
  end
  {
    # dynamic parameters surface via $PSBoundParameters
    Test-Path variable:ForceStatic
    Test-Path variable:ForceDynamic
    $PSBoundParameters

  }

}


    