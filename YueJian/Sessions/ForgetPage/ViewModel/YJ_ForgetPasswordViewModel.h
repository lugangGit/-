//
//  YJ_ForgetPasswordViewModel.h
//  YueJian
//
//  Created by Garry on 2018/4/19.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_ForgetPasswordViewModel : YJ_BaseModel
@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *verificationCode;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *vertificationCodeWithRep;
@property(readonly, strong) RACCommand *verificationCommand;
@property(readonly, strong) RACCommand *confirmCommand;

- (void)forgetPasswordWithSuccessBlock:(YJ_ResponseSuccess)successBlock
             WithFailureBlock:(YJ_ResponseFail)failureBlock;

@end
