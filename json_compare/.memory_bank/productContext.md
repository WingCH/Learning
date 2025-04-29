# Product Context: JSON Compare App

## Problem Solved

Users comparing JSON structures often need to tweak inputs or refer back to them. Losing the input data on page refresh is inconvenient and disrupts the workflow, requiring users to re-paste potentially large JSON objects.

## How It Should Work

The application should automatically save the content of the "Base JSON" and "Actual JSON" input fields as the user types or pastes content. When the user revisits the page or refreshes it, the previously entered JSON data should automatically reappear in the respective input fields, allowing them to continue where they left off without data loss.

## User Experience Goals

*   **Seamless Persistence:** Users shouldn't need to explicitly save the input; it should happen automatically.
*   **Reliable Restoration:** Data entered should reliably reappear after a refresh or revisit.
*   **No Disruption:** The persistence mechanism should not interfere with the core comparison functionality or performance.
