/**
 * @description    Contains all user's related queries
 * @author         Nagarro
 * @history        Version 1.0
 * @test class     UserDaoTest updated 05-28-2026
 **/
public with sharing class UserDao {
    /**
	 * @description Get User Info By Id
	 * @author Nagarro
	 * @param userId
	 * @return List<User>
	 **/
    public static List<User> getUserInfoById(String userId) {
		return new DynamicSOQLSelector()
			.setFrom('User')
			.setFields(new Set<String>{'Id', 'Contact.MailingAddress', 'Contact.OtherAddress', 'Contact.RecordType.Name', 'Contact.Account.Name'})
			.setWhereConditions('ID = :userId')
			.setQueryParams(new Map<String, Object>{ 'userId' => userId })
			.execute();
	}

}