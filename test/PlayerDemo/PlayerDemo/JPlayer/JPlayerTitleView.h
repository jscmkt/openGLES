//
//  JPlayerTitleView.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/30.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPlayerHeader.h"
#import "UIView+JExtension.h"
NS_ASSUME_NONNULL_BEGIN
@protocol JPlayerTitleViewDelegate;

@interface JPlayerTitleView : UIView
@property(nonatomic,weak)id<JPlayerTitleViewDelegate> delegate;
@property(nonatomic,copy)NSString *title;

-(void)showBackButton;
-(void)hideBackButton;
@end
@protocol JPlayerTitleViewDelegate <NSObject>

@optional
-(void)titleViewDidExitFullScreen:(JPlayerTitleView*)titleView;

@end

NS_ASSUME_NONNULL_END
