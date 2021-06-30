$placeCode = "#######"  # You'll have to find your own placecode - I went here to find mine: http://www.iro.umontreal.ca/~roys/ift2905/tp1/meteo/code_villes. You can also look at a network trace loading the weather network for your locality, then hovering over the Air Quality/UV/Pollen info - it'll show up in the link though it gets redirected after
$weather = (invoke-restmethod "https://weatherapi.pelmorex.com/api/v1/observation/placecode/$placeCode").observation          
$T = $weather.temperature 
$rh = $weather.relativeHumidity
$alt = 240

function humidityRatio(){
    param($p_w, $p)
    return (0.621945*$p_w)/($p-$p_w)
}


function findpressure(){
    param($altitude)
    return 101325*[System.Math]::pow(1 - 2.25577e-5*$altitude,5.2559);
}

function saturationPressure(){
param($t)
    $c1 = -5.6745359e3;
    $c2 = 6.3925247e0;
    $c3 = -9.677843e-3;
    $c4 = 6.2215701e-7;
    $c5 = 2.0747825e-9;
    $c6 = -9.484024e-13;
    $c7 = 4.1635019e0;

    $c8=-5.8002206e3;
    $c9=1.3914993;
    $c10=-4.8640239e-2;
    $c11=4.1764768e-5;
    $c12=-1.4452093e-8;
    $c13=6.5459673;
    $pressure = 0;
    if($t -gt 0){
        $t=$t+273.15;
        $pressure=[system.math]::exp($c8/$t+$c9+$c10*$t+$c11*$t*$t+$c12*$t*$t*$t+$c13*[system.Math]::log($t));
      }
    else
      { 
        $t=$t+273.15;
        $pressure=[system.math]::exp($c1/$t+$c2+$c3*$t+$c4*$t*$t+$c5*$t*$t*$t+$c6*$t*$t*$t*$t+$c7*[system.Math]::log($t)); 
      }    
    return($pressure);
    
}

function calcwetbulb(){
    param($t,$p,$w)
    $t_wb=$t;
    $count=1;
    $error=1.0;
    while (($count -lt 10000) -and ($error -gt 0.001))
     {
       $p_ws_wb=saturationpressure $t_wb;
       $ws_wb=humidityratio $p_ws_wb $p;
       $test=(2501*($ws_wb-$w)-$t*(1.006+1.86*$w))/(2.326*$ws_wb-1.006-4.186*$w);
       $error = $t_wb-$test;
       $t_wb = $t_wb - $error/100;
       $count = $count+1;
      }
    return ($t_wb);
}

$p = findpressure $alt
$p_ws=saturationpressure $t;
$p_w=$p_ws*$rh/100.0;
$w = humidityratio $p_w $p;
calcwetbulb $t $p $w
