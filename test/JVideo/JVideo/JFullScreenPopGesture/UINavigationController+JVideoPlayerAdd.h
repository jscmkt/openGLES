//
//  UINavigationController+JVideoPlayerAdd.h
//  JVideo
//
//  Created by you&me on 2019/12/12.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "jScreenshotTransitionMode.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,JFullscreenPopGestureType) {
    JFullscreenPopGestureType_EdgeLeft, //默认,屏幕左边缘出发手势
    JFullscreenPopGestureType_Full,     //全屏出发手势
};

@interface UINavigationController (Setting)

@property(nonatomic)JFullscreenPopGestureType j_gestuerType;

@property(nonatomic)JScreenshotTransitionMode j_transitionMode;

@property(nonatomic,readonly)UIGestureRecognizerState j_fullscreenGestureState;

///如果导航栏上出现黑底,请设置他
@property(nonatomic,strong)UIColor *j_backgroundColor;

///偏移多少,触发pop
@property(nonatomic)float scMaxOffset;


@end

NS_ASSUME_NONNULL_END
