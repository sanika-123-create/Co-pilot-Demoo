# Apex Test Framework Reference

This reference captures how tests are structured in the codebase. New test classes should follow these patterns unless a specific skill rule is stricter.

## 1) Test Data Factory (Required)

- Use `TestDataFactory` for all test data creation.
- Do not inline test data creation in `@TestSetup`.
- Factory methods take a `Map<String, Object>` of parameters and return a `List<SObject>`.

Example:

```apex
@TestSetup
static void makeData() {
    Map<String, Object> rigger1 = new Map<String, Object>{
        'Party_Name__c' => 'BARNHART CRANE & RIGGING CO',
        'Party_Id__c' => '671711'
    };
    List<Account> accounts = TestDataFactory.createRiggerAccounts(
        new List<Map<String, Object>>{ rigger1 }
    );
    insert accounts;
}
```

## 2) Test Class Structure

- Class is `@isTest` and `public with sharing`.
- Use `@TestSetup` for shared data.
- Each test method is focused on a single behavior.
- Use `Test.startTest()` and `Test.stopTest()` around the code under test.
- Create a dedicated Apex test class for each Apex class. For example, if a DAO class and a Controller class are created as part of the requirement, generate separate test classes for the DAO and Controller respectively.
- Create test methods corresponding to each method in the Apex class to ensure proper coverage and validation.
- Avoid generating unnecessary or redundant test methods that do not validate specific business logic or method behavior.

Example:

```apex
@isTest
public with sharing class AccountDaoTest {
    @TestSetup
    static void makeData() {
        // use TestDataFactory
    }

    @isTest
    static void getRiggerAccountsTest() {
        Test.startTest();
        List<Account> riggers = AccountDao.getRiggerAccounts();
        Test.stopTest();
        System.assertEquals(1, riggers.size(), 'Expected 1 account record');
    }
}
```

## 3) Assertions

- Prefer `Assert.*` if the test rules require it, but keep messages consistent and specific.

## 4) Coverage Strategy

- Validate DAO and controller methods with their own test classes.
- Ensure negative paths are covered when input is invalid or empty.
- For bulk logic, create 251+ records via the factory to cross trigger batch boundaries.

## 5) Naming

- Test class: `{ClassName}Test` or `{ClassName}_Test` when matching legacy patterns.
- Test method names are descriptive and usually end with `Test`.

