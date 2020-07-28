//
//  YJ_AddDynameicViewModel.h
//  YueJian
//
//  Created by Garry on 2018/8/11.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_BaseModel.h"

@interface YJ_AddDynameicViewModel : YJ_BaseModel

-(void)getDynameicDataWithPageNumber:(NSString *)pageNumber
                 withSuccessBlock:(YJ_ResponseSuccess)successBlock
                 withFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)postDynameicWithContent:(NSString *)content withImage:(NSMutableArray *)imageArray withCity:(NSString *)city
               withSuccessBlock:(YJ_ResponseSuccess)successBlock
               withFailureBlock:(YJ_ResponseFail)failureBlock;

- (void)deleteDynameicWithDynameicId:(NSString *)dynameicId
                    withSuccessBlock:(YJ_ResponseSuccess)successBlock
                    withFailureBlock:(YJ_ResponseFail)failureBlock;
@end
