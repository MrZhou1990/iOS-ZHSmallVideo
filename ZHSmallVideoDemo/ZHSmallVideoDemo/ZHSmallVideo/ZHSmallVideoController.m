//
//  ZHSmallVideoController.m
//  ZHSmallVideoDemo
//
//  Created by Cloud on 2018/1/12.
//  Copyright © 2018年 Cloud. All rights reserved.
//

#import "ZHSmallVideoController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZHRecordButton.h"
#import "ZHPlayVideoView.h"

@interface ZHSmallVideoController ()<AVCaptureFileOutputRecordingDelegate, ZHRecordButtonDelegate>
@property(nonatomic, strong)AVCaptureSession *captureSession; // 捕获会话
@property(nonatomic, strong)AVCaptureMovieFileOutput *output; // 用来给视频输出
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer; // 视频预览层
@property(nonatomic, strong)UIButton *switchCameraBtn; // 切换摄像头按钮
@property(nonatomic, strong)ZHRecordButton *recordBtn; // 录像按钮
@property(nonatomic, strong)UIButton *cancelBtn; // 取消按钮
@property(nonatomic, assign)BOOL isSystemEndRecord; // 记录系统是否成功结束了录制
@property(nonatomic, weak)AVCaptureDeviceInput *videoInput;
@property(nonatomic, weak)id<ZHSmallVideoControllerDelegate> zh_delegate;
@end

@implementation ZHSmallVideoController

- (instancetype)initWithDelegate:(id<ZHSmallVideoControllerDelegate>)zh_delegate {
    self = [super init];
    if (self) {
        self.zh_delegate = zh_delegate;
    }
    return self;
}

#pragma mark 创建捕捉会话
- (void)zh_buildSession {
    // 捕获会话
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    // 捕捉输入
    // 摄像头
    NSError *videoError = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]
                                                                             error:&videoError];
    if (!videoInput || videoError) {
        NSLog(@"摄像头设备创建失败");
        return;
    }
    if ([_captureSession canAddInput:videoInput]) {
        [_captureSession addInput:videoInput];
        _videoInput = videoInput;
    } else {
        NSLog(@"会话无法加入摄像头");
        return;
    }
    // 麦克风
    NSError *audioError = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio]
                                                                             error:&audioError];
    if (!audioInput || audioError) {
        NSLog(@"麦克风设备创建失败");
        return;
    }
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    } else {
        NSLog(@"会话无法加入麦克风");
        return;
    }
    // 视频输出
    _output = [[AVCaptureMovieFileOutput alloc] init];
    // 设置录制模式
    AVCaptureConnection *captureConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    // 设置防抖
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    if ([_captureSession canAddOutput:_output]) {
        [_captureSession addOutput:_output];
    } else {
        NSLog(@"会话无法加入输出设备");
        return;
    }
    // 添加录像图层
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.frame = CGRectMake(0.f, 0.f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 填充模式
    [self.view.layer addSublayer:_previewLayer];
}

#pragma mark 创建UI
- (void)zh_buildUI {
    // 切换摄像头
    _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchCameraBtn setImage:[UIImage imageNamed:@"video_camera_0104"] forState:UIControlStateNormal];
    [_switchCameraBtn sizeToFit];
    _switchCameraBtn.frame = CGRectMake(self.view.frame.size.width - 15.f - _switchCameraBtn.frame.size.width, 30.f, _switchCameraBtn.frame.size.width, _switchCameraBtn.frame.size.height);
    [_switchCameraBtn addTarget:self action:@selector(zh_switchCameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_switchCameraBtn];
    // 录像按钮
    _recordBtn = [ZHRecordButton buttonWithType:UIButtonTypeCustom];
    CGFloat recordBtnW = 60.f;
    _recordBtn.frame = CGRectMake(self.view.frame.size.width / 2 - recordBtnW / 2, self.view.frame.size.height - recordBtnW - recordBtnW, recordBtnW, recordBtnW);
    _recordBtn.zh_delegate = self;
    [_recordBtn addTarget:self action:@selector(zh_startRecording:) forControlEvents:UIControlEventTouchDown];
    [_recordBtn addTarget:self action:@selector(zh_endRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    // 取消按钮
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setImage:[UIImage imageNamed:@"video_close_0104"] forState:UIControlStateNormal];
    [_cancelBtn sizeToFit];
    _cancelBtn.center = _recordBtn.center;
    _cancelBtn.frame = CGRectMake(_recordBtn.frame.origin.x - 50.f * zScaleWidth - _cancelBtn.frame.size.width, _cancelBtn.frame.origin.y, _cancelBtn.frame.size.width, _cancelBtn.frame.size.height);
    [_cancelBtn addTarget:self action:@selector(zh_cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
}

// 取消方法
- (void)zh_cancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 切换摄像头方法
- (void)zh_switchCameraButtonClick {
    NSError *newError = nil;
    AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:({
        AVCaptureDevice *newDevice = nil;
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == (_videoInput.device.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack)) {
                newDevice = device;
                break;
            }
        }
        newDevice;
    }) error:&newError];
    if (newVideoInput && !newError) {
        [_captureSession beginConfiguration];
        [_captureSession removeInput:_videoInput];
        [_captureSession addInput:newVideoInput];
        [_captureSession commitConfiguration];
        _videoInput = newVideoInput;
    } else {
        NSLog(@"摄像头切换失败");
    }
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    [self zh_buildSession]; // 创建会话
    [self zh_buildUI]; // 这个要在创建会话之后创建
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 将摄像头画面展示在屏幕上
    [_captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)zh_startRecording:(ZHRecordButton *)button {
    _isSystemEndRecord = NO;
    [button zh_startRecording:^(BOOL finish, BOOL isEndRecord) {
        NSLog(@"%d -- %d", isEndRecord, _isSystemEndRecord);
        if (isEndRecord && !_isSystemEndRecord) { // 抬起了按钮，并且系统未成功开始录制（未走录制成功的代理方法）
            _switchCameraBtn.hidden = NO;
            _cancelBtn.hidden = NO;
            UILabel *hintLabel = [[UILabel alloc] init];
            hintLabel.text = @"录制时间太短";
            hintLabel.textColor = [UIColor whiteColor];
            [hintLabel sizeToFit];
            hintLabel.center = _recordBtn.center;
            hintLabel.frame = CGRectMake(hintLabel.frame.origin.x, _recordBtn.frame.origin.y - 20.f - hintLabel.frame.size.height, hintLabel.frame.size.width, hintLabel.frame.size.height);
            hintLabel.alpha = 0.f;
            [self.view addSubview:hintLabel];
            [UIView animateWithDuration:.3 animations:^{
                hintLabel.alpha = 1.f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
                    hintLabel.alpha = 0.f;
                } completion:^(BOOL finished) {
                    [hintLabel removeFromSuperview];
                }];
            }];
        } else if (!isEndRecord) { // 动画执行完毕并且未抬起按钮结束录制
            if (![_output isRecording]) {
                _switchCameraBtn.hidden = YES;
                _cancelBtn.hidden = YES;
//                NSLog(@"开始录制视频...");
                AVCaptureConnection *captureConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
                captureConnection.videoOrientation = [_previewLayer connection].videoOrientation;
                [_output startRecordingToOutputFileURL:({
                    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mp4"]];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                    }
                    url;
                }) recordingDelegate:self];
            } else {
                // 视频录制中，不要做任何操作
                return;
            }
        }
    }];
}

- (void)zh_endRecord:(ZHRecordButton *)button {
    [button zh_endRecord];
    if ([_output isRecording]) {
        [_output stopRecording]; // 通过代理实现结束之后的操作
    }
}

// 压缩视频
- (void)zh_videoCompressionWithVideoUrl:(NSURL *)videoUrl {
    // 加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    // 创建视频资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    // 创建导出视频的URL
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLow.mp4"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    session.outputURL = url;
    // 必须配置输出属性
    session.outputFileType = @"com.apple.quicktime-movie";
    // 导出视频
    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 弹出层播放视频
            __weak typeof(self) weakSelf = self;
            [ZHPlayVideoView zh_playVideoWithUrl:url completion:^(ZHActionButtonType btnType) {
                if (btnType == ZHActionButtonCancel) { // 取消了，重新录制
                    [weakSelf zh_buttonStatus:NO]; // 显示出操作按钮
                } else { // 销毁当前页面，将视频路径回传给上层路径
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        if ([weakSelf.zh_delegate respondsToSelector:@selector(zh_delegateVideoInLocationUrl:)]) {
                            [weakSelf.zh_delegate zh_delegateVideoInLocationUrl:url];
                        }
                    }];
                }
            }];
        });
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    _isSystemEndRecord = YES;
    // 隐藏按钮
    [self zh_buttonStatus:YES];
    // 压缩视频
    [self zh_videoCompressionWithVideoUrl:outputFileURL];
}

- (void)zh_buttonStatus:(BOOL)status {
    _switchCameraBtn.hidden = status;
    _recordBtn.hidden = status;
    _cancelBtn.hidden = status;
}

- (void)dealloc {
//    NSLog(@"销毁了");
}

#pragma mark - ZHRecordButtonDelegate
- (void)zh_delegateEndCountdown {
    // 用户未主动抬起按钮，倒计时结束
    [self zh_endRecord:_recordBtn];
}

@end
