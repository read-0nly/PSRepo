$steps =@(
{
<#   Var Declaration   #>
<#    Board Display    #>
<#      Set cell       #>
<# Clear the gameboard #>
<# Check if play legal #>
<#    Win Condition    #>
<#   Player Flipping   #>
<#     Play a turn     #>
<#      Game loop      #>
},
{
    $Player1="X"
    $Player2="O"
    $CurrentPlayer=$Player1
    $NoPlayer = " "
    $GameBoard = @(
        @($NoPlayer,$NoPlayer,$NoPlayer),
        @($NoPlayer,$NoPlayer,$NoPlayer),
        @($NoPlayer,$NoPlayer,$NoPlayer)
    )
},
{
    <# Board Display #>
    function displayBoard(){
        write-host ($GameBoard[0][0] + " | "+ $GameBoard[0][1] + " | " +$GameBoard[0][2])
        write-host "--+---+--"
        write-host ($GameBoard[1][0] + " | "+ $GameBoard[1][1] + " | " +$GameBoard[1][2])
        write-host "--+---+--"
        write-host ($GameBoard[2][0] + " | "+ $GameBoard[2][1] + " | " +$GameBoard[2][2])
    }
},
{
    <# Board Test #>
    write-host "Display Test" -ForegroundColor Green
    displayBoard
},
{
    <# Set cell #>
    function setCell(){
        param(
            $GameBoard,
            $x,
            $y
        )
        $Gameboard[$x][$y] = $CurrentPlayer
    }
},
{
    <# Set Test #>
    write-host "setCell Test" -ForegroundColor Red
    setCell $GameBoard 0 0
    displayBoard
},
{   
    <# Clear the gameboard #>
    function clearBoard(){
        $GBoard = @(
            @($NoPlayer,$NoPlayer,$NoPlayer),
            @($NoPlayer,$NoPlayer,$NoPlayer),
            @($NoPlayer,$NoPlayer,$NoPlayer)
        )
        return $GBoard
    }
},
{
    <# Clear test #>
    write-host "Clear Test" -ForegroundColor Red
    $Gameboard = clearBoard
    displayBoard
},
{
    <# Check if play legal #>
    function checkLegal(){
        param($x,$y)
        return ($GameBoard[$x][$y] -eq $NoPlayer)
    }
},
{
    <# legal test #>
    write-host "legal Test" -ForegroundColor Red
    setCell $GameBoard 0 0
    displayBoard
    write-host ("Playing 0,0 again would be legal? "+(checkLegal 0 0))
    write-host ("Playing 0,1 would be legal? "+(checkLegal 0 1))
},
{    
    <# Win Condition #>
    function checkWin(){
        #Check each row
        for ($i = 0; $i -le 2; $i++){
            if(
                #Check Row
                ($GameBoard[$i][0] -eq $CurrentPlayer) -and ($GameBoard[$i][1] -eq $CurrentPlayer) -and($GameBoard[$i][2] -eq $CurrentPlayer)
            ){
                return $true
            }
        }
        #Check each column
        for ($i = 0; $i -le 2; $i++){
            if(
                #Check Column
                ($GameBoard[0][$i] -eq $CurrentPlayer) -and ($GameBoard[1][$i] -eq $CurrentPlayer) -and ($GameBoard[2][$i] -eq $CurrentPlayer)
            ){
                return $true
            }
        }
        #Diagonal TopLeft-BottomRight
        if(
            ($GameBoard[0][0] -eq $CurrentPlayer) -and ($GameBoard[1][1] -eq $CurrentPlayer) -and ($GameBoard[2][2] -eq $CurrentPlayer)
        ){
            return $true
        }
        #Diagonal TopRight-BottomLeft
        elseif(
            ($GameBoard[2][0] -eq $CurrentPlayer) -and ($GameBoard[1][1] -eq $CurrentPlayer) -and ($GameBoard[0][2] -eq $CurrentPlayer)
        ){
            return $true
        }    
    }
    
},
{
    <# Win test #>
    write-host "win Test 1" -ForegroundColor Red
    setCell $GameBoard 0 0
    setCell $GameBoard 0 1
    if(checkWin){write-host "Won!"}else{write-host "NoWin"}
    displayBoard
    $Gameboard = clearBoard
},
{
    write-host "win Test 2" -ForegroundColor Red
    setCell $GameBoard 0 0
    setCell $GameBoard 0 1
    setCell $GameBoard 0 2
    if(checkWin){write-host "Won!"}else{write-host "NoWin"}
    displayBoard
    $Gameboard = clearBoard
},
{
    write-host "win Test 3" -ForegroundColor Red
    setCell $GameBoard 0 0
    setCell $GameBoard 1 0
    setCell $GameBoard 2 0
    if(checkWin){write-host "Won!"}else{write-host "NoWin"}
    displayBoard
    $Gameboard = clearBoard
},
{
    write-host "win Test 4" -ForegroundColor Red
    setCell $GameBoard 0 0
    setCell $GameBoard 1 1
    setCell $GameBoard 2 2
    if(checkWin){write-host "Won!"}else{write-host "NoWin"}
    displayBoard
    $Gameboard = clearBoard
},
{
    write-host "win Test 5" -ForegroundColor Red
    setCell $GameBoard 2 0
    setCell $GameBoard 1 1
    setCell $GameBoard 0 2
    if(checkWin){write-host "Won!"}else{write-host "NoWin"}
    displayBoard
},
{
    <# Player Flipping #>
    function flipPlayer(){
        switch($CurrentPlayer){
            $Player1 {
                return $Player2
            }
            $Player2{
                return $Player1
            }
        }
    }
},
{
    <# Flipping test #>
    write-host "flip Test" -ForegroundColor Magenta
    $currentPlayer = flipplayer
    write-host $CurrentPlayer
    $currentPlayer = flipplayer
    write-host $CurrentPlayer
    $currentPlayer = flipplayer
    write-host $CurrentPlayer
},
{
<# Play a turn #>
    function playerTurn(){
        $error = ""
        do{
            cls
            write-host ("Player turn: " + $CurrentPlayer)
            write-host $error -foregroundcolor red
            write-host
            displayboard
            write-host
            write-host
            $x = read-host "enter row"
            $y = read-host "enter column"
            $error = "Please enter a valid play"
        }
        while( -not (checkLegal $x $y))
        setCell $GameBoard $x $y
    }
},
{
    <# Play Test #>
    playerTurn
    playerTurn
    playerTurn
},
{
<# Game loop #>
    function gameLoopAlpha(){
        $KeepGoing = $True
        $Gameboard = clearBoard
        while($KeepGoing){
            playerTurn
            if(checkwin){
                $KeepGoing =$false
            }
            else{
                $currentPlayer = flipplayer
                $KeepGoing= $true
            }
        }
        cls
        write-host
        write-host
        displayboard
        write-host
        write-host
        write-host ("Player " +  $currentPlayer + " Won!") -ForegroundColor green
    }
    gameLoopAlpha
})




$i = 0;
$steps | %{
cls
echo "----------------------------------------------------------"
echo ("Current Step : "+($i));
echo "----------------------------------------------------------"
echo ""
echo ""
echo  $_
echo ""
echo ""
echo "----------------------------------------------------------"
read-host
cls
echo "----------------------------------------------------------"
echo ("Current Step - Result : "+($i++));
echo "----------------------------------------------------------"
echo ""
echo ""
echo (.$_)
echo ""
echo ""
echo "----------------------------------------------------------"
read-host
}
