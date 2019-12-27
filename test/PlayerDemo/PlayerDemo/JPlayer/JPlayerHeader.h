//
//  JPlayerHeader.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/30.
//  Copyright © 2019年 you&me. All rights reserved.
//

#ifndef JPlayerHeader_h
#define JPlayerHeader_h
/****** 宏 ******/
//屏幕宽 高
#define Screen_Width       [UIScreen mainScreen].bounds.size.width
#define Screen_Height      [UIScreen mainScreen].bounds.size.height

//颜色
#define Color_RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0  alpha:1.0]
#define Color_RGB_Alpha(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0  alpha:(a)]
#define Color_Random           [UIColor colorWithRed:arc4random()%256/255.0 green:arc4random()%256/255.0 blue:arc4random()%256/255.0 alpha:1.0]

#endif /* JPlayerHeader_h */
