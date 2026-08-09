$p = 'C:\Users\dalshkas\Desktop\hevjin-app\lib\services\profile_service.dart'
$enc = New-Object System.Text.UTF8Encoding($false)
Copy-Item $p "$p.bak" -Force
$src = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)

$a = "      if (oppositeGender != null) {"
$n = ([regex]::Matches($src, [regex]::Escape($a))).Count
if ($n -ne 1) { Write-Error "ANCHOR FAIL: found $n"; exit 1 }

$r = @"
      // Seed/demo profiles stay hidden unless explicitly enabled via
      // --dart-define=SHOW_DEMO=true. Must remain OFF for release builds:
      // fake profiles violate Google Play's Deceptive Behavior policy.
      if (!const bool.fromEnvironment('SHOW_DEMO')) {
        query = query.eq('is_demo', false);
      }

      if (oppositeGender != null) {
"@
$src = $src.Replace($a, $r.Replace("`n", "`r`n").TrimEnd())
[System.IO.File]::WriteAllText($p, $src, $enc)

$bad = [regex]::Matches($src, "\u00c3[\u0080-\u00bf]").Count
Write-Host "[ok] is_demo filter installed | mojibake: $bad | SHOW_DEMO refs: " ([regex]::Matches($src,'SHOW_DEMO')).Count
