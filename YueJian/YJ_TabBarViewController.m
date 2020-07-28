//
//  YJ_TabBarViewController.m
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_TabBarViewController.h"
#import "YJ_HomeViewController.h"
#import "YJ_PlanViewController.h"
#import "YJ_MyViewController.h"

@interface YJ_TabBarViewController ()

@end

@implementation YJ_TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置tabbar颜色
    [[UITabBar appearance] setTintColor:ThemeColor];
    //首页
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Tabbar" bundle:[NSBundle mainBundle]];
    
    YJ_HomeViewController *homeVC = [mainSB instantiateViewControllerWithIdentifier:@"homeVC"];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:homeVC];
    nav1.tabBarItem.image = [[UIImage imageNamed:@"tab_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav1.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav1.tabBarItem.title = NSLocalizedString(@"Home", nil);
    nav1.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -5.0);
    
    //计划
    YJ_PlanViewController *planVC = [mainSB instantiateViewControllerWithIdentifier:@"planVC"];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:planVC];
    nav2.tabBarItem.image = [[UIImage imageNamed:@"tab_plan_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav2.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_plan_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav2.tabBarItem.title = NSLocalizedString(@"Plan", nil);
    nav2.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -5.0);
    
    //个人
    YJ_MyViewController *myVC = [mainSB instantiateViewControllerWithIdentifier:@"personalVC"];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:myVC];
    nav3.tabBarItem.image = [[UIImage imageNamed:@"tab_me_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav3.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_me_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav3.tabBarItem.title = NSLocalizedString(@"Personal", nil);
    nav3.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -5.0);
    
    self.viewControllers = @[nav1, nav2, nav3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
