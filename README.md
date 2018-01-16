用法
> pod 'ZHSmallVideo', '~> 0.0.1'
# 1.需要设置info.plist
![image](https://note.youdao.com/yws/api/personal/file/WEB579fb2221e3a45842b0a77ec9ff7774a?method=download&shareKey=d43fcf1368de25abf634f62e3b1095f6)
设置View controller-based status bar appearance是为了在录制小视频时隐藏系统时间状态栏。
# 2.引入头文件
```
#import <ZHSmallVideoController.h>
```
# 3.调用小视频
```
ZHSmallVideoController *videoVc = [[ZHSmallVideoController alloc] initWithDelegate:self];
[self presentViewController:videoVc animated:YES completion:nil];
```
# 4.签代理
```
<ZHSmallVideoControllerDelegate>
```
# 5.实现代理
```
- (void)zh_delegateVideoInLocationUrl:(NSURL *)url {
NSLog(@"视频存在本地的路径：%@", url);
}
```
可以将视频base64编码传给服务器，可以取视频第一帧图片用来展示给用户Demo里面都有。  
还附上了服务器端视频字符串解码的代码。
