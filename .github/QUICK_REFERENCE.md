# 🚀 SF Code Generator - Quick Reference Card

**Print this or bookmark it for quick reference**

---

## STARTING THE AGENT

```
/sf-code-generator
```

---

## THE 7-PHASE WORKFLOW

| Phase | What Happens | What You Do |
|-------|--------------|-----------|
| 1️⃣ **Questions** | Agent asks definite questions about requirements | Answer clearly (no assumptions) |
| 2️⃣ **Plan** | Plan saved to `.github/plans/plan_framework.md` | Read, verify accuracy |
| 3️⃣ **Approval** | Agent waits for confirmation | Say "Yes" or "Approved" |
| 4️⃣ **Code** | Agent generates `.cls`, `.js`, `.xml` files | Review generated code |
| 5️⃣ **PMD Scan** | Agent runs: `sf scanner run --pmdconfig=...` | View violation count |
| 6️⃣ **Fix** | Agent fixes violations iteratively | Automated - you wait |
| 7️⃣ **Report** | Final report with metrics | Deploy to dev org |

---

## QUESTIONS IN PHASE 1

### For ALL Artifact Types:
1. Type? (Apex / LWC / VF / Flow / Test)
2. Business purpose?
3. Related objects? (Claims__c, Equipment__c, etc.)
4. Net-new or modification?
5. Framework reference reviewed? (Yes/No)

### For Apex Classes:
6. Class type? (Service / DAO / Batch / Queueable / Utility / etc.)
7. Sharing? (with sharing / without sharing)
8. External APIs? (Yes/No + details)
9. PMD concerns?

### For LWC Components:
10. UI pattern? (Form / Datatable / Modal / Display)
11. Apex integration? (which classes/methods)
12. Error display? (Toast / Modal / Message / Silent)

---

## KEY FRAMEWORK REFERENCES

| Reference | Location | Key Info |
|-----------|----------|----------|
| **Utilities** | `generating-apex-framework-reference.md` § 1.8 | LoggerUtility, DMLUtility, EmailUtility |
| **DAO Pattern** | `generating-apex-framework-reference.md` § 1.3 | 5 examples: single record, filtering, FieldSets, batch, service layer |
| **Common Patterns** | `generating-apex-framework-reference.md` § 1.9 | Bulk ops, email batch notifications |
| **PMD Rules** | `.github/references/pmd-static-ruleset.xml` | 13 rules enforced (loops, complexity, naming, etc.) |
| **Test Pattern** | `generating-apex-test-framework-reference.md` | TestDataFactory, given/when/then, bulk testing |
| **User Guide** | `.github/instructions/using-sf-code-generator.instructions.md` | Complete usage examples |

---

## WHAT YOU'LL GET

### For Apex Service Class:
```
CC_YourService.cls (with ApexDoc, no hardcoded IDs)
CC_YourService.cls-meta.xml (API 66.0)
CC_YourServiceTest.cls (90%+ coverage)
CC_YourServiceTest.cls-meta.xml
```

### For LWC Component:
```
lwc/yourComponent/yourComponent.js (with error handling)
lwc/yourComponent/yourComponent.html (modular templates)
lwc/yourComponent/yourComponent.css
lwc/yourComponent/yourComponent.js-meta.xml
```

### Generated Artifacts Always Include:
✅ Framework patterns (Service-Selector, DAO, Utilities)  
✅ ApexDoc comments  
✅ Error logging via CC_LoggerUtility  
✅ Explicit sharing keywords  
✅ No hardcoded IDs (use Custom Metadata)  
✅ PMD compliant (0 violations)  
✅ Tests with 90%+ coverage  

---

## PMD VIOLATION QUICK-FIX

If you see violations during scanning:

| Violation | Quick Fix |
|-----------|-----------|
| **SOQL in loop** | Query once before loop → use `Map<Id, SObject>` |
| **DML in loop** | Batch outside loop or `Database.executeBatch()` |
| **Cyclomatic Complexity >10** | Extract nested if/else into private helper method |
| **Method too long >400 lines** | Split into 2-3 smaller methods |
| **Too many parameters >7** | Create wrapper/DTO class to group params |
| **Naming convention** | Use: Class=PascalCase, method=camelCase, constant=UPPER_SNAKE |
| **No ApexDoc** | Add: `@param`, `@return`, `@example` comments |
| **System.debug()** | Replace with `CC_LoggerUtility.addApexErrorLog()` |
| **Hardcoded ID** | Use `Custom Metadata`, `Label`, or `describe()` call |
| **CRUD check missing** | Add `WITH USER_MODE` to SOQL or `isReadable()` check |

**The agent fixes these automatically** ✅

---

## DEPLOYMENT CHECKLIST

After Phase 7 report, deploy with:

```bash
# Deploy the class(es)
sf project deploy start \
  --source-dir="force-app/main/default/classes/CC_YourService.cls" \
  --target-org=dev

# Run tests
sf apex run test \
  --class-names=CC_YourServiceTest \
  --code-coverage \
  --target-org=dev

# Flosum rules will validate in CI/CD
```

---

## FRAMEWORK PATTERNS CHEATSHEET

### Service Class Structure
```apex
public with sharing class CC_YourService {
    // Use private selector/DAO for SOQL
    private static CC_YourSelector selector = new CC_YourSelector();
    
    // Public method: business logic
    public static CC_Response processData(List<SObject> records) {
        try {
            // Validate inputs
            // Query: delegate to selector
            // Logic: business rules
            // DML: use CC_DMLUtility
            return new CC_Response(true, results, 'Success');
        } catch (Exception ex) {
            CC_LoggerUtility.addApexErrorLog(className, methodName, params, ex);
            return new CC_Response(false, null, ex.getMessage());
        }
    }
}
```

### Utility Usage
```apex
// Error logging
CC_LoggerUtility.addApexErrorLog('ClassName', 'methodName', 'params', ex);

// Bulk DML
ParamsDMLUtility params = new ParamsDMLUtility();
params.records = recordsToUpdate;
params.sourceClassMethod = 'ClassName~methodName';
Database.SaveResult[] results = CC_DMLUtility.updateRecords(params);

// Email with attachment
EmailRequestWrapper emailReq = new EmailRequestWrapper();
emailReq.templateDeveloperName = 'Template_Name';
emailReq.toEmailIdList = new List<String>{ 'user@company.com' };
Messaging.SingleEmailMessage email = CC_EmailUtility.sendVisualForceTemplateEmail(emailReq);
```

---

## WHEN TO USE

✅ Do use for:
- Creating Apex classes/tests
- Building LWC components
- Generating Visualforce pages
- Refactoring PMD violations
- Implementing Flows

❌ Don't use for:
- General Salesforce questions
- Runtime debugging
- Non-Salesforce code

---

## TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| Agent asks same question | Give more specific answer |
| PMD violations persist | Agent retries; if stuck, ask agent for details |
| Framework not loading | Check `framework_Reference.md` exists at `generating-apex/references/` |
| Test coverage <85% | Agent will ask for more test cases |
| Flosum fails | Check custom field types and API version |

---

## KEY DOCUMENTS

📖 **To Get Started**: Read `.github/instructions/using-sf-code-generator.instructions.md`

📖 **For Framework Guidance**: Read `framework_Reference.md` § 1.3, 1.8, 1.9

📖 **For PMD Rules**: Read `.github/references/pmd-static-ruleset.xml`

📖 **For Setup Details**: Read `.github/AGENT_SETUP_COMPLETE.md`

---

## SUCCESS CHECKLIST

✅ Agent created  
✅ PMD ruleset in place  
✅ Framework enhanced with utilities  
✅ Skills integrated  
✅ Plan template ready  
✅ User guide available  
✅ Ready to generate code  

**Status**: 🚀 READY TO USE

---

**Pro Tips**:
1. Always read the generated plan before approving
2. The agent fixes PMD violations automatically - you just wait
3. Framework references are always consulted - no additional setup needed
4. Test classes are generated automatically with your service classes
5. All code is deployment-ready out of the box

---

**Questions?** See `.github/instructions/using-sf-code-generator.instructions.md` (complete user guide)

