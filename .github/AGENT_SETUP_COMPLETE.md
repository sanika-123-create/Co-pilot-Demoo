# SF Code Generator - Setup & Integration Complete ✅

**Date**: April 26, 2026  
**Agent**: SF Claims Code Generator  
**Status**: FULLY CONFIGURED AND READY TO USE

---

## What Was Set Up

### 1. Custom Agent File ✅
**File**: `.github/agents/sf-code-generator.agent.md`

**Includes**:
- ✅ 7-phase workflow (Requirements → Plan → Approval → Implementation → PMD Scan → Remediation → Report)
- ✅ Questionnaire structure for gathering all requirements upfront
- ✅ Plan generation framework saved to `.github/plans/plan_framework.md`
- ✅ Integration with framework references
- ✅ Automated PMD scanning with `sf scanner run` commands
- ✅ PMD remediation logic for fixing violations
- ✅ Final report with quality metrics

### 2. PMD Static Ruleset ✅
**File**: `.github/references/pmd-static-ruleset.xml`

**Enforces**:
- ✅ Critical rules: No SOQL/DML in loops, CRUD checks, sharing enforcement
- ✅ Design rules: Complexity limits (cyclomatic ≤10), class length (≤1000), parameters (≤7)
- ✅ Naming conventions: PascalCase classes, camelCase methods
- ✅ Security: ApexCRUDViolation, ApexSharingViolations, ApexInsecureEndpoint
- ✅ Performance: AvoidDmlStatementsInLoops, AvoidSoqlStatementsInLoops
- ✅ Quality: UnusedLocalVariable, EmptyIfStmt, ApexDoc requirements
- ✅ JavaScript/ESLint rules: For LWC components

### 3. Apex Framework Integration ✅
**File**: `generating-apex/references/framework_Reference.md`

**Enhanced Sections**:
- ✅ § 1.8: Comprehensive Utility Classes Reference
  - CC__LoggerUtility (error & integration logging)
  - CC__DMLUtility (bulk insert/update/upsert/delete)
  - CC__EmailUtility (email with attachments)
  - CC__Utility (common helpers)
  - CC__BusinessRulesUtility (business rule evaluation)
  - 5 additional utilities documented
- ✅ § 1.9: Common Usage Patterns with real-world examples
- ✅ § 1.3: DAO Pattern with 5 detailed examples showing:
  - Single record retrieval
  - Complex filtering with date ranges
  - FieldSet usage
  - Batch processing (QueryLocator)
  - Service layer integration

### 4. Apex Skill Enhanced ✅
**File**: `.github/skills/skills/generating-apex/SKILL.md`

**Updates**:
- ✅ Phase 1 Step 3: Now mandates reading framework_Reference.md sections 1.3 and 1.8
- ✅ PMD Static Ruleset reference: Agents must review `.github/references/pmd-static-ruleset.xml`
- ✅ Phase 2.5: New "PMD Compliance Checklist" with 13 common violations and auto-fixes
- ✅ Phase 5: PMD scanning now uses the centralized XML ruleset
- ✅ Phase 6: Remediation loop with specific violation fixes

### 5. Apex Test Skill Enhanced ✅
**File**: `.github/skills/skills/generating-apex-test/SKILL.md`

**Updates**:
- ✅ Step 2: References framework_Reference.md for test patterns
- ✅ PMD-driven test generation rules now integrated
- ✅ Test code anti-patterns documented
- ✅ Assertion best practices with failure messages

### 6. Plan Framework Template ✅
**File**: `.github/plans/plan_framework.md`

**Sections**:
- ✅ Artifact details (type, file path, net-new/modification)
- ✅ Business requirements (purpose, objects, dependencies, constraints)
- ✅ Technical architecture (pattern, sharing, utilities, error handling)
- ✅ PMD compliance checklist (13 critical rules)
- ✅ Flosum deployment rules
- ✅ Test strategy with scenarios
- ✅ Implementation checklist
- ✅ User approval step
- ✅ Execution summary (filled after generation)

### 7. Agent Usage Guide ✅
**File**: `.github/instructions/using-sf-code-generator.instructions.md`

**Covers**:
- ✅ How to start the agent
- ✅ 7-phase workflow explanation
- ✅ Questions asked in Phase 1 (by artifact type)
- ✅ Plan review and approval process
- ✅ Implementation details per artifact type
- ✅ PMD scanning and remediation explanation
- ✅ Report interpretation
- ✅ Reference documents guide
- ✅ Common examples (Service class, Test class, Refactoring)
- ✅ When to use/not use the agent
- ✅ Troubleshooting section

---

## How to Use

### Starting the Agent

In GitHub Copilot Chat:

```
/sf-code-generator
```

Or describe your task:
```
Create an Apex service class for claims settlement
```

### The Agent Will:

1. **Ask definite questions** about your requirement (no assumptions)
2. **Generate a plan** at `.github/plans/plan_framework.md`
3. **Wait for your approval** before proceeding
4. **Generate production-ready code** following framework patterns
5. **Run PMD scanner** automatically
6. **Fix any violations** iteratively
7. **Report final metrics** (PMD: 0 violations, Coverage: X%, etc.)

---

## What Gets Referenced Automatically

### Agent Decision Flow

```
User Request
    ↓
Agent reads: .github/agents/sf-code-generator.agent.md ← (This is YOU)
    ↓
Phase 1: Ask questions from questionnaire
    ↓
Phase 2: Generate plan_framework.md template
    ↓
Phase 3: Wait for approval
    ↓
Phase 4: Call generating-apex SKILL.md
    ├→ SKILL reads: generating-apex/references/framework_Reference.md
    ├→ SKILL reads: .github/references/pmd-static-ruleset.xml
    ├→ SKILL reads: assets/templates/
    └→ SKILL generates code
    ↓
Phase 5-6: PMD scanning via sf scanner with pmd-static-ruleset.xml
    ↓
Phase 7: Report results
```

### Framework References Used

| Document | When Used | Key Sections |
|----------|-----------|--------------|
| `framework_Reference.md` | Every Apex generation | § 1.3 (DAO), § 1.8 (Utilities), § 1.9 (Patterns) |
| `generating-apex/SKILL.md` | Apex class creation | Hard-stop constraints, PMD checklist, naming conventions |
| `generating-apex-test/SKILL.md` | Test class creation | TestDataFactory patterns, bulkification, assertions |
| `pmd-static-ruleset.xml` | PMD scanning | Violation rules and severity levels |
| `plan_framework.md` | Plan generation | Template structure for documentation |
| `using-sf-code-generator.instructions.md` | User guidance | How to use the agent, examples, troubleshooting |

---

## Key Features

### ✅ Question-Based Requirements
No assumptions. Every artifact requirement is asked explicitly:
- Business purpose
- Related objects
- Artifact type
- Framework patterns
- Error handling strategy
- Test scope
- PMD concerns

### ✅ Plan-Based Approval
Before any code is written:
- User reviews detailed plan
- User approves architecture
- User verifies PMD rules
- Explicit "proceed" needed

### ✅ Framework Enforcement
Every artifact enforces:
- Service-Selector-Domain patterns
- CC_Logger/DML/Email utility usage
- Bulk-safe code (no SOQL/DML loops)
- Explicit sharing keywords
- ApexDoc comments
- Custom metadata (no hardcoded IDs)

### ✅ Automated PMD Compliance
1. Agent uses `.github/references/pmd-static-ruleset.xml`
2. Scans with: `sf scanner run --target... --pmdconfig=pmd-static-ruleset.xml`
3. Shows violation count for **Apex** AND **JavaScript**
4. Automatically fixes violations iteratively
5. Re-scans until 0 violations achieved

### ✅ Flosum Integration
Plans include:
- Deployment risk assessment
- Custom field tracking
- CRUD/FLS enforcement verification
- API version compliance (66.0)

### ✅ Test Generation
For every service class:
- 90%+ coverage target
- Positive + negative + bulk scenarios
- CC_TestDataFactory integration
- Given/When/Then structure
- Assertions with failure messages

### ✅ Quality Reporting
Final report shows:
- Lines of code
- Methods created
- Test coverage %
- PMD violations (target: 0)
- Flosum compliance status
- Deployment instructions

---

## File Organization

```
.github/
├── agents/
│   └── sf-code-generator.agent.md          ← Custom agent (MAIN ENTRY POINT)
├── instructions/
│   └── using-sf-code-generator.instructions.md  ← User guide
├── plans/
│   └── plan_framework.md                    ← Plan template (auto-populated)
├── references/
│   └── pmd-static-ruleset.xml               ← PMD rules (enforced by agent)
└── skills/
    └── skills/
        ├── generating-apex/
        │   ├── SKILL.md                     ← Enhanced with PMD steps & framework refs
        │   └── references/
        │       └── framework_Reference.md   ← Enhanced with utility classes & DAO examples
        └── generating-apex-test/
            ├── SKILL.md                     ← Enhanced with framework refs
            └── references/
                └── generating-apex-test-framework-reference.md
```

---

## Quick Reference Checklist

Use this when starting a code generation task:

### Before Starting Agent
- [ ] Read `.github/instructions/using-sf-code-generator.instructions.md` (5 min)
- [ ] Know what you want to create (type, business purpose)
- [ ] Have SObject names ready (if applicable)

### During Phase 1 (Questions)
- [ ] Answer each question clearly
- [ ] Don't skip questions - agent needs all context
- [ ] Reference framework if asked

### During Phase 2 (Plan Review)
- [ ] Read entire plan_framework.md
- [ ] Verify business requirements
- [ ] Check architecture pattern is correct
- [ ] Confirm PMD rules understood
- [ ] Look at test strategy

### During Phase 4 (Code Generation)
- [ ] Code is generated with:
  - ✅ ApexDoc comments
  - ✅ Framework utilities integrated
  - ✅ Error handling with logging
  - ✅ Sharing keyword explicit
  - ✅ No hardcoded IDs
  - ✅ Test class (90%+ coverage)

### During Phase 5-6 (PMD Scanning)
- [ ] View PMD violation count
- [ ] If violations: Agent auto-fixes them
- [ ] Re-scan confirmation shown

### During Phase 7 (Final Report)
- [ ] Read quality metrics
- [ ] Check deployment instructions
- [ ] Deploy to dev org if ready

---

## Example Commands (Reference)

These commands are run **by the agent automatically**:

### PMD Scanning (Apex)
```bash
sf scanner run --target="./**/CC_YourClass.cls" \
  --pmdconfig=".github/references/pmd-static-ruleset.xml" \
  --format=json
```

### PMD Scanning (JavaScript)
```bash
sf scanner run --target="./**/lwc/yourComponent/**/*.js" \
  --category=eslint \
  --format=json
```

### Deploy Generated Code
```bash
sf project deploy start \
  --source-dir="force-app/main/default/classes/CC_YourClass.cls" \
  --target-org=dev
```

### Run Test Class
```bash
sf apex run test \
  --class-names=CC_YourClassTest \
  --code-coverage \
  --target-org=dev
```

---

## Troubleshooting Guide

| Issue | Cause | Solution |
|-------|-------|----------|
| Agent asks same question twice | Clarification needed | Provide more specific answer |
| PMD violations still showing | Complex violation | Agent will retry; provide specific violation details if needed |
| "Framework reference not loading" | Framework not in expected location | Verify framework_Reference.md exists at `generating-apex/references/` |
| Test class coverage <85% | Logic too complex or missing cases | Agent will ask to add edge case tests |
| "Flosum validation failed" | Metadata issue | Check custom field types and API version |

---

## Success Criteria

Your agent setup is complete and successful when:

✅ **Agent file created**: `.github/agents/sf-code-generator.agent.md`  
✅ **PMD ruleset in place**: `.github/references/pmd-static-ruleset.xml`  
✅ **Framework references enhanced**: Section 1.8 (Utilities) & 1.9 (Patterns) populated  
✅ **Skills integrated**: generating-apex & generating-apex-test SKILL.md updated  
✅ **Plan template ready**: `.github/plans/plan_framework.md` created  
✅ **User guide available**: `.github/instructions/using-sf-code-generator.instructions.md`  
✅ **All references cross-linked**: Framework docs point to PMD rules, examples  

### Test It Out

Try this first request to verify everything works:

```
/sf-code-generator

Create an Apex service class to validate claim eligibility based on policy rules.
```

The agent should:
1. Ask questions about business purpose, related objects, sharing rules
2. Generate a detailed plan
3. Wait for your approval
4. Generate the code
5. Run PMD scanner
6. Show final report with 0 PMD violations

---

## Next Steps (Optional Enhancements)

Consider adding:
- [ ] `.github/hooks/` for pre-deploy PMD validation
- [ ] Custom Flosum rule mappings in team wiki
- [ ] Jenkins/GitHub Actions integration to enforce PMD on every PR
- [ ] Automated code review rules in VS Code settings
- [ ] Team documentation on framework patterns (internal wiki)

---

## Support & Documentation

- **Agent file**: `.github/agents/sf-code-generator.agent.md` (how it works)
- **User guide**: `.github/instructions/using-sf-code-generator.instructions.md` (how to use)
- **Framework reference**: `generating-apex/references/framework_Reference.md` (patterns & utilities)
- **PMD rules**: `.github/references/pmd-static-ruleset.xml` (quality standards)
- **Plan template**: `.github/plans/plan_framework.md` (what gets documented)

---

