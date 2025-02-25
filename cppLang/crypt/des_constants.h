#ifndef DES_CONSTANTS_H
#define DES_CONSTANTS_H

// 初始换位表
extern const int IP[64];

// 扩展换位表
extern const int E[48];

// PC1换位表（64—>56）
extern const int PC1[56];

// 循环移位表
extern const int move[16];

// PC2换位表（56—>48）
extern const int PC2[48];

// S1 - S8换位表
extern const int S1[4][16];
extern const int S2[4][16];
extern const int S3[4][16];
extern const int S4[4][16];
extern const int S5[4][16];
extern const int S6[4][16];
extern const int S7[4][16];
extern const int S8[4][16];

//P换位表
extern const int P[32];

/**
 * 将字符转换为8位二进制数组
 *
 * 该函数的作用是将一个字符转换为对应的8位二进制表示，并将结果存储在传入的整数数组中。
 *
 * @param ch 要转换的字符
 * @param binary 用于存储转换后的8位二进制数组的指针，数组长度至少为8
 */
void charToBinary(char ch, int *binary);

/**
 * 进行PC1置换
 *
 * 此函数执行DES算法中的PC1（Permuted Choice 1）置换操作，将64位密钥经过PC1置换得到56位密钥。
 *
 * @param key 输入的64位密钥数组，该数组的内容在函数执行过程中不会被修改
 * @param keyPC1 用于存储经过PC1置换后的56位密钥数组的指针，数组长度至少为56
 */
void pc1Substitution(const int *key, int *keyPC1);

/**
 * 进行PC2置换
 *
 * 该函数执行DES算法中的PC2（Permuted Choice 2）置换操作，将经过循环左移合并后的56位密钥经过PC2置换得到48位子密钥，并将其存储到指定轮数的子密钥数组中。
 *
 * @param keyAB 输入的经过循环左移合并后的56位密钥数组，该数组的内容在函数执行过程中不会被修改
 * @param t 当前的轮数，取值范围为0到15
 * @param K 二维数组，用于存储16轮循环生成的48位子密钥，数组大小为[16][48]
 */
void pc2Substitution(const int *keyAB, int t, int K[16][48]);

/**
 * 左移操作
 *
 * 该函数对输入的28位二进制数组进行左移操作，左移的位数根据传入的参数决定。
 *
 * @param arr 要进行左移操作的28位二进制数组
 * @param shift 左移的位数，取值为1或2
 */
void leftShift(int *arr, int shift);

/**
 * 进行E扩展
 *
 * 此函数执行DES算法中的E（Expansion）扩展操作，将32位的右半部分数据扩展为48位。
 *
 * @param R0 输入的32位右半部分数据数组，该数组的内容在函数执行过程中不会被修改
 * @param RE0 用于存储经过E扩展后的48位数据数组的指针，数组长度至少为48
 */
void eExpansion(const int *R0, int *RE0);

/**
 * 进行S盒替换
 *
 * 该函数执行DES算法中的S盒（Substitution Box）替换操作，将48位的输入数据经过8个S盒替换得到8个十进制数据。
 *
 * @param RK 输入的48位数据数组，该数组的内容在函数执行过程中不会被修改
 * @param RKS 用于存储经过S盒替换后的8个十进制数据数组的指针，数组长度至少为8
 */
void sBoxSubstitution(const int *RK, int *RKS);

/**
 * 将RKS转换为32位二进制
 *
 * 此函数将经过S盒替换得到的8个十进制数据转换为32位二进制表示，并将结果存储在传入的整数数组中。
 *
 * @param RKS 输入的包含8个十进制数据的数组，该数组的内容在函数执行过程中不会被修改
 * @param SP 用于存储转换后的32位二进制数组的指针，数组长度至少为32
 */
void rksToBinary(const int *RKS, int *SP);

/**
 * 进行P置换
 *
 * 该函数执行DES算法中的P（Permutation）置换操作，将32位的数据经过P置换得到新的32位数据。
 *
 * @param SP 输入的32位数据数组，该数组的内容在函数执行过程中不会被修改
 * @param RKSP 用于存储经过P置换后的32位数据数组的指针，数组长度至少为32
 */
void pSubstitution(const int *SP, int *RKSP);

/**
 * @brief 使用DES算法结合CBC模式对明文进行加密，并将结果转换为十六进制字符串
 * @param MingWen 要加密的明文，以字符串形式传入
 * @param K 16轮子密钥，是一个二维数组，大小为 [16][48]，在调用此函数前应已正确生成
 * @param text_out 用于存储中间加密结果的二维数组，大小为 [14][64]，
 *                 其中第一行通常存储初始化向量，后续行存储每个分组加密后的结果
 * @param MiWen 用于存储最终加密后的十六进制字符串，数组大小至少为 208，
 *              函数执行完毕后，该数组将包含加密后的十六进制表示
 */
void desCbcEncrypt(const char *MingWen, const int K[16][48], int text_out[14][64], char MiWen[208]);

/**
 * @brief 对十六进制密文进行DES解密操作
 * @param H 存储十六进制密文转换后的十进制数组
 * @param n 十六进制密文转换后的十进制数组的长度
 * @param K 16轮子密钥，二维数组，大小为 [16][48]
 * @param text_out 存储中间结果的二维数组，大小为 [14][64]
 * @param result 存储最终解密结果的二维数组，大小为 [13][64]
 * @param M 存储解密后二进制转换为十进制的结果的二维数组，大小为 [13][8]
 */
void desDecryptionProcess(int *H, int n, int K[16][48], int text_out[14][64], int result[13][64], int M[13][8]);

#endif // DES_CONSTANTS_H