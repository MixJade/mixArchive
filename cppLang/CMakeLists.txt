cmake_minimum_required(VERSION 3.24)
project(cppLang)

set(CMAKE_CXX_STANDARD 17)

#校验输出
add_executable(cppLang main.cpp)
#DES加密
add_executable(Des crypt/Des_Enc.c crypt/des_constants.h crypt/des_constants.c)
#ElGamal数字签名
add_executable(ElGamal crypt/ElGamal_Sign.cpp)
