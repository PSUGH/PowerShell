$json = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri 'https://psugh.github.io/data.json')
$out = @'

{0}
{1}

Diesesmal am {2} um {3} Uhr bei {4}.
Das ist {5} in {6}.

Mit folgenden Themen: 
'@ -f $json.Treffen, $('-' * $($json.Treffen).Length), $json.Datum, $json.Zeit, $json.Ort, $json.Strasse, $json.Stadt

$out
$json.Themen
