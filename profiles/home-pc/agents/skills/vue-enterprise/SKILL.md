---
name: vue-enterprise
description: Build enterprise-grade Vue.js 3 applications with modern tooling and best practices. Use when creating scalable Vue 3 apps with atomic design architecture, comprehensive testing (unit/component/E2E), GraphQL integration, internationalization, Docker deployment, or CI/CD pipelines. Covers Vite setup, Tailwind CSS, Vue Router, Vitest, Cypress, Storybook, Vue I18n, Apollo Client, and GitHub Actions workflows.
---

# Vue.js 3 Enterprise Development

Build scalable, maintainable Vue.js 3 applications following enterprise patterns and best practices.

## Quick Start: New Project

```bash
# Scaffold with Vite
npm create vite@latest my-app -- --template vue

# Install core dependencies
cd my-app
npm install vue-router@4 @vue/apollo-composable @apollo/client graphql graphql-tag
npm install -D vitest @testing-library/vue @vue/test-utils happy-dom cypress
npm install -D tailwindcss postcss autoprefixer
npm install vue-i18n@9
```

## Project Structure (Atomic Design)

```
src/
├── components/
│   ├── atoms/           # Button, Icon, TextField (indivisible)
│   ├── molecules/       # Card, FormInput (atom combinations)
│   ├── organisms/       # Header, LoginForm (complex sections)
│   └── templates/       # Page layouts
├── views/               # Route-level components
├── router/              # Vue Router configuration
├── graphql/             # GraphQL operations
│   ├── auth/
│   ├── users/
│   └── index.js         # Export all operations
├── locales/             # i18n translation files
├── tests/
│   ├── unit/            # Helper/utility tests
│   ├── components/      # Component tests
│   └── e2e/             # Cypress E2E tests
├── plugins/
│   └── apollo.config.js # Apollo Client setup
└── main.js              # App entry with plugins
```

## Component Architecture (Atomic Design)

### Atoms (Single Responsibility)

```vue
<!-- components/atoms/Button.vue -->
<script setup>
defineProps({
  label: { type: String, required: true },
  appearance: { 
    type: String, 
    validator: (v) => ['primary', 'secondary'].includes(v),
    default: 'primary'
  }
});
defineEmits(['click']);
</script>

<template>
  <button :class="`btn--${appearance}`" @click="$emit('click')">
    {{ label }}
  </button>
</template>
```

### Molecules (Compose Atoms)

```vue
<!-- components/molecules/Card.vue -->
<script setup>
import Button from '../atoms/Button.vue';
defineProps({ photo: Object, status: String });
</script>

<template>
  <div v-if="status === 'loading'">Loading...</div>
  <div v-else class="card">
    <img :src="photo.url" />
    <Button label="Save" @click="$emit('save')" />
  </div>
</template>
```

### Organisms (Complex Sections)

```vue
<!-- components/organisms/Header.vue -->
<script setup>
import SearchField from '../molecules/SearchField.vue';
import Button from '../atoms/Button.vue';
</script>
```

### Templates (Page Layouts)

```vue
<!-- components/templates/HomeOverview.vue -->
<script setup>
import Header from '../organisms/Header.vue';
import Cards from '../organisms/Cards.vue';
</script>

<template>
  <main>
    <Header />
    <Cards />
  </main>
</template>
```

## Vue Router Setup

```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: () => import('@/views/HomeView.vue') },
    { path: '/login', component: () => import('@/views/LoginView.vue') },
  ]
});
```

## Testing Strategy

### Unit Tests (Vitest + Testing Library)

```javascript
// tests/unit/helpers.spec.js
import { expect, test } from 'vitest';
import { increment } from '@/helpers/increment';

test('increments by 1', () => {
  expect(increment(5)).toBe(6);
});
```

### Component Tests

```javascript
// tests/components/Button.spec.js
import { render, fireEvent } from '@testing-library/vue';
import { expect, test } from 'vitest';
import Button from '@/components/atoms/Button.vue';

test('emits click event', async () => {
  const { getByText, emitted } = render(Button, {
    props: { label: 'Click me' }
  });
  await fireEvent.click(getByText('Click me'));
  expect(emitted()).toHaveProperty('click');
});
```

### E2E Tests (Cypress)

```javascript
// tests/e2e/login.spec.js
describe('Login', () => {
  it('logs in with valid credentials', () => {
    cy.visit('/login');
    cy.get('[data-testid="email"]').type('user@test.com');
    cy.get('[data-testid="password"]').type('password');
    cy.get('[data-testid="submit"]').click();
    cy.url().should('include', '/dashboard');
  });
});
```

### Vite Config for Testing

```javascript
// vite.config.js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'happy-dom',
    globals: true,
  }
});
```

## GraphQL with Apollo

```javascript
// plugins/apollo.config.js
import { ApolloClient, createHttpLink, InMemoryCache } from '@apollo/client';

export default new ApolloClient({
  link: createHttpLink({ uri: 'http://localhost:1337/graphql' }),
  cache: new InMemoryCache()
});
```

```javascript
// graphql/photos/queries.js
import gql from 'graphql-tag';

export const GET_PHOTOS = gql`
  query GetPhotos {
    photos {
      data { id attributes { title } }
    }
  }
`;
```

```vue
<!-- Using in component -->
<script setup>
import { useQuery } from '@vue/apollo-composable';
import { GET_PHOTOS } from '@/graphql/photos/queries';

const { result, loading, error } = useQuery(GET_PHOTOS);
</script>
```

## Internationalization (Vue I18n)

```javascript
// main.js
import { createI18n } from 'vue-i18n';

const i18n = createI18n({
  locale: 'en',
  fallbackLocale: 'en',
  messages: {
    en: { welcome: 'Welcome' },
    fr: { welcome: 'Bienvenue' }
  }
});

app.use(i18n);
```

```vue
<template>
  <p>{{ $t('welcome') }}</p>
</template>
```

## Tailwind CSS Setup

```javascript
// tailwind.config.js
module.exports = {
  content: ['./index.html', './src/**/*.{vue,js}'],
  theme: { extend: {} },
  plugins: []
};
```

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Docker Containerization

```dockerfile
# Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

```yaml
# docker-compose.yaml
version: '3.8'
services:
  frontend:
    build: .
    ports: ['3000:3000']
    volumes: ['./src:/app/src']
  backend:
    build: ./backend
    ports: ['1337:1337']
```

## CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '18' }
      - run: npm ci
      - run: npm run lint
      - run: npm run test:unit
      - run: npm run test:component
```

## Storybook Documentation

```javascript
// Button.stories.js
import Button from './Button.vue';

export default {
  component: Button,
  argTypes: { size: { control: 'select', options: ['sm', 'md', 'lg'] } }
};

export const Primary = {
  args: { label: 'Button', appearance: 'primary' }
};
```

## Best Practices

1. **Props**: Always define types, validators, and defaults
2. **Events**: Use `defineEmits` for explicit event documentation
3. **Naming**: Multi-word component names (avoid HTML conflicts)
4. **Composition**: Build complex UI from tested atomic parts
5. **Testing**: Unit → Component → E2E pyramid
6. **Imports**: Use `@/` alias for `src/` directory
7. **Async**: Use `() => import()` for route lazy loading

## Nuxt Comparison

| Feature | Vue + Vite | Nuxt |
|---------|-----------|------|
| Routing | Manual config | File-based `pages/` |
| Auto-imports | Manual | Built-in for components/composables |
| SSR | SPA only | Universal/SSR/SSG options |
| Setup | More explicit | More convention-based |

Use Vue + Vite for: Learning, fine-grained control, custom architectures
Use Nuxt for: Rapid development, SSR needs, convention over configuration
