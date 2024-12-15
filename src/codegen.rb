class CodeGenerator
  def initialize(ast, path)
    @ast = ast
    @path = path
    @string_counter = 0
    @increment_counter = 0
    @llvm_ir = ""
    @string_constants = []
    @variables = {}
  end

  def generate
    generate_header
    generate_string_constants
    generate_main_function

    final_ir = @string_constants.join("\n") + "\n" + @llvm_ir
    File.write(@path, final_ir)

    compile_and_run
  end

  private

  def generate_header
    @llvm_ir << <<-LLVM
; Объявления функций
declare i32 @printf(i8*, ...) nounwind
declare i32 @sprintf(i8*, i8*, ...) nounwind
declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)

; Константы для форматирования
@.str.int = private unnamed_addr constant [3 x i8] c"%d\\00", align 1
@.str.newline = private unnamed_addr constant [2 x i8] c"\\0A\\00", align 1

LLVM
  end

  def generate_string_constants
    @ast.each_with_index do |node, index|
      case node[:type]
      when :variable_declaration
        generate_string_constant(node[:value], index) if node[:var_type] == :let_string
      when :assignment
        generate_string_constant(node[:value], index) if node[:var_type] == :assign_string
      when :print
        generate_string_constant(node[:value][1..-2], index) if node[:value].start_with?('"') && node[:value].end_with?('"')
      end
    end
  end

  def generate_string_constant(value, index)
    str_value = value.gsub('"', '').encode('UTF-8')
    str_length = str_value.bytesize + 1
    @string_constants << "@str#{index} = private unnamed_addr constant [#{str_length} x i8] c\"#{str_value}\\00\", align 1"
    @string_counter += 1
  end

  def generate_main_function
    @llvm_ir << "define i32 @main() {\n"

    @ast.each_with_index do |node, index|
      case node[:type]
      when :variable_declaration
        generate_variable_declaration(node, index)
      when :assignment
        generate_assignment(node, index)
      when :increment
        generate_increment(node)
      when :add
        generate_add(node)
      when :print
        generate_print(node, index)
      end
    end

    @llvm_ir << "  ret i32 0\n}\n"
  end

  def generate_variable_declaration(node, index)
    if node[:var_type] == :let_int
      @variables[node[:name]] = { type: 'i32', mutable: node[:mutable] }
      @llvm_ir << "  %#{node[:name]} = alloca i32\n"
      @llvm_ir << "  store i32 #{node[:value]}, i32* %#{node[:name]}\n"
    elsif node[:var_type] == :let_string
      @variables[node[:name]] = { type: 'i8*', mutable: node[:mutable] }
      @llvm_ir << "  %#{node[:name]} = alloca i8*, align 8\n"
      @llvm_ir << "  store i8* getelementptr inbounds ([#{node[:value].bytesize - 1} x i8], [#{node[:value].bytesize - 1} x i8]* @str#{index}, i32 0, i32 0), i8** %#{node[:name]}\n"
    end
  end

  def generate_assignment(node, index)
    if @variables[node[:name]]
      if @variables[node[:name]][:mutable]
        if node[:var_type] == :assign_int && @variables[node[:name]][:type] == 'i32'
          @llvm_ir << "  store i32 #{node[:value]}, i32* %#{node[:name]}\n"
        elsif node[:var_type] == :assign_string && @variables[node[:name]][:type] == 'i8*'
          str_length = node[:value].bytesize - 1
          @llvm_ir << "  store i8* getelementptr inbounds ([#{str_length} x i8], [#{str_length} x i8]* @str#{index}, i32 0, i32 0), i8** %#{node[:name]}\n"
        else
          puts "Fatal error: ".red + "Type mismatch in assignment for variable #{node[:name]}"
          exit(1)
        end
      else
        puts "Fatal error: ".red + "Cannot assign to non-mutable variable #{node[:name]}"
        exit(1)
      end
    else
      puts "Fatal error: ".red + "Unknown variable in assignment: #{node[:name]}"
      exit(1)
    end
  end

  def generate_increment(node)
    if @variables[node[:name]] && @variables[node[:name]][:type] == 'i32' && @variables[node[:name]][:mutable]
      increment_id = "#{node[:name]}_inc_#{@increment_counter}"
      @increment_counter += 1

      @llvm_ir << "  %#{increment_id}_value = load i32, i32* %#{node[:name]}\n"
      @llvm_ir << "  %#{increment_id}_result = add i32 %#{increment_id}_value, 1\n"
      @llvm_ir << "  store i32 %#{increment_id}_result, i32* %#{node[:name]}\n"
    else
      puts "Fatal error: ".red + "Cannot increment non-mutable or non-integer variable - #{node[:name]}"
      puts "\tlet #{node[:name]}:" + "mut".green + "= ..."
      exit(1)
    end
  end

  def generate_add(node)
    if @variables[node[:name]] && @variables[node[:name]][:type] == 'i32' && @variables[node[:name]][:mutable]
      add_id = "#{node[:name]}_add_#{@increment_counter}"
      @increment_counter += 1

      @llvm_ir << "  %#{add_id}_value = load i32, i32* %#{node[:name]}\n"
      @llvm_ir << "  %#{add_id}_result = add i32 %#{add_id}_value, #{node[:value]}\n"
      @llvm_ir << "  store i32 %#{add_id}_result, i32* %#{node[:name]}\n"
    else
      puts "Fatal error:".red + "Cannot add to non-mutable or non-integer variable - #{node[:name]}"
      puts "\tlet #{node[:name]}:mut = ..."
      exit(1)
    end
  end

  def generate_print(node, index)
    if node[:value].start_with?('"') && node[:value].end_with?('"')
      # Printing string literal
      str_length = node[:value].bytesize - 1
      @llvm_ir << "  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([#{str_length} x i8], [#{str_length} x i8]* @str#{index}, i32 0, i32 0))\n"
    elsif @variables[node[:value]]
      # Printing variable
      if @variables[node[:value]][:type] == 'i32'
        @llvm_ir << "  %#{node[:value]}_load_#{index} = load i32, i32* %#{node[:value]}\n"
        @llvm_ir << "  %#{node[:value]}_str_#{index} = call i8* @llvm.stacksave()\n"
        @llvm_ir << "  %#{node[:value]}_ptr_#{index} = alloca [16 x i8]\n"
        @llvm_ir << "  %#{node[:value]}_cast_#{index} = bitcast [16 x i8]* %#{node[:value]}_ptr_#{index} to i8*\n"
        @llvm_ir << "  call i32 (i8*, i8*, ...) @sprintf(i8* %#{node[:value]}_cast_#{index}, i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.int, i32 0, i32 0), i32 %#{node[:value]}_load_#{index})\n"
        @llvm_ir << "  call i32 (i8*, ...) @printf(i8* %#{node[:value]}_cast_#{index})\n"
        @llvm_ir << "  call void @llvm.stackrestore(i8* %#{node[:value]}_str_#{index})\n"
      elsif @variables[node[:value]][:type] == 'i8*'
        @llvm_ir << "  %#{node[:value]}_load_#{index} = load i8*, i8** %#{node[:value]}\n"
        @llvm_ir << "  call i32 (i8*, ...) @printf(i8* %#{node[:value]}_load_#{index})\n"
      end
    else
      if node[:value].nil?
        puts "Fatal error: ".red + "print() cannot be empty"
        exit(1)
      else
        puts "Fatal error: ".red + "Unknown variable in print: #{node[:value]}"
        exit(1)
      end
    end
    # Add newline after each print
    @llvm_ir << "  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.newline, i32 0, i32 0))\n"
  end

  def compile_and_run
    system("llvm-as #{@path} -o a.bc")
    
    if File.exist?("a.bc")
      system("llc a.bc -o a.s")
      
      if File.exist?("a.s")
        system("gcc a.s -o a.out -no-pie")
        system("./a.out")

        File.delete("a.bc") if File.exist?("a.bc")
        File.delete("a.s") if File.exist?("a.s")
      else
        puts "Compiler error: ".red + "a.s file was not created."
      end
    else
      puts "Compiler error: ".red + "a.bc file was not created."
    end
  end
end
