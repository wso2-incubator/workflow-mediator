
import ballerina/http;
import ballerina/io;

//Camunda Records

type CamundaInputTypeVariable record {
    string name;
    string value;
};

type CamundaOutputTypeVariable record {
    string value;
};

type CamundaOutputType record {
    map<CamundaOutputTypeVariable> variables;
};


type CamundaConfig record {|
string engine_type;
string engine_url;

|};

configurable CamundaConfig workflow_engine_config = ?;


distinct service class CamundaWorkflowEngine {

    *WorkflowEngine;

    private string engineURL;


    function init() {
        self.engineURL = workflow_engine_config.engine_url;

    }

    # Description
    #
    # + workflowRequestType - Parameter Description
    # + return - Return Value Description
    public function workflowInitializer(WorkflowRequest workflowRequestType) returns error?  {
       
        string workflowDefinitionID = workflowRequestType.workflow_id;
        http:Client clientCamunda = check new (self.engineURL);
        CamundaOutputType camundaPayload = check self.CamundaConvert(workflowRequestType);
        io:println("Camunda Payload: ", camundaPayload);
        http:Response _ = check clientCamunda->post("/" + workflowDefinitionID + "/start", camundaPayload, {});
    

    }
    # Description
    # the requrst json payload converts the data format whih except from camunda engine
    # + workflowRequestType - json data format. 
    # + return - requset type json data format.
    #
    private isolated function CamundaConvert(WorkflowRequest workflowRequestType) returns error|CamundaOutputType {

        string camundaWorkflowID = workflowRequestType.request_id;

        CamundaOutputType outputType = {
            variables: {}
        };
        outputType.variables["requestID"] = {
            value: camundaWorkflowID
        };
        foreach CamundaInputTypeVariable inputVariable in workflowRequestType.workflow_parameters {
          
                outputType.variables[inputVariable.name] = {
                    value: inputVariable.value
             
            };

        }
        return outputType;
    }
  
}
