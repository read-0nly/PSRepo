cls
$red = $false
$string = "HelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHelloHello"
for($j = 0; $j -lt 30; $j++){
    for($i = 0; $i -lt 29; $i++){
        if($red){
            write-host '//' -NoNewline -ForegroundColor Red
        }
        else
        {
            write-host '//' -NoNewline -ForegroundColor white
        }
        $red = -not $red
    }
    write-host ""
    write-host ($string.substring($j, 30))
    for($i = 0; $i -lt 29; $i++){
        if($red){
            write-host '//' -NoNewline -ForegroundColor Red
        }
        else
        {
            write-host '//' -NoNewline -ForegroundColor white
        }
        $red = -not $red
    }
    $red = -not $red
    start-sleep -milliseconds 500
    cls
}
