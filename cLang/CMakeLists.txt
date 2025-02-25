cmake_minimum_required(VERSION 3.23)
project(cLang C)

set(CMAKE_C_STANDARD 11)

# 打个招呼
add_executable(hello hello.c)

# 设置WIN32标志,以去除黑框
add_executable(S WIN32 sevenBtn/sevenBtn.c)


#DES加密
add_executable(Des crypt/DES_Enc.c crypt/des_constants.h crypt/des_constants.c)
#ElGamal数字签名
add_executable(ElGamal crypt/ElGamal_Sign.c)
#HASH算法MD5
add_executable(HASH_MD5 crypt/HASH_MD5.c)
#公钥加密算法RSA
add_executable(RSA_Enc crypt/RSA_Enc.c)
