#include <string.h>

int IP[64] = { //初始换位表
        58, 50, 42, 34, 26, 18, 10, 2,
        60, 52, 44, 36, 28, 20, 12, 4,
        62, 54, 46, 38, 30, 22, 14, 6,
        64, 56, 48, 40, 32, 24, 16, 8,
        57, 49, 41, 33, 25, 17, 9, 1,
        59, 51, 43, 35, 27, 19, 11, 3,
        61, 53, 45, 37, 29, 21, 13, 5,
        63, 55, 47, 39, 31, 23, 15, 7
};

int E[48] = { //扩展换位表
        32, 1, 2, 3, 4, 5,
        4, 5, 6, 7, 8, 9,
        8, 9, 10, 11, 12, 13,
        12, 13, 14, 15, 16, 17,
        16, 17, 18, 19, 20, 21,
        20, 21, 22, 23, 24, 25,
        24, 25, 26, 27, 28, 29,
        28, 29, 30, 31, 32, 1};

int PC1[56] = { //PC1换位表（64—>56）
        57, 49, 41, 33, 25, 17, 9,
        1, 58, 50, 42, 34, 26, 18,
        10, 2, 59, 51, 43, 35, 27,
        19, 11, 3, 60, 52, 44, 36,
        63, 55, 47, 39, 31, 23, 15,
        7, 62, 54, 46, 38, 30, 22,
        14, 6, 61, 53, 45, 37, 29,
        21, 13, 5, 28, 20, 12, 4};

int move[16] = { //循环移位表
        1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

int PC2[48] = { //PC2换位表（56—>48）
        14, 17, 11, 24, 1, 5,
        3, 28, 15, 6, 21, 10,
        23, 19, 12, 4, 26, 8,
        16, 7, 27, 20, 13, 2,
        41, 52, 31, 37, 47, 55,
        30, 40, 51, 45, 33, 48,
        44, 49, 39, 56, 34, 53,
        46, 42, 50, 36, 29, 32};

int S1[4][16] = { //S换位表
        14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
        0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
        4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
        15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
};
int S2[4][16] = {
        15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
        3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
        0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
        13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
};
int S3[4][16] = {
        10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
        13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
        13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
        1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
};
int S4[4][16] = {
        7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
        13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
        10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
        3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
};
int S5[4][16] = {
        2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
        14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
        4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
        11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
};
int S6[4][16] = {
        12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
        10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
        9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
        4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
};
int S7[4][16] = {
        4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
        13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
        1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
        6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
};
int S8[4][16] = {
        13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
        1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
        7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
        2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
};
//P换位表
int P[32] = {
        16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10,
        2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25
};


// 将字符转换为8位二进制数组
void charToBinary(char ch, int *binary) {
    int i;
    for (i = 0; i < 8; i++) {
        binary[i] = (ch >> (7 - i)) & 1;
    }
}

// 进行PC1置换
void pc1Substitution(const int *key, int *keyPC1) {
    int i;
    for (i = 0; i < 56; i++) {
        keyPC1[i] = key[PC1[i] - 1];
    }
}

// 进行PC2置换
void pc2Substitution(const int *keyAB, int t, int K[16][48]) {
    int i;
    for (i = 0; i < 48; i++) {
        K[t][i] = keyAB[PC2[i] - 1];
    }
}

// 左移操作
void leftShift(int *arr, int shift) {
    int i, n, m;
    if (shift == 1) {
        n = arr[0];
        for (i = 0; i < 27; i++) {
            arr[i] = arr[i + 1];
        }
        arr[27] = n;
    } else {
        n = arr[0];
        m = arr[1];
        for (i = 0; i < 26; i++) {
            arr[i] = arr[i + 2];
        }
        arr[26] = n;
        arr[27] = m;
    }
}

// 进行E扩展
void eExpansion(const int *R0, int *RE0) {
    int i;
    for (i = 0; i < 48; i++) {
        RE0[i] = R0[E[i] - 1];
    }
}

// 进行S盒替换
void sBoxSubstitution(const int *RK, int *RKS) {
    int i, r, c;
    for (i = 0; i < 8; i++) {
        r = RK[(i * 6) + 0] * 2 + RK[(i * 6) + 5];
        c = RK[(i * 6) + 1] * 8 + RK[(i * 6) + 2] * 4 + RK[(i * 6) + 3] * 2 + RK[(i * 6) + 4];
        switch (i) {
            case 0:
                RKS[0] = S1[r][c];
                break;
            case 1:
                RKS[1] = S2[r][c];
                break;
            case 2:
                RKS[2] = S3[r][c];
                break;
            case 3:
                RKS[3] = S4[r][c];
                break;
            case 4:
                RKS[4] = S5[r][c];
                break;
            case 5:
                RKS[5] = S6[r][c];
                break;
            case 6:
                RKS[6] = S7[r][c];
                break;
            case 7:
                RKS[7] = S8[r][c];
                break;
        }
    }
}

// 将RKS转换为32位二进制
void rksToBinary(const int *RKS, int *SP) {
    int i, j, m;
    for (i = 0; i < 8; i++) {
        int b[4] = {0, 0, 0, 0};
        m = RKS[i];
        for (j = 3; m != 0; j--) {
            b[j] = m % 2;
            m = m / 2;
        }
        for (j = 0; j < 4; j++) {
            SP[j + (i * 4)] = b[j];
        }
    }
}

// 进行P置换
void pSubstitution(const int *SP, int *RKSP) {
    int i;
    for (i = 0; i < 32; i++) {
        RKSP[i] = SP[P[i] - 1];
    }
}

// 使用DES--CBC模式对明文进行加密，并将结果转换为十六进制字符串
void desCbcEncrypt(const char *MingWen, const int K[16][48], int text_out[14][64], char MiWen[208]) {
    int text[64];
    int text_ip[64];
    int L0[32], Li[32];
    int R0[32], Ri[32];
    int RE0[48];
    int RK[48];
    int RKS[8];
    int SP[32];
    int RKSP[32];
    int text_end[64];
    int result[13][64];
    int H[208];

    int i, j, k, l, n, t;

    // 计算分组数
    n = strlen(MingWen);
    k = n % 8;
    n = (n - 1) / 8 + 1;

    for (l = 0; l < n; l++) {
        char target[8];
        if (l == (n - 1) && k != 0) {
            // 将最后一个不足8个字符的分组的字符复制到 target 数组
            for (i = 0; i < k; i++)
                target[i] = MingWen[i + (8 * l)];
            // 用空格填充不足8个字符的部分
            for (i = k; i < 8; i++)
                target[i] = ' ';
        } else {
            // 完整的8个字符分组复制到 target 数组
            for (i = 0; i < 8; i++)
                target[i] = MingWen[i + (8 * l)];
        }

        // 将得到的明文转化成二进制数储存到数组text中
        for (i = 0; i < 8; i++) {
            charToBinary(target[i], &text[i * 8]);
        }

        // CBC模式下前一分组的密文异或当前分组
        for (i = 0; i < 64; i++)
            text[i] = text_out[l][i] ^ text[i];

        // 对每个text进行DES加密
        // 进行初始换位
        for (i = 0; i < 64; i++)
            text_ip[i] = text[IP[i] - 1];

        // 分成左右两部分，各32位
        for (i = 0; i < 32; i++) {
            L0[i] = text_ip[i];
            R0[i] = text_ip[i + 32];
        }

        // 16轮迭代
        for (t = 0; t < 16; t++) {
            eExpansion(R0, RE0);

            // RE和K异或
            for (i = 0; i < 48; i++) {
                RK[i] = RE0[i] ^ K[t][i];
            }

            sBoxSubstitution(RK, RKS);
            rksToBinary(RKS, SP);
            pSubstitution(SP, RKSP);

            // 前一轮的左半部分和RKSP异或，得到本轮的右半部分
            for (i = 0; i < 32; i++) {
                Ri[i] = L0[i] ^ RKSP[i];
            }

            // 交换左右部分
            for (i = 0; i < 32; i++) {
                L0[i] = R0[i];
                R0[i] = Ri[i];
            }
        }

        // 一个左右32位交换
        for (i = 0; i < 32; i++)
            Li[i] = R0[i];
        for (i = 0; i < 32; i++)
            R0[i] = L0[i];
        for (i = 0; i < 32; i++)
            L0[i] = Li[i];

        // 初始换位的逆过程
        for (i = 0; i < 32; i++)
            text_end[i] = L0[i];
        for (i = 32; i < 64; i++)
            text_end[i] = R0[i - 32];

        for (i = 0; i < 64; i++)
            text_out[l + 1][IP[i] - 1] = text_end[i];

        for (i = 0; i < 64; i++)
            result[l][i] = text_out[l + 1][i];
    }

    // 把result中的二进制密文转成十进制存到数组H中
    for (j = 0; j < n; j++) {
        for (i = 0; i < 16; i++) {
            H[i + (j * 16)] =
                    result[j][0 + (i * 4)] * 8 + result[j][1 + (i * 4)] * 4 + result[j][2 + (i * 4)] * 2 +
                    result[j][3 + (i * 4)];
        }
    }

    // 将十进制转换为十六进制字符
    for (i = 0; i < n * 16; i++) {
        if (H[i] < 10)
            MiWen[i] = H[i] + 48;
        else if (H[i] == 10)
            MiWen[i] = 'A';
        else if (H[i] == 11)
            MiWen[i] = 'B';
        else if (H[i] == 12)
            MiWen[i] = 'C';
        else if (H[i] == 13)
            MiWen[i] = 'D';
        else if (H[i] == 14)
            MiWen[i] = 'E';
        else if (H[i] == 15)
            MiWen[i] = 'F';
    }
    // 填充字符串结束符
    for (i = n * 16; i < 208; i++)
        MiWen[i] = '\0';
}

// 对十六进制密文进行DES解密操作
void desDecryptionProcess(int *H, int n, int K[16][48], int text_out[14][64], int result[13][64], int M[13][8]) {
    int C[832];
    int i, j, k, l, m, t;
    int r[8], c[8];
    int text[64];
    int text_ip[64];
    int L0[32], Li[32];
    int R0[32], Ri[32];
    int RE0[48];
    int RK[48];
    int RKS[8];
    int SP[32];
    int RKSP[32];
    int text_end[64];

    // 将十进制密文转化成二进制存放在数组C中
    for (i = 0; i < n; i++) {
        int he[4] = {0, 0, 0, 0};
        for (j = 3; H[i] != 0; j--) {
            he[j] = H[i] % 2;
            H[i] = H[i] / 2;
        }
        for (j = 0; j < 4; j++)
            C[j + (i * 4)] = he[j];
    }

    k = n / 16;
    for (l = 0; l < k; l++) {
        // 将每个分组对应的64位二进制密文放到text_out中
        for (i = 0; i < 64; i++)
            text_out[l + 1][i] = C[i + (l * 64)];

        // 进行初始换位
        for (i = 0; i < 64; i++)
            text_ip[i] = text_out[l + 1][IP[i] - 1];

        // 分成左右两部分，各32位
        for (i = 0; i < 32; i++) {
            L0[i] = text_ip[i];
            R0[i] = text_ip[i + 32];
        }

        // 十六次迭代
        for (t = 0; t < 16; t++) {
            // 将右半部分通过扩展换位表E从32位扩展成48位
            for (i = 0; i < 48; i++)
                RE0[i] = R0[E[i] - 1];

            // RE与K异或运算
            for (i = 0; i < 48; i++)
                RK[i] = RE0[i] ^ K[15 - t][i];

            // 将R和K异或运算的结果通过S位移表
            for (i = 0; i < 8; i++) {
                r[i] = RK[(i * 6) + 0] * 2 + RK[(i * 6) + 5];
                c[i] = RK[(i * 6) + 1] * 8 + RK[(i * 6) + 2] * 4 + RK[(i * 6) + 3] * 2 + RK[(i * 6) + 4];
            }

            RKS[0] = S1[r[0]][c[0]];
            RKS[1] = S2[r[1]][c[1]];
            RKS[2] = S3[r[2]][c[2]];
            RKS[3] = S4[r[3]][c[3]];
            RKS[4] = S5[r[4]][c[4]];
            RKS[5] = S6[r[5]][c[5]];
            RKS[6] = S7[r[6]][c[6]];
            RKS[7] = S8[r[7]][c[7]];

            // 把结果转成32位二进制储存在数组SP中
            for (i = 0; i < 8; i++) {
                int b[4] = {0, 0, 0, 0};
                m = RKS[i];
                for (j = 3; m != 0; j--) {
                    b[j] = m % 2;
                    m = m / 2;
                }
                for (j = 0; j < 4; j++)
                    SP[j + (i * 4)] = b[j];
            }

            // 将二进制结果再经过一个P盒换位
            for (i = 0; i < 32; i++)
                RKSP[i] = SP[P[i] - 1];

            // 与前一次的左部异或运算，得到本次迭代的右部
            for (i = 0; i < 32; i++)
                Ri[i] = L0[i] ^ RKSP[i];

            // 交换左右部分
            for (i = 0; i < 32; i++) {
                L0[i] = R0[i];
                R0[i] = Ri[i];
            }
        }

        // 一个左右32位交换
        for (i = 0; i < 32; i++)
            Li[i] = R0[i];
        for (i = 0; i < 32; i++)
            R0[i] = L0[i];
        for (i = 0; i < 32; i++)
            L0[i] = Li[i];

        // 初始换位的逆过程
        for (i = 0; i < 32; i++)
            text_end[i] = L0[i];
        for (i = 32; i < 64; i++)
            text_end[i] = R0[i - 32];

        for (i = 0; i < 64; i++)
            text[IP[i] - 1] = text_end[i];

        // CBC模式下的解密
        for (i = 0; i < 64; i++)
            result[l][i] = text_out[l][i] ^ text[i];
    }

    // 将二进制转成十进制
    for (i = 0; i < (n / 16); i++)
        for (j = 0; j < 8; j++)
            M[i][j] = result[i][(j * 8) + 0] * 128 + result[i][(j * 8) + 1] * 64 + result[i][(j * 8) + 2] * 32 +
                      result[i][(j * 8) + 3] * 16 + result[i][(j * 8) + 4] * 8 + result[i][(j * 8) + 5] * 4 +
                      result[i][(j * 8) + 6] * 2 + result[i][(j * 8) + 7];
}