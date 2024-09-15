class CodeGenerator
  def initialize(ast, path)
    @ast = ast
    @path = path
  end

  def generate
    # Генерация LLVM IR
    str_value = @ast[:value].encode('UTF-8') # Убедитесь, что строка в UTF-8
    str_length = str_value.bytesize + 2 # +1 для \n, +1 для \0
    llvm_ir = <<-LLVM
@.str = private unnamed_addr constant [#{str_length} x i8] c"#{str_value}\\0A\\00", align 1

declare i32 @printf(i8*, ...) nounwind

define i32 @main() {
    call i32 @printf(i8* getelementptr inbounds ([#{str_length} x i8], [#{str_length} x i8]* @.str, i32 0, i32 0))
    ret i32 0
}
LLVM

    # Сохранение LLVM IR в файл
    File.write(@path, llvm_ir)

    # Компиляция LLVM IR в исполняемый файл
    system("llvm-as #{@path} -o a.bc")
    system("llc a.bc -o a.s")
    system("gcc a.s -o a.out -no-pie")

    # Запуск исполняемого файла
    system("./a.out")

    # Удаление временных файлов
    File.delete("a.bc") if File.exist?("a.bc")
    File.delete("a.s") if File.exist?("a.s")
  end
end

