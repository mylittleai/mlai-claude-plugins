---
name: browser-observation
description: >
  This skill should be used when the user asks about browser debugging,
  frontend issues, visual bugs, CSS problems, layout issues, JavaScript errors,
  console output, DOM inspection, taking screenshots, or when Claude needs to
  observe a web page. Also triggers when the user mentions "change-observe loop",
  "screenshot", "console errors", "inspect element", "visual regression",
  "frontend debugging workflow", or when chrome-devtools MCP tools are available
  (take_screenshot, take_snapshot, navigate_page, list_pages, evaluate_script,
  list_console_messages). This skill is part of the mlai-glass plugin.

  <example>
  Context: User reports a visual bug
  user: "The button is misaligned on the login page"
  assistant: "Let me observe the page to diagnose this."
  <commentary>
  Visual bug report — trigger browser observation patterns for the change-observe-iterate loop.
  </commentary>
  </example>

  <example>
  Context: User asks Claude to check their web app
  user: "Can you see what's happening in the browser?"
  assistant: "I'll take a screenshot and check the console."
  <commentary>
  User wants browser observation — apply the observation decision tree.
  </commentary>
  </example>

  <example>
  Context: Claude is debugging a frontend change
  user: "I changed the CSS, does it look right now?"
  assistant: "Let me screenshot the page to verify."
  <commentary>
  Part of a change-observe-iterate loop — screenshot after change to verify.
  </commentary>
  </example>
version: 0.1.0
---

# Browser Observation Patterns

When you have access to chrome-devtools MCP tools, use these patterns to observe the browser effectively. The goal is to gather the right information without unnecessary round trips.

## The Observation Decision Tree

Before observing, decide what information you need:

**Start with the console** when:
- Something should have happened but didn't (event handler, API call, redirect)
- The user reports "it's not working" without a visual symptom
- After a page load, to catch errors before they're lost

**Start with a screenshot** when:
- The user reports a visual problem (layout, styling, alignment)
- You've just made a CSS or template change and need to verify
- You need to understand the current state of the page

**Start with DOM inspection** when:
- You need to check element attributes, classes, or data values
- You suspect a structural issue (wrong nesting, missing elements)
- You need to verify that a dynamic element was rendered

## The Change-Observe-Iterate Loop

When fixing a frontend issue, follow this cycle:

1. **Observe first** — screenshot + console before making any change. This is your baseline.
2. **Make one change** — modify a single thing (CSS rule, template element, JS logic).
3. **Observe again** — screenshot the same view. Compare to baseline.
4. **Evaluate** — did the change fix the issue? Did it introduce new problems?
5. **Iterate or commit** — if not fixed, revert and try a different approach. If fixed, check for side effects.

Do not batch multiple changes before observing. Each observation should verify exactly one change.

## Screenshot vs Snapshot

These are different tools for different purposes:

- **`take_screenshot`** — captures a visual image of the page (pixels). Use when you need to see what the user sees: layout, colors, alignment, visual regressions.
- **`take_snapshot`** — captures the DOM/accessibility tree (structured text). Use when you need to inspect element structure, attributes, classes, or find specific nodes. Faster and cheaper than a screenshot when you don't need visual information.

Rule of thumb: if the question is "does it look right?" → screenshot. If the question is "is it structured right?" → snapshot.

## Chrome Window Management

When chrome-devtools-mcp first launches Chrome, it may appear in front of your terminal. To keep it out of the way, use the glass window positioning command:

```
glass window position right
```

This moves Chrome to the right half of the screen. Options: `right`, `left`, `minimize`.

## Image Comparison

Your visual comparison of images is imprecise. Do not rely on comparing two screenshots by eye to judge whether they match — you will miss subtle differences and overstate similarities.

When you need to compare images programmatically (visual regression, matching a reference design, verifying an asset looks correct):

1. Save the expected image to a file (reference screenshot, design comp, etc.).
2. Take a screenshot and save it to a file.
3. Use ImageMagick `compare` via Bash:

```bash
compare -metric RMSE expected.png actual.png diff.png
```

4. Read the metric output. Lower RMSE = closer match. The diff image highlights differences in red.

**Useful metrics:**
- `RMSE` (root mean square error) — overall similarity, 0 = identical.
- `AE` (absolute error) — count of pixels that differ.
- `PHASH` (perceptual hash) — structural similarity, tolerates compression artifacts.

**When to use this:** any time the user provides a reference image to match, when verifying visual regressions, or when iterating on generated assets (SVG, icons, shaders) against a target.

**Prerequisite:** ImageMagick must be installed (`brew install imagemagick` on macOS, `apt install imagemagick` on Linux). Check with `compare --version` before relying on it.

## Multi-Scale Verification

When generating or modifying visual assets (SVGs, icons, favicons, logos), always verify at multiple sizes. Rendering artifacts — anti-aliasing seams, sub-pixel gaps between adjacent shapes, stroke overshoot at tangent points — often appear only at specific resolutions.

**Pattern:**
1. Generate the asset.
2. Screenshot or rasterize at small (32px), medium (256px), and large (512px+) sizes.
3. Check each size for seams, gaps, or unexpected artifacts.
4. If you find artifacts at one size, fix them and re-check all sizes — a fix at one scale can break another.

**Common traps:**
- Adjacent SVG polygons with no overlap → visible seam at high DPI. Fix: add a thin matching-colour stroke.
- Stroke added to fix seams → overshoot at tangent points (e.g., where a triangle meets a circle). Fix: use fill-only on shapes that must be tangent.
- Sub-pixel elements (r < 1 in a 64×64 viewBox) → invisible at display size but may confuse at other scales.

## Browser Connection Lifecycle

The chrome-devtools-mcp connection can go stale after long idle periods or context compaction. When this happens, the next MCP tool call may silently launch a second Chrome instance instead of reconnecting to the existing one.

**After any long pause or context resumption:**
1. Run `list_pages` to verify the connection is live and returns expected pages.
2. If `list_pages` fails, returns empty results, or shows unexpected pages — the connection is stale.
3. Tell the user if you suspect an orphaned Chrome instance. Do not silently work with a new one.

**Signs of a lost browser:**
- Two Chrome windows visible when there should be one.
- `list_pages` returns a blank new tab instead of the page you were working on.
- Screenshots show a different page than expected.

**Recovery:** Ask the user to close the orphaned Chrome window. The active chrome-devtools-mcp connection will continue working with the remaining instance.

## Common Pitfalls

**Screenshotting too early**: After navigating to a page, wait for the page to finish loading before taking a screenshot. Use `wait_for` if available, or check that key elements have rendered.

**Ignoring console errors**: Always check `list_console_messages` after page load. JavaScript errors often explain why something looks wrong.

**Not checking the right page**: Use `list_pages` to verify which tab/page you're looking at before taking actions. Multi-tab scenarios are common during development.

**Over-observing**: Don't take a screenshot after every tiny change. Group related observations — e.g., after changing a component, screenshot the page that uses it, not every page in the app.

## Tool Quick Reference

| Need | Tool | When |
|------|------|------|
| See the page | `take_screenshot` | After changes, to verify visual state |
| Check for errors | `list_console_messages` | After page load, after interactions |
| Read a specific error | `get_console_message` | When you see an error in the list |
| Find an element | `take_snapshot` | To inspect DOM structure |
| Run JS in page | `evaluate_script` | To check values, trigger actions |
| Go to a URL | `navigate_page` | To load or reload a page |
| Wait for state | `wait_for` | Before screenshotting dynamic content |
| Check network | `list_network_requests` | When API calls might be failing |
| See tabs | `list_pages` | To verify which page is active |
