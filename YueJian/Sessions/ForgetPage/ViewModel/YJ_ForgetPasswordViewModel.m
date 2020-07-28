//
//  YJ_ForgetPasswordViewModel.m
//  YueJian
//
//  Created by Garry on 2018/4/19.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_ForgetPasswordViewModel.h"

@implementation YJ_ForgetPasswordViewModel
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

- (void)forgetPasswordWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                      WithFailureBlock:(YJ_ResponseFail)failureBlock {
    [[YJ_APIManager sharedInstance] putParameters:@{
                                                    @"phoneNum": self.userName,
                                                    @"newPwd": self.password
                                                   }
                                           withURL:kForgotPasswordURL
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
