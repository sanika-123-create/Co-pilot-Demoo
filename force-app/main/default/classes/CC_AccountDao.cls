/**
 * @description       : Get Account Records
 * @author            : Nagarro | 05-28-2026
 **/
public with sharing class CC_AccountDao {
    /**
	 * @description Get Accounts by Id
	 * @param  accountId
	 * @return List<Account>
	 **/
	public static List<Account> getAccountsByPatronCode(String accountId) {
		return new DynamicSOQLSelector()
			.setFrom('Account')
			.setFields(new Set<String>{ 'Id', 'Name' })
			.setWhereConditions('Id = :AccountId')
			.setQueryParams(new Map<String, Object>{ 'AccountId' => accountId })
			.setLimit(1)
			.execute();
	}
}