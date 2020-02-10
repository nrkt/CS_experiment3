@n = common global i32 0, align 4

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1

define i32 @fact1(i32){ 
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 %0, i32* %3, align 4
  %4 = load i32, i32* %3, align 4
  %5 = icmp sle i32 %4, 0
  br i1 %5, label %6, label %7

  ; <label>:6:
  store i32 1, i32* %2, align 4
  br label %13

  ; <label>:7:
  %8 = load i32, i32* %3, align 4
  %9 = sub nsw i32 %8, 1
  %10 = call i32 @fact1(i32 %9)
  %11 = load i32, i32* %3, align 4
  %12 = mul nsw i32 %10, %11
  store i32 %12, i32* %2, align 4
  br label %13

  ; <label>:13:
  %14 = load i32, i32* %2, align 4
  ret i32 %14
}

define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i64 0, i64 0), i32* @n)
  %3 = load i32, i32* @n, align 4
  %4 = call i32 @fact1(i32 %3)
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %4)
  %6 = load i32, i32* %1, align 4
  ret i32 %6
}

declare i32 @scanf(i8*, ...)
declare i32 @printf(i8*, ...)
