enum TokenType
  VerticalBar
  Symbol
  Colon
  Comma
  EOF
end

class Token
  @type : TokenType
  @value : String
  @pos : Int32

  getter :type
  getter :value
  getter :pos

  def initialize(@type, @value, @pos)
  end

  def to_s(io : IO)
    io << "Token(#{@type}, #{@value}, #{@pos})"
  end
end

class Lexer
  @source : String
  @start : Int32
  @pos : Int32

  def initialize(@source)
    @start = 0
    @pos = 0
  end

  def look
    @source[@pos]
  end

  def advance
    @pos += 1
  end

  def selected_token
    @source[@start...@pos]
  end

  def skipspace
    while @pos < @source.size && look.whitespace?
      advance
    end
  end

  def next
    skipspace
    @start = @pos
    return Token.new(TokenType::EOF, "EOF", @source.size) if @pos >= @source.size
    case look
    when '|'
      advance
      Token.new(TokenType::VerticalBar, selected_token, @start)
    when ':'
      advance
      Token.new(TokenType::Colon, selected_token, @start)
    when ','
      advance
      Token.new(TokenType::Comma, selected_token, @start)
    else
      while @pos < @source.size && look != '|' && look != ':' && look != ','
        advance
      end
      Token.new(TokenType::Symbol, selected_token.strip, @start)
    end
  end
end

class Interned
  @@interned = {} of String => Int32
  @@counter = 0
  @value : String
  getter :value

  def initialize(@value)
    if !@@interned.has_key? @value
      @@interned[@value] = @@counter
      @@counter += 1
    end
  end

  def interned
    @@interned[@value]
  end

  def Interned.counter
    @@counter
  end

  def Interned.get_name(interned_symbol)
    begin
      return @@interned.key_for interned_symbol
    rescue ex : IndexError
      raise Exception.new "unreachable"
    end
  end
end

class StackSymbol < Interned
  def to_s(io : IO)
    io << "Stack(\"#{@value}\", #{@@interned[@value]})"
  end
end

class SimpleSymbol < Interned
  def to_s(io : IO)
    io << "Symbol(\"#{@value}\", #{@@interned[@value]})"
  end
end

class Side
  @value = [] of {StackSymbol, SimpleSymbol}
  getter :value

  def <<(stack_and_symbol)
    @value << stack_and_symbol
  end

  def to_s(io : IO)
    io << @value.map { |e| "#{e[0].to_s}: #{e[1].to_s}" }.join(", ")
  end
end

class Rule
  @lhs : Side
  @rhs : Side
  getter :lhs
  getter :rhs

  def initialize(@lhs, @rhs)
  end

  def to_s(io : IO)
    io << "| #{@lhs} | #{@rhs}"
  end
end

class ParseError < Exception
  def initialize(file_name : String, pos : {Int32, Int32}, msg : String)
    super("#{file_name}:#{pos[0]}:#{pos[1]}: #{msg}")
  end
end

class Parser
  @lexer : Lexer
  @look : Token
  @file_name : String
  @source : String

  def initialize(@file_name, @source)
    @lexer = Lexer.new source
    @look = @lexer.next
  end

  def line_and_column(pos : Int32) : {Int32, Int32}
    line = 1
    column = 1

    @source.each_char_with_index { |c, i|
      if i == pos
        return {line, column}
      end
      if c == '\n'
        line += 1
        column = 1
      else
        column += 1
      end
    }
    raise Exception.new "unreachable"
  end

  def advance
    result = @look
    @look = @lexer.next
    result
  end

  def match(type : TokenType)
    raise ParseError.new(@file_name, line_and_column(@look.pos), "expected #{type}") if @look.type != type
    advance
  end

  def stack_and_symbol
    stack = match TokenType::Symbol
    match TokenType::Colon
    symbol = match TokenType::Symbol
    {StackSymbol.new(stack.value), SimpleSymbol.new(symbol.value)}
  end

  def side
    result = Side.new
    if @look.type == TokenType::Symbol
      result << stack_and_symbol
      while @look.type == TokenType::Comma
        advance
        result << stack_and_symbol
      end
    end
    return result
  end

  def rule
    match TokenType::VerticalBar
    lhs = side
    match TokenType::VerticalBar
    rhs = side
    Rule.new lhs, rhs
  end

  def parse
    rules = [] of Rule
    while @look.type != TokenType::EOF
      rules << rule
    end
    rules
  end
end
