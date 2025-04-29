# Tech Context: JSON Compare App

## Core Technologies

*   **Framework:** Next.js 14+ (App Router)
*   **Language:** TypeScript
*   **UI:** React, Shadcn/ui, Tailwind CSS
*   **State Management:** React Hooks (`useState`, `useEffect`)
*   **Linting/Formatting:** ESLint (likely configured via `eslint.config.mjs`), Prettier (implied by auto-formatting)
*   **Package Manager:** npm (inferred from `package.json`, `package-lock.json`)
*   **Testing:** Jest (inferred from `jest.config.js`, `*.test.ts` files)

## Development Setup

*   Standard Next.js project structure.
*   Run locally using `npm run dev` (standard Next.js command).

## Technical Constraints

*   Requires a modern browser supporting `localStorage` API for the persistence feature.
*   JSON parsing relies on the standard `JSON.parse()` browser function.

## Dependencies

*   Key dependencies listed in `package.json`.
*   `@radix-ui/react-*` components (via Shadcn/ui).
*   `tailwind-merge`, `clsx` for utility class management.

## Tool Usage Patterns

*   **Browser `localStorage` API:** Used directly within `useEffect` hooks in `src/app/page.tsx` to store and retrieve `baseJson` and `actualJson` strings for persistence across page refreshes.
