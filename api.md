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
			"resource_set_id": "empty-rs-api-01_id"
		}
	],
	"policy_type": "CSI",
	"key_rules": [{
		"key_id": "cte-key-api-001"
	}]
}
```

```
{
    "description":  "Created via API",
    "name":  "cte-csi-sg-api",
    "k8s_namespace":  "cte-api",
    "k8s_storage_class":  "cte-csi-sc-api",
    "client_profile":  "DefaultClientProfile"
}
```

```
{
	"policy_list": [
		"cte-csi-policy-api-001-id"
	]
}
```

```
{
	"max_clients": 5,
	"ca_id": "ca-id",
	"name_prefix": "cte-token-api-001",
	"cert_duration": 730,
	"lifetime": ""
}
```
