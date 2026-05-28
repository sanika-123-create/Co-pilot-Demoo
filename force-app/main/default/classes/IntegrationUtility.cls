/**
 * IntegrationUtility class external API Integration details.
 * 
 * @author         NAGARRO | 05-28-2026
 * @description    IntegrationUtility class external API Integration details.
 * @history        Version 1.0
 * @test class     IntegrationUtilityTest updated 05-28-2026
 **/
public with sharing class IntegrationUtility {
    /**
     * @description Method to prepare request
     * @author Nagarro | 05-27-2026
     * @param  integrationName
     * @return HttpRequest
     **/
    public static HttpRequest prepareIntegrationRequest(String integrationName) {
        // Prepare the HttpRequest
        HttpRequest req = new HttpRequest();
        try{
            // Fetch the custom metadata record
            External_API_Integration__mdt metadata;
            List<External_API_Integration__mdt> lstMD = CustomMetadataTypeDAO.getExtAPIIntegrationMetadata(integrationName);
            metadata = (lstMD!=null && lstMD.size()>0) ? lstMD[0]:null;
            DebugUtility.addDebug('metadata-'+metadata);
            
            
            // Set the HTTP method
            req.setMethod(metadata.Method_Name__c);
            if (!String.isBlank(metadata.ContentType__c)) {
                req.setHeader('Content-Type', metadata.ContentType__c);
            }
            // If Named Credentials are required, use them
            if (metadata.Is_Name_Credentials_Required__c) {
                String extendedUrl = String.isBlank(metadata.Extended_URL__c)? '': metadata.Extended_URL__c;
                req.setEndpoint('callout:NamedCredential_API' + extendedUrl);
            }else{
                String extendedUrl = String.isBlank(metadata.Extended_URL__c)? '': metadata.Extended_URL__c;
                req.setEndpoint(extendedUrl);
            }
            req = setAdditionalRequestDetails(metadata, req);
            DebugUtility.addDebug('request---'+req);
        } catch(Exception ex){
            LogFactory.error('Error while preparing request',ex);
        }
        return req;
    }
    
    
    /**
     * @description Method to prepare request
     * @author Nagarro | 05-27-2026
     * @param  metadata
     * @param req
     * @return HttpRequest
     **/
    private static HttpRequest setAdditionalRequestDetails(External_API_Integration__mdt metadata, HttpRequest req) {
        // If timeout is set in metadata, use it
        if (metadata.Timeout__c != null) {
            Integer timeout = Integer.valueOf(metadata.Timeout__c);
            req.setTimeout(timeout);
        }
        if(metadata.Is_Access_Token_Required__c){
            String accessToken = getAccessToken();
            req.setHeader('Authorization', 'Bearer ' + accessToken);
        }
        // If body is set in metadata, use it
        if (metadata.Body__c != null) {
            req.setBody(metadata.Body__c);
        }
        return req;
    }
    
    
    /**
     * @description fetchAPIResponse
     * @author Nagarro | 05-27-2026
     * @param request
     * @param methodName
     * @return String
     **/
    public static String fetchAPIResponse(HttpRequest request, String methodName) {
        Http http = new Http();
        HttpResponse res;
        if(request != null){
            try {
                DebugUtility.addDebug('request-'+request?.getBody());
                res = http.send(request);
                DebugUtility.addDebug('response-'+res?.getBody());
                if (res.getStatusCode() == 200 || res.getStatusCode() == 204 || res.getStatusCode() == 201) {
                    return res.getBody();
                } else {
                    LogFactory.error('Error in API call  '+methodName,'request failed');
                }
            } catch (Exception e) {
                LogFactory.error('Error in API call:',e);
            }
        }
        if(Test.isRunningTest()){
            return null;
        }
        return 'API_ERROR';
    }
    
    /**
     * @description get access token
     * @author Nagarro | 05-27-2026
     * @return String
     **/
    public static String getAccessToken() {
        String sessionAccessToken = UserInfo.getSessionId();
        DebugUtility.addDebug('getOrganizationId :'+UserInfo.getOrganizationId().substring(0, 15) + ' ' + UserInfo.getSessionId().substring(15));
        DebugUtility.addDebug('sessionAccessToken : '+sessionAccessToken);
        String accessToken =  SessionCacheUtility.getSessionPlatformCache();
        DebugUtility.addDebug('sessionPlatformCacheToken : '+accessToken);
        String orgPlatformCacheToken = (String) Cache.Org.get('userAccessToken');
        DebugUtility.addDebug('orgPlatformCacheToken : '+ orgPlatformCacheToken);
        return accessToken;
    }
}