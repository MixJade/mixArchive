cmake_minimum_required(VERSION 3.24)
project(cLang C)

set(CMAKE_C_STANDARD 11)

# 打个招呼
add_executable(hello hello.c)

# 设置WIN32标志,以去除黑框
add_executable(S WIN32 sevenBtn.c)
