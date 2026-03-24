---
name: code-standards
description: This skill provides comprehensive coding standards for Go backend and Vue 3 + TypeScript frontend projects. Use this skill when writing, reviewing, or refactoring code to ensure consistency, maintainability, and adherence to best practices. The skill emphasizes separation of concerns where backend handles all business logic and calculations, while frontend focuses solely on presentation.
---

# Code Standards

## Overview

This skill provides comprehensive coding standards for Go backend and Vue 3 + TypeScript frontend development. These standards ensure consistency, maintainability, and adherence to best practices.

## When to Use This Skill

Use this skill when:
- Writing new code (backend or frontend)
- Refactoring existing code
- Reviewing pull requests
- Fixing code quality issues
- Setting up database models (backend)
- Implementing DDD architecture layers (backend)
- Creating Vue components (frontend)
- Managing application state (frontend)

## Core Principles

### Separation of Concerns
- **Backend**: Handles ALL business logic, calculations, and data aggregation
- **Frontend**: ONLY handles presentation, receives pre-calculated data from backend
- **No Business Logic in Frontend**: Frontend should never perform complex calculations
- **Backend Trust**: Frontend trusts backend to provide all necessary data in ready-to-display format

### Production-Grade Code
- **No Mock Data**: Never use mock data, mock functions, or placeholder implementations in production code
- **No Stub Functions**: All functions must have complete, working implementations
- **No TODO Placeholders**: No "TODO", "FIXME", or placeholder code that defers implementation
- **No Temporary Solutions**: Every piece of code must be production-ready, not a quick fix or workaround
- **Complete Implementation**: All features must be fully implemented with proper error handling
- **Testable Code**: Code must be written with testing in mind, but test mocks are only allowed in test files

### Refactoring Principles
- **Feature Preservation**: Refactoring MUST preserve ALL existing functionality - no features should be lost
- **Behavior Equivalence**: After refactoring, the system must behave identically to before
- **No Silent Removals**: Never remove functionality during refactoring without explicit requirement
- **Feature Inventory**: Before refactoring, list all existing features to ensure none are missed
- **Verification Required**: After refactoring, verify each feature still works correctly
- **Incremental Refactoring**: Large refactorings should be broken into smaller, verifiable steps
- **Rollback Ready**: Keep the ability to rollback if issues are discovered post-refactoring

---

## Backend Standards (Go)

### 1. Naming and Formatting
- **Interface data**: Use camelCase naming
- **Comments**: Use English, follow Google conventions
- **Package names**: Use lowercase letters, avoid underscores
- **Function names**: Use camelCase, start with a verb

### 2. Database Field Standards
- **gorm tag**: Must be explicit, every field must have `gorm:"column:field_name"`
- **Database field naming**: Use snake_case naming
- **gorm tag restrictions**: Only write column fields, do not use gorm's index, uniqueIndex features
- **DDL definition**: Create table definitions must explicitly write DDL, cannot use gorm's AutoMigrate feature
- **DDL principle**: What you see is what you get, table structure is clearly defined by DDL
- **DDL NOT NULL**: All DDL fields must have NOT NULL constraint, code must not check IS NULL/IS NOT NULL
- **Update with Model**: When updating database records, use struct model instead of map[string]interface{}
- **Type Safety**: Model-based updates provide compile-time type checking
- **Field Tracking**: Model updates only modify non-zero fields, avoiding accidental zero-value overwrites
- **IDE Support**: Struct fields enable autocomplete and refactoring
- **No Raw SQL for CRUD**: Use gorm model methods for INSERT/UPDATE/DELETE operations, avoid writing raw SQL
- **Model Methods**: Use `db.Create()`, `db.Save()`, `db.Updates()`, `db.Delete()` instead of raw SQL
- **Query Allowed**: Raw SQL is allowed for complex queries that gorm cannot express easily
- **DDL Exception**: Raw SQL is allowed for DDL operations (CREATE TABLE, ALTER TABLE, etc.)
- **Type Safety**: Model methods provide compile-time type checking and IDE support

### 3. Logging Standards
- **Global unified logger**: MUST use wrapped logger instance (e.g., `logger.G()`, `logger.L()`, etc.), NEVER use raw `fmt.Println`, `log.Println` or similar. Multiple logger instances are allowed, naming is flexible as long as semantically appropriate
- **Structured logging**: Use `InfoW`, `DebugW`, `WarnW`, `ErrorW` series functions or `Infow`, `Debugw`, `Warnw`, `Errorw` with key-value pairs
- **Key naming**: Log keys MUST use camelCase naming (e.g., `orderId`, `userId`, `apiKey`), NEVER use snake_case (e.g., `order_id`, `user_id`)
- **Language**: Use English for logs, clear and understandable
- **Security**: Do not print sensitive fields (token, access key, secret key, etc.)
- **Level**: Reasonably use Info, Warn, Error levels

### 4. Timestamp Handling
- **Database storage**: Unified use of int64 timestamps (UnixMilli)
- **Frontend-backend transmission**: Use int64 timestamps
- **Frontend display**: Frontend responsible for converting to local time, displaying year-month-day hour:minute:second

### 5. DDD Architecture Standards
- **Layered structure**: Strictly follow Domain-Driven Design layering
- **Dependency direction**: Outer layers depend on inner layers, inner layers do not depend on outer layers
- **Domain model**: Business logic concentrated in the domain layer
- **Infrastructure**: External dependencies abstracted through interfaces

### 6. Code Quality Standards
- **Compilation check**: Every modification must ensure code compiles successfully
- **Linter check**: Code style must pass revive lint check (https://github.com/mgechev/revive)
- **Fix priority**: Compilation errors and lint errors must be fixed first
- **Avoid duplication**: Eliminate duplicate code, extract common logic into reusable functions or modules
- **Avoid magic values**: Prohibit using magic numbers and magic strings, define them as meaningful constants
- **Prefer struct over map**: Use struct instead of map[string]interface{} when field types are known at compile time
- **Type Safety**: Structs provide compile-time type checking, map does not
- **Performance**: Struct access is faster than map lookup, no runtime hash computation needed
- **IDE Support**: Structs enable IDE autocomplete and refactoring tools
- **Documentation**: Struct fields are self-documenting with clear names and types
- **Early Initialization**: Initialize dependencies at startup, avoid redundant nil checks
- **No Defensive Nil Checks**: Only check for nil when the value can legitimately be nil (optional dependencies, failed initialization)
- **Trust Initialization**: If a dependency is initialized at startup, trust it exists throughout the lifecycle
- **Fail Fast**: If initialization fails, fail immediately rather than checking nil everywhere

### 7. Error Handling Standards
- **Multiple return values**: When a function returns multiple values including error, if error is not nil, other return values must be zero values
- **Success case**: When error is nil, other return values must be valid non-zero values
- **Consistency**: Always follow this pattern for all functions returning error
- **Error Comparison**: Use `errors.Is()` for error value comparison, NEVER use `==` for comparing errors
- **Error Type Assertion**: Use `errors.As()` for error type assertion, NEVER use type assertion directly
- **Error Wrapping**: Use `fmt.Errorf("context: %w", err)` to wrap errors with context
- **Unwrap Chain**: `errors.Is()` and `errors.As()` traverse the error chain automatically

### 8. Business Logic Placement
- **All calculations**: Must be performed in the backend
- **Data aggregation**: Must be done in the backend before sending to frontend
- **Complex computations**: Must be handled by backend services
- **Frontend responsibility**: Only receive and display pre-calculated data

### 9. Goroutine Safety Standards
- **PROHIBITED**: Never use the `go` keyword directly to start a goroutine
- **REQUIRED**: Always use `goroutine.SafeGo` or `goroutine.SafeGoWithContext` to start goroutines
- **Panic Recovery**: SafeGo provides automatic panic recovery with stack trace logging
- **Stack Trace**: Panic stack traces are limited to 65536 bytes (2^16) to prevent excessive log output
- **Context Propagation**: Use `SafeGoWithContext` when context propagation is needed

### 10. Comment Standards
- **Consistency**: Comments must accurately describe what the code does, never contradict the actual implementation
- **Keep Updated**: When modifying code, always update related comments immediately
- **No Outdated Comments**: Remove or update comments that no longer reflect the current code behavior
- **No Misleading Comments**: Comments should not describe functionality that doesn't exist or has been removed
- **Self-Documenting Code**: Prefer clear naming over comments when possible
- **Comment Purpose**: Explain "why" not "what" - the code itself shows what it does
- **Function Comments**: Public functions must have documentation comments explaining purpose and usage
- **Complex Logic**: Add comments for complex algorithms or non-obvious business rules
- **TODO Management**: TODO comments must include issue tracker reference and be actively tracked

### 11. Test Synchronization Standards
- **Sync with Code Changes**: When modifying code, corresponding test cases MUST be updated simultaneously
- **New Features**: New functionality requires new test cases before merge
- **Bug Fixes**: Bug fixes must include regression test cases
- **Refactoring**: Refactored code must update existing tests to match new structure
- **API Changes**: Interface changes require updating integration tests
- **No Orphaned Tests**: Remove tests for deleted code, update tests for modified code
- **Test Coverage**: Maintain or improve test coverage with each change
- **Test First**: For bug fixes, write failing test case first, then fix the code

### 12. Guard Clause Standards
- **Handle Exceptions First**: Check and handle exceptional cases before normal logic
- **Invert Conditions**: Use inverted conditions to return early, avoid deep nesting
- **Flat Code Structure**: Reduce nesting levels, keep code flat and readable
- **Early Return**: Return as soon as possible when conditions are not met
- **Readability**: Guard clauses make the main logic more visible and easier to understand
- **Pattern**: `if err != nil { return }` before proceeding with normal logic
- **Avoid Else**: Prefer early return over else branches when possible

### 13. Refactoring Standards
- **Feature Inventory**: Before refactoring, document ALL existing features and behaviors
- **Feature Checklist**: Create a checklist of features to verify after refactoring
- **No Feature Loss**: Every feature that exists before refactoring MUST exist after refactoring
- **Behavior Verification**: Test each feature after refactoring to confirm it still works
- **Edge Cases**: Pay special attention to edge cases and error handling paths
- **Hidden Features**: Watch for implicit behaviors (caching, logging, validation) that may be overlooked
- **API Compatibility**: Ensure public APIs remain compatible unless explicitly changing them
- **Configuration Preserved**: All configuration options must continue to work
- **Performance Characteristics**: Document and preserve important performance behaviors
- **Security Features**: Never remove or weaken security measures during refactoring
- **Incremental Changes**: Large refactorings should be split into smaller, reviewable changes
- **Rollback Plan**: Have a plan to revert changes if issues are discovered

## Backend Checklist

- [ ] Interface fields use camelCase
- [ ] All fields have explicit `gorm:"column:field_name"` tag
- [ ] No index/uniqueIndex tags in gorm struct
- [ ] DDL fields all have NOT NULL constraint
- [ ] Use struct model for gorm updates, not map[string]interface{}
- [ ] No raw SQL for CRUD operations, use gorm model methods
- [ ] Do not print sensitive information
- [ ] Use English logs with wrapped logger instance (NEVER use `fmt.Println`, `log.Println`, etc.)
- [ ] Use structured logging (`InfoW`, `WarnW`, `ErrorW`, `DebugW`)
- [ ] Log keys use camelCase naming
- [ ] No `fmt.Sprintf` or string concatenation in log messages
- [ ] Database fields use int64 timestamps
- [ ] API responses use int64 timestamps
- [ ] Business logic in domain layer
- [ ] No duplicate code blocks
- [ ] No magic numbers and magic strings
- [ ] Prefer struct over map[string]interface{} for known fields
- [ ] No redundant nil checks for initialized dependencies
- [ ] Dependencies initialized at startup, not checked repeatedly
- [ ] Compiles successfully and passes lint
- [ ] Functions returning error follow zero-value pattern
- [ ] Use `errors.Is()` for error comparison (NEVER use `==`)
- [ ] Use `errors.As()` for error type assertion
- [ ] All calculations are performed in backend
- [ ] Data is aggregated before sending to frontend
- [ ] No direct `go` keyword usage, use `goroutine.SafeGo` or `goroutine.SafeGoWithContext`
- [ ] No mock data or placeholder implementations
- [ ] No TODO/FIXME placeholders in production code
- [ ] Comments accurately describe current code behavior
- [ ] No outdated or misleading comments
- [ ] Public functions have documentation comments
- [ ] Test cases updated when code changes
- [ ] New features have corresponding test cases
- [ ] Bug fixes include regression tests
- [ ] Guard clauses used to handle exceptions first
- [ ] Early returns reduce nesting levels
- [ ] Code structure is flat and readable
- [ ] All existing features documented before refactoring
- [ ] Feature checklist created and verified after refactoring
- [ ] No functionality lost during refactoring
- [ ] Edge cases and error handling verified post-refactoring
- [ ] Security features preserved during refactoring

---

## Frontend Standards (Vue 3 + TypeScript)

### 1. Single Responsibility Principle
- **Presentation Only**: Frontend is ONLY responsible for displaying data
- **No Business Logic**: Never implement business calculations in frontend
- **No Data Aggregation**: Never aggregate or transform complex data in frontend
- **Backend Trust**: Trust backend to provide all necessary pre-calculated data

### 2. Data Display Standards
- **Timestamps**: 
  - Receive int64 timestamps from backend
  - Use utility functions to format to local time
  - Display format: YYYY-MM-DD HH:mm:ss or contextual formats
- **Numbers**: 
  - Use backend-provided formatted values when available
  - Simple formatting only (e.g., decimal places, currency symbols)
  - No complex calculations
- **Data Transformation**: 
  - Only simple transformations (sorting, filtering by existing fields)
  - No data aggregation or statistical calculations
  - No derived data calculations

### 3. Component Structure
- **Vue 3 Composition API**: Use `<script setup>` syntax
- **TypeScript**: All code must be strongly typed
- **Props Validation**: Define prop types explicitly
- **Event Naming**: Use kebab-case for custom events
- **Component Naming**: Use PascalCase for component files

### 4. State Management
- **Pinia**: Use Pinia for global state management
- **Local State**: Use `ref` and `reactive` for component-local state
- **No Business Logic in Stores**: Stores should only manage UI state, not business calculations

### 5. API Integration
- **Request Handling**: Use centralized API modules
- **Error Handling**: Display user-friendly error messages
- **Loading States**: Always show loading indicators during async operations
- **No Data Manipulation**: Use data as received from backend

### 6. Code Quality Standards
- **TypeScript strict mode**: Enable strict type checking
- **ESLint**: Follow Vue and TypeScript best practices
- **No `any` type**: Avoid using `any`, define proper types
- **Consistent Formatting**: Use Prettier for code formatting

### 7. Performance Standards
- **Lazy Loading**: Use dynamic imports for large components
- **Computed Properties**: Use for simple derived values (no complex calculations)
- **Watchers**: Avoid deep watchers when possible
- **No Heavy Computations**: Move all heavy calculations to backend

### 8. UI/UX Standards
- **Responsive Design**: Support desktop and mobile devices
- **Accessibility**: Follow WCAG guidelines
- **Loading States**: Show loading indicators for async operations
- **Error States**: Handle and display errors gracefully
- **Empty States**: Show appropriate messages when no data available

### 9. Comment Standards
- **Consistency**: Comments must accurately describe what the code does, never contradict the actual implementation
- **Keep Updated**: When modifying code, always update related comments immediately
- **No Outdated Comments**: Remove or update comments that no longer reflect the current code behavior
- **No Misleading Comments**: Comments should not describe functionality that doesn't exist or has been removed
- **JSDoc for Public APIs**: Use JSDoc comments for exported functions, components, and types
- **Component Documentation**: Complex components should have comments explaining props and usage
- **Explain Why**: Comments should explain business decisions or non-obvious logic, not restate code
- **TODO Management**: TODO comments must include issue tracker reference and be actively tracked

### 10. Test Synchronization Standards
- **Sync with Code Changes**: When modifying code, corresponding test cases MUST be updated simultaneously
- **New Features**: New components or functions require corresponding test cases
- **Bug Fixes**: Bug fixes must include regression test cases
- **Refactoring**: Refactored components must update existing tests
- **Component Tests**: Update component tests when props, events, or behavior change
- **E2E Tests**: Update E2E tests when user flows or UI structure change
- **No Orphaned Tests**: Remove tests for deleted components, update tests for modified ones
- **Test Coverage**: Maintain or improve test coverage with each change

### 11. Guard Clause Standards
- **Handle Exceptions First**: Check and handle exceptional cases before normal logic
- **Invert Conditions**: Use inverted conditions to return early, avoid deep nesting
- **Flat Code Structure**: Reduce nesting levels, keep code flat and readable
- **Early Return**: Return as soon as possible when conditions are not met
- **Readability**: Guard clauses make the main logic more visible and easier to understand
- **Pattern**: Check invalid props/state first, return early or show fallback UI
- **Avoid Else**: Prefer early return over else branches when possible

### 12. Refactoring Standards
- **Feature Inventory**: Before refactoring, document ALL existing UI features and behaviors
- **Feature Checklist**: Create a checklist of features to verify after refactoring
- **No Feature Loss**: Every feature that exists before refactoring MUST exist after refactoring
- **UI Behavior Preserved**: All user interactions must work the same way after refactoring
- **Edge Cases**: Watch for conditional rendering, error states, loading states that may be missed
- **Event Handlers**: All event handlers (click, input, etc.) must be preserved
- **Computed Properties**: All computed properties and their behaviors must be maintained
- **Watchers**: All watchers and their side effects must be preserved
- **Styling**: CSS classes and styles must continue to work correctly
- **Accessibility**: ARIA attributes and keyboard navigation must be preserved
- **Responsive Behavior**: Mobile/desktop layouts must continue to work
- **Component Props**: All props and their default values must be preserved
- **Component Events**: All emitted events must be preserved
- **Incremental Changes**: Large refactorings should be split into smaller, reviewable changes

## Frontend Checklist

- [ ] No business logic implemented in frontend
- [ ] No complex calculations in frontend
- [ ] No data aggregation in frontend
- [ ] Timestamps formatted using utility functions
- [ ] Numbers displayed with simple formatting only
- [ ] Using Vue 3 Composition API with `<script setup>`
- [ ] TypeScript types defined for all props and data
- [ ] Pinia used for global state only
- [ ] No business logic in stores
- [ ] Centralized API modules used
- [ ] Loading indicators implemented
- [ ] TypeScript strict mode enabled
- [ ] No `any` types used
- [ ] Responsive design implemented
- [ ] No mock data or placeholder implementations
- [ ] No TODO/FIXME placeholders in production code
- [ ] Comments accurately describe current code behavior
- [ ] No outdated or misleading comments
- [ ] JSDoc comments for exported functions and components
- [ ] Test cases updated when code changes
- [ ] New components/functions have corresponding test cases
- [ ] Bug fixes include regression tests
- [ ] Guard clauses used to handle exceptions first
- [ ] Early returns reduce nesting levels
- [ ] Code structure is flat and readable
- [ ] All existing UI features documented before refactoring
- [ ] Feature checklist created and verified after refactoring
- [ ] No functionality lost during refactoring
- [ ] Event handlers preserved during refactoring
- [ ] Accessibility features preserved during refactoring
- [ ] Responsive behavior verified post-refactoring

---

## Examples

See `references/code_examples.md` for detailed examples demonstrating correct and incorrect patterns for both backend and frontend code.

## Resources

### Backend Resources
- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)

### Frontend Resources
- [Vue 3 Documentation](https://vuejs.org/guide/introduction.html)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [Pinia Documentation](https://pinia.vuejs.org/)
