//
//  YJ_BaseViewController.m
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"
#import <AlicloudMobileAnalitics/ALBBMANPageHitBuilder.h>
#import <AlicloudMobileAnalitics/ALBBMANPageHitHelper.h>

static NSString *const SBStyleRed = @"SBStyleRed";
static NSString *const SBStyleGray = @"SBStyleGray";
static NSString *const SBStyleSuccess = @"SBStyleSuccess";

@interface YJ_BaseViewController ()

@property (nonatomic, strong) ALBBMANPageHitBuilder *pageHitBuilder;

@end

@implementation YJ_BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageHitBuilder = [[ALBBMANPageHitBuilder alloc] init];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.pageHitBuilder setPageName:self.navigationItem.title];
    [[ALBBMANPageHitHelper getInstance] pageAppear:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.pageHitBuilder setPageName:self.navigationItem.title];
    [[ALBBMANPageHitHelper getInstance] pageDisAppear:self];
}

-(void)resignActive
{
    [self.view endEditing:YES];
}

-(void)showStatusWithError:(NSString *)status
{
    [SVProgressHUD showErrorWithStatus:status];
}

-(void)showStatusWithSuccess:(NSString *)status
{
    [SVProgressHUD showSuccessWithStatus:status];
}

-(void)showStatusWithWarnning:(NSString *)status
{
    [SVProgressHUD showInfoWithStatus:status];
}

-(NSString *)returnCurrentMessageWithErrorCode:(NSInteger)errorCode
{
    NSString *stringMessage = [[NSString alloc] init];
    NSString *stringCode = [NSString stringWithFormat:@"%ld", (long)errorCode];
    stringMessage = NSLocalizedString(stringCode, nil);
    return stringMessage;
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
