﻿$steps = @({5+9}
,{8*3}
,{8/9}
,{"Hello"}
,{$x=2}
,{$x * 5}
,{$y = $x * 5}
,{$y}
,{$z = "hello"}
,{$z + "world"}
,{$people = @("Jim","Bob","Smith")}
,{$people}
,{$people[0]}
,{$people[1]}
,{$people[-1]}
)
$i = 0;
$steps | %{
cls
echo "----------------------------------------------------------"
echo ("Current Step : "+($i++));
echo "----------------------------------------------------------"
echo ""
echo ""
echo  $_
echo ""
echo ""
echo "----------------------------------------------------------"
echo ""
echo ""
echo (.$_)
echo ""
echo ""
echo "----------------------------------------------------------"
read-host
}
