#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// 判断一个数是否为素数
int isPrime(int p) {
    if (p <= 1) return 0;
    for (int i = 2; i * i <= p; i++) {
        if (p % i == 0) return 0;
    }
    return 1;
}

// 求出n和m之间的最大素数
int findMaxPrime(int n, int m) {
    for (int p = m; p >= n; p--) {
        if (isPrime(p)) return p;
    }
    return 0;
}

// 从用户输入读取整数
int getIntegerInput(const char *prompt) {
    char input[100];
    char *endptr;
    long num;

    while (1) {
        printf("%s", prompt);
        if (fgets(input, sizeof(input), stdin) == NULL) {
            continue;
        }
        errno = 0;
        num = strtol(input, &endptr, 10);
        if (errno != 0 || (*endptr != '\n' && *endptr != '\0')) {
            printf("输入无效，请输入一个整数: ");
        } else {
            break;
        }
    }
    return (int) num;
}

// 产生素数p
int generatePrimeP() {
    int n = getIntegerInput(
            "为一组用户产生一个公钥P(p为素数)\n请输入p所在范围n，m(系统将选择最大的素数P)，先输入n:\n(建议输入1)\n");
    int m = getIntegerInput("再输入m=\n(建议输入23)\n");
    int p = findMaxPrime(n, m);
    if (p == 0) {
        printf("n,m中无素数\n");
        return generatePrimeP();
    }
    return p;
}

// 产生随机数g
int generateRandomG(int p) {
    srand((unsigned int) time(NULL));
    return rand() % p;
}

// 计算公钥y
int calculatePublicKeyY(int p, int g, int x) {
    int y = 1;
    for (int i = 0; i < x; i++) {
        y = (y * g) % p;
    }
    return y;
}

// 求两个数的最大公约数
int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// 输入要签名的字符m
int inputMessage(int p) {
    int m;
    while (1) {
        m = getIntegerInput("输入要签名的字符m:\n(建议输入23)\n");
        if (m <= p) break;
        printf("无法对输入的m进行签名,请重新输入\n");
    }
    return m;
}

// 产生与p-1互质的随机数k
int generateRandomK(int p) {
    int k;
    do {
        k = rand() % p;
    } while (gcd(k, p - 1) != 1);
    return k;
}

// 产生签名
void generateSignature(int g, int p, int x, int m, int *a, int *b) {
    int k = generateRandomK(p);
    *a = 1;
    for (int i = 0; i < k; i++) {
        *a = (*a * g) % p;
    }
    for (int i = 0; i < p - 1; i++) {
        *b = i;
        if ((x * (*a) + k * (*b)) % (p - 1) == m) break;
    }
    printf("%d的数字签名是（%d,%d）\n", m, *a, *b);
}

// 验证签名
void verifySignature(int y, int p, int m, int g, int a, int b, char name) {
    int c1 = 1, d1 = 1, j = 1;
    for (int i = 0; i < a; i++) {
        c1 = (c1 * y) % p;
    }
    for (int i = 0; i < b; i++) {
        d1 = (d1 * a) % p;
    }
    d1 = (d1 * c1) % p;
    for (int i = 0; i < m; i++) {
        j = (j * g) % p;
    }
    if (d1 == j) {
        printf("是用户%c签名的。\n", name);
    } else {
        printf("不是用户%c签名的\n", name);
    }
}

int main() {
    int p, g, x, y, m, a, b;
    char name;

    p = generatePrimeP(); // 产生大素数p
    g = generateRandomG(p); // 产生随机数g
    printf("此用户组的公共参数为p=%d g=%d\n", p, g);

    printf("输入用户名\n(输入单位数字,建议输入2)\n");
    while (scanf(" %c", &name) != 1) {
        while (getchar() != '\n');
        printf("输入无效，请输入一个字符: ");
    }
    // 清除输入缓冲区中的换行符
    while (getchar() != '\n');

    x = getIntegerInput("输入用户密码(私钥）\n");
    if (x >= p) {
        printf("密码应该小于P;\n");
    }

    y = calculatePublicKeyY(p, g, x); // 公钥y的产生
    printf("用户%c公钥y是%d\n", name, y);

    m = inputMessage(p);
    generateSignature(g, p, x, m, &a, &b);
    verifySignature(y, p, m, g, a, b, name);

    return 0;
}