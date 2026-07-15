# Task: concern-analysis

## Purpose

Identify concern boundaries from the problem statement, detect overlap and leakage between concerns, and produce a concern-to-unit mapping. Ensure each unit addresses exactly one concern and each concern is contained within its designated unit.

## Entry Criteria

- Requirements extraction completed
- Decomposition completed (units identified)

## Exit Criteria

- All concerns extracted from requirements and classified
- Concern boundaries identified and documented
- Overlap detected and flagged (two units sharing a concern)
- Leakage detected and flagged (one concern spanning multiple units)
- Concern-to-unit mapping produced
- Every unit verified to address exactly one concern

## Procedure

### Step 1: Extract Concerns from Requirements

From the requirements and problem statement, extract every distinct concern. A concern is a functional or non-functional area of responsibility that the spec must address. Examples: user authentication, data validation, error reporting, access control, caching, logging.

Classify each concern as:

| Classification | Definition | Example |
|---------------|------------|---------|
| **Singular concern** | Addresses exactly one responsibility, cannot be further decomposed | "Password hashing" |
| **Composite concern** | Addresses multiple sub-concerns that could be decomposed | "User management" (includes registration, login, profile, permissions) |

Composite concerns should be decomposed into their constituent singular concerns before proceeding.

### Step 2: Map Concerns to Units

For each unit identified in decomposition, determine which concern(s) it addresses. A unit should address exactly one concern. Document the mapping:

- Unit → Concern(s) it addresses
- Concern → Unit(s) that address it

### Step 3: Detect Overlap

Overlap occurs when two or more units address the same concern. For each concern, check how many units address it:

- **One unit:** Clean separation — no overlap
- **Multiple units:** Overlap detected — flag for review

Overlap is not always a defect (some concerns legitimately span multiple units), but it must be explicitly identified and justified. Document the rationale for each overlap.

### Step 4: Detect Leakage

Leakage occurs when a single unit addresses multiple concerns. For each unit, check how many concerns it addresses:

- **One concern:** Clean separation — no leakage
- **Multiple concerns:** Leakage detected — flag for review

Leakage is a design smell. A unit that addresses multiple concerns should be decomposed into sub-units, each addressing exactly one concern. Document the recommended decomposition for each leakage.

### Step 5: Produce Concern-to-Unit Mapping

Create a structured artifact containing:

- **Concern inventory:** All extracted concerns with classification (singular/composite)
- **Concern-to-unit matrix:** For each concern, which unit(s) address it
- **Overlap report:** Concerns addressed by multiple units, with rationale
- **Leakage report:** Units addressing multiple concerns, with recommended decomposition
- **Clean units:** Units with clean one-to-one concern mapping

## Content Coverage

Does the concern analysis cover:

- All concerns extracted from requirements?
- Concern classification (singular vs composite)?
- Concern-to-unit mapping?
- Overlap detection (concerns addressed by multiple units)?
- Leakage detection (units addressing multiple concerns)?
- Rationale for each overlap?
- Recommended decomposition for each leakage?

**Any format that communicates these concerns clearly is acceptable.** A concern-to-unit matrix table with overlap and leakage annotations works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `requirements`
- Feeds into: `decompose`, `cross-cutting`
