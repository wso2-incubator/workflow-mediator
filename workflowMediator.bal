import ballerina/http;
import ballerina/mime;

//callback record

type CallbackCamunda record {
    string requestID;
    string status;

};

type CallBackConfig record {
    string callback_url;

};
public type WorkflowRequestParamter record {
    string name;
    string value;
};

# Description
#
# + request_id - Request Idenitifier and this use for callback function  
# + workflow_id - External workflow Identifier   
# + workflow_parameters - List of varibles which recived from the request
public type WorkflowRequest record {
    string request_id;
    string workflow_id;
    WorkflowRequestParamter[] workflow_parameters;
};
type WorkflowEngineType record {
   string TYPE;
};
configurable CallBackConfig callback = ?;


service / on new http:Listener(8090) {

    resource function post .(http:Caller caller, http:Request request) returns error? {

        json requestWorkflowPayload = check request.getJsonPayload();
         WorkflowRequest workflowRequestType = check requestWorkflowPayload.cloneWithType(WorkflowRequest);
     
            WorkflowEngine workflowEngine = check createWorkflowEngine(workflow_engine_config.engine_type);
             error? workflowInitializer = workflowEngine.workflowInitializer(workflowRequestType);
             if workflowInitializer is error {

             }
             
       

    }

    resource function post Callback(http:Caller caller, http:Request request) returns error? {
        http:Client CallbackIS = check new (callback.callback_url);

        json callbackPayload = check request.getJsonPayload();
        CallbackCamunda inputRecord = check callbackPayload.cloneWithType(CallbackCamunda);
        string requestID = inputRecord.requestID;
        json payload = {
            "status": inputRecord.status
        };

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON};
        http:Response res = check CallbackIS->patch(requestID, payload, headers);

        check caller->respond(res.statusCode);

    }

}

