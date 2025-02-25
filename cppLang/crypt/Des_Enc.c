#include<stdio.h>
#include "des_constants.h"

int main() { //声明变量
    char MingWen[104]; //存放原始的明文
    char InputKey[9]; //存放字符型的八位密钥
    int key[64]; //存放密钥的二进制形式
    int keyPC1[56]; //存放密钥key经过PC1换位表后变成的56位二进制
    int A[28]; //将keyPC1分成左右两部分，左部A，右部B，各28位，以便进行循环左移
    int B[28];
    int keyAB[56]; //将循环左移后两部分的结果合并起来
    int K[16][48]; //存放16次循环左移产生的子密钥
    int text_out[14][64]; //存放初始化向量和所有经过DES的分组的二进制
    char init[9] = {"encrypt"}; //设置初始化向量为“encrypt”
    int result[13][64];
    int H[208];
    char MiWen[208];
    int M[13][8];

    char choice;
    int t, i, j;
    int flag = 1;


    printf("HYs-des加密/解密\n\n");
    while (flag) {
        printf("A加密，B解密，请选择：\n");
        scanf("%c", &choice);

        while (choice != 'A' && choice != 'B' && choice != 'a' && choice != 'b') {
            printf("对不起，您的输入不合法。请选择A或B，A表示加密，B表示解密。\n");
            scanf("%c", &choice);
        }
        getchar();

        //生成子密钥
        printf("请输入8位密钥：\n");
        gets(InputKey);
        while (InputKey[7] == '\0' || InputKey[8] != '\0') {
            printf("您输入的密钥位数有误，请重新输入8位密钥：\n");
            gets(InputKey);
        }
        //将密钥转化成64位二进制数放到一维数组key中
        for (i = 0; i < 8; i++) {
            charToBinary(InputKey[i], &key[i * 8]);
        }

        // 通过PC1换位表得到56位密钥，存储到keyPC1中
        pc1Substitution(key, keyPC1);
        //分成A和B两部分，各28位
        for (i = 0; i < 28; i++) {
            A[i] = keyPC1[i];
            B[i] = keyPC1[i + 28];
        }

        // 生成16轮子密钥
        for (t = 0; t < 16; t++) {
            leftShift(A, move[t]);
            leftShift(B, move[t]);
            // 合并A和B为56位
            for (i = 0; i < 28; i++) {
                keyAB[i] = A[i];
                keyAB[i + 28] = B[i];
            }
            // 通过PC2置换得到48位子密钥
            pc2Substitution(keyAB, t, K);
        }
        //将初始化向量转化成二进制数储存到数组text_out的第一行中
        for (i = 0; i < 8; i++) {
            charToBinary(init[i], &text_out[0][i * 8]);
        }


        //加密程序
        if (choice == 'A' || choice == 'a') {
            printf("请输入您想加密的内容：\n"); //输入明文
            gets(MingWen);
            while (MingWen[0] == '\0') {
                printf("对不起，明文不可为空，请您输入正确的明文。\n");
                gets(MingWen);
            }

            // 调用加密函数
            desCbcEncrypt(MingWen, K, text_out, MiWen);

            printf("您的明文经过DES加密后的密文是：\n");
            printf("%s\n", MiWen);
            printf("\n\n");
        } else if (choice == 'B' || choice == 'b') {
            //解密程序
            printf("请输入密文内容：\n");
            gets(MiWen);

            for (i = 0; i < 208; i++)
                H[i] = 0;

            for (i = 0; MiWen[i] != '\0'; i++) //将十六进制密文转化成十进制存放在数组H中
            {
                if (MiWen[i] >= '0' && MiWen[i] <= '9')
                    H[i] = MiWen[i] - '0';
                else if (MiWen[i] >= 'A' && MiWen[i] <= 'F')
                    H[i] = MiWen[i] - 'A' + 10;
                else if (MiWen[i] >= 'a' && MiWen[i] <= 'f')
                    H[i] = MiWen[i] - 'a' + 10;
                else {
                    printf("注意:请输入用十六进制表示的密文内容：\n");
                    gets(MiWen);
                    i = 0;
                }
            }
            int n = i; //密文中共有n个字符
            if (n % 16 != 0) {
                printf("对不起，您输入的密文不正确，请确认密文的内容，密文的字符数应是16的倍数。\n");
                printf("请输入密文内容：\n");
                gets(MiWen);

                for (i = 0; i < 208; i++)
                    H[i] = 0;
                //将十六进制密文转化成十进制存放在数组H中
                for (i = 0; MiWen[i] != '\0'; i++) {
                    if (MiWen[i] >= '0' && MiWen[i] <= '9')
                        H[i] = MiWen[i] - '0';
                    else if (MiWen[i] >= 'A' && MiWen[i] <= 'F')
                        H[i] = MiWen[i] - 'A' + 10;
                    else if (MiWen[i] >= 'a' && MiWen[i] <= 'f')
                        H[i] = MiWen[i] - 'a' + 10;
                }
            }
            // 调用解密函数
            desDecryptionProcess(H, n, K, text_out, result, M);
            printf("您的密文经过DES解密后的明文是：\n");
            for (i = 0; i < (n / 16); i++)
                for (j = 0; j < 8; j++)
                    printf("%c", M[i][j]);
            printf("\n\n\n");
        }
        flag = 0;
        printf("是否继续？\n");
        printf("Y继续，N退出，请选择：\n");
        scanf("%c", &choice);

        while (choice != 'Y' && choice != 'N' && choice != 'y' && choice != 'n') {
            printf("对不起，您的输入不合法。请选择Y或N，Y表示继续使用本程序，N表示退出。\n");
            scanf("%c", &choice);
        }
        getchar();
        if (choice == 'Y' || choice == 'y')
            flag = 1;
    }
    return 0;
}
