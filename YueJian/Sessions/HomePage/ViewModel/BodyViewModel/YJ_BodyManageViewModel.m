//
//  YJ_BodyManageViewModel.m
//  YueJian
//
//  Created by LG on 2018/5/16.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BodyManageViewModel.h"

@implementation YJ_BodyManageViewModel

- (void)handlerGetBodyDataSuccessBlock:(YJ_ResponseSuccess)successBlock
                      withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] getParameters:nil
                                                 withURL:[NSString stringWithFormat:@"%@%@", kHomeGetBodyURL, userProfile.userID] 
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

- (void)handlerPostBodyData:(NSMutableDictionary *)dic withSuccessBlock:(YJ_ResponseSuccess)successBlock
           withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [dic setObject:userProfile.userID forKey:@"userId"];
    [[YJ_APIManager sharedInstance] postParameters:dic withURL:kHomePostBodyURL withSuccessBlock:^(id response) {
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
