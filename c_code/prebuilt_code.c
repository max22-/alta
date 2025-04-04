#ifndef ALTA_INCLUDE_GUARD
#define ALTA_INCLUDE_GUARD

#define DEFAULT_STACK_SIZE 256

typedef int interned_symbol;
typedef struct Stack Stack;

#define INIT_STACKS(x)                              \
    do {                                            \
        for(size_t i = 0; i < ARRAY_SIZE(x); i++)   \
            x[i] = stack_new();                     \
    } while(0)

Stack stack_new(void);

#ifdef ALTA_IMPLEMENTATION

#include <stdio.h>
#include <stdlib.h>

struct Stack {
    interned_symbol *items;
    size_t ptr, capacity;
};

static void alloc_failed() {
    fprintf(stderr, "failed to allocate memory\n");
    exit(1);
}

static void stack_underflow() {
    fprintf(stderr, "stack underflow\n");
    exit(1);
}

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

Stack stack_new(void)
{
    Stack stack;
    stack.items = (unsigned int*)malloc(DEFAULT_STACK_SIZE * sizeof(interned_symbol));
    if(!stack.items) alloc_failed();
    stack.ptr = 0;
    stack.capacity = DEFAULT_STACK_SIZE;
    return stack;
}

static void stack_grow(Stack *stack) {
    unsigned int new_capacity = 2 * stack->capacity;
    stack->items = (unsigned int*)realloc(stack->items, new_capacity * sizeof(interned_symbol));
    if(!stack->items) alloc_failed();
    stack->capacity = new_capacity;
}

static void stack_push(Stack *stack, interned_symbol s) {
    if(stack->ptr >= stack->capacity) stack_grow(stack);
    stack->items[stack->ptr++] = s;
}

static interned_symbol stack_peek(Stack *stack, unsigned int n) {
    if(n >= stack->ptr) return -1;
    return stack->items[stack->ptr - 1 - n];
}

static void stack_pop(Stack *stack, unsigned int n) {
    if(n > stack->ptr) stack_underflow();
    stack->ptr -= n;
}