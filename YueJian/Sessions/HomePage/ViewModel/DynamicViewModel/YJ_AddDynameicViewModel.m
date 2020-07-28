//
//  YJ_AddDynameicViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_AddDynameicViewModel.h"

@implementation YJ_AddDynameicViewModel

-(void)getDynameicDataWithPageNumber:(NSString *)pageNumber
             withSuccessBlock:(YJ_ResponseSuccess)successBlock
             withFailureBlock:(YJ_ResponseFail)failureBlock {
    NSLog(@"%@, %d", @"1", [pageNumber intValue]*10);
    [[YJ_APIManager sharedInstance] getParameters:nil withURL:[NSString stringWithFormat:@"%@?pageIndex=%@&pageSize=%d", kHomeGetDynameicURL, @"1", [pageNumber intValue]*10]
      withSuccessBlock:^(id response) {
          if ([response[@"code"] isEqual:@0]) {
              NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:response];
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

- (void)postDynameicWithContent:(NSString *)content withImage:(NSMutableArray *)imageArray withCity:(NSString *)city withSuccessBlock:(YJ_ResponseSuccess)successBlock withFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] postParameters:@{
                                                     @"userId":userProfile.userID,
                                                     @"dynamicContent":content,
                                                     @"dynamicImage":imageArray,
                                                     @"position":city
                                                    }
    withURL:kHomePostDynameicURL
    withSuccessBlock:^(id response) {
        if ([response[@"code"] isEqual:@0]) {
            NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:response];
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

- (void)deleteDynameicWithDynameicId:(NSString *)dynameicId
                        withSuccessBlock:(YJ_ResponseSuccess)successBlock
                        withFailureBlock:(YJ_ResponseFail)failureBlock {
    NSLog(@"%@", dynameicId);
    [[YJ_APIManager sharedInstance] deleteParameters:nil
      withURL:[NSString stringWithFormat:@"%@%@", kHomeDeleteDynameicURL, dynameicId] withSuccessBlock:^(id response) {
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
