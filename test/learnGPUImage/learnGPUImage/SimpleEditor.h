//
//  SimpleEditor.h
//  learnGPUImage
//
//  Created by you&me on 2019/9/19.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface SimpleEditor : NSObject
@property(nonatomic,copy)NSArray *clips;
@property(nonatomic,copy)NSArray *clipTimeRanges;
@property(nonatomic)CMTime transitionDuration;

@property(nonatomic,readonly,retain)AVMutableComposition *composition;// 创建可变的音视频组合
@property(nonatomic,readonly,retain)AVMutableVideoComposition *videoComposition;//用来生成video的组合
@property(nonatomic,readonly,retain)AVMutableAudioMix *audioMix;

-(void)buildCompositionObjectForPlayback;
-(AVPlayerItem *)playerItem;

@end

NS_ASSUME_NONNULL_END
