# Contributing to macOS Dev Setup

Thank you for your interest in contributing! This guide will help you get started.

## 🎯 Philosophy

This project aims to provide a **robust, POSIX-compliant, and user-friendly** setup script for macOS development environments.

### Key Principles

1. **POSIX Compliance**: All scripts must work with `/bin/sh`
2. **Idempotent**: Scripts should be safe to run multiple times
3. **Error Handling**: Comprehensive error handling with cleanup
4. **User Experience**: Clear logging, progress indicators, helpful messages
5. **Architecture Support**: Works on both Intel and Apple Silicon
6. **Zero Dependencies**: No external dependencies beyond macOS built-ins

## 🚀 Getting Started

### Prerequisites

- macOS 12.0 (Monterey) or later
- Basic knowledge of shell scripting
- Understanding of Homebrew

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:

   ```bash
   git clone https://github.com/YOUR_USERNAME/macos-dev-setup.git
   cd macos-dev-setup
   ```

3. Test the current setup:

   ```bash
   # Validate syntax
   sh -n bootstrap.sh setup.sh scripts/*.sh scripts/lib/*.sh

   # Test on a test machine or VM
   ./setup.sh
   ```

## 📝 Code Style

### Shell Script Guidelines

#### Shebang

Always use POSIX shell:

```bash
#!/bin/sh
```

#### No Bashisms

Avoid bash-specific features:

❌ **Don't use:**

```bash
[[ condition ]]           # Use [ condition ] instead
<(command)                # Use temporary files instead
$"string"                 # Use regular strings
{1..10}                   # Use seq or while loop
local var="value"         # Use local var; var="value"
```

✅ **Do use:**

```bash
[ condition ]
tmp=$(mktemp); command > "$tmp"
"string"
seq 1 10
local var
var="value"
```

#### Logging

Use the logging functions from `scripts/lib/log_utils.sh`:

```bash
. "$SCRIPT_DIR/lib/log_utils.sh"

log_debug "Detailed debugging info"
log_info "General information"
log_success "Operation succeeded"
log_warn "Warning message"
log_error "Error message"
log_step "Current step"
log_progress "Long operation in progress..."
log_section "Section Header"
```

#### Error Handling

Always set up error handling:

```bash
. "$SCRIPT_DIR/lib/error_handler.sh"

cleanup_my_script() {
    # Cleanup temporary files, etc.
    log_debug "Cleanup called"
}

main() {
    setup_error_handling
    register_cleanup cleanup_my_script

    # Your code here
}

main "$@"
```

#### Function Naming

- Use lowercase with underscores: `my_function()`
- Start helper functions with underscore: `_internal_function()`
- Use descriptive names: `install_package()` not `inst_pkg()`

#### Comments

- Add comments for complex logic
- Document function parameters
- Explain why, not what

```bash
# Calculate available disk space in GB
# Returns: disk space in gigabytes
get_available_space() {
    # Use df -h for human-readable output
    df -h / | awk 'NR==2 {print $4}'
}
```

## 🧪 Testing

### Syntax Validation

Validate shell syntax before committing:

```bash
# Quick syntax check
sh -n bootstrap.sh setup.sh scripts/*.sh scripts/lib/*.sh

# Advanced checking (optional - requires shellcheck)
brew install shellcheck
shellcheck -s sh *.sh scripts/*.sh scripts/lib/*.sh
```

### Manual Testing

Test your changes on:

1. Fresh macOS installation (VM recommended)
2. Both Intel and Apple Silicon (if possible)
3. Multiple runs (idempotency check)

### Test Checklist

- [ ] Scripts execute without errors
- [ ] Error handling works (test failure scenarios)
- [ ] Cleanup functions run on exit/error
- [ ] Logs are clear and helpful
- [ ] Progress indicators work
- [ ] Scripts are idempotent

## 📦 Adding New Features

### Adding a New Script

1. Create script in `scripts/`:

   ```bash
   touch scripts/my_feature.sh
   chmod +x scripts/my_feature.sh
   ```

2. Use the template:

   ```bash
   #!/bin/sh

   SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
   . "$SCRIPT_DIR/lib/log_utils.sh"
   . "$SCRIPT_DIR/lib/error_handler.sh"
   . "$SCRIPT_DIR/lib/utils.sh"

   cleanup_my_feature() {
       log_debug "Cleanup function called"
   }

   main() {
       setup_error_handling
       register_cleanup cleanup_my_feature

       log_section "My Feature"

       # Your code here

       log_success "Feature completed"
   }

   main "$@"
   ```

3. Add to `setup.sh` if needed

### Adding Utility Functions

Add reusable functions to `scripts/lib/utils.sh`:

```bash
# Brief description of what the function does
# Arguments: $1 - description of first argument
# Returns: description of return value
my_utility_function() {
    local arg1="$1"

    # Implementation

    return 0
}
```

### Modifying Brewfile

When adding packages:

1. Group by category (taps, brews, casks, fonts)
2. Add comments for non-obvious packages
3. Test installation

## 🐛 Reporting Bugs

### Before Submitting

1. Check existing issues
2. Test on latest version
3. Verify it's not a configuration issue

### Bug Report Template

```markdown
**Description**
A clear description of the bug

**To Reproduce**
Steps to reproduce the behavior:
1. Run '...'
2. See error

**Expected Behavior**
What you expected to happen

**Environment**
- macOS version:
- Architecture: (Intel/Apple Silicon)
- Script version:

**Logs**
Paste relevant logs (run with VERBOSE=1)
```

## 📋 Pull Request Process

1. **Create a feature branch**

   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes**
   - Follow code style guidelines
   - Add tests if applicable
   - Update documentation

3. **Test thoroughly**

   ```bash
   # Validate syntax
   sh -n bootstrap.sh setup.sh scripts/*.sh scripts/lib/*.sh

   # Run with verbose output
   VERBOSE=1 ./setup.sh
   ```

4. **Update documentation**
   - Update README.md if needed
   - Add entry to CHANGELOG.md
   - Update IMPROVEMENTS.md for significant changes

5. **Commit with clear messages**

   ```bash
   git commit -m "feat: add support for X"
   git commit -m "fix: resolve issue with Y"
   git commit -m "docs: update README with Z"
   ```

6. **Push and create PR**

   ```bash
   git push origin feature/my-feature
   ```

7. **Fill out PR template**
   - Describe changes
   - Reference issues
   - Add screenshots if relevant

## 🎨 Commit Message Format

Follow conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

Examples:

```text
feat: add support for Apple Silicon detection
fix: resolve Brewfile hash comparison issue
docs: update README with troubleshooting section
refactor: extract logging functions to separate file
```

## 📞 Questions?

- Open an issue for questions
- Tag with `question` label
- Be specific and provide context

## 🙏 Thank You

Every contribution makes this project better. Thank you for being part of it!
