//
//  ZJCommitFrame.m
//  ZJCommitListDemo
//
//  Created by 邓志坚 on 2017/12/10.
//  Copyright © 2017年 邓志坚. All rights reserved.
//

#import "ZJCommitFrame.h"
#import "ZJCommit.h"

#define ScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ScreenHeight        [UIScreen mainScreen].bounds.size.height
@implementation ZJCommitFrame

-(void)setCommit:(ZJCommit *)commit{
    _commit = commit;
    
    [self setUpAllViewFrame];
    
}


-(void)setUpAllViewFrame{
    
    CGFloat iconX = 15;
    CGFloat iconWH = HeightRealValue(85);
    CGFloat iconY = 10;
    self.iconFrame = CGRectMake(iconX, iconY, iconWH, iconWH);
    
    CGFloat timeW = 80;
    CGFloat timeX = ScreenWidth - timeW - 15;
    CGFloat timeY = 15;
    self.timeFrame = CGRectMake(timeX, timeY, timeW, 13);
    
    CGFloat nameX = CGRectGetMaxX(self.iconFrame) + 15;
    CGFloat nameW = ScreenWidth - nameX - (ScreenWidth - CGRectGetMaxX(self.timeFrame)) - 80;
    CGFloat nameY = 13;
    CGFloat nameH = 16;
    self.nameFrame = CGRectMake(nameX, nameY, nameW, nameH);
    
//    CGFloat starX = nameX;
//    CGFloat starY = CGRectGetMaxY(_nameFrame)+10;
//    CGFloat starW = ScreenWidth - starX - 15;
//    CGFloat starH = 22;
//    self.starFrame = CGRectMake(starX, starY, starW, starH);
    
    
    CGFloat contentX = nameX;
    CGFloat contentY = nameY + nameH + 10;
    CGFloat contentW = ScreenWidth - contentX - 15;
    CGSize conSize = [_commit.content sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(contentW, MAXFLOAT)];
    self.contentFrame = CGRectMake(contentX, contentY, contentW, conSize.height);
    
    if (_commit.pic_urls.count) {
        CGFloat photoX = nameX;
        CGFloat photoY = CGRectGetMaxY(self.contentFrame)+10;
        CGSize photoSize = [self photosSizeWithCount:_commit.pic_urls.count photoX:photoX];
        self.photosFrame = CGRectMake(photoX, photoY, photoSize.width, photoSize.height);
    }
    
    CGFloat cityX = nameX;
    CGFloat cityY;
    if (_commit.pic_urls.count == 0) {
        cityY =  CGRectGetMaxY(_contentFrame) + 10;
    }else if (0 < _commit.pic_urls.count  && _commit.pic_urls.count <= 3) {
        cityY = CGRectGetMaxY(_photosFrame) - 10;
    }else if (3 < _commit.pic_urls.count && _commit.pic_urls.count <= 6) {
        cityY = CGRectGetMaxY(_photosFrame);
    }else {
        cityY = CGRectGetMaxY(_photosFrame) + 10;
    }
    //CGFloat cityY = _commit.pic_urls.count > 0 ? CGRectGetMaxY(_photosFrame)  : CGRectGetMaxY(_contentFrame) + 5;
    CGFloat cityW = 100;
    CGFloat cityH =  18;
    self.cityFrame = CGRectMake(cityX, cityY, cityW, cityH);
    
    /*CGFloat likeX = nameX;
    CGFloat likeY = _commit.pic_urls.count > 0 ? CGRectGetMaxY(_photosFrame)  : CGRectGetMaxY(_contentFrame) + 10;
    CGFloat likeW = 55;
    CGFloat likeH =  18;
    self.likeFrame = CGRectMake(likeX, likeY, likeW, likeH);
    
    CGFloat dislikeX = CGRectGetMaxX(self.likeFrame) + 5;
    CGFloat dislikeY = likeY;
    CGFloat dislikeW = 55;
    CGFloat dislikeH =  18;
    self.disLikeFrame = CGRectMake(dislikeX, dislikeY, dislikeW, dislikeH);*/
    
    
    CGFloat deleteW = 20;
    CGFloat deleteH = 20;
    CGFloat deleteX = SCREEN_WIDTH - deleteW - 15;
    CGFloat deleteY = _commit.pic_urls.count > 0 ? cityY : CGRectGetMaxY(_contentFrame) + 10;
    self.deleteFrame = CGRectMake(deleteX, deleteY, deleteW, deleteH);
    
    self.cellHeight = CGRectGetMaxY(self.deleteFrame) + 0;
    
}

// 计算配图的尺寸
-(CGSize)photosSizeWithCount:(NSUInteger)count photoX:(CGFloat)photoX{
    // 获取总的列数
    NSUInteger cols = 3;
    
    // 获取总的行数 （总个数 - 1）/ 总列数
    NSUInteger rols = (count - 1 ) / cols + 1;
    
    // 计算图片的宽高
    CGFloat photoWH = (ScreenWidth - photoX - 15 - 2 * 10) / 3;
    
    CGFloat W = cols * photoWH + (cols - 1) * 10;
    CGFloat H = rols * photoWH + (cols - 1) * 10;
    
    return CGSizeMake(W, H);
}

@end
