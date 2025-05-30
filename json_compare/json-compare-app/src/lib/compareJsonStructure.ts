export interface Difference {
  type: 'Type Mismatch' | 'Missing Field' | 'New Field';
  path: string;
  expectedType: string | null;
  actualType: string | null;
  description: string;
}

/**
 * Helper function to get the type of a value
 */
function getType(value: unknown): string {
  if (value === null) {
    return 'null';
  }
  if (Array.isArray(value)) {
    return 'array';
  }
  return typeof value;
}

/**
 * Recursive function to compare structures
 */
function compareObjects(
  base: unknown,
  actual: unknown,
  path: string = '',
  differences: Difference[] = []
): Difference[] {
  const baseKeys = typeof base === 'object' && base !== null && !Array.isArray(base) ? Object.keys(base as Record<string, unknown>) : [];
  const actualKeys = typeof actual === 'object' && actual !== null && !Array.isArray(actual) ? Object.keys(actual as Record<string, unknown>) : [];
  const allKeys = new Set([...baseKeys, ...actualKeys]);

  for (const key of allKeys) {
    const currentPath = path ? `${path}.${key}` : key;
    const baseValue = typeof base === 'object' && base !== null && !Array.isArray(base) ? (base as Record<string, unknown>)[key] : undefined;
    const actualValue = typeof actual === 'object' && actual !== null && !Array.isArray(actual) ? (actual as Record<string, unknown>)[key] : undefined;
    const baseType = getType(baseValue);
    const actualType = getType(actualValue);

    if (baseKeys.includes(key) && !actualKeys.includes(key)) {
      // Missing Field
      differences.push({
        type: 'Missing Field',
        path: currentPath,
        expectedType: baseType,
        actualType: null,
        description: 'Missing field',
      });
    } else if (!baseKeys.includes(key) && actualKeys.includes(key)) {
      // New Field
      differences.push({
        type: 'New Field',
        path: currentPath,
        expectedType: null,
        actualType: actualType,
        description: 'New field',
      });
    } else if (baseType !== actualType) {
      // Type Mismatch
      differences.push({
        type: 'Type Mismatch',
        path: currentPath,
        expectedType: baseType,
        actualType: actualType,
        description: 'Type mismatch',
      });
      // If types mismatch, but both are objects, still recurse to find nested differences
      if (baseType === 'object' && actualType === 'object') {
         compareObjects(baseValue, actualValue, currentPath, differences);
      }
      // Note: We don't handle array type mismatches here anymore,
      // they are handled in the specific 'array' vs 'array' block below.

    } else if (baseType === 'object' && actualType === 'object') {
      // Both are objects with the same type, recurse
      compareObjects(baseValue, actualValue, currentPath, differences);
    } else if (baseType === 'array' && actualType === 'array') {
      // Both are arrays, compare based on emptiness and first element structure/type
      const arrayBasePath = `${currentPath}[0]`; // Path for element comparison
      const baseArr = Array.isArray(baseValue) ? baseValue : [];
      const actualArr = Array.isArray(actualValue) ? actualValue : [];
      if (baseArr.length > 0 && actualArr.length === 0) {
        // Was non-empty, now empty
        differences.push({
          type: 'Type Mismatch', // Or 'Missing Content'?
          path: arrayBasePath,
          expectedType: `array with elements (e.g., ${getType(baseArr[0])})`,
          actualType: 'empty array',
          description: 'Array changed from having elements to empty',
        });
      } else if (baseArr.length === 0 && actualArr.length > 0) {
        // Was empty, now non-empty
        differences.push({
          type: 'Type Mismatch', // Or 'New Content'?
          path: arrayBasePath,
          expectedType: 'empty array',
          actualType: `array with elements (e.g., ${getType(actualArr[0])})`,
          description: 'Array changed from empty to having elements',
        });
      } else if (baseArr.length > 0 && actualArr.length > 0) {
        // Both non-empty, compare first element type and structure
        const firstBaseType = getType(baseArr[0]);
        const firstActualType = getType(actualArr[0]);

        if (firstBaseType !== firstActualType) {
          // First elements have different types
          differences.push({
            type: 'Type Mismatch',
            path: arrayBasePath,
            expectedType: `array of ${firstBaseType}`,
            actualType: `array of ${firstActualType}`,
            description: 'Array element type mismatch',
          });
        } else if (firstBaseType === 'object') {
          // Both first elements are objects, compare their structure recursively
          compareObjects(baseArr[0], actualArr[0], arrayBasePath, differences);
        }
        // If first elements are primitives of the same type, assume structure matches
      }
      // If both arrays are empty, do nothing (structures match)
    }
    // Primitive types match, do nothing
  }

  return differences;
}

/**
 * Main function to initiate comparison
 */
export function compareJsonStructure(baseJson: string, actualJson: string): Difference[] | { error: string } {
  let baseObj: unknown;
  let actualObj: unknown;

  try {
    baseObj = JSON.parse(baseJson);
  } catch (e) {
    return { error: `Unable to parse base JSON: ${(e as Error).message}` };
  }

  try {
    actualObj = JSON.parse(actualJson);
  } catch (e) {
    return { error: `Unable to parse actual JSON: ${(e as Error).message}` };
  }

  // Ensure both parsed inputs are objects or arrays before comparing
  const baseInputType = getType(baseObj);
  const actualInputType = getType(actualObj);

  if (!['object', 'array'].includes(baseInputType)) {
      return { error: `Base input must be a JSON object or array, but got ${baseInputType}` };
  }
   if (!['object', 'array'].includes(actualInputType)) {
      return { error: `Actual input must be a JSON object or array, but got ${actualInputType}` };
  }

  // Handle case where top-level types are different (e.g., object vs array)
  if (baseInputType !== actualInputType) {
      return [{
          type: 'Type Mismatch',
          path: '(root)',
          expectedType: baseInputType,
          actualType: actualInputType,
          description: 'Root level type mismatch',
      }];
  }

  // If both are arrays, compare based on the first element's structure
  if (baseInputType === 'array') {
      const baseArr = Array.isArray(baseObj) ? baseObj : [];
      const actualArr = Array.isArray(actualObj) ? actualObj : [];
      if (baseArr.length > 0 && actualArr.length > 0) {
          const firstBaseElementType = getType(baseArr[0]);
          const firstActualElementType = getType(actualArr[0]);
          if (firstBaseElementType !== firstActualElementType) {
              return [{
                  type: 'Type Mismatch',
                  path: '[0]',
                  expectedType: `array of ${firstBaseElementType}`,
                  actualType: `array of ${firstActualElementType}`,
                  description: 'Array element type mismatch (root level)',
              }];
          }
          if (firstBaseElementType === 'object') {
              return compareObjects(baseArr[0], actualArr[0], '[0]');
          } else {
              // Arrays of primitives - structure is considered the same if types match
              return [];
          }
      } else {
          // One or both arrays are empty, consider structure the same for now
          return [];
      }
  }

  // Both are objects, proceed with recursive comparison
  return compareObjects(baseObj, actualObj);
}
