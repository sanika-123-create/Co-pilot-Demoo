/**
 *  Contains all Metadata related queries
 * 
 * @author         NAGARRO | 05-28-2026
 * @description    Contains all Metadata related queries
 * @history        Version 1.0
 * @test class     CustomMetadataTypeDAOTest updated 05-28-2026
 **/
public with sharing class CustomMetadataTypeDAO {
    /**
	* @description Get External_API_Integration__mdt By DeveloperName = devName
	* @author Prashanth
	* @param devName 
	* @return List<External_API_Integration__mdt> 
	**/
	public static List<External_API_Integration__mdt> getExtAPIIntegrationMetadata(String devName) {
		return new DynamicSOQLSelector()
			.setFrom('External_API_Integration__mdt')
			.setFields(new Set<String>{ 'DeveloperName', 'Body__c', 'ContentType__c', 
                        'Additional_Params__c','Environment__c','Extended_URL__c',
                        'Is_Name_Credentials_Required__c','Method_Name__c',
                        'Timeout__c','Is_Access_Token_Required__c'})
			.setWhereConditions('DeveloperName = :devName')
			.setQueryParams(new Map<String, Object>{ 'devName' => devName})
			.setLimit(1)
			.execute();
	}    
}