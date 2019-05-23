$ext = [System.IO.Path]::GetExtension("$env:CONFIG_NAME")
if ($ext -eq ".yml") {
    $var = Select-String -Path $env:CONFIG_NAME -Pattern "CVAR_" | %{$_ -replace " ",""} | foreach { 
        $_.ToString().split(":")[4] 
    }
} elseif ($ext -eq ".properties") {
    $var = Select-String -Path $env:CONFIG_NAME -Pattern "CVAR_" | %{$_ -replace " ",""} | foreach { 
        $_.ToString().split("=")[1] 
    }
    else {
    echo "";
    echo "Extensao nao encontrada.";
    echo "";
    exit 1
    }
}
foreach($s in $var) {
    $v1 = $s.replace("$", "")
    $v = "$" + "env:" + $v1
    $ss = Invoke-Expression $v
    if (!$ss) {
        echo "A senha da variavel $s nao existe.";
        $v2 = "FALSE"
    } else {
        #echo $s = $ss;
        (Get-Content $env:CONFIG_NAME).replace("$s", "$ss") | Set-Content $env:CONFIG_NAME
    }
}
if ($v2 -eq "FALSE") {
    exit 1
}
