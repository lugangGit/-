//
//  YJ_SplashViewController.h
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"

@interface YJ_SplashViewController : YJ_BaseViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

+(void)changeRootVCToMain;

@end
