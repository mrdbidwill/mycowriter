# Gem JavaScript Integration Pattern

**Date**: 2026-02-24
**Issue**: mycowriter gem JavaScript not loading
**Root Cause**: Missing JavaScript copy step in install generator
**Resolution**: Updated gem to v0.1.9 with correct pattern

---

## Problem Statement

The mycowriter gem was not working as "plug and play" because its JavaScript controller was not accessible to the host Rails application's importmap system.

### Symptoms
- Error: `The specifier "mycowriter/autocomplete_controller" was a bare specifier, but was not remapped to anything`
- Gem's JavaScript stayed in gem directory, inaccessible to importmap
- Required manual workarounds (copying files, complex importmap configuration)
- Did NOT match the pattern used by sister gem auto_glossary

---

## Investigation Process

### Step 1: Compare with auto_glossary

**auto_glossary (WORKING PATTERN)**:
```ruby
# lib/generators/auto_glossary/install/install_generator.rb
def copy_javascript
  template "glossary_controller.js", "app/javascript/controllers/glossary_controller.js"
end
```

**mycowriter (BROKEN - before fix)**:
```ruby
# lib/generators/mycowriter/install/install_generator.rb
# ❌ NO copy_javascript method!
```

### Step 2: Verify mrdbid Implementation

Checked how mrdbid (production app) uses both gems:

```bash
$ ls /mrdbid/app/javascript/controllers/
glossary_controller.js                    # ← from auto_glossary
mycowriter_autocomplete_controller.js     # ← from mycowriter
```

Both gems' JavaScript files are COPIED into the host app's controllers directory.

### Step 3: Understand Rails Importmap + Stimulus Pattern

**How it works**:
1. `config/importmap.rb` contains: `pin_all_from "app/javascript/controllers", under: "controllers"`
2. This automatically makes ALL controllers in that directory available
3. Stimulus auto-loads controllers based on naming: `mycowriter-autocomplete` → `mycowriter_autocomplete_controller.js`
4. NO manual imports needed in `application.js`
5. NO special importmap pins needed

**Why this is "plug and play"**:
- Generator copies file during `rails g mycowriter:install`
- File is immediately available via importmap
- Stimulus finds it automatically
- Just works™

---

## The Fix

### Changes to mycowriter Gem (v0.1.9)

**1. Updated install generator** (`lib/generators/mycowriter/install/install_generator.rb`):
```ruby
def copy_javascript
  template "autocomplete_controller.js", "app/javascript/controllers/mycowriter_autocomplete_controller.js"
end
```

**2. Added controller template** (`lib/generators/mycowriter/install/templates/autocomplete_controller.js`):
- Copied from `app/javascript/mycowriter/autocomplete_controller.js`
- Now available as generator template

**3. Updated README** (removed manual import instructions):
```
OLD (incorrect):
3. Import your controller in app/javascript/controllers/application.js:
   import MycowriterAutocomplete from "mycowriter/autocomplete_controller"
   application.register("mycowriter--autocomplete", MycowriterAutocomplete)

NEW (correct):
1. Restart your Rails server to load the new Stimulus controller
```

**4. Updated controller name format**:
```
OLD: mycowriter--autocomplete (double-dash, engine namespace pattern)
NEW: mycowriter-autocomplete (single-dash, matches file naming)
```

**5. Bumped version**: `0.1.8` → `0.1.9`

---

## Pattern Comparison

### ❌ WRONG (Engine JavaScript Pattern)

```ruby
# Gem provides JS in gem directory
# app/javascript/mycowriter/autocomplete_controller.js

# Expects manual import:
import MycowriterAutocomplete from "mycowriter/autocomplete_controller"
application.register("mycowriter--autocomplete", MycowriterAutocomplete)

# Problems:
# - Not accessible to importmap
# - Requires complex configuration
# - Not plug and play
# - Doesn't match Rails conventions
```

### ✅ CORRECT (Copy to Controllers Pattern)

```ruby
# Generator copies JS to host app
# → app/javascript/controllers/mycowriter_autocomplete_controller.js

# Stimulus auto-loads via naming convention:
# data-controller="mycowriter-autocomplete"
# ↓
# looks for: mycowriter_autocomplete_controller.js
# ↓
# finds it! (already copied by generator)

# Benefits:
# - Plug and play
# - No manual imports
# - Matches Rails conventions
# - Same pattern as auto_glossary
```

---

## Correct Usage (Post-Fix)

### Installation
```bash
# Add to Gemfile
gem 'mycowriter', '~> 0.1.9'

# Install
bundle install
rails generate mycowriter:install

# That's it! JavaScript is now in app/javascript/controllers/
```

### In Views
```erb
<div data-controller="mycowriter-autocomplete"
     data-mycowriter-autocomplete-url-value="<%= mycowriter.genera_autocomplete_path %>"
     data-mycowriter-autocomplete-kind-value="genera">

  <input data-mycowriter-autocomplete-target="input" minlength="4" />
  <ul data-mycowriter-autocomplete-target="dropdown"></ul>
  <div data-mycowriter-autocomplete-target="list"></div>
</div>
```

### No Application.js Changes Needed!
```javascript
// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }

// ✅ No manual imports!
// ✅ No manual registration!
// ✅ Stimulus finds controllers automatically!
```

---

## Naming Conventions

### Stimulus Controller Naming
- **File name**: `mycowriter_autocomplete_controller.js` (underscore)
- **data-controller**: `mycowriter-autocomplete` (single-dash)
- **data attributes**: `data-mycowriter-autocomplete-target="input"` (single-dash)

### Why Single-Dash Not Double-Dash?

**Double-dash (--) pattern** is for:
- Namespaced engines exposing controllers
- When JavaScript stays in gem directory
- Example: `mycowriter--autocomplete` means "autocomplete controller in mycowriter namespace"

**Single-dash (-) pattern** is for:
- Controllers copied to host app
- Standard Stimulus naming convention
- Example: `mycowriter-autocomplete` is just a descriptive name with dash

Since we're COPYING the controller to the host app (not keeping it in gem namespace), we use single-dash.

---

## Files Changed in mycowriter.com Website

### Removed Workarounds
- ❌ Deleted `app/javascript/mycowriter/` directory (workaround)
- ❌ Removed manual import from `app/javascript/controllers/application.js`
- ❌ Removed custom importmap pin from `config/importmap.rb`

### Added Correct Implementation
- ✅ Copied `mycowriter_autocomplete_controller.js` to `app/javascript/controllers/`
- ✅ Updated all views to use `data-controller="mycowriter-autocomplete"`
- ✅ Updated all data attributes to use single-dash format

### Files Updated
1. `app/views/pages/demo.html.erb`
2. `app/views/pages/gem_docs.html.erb`
3. `PROJECT_CONTEXT.md`
4. `CODING_STANDARDS.md`

---

## Gem Comparison Matrix

| Aspect | auto_glossary | mycowriter (OLD) | mycowriter (NEW) |
|--------|---------------|------------------|------------------|
| Generator copies JS | ✅ Yes | ❌ No | ✅ Yes |
| File location | `controllers/` | `gem/` | `controllers/` |
| Manual import needed | ❌ No | ✅ Yes | ❌ No |
| Plug and play | ✅ Yes | ❌ No | ✅ Yes |
| Controller name | `glossary` | `mycowriter--autocomplete` | `mycowriter-autocomplete` |
| Version | 0.1.1 | 0.1.8 | 0.1.9 |

---

## Lessons Learned

### 1. Follow Established Patterns
When creating similar gems, use the SAME pattern. auto_glossary and mycowriter should work identically.

### 2. Rails Engine JavaScript is Complex
Keeping JavaScript in gem directory requires:
- Custom importmap configuration
- Manual imports
- Complex setup
- NOT beginner-friendly

### 3. Copy Pattern is Better for Simple Gems
For Stimulus controllers:
- Copy to host app during installation
- Let Stimulus auto-loading handle it
- Much simpler for users

### 4. Test Both Gems Together
If mrdbid uses both gems, ensure they follow the same pattern. Inconsistency creates confusion.

### 5. Generator Templates are Key
The `lib/generators/[gem]/install/templates/` directory is crucial. Include ALL files users need.

---

## Testing Checklist

### For Gem Developers
- [ ] Install generator copies JavaScript to `app/javascript/controllers/`
- [ ] File naming matches Stimulus conventions (underscore)
- [ ] data-controller name uses single-dash
- [ ] No manual imports required in application.js
- [ ] No custom importmap pins required
- [ ] README shows correct usage (no manual setup)
- [ ] Works immediately after `rails g [gem]:install`

### For Website Developers
- [ ] Remove all workarounds
- [ ] Use controller name matching copied file
- [ ] No manual imports in application.js
- [ ] No custom importmap configuration
- [ ] Restart server and test
- [ ] Verify browser console shows no errors

---

## Migration Path for Existing Users

If you installed mycowriter v0.1.8 or earlier:

### Option A: Update to 0.1.9 (Recommended)
```bash
# Update Gemfile
gem 'mycowriter', '~> 0.1.9'

# Install
bundle update mycowriter
rails generate mycowriter:install

# Remove manual imports from application.js
# Remove custom importmap pins

# Update views: mycowriter--autocomplete → mycowriter-autocomplete
```

### Option B: Manual Copy (If Can't Update Gem)
```bash
# Copy controller manually
cp $(bundle show mycowriter)/app/javascript/mycowriter/autocomplete_controller.js \
   app/javascript/controllers/mycowriter_autocomplete_controller.js

# Remove manual imports from application.js
# Remove custom importmap pins

# Update views: mycowriter--autocomplete → mycowriter-autocomplete
```

---

## Future Considerations

### For New Gems
1. **Always copy JavaScript in generator**
2. **Follow Stimulus naming conventions**
3. **Test with importmap (most common setup)**
4. **Keep README simple** - no manual setup steps
5. **Match patterns from sister gems**

### For Engine Gems with Complex JavaScript
If gem has:
- Multiple JavaScript files
- JavaScript dependencies
- Shared modules

Consider:
- npm package distribution
- Webpacker/esbuild setup
- Or still copy, but document clearly

### Documentation Standards
- Show COMPLETE working examples
- Include data-controller naming
- Show file structure expectations
- Mention Rails/Stimulus versions

---

## Related Documentation

- `PROJECT_CONTEXT.md` - Full project background
- `CODING_STANDARDS.md` - Section 5: Mycowriter Gem Usage Pattern
- auto_glossary gem: `/auto_glossary_gem/auto_glossary/`
- mycowriter gem: `/mycowriter_gem/mycowriter/`

---

**Status**: ✅ RESOLVED
**Gem Version**: 0.1.9
**Website**: Updated to match pattern
**Pattern**: Matches auto_glossary (plug and play)
