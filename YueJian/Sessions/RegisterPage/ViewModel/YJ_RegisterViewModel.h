//
//  YJ_RegisterViewModel.h
//  YueJian
//
//  Created by Garry on 2018/4/18.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_RegisterViewModel : YJ_BaseModel
//注册
@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *verificationCode;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *vertificationCodeWithRep;
@property(readonly, strong) RACCommand *verificationCommand;
@property(readonly, strong) RACCommand *confirmCommand;

//用户信息
@property(nonatomic, copy) NSString *avater;
@property(nonatomic, copy) NSString *nickname;
@property(nonatomic, copy) NSString *sex;
@property(nonatomic, copy) NSString *birthdate;

//目标与计划
@property(nonatomic, copy) NSString *plan;
@property(nonatomic, copy) NSString *finishDate;
@property(nonatomic, copy) NSString *currentImage;


-(void)registerWithSuccessBlock:(YJ_ResponseSuccess)successBlock
               WithFailureBlock:(YJ_ResponseFail)failureBlock;

-(void)registerUserInfoWithSuccessBlock:(YJ_ResponseSuccess)successBlock
               WithFailureBlock:(YJ_ResponseFail)failureBlock;

-(void)registerPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                       WithFailureBlock:(YJ_ResponseFail)failureBlock;

@end
