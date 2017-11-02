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

## 播放GIF与SDWebImage性能对比

相同两张gif图片，使用iphone8模拟器，虽然使用了一定的cpu，但是对内存消耗差距十分明显（选取的gif图片帧数较多，分别是209和135）

使用SDImageCache播放GIF图片时的内存和CPU消耗:

![image](https://raw.githubusercontent.com/lizilong1989/LongImageCache/master/show/SD-Gif.png)

播放效果:

![image](https://raw.githubusercontent.com/lizilong1989/LongImageCache/master/show/SD.gif)


使用LongImageCache播放GIF图片时的内存和CPU消耗:

![image](https://raw.githubusercontent.com/lizilong1989/LongImageCache/master/show/Long-Gif.png)

播放效果:

![image](https://raw.githubusercontent.com/lizilong1989/LongImageCache/master/show/long.gif)

使用的gif素材：

<img width="215" height="181" src="https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507717762475&di=8e388d038a3a65469db35e53a9b45743&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01a9f35542a2430000019ae979d241.jpg"/>

<img width="215" height="181" src="https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1508757634798&di=d70c6bc2ac001a4ea10dc9698c77b0fb&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0188a958a9ad69a801219c77cff8f7.gif"/>


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
