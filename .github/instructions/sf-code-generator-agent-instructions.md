# Salesforce Code Generator - Agent Usage Guide

**Purpose**: This guide explains how to use the streamlined Salesforce Code Generator agent for creating production-grade Salesforce artifacts with PMD validation.

---

## Quick Start

### Starting the Agent

In GitHub Copilot Chat, type:

```
/salesforce-code-generator
```

Or describe your intent:
- "Create an Apex service class for claims processing"
- "Generate a test class for Service"
- "Build an LWC component for claim submission"

The agent will automatically start the **4-step workflow** with progress updates.

---

## The 4-Step Workflow

```
Step 1: Understand Requirement 📋
         ↓
Step 2: Generate Code ⚙️
         ↓
Step 3: Run PMD Scan 🔍
         ↓
Step 4: Validate Against Ruleset ✅
```

---

## STEP 1: Understand Requirement

The agent automatically analyzes your request to extract:

### What the Agent Detects:

1. **ARTIFACT TYPE**
   - Apex Class | Apex Test Class | LWC Component | Visualforce Page

2. **BUSINESS PURPOSE**
   - What the component does

3. **RELATED OBJECTS**
   - Which Salesforce objects it interacts with

4. **CREATION TYPE**
   - Net-new creation or modification of existing code

**You'll see:**

```
📋 Step 1/4: Understanding Requirement
✓ Artifact type: Apex Service Class
✓ Business purpose: Calculate claim settlement amounts
✓ Target objects: s__c, Equipment__c
```

**The agent only asks questions if critical information is missing.**

---

## STEP 2: Generate Code

The agent creates production-ready files with framework patterns.

**You'll see:**

```
⚙️ Step 2/4: Generating Code
→ Creating Service.cls...
✓ Created: Service.cls (287 lines)
✓ Created: Service.cls-meta.xml
✓ Framework patterns applied
```


### For Apex Classes:
```
force-app/main/default/classes/YourService.cls
force-app/main/default/classes/YourService.cls-meta.xml
```

**Generated with:**
- ✅ Service-Selector-Domain pattern
- ✅ Framework utility references (LogFactory, DMLUtility)
- ✅ ApexDoc comments (`@param`, `@return`, `@example`)
- ✅ Exception handling with logging
- ✅ Bulk-safe code (no SOQL/DML in loops)
- ✅ Explicit sharing keyword (`with sharing`)

### For Apex Test Classes:
```
force-app/main/default/classes/YourServiceTest.cls
force-app/main/default/classes/YourServiceTest.cls-meta.xml
```

**Generated with:**
- ✅ @TestSetup with TestDataFactory
- ✅ Given/When/Then structure
- ✅ Positive + negative + bulk test methods (251+ records)
- ✅ Assertions with failure messages
- ✅ 90%+ code coverage

### For LWC Components:
```
force-app/main/default/lwc/yourComponentName/yourComponentName.js
force-app/main/default/lwc/yourComponentName/yourComponentName.html
force-app/main/default/lwc/yourComponentName/yourComponentName.css
force-app/main/default/lwc/yourComponentName/yourComponentName.js-meta.xml
```

---

## STEP 3: Run PMD Scan

The agent **automatically runs** the PMD scanner using the configured ruleset.

**You'll see:**

```
🔍 Step 3/4: Running PMD Scan
→ Scanning Apex files...
✓ PMD scan complete - 1 file scanned
```

**Commands executed:**

For Apex classes:
```bash
sf scanner run --target="./**/YourService.cls" --format=csv --outfile="ResultApex.csv"
```

For LWC components:
```bash
sf scanner run --target="./**/lwc/**/*.js" --category=eslint --format=csv --outfile="ResultLWC.csv"
```

---

## STEP 4: Validate Against Ruleset

The agent validates generated code against `.github/references/pmd-static-ruleset.xml`.

**You'll see:**

```
✅ Step 4/4: Validating Against pmd-static-ruleset.xml
→ Analyzing violations...
```

**Final report shows:**

```
## ✅ Generation Complete

**Files Created:**
- [ProcessingService.cls](force-app/main/default/classes/ProcessingService.cls)
- [ProcessingService.cls-meta.xml](force-app/main/default/classes/ProcessingService.cls-meta.xml)

## PMD Validation Results

### Apex Files:
- **ProcessingService.cls**: ✅ Clean (0 violations)

## Validation Summary
✓ Total files generated: 2
✓ Files passing PMD: 1
✓ Violations found: 0

🎉 All generated code passed PMD validation with 0 violations!
```

Or, if violations found:

```
## PMD Validation Results

### Apex Files:
- **ProcessingService.cls**: ⚠️ 3 violations
  - Critical: 0
  - Major: 2 — ExcessiveMethodLength (line 45)
  - Minor: 1 — Naming Convention (line 120)

## Validation Summary
✓ Total files generated: 2
✓ Files passing PMD: 0
⚠️ Violations found: 3

### Violations Needing Attention:
1. **ExcessiveMethodLength** (Line 45): Method exceeds 400 lines
   - Suggested fix: Extract helper methods
2. **MethodNamingConventions** (Line 120): Method name should use camelCase
   - Suggested fix: Rename MyMethod → myMethod
```

---

## Progress Tracking

Throughout execution, you'll see live progress updates:

```
📋 Step 1/4: Understanding Requirement
✓ Completed

⚙️ Step 2/4: Generating Code
→ In progress...
✓ Completed

🔍 Step 3/4: Running PMD Scan
→ In progress...
✓ Completed

✅ Step 4/4: Validating Against Ruleset
→ In progress...
✓ Completed
```

---

## Reference Documents

The agent **references** these framework files during code generation:

### For Apex:
- 📖 `.github/skills/skills/generating-apex/references/generating-apex-framework-reference.md`
  - § 1.3: Dynamic SOQL DAO Pattern
  - § 1.8: Utility Classes (LogFactory, DMLUtility)
  - § 1.9: Common Usage Patterns

### For Tests:
- 📖 `.github/skills/skills/generating-apex-test/references/generating-apex-test-framework-reference.md`

### For PMD Rules:
- 📖 `.github/references/pmd-static-ruleset.xml`
  - Critical rules: No SOQL/DML in loops, CRUD checks, sharing enforcement
  - Code quality: Complexity limits, naming conventions

---

## Common Examples

### Example 1: Create a Service Class

```
User: Create an Apex service class for claim settlement calculation

Agent: 
📋 Step 1/4: Understanding Requirement
✓ Artifact type: Apex Service Class
✓ Business purpose: Calculate claim settlement
✓ Target objects: s__c, Equipment__c

⚙️ Step 2/4: Generating Code
→ Creating SettlementService.cls...
✓ Created: SettlementService.cls (287 lines)
✓ Created: SettlementService.cls-meta.xml

🔍 Step 3/4: Running PMD Scan
→ Scanning Apex files...
✓ PMD scan complete

✅ Step 4/4: Validating Against pmd-static-ruleset.xml
→ Analyzing violations...

## ✅ Generation Complete
PMD Validation: 0 violations ✅
```

### Example 2: Create an LWC Component

```
User: Build an LWC component for claim submission form

Agent:
📋 Step 1/4: Understanding Requirement
✓ Artifact type: LWC Component
✓ Business purpose:  submission form
✓ Target objects: s__c

⚙️ Step 2/4: Generating Code
→ Creating claimSubmissionForm...
✓ Created: claimSubmissionForm.js
✓ Created: claimSubmissionForm.html
✓ Created: claimSubmissionForm.js-meta.xml
✓ Created: claimSubmissionForm.css

🔍 Step 3/4: Running PMD Scan
→ Scanning LWC files...
✓ PMD scan complete

✅ Step 4/4: Validating Against pmd-static-ruleset.xml
→ Analyzing violations...

## ✅ Generation Complete
PMD Validation: 0 violations ✅
```

---

## When to Use This Agent

✅ **Use this agent for:**
- Creating new Apex classes (services, DAOs, batch jobs)
- Generating Apex test classes with full coverage
- Building new LWC components
- Creating Visualforce pages

❌ **Do NOT use for:**
- General Salesforce questions (use default agent)
- Debugging runtime errors (use default agent)
- Non-Salesforce code

---

## PMD Ruleset Overview

**Critical Rules from `.github/references/pmd-static-ruleset.xml`:**

| Rule | Threshold | Impact |
|------|-----------|--------|
| **AvoidDmlStatementsInLoops** | 0 violations | Critical |
| **AvoidSoqlInLoops** | 0 violations | Critical |
| **CyclomaticComplexity** | Max 10 per method | Major |
| **ExcessiveParameterList** | Max 3 parameters | Major |
| **ExcessiveMethodLength** | Max 400 lines | Major |
| **ExcessiveClassLength** | Max 1000 lines | Major |
| **ClassNamingConventions** | PascalCase | Minor |
| **MethodNamingConventions** | camelCase | Minor |

---

## Key Benefits

✅ **Streamlined Process**: 4 steps only - no unnecessary phases  
✅ **Progress Visibility**: See live updates at each step  
✅ **Smart Defaults**: Framework patterns applied automatically  
✅ **PMD-First**: Rules validated from pmd-static-ruleset.xml  
✅ **Automated Scanning**: PMD runs automatically after generation  
✅ **Framework-Aligned**: Every artifact uses documented patterns  
✅ **Production-Ready**: No post-generation cleanup needed  

---

## Getting Help

- Framework questions? Read `.github/skills/skills/generating-apex/references/generating-apex-framework-reference.md`
- PMD questions? Read `.github/references/pmd-static-ruleset.xml`
- Test patterns? Read `.github/skills/skills/generating-apex-test/references/generating-apex-test-framework-reference.md`
- Usage questions? Read this guide

