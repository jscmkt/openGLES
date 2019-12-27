//
//  JPlayerLayerView.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPlayerLayerView : UIView
    -(void)addPlayerLayer:(AVPlayerLayer*)playerLayer;
@end

NS_ASSUME_NONNULL_END
