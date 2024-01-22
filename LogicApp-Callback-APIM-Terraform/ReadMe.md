

terraform init
terraform validate
terraform refresh -var-file=Local.tfvars
terraform plan -var-file=Local.tfvars
terraform apply -var-file="Local.tfvars"


# Set policy to call backend

## Logic App Consumption

### Option 1 - Using Backend

```
<set-backend-service backend-id="${azurerm_api_management_backend.workflow_backend.name}" />
<rewrite-uri template="/" copy-unmatched-params="true" />
        
```

### Option 2 - Using inline policy

```
<set-backend-service base-url="${jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).basePath}" />
        <rewrite-uri template="/" copy-unmatched-params="true" />  
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <set-query-parameter name="api-version" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.api-version}</value>
        </set-query-parameter>
        <set-query-parameter name="sig" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.sig}</value>
        </set-query-parameter>
        <set-query-parameter name="sp" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.sp}</value>
        </set-query-parameter>
        <set-query-parameter name="sv" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.logicapp_callbackurl.output).queries.sv}</value>
        </set-query-parameter>
```
## Logic App Standard

### Option 1 - Using Backend

```
<set-backend-service backend-id="${azurerm_api_management_backend.workflow_backend.name}" />
<rewrite-uri template="/" copy-unmatched-params="true" />
        
```

### Option 2 - Using inline policy

```

        <set-backend-service base-url="${jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).basePath}" />
        <rewrite-uri template="/" copy-unmatched-params="true" />  
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <set-query-parameter name="api-version" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.api-version}</value>
        </set-query-parameter>
        <set-query-parameter name="sig" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.sig}</value>
        </set-query-parameter>
        <set-query-parameter name="sp" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.sp}</value>
        </set-query-parameter>
        <set-query-parameter name="sv" exists-action="override">
            <value>${jsondecode(data.azapi_resource_action.workflow_trigger_callback.output).queries.sv}</value>
        </set-query-parameter>

```
