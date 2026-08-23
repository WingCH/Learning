export class KeyedSerialTaskQueue {
  private readonly tails = new Map<string, Promise<void>>();

  public run<T>(key: string, task: () => Promise<T>): Promise<T> {
    const previousTail = this.tails.get(key) ?? Promise.resolve();
    const result = previousTail.then(task, task);
    const currentTail = result.then(
      () => undefined,
      () => undefined,
    );

    this.tails.set(key, currentTail);
    void currentTail.then(() => {
      if (this.tails.get(key) === currentTail) {
        this.tails.delete(key);
      }
    });
    return result;
  }
}
