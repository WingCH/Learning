/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom', // Use jsdom environment
  moduleNameMapper: {
    // Handle module aliases (this should match your tsconfig.json)
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  // Optional: Setup files after env is set up
  // setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  // Optional: Specify test file patterns
  // testMatch: ['**/__tests__/**/*.ts?(x)', '**/?(*.)+(spec|test).ts?(x)'],
};
