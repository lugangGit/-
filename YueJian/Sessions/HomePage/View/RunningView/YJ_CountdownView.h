//
//  YJ_CountdownView.h
//  YueJian
//
//  Created by Garry on 2018/7/19.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YJ_CountdownViewDelegate <NSObject>

- (void)countdownFinish;

@end

@interface YJ_CountdownView : UIView

@property (nonatomic, weak) id<YJ_CountdownViewDelegate> delegate;

- (void)startCountdownWithTime:(NSInteger)time;
- (void)startAnimationCountdownWithTime:(NSInteger)time;

@end
