$p = 'C:\Users\dalshkas\Desktop\hevjin-app\lib\screens\profile\create_profile_screen.dart'
$enc = New-Object System.Text.UTF8Encoding($false)
$src = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)

# --- 1) widget.startPage -> _effStart (global, safe: declaration uses bare 'startPage')
$n = ([regex]::Matches($src, [regex]::Escape('widget.startPage'))).Count
if ($n -lt 6) { Write-Error "ANCHOR FAIL: only $n x widget.startPage found"; exit 1 }
$src = $src.Replace('widget.startPage', '_effStart')
Write-Host "[1] replaced $n x widget.startPage -> _effStart"

# --- 2) field declaration
$a2 = "  int _currentPage = 0;"
if (-not $src.Contains($a2)) { Write-Error "ANCHOR FAIL: field anchor"; exit 1 }
$r2 = "  int _currentPage = 0;`r`n`r`n  /// Effective start page. Falls back to 0 when the basics (name/birthdate)`r`n  /// are missing, so we never persist a profile without a display_name.`r`n  late final int _effStart;"
$src = $src.Replace($a2, $r2)
Write-Host "[2] field _effStart added"

# --- 3) initState: compute _effStart AFTER prefill
$a3 = "    _currentPage = _effStart;`r`n    _prefillFromAuthMetadata();"
if (-not $src.Contains($a3)) {
  $a3 = "    _currentPage = _effStart;`n    _prefillFromAuthMetadata();"
  if (-not $src.Contains($a3)) { Write-Error "ANCHOR FAIL: initState"; exit 1 }
}
$r3 = @"
    _prefillFromAuthMetadata();
    // Guard: register_screen passes startPage=2 to skip the basics page.
    // If the auth metadata did not supply name/birthdate, show the full
    // wizard instead of silently writing a NULL display_name.
    final basicsMissing =
        _nameController.text.trim().isEmpty || _birthDate == null;
    _effStart = (widget.startPage > 0 && basicsMissing) ? 0 : widget.startPage;
    _currentPage = _effStart;
"@
$src = $src.Replace($a3, $r3.Replace("`n", "`r`n").TrimEnd())
Write-Host "[3] initState guard installed"

# --- 4) hard guard in _saveProfile
$a4 = "    // Set birthdate if available"
if (-not $src.Contains($a4)) { Write-Error "ANCHOR FAIL: save guard"; exit 1 }
$r4 = @"
    // Hard guard: never persist a profile row without a display name
    // (display_name is NOT NULL in the database).
    if (!profileData.containsKey('display_name')) {
      _showError('Name und Geburtsdatum sind Pflicht');
      return;
    }

    // Set birthdate if available
"@
$src = $src.Replace($a4, $r4.Replace("`n", "`r`n").TrimEnd())
Write-Host "[4] save guard installed"

[System.IO.File]::WriteAllText($p, $src, $enc)

# --- verify: no mojibake, no leftovers
$bad = [regex]::Matches($src, "\u00c3[\u0080-\u00bf]").Count
Write-Host "MOJIBAKE MATCHES: $bad"
Write-Host "widget.startPage left: " ([regex]::Matches($src, [regex]::Escape('widget.startPage'))).Count
Write-Host "_effStart count: " ([regex]::Matches($src, '_effStart')).Count
