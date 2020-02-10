@n = common global i32 0, align 4
@temp = common global i32 0, align 4

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1

define void @fact0() {
  %1 = alloca i32, align 4
  %2 = load i32, i32* @n, align 4
  %3 = icmp sle i32 %2, 1
  br i1 %3, label %4, label %5

  ; <label>:4:
  store i32 1, i32* @temp, align 4
  br label %12

  ; <label>:5:
  %6 = load i32, i32* @n, align 4
  store i32 %6, i32* %1, align 4
  %7 = load i32, i32* @n, align 4
  %8 = sub nsw i32 %7, 1
  store i32 %8, i32* @n, align 4
  call void @fact0()
  %9 = load i32, i32* @temp, align 4
  %10 = load i32, i32* %1, align 4
  %11 = mul nsw i32 %9, %10
  store i32 %11, i32* @temp, align 4
  br label %12

  ; <label>:12:
  ret void 
}

define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i64 0, i64 0), i32* @n)
  call void @fact0()
  %3 = load i32, i32* @temp, align 4
  %4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %3)
  %5 = load i32, i32* %1, align 4
  ret i32 %5
}

declare i32 @scanf(i8*, ...)
declare i32 @printf(i8*, ...)
