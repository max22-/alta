class CodeGen
  @embedded_c_code : String = {{ read_file("./c_code/prebuilt_code.c") }} + "\n\n"
  @ast : Array(Rule)

  @output_code : String

  def initialize(@ast)
    @output_code = @embedded_c_code
  end

  def emit(code)
    @output_code += code + "\n"
  end

  def gen_names
    emit "const char* stacks_names[] = {"
    emit (0...StackSymbol.counter).map { |interned| "    " + StackSymbol.get_name(interned).inspect }.join(",\n")
    emit "};"
    emit ""
    emit "const char* symbols_names[] = {"
    emit (0...SimpleSymbol.counter).map { |interned| "    " + SimpleSymbol.get_name(interned).inspect }.join(",\n")
    emit "};"
    emit ""
  end

  def gen_stacks_init
    emit "    INIT_STACKS(stacks);"
    @ast.each { |rule|
      if rule.lhs.value.empty?
        rule.rhs.value.each { |stack_and_symbol|
          stack, symbol = stack_and_symbol
          emit "    stack_push(&stacks[#{stack.interned}] /* #{stack.value} */, #{symbol.interned} /* #{symbol.value} */);"
        }
      end
    }
    emit ""
  end

  def gen_rule(n, lhs, rhs)
    emit "    // rule #{n}"
    # @output_code += lhs.to_s + "\n"

    stack_depths = Array.new(StackSymbol.counter, 0)

    condition = lhs.map { |stack_and_symbol|
      stack, symbol = stack_and_symbol
      depth = stack_depths[stack.interned]
      stack_depths[stack.interned] += 1
      "stack_peek(&stacks[#{stack.interned}] /* #{stack.value} */, #{depth}) == #{symbol.interned} /* #{symbol.value} */"
    }.join("\n          && ")
    emit "    if(#{condition}) {"
    stack_depths.each_with_index { |depth, i|
      if depth != 0
        emit "        stack_pop(&stacks[#{i}], #{depth});"
      end
    }

    rhs.each { |stack_and_symbol|
      stack, symbol = stack_and_symbol
      emit "        stack_push(&stacks[#{stack.interned}] /* #{stack.value} */, #{symbol.interned} /* #{symbol.value} */);"
    }

    emit "        return 1;"
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
    gen_names
    emit "Stack stacks[#{StackSymbol.counter}];"
    emit ""
    emit "void alta_init(void) {"
    gen_stacks_init
    emit "}"
    emit ""

    emit "int alta_iteration() {"
    gen_rules
    emit "    return 0;"
    emit "}"
    emit ""

    emit {{ read_file("./c_code/stack_display.c") }}
    emit ""
    emit ""
    emit {{ read_file("./c_code/main.c") }}

    @output_code
  end
end
