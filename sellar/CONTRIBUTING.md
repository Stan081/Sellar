`# Contributing to Sellar

Thank you for your interest in contributing to Sellar! This document provides guidelines and best practices for contributing to the project.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/sellar.git
   cd sellar
   ```
3. **Install dependencies**
   ```bash
   flutter pub get
   ```
4. **Set up environment**
   ```bash
   cp .env.example .env
   ```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test additions or modifications

### 2. Make Your Changes

Follow these guidelines:
- Write clean, readable code
- Follow the existing code style
- Add tests for new features
- Update documentation if needed
- Keep commits focused and atomic

### 3. Run Quality Checks

Before committing, ensure your code passes all checks:

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### 4. Commit Your Changes

Write clear, descriptive commit messages:

```bash
git commit -m "feat: add user profile screen"
git commit -m "fix: resolve navigation bug on settings page"
git commit -m "docs: update README with new setup instructions"
```

Commit message format:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation change
- `style:` - Code style change (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Test changes
- `chore:` - Build process or auxiliary tool changes

### 5. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Reference to any related issues
- Screenshots (if UI changes)
- Test results

## Code Style Guidelines

### Dart/Flutter Best Practices

1. **Use const constructors**
   ```dart
   // Good
   const Text('Hello')
   
   // Avoid
   Text('Hello')
   ```

2. **Prefer final over var**
   ```dart
   // Good
   final name = 'John';
   
   // Avoid
   var name = 'John';
   ```

3. **Use meaningful names**
   ```dart
   // Good
   final userRepository = UserRepositoryImpl();
   
   // Avoid
   final repo = UserRepositoryImpl();
   ```

4. **Document public APIs**
   ```dart
   /// Fetches user data from the API
   /// 
   /// Returns a [User] object if successful, throws [ApiException] otherwise
   Future<User> getUser(String id);
   ```

5. **Handle errors properly**
   ```dart
   // Good
   try {
     final user = await repository.getUser(id);
     return user;
   } on ApiException catch (e) {
     logger.e('Failed to fetch user: $e');
     rethrow;
   }
   ```

### Widget Structure

Keep widgets small and focused:

```dart
class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAvatar(),
        _buildUserInfo(),
        _buildActions(),
      ],
    );
  }

  Widget _buildAvatar() {
    // Build avatar widget
  }

  Widget _buildUserInfo() {
    // Build user info widget
  }

  Widget _buildActions() {
    // Build actions widget
  }
}
```

### State Management

Use appropriate state management for the scope:

```dart
// Local state - StatefulWidget
class Counter extends StatefulWidget {
  // ...
}

// Feature state - BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ...
}

// Global state - Provider
class ThemeProvider extends ChangeNotifier {
  // ...
}
```

## Testing Guidelines

### Unit Tests

Test business logic in isolation:

```dart
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      repository = UserRepositoryImpl(mockApiService);
    });

    test('getUser returns user when API call succeeds', () async {
      // Arrange
      when(() => mockApiService.get('/users/1'))
          .thenAnswer((_) async => Response(data: {'id': '1', 'name': 'John'}));

      // Act
      final user = await repository.getUser('1');

      // Assert
      expect(user.id, '1');
      expect(user.name, 'John');
    });
  });
}
```

### Widget Tests

Test UI components and interactions:

```dart
void main() {
  testWidgets('LoginButton shows loading indicator when pressed', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: LoginButton(onPressed: () {}),
      ),
    );

    // Act
    await tester.tap(find.byType(LoginButton));
    await tester.pump();

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

## Pull Request Guidelines

### Before Submitting

- [ ] Code follows project style guidelines
- [ ] All tests pass
- [ ] New code has test coverage
- [ ] Documentation is updated
- [ ] No merge conflicts
- [ ] Commits are clean and descriptive

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
Describe the tests you ran

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
```

## Feature Development Process

### Adding a New Feature

1. **Create feature directory structure**
   ```
   lib/src/features/your_feature/
   ├── data/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   └── repositories/
   └── presentation/
       ├── screens/
       ├── widgets/
       └── bloc/
   ```

2. **Implement domain layer first**
   - Define entities
   - Define repository interfaces
   - Define use cases (if needed)

3. **Implement data layer**
   - Create data models
   - Implement repositories
   - Add data sources

4. **Implement presentation layer**
   - Create screens
   - Create widgets
   - Add state management (BLoC)

5. **Add navigation**
   - Update `router_config.dart`
   - Add routes

6. **Write tests**
   - Unit tests for business logic
   - Widget tests for UI
   - Integration tests for flows

## Code Review Process

### For Reviewers

- Be respectful and constructive
- Check for code quality and maintainability
- Verify tests are adequate
- Look for potential bugs or edge cases
- Suggest improvements, not just criticisms

### For Contributors

- Respond to feedback promptly
- Be open to suggestions
- Ask questions if feedback is unclear
- Update PR based on feedback
- Thank reviewers for their time

## Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Give credit where it's due
- Focus on the code, not the person
- Have fun and build something great!

## Questions or Need Help?

- Open an issue for bugs or feature requests
- Start a discussion for questions
- Check existing issues before creating new ones
- Provide as much context as possible

## License

By contributing to Sellar, you agree that your contributions will be licensed under the project's MIT License.
