#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define A 0x67452301
#define B 0xefcdab89
#define C 0x98badcfe
#define D 0x10325476

const char str16[] = "0123456789abcdef";

const unsigned int T[] = {
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
        0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
        0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
        0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
        0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
        0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
        0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
        0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
        0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
};

const unsigned int s[] = {
        7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
        5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
        4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
        6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
};

// MD5 �ṹ��
typedef struct {
    unsigned int tempA, tempB, tempC, tempD;
    unsigned int strlength;
} MD5Context;

// F����
unsigned int F(unsigned int b, unsigned int c, unsigned int d) {
    return (b & c) | ((~b) & d);
}

// G����
unsigned int G(unsigned int b, unsigned int c, unsigned int d) {
    return (b & d) | (c & (~d));
}

// H����
unsigned int H(unsigned int b, unsigned int c, unsigned int d) {
    return b ^ c ^ d;
}

// I����
unsigned int I(unsigned int b, unsigned int c, unsigned int d) {
    return c ^ (b | (~d));
}

// ��λ��������
unsigned int shift(unsigned int a, unsigned int n) {
    return (a << n) | (a >> (32 - n));
}

// ѭ��ѹ��
void iterateFunc(MD5Context *ctx, unsigned int *X) {
    unsigned int a = ctx->tempA,
            b = ctx->tempB,
            c = ctx->tempC,
            d = ctx->tempD,
            rec, g, k;
    for (int i = 0; i < 64; i++) {
        if (i < 16) {
            // F����
            g = F(b, c, d);
            k = i;
        } else if (i < 32) {
            // G����
            g = G(b, c, d);
            k = (1 + 5 * i) % 16;
        } else if (i < 48) {
            // H����
            g = H(b, c, d);
            k = (5 + 3 * i) % 16;
        } else {
            // I����
            g = I(b, c, d);
            k = (7 * i) % 16;
        }
        rec = d;
        d = c;
        c = b;
        b = b + shift(a + g + X[k] + T[i], s[i]);
        a = rec;
    }
    ctx->tempA += a;
    ctx->tempB += b;
    ctx->tempC += c;
    ctx->tempD += d;
}

// ����ַ���
unsigned int *padding(const char *src, unsigned int *length) {
    // ��512λ,64���ֽ�Ϊһ��
    unsigned int num = ((strlen(src) + 8) / 64) + 1;
    unsigned int *rec = (unsigned int *) malloc(num * 16 * sizeof(unsigned int));
    if (rec == NULL) {
        return NULL;
    }
    *length = num * 16;
    memset(rec, 0, num * 16 * sizeof(unsigned int));
    for (unsigned int i = 0; i < strlen(src); i++) {
        // һ��unsigned int��Ӧ4���ֽڣ�����4���ַ���Ϣ
        rec[i >> 2] |= (unsigned int) (src[i]) << ((i % 4) * 8);
    }
    // ����1000...000
    rec[strlen(src) >> 2] |= (0x80 << ((strlen(src) % 4) * 8));
    // ���ԭ�ĳ���
    rec[num * 16 - 2] = (strlen(src) << 3);
    return rec;
}

// �������
void format(unsigned int num, char *res) {
    unsigned int base = 1 << 8;
    for (int i = 0; i < 4; i++) {
        unsigned int b = (num >> (i * 8)) % base & 0xff;
        for (int j = 0; j < 2; j++) {
            res[(3 - i) * 2 + j] = str16[b % 16];
            b /= 16;
        }
    }
    res[8] = '\0';
}

// ���뺯��
void md5_encode(const char *src, char *result) {
    MD5Context ctx;
    ctx.tempA = A;
    ctx.tempB = B;
    ctx.tempC = C;
    ctx.tempD = D;
    ctx.strlength = 0;

    unsigned int padded_length;
    unsigned int *padded = padding(src, &padded_length);
    if (padded == NULL) {
        return;
    }

    for (unsigned int i = 0; i < padded_length / 16; i++) {
        unsigned int num[16];
        for (int j = 0; j < 16; j++) {
            num[j] = padded[i * 16 + j];
        }
        iterateFunc(&ctx, num);
    }

    free(padded);

    char temp[9];
    format(ctx.tempA, temp);
    strcpy(result, temp);
    format(ctx.tempB, temp);
    strcat(result, temp);
    format(ctx.tempC, temp);
    strcat(result, temp);
    format(ctx.tempD, temp);
    strcat(result, temp);
}

int main() {
    char src[1024];
    char result[33];

    printf("Plain Text: ");
    fgets(src, sizeof(src), stdin);
    // ȥ�� fgets ���ܶ�ȡ�Ļ��з�
    src[strcspn(src, "\n")] = 0;

    md5_encode(src, result);
    printf("result: %s\n", result);

    return 0;
}