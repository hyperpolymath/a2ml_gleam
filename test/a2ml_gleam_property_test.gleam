// SPDX-License-Identifier: MPL-2.0
// (PMPL-1.0-or-later preferred; MPL-2.0 required for Hex.pm)
//
// a2ml_gleam_property_test — Property-based tests for A2ML parser/renderer.
//
// Validates determinism, idempotency, and structural invariants across
// a range of inputs without relying on external property-testing libraries.

import gleam/list
import a2ml_gleam/parser
import a2ml_gleam/renderer
import a2ml_gleam/types.{Automated, Reviewed, Unverified, Verified}

// ---------------------------------------------------------------------------
// Property: parse is deterministic — same input always produces same output
// ---------------------------------------------------------------------------

pub fn parse_is_deterministic_test() {
  let input = "# Determinism Test\n\n@version 1.0\n\nA test paragraph."

  let result1 = parser.parse(input)
  let result2 = parser.parse(input)
  assert result1 == result2
}

// ---------------------------------------------------------------------------
// Property: parse determinism over 20 calls (manual property loop)
// ---------------------------------------------------------------------------

pub fn parse_deterministic_20_calls_test() {
  let input = "# Loop Test\n\n@version 2.0\n\nHello, A2ML!"

  let first = parser.parse(input)

  list.range(from: 1, to: 20)
  |> list.each(fn(_) {
    let result = parser.parse(input)
    assert result == first
  })
}

// ---------------------------------------------------------------------------
// Property: render is deterministic — same document always renders identically
// ---------------------------------------------------------------------------

pub fn render_is_deterministic_test() {
  let input = "# Render Prop\n\n@version 1.0\n\nParagraph."

  let assert Ok(doc) = parser.parse(input)
  let out1 = renderer.render(doc)
  let out2 = renderer.render(doc)
  assert out1 == out2
}

// ---------------------------------------------------------------------------
// Property: all valid trust level strings round-trip
// ---------------------------------------------------------------------------

pub fn trust_level_strings_roundtrip_test() {
  let assert Ok(Unverified) = parser.parse_trust_level("unverified")
  let assert Ok(Automated) = parser.parse_trust_level("automated")
  let assert Ok(Reviewed) = parser.parse_trust_level("reviewed")
  let assert Ok(Verified) = parser.parse_trust_level("verified")

  assert renderer.render_trust_level(Unverified) == "unverified"
  assert renderer.render_trust_level(Automated) == "automated"
  assert renderer.render_trust_level(Reviewed) == "reviewed"
  assert renderer.render_trust_level(Verified) == "verified"
}

// ---------------------------------------------------------------------------
// Property: roundtrip preserves document title
// ---------------------------------------------------------------------------

pub fn roundtrip_preserves_title_test() {
  let titles = ["Hello World", "My Report", "AI Document 2026", "Test"]

  list.each(titles, fn(title) {
    let input = "# " <> title <> "\n\n@version 1.0\n\nContent."
    let assert Ok(doc1) = parser.parse(input)
    let rendered = renderer.render(doc1)
    let assert Ok(doc2) = parser.parse(rendered)
    assert doc1.title == doc2.title
  })
}

// ---------------------------------------------------------------------------
// Property: invalid trust level strings never produce Ok
// ---------------------------------------------------------------------------

pub fn invalid_trust_levels_never_ok_test() {
  let invalid = [
    "none", "all", "safe", "high", "low", "admin",
    "unknown", "", "trusted", "reviewed1", "aut0mated",
  ]

  list.each(invalid, fn(name) {
    let result = parser.parse_trust_level(name)
    let assert Error(_) = result
  })
}

// ---------------------------------------------------------------------------
// Property: directives count is preserved across roundtrip
// ---------------------------------------------------------------------------

pub fn directives_count_preserved_roundtrip_test() {
  let input =
    "# Multi-Directive\n\n@version 1.5\n\n@author Alice\n\n@license MPL-2.0"

  let assert Ok(doc1) = parser.parse(input)
  assert list.length(doc1.directives) == 3

  let rendered = renderer.render(doc1)
  let assert Ok(doc2) = parser.parse(rendered)
  assert list.length(doc1.directives) == list.length(doc2.directives)
}
