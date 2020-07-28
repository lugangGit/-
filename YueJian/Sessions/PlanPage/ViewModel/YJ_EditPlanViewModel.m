//
//  YJ_EditPlanViewModel.m
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_EditPlanViewModel.h"

@implementation YJ_EditPlanViewModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        _ConfirmCommand = [[RACCommand alloc] initWithEnabled:[self validateInputs]
                                                  signalBlock:^RACSignal *(id input) {
                                                      return [RACSignal empty];
                                                  }];
    }
    
    return self;
}

-(RACSignal *)validateInputs
{
    return [RACSignal combineLatest:@[RACObserve(self, myTarget), RACObserve(self, finsihDate)] reduce:^id(NSString *myTarget, NSString *finsihDate){
        NSLog(@"myTarget:%@,finsihDate:%@", myTarget,finsihDate);
        return @(myTarget.length > 0 && myTarget.length <= 50  && finsihDate.length > 0);
    }];
}

- (void)handlerGetTargetPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
   WithFailureBlock:(YJ_ResponseFail)failureBlock {
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

- (void)handlerPostHeaderPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                             WithFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    NSLog(@"img64:%@", self.finsihImage);
    [[YJ_APIManager sharedInstance] postParameters:@{@"userId":userProfile.userID,
                                                     @"planContent": self.myTarget,
                                                     @"finishDate": self.finsihDate,
                                                     @"currentImage": self.currentImage,
                                                     @"finishImage": self.finsihImage
                                                     }
                                           withURL:kPlanPostEditURL
      withSuccessBlock:^(id response) {
          //判断请求是否成功
          if ([response[@"result"] isEqual:@0]) {
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
