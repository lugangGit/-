//
//  YJ_MyViewController.m
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_MyViewController.h"
#import "YJ_UserProfile.h"
#import "YJ_APIManager.h"
#import "YJ_LoginViewController.h"
#import "YJ_FeedbackViewController.h"
#import "YJ_MessageCenterViewController.h"
#import "YJ_FeedbackViewController.h"

#define USER_AVATARG_HEIGHT 88.0

@interface YJ_MyViewController ()<UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *arrOfData;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) YJ_UserProfile *userProfile;
@property (nonatomic, strong) UIImageView *imgAvatar;
@property (nonatomic, strong) UILabel *labNickName;

@end

@implementation YJ_MyViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [self isLogin];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initArrayData];
    [self drawTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    //更新数据
    if([[YJ_APIManager sharedInstance] isLoggedIn])
    {
        UIImage *img = self.imgAvatar.image;
        self.userProfile = [[YJ_APIManager sharedInstance] readProfile];
        [self.imgAvatar setImageWithURL:[NSURL URLWithString:self.userProfile.userAvatar] placeholderImage:img];
        self.labNickName.text = self.userProfile.nickName;
    }
}

- (void)viewWillDisappear:(BOOL)animate {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)isLogin {
    //判断用户是否在登录状态，如果登录，读取用户信息
    if([[YJ_APIManager sharedInstance] isLoggedIn])
    {
        self.userProfile = [[YJ_APIManager sharedInstance] readProfile];
        [self.imgAvatar setImageWithURL:[NSURL URLWithString:self.userProfile.userAvatar] placeholderImage:[UIImage imageNamed:@"icon_register_header"]];
        self.labNickName.text = self.userProfile.nickName;
    }else {
        self.labNickName.text = NSLocalizedString(@"Click Login", nil);
        [self.imgAvatar setImage:[UIImage imageNamed:@"icon_register_header"]];
    }
}

#pragma mark init table view datasources
- (void)initArrayData
{
    self.arrOfData = @[
                       @[
                           @{@"iconImage":@"icon_me_info",
                             @"description":NSLocalizedString(@"个人信息", nil),
                             @"arrowImage":@"icon_list_arrow"},
                           @{@"iconImage":@"icon_me_repair",
                             @"description":NSLocalizedString(@"商务合作",nil),
                             @"arrowImage":@"icon_list_arrow"},
                           @{@"iconImage":@"icon_me_feedback",
                               @"description":NSLocalizedString(@"意见反馈",nil),
                               @"arrowImage":@"icon_list_arrow"},
                           @{@"iconImage":@"icon_me_setting",
                             @"description":NSLocalizedString(@"设置",nil),
                             @"arrowImage":@"icon_list_arrow"},
                           ],
                       ];
    
}

#pragma mark - draw table view
- (void)drawTableView
{
    [self.view addSubview:self.myTableView];
    self.myTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
    //解决headerView的子视图无法响应交互
    self.myTableView.tableHeaderView.userInteractionEnabled = YES;
}

- (UITableView *)myTableView
{
    if (!_myTableView) {
        //状态栏
        int rectStatus = [[UIApplication sharedApplication] statusBarFrame].size.height;
        //导航栏
        int rectNav = self.navigationController.navigationBar.frame.size.height;
        NSLog(@"head%d", rectStatus + rectNav);
        if ((rectStatus + rectNav) == 88) {
           _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -50, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        }else {
            _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        }
        [_myTableView setDelegate:self];
        [_myTableView setDataSource:self];
        [_myTableView setRowHeight:50];
        [_myTableView setBackgroundColor:TableViewBGColor];
        _myTableView.tableHeaderView = [self setUpHeadView];
    }
    return _myTableView;
}

- (UIView *)setUpHeadView
{
    //CGFloat headerHeight = (CGFloat) SCREEN_WIDTH * (217.0/320.0);
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH-60)];
    [headerView setUserInteractionEnabled:YES];
    headerView.image = [UIImage imageNamed:@"img_my_header"];
    
    self.imgAvatar = [[UIImageView alloc] init];
    self.imgAvatar.backgroundColor = [UIColor whiteColor];
    self.imgAvatar.layer.masksToBounds = YES;
    self.imgAvatar.layer.cornerRadius = USER_AVATARG_HEIGHT/2;
    self.imgAvatar.layer.borderWidth = 1.0;
    [self.imgAvatar setUserInteractionEnabled:YES];
    self.imgAvatar.layer.borderColor = AvatarCycleCGColor;
    [headerView addSubview:self.imgAvatar];
    
    self.labNickName = [[UILabel alloc]init];
    self.labNickName.textAlignment = NSTextAlignmentCenter;
    self.labNickName.font = [UIFont systemFontOfSize:19.0];
    self.labNickName.textColor = [UIColor whiteColor];
    [headerView addSubview:self.labNickName];
    
    [self.imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.centerY.offset(0);
        make.width.height.offset(USER_AVATARG_HEIGHT);
    }];
    
    [self.labNickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(50);
        make.right.offset(-50);
        make.top.equalTo(self.imgAvatar.mas_bottom).with.offset(20);
    }];
    
    //添加点击事件
    self.imgAvatar.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPersonInfo:)];
    [self.imgAvatar addGestureRecognizer:singleTap];
    
    UIButton *btnMessage = [[UIButton alloc] init];
    [btnMessage setImage:[UIImage imageNamed:@"icon_my_message"] forState:UIControlStateNormal];
    //btnMessage.backgroundColor = ThemeColor;
    [headerView addSubview:btnMessage];
    
    //状态栏
    int rectStatus = [[UIApplication sharedApplication] statusBarFrame].size.height;
    //导航栏
    int rectNav = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"head%d", rectStatus + rectNav);
    //根据导航栏高度适配iphoneX
    if ((rectStatus + rectNav) == 64) {
        //初始化tableview
        [btnMessage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(20);
            make.right.offset(-10);
            make.width.height.offset(40);
        }];
    }else {
        [btnMessage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(50);
            make.right.offset(-10);
            make.width.height.offset(40);
        }];
    }

    [[btnMessage rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        YJ_MessageCenterViewController *meVc = [[YJ_MessageCenterViewController alloc] init];
        [self.navigationController pushViewController:meVc animated:YES];
    }];
    
    return headerView;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//[self.arrOfData count]
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.arrOfData objectAtIndex:section] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    if(![[YJ_APIManager sharedInstance] isLoggedIn]) {
                        //还未登陆
                        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
                        YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
                        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
                        [self presentViewController:navc animated:YES completion:nil];
                        loginVC.callback = ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self dismissViewControllerAnimated:NO completion:nil];
                                if([[YJ_APIManager sharedInstance] isLoggedIn])
                                {
                                    [self performSegueWithIdentifier:@"MyInfoPage" sender:nil];

                                }
                            });
                        };
                    }else {
                        [self performSegueWithIdentifier:@"MyInfoPage" sender:nil];
                    }
                }
                    break;
                case 1:
                {
                    // 判断手机是否安装QQ
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
                        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                        NSString *QQ = @"1136516965";
                        NSString *openQQStr = [NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", QQ];
                        NSURL *url = [NSURL URLWithString:openQQStr];
                        NSURLRequest *request = [NSURLRequest requestWithURL:url];
                        [webView loadRequest:request];
                        [self.view addSubview:webView];
                    }else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"你没有安装手机QQ，请安装手机QQ后重试。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [alertView show];
                    }
                }
                    break;
                case 2:
                {
                    YJ_FeedbackViewController *FBVC = [[YJ_FeedbackViewController alloc] init];
                    FBVC.callback = ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    };
                    [self.navigationController pushViewController:FBVC animated:YES];
                }
                    break;
                case 3:
                {
                    [self performSegueWithIdentifier:@"SetPage" sender:nil];
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

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //注册cell
    static NSString *cellIde = @"cellIde";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    //设置cell的样式，带右侧小箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //绘制cell 统一的图标和描述标签
    UIImageView *iconImageView = [[UIImageView alloc] init];
    [cell addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(20);
        make.left.offset(22);
        make.centerY.offset(0);
    }];
    UILabel *labDescription = [[UILabel alloc]init];
    labDescription.font = [UIFont systemFontOfSize:16.0];
    labDescription.textAlignment = NSTextAlignmentLeft;
    labDescription.textColor = MainTextColor;
    [cell addSubview:labDescription];
    
    [labDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImageView.mas_right).with.offset(15);
        make.centerY.offset(0);
    }];
    
    if(indexPath.section == 0){
        iconImageView.image = [UIImage imageNamed:self.arrOfData[indexPath.section][indexPath.row][@"iconImage"]];
        labDescription.text = self.arrOfData[indexPath.section][indexPath.row][@"description"];
    }else {
        iconImageView.image = [UIImage imageNamed:self.arrOfData[indexPath.section][indexPath.row][@"iconImage"]];
        labDescription.text = self.arrOfData[indexPath.section][indexPath.row][@"description"];
    }
    return cell;
}
#pragma mark - setUpHeightForHeaderAndFooter
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else if(section == 1) {
        return 8;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - Edit Personal Info
-(void)editPersonInfo:(UITapGestureRecognizer *)sender
{
    if([[YJ_APIManager sharedInstance] isLoggedIn])
    {
        //登录后逻辑
    }
    else
    {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
        YJ_LoginViewController *loginVC = [mainSB instantiateViewControllerWithIdentifier:@"LoginPage"];
        //登录成功
        loginVC.callback = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                if ([[YJ_APIManager sharedInstance] isLoggedIn]) {
                    //登录后逻辑
                    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
                }
            });
        };
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navc animated:YES completion:nil];
    }
}

//解决tableview和gesture手势冲突
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCell"] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]) {
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
