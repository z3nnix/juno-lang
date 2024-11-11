class CodeGenerator
  def initialize(ast, path)
    @ast = ast
    @path = path
    @string_counter = 0 # Счётчик для уникальных строк
    @llvm_ir = ""
    @string_lengths = [] # Массив для хранения длин строк
  end

  def generate
    # Добавление объявления функции printf один раз
    @llvm_ir << <<-LLVM
declare i32 @printf(i8*, ...) nounwind

LLVM

    # Генерация строковых констант
    string_definitions = ""
    
    @ast.each do |node|
      if node[:type] == :println
        str_value = node[:value].encode('UTF-8') # Убедитесь, что строка в UTF-8
        str_length = str_value.bytesize + 2 # +1 для \n, +1 для \0

        # Генерация уникального имени для каждой строки
        unique_str_name = "@str#{@string_counter}"
        @string_counter += 1

        string_definitions << <<-LLVM
#{unique_str_name} = private unnamed_addr constant [#{str_length} x i8] c"#{str_value}\\0A\\00", align 1
LLVM

        # Сохраняем длину строки для использования позже
        @string_lengths << str_length
      end
    end

    # Добавление определений строк в начало IR
    @llvm_ir << string_definitions

    # Определение функции main
    @llvm_ir << <<-LLVM
define i32 @main() {
LLVM

    # Добавление вызовов printf для каждой строки
    @ast.each_with_index do |node, index|
      if node[:type] == :println
        unique_str_name = "@str#{index}" # Получаем имя строки по индексу
        
        @llvm_ir << <<-LLVM
    call i32 @printf(i8* getelementptr inbounds ([#{@string_lengths[index]} x i8], [#{@string_lengths[index]} x i8]* #{unique_str_name}, i32 0, i32 0))
LLVM
      end
    end

    # Завершение функции main
    @llvm_ir << <<-LLVM
    ret i32 0
}
LLVM

    # Сохранение LLVM IR в файл
    File.write(@path, @llvm_ir)

    # Компиляция LLVM IR в исполняемый файл
    system("llvm-as #{@path} -o a.bc")
    
    # Проверка на наличие файла перед компиляцией
    if File.exist?("a.bc")
      system("llc a.bc -o a.s")
      
      if File.exist?("a.s")
        system("gcc a.s -o a.out -no-pie")
        
        # Запуск исполняемого файла
        system("./a.out")

        # Удаление временных файлов
        File.delete("a.bc") if File.exist?("a.bc")
        File.delete("a.s") if File.exist?("a.s")
      else
        puts "Ошибка: файл a.s не был создан."
      end
    else
      puts "Ошибка: файл a.bc не был создан."
    end
  end
end
