//
//  YJ_MytargetViewModel.m
//  YueJian
//
//  Created by Garry on 2018/4/27.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_MytargetViewModel.h"

@implementation YJ_MytargetViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _confirmCommand = [[RACCommand alloc] initWithEnabled:[self validateInputs]
                                                signalBlock:^RACSignal *(id input) {
                                                    return [RACSignal empty];
                                                }];
    }
    
    return self;
}

- (RACSignal *)validateInputs
{
    return [RACSignal combineLatest:@[RACObserve(self, step)] reduce:^id(NSString *step){
        return @(step.length >= 4 && step.length <= 6);
    }];
}

- (void)targetStepWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                  WithFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] putParameters:@{@"userId": userProfile.userID,
                                                     @"targetStep": self.step}
                                           withURL:kHomePostTargetURL
                                  withSuccessBlock:^(id response)
     {
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

@end
