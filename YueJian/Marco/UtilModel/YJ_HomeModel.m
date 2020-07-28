//
//  YJ_HomeModel.m
//  YueJian
//
//  Created by LG on 2018/4/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_HomeModel.h"

@implementation YJ_HomeModel

- (instancetype)initWeatherWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _location = dictionary[@"basic"][@"location"];
        _condCode = dictionary[@"now"][@"cond_code"];
        _condText = dictionary[@"now"][@"cond_txt"];
        _temperature = dictionary[@"now"][@"fl"];
    }
    return self;
}

- (instancetype)initAirQualityWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _airQuality = dictionary[@"air_now_city"][@"qlty"];
    }
    return self;
}

@end
