//
//  YJ_BodyProfile.m
//  YueJian
//
//  Created by LG on 2018/5/15.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BodyProfile.h"

@implementation YJ_BodyProfile
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _height = dictionary[@"height"];
        _weight = dictionary[@"weight"];
        _bust = dictionary[@"bust"];
        _waist = dictionary[@"waist"];
        _hip = dictionary[@"hip"];
        _fatRate = dictionary[@"fatRate"];
        _targetStep = dictionary[@"targetStep"];

    }
    
    return self;
}
@end
