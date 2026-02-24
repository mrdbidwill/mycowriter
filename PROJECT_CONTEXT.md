# MycoWriter.com Project Context

## ⚠️ CRITICAL: Required Reading for All AI Assistants

This document provides essential context about the mycowriter.com project. **All AI assistants must read this file before making any code changes or recommendations.**

---

## Project Identity

### What This Project Is
- **This is the promotional/demo website for the mycowriter Ruby gem**
- The actual gem code is at: `/Users/wrj/Documents/www/public_html/mycowriter_gem/mycowriter/`
- Gem repository (GitHub): https://github.com/mrdbidwill/mycowriter
- Published on rubygems.org: https://rubygems.org/gems/mycowriter
- Current gem version: 0.1.11
- Website domain: mycowriter.com
- Parent project: mrdbid (`/Users/wrj/Documents/www/public_html/mrdbid`)
- **Shares database with mrdbid**: Both apps use `mrdbid_development` database
- **Server location**: Hostinger VPS at 85.31.233.192 (same server as mrdbid)
- **Data structure**: Uses normalized Genus/Species models (not mb_lists fallback)

### What This Project Is NOT
- This is NOT a standalone application
- This is NOT the gem itself (gem is in separate directory)
- This should NOT have duplicate implementations of gem functionality

---

## Project History & Purpose

### Origin
- Extracted from the mrdbid project as a standalone Rails engine gem
- Developed alongside auto_glossary gem (sister project)
- Both gems created to provide reusable mycology tools for Rails applications

### Primary Function
**Autocomplete tool for fungal genus and species names**
- Acts as a spell checker for complex taxonomic names
- Provides memory aid for hard-to-remember scientific names
- Uses MycoBank taxonomic data from the `mb_lists` database table
- Supports intelligent filtering and ranking of results

### Related Projects
1. **mrdbid** - Parent project, primary user of mycowriter gem
   - Location: `/Users/wrj/Documents/www/public_html/mrdbid`
   - Uses: `gem 'mycowriter', '~> 0.1.8'`
   - Reference implementation for correct gem usage

2. **auto_glossary** - Sister gem for mycology term definitions
   - Provides Wikipedia Glossary of Mycology integration
   - Also has promotional website similar to this project
   - Published on rubygems.org

---

## Scientific Naming Rules (Essential Context)

### Binomial Nomenclature Formatting

Understanding these rules is critical for working with this project:

#### Capitalization
- **Genus name**: ALWAYS starts with a capital letter
  - Examples: Agaricus, Russula, Boletus, Cantharellus
  - Never: agaricus, russula (invalid)

- **Species epithet**: ALWAYS lowercase
  - Examples: campestris, edulis, deliciosus
  - Never: Campestris, Edulis (invalid)

#### Styling
- **When typed**: Always italicized
  - Example: *Agaricus campestris*, *Boletus edulis*
- **When handwritten**: Always underlined
  - Example: <u>Agaricus campestris</u>

#### Abbreviation
- After first mention in text, genus can be abbreviated to first initial
  - First use: *Agaricus campestris*
  - Subsequent: *A. campestris*
  - Also common: *T. rex* for *Tyrannosaurus rex*

#### Language
- All names treated as Latin, regardless of actual origin
- Names may derive from people, places, or descriptions
- Latin grammar rules apply for word endings

### Why This Matters for the Project
The mycowriter gem validates and enforces these rules:
- Requires uppercase first letter for genus names (`require_uppercase: true`)
- Provides user feedback for capitalization errors
- Filters and ranks results based on taxonomic structure
- Maintains proper binomial format in autocomplete results

---

## Critical Architecture Rule

### THE GOLDEN RULE
**This website MUST use the actual mycowriter gem to demonstrate functionality**

### What This Means
1. ✅ **DO**: Install gem via Gemfile
2. ✅ **DO**: Mount engine in routes.rb
3. ✅ **DO**: Use gem's controllers, routes, and JavaScript
4. ✅ **DO**: Keep documentation synchronized with gem's actual API
5. ✅ **DO**: Reference mrdbid project for correct usage examples

6. ❌ **DON'T**: Create duplicate autocomplete implementations
7. ❌ **DON'T**: Copy/paste gem code into this app
8. ❌ **DON'T**: Show documentation for features that don't exist in gem
9. ❌ **DON'T**: Modify gem files directly (they're in separate directory)

### Why This Rule Exists
- **Primary purpose**: This is a promotional/demo website
- **User expectation**: Code shown = code in gem
- **Trust**: Misleading documentation damages credibility
- **Maintenance**: Duplicates require syncing (error-prone)

---

## Known Cross-Contamination Risks

### The Problem
Both mycowriter and auto_glossary were developed simultaneously and share similar patterns. This can lead to confusion.

### Warning Signs
- Documentation mentioning "glossary" instead of "autocomplete"
- References to "terms" instead of "genus/species"
- Controller names from wrong gem
- Route paths that don't match gem structure

### When In Doubt
1. Check the actual gem code at: `/Users/wrj/Documents/www/public_html/mycowriter_gem/mycowriter/`
2. Verify against mrdbid's working implementation
3. Cross-reference with gem's README.md
4. Ask the user before making assumptions

---

## Gem Technical Structure

### Rails Engine Details
- **Type**: Rails Engine with isolated namespace
- **Namespace**: `Mycowriter::`
- **Mount point**: `/mycowriter`
- **Installation**: `rails generate mycowriter:install`

### Routes Provided
```ruby
GET /mycowriter/autocomplete/genera   → mycowriter.genera_autocomplete_path
GET /mycowriter/autocomplete/species  → mycowriter.species_autocomplete_path
```

### Controllers
- `Mycowriter::AutocompleteController` (namespaced)
- Handles JSON responses for autocomplete queries
- Supports both `Genus`/`Species` models AND `mb_lists` table fallback

### JavaScript
- **Stimulus controller**: `inline-autocomplete` (single-dash naming)
- **Installation**: Copies to `app/javascript/controllers/inline_autocomplete_controller.js`
- Provides inline text autocomplete at cursor position in textareas
- Supports two-stage completion: genus first, then species
- Supports debounced search and keyboard navigation
- Inserts complete binomial name with proper formatting

### Database Requirements & Architecture
The gem works with:
1. **Option A**: Host app's `Genus` and `Species` models (preferred) ✅ **USED BY THIS PROJECT**
2. **Option B**: `mb_lists` table (fallback)

**This website and mrdbid share the `mrdbid_development` database:**
- Both apps on same VPS (85.31.233.192)
- Ensures data consistency between demo site and production app
- Uses normalized `genera` and `species` tables (18,860 genera, 380,605 species)
- `mb_lists` table provides source data (537,509 MycoBank records)
- Simpler maintenance: one database to backup/manage

**Database tables used:**
- `genera`: Genus names (e.g., "Agaricus", "Ganoderma")
- `species`: Species epithets with `genera_id` foreign key (e.g., "campestris" → Agaricus)
- `mb_lists`: Complete MycoBank data (taxon_name, rank_name, name_status, authors, etc.)

**Schema Management:**
- This website has NO `db/migrate/` directory
- Schema is managed by mrdbid project only
- mycowriter.com is schema-less: just uses existing tables via models
- Clean separation: demo site doesn't alter database structure

### Configuration
The gem is configurable via initializer:
```ruby
Mycowriter.configure do |config|
  config.min_characters = 4      # Min chars before autocomplete triggers
  config.require_uppercase = true # Enforce capitalization for genus names
  config.results_limit = 20      # Max results returned
end
```

---

## Working Reference Implementation

### See mrdbid Project
Location: `/Users/wrj/Documents/www/public_html/mrdbid`

**Gemfile**:
```ruby
gem 'mycowriter', '~> 0.1.10'    # Genus/species autocomplete
```

**config/routes.rb**:
```ruby
mount Mycowriter::Engine => "/mycowriter"
```

**Installation**:
```bash
bundle install
rails generate mycowriter:install
```

**Usage in views (inline text autocomplete)**:
```erb
<div data-controller="inline-autocomplete"
     data-inline-autocomplete-genus-url-value="<%= mycowriter.genera_autocomplete_path %>"
     data-inline-autocomplete-species-url-value="<%= mycowriter.species_autocomplete_path %>"
     data-inline-autocomplete-min-value="4">
  <%= f.text_area :body,
      data: {
        inline_autocomplete_target: "textarea",
        action: "input->inline-autocomplete#onInput keydown->inline-autocomplete#onKeydown"
      },
      class: "form-textarea" %>
  <div data-inline-autocomplete-target="dropdown" class="hidden"></div>
</div>
```

---

## Data Attribution Requirements

### MycoBank License
The taxonomic data used by this gem comes from MycoBank and is licensed under:

**Creative Commons CC BY-NC-ND**

- **BY (Attribution)**: Credit must be given to MycoBank
- **NC (Non-Commercial)**: Non-commercial use only
- **ND (No Derivatives)**: Data used in unadapted form only

### Required Attribution
Any website or application using the mycowriter gem MUST display:

> "MBList taxonomic data provided by MycoBank (www.mycobank.org)"

This website includes this attribution in:
- Footer
- Documentation pages
- API documentation

---

## Development Guidelines

### Before Making Changes
1. Read this document completely
2. Check if change affects gem vs. website
3. Verify against mrdbid's implementation
4. Review CODING_STANDARDS.md for project-specific rules

### When Adding Features
- Features belong in the gem, not this website
- Website should only demo existing gem features
- Consult user before adding website-only features

### When Updating Documentation
- Changes MUST match gem's actual API
- Verify against gem's README.md
- Test examples work with real gem code
- Update both demo.html.erb and gem_docs.html.erb

### When Encountering Errors
- Check if gem is properly installed (Gemfile)
- Verify engine is mounted (routes.rb)
- Confirm Stimulus controller registered (application.js)
- Compare with mrdbid's working implementation
- Do NOT create workarounds that bypass the gem

---

## File Structure & Locations

### This Project (Website)
```
/Users/wrj/Documents/www/public_html/mycowriter/
├── app/views/pages/
│   ├── demo.html.erb          # Main demo page
│   └── gem_docs.html.erb      # Gem documentation
├── Gemfile                     # Must include mycowriter gem
├── config/routes.rb            # Must mount Mycowriter::Engine
└── PROJECT_CONTEXT.md          # This file
```

### The Actual Gem
```
/Users/wrj/Documents/www/public_html/mycowriter_gem/mycowriter/
├── app/
│   ├── controllers/mycowriter/autocomplete_controller.rb
│   └── javascript/mycowriter/autocomplete_controller.js
├── lib/
│   ├── mycowriter.rb
│   ├── mycowriter/engine.rb
│   └── generators/mycowriter/install/
├── config/routes.rb
├── mycowriter.gemspec
└── README.md
```

### Reference Implementation
```
/Users/wrj/Documents/www/public_html/mrdbid/
└── (see above for key files)
```

---

## Common Scenarios

### Scenario 1: User Asks to "Add Autocomplete Feature"
**Wrong**: Create new controller in this app
**Right**: Check if feature exists in gem, if not, propose gem enhancement

### Scenario 2: "Autocomplete Not Working"
**Check**:
1. Is gem in Gemfile? (`gem 'mycowriter'`)
2. Is engine mounted? (`mount Mycowriter::Engine`)
3. Is Stimulus controller registered?
4. Are routes using correct paths? (`/mycowriter/autocomplete/*`)
5. Are controller names correct? (`mycowriter-autocomplete`)

### Scenario 3: "Update Documentation"
**Steps**:
1. Read gem's README.md first
2. Verify against gem's actual code
3. Test example code works with gem
4. Update website docs to match
5. Never document features that don't exist in gem

### Scenario 4: "Fix a Bug"
**Determine**:
- Bug in gem? → Needs fix in gem repository, not here
- Bug in website's gem usage? → Fix website's integration
- Bug in documentation? → Update docs to match gem reality

---

## Version History

### Current State (2026-02-24)
- Gem version: 0.1.10
- Rails version: 8.0.4
- Status: Website properly uses gem with inline autocomplete

### Previous State (Issue - Fixed)
- Website had duplicate autocomplete implementation
- Was using token/pill controller instead of inline text controller
- Not using actual gem
- Documentation didn't match reality
- **Fixed in version 0.1.10**

---

## Support & Questions

### For Questions About This Website
- Check mrdbid project for working examples
- Review CODING_STANDARDS.md for project rules
- Consult this PROJECT_CONTEXT.md for architecture decisions

### For Questions About the Gem
- Read gem's README.md at `/mycowriter_gem/mycowriter/README.md`
- Check gem's source code
- Test against mrdbid's implementation
- User (Will Johnston) is the gem author

### For Questions About Scientific Naming
- Refer to "Scientific Naming Rules" section above
- Check MycoBank documentation: https://www.mycobank.org
- International Code of Nomenclature for algae, fungi, and plants (ICN)

---

## Changelog

### 2026-02-24
- Initial creation of PROJECT_CONTEXT.md
- Documented project identity, history, and purpose
- Added scientific naming rules and requirements
- Established critical architecture rules
- Added reference to mrdbid implementation
- Included gem technical structure details
- Created common scenarios guide

---

**Last Updated**: 2026-02-24
**Document Version**: 1.0
**Maintained By**: Will Johnston (mrdbidwill@gmail.com)
