import test from "node:test";
import assert from "node:assert/strict";

test("sanity: test harness runs", () => {
  assert.equal(2 + 2, 4);
});