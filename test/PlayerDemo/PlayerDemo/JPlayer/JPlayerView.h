//
//  JPlayerView.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JVideoModel.h"

NS_ASSUME_NONNULL_BEGIN


@protocol JPlayerViewDelegate;
@interface JPlayerView : UIView

    @property(nonatomic,weak)id<JPlayerViewDelegate> delegate;
    /**
     对象方法创建对象
     @param frame       约束
     @param controller  所在的控制器
     @return            对象
     */
    -(instancetype)initWithFrame:(CGRect)frame currentVC:(UIViewController *)controller;
    /**
     设置要播放的视频列表和要播放的视频
     @param videoModels 存储视频model的数组
     @param videoId     当前要播放的视频id

     */
    -(void)setVideoModels:(NSArray<JVideoModel*>*)videoModels playerVideoId:(NSString*)videoId;
    /**
     设置覆盖的图片
     @param imageUrl 覆盖的图片url
     */
    -(void)setCoverImage:(NSString*)imageUrl;
    /**
     点击目录要播放的视频id
     @param videoId 要播放的视频id
     */
    -(void)playVideoWithVideoId:(NSString *)videoId;

    /**
     暂停
     */
    -(void)pause;
    /**
     停止
     */
    -(void)stop;
@end
@protocol JPlayerViewDelegate <NSObject>

    //是否可以播放
    -(BOOL)playerViewShouldPlay;
    @optional
    //播放结束
    -(void)playerView:(JPlayerView*)playView didPlayerEndVideo:(JVideoModel*)videoModel index:(NSInteger)index;
    //开始播放
    -(void)playerView:(JPlayerView*)playView didPlayVideo:(JVideoModel *)videoModel index:(NSInteger)index;
    //播放中
    -(void)playerView:(JPlayerView*)playView didPlayVideo:(JVideoModel *)videoModel playTime:(NSTimeInterval)playTime;

    @end
NS_ASSUME_NONNULL_END
