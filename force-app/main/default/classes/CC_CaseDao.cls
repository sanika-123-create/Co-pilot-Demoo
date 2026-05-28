/**
 * @description       : Get Case Records
 * @author            : Nagarro | 05-28-2026
 **/
public with sharing class CC_CaseDao {
    /**
	 * @description Get Cases by Id
	 * @param  caseId
	 * @return List<Case>
	 **/
	public static List<Case> getCasesById(String caseId) {
		return new DynamicSOQLSelector()
			.setFrom('Case')
			.setFields(new Set<String>{ 'Id', 'Subject' })
			.setWhereConditions('Id = :CaseId')
			.setQueryParams(new Map<String, Object>{ 'CaseId' => caseId })
			.setLimit(1)
			.execute();
	}
}