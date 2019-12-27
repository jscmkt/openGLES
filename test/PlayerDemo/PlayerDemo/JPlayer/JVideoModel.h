//
//  JVideoModel.h
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,JVideoPlayStyle){
    JVideoPlayStyleLocal = 0,   //播放本地视频
    JVideoPlayStyleNetwork,     //播放网络视频
    JVideoPlayStyleNetworkSD,   //播放网络标清视频
    JVideoPlayStyleNetworkHD,   //播放网络高清视频
};
@interface JVideoModel : NSObject
    @property(nonatomic,copy)NSString *videoId;
    @property(nonatomic,copy)NSString *title;
    @property(nonatomic,strong)NSURL *url;
    @property(nonatomic,assign)JVideoPlayStyle style;
    @property(nonatomic,assign)NSTimeInterval currentTime;

    /**
     创建本地视频模型

     @param videoId     视频ID
     @param title       标题
     @param videoPath   播放文件路径
     @param currentTime 当兵前播放时间
     @return            本地视频模型
     */
    -(instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title videoPath:(NSString*)videoPath currentTime:(NSTimeInterval)currentTime;
    /**
     创建网络视频模型

     @param videoId     视频ID
     @param title       标题
     @param url         视频地址
     @param currentTime 当兵前播放时间
     @return            本地视频模型
     */
    -(instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title url:(NSString*)url currentTime:(NSTimeInterval)currentTime;
    /**
     创建网络视频模型

     @param videoId     视频ID
     @param title       标题
     @param hdUrl       gaoqi视频地址
     @param currentTime 当前播放时间
     @return            本地视频模型
     */
    -(instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title sdUrl:(NSString*)sdUrl hdUrl:(NSString*)hdUrl currentTime:(NSTimeInterval)currentTime;

@end

NS_ASSUME_NONNULL_END
