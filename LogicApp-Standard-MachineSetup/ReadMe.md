
This page here covers how to setup a machine ready for developing logic app standard.  Note this covers the bare minimum things but also some of the common
development tools that we use in developing integration solutions with logic apps.




# Microsoft Docs

https://learn.microsoft.com/en-us/azure/logic-apps/create-single-tenant-workflows-visual-studio-code#tools


# Install Chocolatey

We will use chocolatey to install some of the widgets needed
https://chocolatey.org/install

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

# Install Node.js and NPM

We need node for logic app standard and also npm to install some of the things we need.

Microsoft wants us to use 12.x.x or 14.x.x 
We will install version 14.21.2

Get it from this link (NOTE: Get the x64 msi = node-v14.21.2-x64.msi)
https://nodejs.org/download/release/v14.21.2/

In the msi also tick the box to install supported tools which will also install chocolatey

# Check Versions of NPM and Node

```
node -v
npm -v
```

# NPM installed but not latest

```
npm install -g npm
```

# Install Functions Core Tools with NPM

```
npm i -g azure-functions-core-tools@4 --unsafe-perm true
```

# Install VS Code with Chocolatey

```
choco install vscode
```

# Install VS Code Extensions

Install C# for VS Code
```
code --install-extension ms-dotnettools.csharp
```

Install Azure Account for VS Code
```
code --install-extension ms-vscode.azure-account
```

Cuecumber - For specflow:
```
code --install-extension alexkrechik.cucumberautocomplete
```

Azurite - For storage emulator
```
code --install-extension Azurite.azurite
```

Test Explorer for dotnet
```
code --install-extension formulahendry.dotnet-test-explorer
```

Install Logic App Extension

```
code --install-extension ms-azuretools.vscode-azurelogicapps
```

Install Terraform and Azure Terraform

```
code --install-extension HashiCorp.terraform
code --install-extension ms-azuretools.vscode-azureterraform	
```

NPM Support

```
code --install-extension eg2.vscode-npm-script
```

Liquid

```
code --install-extension sissel.shopify-liquid
```

Rest Client

```
code --install-extension humao.rest-client
```

# Important

Turn on vs code auto save

File -> Auto Save


# Nice to Have

The below are some useful tools / themes

```
code --install-extension vscode-icons-team.vscode-icons
```

https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons

To set the theme: File > Preferences > File Icon Theme > VSCode Icons.


The other common one is:
```
code --install-extension miguelsolorio.fluent-icons
```
