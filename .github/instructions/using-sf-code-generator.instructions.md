# SF Claims Code Generator - Agent Usage Guide

**Purpose**: This guide explains how to use the custom SF Code Generator agent for creating production-grade Salesforce artifacts with zero PMD violations.

---

## Quick Start

### Starting the Agent

In GitHub Copilot Chat, type:

```
/sf-code-generator
```

Or describe your intent:
- "Create an Apex service class for claims processing"
- "Generate a test class for ClaimService"
- "Build an LWC component for claim submission"
- "Help me refactor a trigger with PMD violations"

The agent will automatically start the **7-phase workflow**.

---

## The 7-Phase Workflow

```
Phase 1: Requirements Gathering (Ask Questions)
         ↓
Phase 2: Plan Generation (Save plan_framework.md)
         ↓
Phase 3: User Validation (Wait for Approval)
         ↓
Phase 4: Implementation (Create/Modify Files)
         ↓
Phase 5: PMD Scanning (Run sf scanner)
         ↓
Phase 6: Remediation (Fix Violations)
         ↓
Phase 7: Report Results (Show Quality Metrics)
```

---

## PHASE 1: Requirements Gathering

The agent will ask **definite questions** without assumptions. Answer each one clearly.

### Questions You'll Be Asked (In Order)

#### For ALL Requests:

1. **ARTIFACT TYPE**
   - Options: Apex Class | Apex Test Class | LWC Component | Visualforce Page | Flow
   - Example answer: "Apex Service Class"

2. **BUSINESS PURPOSE**
   - What does this component do?
   - Example answer: "Calculate claim settlement amounts based on damage codes and business rules"

3. **RELATED OBJECTS**
   - Which Salesforce objects does it interact with?
   - Example answer: "Claims__c, Equipment__c, Damage_Code__c, Settlement_Rule__c"

4. **NET-NEW VS MODIFICATION**
   - Creating new or modifying existing?
   - If modification: Provide file path and current code snippet

5. **FRAMEWORK REFERENCE CHECK**
   - Have you reviewed the framework patterns?
   - The agent will guide you to: `.github/skills/skills/generating-apex/references/generating-apex-framework-reference.md`

#### For Apex Classes:

6. **CLASS TYPE**
   - Examples: Service | Selector/DAO | Utility | Batch | Queueable | Trigger Handler | Wrapper

7. **SHARING KEYWORD**
   - Options: `with sharing` | `without sharing` | `inherited sharing`
   - Default: `with sharing` (unless you have a business reason for other)

8. **EXTERNAL CALLOUTS**
   - Does it call APIs?
   - If yes: Provide endpoint, HTTP method, and response format

9. **PMD/FLOSUM CONCERNS**
   - Any specific PMD rules you want to focus on?
   - Any known code quality issues to avoid?

#### For LWC Components:

10. **UI INTERACTION PATTERN**
    - Datatable | Form Input | Display Only | Modal | Navigation
    - Example: "Form for claim submission with field validation"

11. **APEX INTEGRATION**
    - Which Apex classes/methods does it call?
    - Example: "CC_ClaimService.submitClaim(claimData)"

12. **ERROR HANDLING**
    - How to show errors: Toast | Modal Dialog | UI Message | Silent Log
    - Example: "Toast notifications for validation errors"

---

## PHASE 2: Plan Generation

The agent creates `.github/plans/plan_framework.md` with:

- ✅ Business requirements summary
- ✅ Framework alignment (Service-Selector pattern, DAO usage, utilities)
- ✅ PMD compliance rules to enforce
- ✅ Flosum deployment checklist
- ✅ Test strategy
- ✅ Implementation checklist

**You will see a message:**

```
✅ Plan Generated: I've created a detailed plan at `.github/plans/plan_framework.md`. 

Please review and confirm:
1. Do the business requirements match your intent?
2. Are the framework patterns and PMD rules correct?
3. Should I proceed with code generation?

Wait for user approval before proceeding.
```

---

## PHASE 3: User Validation

**Read the plan carefully.** Then respond with one of:

- ✅ "Yes, proceed"
- ✅ "Looks good"
- ✅ "Approved, generate the code"
- ✅ "Let's do it"

Or, if changes needed:
- ❌ "Change the business purpose to..."
- ❌ "I need a batch class, not a service class"
- ❌ "Add LWC component alongside the service class"

**The agent will iterate** until you approve.

---

## PHASE 4: Implementation

The agent generates production-ready files:

### For Apex Classes:
```
force-app/main/default/classes/CC_YourService.cls
force-app/main/default/classes/CC_YourService.cls-meta.xml
```

**Generated with:**
- ✅ Service-Selector-Domain pattern
- ✅ Framework utility references (CC_LoggerUtility, CC_DMLUtility)
- ✅ ApexDoc comments (`@param`, `@return`, `@example`)
- ✅ Exception handling with logging
- ✅ Bulk-safe code (no SOQL/DML in loops)
- ✅ Explicit sharing keyword (`with sharing`)

### For Apex Test Classes:
```
force-app/main/default/classes/CC_YourServiceTest.cls
force-app/main/default/classes/CC_YourServiceTest.cls-meta.xml
```

**Generated with:**
- ✅ @TestSetup with CC_TestDataFactory
- ✅ Given/When/Then structure
- ✅ Positive + negative + bulk test methods
- ✅ Assertions with failure messages
- ✅ 90%+ code coverage

### For LWC Components:
```
force-app/main/default/lwc/cc_yourComponentName/cc_yourComponentName.js
force-app/main/default/lwc/cc_yourComponentName/cc_yourComponentName.html
force-app/main/default/lwc/cc_yourComponentName/cc_yourComponentName.css
force-app/main/default/lwc/cc_yourComponentName/cc_yourComponentName.js-meta.xml
```

---

## PHASE 5: PMD Scanning

The agent **automatically runs** the PMD scanner for Apex classes:

```bash
sf scanner run --target="./**/CC_YourService.cls" --outfile="ResultApex.csv"
```
The agent **automatically runs** the PMD scanner for JS component inside LWC:

```bash
sf scanner run --target="./**/yourComponentName.js" --outfile="ResultLWC.csv"
```

**You will see results:**

```
📊 PMD Scan Results for CC_YourService.cls
- Total Issues: 0 ✅
- Critical (Sev 0/1): 0
- Major (Sev 2): 0
- Minor (Sev 3): 0
```

Or, if violations found:

```
📊 PMD Scan Results for CC_YourService.cls
- Total Issues: 3 ⚠️
- Critical (Sev 0/1): 0
- Major (Sev 2): 2 — ExcessiveMethodLength (line 45)
- Minor (Sev 3): 1 — Naming Convention (line 120)
```

---

## PHASE 6: Remediation (If Violations Found)

If PMD violations detected, the agent **automatically fixes** them:

| Violation | Auto-Fix |
|-----------|----------|
| **ExcessiveMethodLength** (>400 lines) | Extract helpers: Split method into 2-3 smaller methods |
| **CyclomaticComplexity** (>10 branches) | Extract conditional logic: Move if/else chains into helper methods |
| **ExcessiveParameterList** (>7 params) | Create wrapper: Group params into DTO/wrapper class |
| **AvoidDmlStatementsInLoops** | Batch DML: Move DML outside loop or use Database.executeBatch() |
| **AvoidSoqlStatementsInLoops** | Optimize query: Query once before loop, use Map<Id, SObject> |
| **Naming Convention** | Rename: Change `MyMethod` → `myMethod`, `MY_VAR` → `myVar` |
| **UnusedLocalVariable** | Remove unused variables |
| **AvoidDebugStatements** | Replace: Use CC_LoggerUtility.addApexErrorLog() |
| **ApexDoc Missing** | Add documentation: Include @param, @return, @example |

The agent **re-scans** until violations are 0.

---

## PHASE 7: Report Results

Final report shows:

```
✨ Code Generation Complete

Artifact: CC_ClaimProcessingService
File Path: force-app/main/default/classes/CC_ClaimProcessingService.cls
Status: ✅ PRODUCTION_READY

Metrics:
- Lines of Code: 287
- Methods: 8 (3 public, 5 private)
- Test Coverage: 92%
- ApexDoc Comments: ✅ Complete

Quality Gates:
✅ PMD Scan: 0 violations
✅ Flosum Rules: Compliant
✅ Framework Alignment: Yes
✅ Sharing Rule Declared: with sharing
✅ Error Handling: Integrated with CC_LoggerUtility

Generated Files:
- ✅ CC_ClaimProcessingService.cls (287 lines)
- ✅ CC_ClaimProcessingService.cls-meta.xml
- ✅ CC_ClaimProcessingServiceTest.cls (410 lines, 92% coverage)
- ✅ CC_ClaimProcessingServiceTest.cls-meta.xml

Next Steps:
1. Review code for business logic correctness
2. Deploy to dev: sf project deploy start --source-dir="force-app/..."
3. Run tests: sf apex run test --class-names=CC_ClaimProcessingServiceTest
4. Flosum will validate deployment risk in CI/CD
```

---

## Reference Documents

The agent **always references** these framework files:

### For Apex:
- 📖 `.github/skills/skills/generating-apex/references/framework_Reference.md`
  - § 1.3: Dynamic SOQL DAO Pattern (5 detailed examples)
  - § 1.8: Utility Classes - Comprehensive Reference
    - CC_LoggerUtility (error logging)
    - CC_DMLUtility (bulk DML with logging)
    - CC_EmailUtility (email with attachments)
    - CC_BusinessRulesUtility (business rule evaluation)
  - § 1.9: Common Usage Patterns

### For Tests:
- 📖 `.github/skills/skills/generating-apex-test/references/generating-apex-test-framework-reference.md`

### For PMD Rules:
- 📖 `.github/references/pmd-static-ruleset.xml`
  - Critical rules: No SOQL/DML in loops, CRUD checks, sharing enforcement
  - Code quality: Complexity limits, naming conventions, documentation

### For Plans:
- 📖 `.github/plans/plan_framework.md`
  - Use as template for code generation plans

---

## Common Examples

### Example 1: Create a Service Class

```
User: Create an Apex service class for claim settlement calculation

Agent: 🎯 Phase 1: Requirements Gathering
  ❓ What is the primary business objective?
  → Calculate claim settlement based on damage codes and business rules
  
  ❓ Which SObjects does this interact with?
  → Claims__c, Equipment__c, Damage_Codes__c, Settlement_Rules__c
  
  ❓ Is this net-new or modification?
  → Net-new
  
  ❓ Should this use 'with sharing', 'without sharing', or 'inherited sharing'?
  → with sharing (default, for data security)
  
  ❓ Does it make external API calls?
  → No

Agent: 📋 Phase 2: Plan Generated
  ✅ Plan saved to .github/plans/plan_framework.md
  
  Highlights:
  - Service class pattern with private selector method
  - Uses CC_ClaimSelector for SOQL
  - Delegates DML to CC_DMLUtility with error logging
  - Returns CC_Response wrapper
  - Test class with 251+ record bulk testing
  - PMD compliance: 0 violations target

User: Yes, proceed

Agent: ⚙️ Phase 4: Implementation
  ✅ Generated CC_ClaimSettlementService.cls
  ✅ Generated CC_ClaimSettlementServiceTest.cls

Agent: 🔍 Phase 5: PMD Scanning
  📊 Results: Total Issues: 0 ✅

Agent: ✨ Phase 7: Report Results
  Status: ✅ PRODUCTION_READY
  PMD: 0 violations
  Coverage: 91%
```

### Example 2: Fix PMD Violations in Existing Class

```
User: I have PMD violations in my ClaimProcessor class. Fix them.

Agent: 🎯 Phase 1: Requirements
  ❓ Can you provide the file path and current violations?
  → force-app/main/default/classes/ClaimProcessor.cls
  → Violations: ExcessiveMethodLength (line 180), CyclomaticComplexity (line 45)

Agent: 📋 Phase 2: Plan
  ✅ Will extract helper methods and reduce complexity

Agent: ⚙️ Phase 4: Implementation
  ✅ Refactored ClaimProcessor.cls
  ✅ Extracted helper method: validateClaimInputs()
  ✅ Extracted helper method: calculateSettlement()
  ✅ Reduced method length from 450 → 280 lines
  ✅ Reduced cyclomatic complexity from 18 → 9

Agent: 🔍 Phase 5: PMD Scanning
  📊 Results: Total Issues: 0 ✅

Agent: ✨ Phase 7: Report
  Status: ✅ REFACTORING_COMPLETE
  PMD Violations Before: 2 → After: 0 ✅
```

---

## When to Use This Agent

✅ **Use this agent for:**
- Creating new Apex classes (services, DAOs, batch jobs)
- Generating Apex test classes with full coverage
- Building new LWC components
- Refactoring code with PMD violations
- Creating Visualforce pages
- Designing Flows

❌ **Do NOT use for:**
- General Salesforce questions (use default agent)
- Debugging runtime errors (use default agent + troubleshooting)
- Non-Salesforce code

---

## Troubleshooting

### Issue: "Agent is not applying framework patterns"

**Solution**: Make sure in Phase 1 you confirmed reading the framework reference. The agent's Phase 4 *depends on* the framework being understood.

### Issue: "PMD violations still appearing after Phase 6"

**Solution**: This shouldn't happen. The agent iterates until 0 violations. If it does, provide the violation details and the agent will attempt another round of remediation.

### Issue: "I need to change something mid-Generation"

**Solution**: Stop the agent and start a new request. The agent will re-gather requirements and create a new plan.

---

## Key Benefits

✅ **No Assumptions**: Every requirement is asked, not inferred  
✅ **Plan Before Code**: You see architecture before implementation  
✅ **PMD-First**: Rules enforced from typing, not added retrospectively  
✅ **Automated Quality Gates**: Scanner runs automatically, violations fixed automatically  
✅ **Framework-Aligned**: Every artifact uses documented patterns  
✅ **Full Coverage**: Tests generated with 90%+ coverage out of the box  
✅ **Production-Ready**: No post-generation cleanup needed  

---

## Getting Help

- Framework questions? Read `.github/skills/skills/generating-apex/references/framework_Reference.md`
- PMD questions? Read `.github/references/pmd-static-ruleset.xml`
- Test patterns? Read `.github/skills/skills/generating-apex-test/references/generating-apex-test-framework-reference.md`
- Usage questions? Read this guide

