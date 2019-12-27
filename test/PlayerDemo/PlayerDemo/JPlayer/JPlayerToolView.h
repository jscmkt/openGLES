//
//  JPlayerToolView.h
//  PlayerDemo
//
//  Created by you&me on 2019/2/2.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JProgressSlider.h"
NS_ASSUME_NONNULL_BEGIN

//@protocol JPlayerToolViewDelegate;
@protocol JPlayerToolViewDelegate;

@interface JPlayerToolView : UIView
@property(nonatomic,weak)id<JPlayerToolViewDelegate> delegate;
@property(nonatomic)UIButton *playSwitch;
@property(nonatomic)UIButton *fullScreen;
@property(nonatomic)UILabel *currentTimeLB;
@property(nonatomic)UILabel *totleTimeLabel;
@property(nonatomic)JProgressSlider *slider;
-(void)exitFullScreen;
@end
@protocol JPlayerToolViewDelegate <NSObject>

-(void)toolView:(JPlayerToolView*)toolView playSwith:(BOOL)isPlay;
-(void)toolView:(JPlayerToolView*)toolView fullScreen:(BOOL)isFull;

@end
NS_ASSUME_NONNULL_END
