#include <iostream>
#include <cstdlib>
#include <ctime>
//�����е�std::cout���cout
using namespace std;

// �ж�һ�����Ƿ�Ϊ����
bool isPrime(int p) {
    if (p <= 1) return false;
    for (int i = 2; i * i <= p; i++) {
        if (p % i == 0) return false;
    }
    return true;
}

// ���n��m֮����������
int findMaxPrime(int n, int m) {
    for (int p = m; p >= n; p--) {
        if (isPrime(p)) return p;
    }
    return 0;
}

// ��������p
int generatePrimeP() {
    int n, m;
    cout << "Ϊһ���û�����һ����ԿP(pΪ����)" << "\n"
         << "������p���ڷ�Χn��m(ϵͳ��ѡ����������P)��������n:" << "\n"
         << "(��������1)" << endl;
    while (!(cin >> n)) {
        cin.clear();
        cin.ignore('\n');
        cout << "������Ч��������һ������: ";
    }
    cout << "������m=" << "\n" << "(��������23)" << endl;
    while (!(cin >> m)) {
        cin.clear();
        cin.ignore('\n');
        cout << "������Ч��������һ������: ";
    }
    int p = findMaxPrime(n, m);
    if (p == 0) {
        cout << "n,m��������" << endl;
        return generatePrimeP();
    }
    return p;
}

// ���������g
int generateRandomG(int p) {
    srand(static_cast<unsigned int>(time(nullptr)));
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
    while (true) {
        cout << "����Ҫǩ�����ַ�m:" << endl;
        cout << "(��������23)" << endl;
        while (!(cin >> m)) {
            cin.clear();
            cin.ignore('\n');
            cout << "������Ч��������һ������: ";
        }
        if (m <= p) break;
        cout << "�޷��������m����ǩ��,����������" << endl;
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
void generateSignature(int g, int p, int x, int m, int &a, int &b) {
    int k = generateRandomK(p);
    a = 1;
    for (int i = 0; i < k; i++) {
        a = (a * g) % p;
    }
    for (int i = 0; i < p - 1; i++) {
        b = i;
        if ((x * a + k * b) % (p - 1) == m) break;
    }
    cout << m << "������ǩ���ǣ�" << a << "," << b << "��" << endl;
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
        cout << "���û�" << name << "ǩ���ġ�" << endl;
    } else {
        cout << "�����û�" << name << "ǩ����" << endl;
    }
}

int main() {
    int p, g, x, y, m, a, b;
    char name;

    p = generatePrimeP(); // ����������p
    g = generateRandomG(p); // ���������g
    cout << "���û���Ĺ�������Ϊp=" << p << " g=" << g << endl;

    cout << "�����û���" << "\n"
         << "(���뵥λ����,��������2)" << endl;
    while (!(cin >> name)) {
        cin.clear();
        cin.ignore('\n');
        cout << "������Ч��������һ���ַ�: ";
    }

    cout << "�����û�����(˽Կ��" << endl;
    while (!(cin >> x)) {
        cin.clear();
        cin.ignore('\n');
        cout << "������Ч��������һ������: ";
    }
    if (x >= p) {
        cout << "����Ӧ��С��P;" << endl;
    }

    y = calculatePublicKeyY(p, g, x); // ��Կy�Ĳ���
    cout << "�û�" << name << "��Կy��" << y << endl;

    m = inputMessage(p);
    generateSignature(g, p, x, m, a, b);
    verifySignature(y, p, m, g, a, b, name);

    return 0;
}