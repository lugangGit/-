//
//  YJ_PlanModel.m
//  YueJian
//
//  Created by Garry on 2018/8/8.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_PlanModel.h"

@implementation YJ_PlanModel

- (instancetype)initPlanHeaderWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _dateCount = dictionary[@"countDownTotal"];
        _countDownCurrent = dictionary[@"countDownCurrent"];
        _finishDate = dictionary[@"finishDateStr"];
        _planContent = dictionary[@"planContent"];
        _currentPhoto = dictionary[@"currentImage"];
        _finishPhoto = dictionary[@"finishImage"];
    }
    
    return self;
}

- (instancetype)initPlanContentWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _planId = dictionary[@"id"];
        _playTimeType = dictionary[@"playTimeType"];
        _playTime = dictionary[@"playTime"];
        _playType = dictionary[@"playType"];
        _eatPlan = dictionary[@"eatPlan"];
    }
    
    return self;
}

@end
