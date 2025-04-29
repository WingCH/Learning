# System Patterns: JSON Compare App

## Core Architecture

*   **Frontend Framework:** Next.js (React)
*   **Component Structure:** Primarily a single-page application (`src/app/page.tsx`) using server components (`"use client"` directive for interactivity).
*   **UI Library:** Shadcn/ui (using components like Card, Button, Textarea, Table).
*   **State Management:** React `useState` hook for managing component-level state (JSON inputs, comparison results, errors).
*   **Comparison Logic:** Dedicated function `compareJsonStructure` in `src/lib/compareJsonStructure.ts`.

## Key Technical Decisions

*   **Client-Side Rendering for Interactivity:** Using `"use client"` to enable hooks (`useState`, `useEffect`) for managing input and results directly in the browser.
*   **Separation of Concerns:** Comparison logic is isolated in a separate library function.

## Design Patterns

*   **State Hook Pattern:** Using `useState` for managing UI state.
*   **Effect Hook Pattern:** Using `useEffect` for side effects, specifically:
    *   Loading initial state from `localStorage` on component mount.
    *   Saving state changes (`baseJson`, `actualJson`) to `localStorage` whenever they occur.
*   **Local Storage Persistence:** Utilizing the browser's `localStorage` API to persist user input (`baseJson`, `actualJson`) across page refreshes and sessions. This provides a simple, client-side persistence mechanism without requiring a backend.
