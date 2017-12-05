//
//  ImageViewController.m
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/11/17.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "ImageViewController.h"
#import "UIImageView+LongCache.h"
#import "UIImageView+LongDisplay.h"

@interface ImageViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) CGPoint panStartPoint;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _array = [NSMutableArray array];
        for (int i = 54; i < 114; i ++) {
            NSString *name = nil;
            if (i < 100) {
                name = [NSString stringWithFormat:@"IMG_00%d.JPG",i];
            } else {
                name = [NSString stringWithFormat:@"IMG_0%d.JPG",i];
            }
            [_array addObject:name];
        }
        [_imageView setImagesWithNames:_array];
        _imageView.animationDuration = 1/24;
        //[_imageView startAnimating];
    }
    return _imageView;
}

- (void)panAction:(UIPanGestureRecognizer*)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.panStartPoint = [recognizer translationInView:self.view];
            NSLog(@"-----Current State: Began-----");
            NSLog(@"start point (%f, %f) in View", self.panStartPoint.x, self.panStartPoint.y);
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currentPoint = [recognizer translationInView:self.view];
            if (currentPoint.x > self.panStartPoint.x) {
                if (_index >= [_array count] || _index <= 0) {
                    _index = 0;
                }
                [_imageView setImageWithName:[_array objectAtIndex:_index]];
                _index++;
            } else {
                if (_index <= 0 || _index >= [_array count]) {
                    _index = [_array count] - 1;
                }
                [_imageView setImageWithName:[_array objectAtIndex:_index]];
                _index--;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"-----Current State: Ended-----");
            CGPoint endPoint = [recognizer translationInView:self.view];
            NSLog(@"end point (%f, %f) in View", endPoint.x, endPoint.y);
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"-----Current State: Cancelled-----");
            NSLog(@"Touch was cancelled");
        }
            break;
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"-----Current State: Failed-----");
            NSLog(@"Failed events");
        }
            break;
        default:
            break;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
