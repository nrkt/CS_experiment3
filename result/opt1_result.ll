@x = common global i32 0, align 4


define i32 @main() {
  %1 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 10, i32* @x, align 4
  %2 = load i32, i32* @x, align 4
  %3 = shl i32 %2, 3
  store i32 %3, i32* @x, align 4
  %4 = load i32, i32* @x, align 4
  %5 = ashr i32 %4, 2
  store i32 %5, i32* @x, align 4
  %6 = load i32, i32* @x, align 4
  %7 = shl i32 %6, 5
  store i32 %7, i32* @x, align 4
  %8 = load i32, i32* @x, align 4
  ret i32 %8
}

