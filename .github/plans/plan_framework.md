# Code Generation Plan - [ARTIFACT_NAME]

**Date**: [TODAY_DATE]  
**Agent**: SF Code Generator  
**Status**: PENDING_APPROVAL  

---

## 1. ARTIFACT DETAILS

| Field | Value |
|-------|-------|
| **Artifact Type** | [Apex Service / LWC Component / Test Class / VF Page / Flow] |
| **File Path** | [e.g., force-app/main/default/classes/CC_YourService.cls] |
| **Net-New or Modification** | [New / Modification] |
| **Related Existing Files** | [If modification, list related files] |

---

## 2. BUSINESS REQUIREMENTS

### Purpose Statement
[What is the primary business objective? 2-3 sentences.]

### Related Salesforce Objects
[List SObjects: Claims__c, Equipment__c, Customer__c, etc.]

### External Dependencies
[External APIs, third-party services, integration endpoints, or "None" if self-contained]

### User Roles Affected
[Who will use this? e.g., Claims processors, Admin, System]

---

## 3. FUNCTIONAL REQUIREMENTS

### Primary Features
- [ ] Requirement 1: [Description]
- [ ] Requirement 2: [Description]
- [ ] Requirement 3: [Description]

### Acceptance Criteria
1. When [condition], then [expected result]
2. When [condition], then [expected result]
3. When [condition], then [expected result]

### Known Constraints
- [Constraint 1: e.g., "Must complete within 5 seconds"]
- [Constraint 2: e.g., "Cannot exceed 100 SOQL queries"]
- [Constraint 3]

---

## 4. TECHNICAL ARCHITECTURE

### Pattern & Framework Alignment

| Aspect | Selection | Framework Reference |
|--------|-----------|-------------------|
| **Architecture Pattern** | Service / Selector / Domain / Utility / Wrapper | [Link to section in framework_Reference.md] |
| **Sharing Rule** | with sharing / without sharing / inherited sharing | [Justification if "without sharing"] |
| **Utility Classes** | CC_LoggerUtility, CC_DMLUtility, CC_EmailUtility, etc. | § 1.8 framework_Reference.md |
| **DAO/Selector Pattern** | Use CC_DynamicSOQLSelector or existing DAO | § 1.3 framework_Reference.md |
| **Response Wrapper** | CC_Response wrapper for Apex returns | § 1.2 framework_Reference.md |
| **Error Handling** | Try/catch with logging via CC_LoggerUtility | § 1.8 framework_Reference.md |

### High-Level Design
[Provide 3-5 bullet points describing the approach, method signatures, and key logic flow]

**Example for Service Class:**
- Public method `processClaimPayment(Id claimId)` validates claim and calculates payment
- Delegates SOQL to `CC_ClaimSelector.getClaimById(claimId)`
- Delegates DML updates to `CC_DMLUtility.updateRecords(params)` with error logging
- Returns `CC_Response` with success/failure status and message
- All errors logged via `CC_LoggerUtility.addApexErrorLog()`

### Class Type (if Apex)
- [ ] Service Class (business logic, orchestration)
- [ ] Selector/DAO (SOQL queries only)
- [ ] Batch Apex (process 200+ records)
- [ ] Queueable (async jobs with chaining)
- [ ] Schedulable (recurring jobs)
- [ ] Trigger Handler (event routing)
- [ ] Utility (reusable helpers)
- [ ] Wrapper/DTO (data transfer)
- [ ] Test Class (unit test)
- [ ] Other: ..................

---

## 5. CODE QUALITY & PMD COMPLIANCE

### Target PMD Rules
Compliance with `.github/references/pmd-static-ruleset.xml`:

| Rule | Threshold | Approach |
|------|-----------|----------|
| **CyclomaticComplexity** | ≤ 10 per method | Extract helper methods if logic exceeds threshold |
| **ExcessiveClassLength** | ≤ 1000 lines | Keep classes focused; split into multiple classes if needed |
| **ExcessiveMethodLength** | ≤ 400 lines | Extract logical sections into private helpers |
| **ExcessiveParameterList** | ≤ 7 parameters | Use wrapper object/DTO if >7 params needed |
| **AvoidDmlStatementsInLoops** | ✅ No DML in loops | Batch DML outside loops or use Database.executeBatch() |
| **AvoidSoqlStatementsInLoops** | ✅ No SOQL in loops | Query once before loop; use Map<Id, SObject> for lookups |
| **ClassNamingConventions** | PascalCase | CC_MyService (not cc_myservice) |
| **MethodNamingConventions** | camelCase | myMethod(), getAccounts() (not MyMethod() or GET_ACCOUNTS()) |
| **AvoidDebugStatements** | ✅ No System.debug() | Use CC_LoggerUtility for structured logging |
| **ApexCRUDViolation** | ✅ CRUD checks required | Include WITH USER_MODE or isReadable() checks |
| **ApexSharingViolations** | ✅ Sharing keyword required | Explicit with sharing / without sharing declaration |
| **UnusedLocalVariable** | ✅ No dead code | Remove unused variables |
| **ApexDoc** | Required on public methods | Document @param, @return, @throws, @example |

### Flosum Compliance
- **Metadata Type**: [Class / Component / VFPage / Flow]
- **API Version**: 66.0 (minimum)
- **Deployment Risk Level**: Low / Medium / High
- **Custom Fields Referenced**: [List custom fields or "None"]
- **Security Considerations**: [CRUD checks, sharing enforcement, PII handling, etc.]

### Known PMD Suppressions (if any)
[Document if suppressions are required, with justification]

```apex
@SuppressWarnings('PMD.ExcessiveParameterList')
// Justification: This method must accept these 10 parameters for backward compatibility with legacy integrations.
public void legacyMethod(String p1, String p2, String p3, ...) {
```

---

## 6. TEST STRATEGY

### Unit Test Scope
- **Test Class**: CC_YourServiceTest.cls
- **Coverage Target**: 90%+ (75% minimum for deploy)
- **Test Data Factory**: Use CC_TestDataFactory for record creation

### Test Scenarios
- [ ] Positive scenario 1: [Description]
- [ ] Positive scenario 2: [Description]
- [ ] Negative scenario 1: [Error condition, e.g., "When input is null"]
- [ ] Edge case 1: [Boundary condition, e.g., "When record count = 251"]
- [ ] Bulk scenario: Test with 251+ records (crosses trigger batch boundary)
- [ ] Exception handling: Verify error logging via integration with CC_LoggerUtility

### Mocking Strategy
- [ ] Mock HTTP callouts? (if yes: provide endpoint URL and response structure)
- [ ] Mock external system? (if yes: describe mock behavior)
- [ ] Use System.runAs() for CRUD/sharing validation? (if yes: describe user persona)

---

## 7. IMPLEMENTATION CHECKLIST

### Before Code Generation
- [ ] Business requirements approved by stakeholder
- [ ] Framework patterns understood and reviewed
- [ ] PMD rules read and acknowledged
- [ ] Test scope consensus achieved
- [ ] Flosum deployment risk documented

### Code Generation Phase
- [ ] {ClassName}.cls generated with ApexDoc
- [ ] {ClassName}.cls-meta.xml created (API version 66.0)
- [ ] Framework patterns applied (Service-Selector, DAO, Error logging, etc.)
- [ ] All utility class references verified (CC_LoggerUtility, CC_DMLUtility, etc.)
- [ ] Sharing keyword declared explicitly
- [ ] Hard stops verified (no SOQL/DML in loops, bind variables, exception handling)

### PMD Scanning Phase
- [ ] `sf scanner run --target="./**/classname1.cls, ./**/classname2.cls"` executed
- [ ] PMD violations count displayed (target: 0)
- [ ] Violations remediated (if any)
- [ ] Re-scanned until clean

### Test Generation Phase (if test class)
- [ ] {ClassName}Test.cls generated using CC_TestDataFactory
- [ ] @TestSetup created for reusable test data
- [ ] Positive test methods generated (Given/When/Then structure)
- [ ] Negative test methods generated (exception scenarios)
- [ ] Bulk scenario tests (251+ records) included
- [ ] Assertions include failure messages
- [ ] Test class passes `sf apex run test`
- [ ] Coverage report shows 90%+ coverage

### Flosum Validation Phase
- [ ] Flosum rules validating deployment risk
- [ ] Custom field references documented
- [ ] CRUD/FLS enforcement verified (if sensitive data)
- [ ] Security controls documented

---

## 8. APPROVAL & ACCEPTANCE

### For User Review

> **Please confirm the following before code generation proceeds:**
>
> 1. ✅ Business requirements match your intent?
> 2. ✅ Architecture and framework patterns correct?
> 3. ✅ PMD and Flosum compliance rules understood?
> 4. ✅ Test strategy sufficient?
>
> **Approved?** Please respond with "Yes" or "Approved" to proceed, or describe changes needed.

---

## 9. EXECUTION SUMMARY (Filled After Generation)

### Generated Artifacts
- ✅ [ClassName].cls (Service, Selector, etc.) - [X lines]
- ✅ [ClassName].cls-meta.xml
- ✅ [ClassName]Test.cls - [Y lines, Coverage: Z%]
- ✅ [ClassName]Test.cls-meta.xml

### Quality Metrics
- **PMD Violations**: 0 ✅
- **Code Coverage**: [Z%] ✅
- **Test Pass Rate**: 100% ✅
- **Flosum Risk Level**: Low/Medium/High
- **Deployment Ready**: ✅ YES

### Deployment Instructions
```bash
# Deploy to dev org
sf project deploy start --source-dir="force-app/main/default/classes/CC_YourService.cls" --target-org=dev

# Run tests
sf apex run test --class-names=CC_YourServiceTest --target-org=dev

# Validate in CI/CD
# Flosum will validate against deployment rules
```

---

**Plan Status**: ⏳ PENDING_APPROVAL → ✅ APPROVED → 🔧 IMPLEMENTATION → 🧪 TESTING → ✅ COMPLETE

