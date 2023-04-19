1. Create Key for CTE-K8s

- Method = POST
- URL = https://$CM_IP_FQDN/api/v1/vault/keys2/
- Payload 

```
{
	"xts": true,
	"name": "cte-key-api-001",
	"unexportable": false,
	"meta": {
		"ownerId": "abc",
		"cte": {
			"cte_versioned": false,
			"persistent_on_client": true,
			"encryption_mode": "CBC_CS1"
		},
		"permissions": {
			"SignVerifyWithKey": [
				"CTE Clients"
			],
			"EncryptWithKey": [
				"CTE Clients"
			],
			"ReadKey": [
				"CTE Clients"
			],
			"DecryptWithKey": [
				"CTE Clients"
			],
			"ExportKey": [
				"CTE Clients"
			],
			"MACVerifyWithKey": [
				"CTE Clients"
			],
			"SignWithKey": [
				"CTE Clients"
			],
			"UseKey": [
				"CTE Clients"
			],
			"MACWithKey": [
				"CTE Clients"
			]
		}
	},
	"undeletable": false,
	"algorithm": "aes",
	"size": 256
}
```

2. Create a resource set to associate with the Guard Point. For this example this resource set applies to the root directory and all its sub folders.
- Method = POST
- URL = https://$CM_IP_FQDN/api/v1/transparent-encryption/resourcesets/
- Payload
```
{
	"description": "Created via API",
	"name": "empty-rs-01",
	"type": "Directory",
	"resources": [{
		"include_subfolders": true,
		"directory": "/",
		"file": "*"
	}]
}
```
Save the resource set ID from the response as "empty-rs-api-01-id"

3. Create a CTE CSI Policy to assoiate with the resource set we created above.
- Method = POST
- URL = https://$CM_IP_FQDN/api/v1/transparent-encryption/policies/
- Payload
```
{
	"name": "cte-csi-policy-api-001",
	"never_deny": false,
	"metadata": {
		"restrict_update": false
	},
	"security_rules": [{
			"exclude_resource_set": false,
			"action": "all_ops",
			"process_set_id": "",
			"effect": "permit,audit,applykey",
			"exclude_user_set": false,
			"exclude_process_set": false,
			"user_set_id": "",
			"resource_set_id": "empty-rs-api-01-id"
		}
	],
	"policy_type": "CSI",
	"key_rules": [{
		"key_id": "cte-key-api-001"
	}]
}
```
Save the ID from the response as "cte-csi-policy-api-001-id"

4. Now create the Kubernetes Storage Group with the Storage Class.
- Method = POST
- URL = https://$CM_IP_FQDN/api/v1/transparent-encryption/csigroups/
- Payload
```
{
    "description":  "Created via API",
    "name":  "cte-csi-sg-api",
    "k8s_namespace":  "cte-api",
    "k8s_storage_class":  "cte-csi-sc-api",
    "client_profile":  "DefaultClientProfile"
}
```
Save the ID from the response as "sgId"

5. Finally associate the CSI Policy with the above created Storage Group
- Method = POST
- URL = https://$CM_IP_FQDN/api/v1/transparent-encryption/csigroups/$sgId/guardpoints/
- Payload
```
{
	"policy_list": [
		"cte-csi-policy-api-001-id"
	]
}
```

6. Last step, get the Registration Token
- Method = POST
- URL = https://$CM_IP_FQDN/api/v1/client-management/regtokens/
- Payload
```
{
	"max_clients": 5,
	"ca_id": "ca-uri",
	"name_prefix": "cte-token-api-001",
	"cert_duration": 730,
	"lifetime": ""
}
```
