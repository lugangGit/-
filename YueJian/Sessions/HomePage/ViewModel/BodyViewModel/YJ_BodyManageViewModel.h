//
//  YJ_BodyManageViewModel.h
//  YueJian
//
//  Created by LG on 2018/5/16.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_BodyManageViewModel : YJ_BaseModel

- (void)handlerGetBodyDataSuccessBlock:(YJ_ResponseSuccess)successBlock
                withFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)handlerPostBodyData:(NSMutableDictionary *)dic withSuccessBlock:(YJ_ResponseSuccess)successBlock
                      withFailureBlock:(YJ_ResponseFail)failureBlock;

@end
