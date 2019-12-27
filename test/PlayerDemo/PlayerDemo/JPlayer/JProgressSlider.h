//
//  JProgressSlider.h
//  PlayerDemo
//
//  Created by you&me on 2019/2/2.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,JSliderDirection) {
    JSliderDirectionHorizonal = 0,
    JSliderDirectionVertical = 1
};


@interface JProgressSlider : UIControl

///最小值
@property(nonatomic,assign) CGFloat minValue;
///最大值
@property(nonatomic,assign) CGFloat maxValue;
///滑动值
@property(nonatomic,assign) CGFloat value;
///滑动的百分比
@property(nonatomic,assign) CGFloat sliderPercent;
///缓冲的百分比
@property(nonatomic,assign) CGFloat progressPrecent;
///是否正在滑动  如果在划定的是 外面d监听的回调不应该设置sliderPercent progressPercent 避免绘制混乱
@property(nonatomic,assign)BOOL isSliding;
///方向
@property(nonatomic,assign) JSliderDirection direction;

-(instancetype)initWithFrame:(CGRect)frame direction:(JSliderDirection)direction; 
@end
NS_ASSUME_NONNULL_END
