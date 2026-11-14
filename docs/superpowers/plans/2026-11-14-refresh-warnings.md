# Refresh warning visibility implementation plan

**Goal:** Persistently hide scan-warning notices from both launchers with a reversible option.
**Architecture:** Add hideRefreshWarnings=false to existing presentation preferences. CatalogModel derives visible scan warnings and launcher notice priority without deleting raw diagnostics. Use existing native bindings and menu actions.
**Authorization:** User directly requested option; small extension of approved architecture, assumptions recorded in Architecture.md/Feasibility.md. Existing branch/workspace retained.

- [x] Add real persistence/menu regressions for legacy defaults, hide/show round-trip, retained raw diagnostics and unsuppressed important notices; observe failure.
- [x] Add defaulted decoder, guarded model edit, native menu toggle and launcher Hide button. Manage exposes setting and retains collapsed warnings for inspection.
- [x] Full Xcode suite, native isolated hide/restart/re-enable check, Debug/Release and new local package verification.
- [x] Update Help, governance records and handoff, lessons only if an actual correction emerges; preserve user choices and prior test build; commit.
