# ===== Syaahi Error Case Verification =====
# Validates the API returns correct error codes for misuse.

$base = "http://localhost:4000/api/v1"
$results = @()

function Test-ErrorCase {
  param(
    [string]$Name,
    [int]$Expected,
    [scriptblock]$Action
  )

  $actual = 0
  $body = ""
  $passed = $false

  try {
    & $Action | Out-Null
    $actual = 200
  } catch {
    $actual = [int]$_.Exception.Response.StatusCode.value__
    try {
      $stream = $_.Exception.Response.GetResponseStream()
      $stream.Position = 0
      $reader = New-Object System.IO.StreamReader($stream)
      $body = $reader.ReadToEnd()
    } catch { $body = "(no body)" }
  }

  $passed = ($actual -eq $Expected)
  $icon = if ($passed) { "[PASS]" } else { "[FAIL]" }
  $color = if ($passed) { "Green" } else { "Red" }

  Write-Host ""
  Write-Host "$icon  $Name" -ForegroundColor $color
  Write-Host "       Expected: $Expected  |  Actual: $actual" -ForegroundColor Gray
  if ($body -and $body.Length -lt 300) {
    Write-Host "       Body: $body" -ForegroundColor DarkGray
  }

  return [PSCustomObject]@{
    Name     = $Name
    Expected = $Expected
    Actual   = $actual
    Passed   = $passed
  }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  SYAAHI ERROR CASE VERIFICATION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

# ===== TESTS =====
$results += Test-ErrorCase -Name "1. Duplicate Email Signup" -Expected 409 -Action {
  $b = @{
    email = "test101312@syaahi.com"
    username = "newuser$(Get-Random)"
    displayName = "Dup Email Test"
    password = "AnotherPass123"
  } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $b -ContentType "application/json"
}

$results += Test-ErrorCase -Name "2. Duplicate Username Signup" -Expected 409 -Action {
  $b = @{
    email = "fresh$(Get-Random)@syaahi.com"
    username = "test101312"
    displayName = "Dup Username Test"
    password = "AnotherPass123"
  } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $b -ContentType "application/json"
}

$results += Test-ErrorCase -Name "3. Signup Missing Password" -Expected 400 -Action {
  $b = @{
    email = "missing$(Get-Random)@syaahi.com"
    username = "mp$(Get-Random)"
    displayName = "Missing Pass"
  } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $b -ContentType "application/json"
}

$results += Test-ErrorCase -Name "4. Signup Invalid Email Format" -Expected 400 -Action {
  $b = @{
    email = "not-an-email"
    username = "bm$(Get-Random)"
    displayName = "Bad Mail"
    password = "ValidPass123"
  } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $b -ContentType "application/json"
}

$results += Test-ErrorCase -Name "5. Signup Invalid Username (caps + dash)" -Expected 400 -Action {
  $b = @{
    email = "caps$(Get-Random)@syaahi.com"
    username = "INVALID-Caps"
    displayName = "Caps Test"
    password = "ValidPass123"
  } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $b -ContentType "application/json"
}

$results += Test-ErrorCase -Name "6. Signup Password Too Short" -Expected 400 -Action {
  $b = @{
    email = "short$(Get-Random)@syaahi.com"
    username = "sp$(Get-Random)"
    displayName = "Short Pass"
    password = "abc"
  } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/auth/signup" -Method Post -Body $b -ContentType "application/json"
}

$results += Test-ErrorCase -Name "7. /me with Garbage JWT" -Expected 401 -Action {
  Invoke-RestMethod -Uri "$base/auth/me" -Headers @{ Authorization = "Bearer this.is.not.a.jwt" }
}

$results += Test-ErrorCase -Name "8. /me Without Token" -Expected 401 -Action {
  Invoke-RestMethod -Uri "$base/auth/me"
}

$results += Test-ErrorCase -Name "9. /me With Wrong Auth Scheme" -Expected 401 -Action {
  Invoke-RestMethod -Uri "$base/auth/me" -Headers @{ Authorization = "Basic abc123" }
}

$results += Test-ErrorCase -Name "10. Get Non-existent Poem" -Expected 404 -Action {
  Invoke-RestMethod -Uri "$base/poems/00000000-0000-0000-0000-000000000000"
}

$results += Test-ErrorCase -Name "11. Create Poem Without Auth" -Expected 401 -Action {
  $b = @{ content = "Trying to write without login"; language = "ENGLISH" } | ConvertTo-Json
  Invoke-RestMethod -Uri "$base/poems" -Method Post -Body $b -ContentType "application/json"
}

# Login for auth-required tests
$token = $null
try {
  $loginBody = @{ email = "test101312@syaahi.com"; password = "MyStrongPass123" } | ConvertTo-Json
  $login = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
  $token = $login.data.token
} catch {
  Write-Host ""
  Write-Host "[WARN] Could not login (rate limited?). Skipping tests 12-13." -ForegroundColor Yellow
}

if ($token) {
  $results += Test-ErrorCase -Name "12. Create Poem With Empty Content" -Expected 400 -Action {
    $b = @{ content = ""; language = "ENGLISH" } | ConvertTo-Json
    Invoke-RestMethod -Uri "$base/poems" -Method Post -Body $b -ContentType "application/json" -Headers @{ Authorization = "Bearer $token" }
  }

  $results += Test-ErrorCase -Name "13. Poem With Invalid Emotion Enum" -Expected 400 -Action {
    $b = @{ content = "Test"; language = "ENGLISH"; emotion = "JEALOUSY" } | ConvertTo-Json
    Invoke-RestMethod -Uri "$base/poems" -Method Post -Body $b -ContentType "application/json" -Headers @{ Authorization = "Bearer $token" }
  }
}

# ===== SUMMARY =====
$total  = $results.Count
$passed = ($results | Where-Object { $_.Passed }).Count
$failed = $total - $passed

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  RESULTS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Total : $total"
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })

if ($failed -gt 0) {
  Write-Host ""
  Write-Host "Failed tests:" -ForegroundColor Red
  $results | Where-Object { -not $_.Passed } | ForEach-Object {
    Write-Host "  - $($_.Name) (expected $($_.Expected), got $($_.Actual))" -ForegroundColor Red
  }
}

Write-Host ""
if ($failed -eq 0) {
  Write-Host "ALL ERROR CASES HANDLED CORRECTLY" -ForegroundColor Green
} else {
  Write-Host "Some error cases need fixing." -ForegroundColor Red
}
Write-Host ""