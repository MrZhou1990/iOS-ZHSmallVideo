用法
> pod 'ZHSmallVideo', '~> 0.0.1'
# 1.引入头文件
```
#import <ZHSmallVideoController.h>
```
# 2.调用小视频
```
ZHSmallVideoController *videoVc = [[ZHSmallVideoController alloc] initWithDelegate:self];
[self presentViewController:videoVc animated:YES completion:nil];
```
# 3.签代理
```
<ZHSmallVideoControllerDelegate>
```
# 4.实现代理
```
- (void)zh_delegateVideoInLocationUrl:(NSURL *)url {
    NSLog(@"视频存在本地的路径：%@", url);
}
```
可以将视频base64编码传给服务器，可以取视频第一帧图片用来展示给用户Demo里面都有。  
还附上了服务器端视频字符串解码的代码。

