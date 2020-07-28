//
//  YJ_HomeModel.h
//  YueJian
//
//  Created by LG on 2018/4/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJ_HomeModel : NSObject

//城市名称
@property (nonatomic,copy) NSString *location;
//实况天气状况代码
@property (nonatomic,copy) NSString *condCode;
//晴
@property (nonatomic,copy) NSString *condText;
//温度
@property (nonatomic,copy) NSString *temperature;
//空气质量
@property (nonatomic,copy) NSString *airQuality;

//解析天气
- (instancetype)initWeatherWithDictionary:(NSDictionary *)dictionary;

//解析空气质量
- (instancetype)initAirQualityWithDictionary:(NSDictionary *)dictionary;

@end
