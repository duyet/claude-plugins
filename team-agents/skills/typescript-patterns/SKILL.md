---
name: typescript-patterns
description: TypeScript best practices, strict typing patterns, and type safety strategies. Use when implementing TypeScript code with focus on type correctness and maintainability.
---

This skill provides TypeScript-specific implementation patterns for type-safe, maintainable code.

## When to Invoke This Skill

Automatically activate for:
- TypeScript/JavaScript project implementation
- Type system design and refinement
- Generic patterns and utility types
- Error handling with type safety
- API type definitions

## Strict Typing Patterns

### Branded Types for Domain Safety

```typescript
// Prevent mixing IDs of different entities
type UserId = string & { readonly brand: unique symbol };
type OrderId = string & { readonly brand: unique symbol };

// Type-safe ID creation
function createUserId(id: string): UserId {
  return id as UserId;
}

// Compiler prevents: processOrder(userId) ✗
function processOrder(orderId: OrderId): void { /* ... */ }
```

### Discriminated Unions for State

```typescript
// Result type for error handling
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

// Usage with exhaustive checking
function handleResult<T>(result: Result<T>): T {
  if (result.success) {
    return result.data;
  }
  throw result.error;
}

// State machines
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

### Type Guards

```typescript
// Runtime type validation
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value &&
    typeof (value as User).id === 'string' &&
    typeof (value as User).email === 'string'
  );
}

// Array type guard
function isArrayOf<T>(
  arr: unknown,
  guard: (item: unknown) => item is T
): arr is T[] {
  return Array.isArray(arr) && arr.every(guard);
}

// Assertion function
function assertNonNull<T>(
  value: T | null | undefined,
  message?: string
): asserts value is T {
  if (value === null || value === undefined) {
    throw new Error(message ?? 'Value is null or undefined');
  }
}
```

### Utility Types

```typescript
// Deep partial for nested objects
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

// Make specific properties required
type RequireFields<T, K extends keyof T> = T & Required<Pick<T, K>>;

// Extract function return type with error handling
type SafeReturn<T extends (...args: any[]) => any> =
  ReturnType<T> extends Promise<infer U> ? U : ReturnType<T>;

// Strict omit (errors on invalid keys)
type StrictOmit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;
```

## Error Handling Patterns

### Custom Error Hierarchy

```typescript
// Base application error
class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

// Specific error types
class ValidationError extends AppError {
  constructor(
    message: string,
    public readonly fields: Record<string, string>
  ) {
    super(message, 'VALIDATION_ERROR', 400);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`, 'NOT_FOUND', 404);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401);
  }
}
```

### Type-Safe Error Handling

```typescript
// Global error handler with type narrowing
function handleError(error: unknown): { code: string; message: string } {
  if (error instanceof AppError && error.isOperational) {
    return { code: error.code, message: error.message };
  }

  if (error instanceof Error) {
    console.error('Unexpected error:', error);
    return { code: 'INTERNAL_ERROR', message: 'Something went wrong' };
  }

  console.error('Unknown error:', error);
  return { code: 'UNKNOWN_ERROR', message: 'An unknown error occurred' };
}

// Try-catch wrapper with typed errors
async function tryCatch<T, E = Error>(
  fn: () => Promise<T>
): Promise<Result<T, E>> {
  try {
    const data = await fn();
    return { success: true, data };
  } catch (error) {
    return { success: false, error: error as E };
  }
}
```

## Generic Patterns

### Repository Pattern

```typescript
interface Repository<T, ID = string> {
  findById(id: ID): Promise<T | null>;
  findAll(options?: FindOptions): Promise<T[]>;
  create(data: Omit<T, 'id' | 'createdAt' | 'updatedAt'>): Promise<T>;
  update(id: ID, data: Partial<T>): Promise<T>;
  delete(id: ID): Promise<void>;
}

interface FindOptions {
  limit?: number;
  offset?: number;
  orderBy?: string;
  orderDir?: 'asc' | 'desc';
}
```

### Builder Pattern

```typescript
class QueryBuilder<T> {
  private filters: Array<(item: T) => boolean> = [];
  private sortFn?: (a: T, b: T) => number;
  private limitCount?: number;

  where(predicate: (item: T) => boolean): this {
    this.filters.push(predicate);
    return this;
  }

  orderBy<K extends keyof T>(key: K, dir: 'asc' | 'desc' = 'asc'): this {
    this.sortFn = (a, b) => {
      const result = a[key] < b[key] ? -1 : a[key] > b[key] ? 1 : 0;
      return dir === 'asc' ? result : -result;
    };
    return this;
  }

  limit(count: number): this {
    this.limitCount = count;
    return this;
  }

  execute(data: T[]): T[] {
    let result = data.filter(item =>
      this.filters.every(f => f(item))
    );
    if (this.sortFn) result = result.sort(this.sortFn);
    if (this.limitCount) result = result.slice(0, this.limitCount);
    return result;
  }
}
```

## Module Organization

### Barrel Exports

```typescript
// types/index.ts - Export all types
export type { User, UserCreate, UserUpdate } from './user';
export type { Order, OrderCreate, OrderStatus } from './order';
export type { ApiResponse, PaginatedResponse } from './api';

// services/index.ts - Export services
export { UserService } from './user.service';
export { OrderService } from './order.service';
```

### Dependency Injection

```typescript
// Container pattern
interface Container {
  get<T>(token: symbol): T;
  register<T>(token: symbol, factory: () => T): void;
}

// Service with injected dependencies
class UserService {
  constructor(
    private readonly db: Database,
    private readonly cache: Cache,
    private readonly logger: Logger
  ) {}
}

// Factory function
function createUserService(container: Container): UserService {
  return new UserService(
    container.get<Database>(DatabaseToken),
    container.get<Cache>(CacheToken),
    container.get<Logger>(LoggerToken)
  );
}
```

## Configuration Patterns

### Environment Variables

```typescript
// Type-safe config
interface Config {
  readonly port: number;
  readonly nodeEnv: 'development' | 'production' | 'test';
  readonly database: {
    readonly url: string;
    readonly maxConnections: number;
  };
}

function loadConfig(): Config {
  const port = parseInt(process.env.PORT ?? '3000', 10);
  const nodeEnv = process.env.NODE_ENV as Config['nodeEnv'] ?? 'development';

  if (!['development', 'production', 'test'].includes(nodeEnv)) {
    throw new Error(`Invalid NODE_ENV: ${nodeEnv}`);
  }

  const dbUrl = process.env.DATABASE_URL;
  if (!dbUrl) {
    throw new Error('DATABASE_URL is required');
  }

  return {
    port,
    nodeEnv,
    database: {
      url: dbUrl,
      maxConnections: parseInt(process.env.DB_MAX_CONN ?? '10', 10),
    },
  };
}

// Freeze for immutability
export const config: Config = Object.freeze(loadConfig());
```

## Best Practices Checklist

- [ ] Use `strict: true` in tsconfig.json
- [ ] Avoid `any` - use `unknown` and narrow with type guards
- [ ] Prefer `interface` for object shapes, `type` for unions/intersections
- [ ] Use `readonly` for immutable properties
- [ ] Leverage discriminated unions for state management
- [ ] Create branded types for domain-specific identifiers
- [ ] Implement proper error class hierarchy
- [ ] Use assertion functions for runtime validation
- [ ] Export types separately from implementations
- [ ] Document complex types with JSDoc comments
