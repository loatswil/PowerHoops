<#
    .SYNOPSIS
        Simulating a basketball tournament from a CSV file

    .DESCRIPTION
        The script takes in the CSV and parses out
        each team then playing a simulated game
        based on region, rank, and bonus in the
        proper order to produce a final four
        and final game.

        The 'bonus' is a number added to each 
        game score for 'reasons' only known to you.
        
        If you want a truly random game, set all of
        the modifier and bonus values the same.

        The results of each game can be written 
        out to a CSV file for input into other 
        platforms for analysis and stats using
        the data for research.
        
    .PARAMETER CSV
        File for reading the teams.
        Should be formatted as follows

        region, name, mascot, rank, bonus
        east, Connecticut, Huskies,1,0
        west, Stetson, Hatters,16,0
        south, Florida Atlantic, Owls,8,0
        midwest, San Diego State, Aztecs,5,0

    .PARAMETER ShowResults
        Optional to show the results of the
        final four and final game. Without 
        this the results are hidden in case
        you want to perform many runs to 
        create a lot of data.

    .PARAMETER NoSave
        Used if you just want to see the results
        and don't want to create a bunch of files.

    .OUTPUTS
        Without the NoSave option, a file will be
        written to the current directory with the 
        results of the each game.

    .EXAMPLE
        March-Madness.ps1 -CSV .\teams.csv -ShowResults -NoSave

        This will run the script taking in the teams.csv file
        from the current directory. It will show the results 
        but not create a file.

        March-Madness.ps1 -CSV .\teams.csv 

        Without and parameters there is no output and a file is
        written with the results.

    .NOTES
        
        To see all Game18 results from files in the current directory:
        gci game*.csv | % {import-csv $_ | where {$_.gamename -like "Game18"}} `
            | select Team1, Rank1, Score1, Team2, Rank2, Score2 | ft

#>

Param(
    # Incoming file name
    [Parameter(Mandatory=$true)]
    [string] $CSV,
    # Switch to show results or simply
    # run the scenario and create the
    # output in case you want many
    # runs just to create data.
    [Parameter(Mandatory=$false)]
    [switch] $ShowResults,
    # Switch to prevent creation 
    # of the output. Mainly for testing
    # the output without creating a 
    # bunch of files.
    [Parameter(Mandatory=$false)]
    [switch] $NoSave
)

# Results holds all of the stats from the Play-Game function
# and are written (if desired) to a file at the end.

$Results = New-Object System.Collections.Generic.List[pscustomobject]

Function Get-Modifier {
    <#
        .SYNOPSIS
            Function to calculate how much weight the ranking of
            each team has on the score of the game. Typically the 
            higher the ranking, the more they would score. Making
            these all the same would give a truly random outcome.
        .EXAMPLE
            Get-Modifier -rank 16

            This would return a modifier of 1 from below.
    #>

    # Incoming rank from the CSV file.
    Param([int]$Rank)
    Switch ($Rank) {
    {$_ -in 1..2} {$Modifier = 8}
    {$_ -in 3..4} {$Modifier = 7}
    {$_ -in 5..6} {$Modifier = 6}
    {$_ -in 7..8} {$Modifier = 5}
    {$_ -in 9..10} {$Modifier = 4}
    {$_ -in 11..12} {$Modifier = 3}
    {$_ -in 13..14} {$Modifier = 2}
    {$_ -in 15..16} {$Modifier = 1}
    }
    Return $Modifier
}

Function Play-Game {
    <#
        .SYNOPSIS
            Function to simulate an actual game. You can adjust the
            max and min values if you want a closer game. Beware that 
            ties can be a thing. I never built 'tie-detection' into the 
            logic. For the statistics to work right, you need to pass
            the teams in to the function as an object with the values
            from the CSV file.
        .EXAMPLE
            Play-Game -Team1 $Team1 -Team2 $Team2 -GameName $GameName

            This plays the game and writes the statistics to $results
            as an $obj.
    #>

    # GameName to track the games in $results.
    # Team1 and Team2 are objects from the CSV
    # to track the names and other stats in $results.
    param([string]$GameName,[PSobject]$Team1,[PSobject]$Team2)

    $Score1 = (((Get-Random -Minimum 55 -Maximum 85) + (2*(Get-Modifier -Rank $Team1.rank))) + $Team1.bonus)
    $Score2 = (((Get-Random -Minimum 55 -Maximum 85) + (2*(Get-Modifier -Rank $Team2.rank))) + $Team2.bonus)

    $Mod1 = (Get-Modifier -Rank $Team1.rank)
    $Mod2 = (Get-Modifier -Rank $Team2.rank)    

    if ($Score1 -gt $Score2) {
        $GameWinner = $Team1
        $GameLoser = $Team2
        } Else {
        $GameWinner = $Team2
        $GameLoser = $Team1 }
    
    $Obj = [pscustomobject]@{
        GameName = $GameName
        Team1 = $Team1.name
        Mascot1 = $Team1.Mascot
        Rank1 = $Team1.rank
        Mod1 = $Mod1
        Bonus1 = $Team1.bonus
        Score1 = $Score1
        Team2 = $Team2.name
        Mascot2 = $Team2.Mascot
        Rank2 = $Team2.rank
        Mod2 = $Mod2
        Bonus2 = $Team2.bonus
        Score2 = $Score2 }

    $Addit = $Results.add($Obj)

    Return $GameWinner
}

# Importing and sorting the teams

$Teams = Import-Csv $CSV

# Big East Teams
$Team1e = $Teams | Where-Object {$_.rank -eq 1 -and $_.region -eq "east"}
$Team2e = $Teams | Where-Object {$_.rank -eq 2 -and $_.region -eq "east"}
$Team3e = $Teams | Where-Object {$_.rank -eq 3 -and $_.region -eq "east"}
$Team4e = $Teams | Where-Object {$_.rank -eq 4 -and $_.region -eq "east"}
$Team5e = $Teams | Where-Object {$_.rank -eq 5 -and $_.region -eq "east"}
$Team6e = $Teams | Where-Object {$_.rank -eq 6 -and $_.region -eq "east"}
$Team7e = $Teams | Where-Object {$_.rank -eq 7 -and $_.region -eq "east"}
$Team8e = $Teams | Where-Object {$_.rank -eq 8 -and $_.region -eq "east"}
$Team9e = $Teams | Where-Object {$_.rank -eq 9 -and $_.region -eq "east"}
$Team10e = $Teams | Where-Object {$_.rank -eq 10 -and $_.region -eq "east"}
$Team11e = $Teams | Where-Object {$_.rank -eq 11 -and $_.region -eq "east"}
$Team12e = $Teams | Where-Object {$_.rank -eq 12 -and $_.region -eq "east"}
$Team13e = $Teams | Where-Object {$_.rank -eq 13 -and $_.region -eq "east"}
$Team14e = $Teams | Where-Object {$_.rank -eq 14 -and $_.region -eq "east"}
$Team15e = $Teams | Where-Object {$_.rank -eq 15 -and $_.region -eq "east"}
$Team16e = $Teams | Where-Object {$_.rank -eq 16 -and $_.region -eq "east"}
    
# West Teams
$Team1w = $Teams | Where-Object {$_.rank -eq 1 -and $_.region -eq "west"}
$Team2w = $Teams | Where-Object {$_.rank -eq 2 -and $_.region -eq "west"}
$Team3w = $Teams | Where-Object {$_.rank -eq 3 -and $_.region -eq "west"}
$Team4w = $Teams | Where-Object {$_.rank -eq 4 -and $_.region -eq "west"}
$Team5w = $Teams | Where-Object {$_.rank -eq 5 -and $_.region -eq "west"}
$Team6w = $Teams | Where-Object {$_.rank -eq 6 -and $_.region -eq "west"}
$Team7w = $Teams | Where-Object {$_.rank -eq 7 -and $_.region -eq "west"}
$Team8w = $Teams | Where-Object {$_.rank -eq 8 -and $_.region -eq "west"}
$Team9w = $Teams | Where-Object {$_.rank -eq 9 -and $_.region -eq "west"}
$Team10w = $Teams | Where-Object {$_.rank -eq 10 -and $_.region -eq "west"}
$Team11w = $Teams | Where-Object {$_.rank -eq 11 -and $_.region -eq "west"}
$Team12w = $Teams | Where-Object {$_.rank -eq 12 -and $_.region -eq "west"}
$Team13w = $Teams | Where-Object {$_.rank -eq 13 -and $_.region -eq "west"}
$Team14w = $Teams | Where-Object {$_.rank -eq 14 -and $_.region -eq "west"}
$Team15w = $Teams | Where-Object {$_.rank -eq 15 -and $_.region -eq "west"}
$Team16w = $Teams | Where-Object {$_.rank -eq 16 -and $_.region -eq "west"}
    
# South Teams
$Team1s = $Teams | Where-Object {$_.rank -eq 1 -and $_.region -eq "south"}
$Team2s = $Teams | Where-Object {$_.rank -eq 2 -and $_.region -eq "south"}
$Team3s = $Teams | Where-Object {$_.rank -eq 3 -and $_.region -eq "south"}
$Team4s = $Teams | Where-Object {$_.rank -eq 4 -and $_.region -eq "south"}
$Team5s = $Teams | Where-Object {$_.rank -eq 5 -and $_.region -eq "south"}
$Team6s = $Teams | Where-Object {$_.rank -eq 6 -and $_.region -eq "south"}
$Team7s = $Teams | Where-Object {$_.rank -eq 7 -and $_.region -eq "south"}
$Team8s = $Teams | Where-Object {$_.rank -eq 8 -and $_.region -eq "south"}
$Team9s = $Teams | Where-Object {$_.rank -eq 9 -and $_.region -eq "south"}
$Team10s = $Teams | Where-Object {$_.rank -eq 10 -and $_.region -eq "south"}
$Team11s = $Teams | Where-Object {$_.rank -eq 11 -and $_.region -eq "south"}
$Team12s = $Teams | Where-Object {$_.rank -eq 12 -and $_.region -eq "south"}
$Team13s = $Teams | Where-Object {$_.rank -eq 13 -and $_.region -eq "south"}
$Team14s = $Teams | Where-Object {$_.rank -eq 14 -and $_.region -eq "south"}
$Team15s = $Teams | Where-Object {$_.rank -eq 15 -and $_.region -eq "south"}
$Team16s = $Teams | Where-Object {$_.rank -eq 16 -and $_.region -eq "south"}
    
# Midwest Teams
$Team1m = $Teams | Where-Object {$_.rank -eq 1 -and $_.region -eq "midwest"}
$Team2m = $Teams | Where-Object {$_.rank -eq 2 -and $_.region -eq "midwest"}
$Team3m = $Teams | Where-Object {$_.rank -eq 3 -and $_.region -eq "midwest"}
$Team4m = $Teams | Where-Object {$_.rank -eq 4 -and $_.region -eq "midwest"}
$Team5m = $Teams | Where-Object {$_.rank -eq 5 -and $_.region -eq "midwest"}
$Team6m = $Teams | Where-Object {$_.rank -eq 6 -and $_.region -eq "midwest"}
$Team7m = $Teams | Where-Object {$_.rank -eq 7 -and $_.region -eq "midwest"}
$Team8m = $Teams | Where-Object {$_.rank -eq 8 -and $_.region -eq "midwest"}
$Team9m = $Teams | Where-Object {$_.rank -eq 9 -and $_.region -eq "midwest"}
$Team10m = $Teams | Where-Object {$_.rank -eq 10 -and $_.region -eq "midwest"}
$Team11m = $Teams | Where-Object {$_.rank -eq 11 -and $_.region -eq "midwest"}
$Team12m = $Teams | Where-Object {$_.rank -eq 12 -and $_.region -eq "midwest"}
$Team13m = $Teams | Where-Object {$_.rank -eq 13 -and $_.region -eq "midwest"}
$Team14m = $Teams | Where-Object {$_.rank -eq 14 -and $_.region -eq "midwest"}
$Team15m = $Teams | Where-Object {$_.rank -eq 15 -and $_.region -eq "midwest"}
$Team16m = $Teams | Where-Object {$_.rank -eq 16 -and $_.region -eq "midwest"}

# Playing the games

# East Region
# Round 1e
$Game1e = Play-Game -GameName Game1e -Team1 $Team1e -Team2 $Team16e
$Game2e = Play-Game -GameName Game2e -Team1 $Team8e -Team2 $Team9e
$Game3e = Play-Game -GameName Game3e -Team1 $Team5e -Team2 $Team12e
$Game4e = Play-Game -GameName Game4e -Team1 $Team4e -Team2 $Team13e
$Game5e = Play-Game -GameName Game5e -Team1 $Team6e -Team2 $Team11e
$Game6e = Play-Game -GameName Game6e -Team1 $Team3e -Team2 $Team14e
$Game7e = Play-Game -GameName Game7e -Team1 $Team7e -Team2 $Team10e
$Game8e = Play-Game -GameName Game8e -Team1 $Team2e -Team2 $Team15e
# Round 2e
$Game9e = Play-Game -GameName Game9e -Team1 $Game1e -Team2 $Game2e
$Game10e = Play-Game -GameName Game10e -Team1 $Game3e -Team2 $Game4e
$Game11e = Play-Game -GameName Game11e -Team1 $Game5e -Team2 $Game6e
$Game12e = Play-Game -GameName Game12e -Team1 $Game7e -Team2 $Game8e
# Round 3e
$Game13e = Play-Game -GameName Game13e -Team1 $Game9e -Team2 $Game10e
$Game14e = Play-Game -GameName Game14e -Team1 $Game11e -Team2 $Game12e
# Round 4e
$Game15e = Play-Game -GameName Game15e -Team1 $Game13e -Team2 $Game14e
    
# West Region
# Round 1w
$Game1w = Play-Game -GameName Game1w -Team1 $Team1w -Team2 $Team16w
$Game2w = Play-Game -GameName Game2w -Team1 $Team8w -Team2 $Team9w
$Game3w = Play-Game -GameName Game3w -Team1 $Team5w -Team2 $Team12w
$Game4w = Play-Game -GameName Game4w -Team1 $Team4w -Team2 $Team13w
$Game5w = Play-Game -GameName Game5w -Team1 $Team6w -Team2 $Team11w
$Game6w = Play-Game -GameName Game6w -Team1 $Team3w -Team2 $Team14w
$Game7w = Play-Game -GameName Game7w -Team1 $Team7w -Team2 $Team10w
$Game8w = Play-Game -GameName Game8w -Team1 $Team2w -Team2 $Team15w
# Round 2w
$Game9w = Play-Game -GameName Game9w -Team1 $Game1w -Team2 $Game2w
$Game10w = Play-Game -GameName Game10w -Team1 $Game3w -Team2 $Game4w
$Game11w = Play-Game -GameName Game11w -Team1 $Game5w -Team2 $Game6w
$Game12w = Play-Game -GameName Game12w -Team1 $Game7w -Team2 $Game8w
# Round 3w
$Game13w = Play-Game -GameName Game13w -Team1 $Game9w -Team2 $Game10w
$Game14w = Play-Game -GameName Game14w -Team1 $Game11w -Team2 $Game12w
# Round 4w
$Game15w = Play-Game -GameName Game15w -Team1 $Game13w -Team2 $Game14w

# South Region
# Round 1s
$Game1s = Play-Game -GameName Game1s -Team1 $Team1s -Team2 $Team16s
$Game2s = Play-Game -GameName Game2s -Team1 $Team8s -Team2 $Team9s
$Game3s = Play-Game -GameName Game3s -Team1 $Team5s -Team2 $Team12s
$Game4s = Play-Game -GameName Game4s -Team1 $Team4s -Team2 $Team13s
$Game5s = Play-Game -GameName Game5s -Team1 $Team6s -Team2 $Team11s
$Game6s = Play-Game -GameName Game6s -Team1 $Team3s -Team2 $Team14s
$Game7s = Play-Game -GameName Game7s -Team1 $Team7s -Team2 $Team10s
$Game8s = Play-Game -GameName Game8s -Team1 $Team2s -Team2 $Team15s
# Round 2s
$Game9s = Play-Game -GameName Game9s -Team1 $Game1s -Team2 $Game2s
$Game10s = Play-Game -GameName Game10s -Team1 $Game3s -Team2 $Game4s
$Game11s = Play-Game -GameName Game11s -Team1 $Game5s -Team2 $Game6s
$Game12s = Play-Game -GameName Game12s -Team1 $Game7s -Team2 $Game8s
# Round 3s
$Game13s = Play-Game -GameName Game13s -Team1 $Game9s -Team2 $Game10s
$Game14s = Play-Game -GameName Game14s -Team1 $Game11s -Team2 $Game12s
# Round 4s
$Game15s = Play-Game -GameName Game15s -Team1 $Game13s -Team2 $Game14s
    
# Midwest Region
# Round 1m
$Game1m = Play-Game -GameName Game1m -Team1 $Team1m -Team2 $Team16m
$Game2m = Play-Game -GameName Game2m -Team1 $Team8m -Team2 $Team9m
$Game3m = Play-Game -GameName Game3m -Team1 $Team5m -Team2 $Team12m
$Game4m = Play-Game -GameName Game4m -Team1 $Team4m -Team2 $Team13m
$Game5m = Play-Game -GameName Game5m -Team1 $Team6m -Team2 $Team11m
$Game6m = Play-Game -GameName Game6m -Team1 $Team3m -Team2 $Team14m
$Game7m = Play-Game -GameName Game7m -Team1 $Team7m -Team2 $Team10m
$Game8m = Play-Game -GameName Game8m -Team1 $Team2m -Team2 $Team15m
# Round 2m
$Game9m = Play-Game -GameName Game9m -Team1 $Game1m -Team2 $Game2m
$Game10m = Play-Game -GameName Game10m -Team1 $Game3m -Team2 $Game4m
$Game11m = Play-Game -GameName Game11m -Team1 $Game5m -Team2 $Game6m
$Game12m = Play-Game -GameName Game12m -Team1 $Game7m -Team2 $Game8m
# Round 3m
$Game13m = Play-Game -GameName Game13m -Team1 $Game9m -Team2 $Game10m
$Game14m = Play-Game -GameName Game14m -Team1 $Game11m -Team2 $Game12m
# Round 4m
$Game15m = Play-Game -GameName Game15m -Team1 $Game13m -Team2 $Game14m

##############
# Final Four #
##############
$Game16 = Play-Game -GameName Game16 -Team1 $Game15e -Team2 $Game15w
$Game17 = Play-Game -GameName Game17 -Team1 $Game15m -Team2 $Game15s
$Game18 = Play-Game -GameName Game18 -Team1 $Game16 -Team2 $Game17
$Winner = $Game18

# Showing or not showing the results.

if ($ShowResults) {

    $16Team1 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Team1
    $16Team2 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Team2
    $16Score1 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Score1
    $16Score2 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Score2
    $16Rank1 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Rank1
    $16Rank2 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Rank2
    $16Mascot1 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Mascot1
    $16Mascot2 = $Results | Where-Object {$_.GameName -eq "Game16"} | Select Mascot2

    $17Team1 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Team1
    $17Team2 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Team2
    $17Score1 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Score1
    $17Score2 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Score2
    $17Rank1 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Rank1
    $17Rank2 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Rank2
    $17Mascot1 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Mascot1
    $17Mascot2 = $Results | Where-Object {$_.GameName -eq "Game17"} | Select Mascot2

    $18Team1 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Team1
    $18Team2 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Team2
    $18Score1 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Score1
    $18Score2 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Score2
    $18Rank1 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Rank1
    $18Rank2 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Rank2
    $18Mascot1 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Mascot1
    $18Mascot2 = $Results | Where-Object {$_.GameName -eq "Game18"} | Select Mascot2

    ""
    Write-Host "Final Four:"
    Write-Host "==========="
    Write-Host "The $($16Team1.Team1) $($16Mascot1.Mascot1)($($16Rank1.Rank1)) score: $($16Score1.Score1)"
    Write-Host "The $($16Team2.Team2) $($16Mascot2.Mascot2)($($16Rank2.Rank2)) score: $($16Score2.Score2)"
    Write-Host "The $($17Team1.Team1) $($17Mascot1.Mascot1)($($17Rank1.Rank1)) score: $($17Score1.Score1)"
    Write-Host "The $($17Team2.Team2) $($17Mascot2.Mascot2)($($17Rank2.Rank2)) score: $($17Score2.Score2)"
    ""
    Write-Host "Final game:"
    Write-Host "==========="
    Write-Host "The $($18Team1.Team1) $($18Mascot1.Mascot1)($($18Rank1.Rank1)) score: $($18Score1.Score1)"
    Write-Host "The $($18Team2.Team2) $($18Mascot2.Mascot2)($($18Rank2.Rank2)) score: $($18Score2.Score2)"
    Write-Host ""
}

# Writing or not writing a file.

if (!($NoSave)) {
    $tmppath =  "./" + "game-" + (Get-Date).ToString('yyyy_MM_dd_hhmmss') + ".csv"
    $results | export-csv -NoTypeInformation -Path $tmppath
    #
    # $tmppath   # Uncomment if you want the filename written to output.
    # ""
}