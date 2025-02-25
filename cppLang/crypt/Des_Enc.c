#include<stdio.h>
#include "des_constants.h"

int main() { //��������
    char MingWen[104]; //���ԭʼ������
    char InputKey[9]; //����ַ��͵İ�λ��Կ
    int key[64]; //�����Կ�Ķ�������ʽ
    int keyPC1[56]; //�����Կkey����PC1��λ����ɵ�56λ������
    int A[28]; //��keyPC1�ֳ����������֣���A���Ҳ�B����28λ���Ա����ѭ������
    int B[28];
    int keyAB[56]; //��ѭ�����ƺ������ֵĽ���ϲ�����
    int K[16][48]; //���16��ѭ�����Ʋ���������Կ
    int text_out[14][64]; //��ų�ʼ�����������о���DES�ķ���Ķ�����
    char init[9] = {"encrypt"}; //���ó�ʼ������Ϊ��encrypt��
    int result[13][64];
    int H[208];
    char MiWen[208];
    int M[13][8];

    char choice;
    int t, i, j;
    int flag = 1;


    printf("HYs-des����/����\n\n");
    while (flag) {
        printf("A���ܣ�B���ܣ���ѡ��\n");
        scanf("%c", &choice);

        while (choice != 'A' && choice != 'B' && choice != 'a' && choice != 'b') {
            printf("�Բ����������벻�Ϸ�����ѡ��A��B��A��ʾ���ܣ�B��ʾ���ܡ�\n");
            scanf("%c", &choice);
        }
        getchar();

        //��������Կ
        printf("������8λ��Կ��\n");
        gets(InputKey);
        while (InputKey[7] == '\0' || InputKey[8] != '\0') {
            printf("���������Կλ����������������8λ��Կ��\n");
            gets(InputKey);
        }
        //����Կת����64λ���������ŵ�һά����key��
        for (i = 0; i < 8; i++) {
            charToBinary(InputKey[i], &key[i * 8]);
        }

        // ͨ��PC1��λ��õ�56λ��Կ���洢��keyPC1��
        pc1Substitution(key, keyPC1);
        //�ֳ�A��B�����֣���28λ
        for (i = 0; i < 28; i++) {
            A[i] = keyPC1[i];
            B[i] = keyPC1[i + 28];
        }

        // ����16������Կ
        for (t = 0; t < 16; t++) {
            leftShift(A, move[t]);
            leftShift(B, move[t]);
            // �ϲ�A��BΪ56λ
            for (i = 0; i < 28; i++) {
                keyAB[i] = A[i];
                keyAB[i + 28] = B[i];
            }
            // ͨ��PC2�û��õ�48λ����Կ
            pc2Substitution(keyAB, t, K);
        }
        //����ʼ������ת���ɶ����������浽����text_out�ĵ�һ����
        for (i = 0; i < 8; i++) {
            charToBinary(init[i], &text_out[0][i * 8]);
        }


        //���ܳ���
        if (choice == 'A' || choice == 'a') {
            printf("������������ܵ����ݣ�\n"); //��������
            gets(MingWen);
            while (MingWen[0] == '\0') {
                printf("�Բ������Ĳ���Ϊ�գ�����������ȷ�����ġ�\n");
                gets(MingWen);
            }

            // ���ü��ܺ���
            desCbcEncrypt(MingWen, K, text_out, MiWen);

            printf("�������ľ���DES���ܺ�������ǣ�\n");
            printf("%s\n", MiWen);
            printf("\n\n");
        } else if (choice == 'B' || choice == 'b') {
            //���ܳ���
            printf("�������������ݣ�\n");
            gets(MiWen);

            for (i = 0; i < 208; i++)
                H[i] = 0;

            for (i = 0; MiWen[i] != '\0'; i++) //��ʮ����������ת����ʮ���ƴ��������H��
            {
                if (MiWen[i] >= '0' && MiWen[i] <= '9')
                    H[i] = MiWen[i] - '0';
                else if (MiWen[i] >= 'A' && MiWen[i] <= 'F')
                    H[i] = MiWen[i] - 'A' + 10;
                else if (MiWen[i] >= 'a' && MiWen[i] <= 'f')
                    H[i] = MiWen[i] - 'a' + 10;
                else {
                    printf("ע��:��������ʮ�����Ʊ�ʾ���������ݣ�\n");
                    gets(MiWen);
                    i = 0;
                }
            }
            int n = i; //�����й���n���ַ�
            if (n % 16 != 0) {
                printf("�Բ�������������Ĳ���ȷ����ȷ�����ĵ����ݣ����ĵ��ַ���Ӧ��16�ı�����\n");
                printf("�������������ݣ�\n");
                gets(MiWen);

                for (i = 0; i < 208; i++)
                    H[i] = 0;
                //��ʮ����������ת����ʮ���ƴ��������H��
                for (i = 0; MiWen[i] != '\0'; i++) {
                    if (MiWen[i] >= '0' && MiWen[i] <= '9')
                        H[i] = MiWen[i] - '0';
                    else if (MiWen[i] >= 'A' && MiWen[i] <= 'F')
                        H[i] = MiWen[i] - 'A' + 10;
                    else if (MiWen[i] >= 'a' && MiWen[i] <= 'f')
                        H[i] = MiWen[i] - 'a' + 10;
                }
            }
            // ���ý��ܺ���
            desDecryptionProcess(H, n, K, text_out, result, M);
            printf("�������ľ���DES���ܺ�������ǣ�\n");
            for (i = 0; i < (n / 16); i++)
                for (j = 0; j < 8; j++)
                    printf("%c", M[i][j]);
            printf("\n\n\n");
        }
        flag = 0;
        printf("�Ƿ������\n");
        printf("Y������N�˳�����ѡ��\n");
        scanf("%c", &choice);

        while (choice != 'Y' && choice != 'N' && choice != 'y' && choice != 'n') {
            printf("�Բ����������벻�Ϸ�����ѡ��Y��N��Y��ʾ����ʹ�ñ�����N��ʾ�˳���\n");
            scanf("%c", &choice);
        }
        getchar();
        if (choice == 'Y' || choice == 'y')
            flag = 1;
    }
    return 0;
}
