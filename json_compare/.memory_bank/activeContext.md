# Active Context: JSON Compare App

## Current Focus

Implementing persistence for user input (Base JSON and Actual JSON) using browser `localStorage`.

## Recent Changes

*   Modified `src/app/page.tsx`:
    *   Imported `useEffect` hook.
    *   Added a `useEffect` hook to load `baseJson` and `actualJson` from `localStorage` on component mount.
    *   Added `useEffect` hooks to save `baseJson` and `actualJson` to `localStorage` whenever their respective state variables change.
*   Created initial Memory Bank files:
    *   `projectbrief.md`
    *   `productContext.md`
    *   `systemPatterns.md`
    *   `techContext.md`

## Next Steps

1.  Create `progress.md` to finalize the initial Memory Bank setup for this feature.
2.  Inform the user about the completion of the persistence feature implementation.

## Active Decisions & Considerations

*   Chose `localStorage` for simplicity and client-side scope, suitable for non-sensitive temporary data persistence.
*   Ensured `localStorage` items are cleared if the corresponding input field becomes empty.

## Important Patterns & Preferences

*   Utilize React Hooks (`useState`, `useEffect`) for state management and side effects.
*   Maintain separation of concerns (UI logic in `page.tsx`, core comparison in `lib/`).
*   Keep Memory Bank documentation updated with changes.

## Learnings & Insights

*   Implementing persistence with `useEffect` and `localStorage` in React/Next.js is straightforward for basic use cases.
