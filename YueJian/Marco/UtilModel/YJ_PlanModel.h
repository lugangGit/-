//
//  YJ_PlanModel.h
//  YueJian
//
//  Created by Garry on 2018/8/8.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJ_PlanModel : NSObject
//倒计时
@property(nonatomic, copy) NSString *dateCount;
//当前倒计时
@property(nonatomic, copy) NSString *countDownCurrent;
//时间
@property(nonatomic, copy) NSString *finishDate;
//目标
@property(nonatomic, copy) NSString *planContent;
//当前照片
@property(nonatomic, copy) NSString *currentPhoto;
//完成照片
@property(nonatomic, copy) NSString *finishPhoto;

//运动计划ID
@property(nonatomic, copy) NSString *planId;
//运动时间类型 早晨
@property(nonatomic, copy) NSString *playTimeType;
//运动时间段
@property(nonatomic, copy) NSString *playTime;
//运动类型
@property(nonatomic, copy) NSString *playType;
//饮食计划
@property(nonatomic, copy) NSString *eatPlan;

- (instancetype)initPlanHeaderWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initPlanContentWithDictionary:(NSDictionary *)dictionary;

@end
