//
//  ViewController.m
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import "ViewController.h"
#import "ZHSmallVideoController.h"
#import "UIImage+ZHExtension.h"

@interface ViewController ()<ZHSmallVideoControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"录制小视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.center = self.view.center;
    btn.frame = CGRectMake(btn.frame.origin.x, 100, btn.frame.size.width, btn.frame.size.height);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(zh_record) forControlEvents:UIControlEventTouchUpInside];
}

- (void)zh_record {
    ZHSmallVideoController *videoVc = [[ZHSmallVideoController alloc] initWithDelegate:self];
    [self presentViewController:videoVc animated:YES completion:nil];
}

// 录制结束的代理，将录制视频存在本地的路径返回，直接根据路径操作文件即可
- (void)zh_delegateVideoInLocationUrl:(NSURL *)url {
    NSLog(@"视频存在本地的路径：%@", url);
    [self zh_showVideoPreviewWithImage:[UIImage zh_getVideoPreViewImage:url]]; // 根据视频的第一帧展示预览图
    /*
     // 第一帧图片
     NSData *imgData = UIImagePNGRepresentation([UIImage zh_getVideoPreViewImage:url]);
     NSLog(@"图片数据流：%@", imgData);
     NSString *imgBase64String = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
     NSLog(@"图片数据流字符串：%@", imgBase64String);
     // 视频
     NSData *videoData = [NSData dataWithContentsOfURL:url];
     NSLog(@"视频数据流：%@", videoData);
     // 将视频数据base64编码，用于传给服务器
     NSString *videoBase64String = [videoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
     NSLog(@"视频数据流字符串：%@", videoBase64String);
     */
    
    /*
     服务端将base64编码后的字符串解码保存为文件
     
     public static void main(String[] args) {
     try {
         byte[] buffer = new BASE64Decoder().decodeBuffer("接收到的客户端base64编码后的字符串");
         FileOutputStream outputStream = new FileOutputStream("/Users/Cloud/Desktop/tempLow.mp4"); // 此处是输出路径，文件名自己设置
         outputStream.write(buffer);
         outputStream.close();
     } catch (IOException e) {
         System.out.println("视频流转码时出现异常：");
         e.printStackTrace();
         }
     }
     */
}

- (void)zh_showVideoPreviewWithImage:(UIImage *)image {
    for (UIView *view in self.view.subviews) {
        if ([view class] != [UIButton class]) {
            [view removeFromSuperview];
        }
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.center = self.view.center;
    imageView.image = image;
    [self.view addSubview:imageView];
}

@end
