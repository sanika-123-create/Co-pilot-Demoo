# Comprehensive Framework Reference

This reference defines the architectural patterns, naming conventions, and framework structures used across Apex, Apex Tests, LWC, and Visualforce in the  codebase. All new components must follow these patterns.

---

## 1) APEX FRAMEWORK

### 1.1 Architecture Layers

The codebase follows a **strict 3-layer architecture**:

```
UI Layer (LWC/VF/Aura)
    ↓
Controller Layer ({Object}Controller)
    ↓
DAO/Selector Layer ({Object}Dao)
    ↓
Database (SOQL)
```

**Rules:**
- Controllers handle UI requests and return `Response` wrapper objects
- DAOs centralize all SOQL queries—controllers/services NEVER embed SOQL
- Helpers extract business logic from controllers
- Triggers delegate to `TriggerHandler` base class

### 1.2 Naming Conventions

```
DAO Classes:           {Object}Dao
Controller Classes:    {Object}Controller
Trigger Classes:       {Object}Trigger
Trigger Handler:       {Object}TriggerHandler
Helper Classes:        {ObjectName}Helper / CommonHelper
Utility Classes:       SharedUtility / CommonUtil
Wrapper Classes:       {ObjectName}Wrapper or inline inner class
Test Classes:          {ClassName}Test
Queueable Classes:     {CustomName}Queueable
Batch Classes:         {CustomName}Batch
```

**Examples:**
- `CaseDao.cls` – all User SOQL queries
- `ClaimController.cls` – Claim UI handlers
- `ClaimTriggerHandler.cls` – Claim trigger logic
- `BusinessRulesUtility.cls` – shared business logic
- `AccountUpdateWrapper.cls` – wrapper for complex data

### 1.3 Dynamic SOQL Pattern (MANDATORY for all DAO methods)

Always use `DynamicSOQLSelector` for query building:

```apex
public static List<User> getUserByRacfId(String racfId) {
    return new DynamicSOQLSelector()
        .setFrom('User')
        .setFields(new Set<String>{ 'Id', 'ContactId', 'IsActive', 'Phone'})
        .setWhereConditions('email = :emailId')
        .setQueryParams(new Map<String, Object>{ 'emailId' => emailId})
        .setLimit(1)
        .execute();
}
```

**Key Methods:**
- `.setFrom(sObject)` – required, the object to query
- `.setFields(Set<String>)` – field list (supports relationships like `Contact.Name`)
- `.setFieldSet(FieldSet)` – alternative: query defined field set
- `.setWhereConditions(String)` – WHERE clause with bind variables (`:variable`)
- `.setQueryParams(Map<String, Object>)` – bind all variables here
- `.setLimit(Integer)` – deterministic result ordering
- `.setOrderAscBy(String)` / `.setOrderDescBy(String)` – sort order
- `.setAccessLevel(System.AccessLevel.SYSTEM_MODE)` – if needs system mode
- `.execute()` – returns `List<SObject>`
- `.getQueryLocator()` – for Batch apex (returns `Database.QueryLocator`)

**Critical Rules:**
- ✅ Use bind variables for ALL user-provided values
- ❌ NEVER concatenate user input into SOQL
- ✅ Always set `.setLimit()` and order for deterministic results
- ✅ Use `.setAccessLevel()` only when necessary to bypass sharing rules

### 1.3.1 Comprehensive DAO Usage Examples

**Example 1: Single Record Retrieval**
```apex
/**
 * @description Retrieve a specific claim with all related equipment
 * @param claimId - The claim record ID
 * @return Case - Single claim record with related data
 **/
public static Case getClaimDetailsById(String claimId) {
    List<Case> claims = new DynamicSOQLSelector()
        .setFrom('Case')
        .setFields(new Set<String>{ 
            'Id', 'Name', 'Subject', 'Status', 'Priority',
            'Claim_Amount__c', 'CreatedDate',
            'Customer__r.Name', 'Supplier_Claimant__r.Name'
        })
        .setWhereConditions('Id = :claimId')
        .setQueryParams(new Map<String, Object>{ 'claimId' => claimId })
        .setLimit(1)
        .execute();
    
    return claims.isEmpty() ? null : (Case) claims[0];
}
```

**Example 2: Multiple Records with Complex Filtering**
```apex
/**
 * @description Get all active claims for a customer within date range
 * @param customerId - Customer account ID
 * @param startDate - Start of date range
 * @param endDate - End of date range
 * @return List<Case> - Filtered list of claims
 **/
public static List<Case> getClaimsByCustomerAndDateRange(Id customerId, Date startDate, Date endDate) {
    return new DynamicSOQLSelector()
        .setFrom('Case')
        .setFields(new Set<String>{ 
            'Id', 'Name', 'Status', 'Claim_Amount__c', 
            'CreatedDate', 'Customer__c'
        })
        .setWhereConditions('Customer__c = :customerId AND Status != :closed AND CreatedDate >= :startDate AND CreatedDate <= :endDate')
        .setQueryParams(new Map<String, Object>{ 
            'customerId' => customerId,
            'closed' => 'Closed',
            'startDate' => startDate,
            'endDate' => endDate
        })
        .setOrderDescBy('CreatedDate')
        .setLimit(1000)
        .execute();
}
```

**Example 3: Using Field Sets**
```apex
/**
 * @description Retrieve user info using predefined field set
 * @param userId - User record ID
 * @return List<User> - User records with fieldset fields
 **/
public static List<User> getUserInfoWithFieldSet(String userId) {
    return new DynamicSOQLSelector()
        .setFrom('User')
        .setFieldSet(Schema.SObjectType.User.fieldSets.UserInfoPreview)
        .setWhereConditions('Id = :userId')
        .setQueryParams(new Map<String, Object>{ 'userId' => userId })
        .setLimit(1)
        .execute();
}
```

**Example 4: Batch Processing with QueryLocator**
```apex
/**
 * @description Get all inactive users for batch deactivation
 * @param inactiveDays - Number of days of inactivity threshold
 * @return Database.QueryLocator - QueryLocator for batch job
 **/
public static Database.QueryLocator getInactiveUsersForBatch(Integer inactiveDays) {
    Date inactiveDate = Date.today().addDays(-inactiveDays);
    
    return new DynamicSOQLSelector()
        .setFrom('User')
        .setFields(new Set<String>{ 'Id', 'IsActive', 'LastLoginDate', 'Profile.Name' })
        .setWhereConditions('Profile.Name IN :profileNames AND LastLoginDate < :inactiveDate AND IsActive = true')
        .setQueryParams(new Map<String, Object>{ 
            'profileNames' => System.Label.COMMUNITY_LOGIN_PROFILE.split(','),
            'inactiveDate' => inactiveDate
        })
        .getQueryLocator();
}
```

**Example 5: DAO Pattern in Service Layer (Recommended)**
```apex
public class ClaimService {
    
    /**
     * @description Get and validate claim details
     * @param claimId - Claim ID to fetch
     * @return Response - Response wrapper with data and status
     **/
    public static Response getClaimDetails(String claimId) {
        Boolean isSuccess = false;
        String message = 'Claim not found';
        List<SObject> data = new List<SObject>();
        
        try {
            // Call DAO for SOQL
            List<Case> claims = ClaimDao.getClaimById(claimId);
            
            if (!claims.isEmpty()) {
                data.addAll(claims);
                isSuccess = true;
                message = '';
            }
        } catch (Exception ex) {
            message = 'Error retrieving claim details';
            LogFactory.error('ClaimService.getClaimDetails', ex);
        }
        
        return new Response(isSuccess, data, message);
    }
}
```

### 1.4 Response Wrapper Pattern

All controllers return `Response`:

```apex
@AuraEnabled(cacheable=true)
public static Response getUserDetails(String userId) {
    Boolean isSuccess = false;
    String message = 'No records found';
    List<User> data = new List<User>();
    
    try {
        data = UserDao.getUserInfoById(userId);
        if (data != null && !data.isEmpty()) {
            isSuccess = true;
            message = '';
        }
    } catch (Exception ex) {
        isSuccess = false;
        message = 'Error retrieving user details';
        LogFactory.error('UserController.getUserDetails', ex);
    }
    
    return new Response(isSuccess, data, message);
}
```

**Response Structure:**
```apex
public class Response {
    @AuraEnabled public Boolean isSuccess;
    @AuraEnabled public List<SObject> data;
    @AuraEnabled public String message;
    
    public Response(Boolean isSuccess, List<SObject> data, String message) {
        this.isSuccess = isSuccess;
        this.data = data;
        this.message = message;
    }
}
```

### 1.5 Error Handling Pattern

**Server-side logging:**
```apex
try {
    // logic
} catch (Exception ex) {
    LogFactory.error('ClassName.methodName', ex);
    throw new AuraHandledException('Safe message for UI');
}
```

**Trigger error logging:**
```apex
Database.SaveResult result = Database.insert(record);
LogFactory.logDatabaseErrors('ClassName.methodName', result);
```

### 1.6 Trigger Handler Framework

All triggers delegate to `TriggerHandler`:

**Trigger Code:**
```apex
trigger ClaimTrigger on Case (before insert, before update, after insert, after update) {
    new ClaimTriggerHandler().run();
}
```

**Handler Class:**
```apex
public class ClaimTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        // validate new claim records
    }
    
    public override void beforeUpdate() {
        // handle updates
    }
    
    public override void afterInsert() {
        // post-insert logic
    }
    
    public override void afterUpdate() {
        // post-update logic
    }
}
```

**Handler Framework Features:**
- Automatic trigger context detection (before/after, insert/update/delete/undelete)
- Loop count prevention (avoid infinite recursion)
- Bypass mechanism for testing: `TriggerHandler.bypass('ClassName')`
- Bulkified DML handling via `existingRecordsToUpdateMap`

### 1.7 Wrapper/Inner Class Pattern

For complex data structures, use inner classes:

```apex
public class ClaimHelper {
    
    // Inner wrapper class
    public class ClaimWrapper {
        public String claimNumber { get; set; }
        public Decimal claimAmount { get; set; }
        public List<EquipmentWrapper> equipment { get; set; }
        
        public ClaimWrapper(String claimNumber, Decimal claimAmount) {
            this.claimNumber = claimNumber;
            this.claimAmount = claimAmount;
            this.equipment = new List<EquipmentWrapper>();
        }
    }
    
    public class EquipmentWrapper {
        public String equipmentId { get; set; }
        public String vinNumber { get; set; }
    }
}
```

---

## 1.8 SharedUtility CLASSES - COMPREHENSIVE REFERENCE

The  codebase includes specialized SharedUtility classes for common operations. Use these instead of duplicating logic.

### 1.8.1 LogFactory - Error & Event Logging

**Purpose:** Centralized error logging for Apex, LWC, DML operations, and integrations.

**Key Methods:**

```apex
/**
 * @description Log Apex exceptions with only messgae stack trace
 * @param sourceClass - Name of the class.methodName where error occurred
 * @param message - error message
 */
public static void error(String sourceClass, String message) 

/**
 * @description Log Apex exceptions with stack trace
 * @param sourceClass - Name of the class.methodName where error occurred
 * @param ex - Exception containing information related to the error (Stacktrace, Message, Line Number etc.)
 */
public static void error(String sourceClass, Exception ex) 

/**
 * @description Log DML operation errors (insert, update, delete, upsert)
 * @param sourceClass - Name of the class.methodName where error occurred
 * @param dataBaseErrors for error logs details
 */
public static void logDatabaseErrors(String sourceClass, List<Database.Error> errors)

/**
 * @description Log errors from LWC components
 * @param componentName - LWC component name
 * @param message - Error message from LWC
 */
@AuraEnabled
public static void createLogRecord(String componentName, String message)

```

**Usage Examples:**

```apex
// In Apex Exception Handling
try {
    List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
} catch (Exception ex) {
    LogFactory.error(
        'AccountService.getAccounts',
        ex
    );
    throw new AuraHandledException('Unable to retrieve accounts');
}
```

### 1.8.2 DMLUtility - Bulk DML Operations

**Purpose:** Standardized bulk insert, update, upsert, delete with error logging and access control.

**Key Methods:**

```apex
/** 
 * @description Method to insert SObject records
 * @param       records - The SObject records to be inserted
 * @param       allOrNoneIndicator - Boolean indicator for partial insert
 * @return      Database.SaveResult[]
**/
public static Database.SaveResult[] insertRecords(List<SObject> records, Boolean allOrNoneIndicator)

/**
 * @description Update records with error logging
 * @param       records - The SObject records to be inserted
 * @param       allOrNoneIndicator - Boolean indicator for partial insert
 * @return      Database.SaveResult[]
 */
public static Database.SaveResult[] updateRecords(List<SObject> records, Boolean allOrNoneIndicator)

/**
 * @description         Method to update SObject records
 * @param records       The SObject records to be updated 
 * @param dmlOptions    dmlOptions indicator for diffrent dml operations
 * @return              Database.SaveResult[]
 */
public static Database.SaveResult[] updateRecords(List<SObject> records, Database.DMLOptions dmlOptions)

/**
 * @description     : Method to upsert SObject records
 * @param records - The SObject records to be upserted
 * @param allOrNoneIndicator - Boolean indicator for partial insert
 * @return Database.UpsertResult[]
 */
public static Database.UpsertResult[] upsertRecords(List<SObject> records, Boolean allOrNoneIndicator)

/**
 * @description     : Method to delete SObject records
 * @param records - The SObject records to be deleted
 * @param allOrNoneIndicator - Boolean indicator for partial delete
 * @return      : Database.DeleteResult[]
 */
public static Database.DeleteResult[] deleteRecords(List<SObject> records, Boolean allOrNoneIndicator)
```

**Usage Examples:**

```apex
// Insert with error logging
List<Account> accountsToInsert = new List<Account>();
accountsToInsert.add(new Account(Name = 'Test Account'));

Database.SaveResult[] results = DMLUtility.insertRecords(accountsToInsert,true);

// Check results
for (Database.SaveResult result : results) {
    if (!result.isSuccess()) {
        for (Database.Error error : result.getErrors()) {
            System.debug('Error: ' + error.getMessage());
        }
    }
}

// Upsert with external ID
List<Account> accountsToUpsert = new List<Account>();
accountsToUpsert.add(new Account(
    External_ID__c = 'EXT123',
    Name = 'Updated Account'
));

Database.UpsertResult[] upsertResults = DMLUtility.upsertRecords(accountsToUpsert,false);
```

### 1.8.3 EmailUtility - Email Communication

**Purpose:** Send emails with templates, PDF attachments, and org-wide email addresses.

**Key Methods:**

```apex
/**
 * @description Send email using stored email template
 * @param emailRequest - EmailRequestWrapper containing:
 *   - sourceRecordId: Record ID for template merge
 *   - templateDeveloperName: Email template API name
 *   - toEmailIdList: List<String> recipient emails
 *   - ccEmailIdList: List<String> CC recipients (optional)
 *   - subject: Override subject (optional)
 *   - whoId: Contact/Lead ID for relationship
 *   - emailTemplateId: Pre-queried template ID (optional, for bulk)
 *   - setOrgWideEmailAddressId: Pre-queried org-wide email (optional)
 * @return Messaging.SingleEmailMessage - Prepared but unsent email
 */
public static Messaging.SingleEmailMessage sendVisualForceTemplateEmail(EmailRequestWrapper emailRequest)

/**
 * @description Send email with VF page rendered as PDF attachment
 * @param emailRequest - EmailRequestWrapper with additional:
 *   - pdfVFPageName: VF page name (without /apex/)
 *   - attachmentFileName: Name for PDF attachment
 * @return Messaging.SingleEmailMessage - Email with PDF attachment
 */
public static Messaging.SingleEmailMessage sendVisualForceTemplateEmailWithPDF(EmailRequestWrapper emailRequest)
```

**EmailRequestWrapper Structure:**
```apex
public class EmailRequestWrapper {
    public String sourceRecordId;              // Record for merge fields
    public String templateDeveloperName;       // Email template developer name
    public List<String> toEmailIdList;         // To: recipients
    public List<String> ccEmailIdList;         // CC: recipients
    public String subject;                     // Subject (overrides template)
    public String whoId;                       // Contact/Lead ID
    public String pdfVFPageName;              // VF page name (without /apex/)
    public String attachmentFileName;          // PDF filename
    public String emailTemplateId;            // Pre-queried template ID
    public String setOrgWideEmailAddressId;   // Pre-queried org-wide email
}
```

**Usage Examples:**

```apex
// Simple email with template
EmailRequestWrapper emailRequest = new EmailRequestWrapper();
emailRequest.sourceRecordId = claimRecord.Id;
emailRequest.templateDeveloperName = 'Claim_Approved_Email';
emailRequest.toEmailIdList = new List<String>{ 'customer@example.com' };
emailRequest.ccEmailIdList = new List<String>{ 'manager@example.com' };
emailRequest.subject = 'Your Claim #' + claimRecord.Name + ' has been approved';

Messaging.SingleEmailMessage email = EmailUtility.sendVisualForceTemplateEmail(emailRequest);

// Send up to 5 emails (Salesforce limit)
if (email != null) {
    Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
}

// Email with PDF attachment (for bulk: pre-query template and org-wide email)
EmailHelper emailRequest = new EmailRequestWrapper();
emailRequest.sourceRecordId = claimRecord.Id;
emailRequest.templateDeveloperName = 'Claim_Summary_PDF';
emailRequest.toEmailIdList = new List<String>{ 'customer@example.com' };
emailRequest.pdfVFPageName = 'ClaimDetailsPrintable';
emailRequest.attachmentFileName = 'Claim_' + claimRecord.Name + '.pdf';
emailRequest.emailTemplateId = templateId;  // From batch query
emailRequest.setOrgWideEmailAddressId = orgWideEmailId;  // From batch query

Messaging.SingleEmailMessage emailWithPDF = EmailUtility.sendVisualForceTemplateEmailWithPDF(emailRequest);
```

### 1.8.4 SharedUtility - Shared Helper Methods

**Purpose:** Common utility functions for formatting, comparisons, and data operations.

**Key Methods:**

```apex
/**
 * @description Format date to MM/DD/YYYY format
 * @param inputDate - Date object
 * @return String - Formatted date string
 */
public static String formatDate(Date inputDate)

/**
 * @description Case-insensitive contains check
 * @param allValues - List of strings to search
 * @param valueToCheck - Value to find
 * @return Boolean - True if found (case-insensitive)
 */
public static Boolean contains(List<String> allValues, String valueToCheck)

```

**Usage Examples:**

```apex

// Format date
Date claimDate = Date.newInstance(2026, 3, 18);
String formattedDate = SharedUtility.formatDate(claimDate); // "3/18/2026"

// Case-insensitive list search
List<String> statusList = new List<String>{ 'Active', 'Inactive', 'Pending' };
Boolean isActive = SharedUtility.contains(statusList, 'active'); // true
```

### 1.8.5 IntegrationUtility - External System Integration

**Purpose:** Handle API callouts, request/response formatting, and integration logging.

### 1.8.6 DebugUtility - Debug Logging

**Purpose:** System debug logging with level control and performance tracking.

**Key Methods:**

```apex
/**
 * @description Add debug entry with timestamp
 * @param logMessage - Debug message
 */
public static void addDebug(String logMessage)

/**
* @description log and track messgae in the system.
* @param loggingLevel System.LoggingLevel loggingLevel, String logMessage
* @param logMessage message to be logged
**/
@SuppressWarnings('PMD.AvoidDebugStatements')
public static void addDebug(System.LoggingLevel loggingLevel, String logMessage)
```

### 1.8.7 WithoutSharingUtility - Bypass Sharing Rules

**Purpose:** Perform operations bypassing object/field-level security when explicitly needed.

```apex
public without sharing class WithoutSharingUtility {
    /**
     * @description Query records without sharing restrictions
     * Used sparingly for batch jobs and system operations only
     */
    public static List<SObject> getRecordsIgnoringSharing(String query)
}
```

**Usage:** Only use when there's a business requirement and document the reason.

```apex
// AVOID - Use with sharing by default
public static List<Account> getAccountsAsAdmin() {
    // Justification: Batch job needs to deactivate all inactive accounts system-wide
    return WithoutSharingUtility.getRecordsIgnoringSharing('SELECT Id FROM Account WHERE IsActive = false');
}
```

---

## 1.9 UTILITY CLASSES - COMMON USAGE PATTERNS

### Pattern: Bulk Operations with Error Handling

```apex
public class ClaimBatchProcessor {
    
    /**
     * @description Update multiple claims in bulk
     * @param claimsToUpdate - Claims requiring updates
     */
    public static Response updateClaimsInBulk(List<Case> claimsToUpdate) {
        Boolean isSuccess = false;
        String message = '';
        List<SObject> updatedRecords = new List<SObject>();
        
        try {
            // Use DML Utility for bulk update with logging
            
            Database.SaveResult[] results = DMLUtility.updateRecords(claimsToUpdate,false);/* false - Allow partial updates*/
            
            Integer successCount = 0;
            for (Database.SaveResult result : results) {
                if (result.isSuccess()) {
                    successCount++;
                } else {
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error: ' + error.getMessage());
                    }
                }
            }
            
            isSuccess = true;
            message = successCount + ' of ' + results.size() + ' claims updated';
            
        } catch (Exception ex) {
            message = 'Batch update failed: ' + ex.getMessage();
            LogFactory.error('ClaimBatchProcessor.updateClaimsInBulk',ex);
        }
        
        return new Response(isSuccess, updatedRecords, message);
    }
}
```

### Pattern: Email Notifications in Batch

```apex
public class ClaimNotificationBatch implements Database.Batchable<SObject> {
    
    // Batch execution
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Use DAO for query
        return ClaimDao.getClaimsAwaitingNotification();
    }
    
    public void execute(Database.BatchableContext bc, List<Case> claimsToNotify) {
        // Pre-query template and org-wide email for performance
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Claim_Notification'];
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Support'];
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Case claim : claimsToNotify) {
            EmailRequestWrapper emailRequest = new EmailRequestWrapper();
            emailRequest.sourceRecordId = claim.Id;
            emailRequest.templateDeveloperName = 'Claim_Notification';
            emailRequest.toEmailIdList = new List<String>{ claim.Customer__r.Email__c };
            emailRequest.emailTemplateId = template.Id;
            emailRequest.setOrgWideEmailAddressId = orgWideEmail.Id;
            
            Messaging.SingleEmailMessage email = EmailUtility.sendVisualForceTemplateEmail(emailRequest);
            if (email != null) {
                emailsToSend.add(email);
            }
        }
        
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception ex) {
                LogFactory.error('ClaimNotificationBatch.execute',ex);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Finish logic
    }
}
```

### 1.9 Code Quality Standards

**Avoid:**
- ❌ Embedding SOQL in controllers/helpers
- ❌ Hardcoded literals (use labels: `System.Label.LABEL_NAME`)
- ❌ Nested if blocks deeper than 3 levels (extract to helper method)
- ❌ SOQL/DML inside loops (bulkify)
- ❌ Public modifiers without reason (use private/protected)

**Enforce:**
- ✅ All classes: `public with sharing` (unless `without sharing` is explicitly needed)
- ✅ All methods: correct access level (public only for UI/invocable)
- ✅ Documentation: use JSDoc-style comments with `@description`, `@author`, `@param`, `@return`
- ✅ Constants: all repeated values in named constants
- ✅ Early return pattern to reduce nesting

---

## 2) APEX TEST FRAMEWORK

### 2.1 Test Class Structure

```apex
@isTest
public class UserDaoTest {
    
    @TestSetup
    static void setupTestData() {
        // Shared test data for all test methods
        User testUser = TestDataFactory.createSystemAdminUser(
            new Map<String, Object> {
                'Username' => 'testuser' + DateTime.now().getTime() + '@test.com',
                'Email' => 'testuser@test.com',
                'FirstName' => 'Test',
                'LastName' => 'User',
                'FederationIdentifier' => 'TESTUSER001'
            }
        );
        insert testUser;
    }
    
    @isTest
    static void testPositiveScenario() {
        List<User> result = UserDao.getUserByRacfId('TESTUSER001');
        System.assertEquals(true, result != null, 'Result should not be null');
        System.assertEquals(1, result.size(), 'One user should be returned');
    }
    
    @isTest
    static void testNegativeScenario() {
        List<User> result = UserDao.getUserByRacfId('NONEXISTENT');
        System.assertEquals(true, result != null, 'Result should be a list');
        System.assertEquals(0, result.size(), 'No users should be returned');
    }
    
    @isTest
    static void testEdgeCaseScenario() {
        List<User> result = UserDao.getUserByRacfId(null);
        // Validate null handling
    }
}
```

### 2.2 Test Data Factory Pattern

Use `TestDataFactory` for all test data:

```apex
// Create account records
List<Account> suppliers = TestDataFactory.createSupplierAccount(
    new Map<String, Object> {
        'Name' => 'Test Supplier',
        'Supplier_Type__c' => 'Freight',
        'REV_SCAC__c' => '354',
        'External_ID__c' => 'Sup-001'
    },
    1  // number of records
);
insert suppliers;

// Create claim records
List<Case> claims = TestDataFactory.createClaim(
    new Map<String, Object> {
        'Status' => 'New',
        'Subject' => 'Test Claim',
        'Customer__c' => customerAccountId,
        'Supplier_Claimant__c' => supplierAccountId,
        'RecordTypeId' => claimRecTypeId
    },
    5  // number of records
);
insert claims;

// Create users
User adminUser = TestDataFactory.createSystemAdminUser(
    new Map<String, Object> {
        'Username' => 'admin' + DateTime.now().getTime() + '@test.com',
        'Email' => 'admin@test.com'
    }
);
insert adminUser;
```

**Factory Methods Available:**
- `createAccount(Map params, Integer count)`
- `createCustomerAccountForClaims(Map params, Integer count)`
- `createClaim(Map params, Integer count)`
- `createSystemAdminUser(Map params)`
- Additional methods in `TestDataFactory`

### 2.3 Test Coverage Requirements

**Minimum coverage per method:**
- Positive case (happy path)
- Negative case (error condition)
- Edge case (boundary values, null, empty)

**Example:**
```apex
@isTest
static void testGetUserInfoByIdPositive() {
    // POSITIVE: Valid user ID should return user
    List<User> result = UserDao.getUserInfoById(UserInfo.getUserId());
    System.assert(result != null, 'Should return user list');
}

@isTest
static void testGetUserInfoByIdNegative() {
    // NEGATIVE: Invalid user ID should return empty list
    List<User> result = UserDao.getUserInfoById('invalidId');
    System.assertEquals(0, result.size(), 'Should return empty list');
}

@isTest
static void testGetUserInfoByIdEdgeCase() {
    // EDGE CASE: Null ID should handle gracefully
    try {
        UserDao.getUserInfoById(null);
    } catch (Exception ex) {
        System.assert(true, 'Exception expected for null ID');
    }
}
```

### 2.4 Async Test Patterns

**For Queueable/Future/Batch:**
```apex
@isTest
static void testQueueableAsync() {
    Test.startTest();
    
    System.enqueueJob(new FetchServiceCasesQueueable(caseIds));
    
    Test.stopTest();
    
    // Assertions after Test.stopTest()
    List<Case> updatedCases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
    System.assertEquals('Processed', updatedCases[0].Status);
}
```

### 2.5 Test Assertions Best Practices

```apex
// ❌ BAD: Only checking non-null
System.assert(result != null);

// ✅ GOOD: Assert business outcome
System.assertEquals(1, result.size(), 'One record should be returned');
System.assertEquals('Claim Number', result[0].Name, 'Claim name should match');

// ✅ Bulk testing
System.assertEquals(100, result.size(), 'All 100 records should be returned');
```

### 2.6 Test Isolation

```apex
@isTest
public class TriggerHandlerTest {
    
    @isTest(SeeAllData=false)
    static void testWithoutOrgData() {
        // Only uses data from @TestSetup
    }
    
    @isTest(SeeAllData=true)
    static void testWithOrgData() {
        // Can access all org data (use sparingly)
    }
}
```

### 2.7 Code Coverage Checklist

- ✅ All branches of if/else tested
- ✅ All public methods tested
- ✅ Exception paths tested (try/catch)
- ✅ Bulkified logic tested with 200+ records
- ✅ Trigger contexts tested (before insert, after update, etc.)
- ✅ Async jobs validated with `Test.startTest()` / `Test.stopTest()`

---

## 5) CROSS-FRAMEWORK PATTERNS & STANDARDS

### 5.1 Naming & Documentation Standards

**JSDoc Comments for Apex:**
```apex
/**
 * @description Retrieves all active users with a specific profile
 * @author Nagarro
 * @param profileName - The name of the profile to filter by
 * @return List<User> - List of active users
 * @throws AuraHandledException if profile not found
 **/
public static List<User> getUsersByProfile(String profileName) { }
```

**Timestamp Format:**
```apex
@last modified on  : 03-18-2026
@last modified by  : Developer Name
```

### 5.2 Constants & Labels

**Use System Labels for text:**
```apex
// In Apex
String loginProfile = System.Label.COMMUNITY_LOGIN_PROFILE;

// In LWC
import labelName from '@salesforce/label/c.labelApiName';
```

**In-class constants:**
```apex
public class Constants {
    public static final String PROFILE_ADMIN = 'System Administrator';
    public static final String STATUS_ACTIVE = 'Active';
    public static final Integer MAX_QUERY_LIMIT = 50000;
}
```

### 5.3 Sharing Rules

**Default:**
```apex
public with sharing class UserController { }
```

**Exception (requires business justification):**
```apex
public without sharing class SystemUtility { 
    // Justification: System utility needs to bypass sharing for batch jobs
}
```

### 5.4 Suppress PMD Warnings

Only when justified:
```apex
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity')
public class ComplexBusinessLogic { }
```

### 5.5 Deprecated Methods

```apex
@Deprecated
public static void oldMethod() {
    // Use newMethod() instead
}
```

---

## 6) DIRECTORY STRUCTURE

```
force-app/main/default/
├── classes/
│   ├── *Dao.cls                  (Data Access Layer)
│   ├── *Controller.cls          (UI Controllers)
│   ├── *TriggerHandler.cls      (Trigger Handlers)
│   ├── *Helper.cls              (Business Logic)
│   ├── Utility.cls              (Shared Utilities)
│   ├── *Test.cls                         (Unit Tests)
│   └── TestDataFactory.cls      (Test Data)
├── lwc/
│   ├── componentName/
│   │   ├── componentName.js
│   │   ├── componentName.html
│   │   ├── componentName.css
│   │   └── componentName.js-meta.xml
├── pages/
│   ├── *.page                   (PDF/Email Templates)
│   └── *Controller.cls
├── triggers/
│   └── {Object}Trigger.trigger
└── objects/
    └── {CustomObject}/
        ├── fields/
        ├── recordTypes/
        └── validationRules/
```

---

## 7) CHECKLISTS FOR AGENT

### Before creating new Apex class:
- [ ] Is there existing DAO for this object? (Reuse if possible)
- [ ] Does it handle SOQL? → Go to DAO layer
- [ ] Does it handle business logic? → Go to Helper/Service layer
- [ ] Does it handle UI? → Go to Controller layer
- [ ] Bulk-safe? (not in loops)
- [ ] Using DynamicSOQLSelector?
- [ ] Has error logging?
- [ ] Returns Response if controller?

### Before creating new Test class:
- [ ] Uses @TestSetup for shared data?
- [ ] Tests positive case?
- [ ] Tests negative case?
- [ ] Tests edge case?
- [ ] Uses TestDataFactory?
- [ ] Has System.assertEquals assertions?
- [ ] Tests bulk scenarios (200+ records)?

### Before creating LWC:
- [ ] Imports @salesforce/apex/* for Apex calls?
- [ ] Has error handling?
- [ ] Shows spinner/loading state?
- [ ] Validates null/undefined data?
- [ ] Uses @track for reactive properties?
- [ ] Has toast notifications?

### Before creating VF Page:
- [ ] Logic in controller, not page?
- [ ] Uses <apex:outputText> for formatting?
- [ ] Has null checks?
- [ ] No heavy getters?

---

## 8) COMMON IMPORTS & DECLARATIONS

**Apex Commons:**
```apex
import System.AccessLevel;
import System.Type;
import Database.QueryLocator;
import Database.SaveResult;

// Constants
private static final String CLASS_NAME = 'ClassName';
private static final String METHOD_NAME = 'methodName';

// Exception
public class CustomException extends Exception {}
```

**LWC Commons:**
```javascript
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
```

---

## 9) VERSION & MAINTENANCE

**Last Updated:** April 2026  
**Maintained By:** Development Team  
**Current Version:** 2.0

**Key Changes from v1.0:**
- Added comprehensive LWC framework patterns
- Enhanced Visualforce guidelines
- Added PMD compliance standards
- Expanded test data factory documentation
- Added cross-framework patterns section
