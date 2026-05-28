/*******************************************************************************************************************
 * @company     : Nagarro Inc.
 * @date        : 01-06-2023
 * @author      : Nagarro
 * @description : This class is wrapper class for the DynamicSOQLSelector class
 * @history     : Version 1.0
 * @test class  : DynamicSOQLSelectorTest
 *******************************************************************************************************************/
public class DynamicSOQLSelectorWrapper {
	public String objectName;
	public Set<String> fieldNames;
	public System.AccessLevel accessLevel;
	public String condition;
	public String havingCondition;
	public Map<String, Object> queryParams;
	public Integer limitValue;
	public Integer offsetValue;
	public Boolean forUpdate;
	public Boolean allRows;
	public List<String> sortFieldsList;
	public List<String> groupByFields;
	public Set<String> whereConditionSet;

	public DynamicSOQLSelectorWrapper() {
		this.fieldNames = new Set<String>();
		this.accessLevel = System.AccessLevel.SYSTEM_MODE;
		this.condition = '';
		this.queryParams = new Map<String, Object>();
		this.forUpdate = false;
		this.allRows = false;
		this.sortFieldsList = new List<String>();
		this.groupByFields = new List<String>();
		this.whereConditionSet = new Set<String>();
	}
}