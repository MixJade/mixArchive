#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// �ж�һ�����Ƿ�Ϊ����
int isPrime(int p) {
    if (p <= 1) return 0;
    for (int i = 2; i * i <= p; i++) {
        if (p % i == 0) return 0;
    }
    return 1;
}

// ���n��m֮����������
int findMaxPrime(int n, int m) {
    for (int p = m; p >= n; p--) {
        if (isPrime(p)) return p;
    }
    return 0;
}

// ���û������ȡ����
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
            printf("������Ч��������һ������: ");
        } else {
            break;
        }
    }
    return (int) num;
}

// ��������p
int generatePrimeP() {
    int n = getIntegerInput(
            "Ϊһ���û�����һ����ԿP(pΪ����)\n������p���ڷ�Χn��m(ϵͳ��ѡ����������P)��������n:\n(��������1)\n");
    int m = getIntegerInput("������m=\n(��������23)\n");
    int p = findMaxPrime(n, m);
    if (p == 0) {
        printf("n,m��������\n");
        return generatePrimeP();
    }
    return p;
}

// ���������g
int generateRandomG(int p) {
    srand((unsigned int) time(NULL));
    return rand() % p;
}

// ���㹫Կy
int calculatePublicKeyY(int p, int g, int x) {
    int y = 1;
    for (int i = 0; i < x; i++) {
        y = (y * g) % p;
    }
    return y;
}

// �������������Լ��
int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// ����Ҫǩ�����ַ�m
int inputMessage(int p) {
    int m;
    while (1) {
        m = getIntegerInput("����Ҫǩ�����ַ�m:\n(��������23)\n");
        if (m <= p) break;
        printf("�޷��������m����ǩ��,����������\n");
    }
    return m;
}

// ������p-1���ʵ������k
int generateRandomK(int p) {
    int k;
    do {
        k = rand() % p;
    } while (gcd(k, p - 1) != 1);
    return k;
}

// ����ǩ��
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
    printf("%d������ǩ���ǣ�%d,%d��\n", m, *a, *b);
}

// ��֤ǩ��
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
        printf("���û�%cǩ���ġ�\n", name);
    } else {
        printf("�����û�%cǩ����\n", name);
    }
}

int main() {
    int p, g, x, y, m, a, b;
    char name;

    p = generatePrimeP(); // ����������p
    g = generateRandomG(p); // ���������g
    printf("���û���Ĺ�������Ϊp=%d g=%d\n", p, g);

    printf("�����û���\n(���뵥λ����,��������2)\n");
    while (scanf(" %c", &name) != 1) {
        while (getchar() != '\n');
        printf("������Ч��������һ���ַ�: ");
    }
    // ������뻺�����еĻ��з�
    while (getchar() != '\n');

    x = getIntegerInput("�����û�����(˽Կ��\n");
    if (x >= p) {
        printf("����Ӧ��С��P;\n");
    }

    y = calculatePublicKeyY(p, g, x); // ��Կy�Ĳ���
    printf("�û�%c��Կy��%d\n", name, y);

    m = inputMessage(p);
    generateSignature(g, p, x, m, &a, &b);
    verifySignature(y, p, m, g, a, b, name);

    return 0;
}