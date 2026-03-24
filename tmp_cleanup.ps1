$c = Get-Content 'f:\pocket-mates-app-ne72dv\lib\custom_code\widgets\courses_widget.dart'
if ($c.Length -ge 3230) {
    $new = $c[0..2097] + $c[3229..($c.Length-1)]
    Set-Content -Path 'f:\pocket-mates-app-ne72dv\lib\custom_code\widgets\courses_widget.dart' -Value $new -Encoding utf8
    Write-Output "Cleaned. New length: $($new.Length)"
} else {
    Write-Output "File too short for expected ranges. Length: $($c.Length)"
}
