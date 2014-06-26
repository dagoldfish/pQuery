<#
	pQuery - powerShell Web automation simplified! Inspired by jQuery's ease of use
	
	Author: Gil Ferreira 
	gitHub: github.com/misterGF
	Created: 06/11/2014
	
	Import-Module pQuery
#>

#Create pQuery Variable
	$global:pQuery = New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{ Version=1.0; Description='pQuery - powerShell Web automation simplified! Inspired by jQuery''s ease of use'; validElements = ("button","div","form","input","a"); URL=$null }
	
	#Define functions
	$init = {

	<#	Starts web autiomation by creating browser object. This function will create a browser object	#>
		
		$ErrorActionPreference = "STOP"	
		
		try
		{	
			[System.Reflection.Assembly]::LoadFrom("$PSScriptRoot\SimpleBrowser.dll") | Out-Null
			$global:pQueryBrowser = New-Object SimpleBrowser.Browser $null,$null
		}
		catch
		{
			Write-Host "Unable to create browser object. Error: $_" -ForegroundColor:Red
		}
	}
	
	$end = {
		<# End pQuery browser isntance. #>		
		$pQueryBrowser.Close()		
	}
	
	$setCredentials = {
		<#
	    Pass in string with "username:password" syntax to allow for access behind website that is protected by basic authentication
		
	    C:\PS> $pQuery.setCredentials("gil:mypassword")
		#>
		param([Parameter(Mandatory=$True)][string]$creds)
	
		$basicAuth = "Authorization: Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($creds))
		$pQueryBrowser.SetHeader($basicAuth)
		
		if($?)
		{
			Write-Host "Successfully set header for basic authentication!" -ForegroundColor:Green
		}
		else
		{
			Write-Host "Unable to set header" -ForegroundColor:Red
		}
	}
	
	$navigate = {
	<#
	    Navigate to a specific URI.
		
	    C:\PS> $pQuery.navigate("http://github.com/misterGF")
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
			$nav = $pQueryBrowser.Navigate($Site)
			
			if($nav)
			{
				Write-Host "Navigated to $site" -ForegroundColor:Green
				$pQuery.Url = $pQueryBrowser.Url.ToString()
			}
			else
			{
				Write-Host "Unable to navigate to $site" -ForegroundColor:Red
				Write-host $pQueryBrowser.LastWebException.Message
			}
		}
		else
		{
			Write-Host "Browser not initalized. Try running $pQuery.init() first." -ForegroundColor:Red
		}
	}
	
	$getHTML = {
		<#
			get HTML response
		#>	
		
		$pQueryBrowser.get_CurrentHtml()					
	}
	
	$select = {
		<#
			Selecting!
				Types can be button, div, form, textField, link or radioButton.

				$pQuery.Select("button") //By Type

				$pQuery.Select("#button") //By ID

				$pQuery.Select(".button") //By Class
		#>	
	
		param([Parameter(Mandatory=$True)][string]$selector)
		
		$firstChar = $selector[0]
		
		if( (".","#") -contains $firstChar)
		{
			$selector = $selector.Substring(1)
		}
		
		switch($firstChar)
		{
			"." {				
					#Searching by Class
					foreach($type in $pQuery.validElements)
					{
						$pQueryBrowser.Find($type,[SimpleBrowser.FindBy]::Class,$selector)																	
					}				
				}
				
			"#" {
					#Searching by ID										
					foreach($type in $pQuery.validElements)
					{
						$pQueryBrowser.Find($type,[SimpleBrowser.FindBy]::Id,$selector)												
					}
				}
				
			default 
				{
					#Looking for an element
					if($pQuery.validElements -contains $selector)
					{
						$pQueryBrowser.FindAll($selector)								
					}
					else
					{ 
						$invalid = "$selector is an invalid type. Type one of these {0}" -f ($pQuery.validElements -join ",")
						Write-Host $invalid -ForegroundColor:Red
					}													
				}		
		}	
	}
	
	$getText = {
		<#
			Getting Text!

				$pQuery.getText("button") //By Type

				$pQuery.getText("#button") //By ID

				$pQuery.getText(".button") //By Class
		#>
		param([Parameter(Mandatory=$True)][string]$selector)
		
		$firstChar = $selector[0]
		
		if( (".","#") -contains $firstChar)
		{
			$selector = $selector.Substring(1)
		}
		
		$specialOutput = New-Object -TypeName 'System.Management.Automation.PSObject' -Property @{ Value=$null; Xelement=$null}
		
		switch($firstChar)
		{
			"." {
					#Searching by Class
					foreach($type in $pQuery.validElements)
					{
						$element = $pQueryBrowser.Find($type,[SimpleBrowser.FindBy]::Class,$selector)
						
						if($element.value)
						{
							$element | Select Value,Xelement | FL
						}
						else
						{
							$value = $element.Xelement.Value 
							
							$specialOutput.Value = $value
							$specialOutput.Xelement = $element.Xelement
								
							if($specialOutput.Xelement)
							{
								$specialOutput | FL
							}																			 
						}
					}									
				}
				
			"#" {
					#Searching by ID					
					$element = $pQueryBrowser.Find($selector)
						
					if($element.value)
					{
						$element | Select Value,Xelement | FL
					}
					else
					{
						$value = $element.Xelement.Value 
							
						$specialOutput.Value = $value
						$specialOutput.Xelement = $element.Xelement
								
						if($specialOutput.Xelement)
						{
							$specialOutput | FL
						}																			 
					}
				}
				
			default 
				{
					#Looking for an element
					if($pQuery.validElements -contains $selector)
					{
						$pQueryBrowser.FindAll($selector) | FL											
					}
					else
					{ 
						$invalid = "$selector is an invalid type. Type one of these {0}" -f ($pQuery.validElements -join ",")
						Write-Host $invalid -ForegroundColor:Red
					}
													
				}		
		}		
	
	}
	
	$setText = {
		<#
			Setting Text!
			
				$pQuery.setText("button","My Modified Text") //By Type

				$pQuery.setText("#button","My Modified Text") //By ID

				$pQuery.setText(".button","My Modified Text") //By Class
		#>
		param([Parameter(Mandatory=$True)][string]$selector,[Parameter(Mandatory=$True)][string]$text )
		
		$ErrorActionPreference = "STOP"
		
		$firstChar = $selector[0]
		
		if( (".","#") -contains $firstChar)
		{
			$selector = $selector.Substring(1)
		}
		
		switch($firstChar)
		{
			"." {
					#Searching by Class
					foreach($type in $pQuery.validElements)
					{
						$element = $pQueryBrowser.Find($type,[SimpleBrowser.FindBy]::Class,$selector)
						
						if($element.exists)
						{
							try
							{
								$element.value = $text
								Write-Host "Set value of $text on $selector!" -ForegroundColor:green	
							}
							catch
							{
								Write-Host "Unable to set value of $text on $selector." -ForegroundColor:red
							}
						}
					}									
				}
				
			"#" {
					#Searching by ID					
					$element = $pQueryBrowser.Find($selector)
						
					if($element.exists)
					{
						try
						{
							$element.value = $text
							Write-Host "Set value of $text on $selector!" -ForegroundColor:green	
						}
						catch
						{
							Write-Host "Unable to set value of $text on $selector." -ForegroundColor:Red
						}
					}
				}		
			default 
				{
					#Looking for an element
					if($pQuery.validElements -contains $selector)
					{
						$element = $pQueryBrowser.FindAll($selector)
						
						if($element.exists)
						{
							$element.value = $text
							Write-Host "Set value of $text on $selector!" -ForegroundColor:green	
						}						
					}
					else
					{ 
						$invalid = "$selector is an invalid type. Type one of these {0}" -f ($pQuery.validElements -join ",")
						Write-Host $invalid -ForegroundColor:Red
					}
													
				}	
		}		
	}
	
	$click = {
		<#
			Clicking!
			
				$pQuery.click("#button") //By ID

				$pQuery.click(".button") //By Class
		#>	
		param([Parameter(Mandatory=$True)][string]$selector)
		
		$ErrorActionPreference = "STOP"
		
		$firstChar = $selector[0]
		
		if( (".","#") -contains $firstChar)
		{
			$selector = $selector.Substring(1)
		}
		
		switch($firstChar)
		{
			"." {
					#Searching by Class
					foreach($type in $pQuery.validElements)
					{
						$element = $pQueryBrowser.Find($type,[SimpleBrowser.FindBy]::Class,$selector)
						
						if($element.exists)
						{
							try
							{
								$click = $element.click()
								
								if($click -eq "SucceededNavigationComplete")
								{
									Write-Host "Successfully clicked $selector!" -ForegroundColor:green
								}
									
							}
							catch
							{
								Write-Host "Unable to click on $selector." -ForegroundColor:red
							}
						}
					}									
				}
				
			"#" {
					#Searching by ID					
					$element = $pQueryBrowser.Find($selector)
						
					if($element.exists)
						{
							try
							{
								$click = $element.click()
								
								if($click -eq "SucceededNavigationComplete")
								{
									Write-Host "Successfully clicked $selector!" -ForegroundColor:green
								}
									
							}
							catch
							{
								Write-Host "Unable to click on $selector." -ForegroundColor:red
							}
						}
				}		
			default 
				{
					Write-Host "Clicking only supports classes and id selectors" -ForegroundColor:Red												
				}	
		}
		
		#Update URL
		$pQuery.Url = $pQueryBrowser.Url.ToString()
	}
	
	$submit = {
		<#
			Submit!
			
				$pQuery.submit("#button") //By ID

				$pQuery.submit(".button") //By Class
		#>		
	
	}
		
	#Add Functions
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Init' -Value $init
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'End' -Value $end
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'setCredentials' -Value $setCredentials
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Navigate' -Value $navigate
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Select' -Value $select
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'getHTML' -Value $getHTML
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'getText' -Value $getText
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'setText' -Value $setText
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Click' -Value $click
	Add-Member -InputObject $pQuery -MemberType ScriptMethod -Name 'Submit' -Value $submit