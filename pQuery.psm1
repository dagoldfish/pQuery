<#
	pQuery - powerShell Web automation simplified! Inspired by jQuery's ease of use
	
	Author: Gil Ferreira 
	gitHub: github.com/misterGF
	Created: 06/11/2014
	
	Import-Module C:\Users\gil.ferreira\Dropbox\Work\Programming\PowerShell\Migration\pQuery
#>

#Create pQuery Variable
	$global:pQuery = New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{ Version=1.0; Description='pQuery - powerShell Web automation simplified! Inspired by jQuery''s ease of use' }
	
	#Define functions
	$init = {

	<#
	.SYNOPSIS
	    Starts web autiomation by creating browser object.
	.DESCRIPTION
		This function will create a browser object and is called automatically by the module
	.EXAMPLE
	    C:\PS> N/A
	.NOTES
	    Part of pQuery module
	#>
		
		$ErrorActionPreference = "STOP"	
		
		try
		{				
			$global:pQueryBrowser = New-Object WatiN.Core.IE
			$global:pQueryBrowser.visible = $false
		}
		catch
		{
			Write-Host "Unable to create browser object. Error: $_" -ForegroundColor:Red
		}
	}	
	
	$navigate = {
	<#
	.SYNOPSIS
	    Navigate to a specific URI.
	.DESCRIPTION
		This function  will navigate to the site specified in the Site parameter. Specify 
	.EXAMPLE
	    C:\PS> $pQuery.navigate("http://github.com/misterGF")
	.NOTES
	    Part of pQuery module
	#>
		param([Parameter(Mandatory=$True)][URI]$Site)
			
		#Make sure site is URI
		if(!$Site.IsAbsoluteUri)
		{	
			Write-Host "$site is not a valid URI. Make sure to include the http:// part!" -ForegroundColor:Red
			return
		}	
		
		#Make sure browser was initialized
		if($pQueryBrowser)
		{
			$pQueryBrowser.visible = $true
			$pQueryBrowser.GoTo($Site)
		}
		else
		{
			Write-Host "Browser not initalized. Try running $pQuery.init() first." -ForegroundColor:Red
		}
	}
	
	#Add functions
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Init' -Value $init
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Navigate' -Value $navigate

	#Init Module
	$pQuery.init()



function Get-WebElement
{
<#
.SYNOPSIS
    Start web automation.
.DESCRIPTION
	This cmdlet will create a browser object and navigate to the site that you want to automate.
	Pass in the optional visible switch if you want to see the browser.
.EXAMPLE
    C:\PS> Start-WebAutomation -site "google.com" -visible
.NOTES
    Part of pQuery module
#>

}

function Get-WebElementText
{


}

function Set-WebElementText
{


}

function Test-WebElementClass
{

}

function Invoke-WebButtonClick
{


}

function Invoke-WebFormSubmit
{


}
