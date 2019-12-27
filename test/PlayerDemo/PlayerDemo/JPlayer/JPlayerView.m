//
//  JPlayerView.m
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JPlayerView.h"
#import "JPlayerToolView.h"
#import "JPlayerHeader.h"
#import "JPlayerFailedView.h"
#import "JPlayerLayerView.h"
#import "JPlayerTitleView.h"
#import "JFullViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+JExtension.h"
@interface JPlayerView ()<JPlayerToolViewDelegate,JPlayerTitleViewDelegate,JPlayerFailedViewDelegate>
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVPlayerItem *playerItem;
@property(nonatomic,strong)AVPlayerLayer *playerLayer;

@property(nonatomic,strong)JFullViewController *fullVC;
@property(nonatomic,weak)UIViewController *currentVC;

@property(nonatomic,strong)JPlayerTitleView *titleView;
@property(nonatomic,strong)JPlayerToolView *toolView;
@property(nonatomic,strong)JPlayerFailedView *failedView;
@property(nonatomic,strong)JPlayerLayerView *layerView;
@property(nonatomic,strong)UIActivityIndicatorView *activity;
@property(nonatomic,strong)UIImageView *coverImageView;
@property(nonatomic,strong)CADisplayLink *link;
@property(nonatomic,assign)NSTimeInterval lastTime;
@property(nonatomic,strong)NSTimer *toolViewShowTimer;
@property(nonatomic,assign)NSTimeInterval toolViewShowTime;

///当前是否显示控制条
@property(nonatomic,assign)BOOL isShowToolView;
///是否第一次播放
@property(nonatomic,assign)BOOL isFirstPlay;
///是否重播
@property(nonatomic,assign)BOOL isReplay;

@property(nonatomic,strong)NSArray *videoArr;
@property(nonatomic,strong)JVideoModel *videoModel;
@property(nonatomic)CGRect playerFrame;
@end

@implementation JPlayerView
#pragma mark - 初始化
-(instancetype)initWithFrame:(CGRect)frame currentVC:(UIViewController *)controller{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        self.currentVC = controller;
        _isShowToolView = YES;
        _isFirstPlay = YES;
        _isReplay = NO;
        _playerFrame = frame;
        [self addSubViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}
#pragma mark notification
-(void)videoPlayEnd{
    NSLog(@"播放完成");
    self.toolView.playSwitch.selected = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.toolView.y = self.height - self.toolView.height;
        self.titleView.y = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isShowToolView = YES;
    }];

    self.videoModel.currentTime = 0;
    NSInteger index = [self.videoArr indexOfObject:self.videoModel];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayerEndVideo:index:)]) {
        [self.delegate playerView:self didPlayerEndVideo:self.videoModel index:index];
    }
    if(index != self.videoArr.count - 1 ){
        [self.player pause];
        self.videoModel = self.videoArr[index+1];
        self.titleView.title = self.videoModel.title;
        [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
        [self addToolViewTimer];
    }else{
        self.isReplay = YES;
        [self.player pause];
        self.link.paused = YES;
        [self removeToolViewTimer];
        self.coverImageView.hidden = NO;
        self.toolView.slider.sliderPercent = 0;
        self.toolView.slider.enabled = NO;
        [self.activity stopAnimating];
    }
}
#pragma mark - 设置覆盖的图片
-(void)setCoverImage:(NSString *)imageUrl{
    _coverImageView.hidden = NO;
    [_coverImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@""]];
}

#pragma mark - 设置要播放的视频列表和要播放的视频
-(void)setVideoModels:(NSArray<JVideoModel *> *)videoModels playerVideoId:(NSString *)videoId{
    self.videoArr = [NSArray arrayWithArray:videoModels];
    if (videoId.length > 0) {
        for (JVideoModel *model in self.videoArr) {
            if ([model.videoId isEqualToString:videoId]) {
                NSInteger index = [self.videoArr indexOfObject:model];
                self.videoModel = self.videoArr[index];
                break;
            }
        }
    }else{
        self.videoModel = self.videoArr.firstObject;
    }
    _titleView.title = self.videoModel.title;
    _isFirstPlay = YES;
}
#pragma mark - 点击目录要播放的视频id
-(void)playVideoWithVideoId:(NSString *)videoId{
    if (![self.delegate respondsToSelector:@selector(playerViewShouldPlay)]) {
        return;
    }
    [self.delegate playerViewShouldPlay];
    for ( JVideoModel *model in self.videoArr) {
        if ([model.videoId isEqualToString:videoId]) {
            NSInteger index = [self.videoArr indexOfObject:model];
            self.videoModel = self.videoArr[index];
            break;
        }
    }
    _titleView.title = self.videoModel.title;
    if (_isFirstPlay) {
        _coverImageView.hidden = YES;
        [self setPlayer];
        [self addToolViewTimer];
        _isFirstPlay = NO;
    }else{
        [self.player pause];
        [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
        [self addToolViewTimer];
    }
}

///暂停
-(void)pause{
    [self.player pause];
    self.link.paused = YES;
    _toolView.playSwitch.selected = NO;
    [self removeToolViewTimer];
}
///停止
-(void)stop{
    [self.player pause];
    [self.link invalidate];
    _toolView.playSwitch.selected = NO;
    [self removeToolViewTimer];
}

#pragma mark - 设置播放器
-(void)setPlayer{
    if (self.videoModel) {
        if (self.videoModel.url) {
            if (![self checkNetWork]) {
                return;
            }
            self.playerItem = [AVPlayerItem playerItemWithURL:self.videoModel.url];
            [self addObserverWithPlayerItem:self.playerItem];

            if (self.player) {
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
            }else{
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
            }
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            [_layerView addPlayerLayer:self.playerLayer];
            NSInteger index = [self.videoArr indexOfObject:self.videoModel];
            if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayVideo:index:)]) {
                [self.delegate playerView:self didPlayVideo:self.videoModel index:index];

            }
            self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateSlider)];
            [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }else{
            _failedView.hidden = NO;
        }
    }else{
        _failedView.hidden = NO;
    }
}

#pragma mark - 切换当前播放的内容
-(void)replaceCurrentPlayerItemWithVideoModel:(JVideoModel*)model{
    if (self.player) {
        if (model) {
            if (![self checkNetWork]) {
                return;
            }
            //由暂停状态切换时候 开启定时器，将暂停状态设置为播放状态
            self.link.paused = NO;
            _toolView.playSwitch.selected = YES;

            //移除当前ACPlayerItem对“loadedTimeRanges”和”status“的监听
            [self removeObserverWithPlayerItem:self.playerItem];
            if (model.url) {
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:model.url];
                self.playerItem = playerItem;
                [self addObserverWithPlayerItem:self.playerItem];
                //更换播放的AVPlayerItem
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
                NSInteger index = [self.videoArr indexOfObject:self.videoModel];
                if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayVideo:index:)]) {
                    [self.delegate playerView:self didPlayVideo:self.videoModel index:index];
                }
                _toolView.playSwitch.enabled = NO;
                _toolView.slider.enabled = NO;
            }else{
                _toolView.playSwitch.selected = NO;
                _failedView.hidden = NO;
            }
        }else{
            _toolView.playSwitch.selected = NO;
            _failedView.hidden = NO;
        }
    }
}

#pragma mark - time event
///更新进度条
-(void)updateSlider{
    NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
    NSTimeInterval total = CMTimeGetSeconds(self.player.currentItem.duration);
    //如果用户在手动滑动滑块，则不对滑块的进度进行设置重绘
    if (!_toolView.slider.isSliding) {
        _toolView.slider.sliderPercent = current / total;
    }
    if (current != self.lastTime) {
        [_activity stopAnimating];
        _toolView.currentTimeLB.text = [self convertTimeToString:current];
        _toolView.totleTimeLabel.text = isnan(total)?@"00:00":[self convertTimeToString:total];

        if (self.delegate && [self.delegate respondsToSelector:@selector(playerView:didPlayVideo:playTime:)]) {
            [self.delegate playerView:self didPlayVideo:self.videoModel playTime:current];
        }
    }else{
        [_activity startAnimating];

    }
    //记录当前播放时间 用于区分是否卡顿显示缓冲动画
    self.lastTime = current;
}
-(void)updateToolViewShowTime{
    _toolViewShowTime++;
    if (_toolViewShowTime == 5) {
        [self removeToolViewTimer];
        _toolViewShowTime = 0;
        [self showOrHideBar];
    }
}
#pragma mark - failedView delegate
///重复播放
-(void)failedViewDidReplay:(JPlayerFailedView *)failedView{
    self.failedView.hidden = YES;
    [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
}

#pragma mark - titleView delegate
-(void)titleViewDidExitFullScreen:(JPlayerTitleView *)titleView{
    [self.toolView exitFullScreen];
}

#pragma mark - toolView Delegate
-(void)toolView:(JPlayerToolView *)toolView playSwith:(BOOL)isPlay{
    if (_isFirstPlay) {
        if ([self.delegate playerViewShouldPlay]) {
            self.toolView.playSwitch.selected = !_toolView.playSwitch.selected;
            return;
        }
        self.coverImageView.hidden = NO;
        if (!self.videoModel.videoId) {
            self.coverImageView.hidden = NO;
            self.toolView.playSwitch.selected = !_toolView.playSwitch.selected;
            return;
        }
        [self setPlayer];
        [self addToolViewTimer];
        self.isFirstPlay = NO;
    }else if(self.isReplay){
        self.coverImageView.hidden = YES;
        self.videoModel = self.videoArr.firstObject;
        self.titleView.title = self.videoModel.title;
        [self addToolViewTimer];
        [self replaceCurrentPlayerItemWithVideoModel:self.videoModel];
        self.isReplay = NO;

    }else{
        if (!isPlay) {
            [self.player pause];
            self.link.paused = YES;
            [_activity stopAnimating];
            [self removeToolViewTimer];
        }else{
            [self.player play];
            self.link.paused = NO;
            [self addToolViewTimer];
        }
    }
}

-(void)toolView:(JPlayerToolView *)toolView fullScreen:(BOOL)isFull{
    [self addToolViewTimer];
    //弹出全屏播放器
    if (isFull) {
        [self.currentVC presentViewController:self.fullVC animated:NO completion:^{
            [self.titleView showBackButton];
            [self.fullVC.view addSubview:self];
            self.center = self.fullVC.view.center;
            [UIView animateWithDuration:0.15 animations:^{
                self.frame = self.fullVC.view.bounds;
                self.layerView.frame = self.bounds;
                self.failedView.frame = self.bounds;
                [self makeContraintsForUI];
                [self showOrHideBar];
            } completion:nil];
        }];
    }else{
        [self.titleView hideBackButton];
        [self.fullVC dismissViewControllerAnimated:NO completion:^{
            [self.currentVC.view addSubview:self];
            [UIView animateWithDuration:0.15 animations:^{
                self.frame = self.playerFrame;
                self.layerView.frame = self.bounds;
                self.failedView.frame = self.bounds;
                [self makeContraintsForUI];
                [self showOrHideBar];
            } completion:nil];
        }];
    }
}
#pragma mark - 监听视频缓冲和加载状态
//注册观察者监听状态和缓冲
-(void)addObserverWithPlayerItem:(AVPlayerItem*)playerItem{
    if(playerItem){
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];

    }
}

//移除观察者
-(void)removeObserverWithPlayerItem:(AVPlayerItem *)playerItem{
    if (playerItem) {
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [playerItem removeObserver:self forKeyPath:@"status"];

    }
}
//监听变化方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *playrtItem = (AVPlayerItem*)object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval loadedTime = [self availableDurationWithPlayeraItem:playrtItem];
        NSTimeInterval totalTime = CMTimeGetSeconds(playrtItem.duration);
        if (!_toolView.slider.isSliding) {
            _toolView.slider.progressPrecent = loadedTime/totalTime;

        }
    }else if ([keyPath isEqualToString:@"status"]){
        if (playrtItem.status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"playerItem is ready");

            [self.player play];
            self.link.paused = NO;
            CMTime seekTime = CMTimeMake(self.videoModel.currentTime, 1);
            [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
                if (finished) {
                    NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
                    self.toolView.currentTimeLB.text = [self convertTimeToString:current];
                }
            }];
            _toolView.slider.enabled = YES;
            _toolView.playSwitch.enabled = YES;
            _toolView.playSwitch.selected = YES;
        }else{
            NSLog(@"load break");
            self.failedView.hidden = NO;
        }
    }
}
///转换时间成字符串
-(NSString*)convertTimeToString:(NSTimeInterval)time{
    if (time <= 0) {
        return @"00:00";
    }
    int minute = time / 60;
    int second = (int)time % 60;
    NSString *timeStr;
    if (minute >= 100) {
        timeStr = [NSString stringWithFormat:@"%d:%02d",minute,second];
    }else{
        timeStr = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    }
    return timeStr;
}
//获取缓冲进度
-(NSTimeInterval)availableDurationWithPlayeraItem:(AVPlayerItem*)playerItem{
    NSArray *loadedTimeTanges = [playerItem loadedTimeRanges];
    //获取缓冲区域
    CMTimeRange timeRange = [loadedTimeTanges.firstObject CMTimeRangeValue];
    NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
    //计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}
-(void)addToolViewTimer{

    [self removeToolViewTimer];
    _toolViewShowTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateToolViewShowTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.toolViewShowTimer forMode:NSRunLoopCommonModes];
}
-(void)removeToolViewTimer{
    [_toolViewShowTimer invalidate];
    _toolViewShowTimer = nil;
    _toolViewShowTime = 0;
}
#pragma mark - 网络监测
-(BOOL)checkNetWork{

    //网络监测 Reachability
//    Reachability *re = [Reachability reachabilityForInternetConnection];
//    if ([re currentReachabilityStatus] ==NotReachable) {
//        return NO;
//    }else if ([re currentReachabilityStatus] ==ReachableViaWiFi)
//    {
//        //        NSLog(@"当前wifi连接");
//        return YES;
//    }else{
//        //        NSLog(@"wwan(3g)");
//        return YES;
//    }
    return YES;
}
#pragma mark - addSubViews
-(void)addSubViews{
    ///播放额layerView
    [self addSubview:self.layerView];
    ///菊花
    [self addSubview:self.activity];
    ///加载失败
    [self addSubview:self.failedView];
    ///覆盖的图片
    [self addSubview:self.coverImageView];
    ///下部的工具栏
    [self addSubview:self.toolView];
    ///上部的标题栏
    [self addSubview:self.titleView];

    [self makeContraintsForUI];

}
#pragma mark - 添加约束
-(void)makeContraintsForUI{
    _layerView.frame = CGRectMake(0, 0, self.width, self.height);
    _toolView.frame = CGRectMake(0, self.height, self.width, 44);
    _titleView.frame = CGRectMake(0, 0, self.width, 44);
    _activity.frame = CGRectMake(0, 0, 30, 30);
    _activity.center = self.center;
    _failedView.frame = CGRectMake(0, 0, self.width, self.height);
    _coverImageView.frame = CGRectMake(0, 0, self.width, self.height);

}
-(void)layoutSubviews{
    [self.superview bringSubviewToFront:self];
}
#pragma mark -  sliderevent
-(void)progressValueChange:(JProgressSlider*)slider{
    [self addToolViewTimer];
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        NSTimeInterval duration = slider.sliderPercent * CMTimeGetSeconds(self.player.currentItem.duration);
        CMTime seekTime = CMTimeMake(duration, 1);
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
            if (finished) {
                NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
                self.toolView.currentTimeLB.text = [self convertTimeToString:current];
            }
        }];
    }
}

#pragma mark - touch event
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeToolViewTimer];
    [self showOrHideBar];
}


-(void)showOrHideBar{
    [UIView animateWithDuration:0.25 animations:^{
        self.toolView.y = self.isShowToolView ? self.height : self.height-44;
        self.titleView.y = self.isShowToolView ? -44 : 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isShowToolView = !self.isShowToolView;
        if (self.isShowToolView) {
            [self addToolViewTimer];
        }
    }];

}

-(void)dealloc{
    NSLog(@"player view dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self removeObserverWithPlayerItem:self.playerItem];
}
#pragma mark - setter and getter
-(UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc]init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}
-(JFullViewController *)fullVC{
    if (!_fullVC) {
        _fullVC = [[JFullViewController alloc]init];
    }
    return _fullVC;
}
-(JPlayerLayerView *)layerView{
    if (!_layerView) {
        _layerView = [[JPlayerLayerView alloc]init];
    }
    return _layerView;
}
-(UIActivityIndicatorView *)activity{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _activity.color = [UIColor redColor];
        [_activity setCenter:self.center];
        //设置显示类型
        [_activity setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyleWhiteLarge)];

    }
    return _activity;
}
-(JPlayerFailedView *)failedView{
    if (!_failedView) {
        _failedView = [[JPlayerFailedView alloc]init];
        _failedView.hidden = YES;
    }
    return _failedView;
}
-(JPlayerToolView *)toolView{
    if (!_toolView) {
        _toolView = [[JPlayerToolView alloc]init];
        _toolView.delegate = self;
        [_toolView.slider addTarget:self action:@selector(progressValueChange:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _toolView;
}
-(JPlayerTitleView *)titleView{
    if (!_titleView) {
        _titleView = [[JPlayerTitleView alloc]init];
        _titleView.delegate = self;
    }
    return _titleView;
}
@end

