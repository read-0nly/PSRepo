$VT100 = [pscustomobject]@{
    "Fore" = @{
        "Black" = [char]27+"[30m" ;
        "Red" = [char]27+"[31m" ;
        "Green" = [char]27+"[32m" ;
        "Yellow" = [char]27+"[33m" ;
        "Blue" = [char]27+"[34m" ;
        "Magenta" = [char]27+"[35m" ;
        "Cyan" = [char]27+"[36m" ;
        "White" = [char]27+"[37m" ;
        "Extended" = [char]27+"[38m" ;
        "Reset" = [char]27+"[39m" ;
        "Black+" = [char]27+"[90m" ;
        "Red+" = [char]27+"[91m" ;
        "Green+" = [char]27+"[92m" ;
        "Yellow+" = [char]27+"[93m" ;
        "Blue+" = [char]27+"[94m" ;
        "Magenta+" = [char]27+"[95m" ;
        "Cyan+" = [char]27+"[96m" ;
        "White+" = [char]27+"[97m" ;       
    }
    "Back" = @{
        "Black" = [char]27+"[40m" ;
        "Red" = [char]27+"[41m" ;
        "Green" = [char]27+"[42m" ;
        "Yellow" = [char]27+"[43m" ;
        "Blue" = [char]27+"[44m" ;
        "Magenta" = [char]27+"[45m" ;
        "Cyan" = [char]27+"[46m" ;
        "White" = [char]27+"[47m" ;
        "Extended" = [char]27+"[48m" ;
        "Reset" = [char]27+"[49m" ;
        "Black+" = [char]27+"[100m" ;
        "Red+" = [char]27+"[101m" ;
        "Green+" = [char]27+"[102m" ;
        "Yellow+" = [char]27+"[103m" ;
        "Blue+" = [char]27+"[104m" ;
        "Magenta+" = [char]27+"[105m" ;
        "Cyan+" = [char]27+"[106m" ;
        "White+" = [char]27+"[107m" ;    
    
    }
    "Style" = @{
        "Bold" = [char]27+"[1m"
        "NoBold" = [char]27+"[22m"
        "Underline" = [char]27+"[4m"
        "NoUnderline"=[char]27+"[24m"
        "Negative" = [char]27+"[7m"
        "Positive" = [char]27+"[27m"
    }
    "ResetAll" = [char]27+"[0m"
}
