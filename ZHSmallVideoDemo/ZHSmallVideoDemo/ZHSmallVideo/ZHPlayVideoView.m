//
//  ZHPlayVideoView.m
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import "ZHPlayVideoView.h"
#import <AVFoundation/AVFoundation.h>

#define KEYWINDOW [UIApplication sharedApplication].keyWindow
#define ANIMATIONDURATION 0.3

@interface ZHPlayVideoView ()
@property(nonatomic, strong)AVPlayer *player;
@property(nonatomic, strong)AVPlayerItem *playerItem;
@property(nonatomic, strong)AVPlayerLayer *playerLayer;
@property(nonatomic, copy)ZHActionButtonBlock block;
@end

@implementation ZHPlayVideoView

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        // 监听播放完成通知，用来重复播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zh_playFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        // 创建播放器
        _playerItem = [AVPlayerItem playerItemWithURL:url];
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = self.layer.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:_playerLayer];
        [_player play];
        // 创建返回按钮
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.tag = 1000;
        [cancelBtn setImage:[UIImage imageNamed:@"video_return_0104"] forState:UIControlStateNormal];
        CGFloat cancelBtnW = 60.f;
        cancelBtn.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        cancelBtn.frame = CGRectMake(cancelBtn.frame.origin.x, self.frame.size.height - cancelBtnW * 2, cancelBtnW, cancelBtnW);
        [cancelBtn addTarget:self action:@selector(zh_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        // 创建使用按钮
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.tag = 1001;
        [confirmBtn setImage:[UIImage imageNamed:@"video_success_0104"] forState:UIControlStateNormal];
        [confirmBtn sizeToFit];
        confirmBtn.frame = cancelBtn.frame;
        [confirmBtn addTarget:self action:@selector(zh_buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmBtn];
        // 移动
        [self zh_moveButton:cancelBtn value:(-50 * zScaleWidth - cancelBtn.frame.size.width)]; // 左移需要多加一个按钮的距离
        [self zh_moveButton:confirmBtn value:50 * zScaleWidth];
    }
    return self;
}

- (void)zh_moveButton:(UIButton *)button value:(CGFloat)value {
    [UIView animateWithDuration:.3 animations:^{
        button.frame = CGRectMake(button.frame.origin.x + value, button.frame.origin.y, button.frame.size.width, button.frame.size.height);
    }];
}

- (void)zh_playFinish {
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

+ (void)zh_playVideoWithUrl:(NSURL *)url completion:(ZHActionButtonBlock)completion {
    [self zh_endPlay];
    ZHPlayVideoView *playView = [[ZHPlayVideoView alloc] initWithFrame:KEYWINDOW.bounds url:url];
    playView.block = completion;
    [KEYWINDOW addSubview:playView];
}

+ (void)zh_endPlay {
    for (UIView *view in KEYWINDOW.subviews) {
        if ([view class] == [ZHPlayVideoView class]) {
            ZHPlayVideoView *playView = (ZHPlayVideoView *)view;
            [playView.player pause];
            [view removeFromSuperview];
        }
    }
}

- (void)zh_buttonClick:(UIButton *)button {
    [ZHPlayVideoView zh_endPlay];
    self.block(button.tag - 1000 == 0 ? ZHActionButtonCancel : ZHActionButtonConfirm);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

@end
