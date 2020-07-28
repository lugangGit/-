//
//  YJ_HomeViewModel.m
//  YueJian
//
//  Created by LG on 2018/4/10.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_HomeViewModel.h"

@implementation YJ_HomeViewModel

- (void)handlerGetHomeWeatherData:(NSString *)location withSuccessBlock:(YJ_ResponseSuccess)successBlock
                             withFailureBlock:(YJ_ResponseFail)failureBlock
{
    [[YJ_APIManager sharedInstance] getWeatherParameters:nil
                                          withURL:[NSString stringWithFormat:@"/weather/now?location=%@&key=%@", location, kWeatherAPIKey]
                                  withSuccessBlock:^(id response)
     {
         if ([response[@"result"] isEqual:@0]) {
             NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                   code:errno userInfo:response];
             failureBlock(underlyingError);
         }else
         {
             successBlock(response);
         }
     } withFailureBlock:^(NSError *error) {
         failureBlock(error);
     } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
     }];
}

- (void)handlerGetHomeAirQualityData:(NSString *)location withSuccessBlock:(YJ_ResponseSuccess)successBlock
                withFailureBlock:(YJ_ResponseFail)failureBlock
{
    [[YJ_APIManager sharedInstance] getWeatherParameters:nil
                                                 withURL:[NSString stringWithFormat:@"/air/now?location=%@&key=%@", location, kWeatherAPIKey]
                                        withSuccessBlock:^(id response)
     {
         if ([response[@"result"] isEqual:@0]) {
             NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                   code:errno userInfo:response];
             failureBlock(underlyingError);
         }else
         {
             successBlock(response);
         }
     } withFailureBlock:^(NSError *error) {
         failureBlock(error);
     } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
     }];
}

- (void)handlerGetHomeTargetStepDataWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                    withFailureBlock:(YJ_ResponseFail)failureBlock
{
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] getParameters:nil
                                          withURL:[NSString stringWithFormat:@"%@%@", kHomeGetTargetURL, userProfile.userID]
                                        withSuccessBlock:^(id response)
     {
         if ([response[@"result"] isEqual:@0]) {
             NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                         code:errno userInfo:response];
             failureBlock(underlyingError);
         }else
         {
             successBlock(response);
         }
     } withFailureBlock:^(NSError *error) {
         failureBlock(error);
     } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
     }];
}

@end
