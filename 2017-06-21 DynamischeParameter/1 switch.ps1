function Test1
{
  [CmdletBinding()]
  param
  (
    [Switch]
    $ForceStatic

  )
  dynamicparam
  {
    # create a dictionary that stores all dynamic parameters:
    $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    
    # create an attribute collection to add all attributes needed to the dynamic parameter:
    $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]

    # create attribute "ParameterSetName" and make this parameter visible in all parametersets:
    # (add more of these attributes to define more than one parameterset, and add them all to the attribute collection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = '__AllParameterSets'
    $attributes.Mandatory = $false
    # add attribute to collection:
    $attributeCollection.Add($attributes)

    # add switch parameter
    $Name = 'ForceDynamic'
    $dynParam = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, [Switch] , $attributeCollection)

    # add new dynamic parameter to the list of available dynamic parameters:
    $paramDictionary.Add($Name, $dynParam)

    # return the list of dynamic parameters:
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
