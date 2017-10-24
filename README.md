# LongImageCache

这是一个简单的图片缓存，同时使用了LongRequest（文件下载），LongDispatch（多任务），实现了一个较为完整的缓存机制

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

##运行Demo

进入ImageCacheDemo路径下执行，点击ImageCacheDemo.xcworkspace即可运行

```
pod install
```