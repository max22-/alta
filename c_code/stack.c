#define DEFAULT_STACK_SIZE 256

typedef unsigned int interned_symbol;

typedef struct Stack {
    interned_symbol *items;
    size_t ptr, capacity;
} Stack;

static void alloc_failed() {
    fprintf(stderr, "failed to allocate memory\n");
    exit(1);
}

static void stack_underflow() {
    fprintf(stderr, "stack underflow\n");
    exit(1);
}

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

#define INIT_STACKS(x)                              \
    do {                                            \
        for(size_t i = 0; i < ARRAY_SIZE(x); i++)   \
            x[i] = stack_new();                     \
    } while(0)

Stack stack_new(void)
{
    Stack stack;
    stack.items = (unsigned int*)malloc(DEFAULT_STACK_SIZE * sizeof(interned_symbol));
    if(!stack.items) alloc_failed();
    stack.ptr = 0;
    stack.capacity = 0;
}

void stack_grow(Stack *stack) {
    unsigned int new_capacity = 2 * stack->capacity;
    stack->items = (unsigned int*)malloc(new_capacity * sizeof(interned_symbol));
    if(!stack->items) alloc_failed();
    stack->capacity = new_capacity;
}

void stack_push(Stack *stack, interned_symbol s) {
    if(stack->ptr >= stack->capacity) stack_grow(stack);
    stack->items[stack->ptr++] = s;
}

interned_symbol stack_pop(Stack *stack) {
    if(stack->ptr == 0) stack_underflow();
    return stack->items[--stack->ptr];
}