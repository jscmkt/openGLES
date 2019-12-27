//
//  UIView+JExtension.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JExtension)
    @property (assign, nonatomic) CGFloat x;
    @property (assign, nonatomic) CGFloat y;
    @property (assign, nonatomic) CGFloat centerX;
    @property (assign, nonatomic) CGFloat centerY;
    @property (assign, nonatomic) CGFloat width;
    @property (assign, nonatomic) CGFloat height;
    @property (assign, nonatomic) CGSize size;
    @property (assign, nonatomic) CGPoint origin;


@end

NS_ASSUME_NONNULL_END
