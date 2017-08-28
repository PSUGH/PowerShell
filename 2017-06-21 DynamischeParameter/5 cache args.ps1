function test5
{
  [CmdletBinding()]
  param
  (
    [Switch]
    $ClearCache
  )

  dynamicparam
  {
    # if there is a default value, use it as bound parameter:
    $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    $Name = 'FavoriteCity'
    $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = '__AllParameterSets'
    if ( $script:DefaultValue -ne $null -and !$ClearCache) 
    {
      $PSBoundParameters.Add('FavoriteCity',$script:DefaultValue) 
      $PSBoundParameters.Add('isDefault', $true)     
      $attributes.Mandatory = $false
      $attributeCollection.Add($attributes)
      
      $dynParam = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, [String] , $attributeCollection)
      $dynParam.Value = $script:DefaultValue
      $paramDictionary.Add($Name, $dynParam)
    }
    # else, add a mandatory parameter and clear possible cache values:
    else
    {
      $script:DefaultValue = $null
      $attributes.Mandatory = $true
      $attributeCollection.Add($attributes)
      
      $dynParam = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($Name, [String] , $attributeCollection)
      $paramDictionary.Add($Name, $dynParam)      
    }
    $paramDictionary
  }

  end
  {
    # was this a cached parameter?
    $isDefault = $PSBoundParameters.ContainsKey('isDefault')
    if (!$isDefault)
    {
      # no, cache it for next time
      $script:DefaultValue = $PSBoundParameters['FavoriteCity']
    }
    # get the parameter value:
    $city = $PSBoundParameters['FavoriteCity']
    "Your favorite city is $city"
    if ($isDefault) { Write-Warning "Choice was taken from your previous choice (cached)."}
  }
}
