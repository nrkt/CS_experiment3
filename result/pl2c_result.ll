@n = common global i32 0, align 4
@sum = common global i32 0, align 4

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define void @result1(i32){ 
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = load i32, i32* @sum, align 4
  %4 = load i32, i32* %2, align 4
  %5 = add nsw i32 %3, %4
  store i32 %5, i32* @sum, align 4
  ret void 
}

define void @result0() {
  %1 = load i32, i32* @sum, align 4
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %1)
  ret void 
}

define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 10, i32* @n, align 4
  store i32 0, i32* @sum, align 4
  br label %2

  ; <label>:2:
  %3 = load i32, i32* @n, align 4
  %4 = icmp sgt i32 %3, 0
  br i1 %4, label %5, label %9

  ; <label>:5:
  %6 = load i32, i32* @n, align 4
  call void @result1(i32 %6)
  %7 = load i32, i32* @n, align 4
  %8 = sub nsw i32 %7, 1
  store i32 %8, i32* @n, align 4
  br label %2

  ; <label>:9:
  call void @result0()
  %10 = load i32, i32* @n, align 4
  ret i32 %10
}

declare i32 @printf(i8*, ...)
