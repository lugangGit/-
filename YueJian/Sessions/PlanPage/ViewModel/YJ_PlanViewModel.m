//
//  YJ_PlanViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/8.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_PlanViewModel.h"

@implementation YJ_PlanViewModel

- (void)handlerGetHeaderPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] getParameters:nil
                                                 withURL:[NSString stringWithFormat:@"%@%@", kPlanGetEditURL, userProfile.userID]
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

- (void)handlerGetCellPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                            withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] getParameters:nil
                                          withURL:[NSString stringWithFormat:@"%@%@", kPlanGetAddURL, userProfile.userID]
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

- (void)deletePlanWithPlanId:(NSString *)planId
               withSuccessBlock:(YJ_ResponseSuccess)successBlock
               withFailureBlock:(YJ_ResponseFail)failureBlock
{
     NSLog(@"%@", planId);
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] deleteParameters:@{
                                                       @"planId":planId
                                                      }
    withURL:kPlanDeleteAddURL withSuccessBlock:^(id response) {
        //判断请求是否成功
        if ([response[@"code"] isEqual:@0]) {
            //没有数据，进行异常处理
            NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:response];
            failureBlock(underlyingError);
        }else
        {
            successBlock(response);
        }
    } withFailureBlock:^(NSError *error) {
        //请求失败
        failureBlock(error);
    } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
    }];
}


@end
