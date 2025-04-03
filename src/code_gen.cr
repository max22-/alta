class CodeGen
    @c_code : String = 
        {{ read_file("./c_code/includes.c") }} + "\n\n" +
        {{ read_file("./c_code/stack.c")}} + "\n\n"
    @ast : Array(Rule)

    def initialize(@ast)
    end

    def generate
        puts @c_code

        #puts(
        #    "Stack stacks[#{StackSymbol.counter}];\n"   \
        #    "\n"                                        \
        #    "void alta_setup(void) {\n"                 \
        #    "    INIT_STACKS(stacks);\n"
        #)
        
        @ast.each { |rule| 
            if rule.lhs.value.empty?
                rule.rhs.value.each { | stack_and_symbol|
                stack, symbol = stack_and_symbol
                puts "    stack_push(&stack[#{stack.interned}], #{symbol.interned});\n"
            }
            end
        }

        puts
            "}\n"                   \
            "\n"                    \
            "void alta_loop() {\n"  \
            "}\n"

    end
end