# LongImageCache

这是一个简单的图片缓存，同时使用了LongRequest（文件下载），LongDispatch（多任务），实现了一个较为完整的缓存机制，默认支持gif图片的播放

## 集成

1.使用 Cocoapods 来集成LongImageCache, 集成方法如下:

```
pod 'LongImageCache'
```

## 使用方法


图片缓存使用方法

```
//首先引入header
#import "UIImageView+LongCache.h"

//缓存图片
NSString *url = @"http://127.0.0.1/test.jpg";
[imageView setImageWithUrl:url placeholderImage:nil toDisk:YES];

```

## 运行Demo

进入ImageCacheDemo路径下执行，点击ImageCacheDemo.xcworkspace即可运行

```
pod install
```

## Relase Note

### v1.0.3 

* 提高gif图片播放性能，降低内存和cpu的消耗
* 对imagecache进行性能优化

### v1.0.2

* 修复设置空url导致的crash问题

### v1.0.1

* 添加图片浏览功能的LongPhotoBrowser,可以简单浏览图片

### v1.0.0

* 轻量级的ImageCache，可以支持网络图片加载，gif播放等功能