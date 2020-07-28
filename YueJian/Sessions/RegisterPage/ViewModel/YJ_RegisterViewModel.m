//
//  YJ_RegisterViewModel.m
//  YueJian
//
//  Created by Garry on 2018/4/18.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_RegisterViewModel.h"

@implementation YJ_RegisterViewModel

- (instancetype) init
{
    self = [super init];
    if (self) {
        _verificationCommand = [[RACCommand alloc] initWithEnabled:[self validateInputsWithVertificationCode]
                                                       signalBlock:^RACSignal *(id input) {
                                                           return [RACSignal empty];
                                                       }];
        
        _confirmCommand = [[RACCommand alloc] initWithEnabled:[self validateInputsWithPassword]
                                                  signalBlock:^RACSignal *(id input) {
                                                      return [RACSignal empty];
                                                  }];
    }
    
    return self;
}

-(RACSignal *)validateInputsWithVertificationCode
{
    return [RACSignal combineLatest:@[RACObserve(self, userName)] reduce:^id(NSString *userName){
        return @([userName jk_isMobileNumber]);
    }];
}

-(RACSignal *)validateInputsWithPassword
{
    return [RACSignal combineLatest:@[RACObserve(self, userName), RACObserve(self, verificationCode), RACObserve(self, password)] reduce:^id(NSString *userName, NSString *verificationCode, NSString *password){
        //如果验证码是6位
        return @([userName jk_isMobileNumber] && verificationCode.length <= 6 && password.length >= 1 && password.length <= 16);
    }];
  
}

- (void)registerWithSuccessBlock:(YJ_ResponseSuccess)successBlock WithFailureBlock:(YJ_ResponseFail)failureBlock {
    [[YJ_APIManager sharedInstance] postParameters:@{@"phoneNum": self.userName,
                                                     @"password": self.password}
                                           withURL:kRegisterURL
                                  withSuccessBlock:^(id response)
     {
         if ([response[@"code"] isEqual:@0]) {
             NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                   code:errno userInfo:response];
             failureBlock(underlyingError);
         }else
         {
             YJ_UserProfile *user = [[YJ_UserProfile alloc] initWithDictionary:response[@"data"]];
             [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
             [[YJ_APIManager sharedInstance] saveLoggedInStatus];
             ALBBMANAnalytics *man = [ALBBMANAnalytics getInstance];
             [man updateUserAccount:user.phoneNum userid:user.userID];
             successBlock(response);
         }
     } withFailureBlock:^(NSError *error) {
         failureBlock(error);
     } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
     }];
}

- (void)registerUserInfoWithSuccessBlock:(YJ_ResponseSuccess)successBlock WithFailureBlock:(YJ_ResponseFail)failureBlock {
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    NSLog(@"%@,%@,%@,%@", self.nickname, self.sex, self.birthdate, userProfile.userID);
    [[YJ_APIManager sharedInstance] postParameters:@{@"userId": userProfile.userID,
                                                     @"userAvatar": self.avater,
                                                     @"nickName": self.nickname,
                                                     @"sex": self.sex,
                                                     @"birth": self.birthdate}
                                           withURL:kRegisterUserInfoURL
                                  withSuccessBlock:^(id response)
     {
         if ([response[@"code"] isEqual:@0]) {
             NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                   code:errno userInfo:response];
             failureBlock(underlyingError);
         }else
         {
             [[YJ_APIManager sharedInstance] saveProfile:response[@"data"]];
             successBlock(response);
         }
     } withFailureBlock:^(NSError *error) {
         failureBlock(error);
     } withProgress:^(int64_t bytesProgress, int64_t totalBytesProgress) {
     }];
}

- (void)registerPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock WithFailureBlock:(YJ_ResponseFail)failureBlock {
    NSLog(@"%@, %@", self.plan, self.finishDate);
    YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
    [[YJ_APIManager sharedInstance] postParameters:@{@"userId": userProfile.userID,
                                                     @"planContent": self.plan,
                                                     @"finishDate":self.finishDate,
                                                     @"currentImage": self.currentImage,
                                                     @"finishImage": @""}
                                           withURL:kPlanPostEditURL
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
