import type {
  PendingResponseDelay,
  ResponseDelayPolicy,
} from "../../application/messages/response-delay-policy.js";

export interface ResponseDelayConfig {
  readonly minimumMs: number;
  readonly maximumMs: number;
}

export type RandomSource = () => number;
export type Clock = () => number;
export type Sleep = (milliseconds: number) => Promise<void>;

export class RandomizedResponseDelayPolicy implements ResponseDelayPolicy {
  public constructor(
    private readonly config: ResponseDelayConfig,
    private readonly random: RandomSource,
    private readonly clock: Clock,
    private readonly sleep: Sleep,
  ) {
    validateNonNegativeInteger("minimumMs", config.minimumMs);
    validateNonNegativeInteger("maximumMs", config.maximumMs);
    if (config.minimumMs > config.maximumMs) {
      throw new Error("Response delay minimumMs 不可大於 maximumMs。");
    }
  }

  public begin(): PendingResponseDelay {
    const randomValue = this.random();
    if (randomValue < 0 || randomValue >= 1 || !Number.isFinite(randomValue)) {
      throw new Error("Random source 必須回傳介乎 0（含）與 1（不含）的數值。");
    }

    const range = this.config.maximumMs - this.config.minimumMs;
    const minimumDurationMs = this.config.minimumMs +
      Math.floor(randomValue * (range + 1));
    const sendNotBeforeMs = this.clock() + minimumDurationMs;

    return {
      wait: async () => {
        const remainingMs = Math.max(0, sendNotBeforeMs - this.clock());
        if (remainingMs > 0) {
          await this.sleep(remainingMs);
        }
      },
    };
  }
}

function validateNonNegativeInteger(name: string, value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new Error(`${name} 必須是非負整數。`);
  }
}
