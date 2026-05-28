/**
 * Perform operations bypassing object/field-level security when explicitly needed.
 * 
 * @author         NAGARRO | 05-28-2026
 * @description    Perform operations bypassing object/field-level security when explicitly needed.
 * @history        Version 1.0
 * @test class     WithoutSharingUtilityTest updated 05-28-2026
 **/
public without sharing class WithoutSharingUtility {
    /**
	* @description Method to get users
	* @author Nagarro | 05-22-2024 
	* @param  userId 
	* @return List<User> 
	**/
	@AuraEnabled(cacheable=true)
	public static List<User> getUserDetails(String userId) {
		return UserDao.getUserInfoById(userId);
	}    
}