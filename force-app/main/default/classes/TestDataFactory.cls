/**
 * @description       : Test Data Factory class
 * @author            : Nagarro
 **/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.cyclomaticcomplexity')
@isTest
public with sharing class TestDataFactory {
    /**
     * @description Create Customer Account
     * @param param
     * @param noOfRecords
     * @return List<Account>
     **/
    public static List<Account> createCustomerAccount(Map<String,Object> param , Integer noOfRecords){
        List<Account> records = new List<Account>();
        for(Integer i = 0; i< noOfRecords; i++){
            Account accountObj = new Account(
                Type = 'Customer',
                Name = (String) param.get('Name'),
                BillingStreet = '789 Maple St',
                BillingPostalCode = '12345',
                BillingCity = 'SupplierTown',
                BillingCountry = 'USA',
                BillingState = 'ST'
            );
            records.add(accountObj);
        }
        return records;
    }
}