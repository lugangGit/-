//
//  YJ_EditPlanViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_EditPlanViewModel : YJ_BaseModel
@property(nonatomic, copy) NSString *myTarget;
@property(nonatomic, copy) NSString *finsihDate;
@property(nonatomic, copy) NSString *currentImage;
@property(nonatomic, copy) NSString *finsihImage;
@property(readonly, strong) RACCommand *ConfirmCommand;

- (void)handlerGetTargetPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                  WithFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)handlerPostHeaderPlanWithSuccessBlock:(YJ_ResponseSuccess)successBlock
                            WithFailureBlock:(YJ_ResponseFail)failureBlock;

@end
