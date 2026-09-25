# Contributing to jekyll-llm-sidecars

## Development Setup

### Prerequisites

- Ruby 3.3 or higher
- Bundler

### Clone and Setup

```bash
git clone https://github.com/Texarkanine/jekyll-llm-sidecars.git
cd jekyll-llm-sidecars
bundle install
```

### Running Tests

```bash
bundle exec rspec
```

### Mutation Testing

This project uses [Mutant](https://github.com/mbj/mutant) with the RSpec integration (`mutant-rspec`). Configuration lives in `config/mutant.yml` (`usage: opensource`). Goal: **100% mutation coverage**.

Confirm the suite passes under Mutant before analyzing mutations:

```bash
bundle exec mutant test
```

Run mutation analysis (prefer `--fail-fast` while iterating):

```bash
bundle exec mutant run --fail-fast
bundle exec mutant run
```

#### Alive Mutations

When a mutant survives, decide which bucket it falls into before changing anything:

- **A) The code does too much** for what the tests require. The surviving mutation reveals redundant behavior. Simplify the implementation.
- **B) A test is missing.** The behavior is intentional but no test observes it. Add an observing example.

If unsure, ask before choosing.

#### Constraints

- Keep the RSpec suite green (`bundle exec rspec`).
- An ignore is allowed only when a structure check has shown the variants cannot be told apart. Do not ignore a whole subject. Do not change `coverage_criteria`.
- Do not use `send` or `__send__` to invoke private methods in tests just to satisfy Mutant.
- Do not stub or mock the system under test (stub collaborators instead).

Done when both are green:

```bash
bundle exec rspec
bundle exec mutant run
```

Examples must be nested under `#method` or `.method` describes so Mutant can select them.

### Code Quality

```bash
bundle exec rubocop
```
