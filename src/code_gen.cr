class CodeGen
    @embedded_c_code : String = 
        {{ read_file("./c_code/includes.c") }} + "\n\n" +
        {{ read_file("./c_code/stack.c")}} + "\n\n"
    @ast : Array(Rule)

    @output_code : String

    def initialize(@ast)
        @output_code = @embedded_c_code
    end

    def emit(code)
        @output_code += code + "\n"
    end

    def gen_stacks_init
        emit "    INIT_STACKS(stacks);"
        @ast.each { |rule| 
            if rule.lhs.value.empty?
                rule.rhs.value.each { | stack_and_symbol|
                stack, symbol = stack_and_symbol
                emit "    stack_push(&stack[#{stack.interned}], #{symbol.interned});"
            }
            end
        }
        emit ""
    end

    def gen_push_back(lhs, n)
        (0..n).reverse_each { | i |
            stack, symbol = lhs[i]
            emit "            stack_push(&stacks[#{stack.interned} /* #{stack.value} */], s#{i});"
        }
    end

    def gen_rule(n, lhs, rhs)
        emit "    // rule #{n}"
        emit "    {"
        #@output_code += lhs.to_s + "\n"
        lhs.each_with_index { | stack_and_symbol, i |
            stack, symbol = stack_and_symbol
            emit "        interned_symbol s#{i} = stack_pop(&stacks[#{stack.interned}]); /* #{stack.value} */"
            emit "        if(s#{i} != #{symbol.interned} /* #{symbol.value} */) {"
            gen_push_back lhs, i
            emit "        }"
        }
        emit "    }"
        emit ""
    end

    def gen_rules
        @ast.each_with_index { |rule, n| 
            if !rule.lhs.value.empty?
                gen_rule n, rule.lhs.value, rule.rhs.value
            end
        }
    end

    def generate
        emit "Stack stacks[#{StackSymbol.counter}];"
        emit ""
        emit "void alta_init(void) {"
        
        gen_stacks_init

        gen_rules

        emit "}"
        emit ""
        emit "void alta_loop() {"
        emit "}"

        @output_code
    end
end