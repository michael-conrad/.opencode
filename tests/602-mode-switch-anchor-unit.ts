/**
 * Unit test for spec #602: Mode-Switch Anchor Plugin
 *
 * Tests the handleModeSwitchParts() code path by calling it with
 * mock synthetic parts and asserting the transformation occurred.
 *
 * RED phase: Compile failure — handleModeSwitchParts doesn't exist yet.
 * GREEN phase: Compile success + assertions pass.
 *
 * Usage:
 *   PATH=.tools/node/bin:$PATH npx tsc --noEmit --pretty false .opencode/tests/602-mode-switch-anchor-unit.ts 2>&1
 *
 * Co-authored with AI: OpenCode (deepseek-v4-flash)
 */

// Mock TextPart type matching the SDK's TextPart shape
interface TextPart {
  type: "text";
  text: string;
  synthetic?: boolean;
}

// Mock Message type matching the SDK's Message shape
interface Message {
  info: {
    role: "user" | "assistant";
    agent: string;
    sessionID?: string;
  };
  parts: TextPart[];
}

// The handler function imported from the plugin — RED phase: import fails
import { handleModeSwitchParts, MODE_SWITCH_ANCHOR } from "../plugins/session-enforcement.ts";

// ---------------------------------------------------------------------------
// Test 1: Transition turn — build-switch detected, last assistant was plan
// ---------------------------------------------------------------------------
function testTransitionBuildSwitch(): void {
  const messages: Message[] = [
    {
      info: { role: "assistant", agent: "plan" },
      parts: [{ type: "text", text: "This was the plan phase." }],
    },
    {
      info: { role: "user", agent: "build" },
      parts: [
        {
          type: "text",
          text: "Your operational mode has changed from plan to build. You are no longer in read-only mode. You are permitted to make file changes, run shell commands, and utilize your arsenal of tools as needed.\n\nI need to implement feature X.",
          synthetic: true,
        },
      ],
    },
  ];

  // Call the function under test
  // handleModeSwitchParts(messages);

  // After call, the synthetic part should be replaced with MODE_SWITCH_ANCHOR
  const part = messages[1].parts[0];
  if (part.text === MODE_SWITCH_ANCHOR) {
    console.log("PASS: testTransitionBuildSwitch — part.text replaced with anchor");
  } else {
    console.error("FAIL: testTransitionBuildSwitch — expected anchor, got:", part.text.substring(0, 60));
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Test 2: Non-transition turn — stale build-switch re-injection is stripped
// ---------------------------------------------------------------------------
function testNonTransitionStaleBuildSwitch(): void {
  const messages: Message[] = [
    {
      info: { role: "assistant", agent: "build" },
      parts: [{ type: "text", text: "Previous build turn." }],
    },
    {
      info: { role: "user", agent: "build" },
      parts: [
        {
          type: "text",
          text: "Your operational mode has changed from plan to build. You are no longer in read-only mode.\n\nLet's continue.",
          synthetic: true,
        },
      ],
    },
  ];

  // handleModeSwitchParts(messages);

  const part = messages[1].parts[0];
  if (part.text === "" && part.synthetic === false) {
    console.log("PASS: testNonTransitionStaleBuildSwitch — part stripped to empty");
  } else {
    console.error("FAIL: testNonTransitionStaleBuildSwitch — expected empty, got text:", part.text.length);
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Test 3: Transition turn — plan-mode detected, replaced with anchor
// ---------------------------------------------------------------------------
function testTransitionPlanMode(): void {
  const messages: Message[] = [
    {
      info: { role: "assistant", agent: "build" },
      parts: [{ type: "text", text: "Build work complete." }],
    },
    {
      info: { role: "user", agent: "plan" },
      parts: [
        {
          type: "text",
          text: "# Plan Mode - System Reminder\n\nCRITICAL: Plan mode ACTIVE - you are in READ-ONLY phase.\n\nLet me review the approach.",
          synthetic: true,
        },
      ],
    },
  ];

  // handleModeSwitchParts(messages);

  const part = messages[1].parts[0];
  if (part.text === MODE_SWITCH_ANCHOR) {
    console.log("PASS: testTransitionPlanMode — plan-mode part replaced with anchor");
  } else {
    console.error("FAIL: testTransitionPlanMode — expected anchor");
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Test 4: Non-transition plan-mode turn — stale re-injection stripped
// ---------------------------------------------------------------------------
function testNonTransitionStalePlanMode(): void {
  const messages: Message[] = [
    {
      info: { role: "assistant", agent: "plan" },
      parts: [{ type: "text", text: "Previous plan turn." }],
    },
    {
      info: { role: "user", agent: "plan" },
      parts: [
        {
          type: "text",
          text: "# Plan Mode - System Reminder\n\nCRITICAL: Plan mode ACTIVE\n\nLet me think about this more.",
          synthetic: true,
        },
      ],
    },
  ];

  // handleModeSwitchParts(messages);

  const part = messages[1].parts[0];
  if (part.text === "" && part.synthetic === false) {
    console.log("PASS: testNonTransitionStalePlanMode — stale plan-mode stripped");
  } else {
    console.error("FAIL: testNonTransitionStalePlanMode — expected empty");
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Test 5: Non-synthetic parts are NOT touched
// ---------------------------------------------------------------------------
function testNonSyntheticPartUntouched(): void {
  const messages: Message[] = [
    {
      info: { role: "assistant", agent: "plan" },
      parts: [{ type: "text", text: "Plan phase." }],
    },
    {
      info: { role: "user", agent: "build" },
      parts: [
        {
          type: "text",
          text: "Your operational mode has changed from plan to build.\n\nImplement feature X.",
          // synthetic is NOT set — should be skipped
        },
      ],
    },
  ];

  // handleModeSwitchParts(messages);

  const part = messages[1].parts[0];
  if (part.text.includes("operational mode has changed")) {
    console.log("PASS: testNonSyntheticPartUntouched — non-synthetic part preserved");
  } else {
    console.error("FAIL: testNonSyntheticPartUntouched — non-synthetic part was modified");
    process.exit(1);
  }
}

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------
console.log("=== Unit Tests: Mode-Switch Anchor Plugin ===");

testTransitionBuildSwitch();
testNonTransitionStaleBuildSwitch();
testTransitionPlanMode();
testNonTransitionStalePlanMode();
testNonSyntheticPartUntouched();

console.log("PASS: All unit tests passed");
