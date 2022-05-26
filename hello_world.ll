define i64 @function_0() {
  block_0:
  ret i64 3

}

@.output_format_string = private unnamed_addr constant [4 x i8] c"%d\0A\00"
declare i32 @printf(i8* nocapture, ...) nounwind
define i32 @main() {
  %cast_output_format_string = getelementptr [4 x i8],[4 x i8]* @.output_format_string, i64 0, i64 0
  %super_main_result = call i64 @function_0()
  call i32 (i8*, ...) @printf(i8* %cast_output_format_string, i64 %super_main_result)
  ret i32 0
}

