//
//  YJ_LoginViewMode.h
//  YueJian
//
//  Created by Garry on 2018/4/12.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_LoginViewModel : YJ_BaseModel

@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *password;
@property(readonly, strong) RACCommand *loginCommand;
@property(nonatomic, copy) NSString *phoneNumber;

- (void)loginWithSuccessBlock:(YJ_ResponseSuccess)successBlock
            WithFailureBlock:(YJ_ResponseFail)failureBlock;

@end
