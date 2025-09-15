# Contributing to IFS Cloud Auth Flutter

Thank you for your interest in contributing to this project! This document outlines the process for contributing.

## Development Setup

1. **Prerequisites**:
   - Flutter SDK (3.0.0 or later)
   - Dart SDK (3.0.0 or later)

2. **Setup**:
   ```bash
   git clone https://github.com/graknol/ifscloud_auth_flutter.git
   cd ifscloud_auth_flutter
   flutter pub get
   ```

3. **Running Tests**:
   ```bash
   flutter test
   ```

4. **Code Analysis**:
   ```bash
   flutter analyze
   ```

## Code Style

- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` to format your code
- Ensure all code passes `flutter analyze` without warnings

## Testing

- Write tests for all new functionality
- Maintain test coverage for existing code
- Tests should be placed in the `test/` directory
- Use descriptive test names and group related tests

## Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Run `flutter analyze` and fix any issues
7. Update documentation if needed
8. Submit a pull request

## Reporting Issues

When reporting issues, please include:
- Flutter version
- Dart version
- Platform (iOS/Android)
- Detailed steps to reproduce
- Expected vs actual behavior
- Error messages or logs

## Code of Conduct

This project follows the [Flutter Code of Conduct](https://github.com/flutter/flutter/blob/master/CODE_OF_CONDUCT.md).

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.