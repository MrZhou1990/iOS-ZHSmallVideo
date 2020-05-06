//
//  ZHPlayVideoView.h
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#define zScaleWidth [UIScreen mainScreen].bounds.size.width / 375
#define zScaleHeight [UIScreen mainScreen].bounds.size.height / 667

typedef enum : NSUInteger {
    ZHActionButtonCancel,
    ZHActionButtonConfirm,
} ZHActionButtonType;

typedef void(^ZHActionButtonBlock)(ZHActionButtonType btnType);

@interface ZHPlayVideoView : UIView
/**
 播放视频
 */
+ (void)zh_playVideoWithUrl:(NSURL *)url completion:(ZHActionButtonBlock)completion;

/**
 结束播放
 */
+ (void)zh_endPlay;
@end
