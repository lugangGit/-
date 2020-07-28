//
//  YJ_HealthKitManage.h
//  YueJian
//
//  Created by LG on 2018/4/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <UIKit/UIDevice.h>

#define HKVersion [[[UIDevice currentDevice] systemVersion] doubleValue]
#define CustomHealthErrorDomain @"com.sdqt.healthError"

@interface YJ_HealthKitManage : NSObject

+ (id)shareInstance;

- (void)authorizeHealthKit:(void(^)(BOOL success, NSError *error))compltion;

- (void)getStepCount:(void(^)(double stepValue, double timeValue, NSError *error))completion;

- (void)getDistance:(void(^)(double value, NSError *error))completion;

@property (nonatomic, strong) HKHealthStore *healthStore;

@end
