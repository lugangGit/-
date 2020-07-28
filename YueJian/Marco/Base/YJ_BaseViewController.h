//
//  YJ_BaseViewController.h
//  YueJian
//
//  Created by LG on 2018/3/30.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface YJ_BaseViewController : UIViewController

-(void)showStatusWithError:(NSString *)status;

-(void)showStatusWithWarnning:(NSString *)status;

-(void)showStatusWithSuccess:(NSString *)status;

-(NSString *)returnCurrentMessageWithErrorCode:(NSInteger)errorCode;

@end
