void stack_display(interned_symbol s) {
    Stack *stack = &stacks[s];
    printf("* %s\n", stacks_names[s]);
    if(stack->ptr > 0) {
        for(int i = stack->ptr - 1; i >= 0; i--) {
            printf("  - %s\n", symbols_names[stack->items[i]]);
        }
    }
}

void stacks_display() {
    for(size_t i = 0; i < ARRAY_SIZE(stacks); i++)
        stack_display(i);
}