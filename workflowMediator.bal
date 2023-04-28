import ballerina/http;
import ballerina/mime;

//callback record

type CallbackPayload record {
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
# + requestID - Request Idenitifier and this use for callback function  
# + workflowID - External workflow Identifier   
# + workflowVariable - List of varibles which recived from the request
public type WorkflowRequest record {
    string requestID;
    string workflowID;
    WorkflowRequestParamter[] workflowVariable;
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
                return workflowInitializer;
             }
             check caller->respond(200);
             
    }

    resource function post Callback(http:Caller caller, http:Request request) returns error? {

        http:Client CallbackIS = check new (callback.callback_url);

        json callbackPayload = check request.getJsonPayload();
        CallbackPayload callbackpayload = check callbackPayload.cloneWithType(CallbackPayload);
        string requestID = callbackpayload.requestID;
        json ISCallbackPayload = {
            "status": callbackpayload.status
        };

        map<string> headers = {"Content-Type": mime:APPLICATION_JSON};
        http:Response res = check CallbackIS->patch(requestID, ISCallbackPayload, headers);

        check caller->respond(res.statusCode);

    }

}

