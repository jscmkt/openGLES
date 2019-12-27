//
//  JVideoModel.m
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JVideoModel.h"

@interface JVideoModel ()
    @property(nonatomic,copy)NSString *sdUrl;
    @property(nonatomic,copy)NSString *hdUrl;
@end

@implementation JVideoModel
-(instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title videoPath:(NSString *)videoPath currentTime:(NSTimeInterval)currentTime{
    self = [super init];
    if (self) {
        _videoId = videoId;
        _title = title;
        _currentTime = currentTime;
        _url = [NSURL fileURLWithPath:videoPath];
        _style = JVideoPlayStyleLocal;
    }
    return self;
}
-(instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title url:(NSString *)url currentTime:(NSTimeInterval)currentTime{
    if (self = [super init]) {
        _videoId = videoId;
        _title = title;
        _currentTime = currentTime;
        _url = [NSURL URLWithString:url];
        _style = JVideoPlayStyleNetwork;
    }
    return self;
}
    -(instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title sdUrl:(NSString *)sdUrl hdUrl:(NSString *)hdUrl currentTime:(NSTimeInterval)currentTime{
        if (self = [super init]) {
            _videoId = videoId;
            _title = title;
            _currentTime = currentTime;
            _sdUrl = sdUrl;
            _hdUrl = hdUrl;
            _style = JVideoPlayStyleNetworkHD;
        }
        return self;
    }
    -(void)setStyle:(JVideoPlayStyle)style{
        _style = style;
        if (_style == JVideoPlayStyleNetworkSD) {
            _url = [NSURL URLWithString:_sdUrl];
        }else if(_style == JVideoPlayStyleNetworkHD){
            _url = [NSURL URLWithString:_hdUrl];
        }
    }
@end
