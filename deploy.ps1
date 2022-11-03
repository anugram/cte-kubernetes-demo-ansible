$username = "admin"
$password = ""
$kms = "1.1.1.1"
$counter = "003"

#Param($cleanup)
$cleanup = 'y'
#Invoke API for token generation
Write-Output "Getting token from Thales CipherTrust Manager..."
$Url = "https://$kms/api/v1/auth/tokens"
$Body = @{
    grant_type = "password"
    username = $username
    password = $password
}
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $Url -Body $body
$jwt = $response.jwt

#Generic header for next set of API calls
$headers = @{    
    Authorization="Bearer $jwt"
}

Write-Output "-------------------------------"
Write-Output "Cleaning up demo system first"
Write-Output "-------------------------------"

Write-Output "Removing any, if exists, CSI Policy, Keys, Kubernetes Security Group, etc. with same names"

if (('y' -eq $cleanup.ToLower()) -or ('yes' -eq $cleanup.ToLower())) {
    $url = "https://$kms/api/v1/transparent-encryption/csigroups"
    $response = Invoke-RestMethod -SkipCertificateCheck -Method 'Get' -Uri $url -Headers $headers
    $storageGroups = $response.resources
	$sgToDelete = $storageGroups | where-object { $_.name -match "cte-csi-sg" }
	$sgId = $sgToDelete.id
	if($null -ne $sgId) {
		try {
			$url = "https://$kms/api/v1/transparent-encryption/csigroups/$sgId"
			$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Delete' -Uri $url -Headers $headers
		} catch {
			Write-Output "just proceeding anyways...."
		}
	}
	
	$url = "https://$kms/api/v1/transparent-encryption/policies"
    $response = Invoke-RestMethod -SkipCertificateCheck -Method 'Get' -Uri $url -Headers $headers
    $profiles = $response.resources
	$profileToDelete = $profiles | where-object { $_.name -match "cte-csi-policy-$counter" }
	$profileId = $profileToDelete.id
	if($null -ne $profileId) {
		$url = "https://$kms/api/v1/transparent-encryption/policies/$profileId"
		$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Delete' -Uri $url -Headers $headers
	}
	
	$url = "https://$kms/api/v1/transparent-encryption/resourcesets"
    $response = Invoke-RestMethod -SkipCertificateCheck -Method 'Get' -Uri $url -Headers $headers
    $resourcesets = $response.resources
	$rsToDelete = $resourcesets | where-object { $_.name -match "tmp-data" }
	$rsId = $rsToDelete.id
	if($null -ne $rsId) {
		$url = "https://$kms/api/v1/transparent-encryption/resourcesets/$rsId"
		$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Delete' -Uri $url -Headers $headers
	}
	
	
	$url = "https://$kms/api/v1/vault/keys2"
    $response = Invoke-RestMethod -SkipCertificateCheck -Method 'Get' -Uri $url -Headers $headers
    $keys = $response.resources
	$keyToDelete = $keys | where-object { $_.name -match "cte-key-$counter" }
	$keyId = $keyToDelete.id
	if($null -ne $keyId) {
		try {
			$url = "https://$kms/api/v1/vault/keys2/$keyId"
			$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Delete' -Uri $url -Headers $headers
		} catch {
			Write-Output "just proceeding anyways...."
		}
	}	
	$xtsKeyToDelete = $keys | where-object { $_.name -match "cte-key-$counter_xts" }
	$xtsKeyId = $xtsKeyToDelete.id
	if($null -ne $xtsKeyId) {
		try {
			$url = "https://$kms/api/v1/vault/keys2/$xtsKeyId"
			$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Delete' -Uri $url -Headers $headers
		} catch {
			Write-Output "just proceeding anyways...."
		}
	}
}
#exit

Write-Output "-----------------------------------------------------------------"
Write-Output "Next few steps will create boilerplate config on your CM instance"
Write-Output "-----------------------------------------------------------------"

#Fetching local root CA ID
$url = "https://$kms/api/v1/ca/local-cas?subject=/C=US/ST=TX/L=Austin/O=Thales/CN=CipherTrust Root CA"
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Get' -Uri $url -Headers $headers -ContentType 'application/json'
$caID = $response.resources[0].uri

#Fetching logged in user ID
$url = "https://$kms/api/v1/auth/self/user/"
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Get' -Uri $url -Headers $headers -ContentType 'application/json'
$userID = $response.user_id

#Create Key for CSI Policy
Write-Output "Creating key for CSI policy..."
$url = "https://$kms/api/v1/vault/keys2/"
$body = @{
    'name' = "cte-key-$counter"
	'algorithm' = "aes"
	'size' = 256
	'undeletable' = $false
	'unexportable' = $false
	'meta' = @{
	    'ownerId' = $userID
		'permissions' = @{
		    'DecryptWithKey' = @('CTE Clients')
			'EncryptWithKey' = @('CTE Clients')
			'ExportKey' = @('CTE Clients')
			'MACVerifyWithKey' = @('CTE Clients')
			'MACWithKey' = @('CTE Clients')
			'ReadKey' = @('CTE Clients')
			'SignVerifyWithKey' = @('CTE Clients')
			'SignWithKey' = @('CTE Clients')
			'UseKey' = @('CTE Clients')
		}
		'cte' = @{
		    'persistent_on_client' = $true
			'encryption_mode' = "CBC_CS1"
			'cte_versioned' = $false
		}
	}
	'xts' = $true
}
$jsonBody = $body | ConvertTo-Json -Depth 5
try {
	$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $url -Body $jsonBody -Headers $headers -ContentType 'application/json'
	$keyId = $response.id
} catch {
    Write-Output "just proceeding anyways...."
}

#Create Resource Set
Write-Output "Creating Resource Set..."
$url = "https://$kms/api/v1/transparent-encryption/resourcesets/"
$body = @{
    'name' = "tmp-data"
	'description' = "Created via Powershell"
	'type' = "Directory"
	'resources' = @(
	    @{
		    'directory' = "/mnt/azure"
			'file' = "*"
			'include_subfolders' = $true
		}
	)
}
$jsonBody = $body | ConvertTo-Json -Depth 5
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $url -Body $jsonBody -Headers $headers -ContentType 'application/json'
$rsId = $response.id

#Create CSI Policy
Write-Output "Creating Container Storage Interface Policy..."
$url = "https://$kms/api/v1/transparent-encryption/policies/"
$body = @{
  'name' = "cte-csi-policy-$counter"
  'policy_type' = "CSI"
  'metadata' = @{
      'restrict_update' = $false
  }
  'key_rules' = @(
      @{
      'key_id' = "cte-key-$counter"
      }
  )
  'never_deny' = $false
  'security_rules' = @(
    @{
      'process_set_id' = ""
      'resource_set_id' = ""
      'user_set_id' = ""
      'exclude_user_set' = $false
      'exclude_resource_set' = $false
      'exclude_process_set' = $false
      'action' = "all_ops"
      'effect' = "permit,audit,applykey"
    },
    @{
      'process_set_id' = ""
      'resource_set_id' = $rsId
      'user_set_id' = ""
      'exclude_user_set' = $false
      'exclude_resource_set' = $false
      'exclude_process_set' = $false
      'action' = "all_ops"
      'effect' = "permit,audit,applykey"
    }
  )
}
$jsonBody = $body | ConvertTo-Json -Depth 5
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $url -Body $jsonBody -Headers $headers -ContentType 'application/json'
$policyId = $response.id

#Create Kubernetes Storage Group
Write-Output "Creating Kubernetes Storage Group..."
$url = "https://$kms/api/v1/transparent-encryption/csigroups/"
$body = @{
  'name' = "cte-csi-sg"
  'k8s_namespace' = "cte"
  'k8s_storage_class' = "cte-csi-sc"
  'description' = "Created via Powershell"
  'client_profile' = "DefaultClientProfile"
}
$jsonBody = $body | ConvertTo-Json -Depth 5
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $url -Body $jsonBody -Headers $headers -ContentType 'application/json'
$sgId = $response.id

#Create Kubernetes Storage Group GuardPoints
Write-Output "Creating Kubernetes Storage Group GuardPoints..."
$url = "https://$kms/api/v1/transparent-encryption/csigroups/$sgId/guardpoints/"
$body = @{
  'policy_list' = @($policyId)
}
$jsonBody = $body | ConvertTo-Json -Depth 5
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $url -Body $jsonBody -Headers $headers -ContentType 'application/json'

#Create Registration Token
Write-Output "Creating Registration Token..."
$url = "https://$kms/api/v1/client-management/regtokens/"
$body = @{
  'name_prefix' = "cte-token-$counter"
  'lifetime' = ""
  'cert_duration' = 730
  'ca_id' = $caID
  'max_clients' = 5
}
$jsonBody = $body | ConvertTo-Json -Depth 5
$response = Invoke-RestMethod -SkipCertificateCheck -Method 'Post' -Uri $url -Body $jsonBody -Headers $headers -ContentType 'application/json'
$regToken = $response.token
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($regToken)
$regTokenEnc =[Convert]::ToBase64String($Bytes)

cp -rf ./templates/azure-file/*.* ./example/
sed -i "s/CM_TOKEN_ENC/$regTokenEnc/g" ./example/cmtoken.yaml
sed -i "s/VAR_NS/cte/g" ./example/cmtoken.yaml
sed -i "s/CM_STORAGE_CLASS/cte-csi-sc/g" ./example/local-pvc.yaml
sed -i "s/VAR_NS/cte/g" ./example/local-pvc.yaml
sed -i "s/CM_STORAGE_CLASS/cte-csi-sc/g" ./example/storage.yaml
sed -i "s/CM_STORAGE_GROUP/cte-csi-sg/g" ./example/storage.yaml
sed -i "s/CM_IP/$kms/g" ./example/storage.yaml
sed -i "s/VAR_NS/cte/g" ./example/storage.yaml
sed -i "s/CM_CTE_POLICY/cte-csi-policy-$counter/g" ./example/pvc.yaml
sed -i "s/CM_STORAGE_CLASS/cte-csi-sc/g" ./example/pvc.yaml
sed -i "s/VAR_NS/cte/g" ./example/pvc.yaml
sed -i "s/VAR_NS/cte/g" ./example/createNamespace.yaml
sed -i "s/VAR_NS/cte/g" ./example/demo.yaml
sed -i "s/VAR_NS/cte/g" ./example/createStorageClass.yaml

cd ./ciphertrust-transparent-encryption-kubernetes && ./deploy.sh
cd ..
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl apply -f ./example/createNamespace.yaml
kubectl apply -f ./example/createStorageClass.yaml
kubectl apply -f ./example/cmtoken.yaml
kubectl apply -f ./example/storage.yaml
kubectl apply -f ./example/local-pvc.yaml
kubectl apply -f ./example/pvc.yaml
kubectl apply -f ./example/demo.yaml
