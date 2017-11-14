//
//  LongPhotoBrowser.m
//  Pods
//
//  Created by zilong.li on 2017/10/24.
//

#import "LongPhotoBrowser.h"

#import "UIImageView+LongCache.h"

static LongPhotoBrowser *browser = nil;

@interface LongCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LongCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.maximumZoomScale = 2.0f;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:_imageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageView.frame = self.bounds;
    _scrollView.frame = self.bounds;
}

- (void)dealloc
{
    [_imageView stopAnimating];
}

- (void)layoutSubviews {
    
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter))
        _imageView.frame = frameToCenter;
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
    
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end

@interface LongPhotoViewController : UICollectionViewController <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation LongPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[LongCollectionViewCell class] forCellWithReuseIdentifier:@"collectionCell"];
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAction)];
    [self.collectionView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.collectionView addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPress.minimumPressDuration = 1.0f;
    [self.collectionView addGestureRecognizer:longPress];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
    [self.view addSubview:self.titleView];
}

#pragma mark - view

- (UIView*)titleView
{
    if (_titleView == nil) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.collectionView.frame), 64)];
        _titleView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _titleView.hidden = YES;
        [_titleView addSubview:self.closeButton];
    }
    return _titleView;
}

- (UIButton*)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, 20, CGRectGetHeight(_titleView.frame), 44);
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_images count] > 0) {
        return [_images count];
    }
    
    if ([_urls count] > 0) {
        return [_urls count];
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identify = @"collectionCell";
    LongCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    [cell sizeToFit];
    cell.imageView.image = nil;
    if ([_images count] > 0) {
        cell.imageView.image = [_images objectAtIndex:indexPath.row];
    }
    
    if ([_urls count] > 0) {
        [cell.imageView setImageWithUrl:[_urls objectAtIndex:indexPath.row] placeholderImage:nil toDisk:NO showActivityView:YES];
    }
    
    cell.userInteractionEnabled = YES;
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showAction
{
    self.titleView.hidden = !self.titleView.hidden;
}

- (void)doubleTapAction:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    LongCollectionViewCell *cell = (LongCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        if (cell.scrollView.zoomScale != 1.0f) {
            [UIView animateWithDuration:0.2 animations:^{
                [cell.scrollView setZoomScale:1.0];
            }];
        }
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    LongCollectionViewCell *cell = (LongCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save to Album"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               UIImageWriteToSavedPhotosAlbum(cell.imageView.image, self, nil, nil);
                                                           }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        [alertController addAction:saveAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end

@implementation LongPhotoBrowser

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        browser = [[LongPhotoBrowser alloc] init];
    });
    return browser;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)showWithImages:(NSArray*)aImages
{
    [self showWithImages:aImages withIndex:0];
}

- (void)showWithImages:(NSArray*)aImages withIndex:(NSInteger)aIndex
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    LongPhotoViewController *view = [[LongPhotoViewController alloc] initWithCollectionViewLayout:flowLayout];
    view.images = aImages;
    view.index = aIndex;
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootController presentViewController:view animated:YES completion:nil];
}

- (void)showWithUrls:(NSArray*)aUrls
{
    [self showWithUrls:aUrls withIndex:0];
}

- (void)showWithUrls:(NSArray*)aUrls withIndex:(NSInteger)aIndex
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    LongPhotoViewController *view = [[LongPhotoViewController alloc] initWithCollectionViewLayout:flowLayout];
    view.urls = aUrls;
    view.index = aIndex;
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootController presentViewController:view animated:YES completion:nil];
}

@end
