//
//  YJ_SignViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/6.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_SignViewModel.h"

@implementation YJ_SignViewModel

- (void)handlerPostSignData:(NSString *)currentDate withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] postParameters:@{@"userId": userProfile.userID,
                                                     @"signDate": currentDate}
                                           withURL:kHomePostSignURL
                                  withSuccessBlock:^(id response)
     {
         if ([response[@"code"] isEqual:@0]) {
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

- (void)handlerGetSignDataWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                          withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] getParameters:nil
                                                 withURL:[NSString stringWithFormat:@"%@%@", kHomeGetSignURL, userProfile.userID]  
                                        withSuccessBlock:^(id response)
     {
         if ([response[@"code"] isEqual:@0]) {
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
