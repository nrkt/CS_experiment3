@i = common global i32 0, align 4
@j = common global i32 0, align 4
@n = common global i32 0, align 4
@a = common dso_local global [100 x i32] zeroinitializer, align 16

@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"%d\00", align 1

define void @initialize1(i32){ 
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = alloca i32, align 4
  store i32 1, i32* %3, align 4
  br label %4

  ; <label>:4:
  %5 = load i32, i32* %3, align 4
  %6 = load i32, i32* %2, align 4
  %7 = icmp sle i32 %5, %6
  br i1 %7, label %8, label %17

  ; <label>:8:
  %9 = load i32, i32* %3, align 4
  %10 = sub nsw i32 %9, 1
  %11 = sext i32 %10 to i64
  %12 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %11
  %13 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i64 0, i64 0), i32* %12)
  br label %14

  ; <label>:14:
  %15 = load i32, i32* %3, align 4
  %16 = add nsw i32 %15, 1
  store i32 %16, i32* %3, align 4
  br label %4

  ; <label>:17:
  ret void 
}

define void @swap1(i32){ 
  %2 = alloca i32, align 4
  store i32 %0, i32* %2, align 4
  %3 = alloca i32, align 4
  %4 = load i32, i32* %2, align 4
  %5 = sub nsw i32 %4, 1
  %6 = sext i32 %5 to i64
  %7 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %6
  %8 = load i32, i32* %7, align 4
  store i32 %8, i32* %3, align 4
  %9 = load i32, i32* %2, align 4
  %10 = sub nsw i32 %9, 1
  %11 = sext i32 %10 to i64
  %12 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %11
  %13 = load i32, i32* %2, align 4
  %14 = add nsw i32 %13, 1
  %15 = sub nsw i32 %14, 1
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %16
  %18 = load i32, i32* %17, align 4
  store i32 %18, i32* %12, align 4
  %19 = load i32, i32* %2, align 4
  %20 = add nsw i32 %19, 1
  %21 = sub nsw i32 %20, 1
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %22
  %24 = load i32, i32* %3, align 4
  store i32 %24, i32* %23, align 4
  ret void 
}

define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str.1, i64 0, i64 0), i32* @n)
  %3 = load i32, i32* @n, align 4
  %4 = icmp sle i32 %3, 100
  br i1 %4, label %5, label %44

  ; <label>:5:
  %6 = load i32, i32* @n, align 4
  call void @initialize1(i32 %6)
  %7 = load i32, i32* @n, align 4
  store i32 %7, i32* @i, align 4
  br label %8

  ; <label>:8:
  %9 = load i32, i32* @i, align 4
  %10 = icmp sle i32 1, %9
  br i1 %10, label %11, label %43

  ; <label>:11:
  store i32 1, i32* @j, align 4
  br label %12

  ; <label>:12:
  %13 = load i32, i32* @j, align 4
  %14 = load i32, i32* @i, align 4
  %15 = icmp slt i32 %13, %14
  br i1 %15, label %16, label %34

  ; <label>:16:
  %17 = load i32, i32* @j, align 4
  %18 = sub nsw i32 %17, 1
  %19 = sext i32 %18 to i64
  %20 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %19
  %21 = load i32, i32* %20, align 4
  %22 = load i32, i32* @j, align 4
  %23 = add nsw i32 %22, 1
  %24 = sub nsw i32 %23, 1
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %25
  %27 = load i32, i32* %26, align 4
  %28 = icmp sgt i32 %21, %27
  br i1 %28, label %29, label %31

  ; <label>:29:
  %30 = load i32, i32* @j, align 4
  call void @swap1(i32 %30)
  br label %31

  ; <label>:31:
  %32 = load i32, i32* @j, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* @j, align 4
  br label %12

  ; <label>:34:
  %35 = load i32, i32* @i, align 4
  %36 = sub nsw i32 %35, 1
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds [100 x i32], [100 x i32]* @a, i64 0,i64 %37
  %39 = load i32, i32* %38, align 4
  %40 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %39)
  %41 = load i32, i32* @i, align 4
  %42 = sub nsw i32 %41, 1
  store i32 %42, i32* @i, align 4
  br label %8

  ; <label>:43:
  br label %44

  ; <label>:44:
  %45 = load i32, i32* @i, align 4
  ret i32 %45
}

declare i32 @scanf(i8*, ...)
declare i32 @printf(i8*, ...)
