## Function App host storage requirements

When Azure Functions uses identity-based host storage (`AzureWebJobsStorage__credential=managedidentity`), the Function App's system-assigned managed identity must be granted storage data-plane roles on the storage account.

Minimum required role assignments:
- Storage Blob Data Owner
- Storage Queue Data Contributor
- Storage Table Data Contributor

If these roles are omitted, the Function host may deploy successfully but fail at runtime when initializing host storage artifacts.