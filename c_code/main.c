#ifdef USE_PREBUILT_MAIN

int main(void) {
    alta_init();
    stacks_display();
    while(alta_iteration());
    printf("\n\nResult:\n");
    stacks_display();
    return 0;
}

#endif /* USE_PREBUILT_MAIN */

#endif /* ALTA_IMPLEMENTATION*/

#endif /* ALTA_INCLUDE_GUARD */