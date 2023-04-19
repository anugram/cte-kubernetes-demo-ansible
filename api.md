```
{
	"xts": true,
	"name": "cte-key-001",
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
