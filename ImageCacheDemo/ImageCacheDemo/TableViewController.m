//
//  TableViewController.m
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "TableViewController.h"

#import "LongCache.h"
#import "UIImageView+LongCache.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface TableViewController ()
{
    NSArray *_datasource;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _datasource = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073238182&di=9c3f0b5e4d272bd7ed17cf9ecc3501e9&imgtype=jpg&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Ff2deb48f8c5494eeb4f77dd924f5e0fe98257e1c.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073219291&di=a24a7e931f459b4b45683eda29d0fbcc&imgtype=0&src=http%3A%2F%2Fzxpic.imtt.qq.com%2Fzxpic_imtt%2F2016%2F09%2F15%2Foriginalimage%2F131534_2944753022_12_600_466.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073219290&di=486b69b00ce2120a7d3fe206c782d534&imgtype=0&src=http%3A%2F%2Fzxpic.imtt.qq.com%2Fzxpic_imtt%2F2016%2F09%2F15%2Foriginalimage%2F131534_2944753022_15_600_395.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073219290&di=a302de76ffcda85d9925e778b285684e&imgtype=0&src=http%3A%2F%2Fimg.bimg.126.net%2Fphoto%2FiHzmO2LxsrAHF3rmU5KMIg%3D%3D%2F3121557491737988767.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506078640080&di=de5e56b9c829e1cbcd0a876912b0db96&imgtype=jpg&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F18d8bc3eb13533fad89aeaeea1d3fd1f40345bc5.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073238182&di=9c3f0b5e4d272bd7ed17cf9ecc3501e9&imgtype=jpg&src=http%3A%2F%2Fe.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2Ff2deb48f8c5494eeb4f77dd924f5e0fe98257e1c.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073219291&di=a24a7e931f459b4b45683eda29d0fbcc&imgtype=0&src=http%3A%2F%2Fzxpic.imtt.qq.com%2Fzxpic_imtt%2F2016%2F09%2F15%2Foriginalimage%2F131534_2944753022_12_600_466.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073219290&di=486b69b00ce2120a7d3fe206c782d534&imgtype=0&src=http%3A%2F%2Fzxpic.imtt.qq.com%2Fzxpic_imtt%2F2016%2F09%2F15%2Foriginalimage%2F131534_2944753022_15_600_395.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506073219290&di=a302de76ffcda85d9925e778b285684e&imgtype=0&src=http%3A%2F%2Fimg.bimg.126.net%2Fphoto%2FiHzmO2LxsrAHF3rmU5KMIg%3D%3D%2F3121557491737988767.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1506078640080&di=de5e56b9c829e1cbcd0a876912b0db96&imgtype=jpg&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fimage%2Fpic%2Fitem%2F18d8bc3eb13533fad89aeaeea1d3fd1f40345bc5.jpg",
                    @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507717762475&di=8e388d038a3a65469db35e53a9b45743&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01a9f35542a2430000019ae979d241.jpg"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_datasource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];
    }
    NSString *url = [_datasource objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageNamed:@"imageDownloadFail"];
    [cell.imageView setImageWithUrl:url placeholderImage:image toDisk:NO showActivityView:YES];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.f;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
