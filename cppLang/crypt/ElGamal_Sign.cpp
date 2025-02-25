#include <iostream>
#include <cstdlib>
#include <ctime>
//把所有的std::cout变成cout
using namespace std;

// 判断一个数是否为素数
bool isPrime(int p) {
    if (p <= 1) return false;
    for (int i = 2; i * i <= p; i++) {
        if (p % i == 0) return false;
    }
    return true;
}

// 求出n和m之间的最大素数
int findMaxPrime(int n, int m) {
    for (int p = m; p >= n; p--) {
        if (isPrime(p)) return p;
    }
    return 0;
}

// 产生素数p
int generatePrimeP() {
    int n, m;
    cout << "为一组用户产生一个公钥P(p为素数)" << "\n"
         << "请输入p所在范围n，m(系统将选择最大的素数P)，先输入n:" << "\n"
         << "(建议输入1)" << endl;
    while (!(cin >> n)) {
        cin.clear();
        cin.ignore('\n');
        cout << "输入无效，请输入一个整数: ";
    }
    cout << "再输入m=" << "\n" << "(建议输入23)" << endl;
    while (!(cin >> m)) {
        cin.clear();
        cin.ignore('\n');
        cout << "输入无效，请输入一个整数: ";
    }
    int p = findMaxPrime(n, m);
    if (p == 0) {
        cout << "n,m中无素数" << endl;
        return generatePrimeP();
    }
    return p;
}

// 产生随机数g
int generateRandomG(int p) {
    srand(static_cast<unsigned int>(time(nullptr)));
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
    while (true) {
        cout << "输入要签名的字符m:" << endl;
        cout << "(建议输入23)" << endl;
        while (!(cin >> m)) {
            cin.clear();
            cin.ignore('\n');
            cout << "输入无效，请输入一个整数: ";
        }
        if (m <= p) break;
        cout << "无法对输入的m进行签名,请重新输入" << endl;
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
    cout << m << "的数字签名是（" << a << "," << b << "）" << endl;
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
        cout << "是用户" << name << "签名的。" << endl;
    } else {
        cout << "不是用户" << name << "签名的" << endl;
    }
}

int main() {
    int p, g, x, y, m, a, b;
    char name;

    p = generatePrimeP(); // 产生大素数p
    g = generateRandomG(p); // 产生随机数g
    cout << "此用户组的公共参数为p=" << p << " g=" << g << endl;

    cout << "输入用户名" << "\n"
         << "(输入单位数字,建议输入2)" << endl;
    while (!(cin >> name)) {
        cin.clear();
        cin.ignore('\n');
        cout << "输入无效，请输入一个字符: ";
    }

    cout << "输入用户密码(私钥）" << endl;
    while (!(cin >> x)) {
        cin.clear();
        cin.ignore('\n');
        cout << "输入无效，请输入一个整数: ";
    }
    if (x >= p) {
        cout << "密码应该小于P;" << endl;
    }

    y = calculatePublicKeyY(p, g, x); // 公钥y的产生
    cout << "用户" << name << "公钥y是" << y << endl;

    m = inputMessage(p);
    generateSignature(g, p, x, m, a, b);
    verifySignature(y, p, m, g, a, b, name);

    return 0;
}