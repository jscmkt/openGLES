//
//  main.cpp
//  XXX
//
//  Created by you&me on 2019/10/8.
//  Copyright © 2019 you&me. All rights reserved.
//

#include <iostream>
using namespace std;
int main(int argc, const char * argv[]) {
    int y,m,d;
    bool leap;
    cout << "y=\n" << "m=.\n";
    cin >> y >> m;
    if (y >= 1900 && y < 3000 && m > 0 && m<13 ) ;
    cout << "d=";
    if(m==1 || m==3 || m==5 || m==7 || m==8 || m==10 || m==12) d=31;
    else if (m==4||m==6||m==9||m==11) d=30;
    cout << d;
    cin >> y;
    leap = 0;
    if (y % 4 ==0 && y %100 != 0 || y % 400 == 0 ) leap = 1;
    if (leap && m ==2) d ==29 ;
    else if(m == 2) d==28;
    cout << d;
    return 0;
}
