This is a powershell script which can help you with testing the logic app workflow definition

You can run the powershell file locally on your machine to check before pusing any changes to your repo

You can add the below yaml to a pipeline to run the tests in a pipeline.


```

steps:
- powershell: |
   Install-Module -Name Pester -Force -SkipPublisherCheck
   
   Import-Module Pester
   
   Invoke-Pester -Script LogicApp-Governance-Tests.ps1 -Output Diagnostic
  workingDirectory: '$(System.DefaultWorkingDirectory)\$(SolutionFolder)'
  displayName: 'Pester - Governance Testing'

```

The below example shows what the tests look like when ran in a pipeline

![image](https://user-images.githubusercontent.com/11812194/163202217-38c75991-995d-4ad8-bbe1-b1eb3ebb4e8e.png)
