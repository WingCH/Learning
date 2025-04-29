import { compareJsonStructure, Difference } from './compareJsonStructure';

describe('compareJsonStructure', () => {
  // Helper to sort differences for consistent comparison
  const sortDifferences = (diffs: Difference[]) => diffs.sort((a, b) => a.path.localeCompare(b.path));

  it('should return an empty array when structures are identical', () => {
    const baseJson = JSON.stringify({ a: 1, b: "hello", c: { d: true } });
    const actualJson = JSON.stringify({ a: 1, b: "hello", c: { d: true } });
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual([]);
  });

  it('should return an empty array for identical arrays of primitives', () => {
    const baseJson = JSON.stringify([1, 2, 3]);
    const actualJson = JSON.stringify([4, 5, 6]); // Values differ, but structure (array of numbers) is the same
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual([]);
  });

  it('should return an empty array for identical arrays of objects (comparing first element structure)', () => {
    const baseJson = JSON.stringify([{ id: 1, name: "a" }, { id: 2, name: "b" }]);
    const actualJson = JSON.stringify([{ id: 3, name: "c" }, { id: 4, name: "d" }]);
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual([]);
  });

  it('should detect type mismatch (Test Case 1)', () => {
    const baseJson = JSON.stringify({ id: "123" });
    const actualJson = JSON.stringify({ id: 123 });
    const expected: Difference[] = [
      { type: 'Type Mismatch', path: 'id', expectedType: 'string', actualType: 'number', description: 'Type mismatch' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual(expected);
  });

  it('should detect missing field (Test Case 2)', () => {
    const baseJson = JSON.stringify({ name: "Wing", email: "wing@example.com" });
    const actualJson = JSON.stringify({ name: "Wing" });
    const expected: Difference[] = [
      { type: 'Missing Field', path: 'email', expectedType: 'string', actualType: null, description: 'Missing field' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual(expected);
  });

  it('should detect new field', () => {
    const baseJson = JSON.stringify({ name: "Wing" });
    const actualJson = JSON.stringify({ name: "Wing", age: 30 });
    const expected: Difference[] = [
      { type: 'New Field', path: 'age', expectedType: null, actualType: 'number', description: 'New field' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual(expected);
  });

  it('should handle complex nested structure (Test Case 3)', () => {
    const baseJson = JSON.stringify({
      user: {
        id: "123",
        profile: { name: "Wing", age: 30, contact: { email: "wing@example.com", phone: "12345678" } },
        roles: ["admin", "editor"],
        settings: { notifications: true, theme: "dark" }
      }
    });
    const actualJson = JSON.stringify({
      user: {
        id: 123,
        profile: { name: "Wing", contact: { email: "wing@example.com" } },
        roles: "admin",
        settings: { theme: "dark", language: "en" }
      }
    });
    const expected: Difference[] = [
      { type: 'Type Mismatch', path: 'user.id', expectedType: 'string', actualType: 'number', description: 'Type mismatch' },
      { type: 'Missing Field', path: 'user.profile.age', expectedType: 'number', actualType: null, description: 'Missing field' },
      { type: 'Missing Field', path: 'user.profile.contact.phone', expectedType: 'string', actualType: null, description: 'Missing field' },
      { type: 'Type Mismatch', path: 'user.roles', expectedType: 'array', actualType: 'string', description: 'Type mismatch' },
      { type: 'Missing Field', path: 'user.settings.notifications', expectedType: 'boolean', actualType: null, description: 'Missing field' },
      { type: 'New Field', path: 'user.settings.language', expectedType: null, actualType: 'string', description: 'New field' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    // Sort results by path for consistent comparison
    expect(sortDifferences(result as Difference[])).toEqual(sortDifferences(expected));
  });

  it('should handle level change (Test Case 4)', () => {
    const baseJson = JSON.stringify({ user: { id: "123", profile: { name: "Wing" } } });
    const actualJson = JSON.stringify({ user: { id: "123", name: "Wing" } });
    // const expected: Difference[] = [
    //   { type: 'Missing Field', path: 'user.profile', expectedType: 'object', actualType: null, description: 'Missing field' },
    //   { type: 'New Field', path: 'user.name', expectedType: null, actualType: 'string', description: 'New field' },
    // ];
    const result = compareJsonStructure(baseJson, actualJson);
    // Note: The current logic might report missing 'user.profile.name' and new 'user.name'.
    // Let's adjust the expectation based on how the current logic likely works (comparing keys at each level).
    // It will find 'profile' missing in actual, and 'name' new in actual at the 'user' level.
    const expectedBasedOnLogic: Difference[] = [
      { type: 'Missing Field', path: 'user.profile', expectedType: 'object', actualType: null, description: 'Missing field' },
      { type: 'New Field', path: 'user.name', expectedType: null, actualType: 'string', description: 'New field' },
    ];
    expect(sortDifferences(result as Difference[])).toEqual(sortDifferences(expectedBasedOnLogic));
  });


  it('should handle empty objects', () => {
    const baseJson = JSON.stringify({});
    const actualJson = JSON.stringify({});
    expect(compareJsonStructure(baseJson, actualJson)).toEqual([]);

    const baseJson2 = JSON.stringify({ a: 1 });
    const actualJson2 = JSON.stringify({});
    const expected2: Difference[] = [
      { type: 'Missing Field', path: 'a', expectedType: 'number', actualType: null, description: 'Missing field' },
    ];
    expect(compareJsonStructure(baseJson2, actualJson2)).toEqual(expected2);

    const baseJson3 = JSON.stringify({});
    const actualJson3 = JSON.stringify({ b: "test" });
    const expected3: Difference[] = [
      { type: 'New Field', path: 'b', expectedType: null, actualType: 'string', description: 'New field' },
    ];
    expect(compareJsonStructure(baseJson3, actualJson3)).toEqual(expected3);
  });

  it('should handle null values correctly', () => {
    const baseJson = JSON.stringify({ a: null });
    const actualJson = JSON.stringify({ a: null });
    expect(compareJsonStructure(baseJson, actualJson)).toEqual([]);

    const baseJson2 = JSON.stringify({ a: null });
    const actualJson2 = JSON.stringify({ a: "string" });
    const expected2: Difference[] = [
      { type: 'Type Mismatch', path: 'a', expectedType: 'null', actualType: 'string', description: 'Type mismatch' },
    ];
    expect(compareJsonStructure(baseJson2, actualJson2)).toEqual(expected2);

    const baseJson3 = JSON.stringify({ a: 1 });
    const actualJson3 = JSON.stringify({ a: null });
    const expected3: Difference[] = [
      { type: 'Type Mismatch', path: 'a', expectedType: 'number', actualType: 'null', description: 'Type mismatch' },
    ];
    expect(compareJsonStructure(baseJson3, actualJson3)).toEqual(expected3);
  });

  it('should detect root level type mismatch (object vs array)', () => {
    const baseJson = JSON.stringify({ a: 1 });
    const actualJson = JSON.stringify([1, 2]);
    const expected: Difference[] = [
      { type: 'Type Mismatch', path: '(root)', expectedType: 'object', actualType: 'array', description: 'Root level type mismatch' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual(expected);
  });

  it('should detect root level type mismatch (array vs object)', () => {
    const baseJson = JSON.stringify([1, 2]);
    const actualJson = JSON.stringify({ a: 1 });
    const expected: Difference[] = [
      { type: 'Type Mismatch', path: '(root)', expectedType: 'array', actualType: 'object', description: 'Root level type mismatch' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toEqual(expected);
  });

  it('should detect type mismatch within arrays (based on first element)', () => {
    const baseJson = JSON.stringify({ data: [{ id: 1 }] });
    const actualJson = JSON.stringify({ data: ["string"] }); // Array of strings instead of objects
    const expected: Difference[] = [
      // The primary mismatch is the array elements' type
      { type: 'Type Mismatch', path: 'data[0]', expectedType: 'array of object', actualType: 'array of string', description: 'Array element type mismatch' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(sortDifferences(result as Difference[])).toEqual(sortDifferences(expected));
  });

  it('should compare structure of first object in arrays', () => {
    const baseJson = JSON.stringify({ items: [{ name: "A", value: 1 }] });
    const actualJson = JSON.stringify({ items: [{ name: "B" }] }); // Missing 'value' field in first element
    const expected: Difference[] = [
      { type: 'Missing Field', path: 'items[0].value', expectedType: 'number', actualType: null, description: 'Missing field' },
    ];
    const result = compareJsonStructure(baseJson, actualJson);
    expect(sortDifferences(result as Difference[])).toEqual(sortDifferences(expected));
  });

  it('should handle empty arrays correctly', () => {
    const baseJson = JSON.stringify({ data: [] });
    const actualJson = JSON.stringify({ data: [] });
    expect(compareJsonStructure(baseJson, actualJson)).toEqual([]);

    const baseJson2 = JSON.stringify({ data: [] });
    const actualJson2 = JSON.stringify({ data: [1, 2] });
    const expected2: Difference[] = [
      { type: 'Type Mismatch', path: 'data[0]', expectedType: 'empty array', actualType: 'array with elements (e.g., number)', description: 'Array changed from empty to having elements' },
    ];
    expect(compareJsonStructure(baseJson2, actualJson2)).toEqual(expected2);


    const baseJson3 = JSON.stringify({ data: [{ a: 1 }] });
    const actualJson3 = JSON.stringify({ data: [] });
    const expected3: Difference[] = [
      { type: 'Type Mismatch', path: 'data[0]', expectedType: 'array with elements (e.g., object)', actualType: 'empty array', description: 'Array changed from having elements to empty' },
    ];
    expect(compareJsonStructure(baseJson3, actualJson3)).toEqual(expected3);
  });


  it('should return error for invalid base JSON', () => {
    const baseJson = "{ invalid json";
    const actualJson = JSON.stringify({ a: 1 });
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toHaveProperty('error');
    expect((result as { error: string }).error).toContain('Unable to parse base JSON');
  });

  it('should return error for invalid actual JSON', () => {
    const baseJson = JSON.stringify({ a: 1 });
    const actualJson = "[ invalid json ]";
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toHaveProperty('error');
    expect((result as { error: string }).error).toContain('Unable to parse actual JSON');
  });

  it('should return error if base input is not object or array', () => {
    const baseJson = JSON.stringify("a string");
    const actualJson = JSON.stringify({ a: 1 });
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toHaveProperty('error');
    expect((result as { error: string }).error).toContain('Base input must be a JSON object or array');
  });

  it('should return error if actual input is not object or array', () => {
    const baseJson = JSON.stringify({ a: 1 });
    const actualJson = JSON.stringify(123);
    const result = compareJsonStructure(baseJson, actualJson);
    expect(result).toHaveProperty('error');
    expect((result as { error: string }).error).toContain('Actual input must be a JSON object or array');
  });

});
