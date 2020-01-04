#Set player characters
$p1 = "X"
$p2 = "O"
#Count for the current turn
$Turn = 1
#Has the game been won?
$won = $false
#Who won?
$winner = ""
#Array representing the game board (3x3 table, or 3 rows containing 3 cells)
$gameboard = @(
    @(" "," "," "),
    @(" "," "," "),
    @(" "," "," ")
)

#Get coordinates from the player
function getCoord(){
    $row  =[int](read-host "Enter the row number")-1
    $col = [int](read-host "Enter the column number")-1
    #If the coordinates are valid, return them, otherwise ask again
    if (    
        #Coordinates are within valid range, 0-2 (Powershell arrays start at 0!)
        ($row -gt -1 -and $row -lt 3 -and $col -gt -1 -and $col -lt 3) -and
        #That cell isn't occupied
        ($gameboard[$row][$col] -ne $p1 -and $gameboard[$row][$col] -ne $p2)
       ){
            return @(($row),($col))
    }
    else{
        #Ask again, return what the new ask attempt results in
        write-host "Invalid play"
        return getCoord
    }
}

function checkWin(){
    #Check each row and column for a win, first the first row and first column, then the second row and second column, then the third row and column
    for($i=0; $i -lt 3; $i++){
        #Check the row
        $checkResult = countRow($i)
        #If the row has 3 for player 1, they win
        if($checkResult[0] -eq 3){
            #Set the winner to Player 1, and flag that the game is won
            $script:winner = $p1
            $script:won = $true
        }
        
        #If the row has 3 for player 2, they win
        if($checkResult[1] -eq 3){
            #Set the winner to Player 2, and flag that the game is won
            $script:winner = $p2
            $script:won = $true
        }
        #Check the column
        $checkResult = countCol($i)
        
        #If the column has 3 for player 1, they win
        if($checkResult[0] -eq 3){
            $script:winner = $p1
            $script:won = $true
        }
        
        #If the column has 3 for player 2, they win
        if($checkResult[1] -eq 3){
            $script:winner = $p2
            $script:won = $true
        }
    }
    #Check one diagonal then the next
    $checkResult = countDiag($true)
    if($checkResult[0] -eq 3){
        $script:winner = $p1
        $script:won = $true
    }
    if($checkResult[1] -eq 3){
        $script:winner = $p2
        $script:won = $true
    }    
    $checkResult = countDiag($false)
    if($checkResult[0] -eq 3){
        $script:winner = $p1
        $script:won = $true
    }
    if($checkResult[1] -eq 3){
        $script:winner = $p2
        $script:won = $true
    }
}

function drawScreen(){
    #Write the column labels along the top row
    write-host ("   1  2  3 ")
    write-host
    #Counter for the row labels
    $i=1
    #For each row, display the cells
    foreach ($row in $gameboard){
        #Write the row label before the cell enumeration
        write-host ($i+" ") -NoNewline
        #For each cell, write it to the line without going to the next line
        foreach($cell in $row){
            write-host ("  " + $cell) -NoNewline
        }
        #Go to the next line
        write-host
        write-host
        #Increment the row counter then loop
        $i++
    }
}

function countRow([int]$row){
    #Pick the cells of the selected row then count the player sigils in those cells
    $set = @($gameboard[$row][0],$gameboard[$row][1],$gameboard[$row][2])
    #Return the count of that row
    return countCells($set)
}
function countCol([int]$col){
    #Pick the cells of the selected column then count the player sigils in those cells
    $set = @($gameboard[0][$col],$gameboard[1][$col],$gameboard[2][$col])
    #Return the count of that column
    return countCells($set)
}
function countDiag([bool]$slashDir){
    # True is /, false is  \
    #Create the set first outside the conditional, so the result exists outside of the conditional scope
    $set = @()

    if($slashDir -eq $true){
        #Assign the / cells to the set
        $set = @($gameboard[2][0],$gameboard[1][1],$gameboard[0][2])
    }
    else{
        #Assign the \ cells to the set
        $set = @($gameboard[0][0],$gameboard[1][1],$gameboard[2][2])
    }
    #Count the player sigils in the set and return the results
    return countCells($set)
}
function countCells([string[]]$cells){
    #Set the variables to keep the count of player occurences
    $countP1 = 0
    $countP2 = 0
    #For each cell in the set, if it's player 1, add to countp1, if it's player 2, add to countp2
    foreach ($cell in $set){
        #Switch is just a weird if - alternatively, this is if($cell -eq p1){} elseif($cell -eq $p2){}
        switch($cell){
            #if cell is P1, add to p1
            $p1 {
                #add to p1
                $countP1++;
            }
            #if cell is P1, add to p2
            $p2{
                #add to p2
                $countP2++;
            }
        }
    }
    #return the count pair as an array
    return @($countP1,$countP2)
}

function play(){
    #Keep playing until the game is won
    While ( -not $won ){
        #Clear the screen
        cls

        #Figure out who's turn it is
        if (($turn % 2) -eq 0){
            #O's turn, even turn numbers
            #Draw the screen
            drawScreen
            #Make some space
            write-host;write-host
            #Write that it's Player 2's turn
            write-host ($p2 + "'s turn!") -foregroundColor Cyan
            #Get player coordinates
            $coords = getCoord
            #Assign the player to the selected cell
            $gameboard[$coords[0]][$coords[1]] = $p2
            #Check if the game is won
            checkWin
        }
        else{
            #X's turn, odd turn numbers
            #Draw the screen
            drawScreen
            #Make some space
            write-host;write-host
            #Write that it's Player 2's turn
            write-host ($p1 + "'s turn!") -foregroundColor Magenta
            #Get player coordinates
            $coords = getCoord
            #Assign the player to the selected cell
            $gameboard[$coords[0]][$coords[1]] = $p1
            #Check if the game is won
            checkWin
        }
        #increment the turn counter
        $turn++
    }
    #The play loop is broken so a winner was declared
    #Clear the screen
    cls
    #Draw the final play
    drawscreen
    #Declare the winner
    write-host ($winner + " won the game!") -ForegroundColor Green
}