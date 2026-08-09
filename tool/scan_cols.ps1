$root = 'C:\Users\dalshkas\Desktop\hevjin-app\lib'
$cols = 'user1_id','user2_id','user1','user2','match_id','sender_id','receiver_id','blocker_id','blocked_id','reporter_id','reported_id','from_user','to_user'
$files = Get-ChildItem -Path $root -Recurse -Filter '*.dart'
$found = @{}
foreach ($f in $files) {
  $t = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
  foreach ($c in $cols) {
    if ($t -match "'$c'") { $found[$c] = $true }
  }
}
Write-Host "COLUMNS IN USE:"
$found.Keys | Sort-Object | ForEach-Object { "  $_" }
