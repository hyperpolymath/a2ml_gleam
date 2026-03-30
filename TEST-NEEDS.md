# Test & Benchmark Requirements

## Current State
- Unit tests: 1 test file (a2ml_gleam_test.gleam) — count unknown (gleam not installed)
- Integration tests: NONE
- E2E tests: NONE
- Benchmarks: NONE
- panic-attack scan: NEVER RUN

## What's Missing
### Point-to-Point (P2P)
- a2ml_gleam.gleam (main module) — possibly tested but coverage unknown
- a2ml_gleam/types.gleam — no dedicated tests
- a2ml_gleam/parser.gleam — likely undertested (parsing is complex)
- a2ml_gleam/renderer.gleam — likely undertested
- tests/fuzz/ directory contains only placeholder.txt — no fuzzing

### End-to-End (E2E)
- Parse and render round-trip
- Error handling for malformed A2ML input
- Cross-implementation compatibility (output should match a2ml_ex, a2ml-rs)

### Aspect Tests
- [ ] Security (untrusted input handling)
- [ ] Performance (large document parsing)
- [ ] Concurrency (Gleam/BEAM actor safety)
- [ ] Error handling (Result types properly propagated)
- [ ] Accessibility (N/A)

### Build & Execution
- [ ] gleam build — not verified (gleam 1.7.0 not installed)
- [ ] gleam test — not verified
- [ ] Self-diagnostic — none

### Benchmarks Needed
- Parse throughput vs other A2ML implementations
- BEAM vs JS target performance comparison

### Self-Tests
- [ ] panic-attack assail on own repo
- [ ] Built-in doctor/check command (if applicable)

## Priority
- **MEDIUM** — Small library (4 source modules) with 1 test file. Fuzz directory is empty. Cannot verify tests run without correct gleam version.
