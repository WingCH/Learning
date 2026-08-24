import assert from "node:assert/strict";
import test from "node:test";

import { RandomizedResponseDelayPolicy } from "../../../src/infrastructure/timing/randomized-response-delay-policy.js";

test("fast API 只等待隨機 minimum deadline 的剩餘時間", async () => {
  let currentTimeMs = 1_000;
  const sleepCalls: number[] = [];
  const policy = new RandomizedResponseDelayPolicy(
    { minimumMs: 2_000, maximumMs: 5_000 },
    () => 0,
    () => currentTimeMs,
    async (milliseconds) => {
      sleepCalls.push(milliseconds);
    },
  );

  const delay = policy.begin();
  currentTimeMs = 1_500;
  await delay.wait();

  assert.deepEqual(sleepCalls, [1_500]);
});

test("random source 接近 1 時可抽到 maximum delay", async () => {
  let currentTimeMs = 1_000;
  const sleepCalls: number[] = [];
  const policy = new RandomizedResponseDelayPolicy(
    { minimumMs: 2_000, maximumMs: 5_000 },
    () => 0.999_999,
    () => currentTimeMs,
    async (milliseconds) => {
      sleepCalls.push(milliseconds);
    },
  );

  const delay = policy.begin();
  currentTimeMs = 2_000;
  await delay.wait();

  assert.deepEqual(sleepCalls, [4_000]);
});

test("API latency 已超過 deadline 時不再額外等待", async () => {
  let currentTimeMs = 1_000;
  const sleepCalls: number[] = [];
  const policy = new RandomizedResponseDelayPolicy(
    { minimumMs: 2_000, maximumMs: 5_000 },
    () => 0.5,
    () => currentTimeMs,
    async (milliseconds) => {
      sleepCalls.push(milliseconds);
    },
  );

  const delay = policy.begin();
  currentTimeMs = 10_000;
  await delay.wait();

  assert.deepEqual(sleepCalls, []);
});

test("拒絕 minimum 大於 maximum 或無效 random source", async () => {
  assert.throws(
    () => new RandomizedResponseDelayPolicy(
      { minimumMs: 5_000, maximumMs: 2_000 },
      () => 0.5,
      Date.now,
      async () => {},
    ),
    /minimumMs 不可大於 maximumMs/,
  );
  const policy = new RandomizedResponseDelayPolicy(
    { minimumMs: 2_000, maximumMs: 5_000 },
    () => 1,
    Date.now,
    async () => {},
  );
  assert.throws(
    () => policy.begin(),
    /Random source 必須回傳/,
  );
});
