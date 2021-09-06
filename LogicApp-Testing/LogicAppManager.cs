using Microsoft.Azure.Management.Logic;
using Microsoft.Azure.Management.Logic.Models;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using Microsoft.Rest.Azure;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace AcceptanceTests.Helpers
{
    public class LogicAppManager
    {                
        public string RunId { get; set; }
        public string LogicAppName { get; set; }
        public HttpResponseMessage LogicAppTriggerResponse { get; set; }
        public string LogicAppTriggerResponseStatus { get; set; }

        public WorkflowStatus LogicAppStatus { get; set; }

        private Config _config = new Config();
        private LogicManagementClient _client;
        private List<Workflow> _workflows = new List<Workflow>();
        private List<WorkflowRunAction> _workFlowRunActions = new List<WorkflowRunAction>();

        public enum TriggerType
        {
            Http,
            Other
        }

        public static LogicAppManager CreateLogicAppManager(string logicAppName)
        {
            var logicAppManager = new LogicAppManager();
            logicAppManager.LogicAppName = logicAppName;
            logicAppManager.StartTracking();

            return logicAppManager;
        }

        /// <summary>
        /// Initializes the LogicManagementClient and assigns it to a static variable. This will be used the test framework to retrieve data using Azure Logic Apps SDK
        /// </summary>
        public void StartTracking()
        {
            ServiceClientCredentials credentials = GetAzureCredentials();
            _client = new LogicManagementClient(credentials);
            _client.SubscriptionId = Config.SubscriptionId;

            RefreshWorkflowList();
        }

        public void RefreshWorkflowList()
        {
            var response = _client.Workflows.ListByResourceGroupAsync(Config.ResourceGroupName).Result;
            foreach (var workflow in response)
                _workflows.Add(workflow);

            var nextPageLink = response.NextPageLink;
            while (nextPageLink != null)
            {
                nextPageLink = DownloadMoreWorkflows(_workflows, nextPageLink);
            }
        }

        private string DownloadMoreWorkflows(List<Workflow> workflows, string nextPageLink)
        {
            var response = _client.Workflows.ListByResourceGroupNext(nextPageLink);
            foreach (var workflow in response)
                workflows.Add(workflow);

            return response.NextPageLink;
        }

        public bool CheckIfLogicAppIsEnabled()
        {
            bool enabled = false;
                        
            foreach(var workflow in _workflows)
            {
                if (workflow.Name == LogicAppName)
                {
                    if (workflow.State.Value.ToString() == "Enabled")
                    {
                        enabled = true;
                    }
                }
            }
            
            return enabled;
        }

        public void WaitUntilLogicAppIsComplete()
        {
            WorkflowStatus? status;

            while (true)
            {
                var run = _client.WorkflowRuns.Get(Config.ResourceGroupName, LogicAppName, RunId);
                status = run.Status;
                LogicAppStatus = status.GetValueOrDefault();
                if (status == WorkflowStatus.Succeeded || status == WorkflowStatus.Failed)
                {
                    Console.WriteLine("Logic App execution for run identifier: " + RunId + " is completed");
                    break;
                }
                else
                    Thread.Sleep(50);
            }
        }

        public void StartLogicAppWithOtherTrigger(string triggerName, HttpContent content, bool waitForLogicAppToComplete = true)
        {            
            LogicAppTriggerResponseStatus = ExecuteLogicAppWithOtherTriggerType(triggerName);

            if (waitForLogicAppToComplete)
            {
                WaitUntilLogicAppIsComplete();
                DownloadWorkflowRunActions();
            }            
        }

        public bool WasLogicAppTriggerAccepted()
        {
            if (LogicAppTriggerResponseStatus == System.Net.HttpStatusCode.Accepted.ToString())
                return true;
            else
                return false;
        }

        public bool CheckLogicAppTriggerStatus(HttpStatusCode expectedStatus)
        {
            if (LogicAppTriggerResponseStatus == expectedStatus.ToString())
                return true;
            else
                return false;
        }

        public void StartLogicAppWithManualHttpTrigger(HttpContent content, bool waitForLogicAppToComplete = true)
        {
            var triggerName = "manual";
            
            var url = GetCallBackUrl(triggerName);
            var client = new HttpClient();
            var uri = new Uri(url.Value);

            LogicAppTriggerResponse = client.PostAsync(uri, content).Result;
            LogicAppTriggerResponseStatus = LogicAppTriggerResponse.StatusCode.ToString();
            RunId = LogicAppTriggerResponse.Headers.GetValues("x-ms-workflow-run-id").First();
            Console.WriteLine("The Run identifier is: " + RunId);

            if (waitForLogicAppToComplete)
            {
                WaitUntilLogicAppIsComplete();
                DownloadWorkflowRunActions();
            }            
        }

        private WorkflowTriggerCallbackUrl GetCallBackUrl(string triggerName)
        {
            var url = _client.WorkflowTriggers.ListCallbackUrl(Config.ResourceGroupName, LogicAppName, triggerName);
            return url;
        }
        
        private string ExecuteLogicAppWithOtherTriggerType(string triggerName)
        {
            var result = _client.WorkflowTriggers.RunAsync(Config.ResourceGroupName, LogicAppName, triggerName).Result;
            return result.ToString();
        }

        public void DownloadWorkflowRunActions()
        {
            _workFlowRunActions = new List<WorkflowRunAction>();
            var actions = _client.WorkflowRunActions.ListAsync(Config.ResourceGroupName, LogicAppName, RunId).Result;
            foreach (var action in actions)
                _workFlowRunActions.Add(action);

            var nextPageLink = actions.NextPageLink;
            while (nextPageLink != null)
            {
                nextPageLink = DownloadMoreWorkflowRunActions(_workFlowRunActions, nextPageLink);
            }
        }

        private string DownloadMoreWorkflowRunActions(List<WorkflowRunAction> actions, string nextPageLink)
        {
            var response = _client.WorkflowRunActions.ListNextAsync(nextPageLink).Result;
            foreach (var action in response)
                actions.Add(action);

            return response.NextPageLink;
        }

        public bool CheckLogicAppActionResult(string actionName, WorkflowStatus expectedStatus)
        {
            var result = _workFlowRunActions.FirstOrDefault(x => x.Name == actionName);
            if (result == null)
                return false;

            if (result.Status == expectedStatus)
                return true;
            else
                return false;
        }

        public bool CheckLogicAppActionSucceeded(string actionName)
        {
            var result = _workFlowRunActions.FirstOrDefault(x => x.Name == actionName);
            if (result == null)
                return false;

            if (result.Status == WorkflowStatus.Succeeded)
                return true;
            else
                return false;
        }

        /// <summary>
        /// Pass the SPN and azure subscription details and generate a OAUTH2.0 token
        /// </summary>
        /// <returns></returns>
        private static ServiceClientCredentials GetAzureCredentials()
        {
            var authContext = new AuthenticationContext(string.Format("https://login.windows.net/{0}", Config.TenantId));
            var credential = new ClientCredential(Config.WebApiApplicationId, Config.Secret);
            AuthenticationResult authResult = authContext.AcquireTokenAsync("https://management.core.windows.net/", credential).Result;
            string token = authResult.CreateAuthorizationHeader().Substring("Bearer ".Length);

            return new TokenCredentials(token);
        }
    }

    public class Config
    {
        public static string ResourceGroupName
        {
            get
            {
                return ConfigurationManager.AppSettings["logicAppManager:ResourceGroupName"];
            }
        }

        public static string SubscriptionId
        {
            get
            {
                return ConfigurationManager.AppSettings["logicAppManager:SubscriptionId"];
            }
        }

        public static string TenantId
        {
            get
            {
                return ConfigurationManager.AppSettings["logicAppManager:TenantId"];
            }
        }

        public static string WebApiApplicationId
        {
            get
            {
                return ConfigurationManager.AppSettings["logicAppManager:WebApiApplicationId"];
            }
        }

        public static string Secret
        {
            get
            {
                return ConfigurationManager.AppSettings["logicAppManager:Secret"];
            }
        }
    }
}
