

#include "pch.h"
#include <iostream>

using namespace std;

int main()
{
	setlocale(LC_ALL, "Rus");
	float l, res;
	float g = 9.81;
	float twopi = 6.28;
	cout << "Введите длину маятника в метрах L=";
	cin >> l;
	_asm
	{
		fld[g]
		fld[l]
		fdiv st(0), st(1)
		fsqrt
		fld[twopi]
		fmul
		fst[res]
	}
	cout << "Результат = " << res << endl;
	return 0;
}


