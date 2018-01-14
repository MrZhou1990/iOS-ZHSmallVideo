//
//  ZHRecordButton.m
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import "ZHRecordButton.h"

static const CGFloat zMaxRecordTime = 11; // 这里要加1秒，第10秒的时候结束，但是是9秒的时间
static const CGFloat zTimeInterval = 1;

@interface ZHRecordButton ()
@property(nonatomic, strong)UIView *centerView;
@property(nonatomic, strong)CALayer *animationLayer;
@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)BOOL isEndRecord;
@property(nonatomic, assign)CGFloat recordTime; // 记录录制时间
@property(nonatomic, weak)CAShapeLayer *circleLayer;
@end

@implementation ZHRecordButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _recordTime = 0;
        _isEndRecord = YES;;
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor whiteColor];
        _centerView.userInteractionEnabled = NO;
        [self addSubview:_centerView];
        [self zh_buildLayer]; // 构建圆圈动画
    }
    return self;
}

- (void)zh_buildLayer {
    _animationLayer = [CALayer layer];
    [self.layer addSublayer:_animationLayer];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layer.cornerRadius = frame.size.height / 2;
    _centerView.frame = CGRectMake(0.f, 0.f, frame.size.width - 10.f, frame.size.height - 10.f);
    _centerView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _centerView.layer.cornerRadius = _centerView.frame.size.height / 2;
    _animationLayer.bounds = self.bounds;
    _animationLayer.position = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

- (void)zh_startRecording:(void (^)(BOOL finish, BOOL isEndRecord))completion {
    _isEndRecord = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.5 animations:^{
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        _centerView.transform = CGAffineTransformMakeScale(.5f, .5f);
    } completion:^(BOOL finished) {
        completion(YES, _isEndRecord);
        if (!_isEndRecord) {
            [weakSelf zh_circleAnimation]; // 画圆环
            [self zh_startTimer]; // 开始倒计时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(YES, _isEndRecord);
            });
        }
    }];
}

- (NSTimer *)timer {
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:zTimeInterval target:self selector:@selector(zh_timerAction:) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)zh_startTimer {
    [self zh_stopTimer];
    _recordTime = 0;
    [self.timer fire];
}

- (void)zh_stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)zh_timerAction:(NSTimer *)timer {
    _recordTime += zTimeInterval; // 每次加一秒
    if (_recordTime >= zMaxRecordTime) { // 当到达最大限制录像时间触发
        // 结束计时
        [self zh_stopTimer];
        // 触发代理
        if ([self.zh_delegate respondsToSelector:@selector(zh_delegateEndCountdown)]) {
            [self.zh_delegate zh_delegateEndCountdown];
        }
    }
}

- (void)zh_endRecord {
    _isEndRecord = YES;
    [self zh_stopTimer];
    [self zh_removeCircleAnimation];
    [UIView animateWithDuration:.5 animations:^{
        self.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _centerView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    }];
}

// 绘制转动圆环
- (void)zh_circleAnimation {
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = _animationLayer.bounds;
    [_animationLayer addSublayer:circleLayer];
    _circleLayer = circleLayer; // 指向这个layer用来删除
    circleLayer.fillColor =  [UIColor clearColor].CGColor;
    circleLayer.strokeColor  = [UIColor greenColor].CGColor;
    circleLayer.lineWidth = 3.f;
    CGFloat radius = _animationLayer.bounds.size.width / 2 - circleLayer.lineWidth / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:circleLayer.position radius:radius startAngle:-M_PI / 2 endAngle:M_PI * 3 / 2 clockwise:true];
    circleLayer.path = path.CGPath;
    CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    checkAnimation.duration = 10;
    checkAnimation.fromValue = @(0.0f);
    checkAnimation.toValue = @(1.0f);
    [checkAnimation setValue:@"checkAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:checkAnimation forKey:nil];
}

- (void)zh_removeCircleAnimation {
    [_circleLayer removeAllAnimations];
    [_circleLayer removeFromSuperlayer];
}

@end
