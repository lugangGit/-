//
//  YJ_SplashViewController.m
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_SplashViewController.h"

@interface YJ_SplashViewController ()

@end

@implementation YJ_SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(dismissProgressView) withObject:nil afterDelay:0];
}

- (void)didReceeMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissProgressView {
    [YJ_SplashViewController changeRootVCToMain];
}

+ (void)changeRootVCToMain
{
    //TODO: 进入首页
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Tabbar" bundle:[NSBundle mainBundle]];
    [UIApplication sharedApplication].delegate.window.rootViewController = mainSB.instantiateInitialViewController;
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
