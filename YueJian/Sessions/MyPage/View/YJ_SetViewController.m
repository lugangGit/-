//
//  YJ_SetViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_SetViewController.h"
#import "YJ_AboutViewController.h"
#import "YJ_UserProfile.h"
#import "YJ_APIManager.h"
#import <SDWebImage/SDImageCache.h>

@interface YJ_SetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *infoTableView;
@property (nonatomic, strong) NSArray *arrOfData;
@property (nonatomic, strong) NSString *messageCache;
@end

@implementation YJ_SetViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGColor;
    
    //导航栏返回按钮
    [self setNavigation];
    
    [self setUpTableView];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"设置", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - setUpView
- (void)setUpTableView
{
    _infoTableView = [[UITableView alloc]init];
    _infoTableView.backgroundColor = BGColor;
    [_infoTableView setDelegate:self];
    [_infoTableView setDataSource:self];
    _infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.infoTableView];
    
    [_infoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
}

#pragma mark - initDataSource
- (NSArray *)arrOfData
{
    if (!_arrOfData) {
        _arrOfData =@[
                       @[@{@"iconImage":@"icon_set_delete",
                           @"description":NSLocalizedString(@"清除缓存",nil),
                           @"info":NSLocalizedString(@"NotSet",nil)}],
                       @[@{@"iconImage":@"icon_set_about", @"description":NSLocalizedString(@"关于乐健",nil)}]
                     ];
    }
    return _arrOfData;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrOfData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.arrOfData objectAtIndex:section] count];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //注册cell
    static NSString *cellIde = @"cellIde";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    //在第一个分组中，每个cell的公共部分，图标和描述信息
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    [cell.contentView addSubview:iconImageView];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(20);
        make.left.offset(22);
        make.centerY.offset(0);
    }];
    
    UILabel *labDescription = [[UILabel alloc]init];
    labDescription.font = [UIFont systemFontOfSize:16.0];
    labDescription.textAlignment = NSTextAlignmentLeft;
    labDescription.textColor = MainTextColor;
    [cell.contentView addSubview:labDescription];
    
    [labDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImageView.mas_right).with.offset(15);
        make.centerY.offset(0);
        make.width.offset(90);
    }];
    
    
    UILabel *labInfo = [[UILabel alloc] init];
    labInfo.textAlignment = NSTextAlignmentRight;
    labInfo.textColor = [UIColor jk_colorWithWholeRed:150.0 green:150.0 blue:150.0];
    labInfo.font = [UIFont systemFontOfSize:14.0];
    [cell.contentView addSubview:labInfo];

    [labInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labDescription.mas_right).with.offset(20);
        make.centerY.offset(0);
        make.right.offset(0);
    }];
    


    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    iconImageView.image = [UIImage imageNamed:self.arrOfData[0][indexPath.row][@"iconImage"]];

                    CGFloat size = [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath: [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
                    
                    self.messageCache = size > 1 ? [NSString stringWithFormat:@"%.2fM", size] : [NSString stringWithFormat:@"%.2fK", size * 1024.0];
                    NSLog(@"message %@", self.messageCache);
                    
                    labInfo.text = self.messageCache;
                    labDescription.text = self.arrOfData[0][indexPath.row][@"description"];
                    
                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    iconImageView.image = [UIImage imageNamed:self.arrOfData[1][indexPath.row][@"iconImage"]];
                    labInfo.text = self.arrOfData[1][indexPath.row][@"info"];
                    labDescription.text = self.arrOfData[1][indexPath.row][@"description"];

                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //处理不同cell的点击事件
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"友情提示", nil) message:[NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"确定清除", nil), self.messageCache, NSLocalizedString(@"缓存？", nil)]  preferredStyle:UIAlertControllerStyleAlert];
                    
                    // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
                    UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    }];
                    
                    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [SVProgressHUD show];
                        [self clearCache];
                        CGFloat size = [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject] + [self folderSizeAtPath: [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
                        
                        self.messageCache = size > 1 ? [NSString stringWithFormat:@"%.2fM", size] : [NSString stringWithFormat:@"%.2fK", size * 1024.0];
                        [self.infoTableView reloadData];
                    }];
                    
                    // 3.将“取消”和“确定”按钮加入到弹框控制器中
                    [alertVc addAction:cancle];
                    [alertVc addAction:confirm];
                    
                    // 4.控制器 展示弹框控件，完成时不做操作
                    [self presentViewController:alertVc animated:YES completion:nil];
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    YJ_AboutViewController *avc = [[YJ_AboutViewController alloc] init];
                    [self.navigationController pushViewController:avc animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//针对不同cell，计算不同高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.0;
}

#pragma mark - setUpHeightForHeaderAndFooter
//设置tableview的section的头部和脚部高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

//设置分区尾区域的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

//fooderView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BGColor;
    return view;
}

#pragma mark - 清除缓存
- (NSUInteger)getSize {
    NSUInteger size = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:cachePath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

//计算目录大小
- (CGFloat)folderSizeAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 获取该目录下的文件，计算其大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // 将大小转化为M
        NSLog(@"size%f", size);
        return size / 1024.0 / 1024.0;
    }
    return 0;
}

- (long long)fileSizeAtPath:(NSString*)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(void)clearCache
{
    //彻底清除缓存第一种方法
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"libPath:%@",path);

    NSString *str = [NSString stringWithFormat:@"缓存已清除%.1fM", [self folderSizeAtPath:path]];
    NSLog(@"libStr%@",str);
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    for (NSString *p in files) {
        NSError *error;
        NSString *Path = [path stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
            [[NSFileManager defaultManager] removeItemAtPath:Path error:&error];
        }
    }
    
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"cache:%@",cachePath);
    NSString *cacheStr = [NSString stringWithFormat:@"缓存已清除%.1fM", [self folderSizeAtPath:cachePath]];
    NSLog(@"cacheStr%@",cacheStr);
    
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:cachePath];
    
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    [SVProgressHUD dismiss];
}


#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//处理手势冲突（父类的手势）
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCell"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
