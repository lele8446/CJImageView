//
//  ViewController.m
//  CJImageView
//
//  Created by C.K.Lian on 15/12/30.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import "ViewController.h"
#import "CJImageView.h"
#import "CJHttpClient.h"
#import "CJImageViewCache.h"

#define loadUrl @"http://mrobot.pcauto.com.cn/v2/cms/channels/1?pageNo=1&pageSize=400&v=4.0.0"
#define DECODE YES

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, weak)IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *tableArray;

@property(nonatomic, weak)IBOutlet UILabel *cacheLabel;
@property(nonatomic, weak)IBOutlet UISwitch *switchView;
@property(nonatomic)BOOL imgBool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableArray = [NSMutableArray arrayWithCapacity:4];
    self.imgBool = YES;
    self.switchView.on = NO;
    
    [self loadData];
    self.cacheLabel.text = [NSString stringWithFormat:@"缓存大小:%@M",@([[CJImageViewCache sharedImageCache]getCacheCapacity])];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    __weak typeof(self) wSelf = self;
    [CJHttpClient getUrl:loadUrl parameters:nil timeoutInterval:HTTP_DEFAULT_TIMEOUT cachPolicy:CJRequestReturnCacheDataElseLoad completionHandler:^(NSData *data, NSURLResponse *response){
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        [wSelf.tableArray addObjectsFromArray:dic[@"data"]];
        [wSelf.tableView reloadData];
    }errorHandler:^(NSError *error){
        
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableViewCell = @"tableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:tableViewCell];
        CJImageView *img = [[CJImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 70)];
        [cell.imageView addSubview:img];
        img.tag = [@"img" hash];
    }
    
    cell.imageView.frame = CGRectMake(10, 5, 120, 70);
    cell.imageView.image = [self createImageWithColor:[UIColor clearColor] width:cell.imageView.frame.size.width height:cell.imageView.frame.size.height];
    cell.textLabel.text = self.tableArray[indexPath.row][@"title"];

    CJImageView *img = (CJImageView *)[cell.imageView viewWithTag:[@"img" hash]];
    if (img != nil) {
        img.image = [self createImageWithColor:[UIColor clearColor] width:cell.imageView.frame.size.width height:cell.imageView.frame.size.height];
    }else{
        CJImageView *img = [[CJImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 70)];
        [cell.imageView addSubview:img];
        img.tag = [@"img" hash];
    }

    
    //滑动期间不加载图片
    if (self.switchView.on) {
        if (!tableView.dragging && !tableView.decelerating)
        {
            for (UIView *view in cell.imageView.subviews) {
                if (view.tag == [@"img" hash]) {
                    CJImageView *img = (CJImageView *)view;
                    [img setUri:self.tableArray[indexPath.row][@"image"] defaultImage:[self createImageWithColor:[UIColor colorWithRed:0.3814 green:0.479 blue:1.0 alpha:1.0] width:cell.imageView.frame.size.width height:cell.imageView.frame.size.height] showIndicator:YES style:UIActivityIndicatorViewStyleWhite decoded:DECODE];
                }
            }
        }
    }else{
        for (UIView *view in cell.imageView.subviews) {
            if (view.tag == [@"img" hash]) {
                CJImageView *img = (CJImageView *)view;
                [img setUri:self.tableArray[indexPath.row][@"image"] defaultImage:[self createImageWithColor:[UIColor colorWithRed:0.3814 green:0.479 blue:1.0 alpha:1.0] width:cell.imageView.frame.size.width height:cell.imageView.frame.size.height] showIndicator:YES style:UIActivityIndicatorViewStyleWhite decoded:DECODE];
            }
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self getCellInTableView:self.tableView IndexPathForRow:indexPath.row inSection:indexPath.section];
    for (UIView *view in cell.imageView.subviews) {
        if (view.tag == [@"img" hash]) {
            CJImageView *img = (CJImageView *)view;
            [img setUri:self.tableArray[indexPath.row][@"image"] defaultImage:[self createImageWithColor:[UIColor colorWithRed:0.3814 green:0.479 blue:1.0 alpha:1.0] width:cell.imageView.frame.size.width height:cell.imageView.frame.size.height] showIndicator:YES style:UIActivityIndicatorViewStyleWhite decoded:DECODE];
        }
    }
}

//获取指定cell
- (UITableViewCell *)getCellInTableView:(UITableView *)tableView IndexPathForRow:(NSInteger)row inSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
}

// 滚动停止的时候再去获取image的信息来显示在UITableViewCell上
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate && self.switchView.on){
//        [self loadImagesForOnScreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.switchView.on) {
//        [self loadImagesForOnScreenRows];
    }
    self.cacheLabel.text = [NSString stringWithFormat:@"缓存大小:%@M",@([[CJImageViewCache sharedImageCache]getCacheCapacity])];
}

//加载视图内cell的图片
- (void)loadImagesForOnScreenRows
{
    if([self.tableArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for(NSIndexPath *indexPath in visiblePaths)
        {
            UITableViewCell *cell = [self getCellInTableView:self.tableView IndexPathForRow:indexPath.row inSection:indexPath.section];
            for (UIView *view in cell.imageView.subviews) {
                if (view.tag == [@"img" hash]) {
                    CJImageView *img = (CJImageView *)view;
                    [img setUri:self.tableArray[indexPath.row][@"image"] defaultImage:[self createImageWithColor:[UIColor colorWithRed:0.3814 green:0.479 blue:1.0 alpha:1.0] width:cell.imageView.frame.size.width height:cell.imageView.frame.size.height] showIndicator:YES style:UIActivityIndicatorViewStyleWhite decoded:DECODE];
                }
            }
        }
    }
}

- (IBAction)switchClick:(UISwitch *)sender{

}

- (IBAction)clearCache:(id)sender
{
    [CJHttpClient removeAllCachedResponses];
    [[CJImageViewCache sharedImageCache] clearAllCache];
    self.cacheLabel.text = [NSString stringWithFormat:@"缓存大小:%@M",@([[CJImageViewCache sharedImageCache]getCacheCapacity])];
}

- (IBAction)clearUrlCache:(id)sender
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for(NSIndexPath *indexPath in visiblePaths)
    {
        [[CJImageViewCache sharedImageCache]clearWithUri:self.tableArray[indexPath.row][@"image"]];
    }
    self.cacheLabel.text = [NSString stringWithFormat:@"缓存大小:%@M",@([[CJImageViewCache sharedImageCache]getCacheCapacity])];
}

/**
 *  生成纯色图片
 *
 *  @param color
 *  @param width
 *  @param height
 *
 *  @return
 */
- (UIImage *)createImageWithColor:(UIColor *)color width:(CGFloat)width height:(CGFloat)height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
