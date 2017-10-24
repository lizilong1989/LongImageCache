//
//  LongPhotoBrowser.m
//  Pods
//
//  Created by zilong.li on 2017/10/24.
//

#import "LongPhotoBrowser.h"

#import "UIImageView+LongCache.h"

static LongPhotoBrowser *browser = nil;

@interface LongCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LongCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageView.frame = self.bounds;
}

@end

@interface LongPhotoViewController : UICollectionViewController <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, assign) NSInteger index;

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)];
    [self.collectionView addGestureRecognizer:tap];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
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
    if (!cell) {
        
    }
    [cell sizeToFit];
    cell.imageView.image = nil;
    if ([_images count] > 0) {
        cell.imageView.image = [_images objectAtIndex:indexPath.row];
    }
    
    if ([_urls count] > 0) {
        [cell.imageView setImageWithUrl:[_urls objectAtIndex:indexPath.row]];
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
