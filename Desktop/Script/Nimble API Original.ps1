###########################
# Enable HTTPS
###########################

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

###########################
# Get Token
###########################

$array = "10.201.10.170"
$username = ""
$password = "#1"

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

#$token

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
	#write-host $volume.data.name :     $volume.data.id
	$vol_array += $volume.data
	
}


###########################
# Print Results
###########################



#$vol_array | sort-object name -descending | Select name,avg_stats_last_5mins
$vol_array | sort-object name 