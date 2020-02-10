@sum = common global i32 0, align 4
@n = common global i32 0, align 4

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1

define void @proc10() {
  %1 = load i32, i32* @sum, align 4
  %2 = load i32, i32* @n, align 4
  %3 = add nsw i32 %1, %2
  store i32 %3, i32* @sum, align 4
  call void @proc20()
  ret void 
}

define void @proc20() {
  %1 = load i32, i32* @n, align 4
  %2 = sub nsw i32 %1, 1
  store i32 %2, i32* @n, align 4
  %3 = load i32, i32* @n, align 4
  %4 = icmp sgt i32 %3, 0
  br i1 %4, label %5, label %6

  ; <label>:5:
  call void @proc10()
  br label %9

  ; <label>:6:
  %7 = load i32, i32* @sum, align 4
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %7)
  br label %9

  ; <label>:9:
  ret void 
}

define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 0, i32* @sum, align 4
  %2 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i64 0, i64 0), i32* @n)
  call void @proc10()
  %3 = load i32, i32* @sum, align 4
  ret i32 %3
}

declare i32 @scanf(i8*, ...)
declare i32 @printf(i8*, ...)
