#ifndef DES_CONSTANTS_H
#define DES_CONSTANTS_H

// ��ʼ��λ��
extern const int IP[64];

// ��չ��λ��
extern const int E[48];

// PC1��λ��64��>56��
extern const int PC1[56];

// ѭ����λ��
extern const int move[16];

// PC2��λ��56��>48��
extern const int PC2[48];

// S1 - S8��λ��
extern const int S1[4][16];
extern const int S2[4][16];
extern const int S3[4][16];
extern const int S4[4][16];
extern const int S5[4][16];
extern const int S6[4][16];
extern const int S7[4][16];
extern const int S8[4][16];

//P��λ��
extern const int P[32];

/**
 * ���ַ�ת��Ϊ8λ����������
 *
 * �ú����������ǽ�һ���ַ�ת��Ϊ��Ӧ��8λ�����Ʊ�ʾ����������洢�ڴ�������������С�
 *
 * @param ch Ҫת�����ַ�
 * @param binary ���ڴ洢ת�����8λ�����������ָ�룬���鳤������Ϊ8
 */
void charToBinary(char ch, int *binary);

/**
 * ����PC1�û�
 *
 * �˺���ִ��DES�㷨�е�PC1��Permuted Choice 1���û���������64λ��Կ����PC1�û��õ�56λ��Կ��
 *
 * @param key �����64λ��Կ���飬������������ں���ִ�й����в��ᱻ�޸�
 * @param keyPC1 ���ڴ洢����PC1�û����56λ��Կ�����ָ�룬���鳤������Ϊ56
 */
void pc1Substitution(const int *key, int *keyPC1);

/**
 * ����PC2�û�
 *
 * �ú���ִ��DES�㷨�е�PC2��Permuted Choice 2���û�������������ѭ�����ƺϲ����56λ��Կ����PC2�û��õ�48λ����Կ��������洢��ָ������������Կ�����С�
 *
 * @param keyAB ����ľ���ѭ�����ƺϲ����56λ��Կ���飬������������ں���ִ�й����в��ᱻ�޸�
 * @param t ��ǰ��������ȡֵ��ΧΪ0��15
 * @param K ��ά���飬���ڴ洢16��ѭ�����ɵ�48λ����Կ�������СΪ[16][48]
 */
void pc2Substitution(const int *keyAB, int t, int K[16][48]);

/**
 * ���Ʋ���
 *
 * �ú����������28λ����������������Ʋ��������Ƶ�λ�����ݴ���Ĳ���������
 *
 * @param arr Ҫ�������Ʋ�����28λ����������
 * @param shift ���Ƶ�λ����ȡֵΪ1��2
 */
void leftShift(int *arr, int shift);

/**
 * ����E��չ
 *
 * �˺���ִ��DES�㷨�е�E��Expansion����չ��������32λ���Ұ벿��������չΪ48λ��
 *
 * @param R0 �����32λ�Ұ벿���������飬������������ں���ִ�й����в��ᱻ�޸�
 * @param RE0 ���ڴ洢����E��չ���48λ���������ָ�룬���鳤������Ϊ48
 */
void eExpansion(const int *R0, int *RE0);

/**
 * ����S���滻
 *
 * �ú���ִ��DES�㷨�е�S�У�Substitution Box���滻��������48λ���������ݾ���8��S���滻�õ�8��ʮ�������ݡ�
 *
 * @param RK �����48λ�������飬������������ں���ִ�й����в��ᱻ�޸�
 * @param RKS ���ڴ洢����S���滻���8��ʮ�������������ָ�룬���鳤������Ϊ8
 */
void sBoxSubstitution(const int *RK, int *RKS);

/**
 * ��RKSת��Ϊ32λ������
 *
 * �˺���������S���滻�õ���8��ʮ��������ת��Ϊ32λ�����Ʊ�ʾ����������洢�ڴ�������������С�
 *
 * @param RKS ����İ���8��ʮ�������ݵ����飬������������ں���ִ�й����в��ᱻ�޸�
 * @param SP ���ڴ洢ת�����32λ�����������ָ�룬���鳤������Ϊ32
 */
void rksToBinary(const int *RKS, int *SP);

/**
 * ����P�û�
 *
 * �ú���ִ��DES�㷨�е�P��Permutation���û���������32λ�����ݾ���P�û��õ��µ�32λ���ݡ�
 *
 * @param SP �����32λ�������飬������������ں���ִ�й����в��ᱻ�޸�
 * @param RKSP ���ڴ洢����P�û����32λ���������ָ�룬���鳤������Ϊ32
 */
void pSubstitution(const int *SP, int *RKSP);

/**
 * @brief ʹ��DES�㷨���CBCģʽ�����Ľ��м��ܣ��������ת��Ϊʮ�������ַ���
 * @param MingWen Ҫ���ܵ����ģ����ַ�����ʽ����
 * @param K 16������Կ����һ����ά���飬��СΪ [16][48]���ڵ��ô˺���ǰӦ����ȷ����
 * @param text_out ���ڴ洢�м���ܽ���Ķ�ά���飬��СΪ [14][64]��
 *                 ���е�һ��ͨ���洢��ʼ�������������д洢ÿ��������ܺ�Ľ��
 * @param MiWen ���ڴ洢���ռ��ܺ��ʮ�������ַ����������С����Ϊ 208��
 *              ����ִ����Ϻ󣬸����齫�������ܺ��ʮ�����Ʊ�ʾ
 */
void desCbcEncrypt(const char *MingWen, const int K[16][48], int text_out[14][64], char MiWen[208]);

/**
 * @brief ��ʮ���������Ľ���DES���ܲ���
 * @param H �洢ʮ����������ת�����ʮ��������
 * @param n ʮ����������ת�����ʮ��������ĳ���
 * @param K 16������Կ����ά���飬��СΪ [16][48]
 * @param text_out �洢�м����Ķ�ά���飬��СΪ [14][64]
 * @param result �洢���ս��ܽ���Ķ�ά���飬��СΪ [13][64]
 * @param M �洢���ܺ������ת��Ϊʮ���ƵĽ���Ķ�ά���飬��СΪ [13][8]
 */
void desDecryptionProcess(int *H, int n, int K[16][48], int text_out[14][64], int result[13][64], int M[13][8]);

#endif // DES_CONSTANTS_H