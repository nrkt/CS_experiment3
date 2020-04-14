講義で作成したPascalコンパイラ(LLVM IR出力)
====

# 実行方法
Makeコマンドでコンパイルしたあと, `./parser (ファイル名)`でコンパイル  
llvmファイル(result.ll)が作成されるので`lli result.ll`で実行  

# 実行できるもの
*while文  
*for文  
*配列  
*手続き  
*関数(オーバーロード可)  
*write文(文字列不可)  
*read文(文字列不可)
