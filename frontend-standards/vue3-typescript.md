# Vue 3 + TypeScript Standards

## 1. No Business Logic, Pure Calculations Allowed

> **[@CoT-required]**: When reviewing frontend standards, execute Review Process Step 1-3 before giving conclusions.

Frontend must NOT contain business logic (rules, validation, complex data transformation).
Pure data calculations are allowed if data is already provided by backend
(e.g., expensive client-side computation to reduce server load).

**Business Logic = Rules/Decisions** (must stay in backend):
- "If VIP user, apply 10% discount"
- "If order > $100, free shipping"
- "Calculate tax based on user location"

**Pure Calculation = Math on Existing Data** (allowed in frontend):
- `items.reduce((sum, i) => sum + i.price * i.qty, 0)`
- Sorting a list by a field
- Filtering visible items

```typescript
// ❌ Bad: Business logic in frontend
const UserCard = ({ user, orders }) => {
  const discount = user.isVIP ? calculateVIPDiscount(orders) : 0;
  // Business rules belong in backend
};

// ✅ Good: Backend sends calculated values
const UserCard = ({ user, calculatedDiscount }) => {
  return <span>Discount: {calculatedDiscount}</span>;
};

// ✅ Good: Pure calculation on existing data
const OrderSummary = ({ items }) => {
  const subtotal = items.reduce((sum, i) => sum + i.price * i.qty, 0);
  // Math on existing data is fine
  return <span>Subtotal: {subtotal}</span>;
};
```

## 2. Frontend: No Business Logic, Pure Calculations OK [@CoT-required]

> **Canonical source**: [L1 Rule 8](../code-review/levels/L1_minimal.md#8-frontend-no-business-logic-pure-calculations-ok-cot-required)

Frontend must NOT contain business logic (rules, validation, data transformation).
Pure data calculations are allowed if data is already provided by backend
(e.g., expensive client-side computation to reduce server load).

```typescript
// ❌ Bad: Business logic in frontend
// "If VIP user, apply 10% discount" → This is business logic, keep in backend
const discount = user.isVIP ? calculateDiscount(order.total, 0.1) : 0;

// ✅ Good: Pure calculation on existing data (no business rules)
const total = orders.reduce((sum, o) => sum + o.total, 0);

// ✅ Also Good: Backend organizes data, frontend computes on it
// Backend sends {items: [{price: 100, qty: 2}, {price: 50, qty: 1}]}
// Frontend computes: items.reduce((sum, i) => sum + i.price * i.qty, 0)
```

## 3. Data Display Standards

- **Timestamps**: Receive int64 from backend, format to local time
- **Numbers**: Use backend-provided formatted values, simple formatting only
- **Data Transformation**: Simple sorting/filtering allowed, complex aggregation prefers backend

## 4. Component Structure

- Vue 3 Composition API: Use `<script setup>` syntax
- TypeScript: All code must be strongly typed
- Props Validation: Define prop types explicitly
- Component Naming: PascalCase files

```typescript
// ✅ Good
<script setup lang="ts">
interface Props {
  userId: number;
  userName: string;
}

const props = defineProps<Props>();
</script>
```

## 5. State Management

- **Pinia**: Use for global state only
- **Local State**: Use `ref` and `reactive`
- **No Business Logic in Stores**: Stores manage UI state only

```typescript
// ✅ Good: Store for UI state only
export const useUserUIStore = defineStore('userUI', () => {
  const isLoading = ref(false);
  const errorMessage = ref<string | null>(null);
  return { isLoading, errorMessage };
});
```

## 6. API Integration

- Request Handling: Use centralized API modules
- Error Handling: Display user-friendly messages
- Loading States: Always show loading indicators

## 7. Code Quality Standards

- TypeScript strict mode enabled
- No `any` type — define proper types
- ESLint + Prettier for formatting

## 8. Guard Clauses

```typescript
// ✅ Good: Handle exceptions first
const UserProfile = ({ user }) => {
  if (!user) {
    return <EmptyState message="No user data" />;
  }
  return <div>{user.name}</div>;
};
```

## 9. Test Synchronization

- New components require test cases
- Bug fixes include regression tests
- Update tests when props/events change

```typescript
// ✅ Good: Component test
import { mount } from '@vue/test-utils';
import UserCard from '../UserCard.vue';

describe('UserCard', () => {
  it('displays user name', () => {
    const wrapper = mount(UserCard, {
      props: { userName: 'Alice' },
    });
    expect(wrapper.text()).toContain('Alice');
  });
});
```

## 10. Test Directory Structure

```
frontend/
├── src/
│   ├── components/
│   │   ├── UserCard.vue
│   │   └── __tests__/
│   │       └── UserCard.test.ts
│   ├── views/
│   │   └── __tests__/
│   │       └── Dashboard.test.ts
│   └── stores/
│       └── __tests__/
│           └── user.test.ts
└── tests/
    ├── integration/
    └── e2e/
```

## 11. Naming Conventions

- Component files: PascalCase (e.g., `UserCard.vue`)
- Event names: kebab-case
- CSS classes: kebab-case
- Store files: camelCase or kebab-case (e.g., `userStore.ts`)

## 12. Responsive Design

Support both desktop and mobile layouts. Use CSS media queries or utility classes.

```vue
<!-- ✅ Good: Responsive layout -->
<template>
  <div class="user-card">
    <div class="user-card__desktop">{{ user.name }}</div>
    <div class="user-card__mobile">{{ user.name }}</div>
  </div>
</template>

<style scoped>
.user-card__desktop { display: block; }
.user-card__mobile { display: none; }

@media (max-width: 768px) {
  .user-card__desktop { display: none; }
  .user-card__mobile { display: block; }
}
</style>
```

## 13. UI/UX Standards

- **Loading States**: Show loading indicators for async operations
- **Error States**: Handle and display errors gracefully
- **Empty States**: Show appropriate messages when no data available
- **Accessibility**: Follow WCAG guidelines

```vue
<!-- ✅ Good: Complete state handling -->
<template>
  <div class="user-profile">
    <div v-if="isLoading" class="loading-spinner" />
    <div v-else-if="error" class="error-message">{{ error }}</div>
    <div v-else-if="!user" class="empty-state">No user found</div>
    <div v-else class="user-content">{{ user.name }}</div>
  </div>
</template>
```

## 14. Security (XSS Prevention)

- **No tokens/keys in localStorage**: Use HttpOnly cookies
- **No v-html with user data**: Use v-text
- **External URLs**: Validate against allowlist
- **CSP headers**: Configured server-side

```vue
<!-- ❌ Bad: v-html with user data (XSS risk) -->
<div v-html="user.bio"></div>

<!-- ✅ Good: v-text -->
<div v-text="user.bio"></div>
```
