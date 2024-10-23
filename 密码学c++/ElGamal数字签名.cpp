#include<iostream>
#include <stdlib.h>
#include<time.h>
using namespace std;
int a, b;
int prime_number_p();
int random(int);
int m_develop(int);
/*---------------------------------*/
int prime(int p)
{
	int i, j;
	for (i = 2;i < p;i++)
	{
		j = p % i;
		if (j == 0)return 0;
	}
	return 1;
}//判断是否为素数,若为素数则返回1
/*------------------------------------*/
int prime_number_max(int n, int m)
{
	int p;
	for (p = m;p >= n;p--)
	{
		if (prime(p) == 1)
			return p;
	}
}//求出n,m之间的最大素数
/*--------------------------------*/
int prime_number_p()
{
	int p, m, n;
	cout << "为一组用户产生一个公钥P(p为素数)" << endl;
	cout << "请输入p所在范围n，m(系统将选择最大的素数P)，先输入n:"<< "\n" << "(建议输入1)" << endl;
	cin >> n;
	cout << "再输入m="<< "\n" << "(建议输入23)"<< endl;
	cin >> m;
	p = prime_number_max(n, m);
	if (p == 0)
	{
		cout << "n,m中无素数";
		p = prime_number_p();
	}
	return p;
}//p的产生
/*-------------------------------*/
int Random_number_g(int p)
{
	int g;
	srand((int)time(NULL));
	g = rand() % p;
	return g;
}//g的产生
int PKI_y(int p, int g, int x)
{
	int y;
	int i;
	y = 1;
	for (i = 0;i < x;i++)
	{
		y *= g;
		y %= p;
	}
	return y;
}//公钥y的产生
int gcd(int a, int b)
{
	int s[50], q[50];
	if (a > b)
	{
		s[0] = a;
		s[1] = b;
	}
	else
	{
		s[0] = a;
		s[1] = b;
	}
	int i = 1;
	for (i = 1;i < 100;i++)
	{
		s[i + 1] = s[i - 1] % s[i];
		q[i] = s[i - 1] / s[i];
		if (s[i + 1] == 0) break;
	}
	return s[i];
}//求a，b是否互素
/*----------------------------------*/
int m_develop(int p)
{
	int m;
	cin >> m;
	if (m > p)
	{
		cout << "无法对输入的m进行签名,请重新输入" << endl;
		m = m_develop(p);
	}
	return m;
}
int prime_k(int p)
{
	int k, i;
	k = rand() % p;
	i = gcd(k, p - 1);
	if (i != 1)
	{
		k = prime_k(p);
	}
	return k;
}//随即数k的产生
/*-----------------------------------*/
void elg_sign_develop(int g, int p, int x, int m)
{
	int k;
	int i = 1;
	k = prime_k(p);//产生一个k的随机数,k与p-1互质
	//a=(g^k)%p;
	for (i = 0;i < k;i++)
	{
		a *= g;
		a %= p;
	}
	//while(m!=(a*x+k*i)%(p-1))
	//{i++;}b=i;
	for (i = 0;i < p - 1;i++)
	{
		b = i;
		if ((x * a + k * b) % (p - 1) == m) break;
	}
	k = 0;//丢弃随即数K
	cout << m << "的数字签名是（" << a << "," << b << "）" << endl;
}//产生签名
/*-------------------*/
void elg_sign_test(int y, int p, int m, int g, char name)
{
	int i, c1, d1, j;
	c1 = d1 = j = 1;
	//i=((y^a)*(a^b))%p;
	for (i = 0;i < a;i++)
	{
		c1 *= y;
		c1 %= p;
	}
	for (i = 0;i < b;i++)
	{
		d1 *= a;
		d1 %= p;
	}
	d1 *= c1;
	d1 %= p;
	//j=(g^m)%p;
	for (i = 0;i < m;i++)
	{
		j *= g;
		j %= p;
	}
	if (d1 == j)
	{
		cout << "是用户" << name << "签名的。" << endl;
	}
	else
	{
		cout << "不是用户" << name << "签名的" << endl;
	}
}//验证签名
/*------------------*/
int main()
{
	int p, g, x, y, m, i;
	a = b = 1;
	char name;
	p = prime_number_p();//产生大素数p
	g = Random_number_g(p);//产生随即数g
	cout << "此用户组的公共参数为p=" << p << " g=" << g << endl;
	cout << "输入用户名"<< "\n" << "(输入单位数字,建议输入2)" << endl;
	cin >> name;
	cout << "输入用户密码(私钥）" << endl;//私钥
	cin >> x;
	if (x >= p)
		cout << "密码应该小于P;" << endl;
	y = PKI_y(p, g, x);//公钥y的产生
	cout << "用户" << name << "公钥y是" << y << endl;
	cout << "输入要签名的字符m"<< "\n" << "(建议输入23)" << endl;
	m = m_develop(p);
	elg_sign_develop(g, p, x, m);
	elg_sign_test(y, p, m, g, name);
jj:cout << "结束程序请输入0" << endl;
	cin >> i;
	if (i == 0)
		exit(0);
	else
		goto jj;
}

