//
//  ZHRecordButton.h
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHRecordButtonDelegate <NSObject>

/**
 结束倒计时代理方法
 */
- (void)zh_delegateEndCountdown;
@end

@interface ZHRecordButton : UIButton
@property(nonatomic, weak)id<ZHRecordButtonDelegate> zh_delegate;

/**
 开始录制
 */
- (void)zh_startRecording:(void (^) (BOOL finish, BOOL isEndRecord))completion;

/**
 结束录制
 */
- (void)zh_endRecord;
@end
