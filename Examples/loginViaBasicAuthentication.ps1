$site = "https://protected.domain.com" #Site that is hosted behind basic authenticaiton
$userpass = "gil:password" #username:password

$pQuery.Init()
$pQuery.setCredentials($userpass)
$pQuery.Navigate($site)
$pQuery.getHTML() #Spit out the response 
