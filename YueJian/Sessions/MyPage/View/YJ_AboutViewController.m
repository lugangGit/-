//
//  YJ_AboutViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/3.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_AboutViewController.h"

@interface YJ_AboutViewController ()

@end

@implementation YJ_AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self setUpView];
    
    [self setNavigation];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"关于乐健", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}


//自定义导航栏返回按钮的方法
- (void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUpView
{
    UIImageView *img = [[UIImageView alloc]init];
    img.layer.cornerRadius = 10;
    img.layer.borderWidth = 1.0;
    img.layer.borderColor =[UIColor clearColor].CGColor;
    img.clipsToBounds = TRUE;//去除边界
    [img setImage:[UIImage imageNamed:@"icon_logo_YueJian"]];
    [self.view addSubview:img];
    
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80);
        make.height.offset(80);
        make.centerX.offset(0);
        make.centerY.offset(-65);
    }];
    
    UILabel *lab = [[UILabel alloc] init];
    [lab setFont:[UIFont systemFontOfSize:13]];
    lab.textColor = MainTextColor;
    lab.text = NSLocalizedString(@"当前版本", nil);
    [self.view addSubview:lab];
    
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(img.mas_bottom).offset(30);
        make.centerX.offset(-20);
    }];
    
    UILabel *version = [[UILabel alloc] init];
    [version setFont:[UIFont systemFontOfSize:13]];
    version.textColor = ThemeColor;
    version.textAlignment = NSTextAlignmentCenter;
    version.text = NSLocalizedString(@"V1.0.0", nil);
    [self.view addSubview:version];
    
    [version mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(img.mas_bottom).offset(30);
        make.centerX.offset(27);
    }];
    
    /*UILabel *copyRightCN = [[UILabel alloc] init];
    [copyRightCN setFont:[UIFont systemFontOfSize:9]];
    copyRightCN.textColor = ThemeColor;
    copyRightCN.text = NSLocalizedString(@"AboutCopyRightCN", nil);
    [self.view addSubview:copyRightCN];
    
    [copyRightCN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-34);
        make.centerX.offset(0);
    }];
    
    UILabel *copyRightEN = [[UILabel alloc] init];
    [copyRightEN setFont:[UIFont systemFontOfSize:8]];
    copyRightEN.textColor = ThemeColor;
    copyRightEN.text = NSLocalizedString(@"AboutCopyRightEN", nil);
    [self.view addSubview:copyRightEN];
    
    [copyRightEN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-18);
        make.centerX.offset(0);
    }];*/
    
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
