# Task: state-analysis

## Purpose

Model the state transitions introduced or affected by the change, verify completeness of the state machine (no deadlock states, no unreachable states, all transitions defined), and document the state model as a spec artifact.

## Entry Criteria

- Decomposition completed (units identified)
- Interface compatibility analysis completed (unit interfaces known)

## Exit Criteria

- All states extracted from requirements and decomposition
- Valid transitions enumerated for each state
- Completeness verified (no deadlock states, no unreachable states, all transitions defined)
- State model artifact produced
- Every state has an exit path to a terminal or stable state

## Procedure

### Step 1: Extract States from Requirements

From the requirements and decomposition, identify all distinct states that the system or component can be in. States are discrete, mutually exclusive modes of operation:

- **Initial state:** The state before any operation begins
- **Intermediate states:** States the system passes through during operation
- **Terminal states:** States where the system stops (success, failure, cancelled)
- **Error states:** States entered when an error occurs
- **Recovery states:** States entered when recovering from an error

For each state, document:

- **State name:** A concise, descriptive name
- **State description:** What it means for the system to be in this state
- **Entry conditions:** What must be true for the system to enter this state
- **Exit conditions:** What must be true for the system to leave this state

### Step 2: Enumerate Valid Transitions

For each state, enumerate all valid transitions to other states:

- **Trigger:** What event or condition causes the transition
- **Target state:** The state the system transitions to
- **Guard condition:** Any condition that must be true for the transition to be valid
- **Action:** What happens during the transition (data transformation, side effect, external call)

Document the transition as: Current State → [Trigger / Guard] → Target State

### Step 3: Verify Completeness

Verify the state machine is complete:

- **No deadlock states:** Every state must have at least one outgoing transition (except explicitly terminal states). A state with no outgoing transitions that is not terminal is a deadlock state — flag as a defect.
- **No unreachable states:** Every state must be reachable from the initial state through a chain of valid transitions. A state with no incoming path from the initial state is unreachable — flag as a defect.
- **All transitions defined:** For every pair of states that could logically transition, verify a transition is defined. Missing transitions between logically connected states are defects.
- **Exit path:** Every non-terminal state must have a path to a terminal state (success or failure). States that can be entered but never exited (except through system termination) are defects.

### Step 4: Document State Model

Create a structured artifact containing:

- **State inventory:** All states with descriptions, entry conditions, and exit conditions
- **Transition table:** All valid transitions with triggers, guards, and actions
- **Completeness verification:** Confirmation that no deadlock states, no unreachable states, and all transitions are defined
- **Defect report:** Any deadlock states, unreachable states, or missing transitions found

### Step 5: Verify Coverage

Cross-reference the state model against the spec's scope. Verify that:

- Every state implied by the requirements is in the inventory
- Every transition implied by the requirements is in the transition table
- Every error condition in the requirements has a corresponding error state
- Every recovery path in the requirements has a corresponding recovery state and transition

## Content Coverage

Does the state analysis cover:

- All states extracted from requirements?
- Valid transitions enumerated for each state?
- Completeness verification (no deadlocks, no unreachable states, all transitions defined)?
- Exit path from every non-terminal state?
- Coverage verification against requirements?

**Any format that communicates these concerns clearly is acceptable.** A state transition diagram in table form (current state → trigger → target state) with a completeness checklist works well. The agent chooses the format that best serves the spec's complexity.

## Context Required

- Preceded by: `decompose`, `interface-compatibility`
- Feeds into: `pipeline-readiness-gate`
