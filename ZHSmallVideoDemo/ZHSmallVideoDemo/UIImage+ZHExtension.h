//
//  UIImage+ZHExtension.h
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZHExtension)

/**
 获取视频第一帧
 
 @param path 视频在本地的路径
 @return 返回视频第一帧的Image
 */
+ (UIImage *)zh_getVideoPreViewImage:(NSURL *)path;
@end
