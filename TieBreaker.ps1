# Define two variables with random values
$var1 = Get-Random -Minimum 1 -Maximum 10
$var2 = Get-Random -Minimum 1 -Maximum 10

# Output the initial values
Write-Host "Initial values: var1 = $var1, var2 = $var2"

# Check if the variables are the same
if ($var1 -eq $var2) {
    # Randomly choose to increment either var1 or var2
    if (Get-Random -Minimum 0 -Maximum 2) {
        $var1 += 1
        Write-Host "Variables were the same. Incremented var1 to $var1."
    } else {
        $var2 += 1
        Write-Host "Variables were the same. Incremented var2 to $var2."
    }
} else {
    Write-Host "Variables are different. No changes made."
}

# Output the final values
Write-Host "Final values: var1 = $var1, var2 = $var2"
