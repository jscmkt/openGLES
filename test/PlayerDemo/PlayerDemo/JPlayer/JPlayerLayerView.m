//
//  JPlayerLayerView.m
//  PlayerDemo
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

#import "JPlayerLayerView.h"

@interface JPlayerLayerView ()
    @property(nonatomic,strong)AVPlayerLayer *playLayer;

@end

@implementation JPlayerLayerView

    -(void)addPlayerLayer:(AVPlayerLayer *)playerLayer{
        _playLayer = playerLayer;
        playerLayer.backgroundColor = [UIColor blackColor].CGColor;
        _playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_playLayer];
    }

    -(void)layoutSublayersOfLayer:(CALayer *)layer{
        [super layoutSublayersOfLayer:layer];
        _playLayer.frame = self.bounds;
    }
@end
