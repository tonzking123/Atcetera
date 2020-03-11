###########################
# Enable HTTPS
###########################

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

###########################
# Get Token
###########################
#+-------------------------------------------+
#|-------------------------------------------|
#||                                         ||
#||                                         ||
#||             information here            ||
#||                                         ||
#||                                         ||
#|-------------------------------------------|
#+-------------------------------------------+



$array = "10.201.10.170"
$username = ""
$password = ""
$LineToken = ""

#---------------------------------------

$data = @{
    username = $username
    password = $password
}

$body = convertto-json (@{ data = $data })

$uri = "https://" + $array + ":5392/v1/tokens"
$token = Invoke-RestMethod -Uri $uri -Method Post -Body $body
$token = $token.data.session_token

###########################
# Print Results
###########################

$token

#Expected output is a session token, similar to :7f39888e5b9ba094f4f3103fb3f923b2

###########################
# Get Volume List
###########################

$header = @{ "X-Auth-Token" = $token }
$uri = "https://" + $array + ":5392/v1/volumes"
$volume_list = Invoke-RestMethod -Uri $uri -Method Get -Header $header
$vol_array = @();

foreach ($volume_id in $volume_list.data.id){

	
	$uri = "https://" + $array + ":5392/v1/volumes/" + $volume_id
	$volume = Invoke-RestMethod -Uri $uri -Method Get -Header $header
	#write-host $volume.data.name :     $volume.data.avg_stats_last_5mins.read_throughput
	$vol_array += $volume.data
    $userObj = New-Object PSObject
    $userObj | Add-Member NoteProperty -Name "Volume Name" -Value $volume.data.name
    $userObj | Add-Member NoteProperty -Name "Read IOP" -Value $volume.data.avg_stats_last_5mins.read_iops
    $userObj | Add-Member NoteProperty -Name "Write IOP" -Value $volume.data.avg_stats_last_5mins.write_iops
    $userObj | Add-Member NoteProperty -Name "Perf_Policy" -Value $volume.data.perfpolicy_name

    #Write-Output $userObj
    $export = $userobj | Select-Object "Volume Name","Read IOP","Write IOP","Perf_Policy" 

    #################
    #Write Volume Name to check
    #################

    #$export
    
    foreach($VolName in $export | Where-Object{$export.Perf_Policy -eq "Exchange 2010 data store"}){
    
        if($VolName.'Read IOP' -gt 800){

            #to check if volume we needed is matching with perf policy
            #Write-Host  $VolName.'Volume Name' + "         " + $VolName.Perf_Policy "    " + $VolName.'Read IOP'
            curl -Uri 'https://notify-api.line.me/api/notify' -Method Post -Headers @{Authorization = 'Bearer $LineToken'} -Body @{message = $export.'Volume Name' + " IOP is Higher than 800"}


            }
    }
    
	
}



Write-Host ----------------------------------------------------------

#Write-Output $alert


###########################
# Print Results
###########################



#$vol_array | sort-object name -descending | Select name,avg_stats_last_5mins
#$haha = $vol_array | sort-object name | Select name,avg_stats_last_5mins 




