# Contributing to OrionX Ruby SDK

Thank you for your interest in contributing to the OrionX Ruby SDK! This document provides guidelines for contributing to this project.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to see if the problem has already been reported. When creating a bug report, please include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Ruby version and gem version
- Any relevant error messages or logs

### Suggesting Features

Feature requests are welcome! Please provide:

- A clear and descriptive title
- A detailed description of the proposed feature
- Use cases and examples
- Any relevant implementation details

### Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Run RuboCop and fix any style issues
7. Update documentation as needed
8. Submit a pull request

## Development Setup

```bash
git clone https://github.com/PabloB07/orionx-sdk-ruby.git
cd orionx-sdk-ruby
bundle install
```

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage report
COVERAGE=true bundle exec rspec

# Run specific test file
bundle exec rspec spec/client_spec.rb

# Run specific test
bundle exec rspec spec/client_spec.rb:15
```

## Code Style

This project uses RuboCop for code formatting and style enforcement:

```bash
# Check for style issues
bundle exec rubocop

# Auto-fix issues where possible
bundle exec rubocop -A

# Check specific files
bundle exec rubocop lib/orionx/client.rb
```

## Writing Tests

- All new features must include tests
- Tests should be written using RSpec
- Use descriptive test names and contexts
- Mock external API calls using WebMock
- Aim for high test coverage

Example test structure:

```ruby
RSpec.describe OrionX::NewFeature do
  describe "#new_method" do
    context "when given valid parameters" do
      it "returns expected result" do
        # Test implementation
      end
    end

    context "when given invalid parameters" do
      it "raises validation error" do
        # Test implementation
      end
    end
  end
end
```

## Documentation

- Update README.md for new features
- Add YARD documentation for new methods
- Include code examples where helpful
- Update CHANGELOG.md following Keep a Changelog format

## Commit Messages

Use clear and meaningful commit messages:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters or less
- Reference issues and pull requests liberally

Examples:
```
Add retry mechanism for failed API requests

Fix authentication error handling in API client

Update README with new configuration options

Refs #123
```

## Release Process

1. Update version in `lib/orionx/version.rb`
2. Update CHANGELOG.md with new version details
3. Create release commit: `git commit -m "Release vX.X.X"`
4. Create git tag: `git tag -a vX.X.X -m "Release vX.X.X"`
5. Push changes and tags: `git push origin main --tags`

## Questions?

If you have questions about contributing, please:

1. Check existing issues and discussions
2. Create an issue for discussion
3. Reach out to the maintainers

Thank you for contributing to OrionX Ruby SDK!