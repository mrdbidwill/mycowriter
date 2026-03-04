# Mycowriter

Mycowriter is a standalone Ruby gem (Rails engine) that provides intelligent, inline autocomplete for fungal genus and species names using MycoBank data.

## Features

- Inline autocomplete in textareas at the cursor position
- Two-stage genus then species suggestions
- Debounced search for responsive typing
- Configurable minimum characters, uppercase enforcement, and result limits
- Engine-mounted JSON endpoints for autocomplete

## Requirements

- Ruby 3.2 or higher
- Rails 7.0 or higher

## Installation

1. Add the gem to your Gemfile:

```ruby
gem "mycowriter", "~> 0.1.11"
```

2. Install and run the generator:

```bash
bundle install
rails generate mycowriter:install
```

The installer will:

- Create `config/initializers/mycowriter.rb`
- Mount the engine at `/mycowriter`
- Copy the Stimulus controller to `app/javascript/controllers/inline_autocomplete_controller.js`

Restart your Rails server after installation.

## Database setup

Mycowriter supports two data sources:

1. Existing `Genus` and `Species` models in your app (preferred)
2. An `mb_lists` table populated with MycoBank data

To generate the optional `mb_lists` table:

```bash
rails generate mycowriter:mb_lists_migration
rails db:migrate
```

Minimum columns: `id`, `taxon_name`. Optional: `rank_name`, `name_status`.

### MycoBank data and attribution

MycoBank data is licensed under Creative Commons CC BY-NC-ND and requires attribution:

```
MBList taxonomic data provided by MycoBank (www.mycobank.org)
```

## Usage

Add the controller to any textarea where you want inline autocomplete:

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

The controller inserts the selected name at the cursor position. Customize formatting in your app as needed.

## Configuration

Edit `config/initializers/mycowriter.rb`:

```ruby
Mycowriter.configure do |config|
  config.min_characters = 4
  config.require_uppercase = true
  config.results_limit = 20
end

Rails.application.config.to_prepare do
  Mycowriter::AutocompleteController.class_eval do
    skip_after_action :verify_authorized, raise: false
    skip_after_action :verify_policy_scoped, raise: false
    skip_before_action :authenticate_user!, raise: false if respond_to?(:authenticate_user!)
  end
end
```

## Routes

The gem provides:

```
GET /mycowriter/autocomplete/genera
GET /mycowriter/autocomplete/species
```

## License

The gem is available under the MIT License.
