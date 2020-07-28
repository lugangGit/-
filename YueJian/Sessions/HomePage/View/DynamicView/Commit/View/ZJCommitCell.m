//
//  ZJCommitCell.m
//  ZJUIKit
//
//  Created by dzj on 2018/1/23.
//  Copyright © 2018年 kapokcloud. All rights reserved.
//

#import "ZJCommitCell.h"
#import "ZJCommitFrame.h"
#import "ZJCommitPhotoView.h"
#import "ZJCommit.h"
#import "ZJStarsView.h"
#import "ZJButton.h"
#import "ZJImgLeftBtn.h"
#import "YJ_UserProfile.h"
#import "YJ_APIManager.h"

@interface ZJCommitCell()

@property(nonatomic, weak) UIImageView          *iconView;
@property(nonatomic, weak) UILabel              *nameLab;
@property(nonatomic, weak) UILabel              *timeLab;
@property(nonatomic, weak) UILabel              *contentLab;
@property(nonatomic, weak) UILabel              *cityLab;
@property(nonatomic ,weak) UIButton             *deleteBtn;

@property(nonatomic,weak) ZJCommitPhotoView     *photosView;
@property(nonatomic,weak) ZJStarsView           *starView;

@property(nonatomic, strong) ZJCommit           *commit;

@end

@implementation ZJCommitCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpAllView];
    }
    return self;
}


-(void)setCommitFrame:(ZJCommitFrame *)commitFrame{
    _commitFrame = commitFrame;
    
    _iconView.frame = commitFrame.iconFrame;
    _nameLab.frame = commitFrame.nameFrame;
    _timeLab.frame = commitFrame.timeFrame;
    _contentLab.frame = commitFrame.contentFrame;
    _cityLab.frame = commitFrame.cityFrame;
//    _likeBtn.frame = commitFrame.likeFrame;
    //_disLikeBtn.frame = commitFrame.disLikeFrame;
//    _starView.frame = commitFrame.starFrame;
    _deleteBtn.frame = commitFrame.deleteFrame;
    
    
    _photosView.selfVc = self.selfVc;
    
    ZJCommit *commit = commitFrame.commit;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:commit.avatar] placeholderImage:kImageName(@"icon_register_header")];
    _nameLab.text = commit.nickname;
    _contentLab.text = commit.content;
    _cityLab.text = commit.city;
    //NSInteger time = [commit.add_time integerValue];
    //_timeLab.text = NSDate dateWithTimeInterval:time format:@"MM月dd日"];
    _timeLab.text = [commit.add_time substringToIndex:10];
    
    /*[_likeBtn setTitle:[NSString stringWithFormat:@"%@",commit.like_count] forState:UIControlStateNormal];
    [_disLikeBtn setTitle:[NSString stringWithFormat:@"%@",commit.unlike_count] forState:UIControlStateNormal];

    self.starView.starCount = [NSString stringWithFormat:@"%@",commit.rating];
    
    if ( commit.like_id == nil) {
        [self.likeBtn setImage:kImageName(@"new_organize_dislike") forState:UIControlStateNormal];
        [self.disLikeBtn setImage:kImageName(@"new_unlike_unsele") forState:UIControlStateNormal];
    }else{
        if (commit.like_type == nil) {
            [self.likeBtn setImage:kImageName(@"new_organize_dislike") forState:UIControlStateNormal];
            [self.disLikeBtn setImage:kImageName(@"new_unlike_unsele") forState:UIControlStateNormal];
        }else{
            if (commit.like_type != nil && [commit.like_type integerValue] == 1){
                [self.likeBtn setImage:kImageName(@"new_organize_like") forState:UIControlStateNormal];
                [self.disLikeBtn setImage:kImageName(@"new_unlike_unsele") forState:UIControlStateNormal];
            }else if (commit.like_type != nil && [commit.like_type integerValue] == 2){
                [self.likeBtn setImage:kImageName(@"new_organize_dislike") forState:UIControlStateNormal];
                [self.disLikeBtn setImage:kImageName(@"new_unlike_sele") forState:UIControlStateNormal];
            }
        }
    }*/
    
    if([[YJ_APIManager sharedInstance] isLoggedIn])
    {
        YJ_UserProfile *userProfile = [[YJ_APIManager sharedInstance] readProfile];
        if ([commit.uid integerValue] != [userProfile.userID integerValue] || userProfile.userID == nil) {
            _deleteBtn.hidden = YES;
        }else{
            _deleteBtn.hidden = NO;
        }
    }else {
        _deleteBtn.hidden = YES;
    }

    _photosView.pic_urls = commit.pic_urls;
    _photosView.frame = commitFrame.photosFrame;
}

-(void)likeBtnClick:(ZJImgLeftBtn *)sender{
    
    if ([self.delegate respondsToSelector:@selector(likeBtnClickAction:)] ) {
        [self.delegate likeBtnClickAction:sender];
    }
}


-(void)disLikeBtnClick:(ZJImgLeftBtn *)sender{
    
    if ([self.delegate respondsToSelector:@selector(disLikeBtnClickAction:)]) {
        [self.delegate disLikeBtnClickAction:sender];
    }
    
}

-(void)deleteBtnClick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(deleteBtnClickAction:)]) {
        [self.delegate deleteBtnClickAction:sender];
    }
}

-(void)setChildBtnTag:(NSInteger)tag{
    _deleteBtn.tag = tag;
    _likeBtn.tag = tag;
    _disLikeBtn.tag = tag;
    
}
-(void)setUpAllView{
    UIImageView *iconView = [[UIImageView alloc]init];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = (85/1334.0)*SCREEN_HEIGHT/2;
    [self.contentView addSubview:iconView];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    _iconView = iconView;
    
    UILabel *nameLab = [[UILabel alloc]init];
    //nameLab.backgroundColor = ThemeColor;
    [self addOneLabelWithLab:nameLab TextColor:kBlackColor fontSize:16 isBold:YES];
    _nameLab = nameLab;
    
    /*ZJStarsView *starView = [[ZJStarsView alloc]init];
    [self.contentView addSubview:starView];
    _starView = starView;*/
    
    UILabel *timeLab = [[UILabel alloc]init];
    //timeLab.backgroundColor = [UIColor redColor];
    [self addOneLabelWithLab:timeLab TextColor:[UIColor lightGrayColor] fontSize:12 isBold:NO];
    timeLab.textAlignment = NSTextAlignmentRight;
    _timeLab = timeLab;
    
    UILabel *contentLab = [[UILabel alloc]init];
    [self addOneLabelWithLab:contentLab TextColor:kBlackColor fontSize:15 isBold:NO];
    contentLab.numberOfLines = 0;
    _contentLab = contentLab;
    
    /*ZJImgLeftBtn *likeBtn = [[ZJImgLeftBtn alloc]init];
    [likeBtn setImage:kImageName(@"new_organize_dislike") forState:UIControlStateNormal];
    [likeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    likeBtn.titleLabel.font = kFontWithSize(12);
    [self.contentView addSubview:likeBtn];
    [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _likeBtn = likeBtn;*/
    
    UIButton *deleteBtn = [UIButton new];
    [deleteBtn setImage:kImageName(@"icon_dynamic_delete") forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteBtn];
    _deleteBtn = deleteBtn;
    _deleteBtn.hidden = NO;
    
    UILabel *cityLab = [[UILabel alloc]init];
    [self addOneLabelWithLab:cityLab TextColor:[UIColor lightGrayColor] fontSize:13 isBold:NO];
    //cityLab.backgroundColor = ThemeColor;
    [self addOneLabelWithLab:nameLab TextColor:kBlackColor fontSize:16 isBold:YES];
    _cityLab = cityLab;
    
    /*ZJImgLeftBtn *disLikeBtn = [[ZJImgLeftBtn alloc]init];
    [disLikeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [disLikeBtn setImage:kImageName(@"new_unlike_unsele") forState:UIControlStateNormal];
    disLikeBtn.titleLabel.font = kFontWithSize(12);
    [self.contentView addSubview:disLikeBtn];
    _disLikeBtn = disLikeBtn;
    [disLikeBtn addTarget:self action:@selector(disLikeBtnClick:) forControlEvents:UIControlEventTouchUpInside];*/
    
    ZJCommitPhotoView *photosView = [[ZJCommitPhotoView alloc]init];
    [self.contentView addSubview:photosView];
    photosView.selfVc = self.selfVc;
    _photosView = photosView;
    
}

-(void)addOneLabelWithLab:(UILabel *)label TextColor:(UIColor *)textColor fontSize:(float)fontSize isBold:(BOOL)isBold{
    
    label.textColor = textColor;
    
    if (isBold) {
        label.font = [UIFont boldSystemFontOfSize:fontSize];
    }else{
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    [self.contentView addSubview:label];
    
}





+(instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"ZJCommitCell";
    id cell  = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
