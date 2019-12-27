//
//  JPlayerFailedView.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+JExtension.h"
NS_ASSUME_NONNULL_BEGIN
@protocol JPlayerFailedViewDelegate;
@interface JPlayerFailedView : UIView
    @property(nonatomic,weak)id<JPlayerFailedViewDelegate> delegate;
@end
@protocol JPlayerFailedViewDelegate <NSObject>

@optional
    -(void)failedViewDidReplay:(JPlayerFailedView*)failedView;

@end

NS_ASSUME_NONNULL_END
