<#
	This will search google for the term powershell and print out
	links that contain the keyword powershell

#>
$term = "powershell"

$pQuery.Init()
$pQuery.Navigate("http://google.com")
$pQuery.setText(".lst",$term) #Used $pQuery.select("input") to find the class name
$pQuery.Click(".lsb") #Used $pquery.select("input") to find class name as well.
$pQuery.Select("a") | %{  if($_.value -match $term){ Write-Host $_.value " `r`r " } }