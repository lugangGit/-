//
//  YJ_HomeViewController.h
//  YueJian
//
//  Created by LG on 2018/5/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseViewController.h"
#import <HealthKit/HealthKit.h>

@interface YJ_HomeViewController : YJ_BaseViewController

@property (nonatomic,strong) HKHealthStore *healthStore;

@end
