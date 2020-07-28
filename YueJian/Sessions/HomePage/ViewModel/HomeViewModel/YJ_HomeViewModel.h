//
//  YJ_HomeViewModel.h
//  YueJian
//
//  Created by LG on 2018/4/10.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_HomeViewModel : YJ_BaseModel

-(void)handlerGetHomeWeatherData:(NSString *)location withSuccessBlock:(YJ_ResponseSuccess)successBlock
                                withFailureBlock:(YJ_ResponseFail)failureBlock;

-(void)handlerGetHomeAirQualityData:(NSString *)location withSuccessBlock:(YJ_ResponseSuccess)successBlock
                withFailureBlock:(YJ_ResponseFail)failureBlock;

-(void)handlerGetHomeTargetStepDataWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                   withFailureBlock:(YJ_ResponseFail)failureBlock;

@end
