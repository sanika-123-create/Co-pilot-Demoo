/**
 * SessionCacheUtility class session details.
 * 
 * @author         NAGARRO | 05-28-2026
 * @description    SessionCacheUtility class session details.
 * @history        Version 1.0
 * @test class     SessionCacheUtilityTest updated 05-28-2026
 **/
public class SessionCacheUtility {
    
    /**
     * @description Method to cache access token in org platform cache
     * @param accessToken String accessToken
     **/
    public static void saveOrgPlatformCache(String accessToken) {
        Cache.Org.put('userAccessToken', accessToken, 3600);  // Store for 1 hour (3600 seconds)
        DebugUtility.addDebug('Access token stored in org cache: ' + accessToken);
    }
    
    /**
     * @description Method to remove the access token from org platform cache
     * @param orgCacheName String orgCacheName
     **/
    public static void removeOrgPlatformCache(String orgCacheName) {
        Boolean isRemoved = Cache.Org.remove(orgCacheName);  // Remove the value by key
        if (isRemoved) {
            DebugUtility.addDebug('Access token removed from Org Cache.');
        } else {
            DebugUtility.addDebug('No token found to remove.');
        }
    }
    
    /**
     * @description Method to get the access token from org platform cache
     **/
    @AuraEnabled(cacheable=true)
    public static void getOrgPlatformCache() {
        String cachedAccessToken = (String) Cache.Org.get('userAccessToken');
        if (cachedAccessToken != null) {
            DebugUtility.addDebug('Retrieved access token from org cache: ' + cachedAccessToken);
            //Save org platform cache to Session Platform Cache
            saveSessionPlatformCache(cachedAccessToken);
            //removeOrgPlatformCache('userAccessToken');
        } else {
            DebugUtility.addDebug('No access token found in org cache.');
        }
    }
    
    /**
     * @description Method to store access token in session platform cache
     * @param accessToken String accessToken
     **/
    public static void saveSessionPlatformCache(String accessToken) {
        Cache.Session.put('userAccessToken', accessToken);  // Store for 1 hour (3600 seconds)
        DebugUtility.addDebug('Access token stored in session cache: ' + accessToken);
    }
    
    /**
     * @description Method to retrieve access token from session platform cache
     * @return String
     **/
    public static String getSessionPlatformCache() {
        String cachedAccessToken = (String) Cache.Session.get('userAccessToken');
        if (cachedAccessToken != null) {
            DebugUtility.addDebug('Retrieved access token from org cache: ' + cachedAccessToken);
            return cachedAccessToken;
        } else {
            DebugUtility.addDebug('No access token found in org cache.');
            return null;
        }
    }
    
    /**
     * @description Example method to make a GET request using the named credential
     * @return String
     **/
    public static String getDataFromAPI() {
        HttpRequest req = new HttpRequest();
        
        // The named credential handles the OAuth token request automatically
        req.setEndpoint('callout:UserAccessToken/oauth/token'); // Named credential endpoint
        req.setMethod('POST');  // Ensure POST is supported for the token endpoint
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');  // Ensure proper header
        // Add the body for OAuth2 request (client credentials grant flow)
        req.setBody('grant_type=client_credentials&scope=api');
        Http http = new Http();
        try {
            HttpResponse response = http.send(req);
            // Check for success
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                throw new CalloutException('Error from API: ' + response.getStatus() + ' - ' + response.getBody());
            }
        } catch (CalloutException e) {
            DebugUtility.addDebug('Callout error: ' + e.getMessage());
            throw e;
        }
    }
}