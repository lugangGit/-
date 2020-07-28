//
//  YJ_EditPlanViewController.m
//  YueJian
//
//  Created by Garry on 2018/7/31.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_EditPlanViewController.h"
#import "UIImage+UIImageExtras.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "YJ_EditPlanViewModel.h"
#import "YJ_PlanModel.h"
#import "UIImageView+WebCache.h"

#define MAX_STARWORDS_LENGTH 50

@interface YJ_EditPlanViewController ()<UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    int photoType;
}
@property (nonatomic, strong) UILabel *labPlaceHolder;
@property (nonatomic, strong) UITextView *textPlanContent;
@property (nonatomic, strong) UILabel *labTextCount;
@property (nonatomic, strong) UITextField *tfFinishDate;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, assign) BOOL isFirstChoose;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *afterImageView;
@property (nonatomic, strong) UIButton *btnDelImage;
@property (nonatomic, strong) UIButton *btnDelAfterImage;
@property (nonatomic, strong) YJ_EditPlanViewModel *viewModel;

@end

@implementation YJ_EditPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_EditPlanViewModel alloc] init];

    //获取数据
    [self handlerPlanData];
    
    //设置导航栏
    [self setNavigation];
    
    //绘制视图
    [self drawUI];
    
    self.isFirstChoose = YES;
}

#pragma mark - 获取数据
- (void)handlerPlanData {
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [weakSelf.viewModel handlerGetTargetPlanWithSuccessBlock:^(id response) {
        NSLog(@"%@", response);
        [SVProgressHUD dismiss];
        YJ_PlanModel *planHeader = [[YJ_PlanModel alloc] initPlanHeaderWithDictionary:response[@"data"]];
        NSLog(@"%@", planHeader);
        
        NSLog(@"%@", planHeader.planContent);
        NSString *planContent = [NSString stringWithFormat:@"%@", planHeader.planContent];
        if (![planContent isEqualToString:@""] && ![planContent isEqualToString:@"(null)"]) {
            self.textPlanContent.text = planContent;
            NSNumber *lengthNum = [[NSNumber alloc] initWithInteger:self.textPlanContent.text.length];
            self.labTextCount.text = [lengthNum.stringValue stringByAppendingString:@"/50"];
        }
        
        NSString *finishDate = [NSString stringWithFormat:@"%@", planHeader.finishDate];
        if (![finishDate isEqualToString:@""] && ![finishDate isEqualToString:@"(null)"]) {
            self.tfFinishDate.text = finishDate;
        }
        
        NSString *currentPhoto = [NSString stringWithFormat:@"%@", planHeader.currentPhoto];
        if (![currentPhoto isEqualToString:@""] && ![currentPhoto isEqualToString:@"(null)"]) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:planHeader.currentPhoto]];
        }
        
        NSString *finishPhoto = [NSString stringWithFormat:@"%@", planHeader.finishPhoto];
        if (![finishPhoto isEqualToString:@""] && ![finishPhoto isEqualToString:@"(null)"] ) {
            [self.afterImageView sd_setImageWithURL:[NSURL URLWithString:planHeader.finishPhoto]];
        }
        
        NSLog(@"%@", planHeader.currentPhoto);
        if (planHeader.currentPhoto == nil || [planHeader.currentPhoto isEqualToString:@""]) {
            self.viewModel.currentImage = @"";
        }else {
            self.viewModel.currentImage = planHeader.currentPhoto;
        }
        
        NSLog(@"%@", planHeader.finishPhoto);
        if (planHeader.finishPhoto == nil || [planHeader.finishPhoto isEqualToString:@""]) {
            self.viewModel.finsihImage = @"";
        }else {
            self.viewModel.finsihImage = planHeader.finishPhoto;
        }
    } WithFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
    }];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

#pragma mark - 绘制视图
- (void)drawUI {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.offset(0);
    }];
    
    //UIDatePicker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minuteInterval = 30;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignActive)];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self drawCellUI:cell];
    
    return cell;
}

//然后在设置cell的高度(controller)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 650;
}

- (void)drawCellUI:(UITableViewCell *)cell {
    UILabel *labPlan = [[UILabel alloc] init];
    labPlan.font = [UIFont systemFontOfSize:18];
    labPlan.textColor = [UIColor blackColor];
    labPlan.text = @"目标与计划";
    [cell addSubview:labPlan];

    UILabel *labSubPlan = [[UILabel alloc] init];
    labSubPlan.font = [UIFont systemFontOfSize:12];
    labSubPlan.textColor = [UIColor grayColor];
    labSubPlan.text = @"记录下期望达成目标";
    [cell addSubview:labSubPlan];

    self.textPlanContent = [[UITextView alloc]init];
    self.textPlanContent.delegate = self;
    self.textPlanContent.textColor = [UIColor blackColor];
    self.textPlanContent.font = [UIFont systemFontOfSize:14];
    self.textPlanContent.layer.borderColor = BGColor.CGColor;
    self.textPlanContent.layer.borderWidth = 1.0;
    self.textPlanContent.layer.cornerRadius = 10;
    self.textPlanContent.backgroundColor = BGColor;
    [cell addSubview:self.textPlanContent];

    self.labPlaceHolder = [[UILabel alloc] init];
    self.labPlaceHolder.textColor = [UIColor grayColor];
    self.labPlaceHolder.text = @"";
    self.labPlaceHolder.font = [UIFont systemFontOfSize:14];
    self.labPlaceHolder.preferredMaxLayoutWidth = SCREEN_WIDTH - 32.0;
    [self.textPlanContent addSubview:self.labPlaceHolder];

    self.labTextCount = [[UILabel alloc] init];
    self.labTextCount.font = [UIFont systemFontOfSize:14];
    self.labTextCount.textColor = [UIColor grayColor];
    self.labTextCount.text = @"0/50";
    self.labTextCount.textAlignment = NSTextAlignmentRight;
    [self.textPlanContent addSubview:self.labTextCount];

    //完成时间
    UILabel *labFinishDate = [[UILabel alloc] init];
    labFinishDate.font = [UIFont systemFontOfSize:18];
    labFinishDate.textColor = [UIColor blackColor];
    labFinishDate.text = @"计划完成时间";
    [cell addSubview:labFinishDate];

    UILabel *labSubDate = [[UILabel alloc] init];
    labSubDate.font = [UIFont systemFontOfSize:12];
    labSubDate.textColor = [UIColor grayColor];
    labSubDate.text = @"提醒自己在计划时间完成";
    [cell addSubview:labSubDate];

    self.tfFinishDate = [[UITextField alloc] init];
    self.tfFinishDate.delegate = self;
    self.tfFinishDate.tag = 1001;
    self.tfFinishDate.font = [UIFont systemFontOfSize:14];
    self.tfFinishDate.textColor = [UIColor blackColor];
    self.tfFinishDate.backgroundColor = BGColor;
    self.tfFinishDate.layer.borderColor = BGColor.CGColor;
    self.tfFinishDate.layer.borderWidth = 1.0;
    self.tfFinishDate.layer.cornerRadius = 10;
    [cell addSubview:self.tfFinishDate];

    //照片
    UILabel *labPhone = [[UILabel alloc] init];
    labPhone.font = [UIFont systemFontOfSize:18];
    labPhone.textColor = [UIColor blackColor];
    labPhone.text = @"拍照";
    [cell addSubview:labPhone];

    UILabel *labSubPhone = [[UILabel alloc] init];
    labSubPhone.font = [UIFont systemFontOfSize:12];
    labSubPhone.textColor = [UIColor grayColor];
    labSubPhone.text = @"记录在这一刻的你";
    [cell addSubview:labSubPhone];

    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_userInfo_bg"]];
    self.imageView.tag = 0;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    [self.imageView addGestureRecognizer:tapGesture];
    [cell addSubview:self.imageView];

    self.btnDelImage = [[UIButton alloc] init];
    self.btnDelImage.hidden = YES;
    [self.btnDelImage setImage:[UIImage imageNamed:@"icon_dynamic_photoDelete"] forState:UIControlStateNormal];
    [self.imageView addSubview:self.btnDelImage];

    UILabel *labAfterSubPhone = [[UILabel alloc] init];
    labAfterSubPhone.font = [UIFont systemFontOfSize:12];
    labAfterSubPhone.textColor = [UIColor grayColor];
    labAfterSubPhone.text = @"当目标完成时记录";
    labAfterSubPhone.textAlignment = NSTextAlignmentRight;
    [cell addSubview:labAfterSubPhone];

    self.afterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_userInfo_bg"]];
    self.afterImageView.tag = 1;
    self.afterImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.afterImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureAfter = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    [self.afterImageView addGestureRecognizer:tapGestureAfter];
    [cell addSubview:self.afterImageView];

    self.btnDelAfterImage = [[UIButton alloc] init];
    self.btnDelAfterImage.hidden = YES;
    [self.btnDelAfterImage setImage:[UIImage imageNamed:@"icon_dynamic_photoDelete"] forState:UIControlStateNormal];
    [self.afterImageView addSubview:self.btnDelAfterImage];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = BGColor;
    [cell addSubview:lineView];


    [labPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.left.offset(45);
        make.width.offset(100);
        make.height.offset(20);
    }];

    [labSubPlan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labPlan.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(200);
        make.height.offset(15);
    }];

    [self.textPlanContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPlan.mas_bottom).offset(15);
        make.left.offset(45);
        make.right.offset(-45);
        make.height.offset(80);
    }];

    [self.labPlaceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(4);
        make.top.offset(8);
        make.right.offset(-4);
    }];

    [self.labTextCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(-5);
        make.top.offset(60);
        make.height.offset(15);
    }];

    //时间约束
    [labFinishDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textPlanContent.mas_bottom).offset(30);
        make.left.offset(45);
        make.width.offset(150);
        make.height.offset(20);
    }];

    [labSubDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labFinishDate.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(200);
        make.height.offset(15);
    }];

    [self.tfFinishDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubDate.mas_bottom).offset(15);
        make.left.offset(45);
        make.right.offset(-45);
        make.height.offset(35);
    }];

    //照片约束
    [labPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfFinishDate.mas_bottom).offset(30);
        make.left.offset(45);
        make.width.offset(150);
        make.height.offset(20);
    }];

    [labSubPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labPhone.mas_bottom).offset(10);
        make.left.offset(45);
        make.width.offset(160);
        make.height.offset(15);
    }];

    [labAfterSubPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labPhone.mas_bottom).offset(10);
        make.right.offset(-45);
        make.width.offset(160);
        make.height.offset(15);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPhone.mas_bottom).offset(15);
        make.left.offset(40);
        make.height.width.offset(130);
    }];

    [self.afterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPhone.mas_bottom).offset(15);
        make.right.offset(-40);
        make.height.width.offset(130);
    }];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPhone.mas_bottom).offset(20);
        make.centerX.offset(0);
        make.width.offset(1);
        make.height.offset(120);
    }];

    [self.btnDelImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.right.offset(0);
        make.width.height.offset(20);
    }];

    [self.btnDelAfterImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.right.offset(0);
        make.width.height.offset(20);
    }];


    [[self.btnDelImage rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        self.viewModel.currentImage = @"";
        self.btnDelImage.hidden = YES;
        self.imageView.image = [UIImage imageNamed:@"img_userInfo_bg"];
    }];

    [[self.btnDelAfterImage rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        self.viewModel.finsihImage = @"";
        self.btnDelAfterImage.hidden = YES;
        self.afterImageView.image = [UIImage imageNamed:@"img_userInfo_bg"];
    }];
    
    //确定按钮
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateHighlighted];
    btnConfirm.layer.cornerRadius = 20;
    [btnConfirm setBackgroundColor:ThemeColor];
    [cell addSubview:btnConfirm];
    
    //添加约束
    [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(30);
        make.height.offset(40);
        make.left.offset(60);
        make.right.offset(-60);
    }];
    
    //RAC(self.viewModel, myTarget) = self.textPlanContent.rac_textSignal;
    
    btnConfirm.rac_command = self.viewModel.ConfirmCommand;
    
    RAC(btnConfirm, backgroundColor) = [RACObserve(btnConfirm, enabled) map:^id(NSNumber *value) {
        return value.boolValue ? ThemeColor : ButtonTitleNormal;
    }];
    
    __weak typeof(self) weakSelf = self;
    [[btnConfirm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [SVProgressHUD show];
        [weakSelf.viewModel handlerPostHeaderPlanWithSuccessBlock:^(id response) {
            weakSelf.callback();
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

- (void)tapPhotoAction:(UITapGestureRecognizer *)tap {
    NSLog(@"%ld", tap.view.tag);
    photoType = (int)tap.view.tag;
    if (photoType == 1) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"友情提示" message:@"确定目标与计划已经完成？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"%@", @"confirm");
            [self presentAlertSheet];

        }];
        UIAlertAction *action2=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"%@", @"cancel");
            return;
        }];
        [controller addAction:action1];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    [self presentAlertSheet];
}

- (void)presentAlertSheet {
    [self.view endEditing:YES];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"拍照",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断是否可以打开相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            //无权限访问相机
            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
                
                // 1.创建弹框控制器, UIAlertControllerStyleAlert这个样式代表弹框显示在屏幕中央
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"请在iphone的“设置-隐私-相机”选项中，允许访问你的相机。", nil) preferredStyle:UIAlertControllerStyleAlert];
                // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    NSLog(@"点击了取消按钮");
                }];
                // 3.将“取消”按钮加入到弹框控制器中
                [alertVc addAction:cancle];
                // 4.控制器 展示弹框控件，完成时不做操作
                [picker presentViewController:alertVc animated:YES completion:nil];
                
            }else {
                //有限权访问相机
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }];
    
    UIAlertAction *chooseFromPhotos = [UIAlertAction actionWithTitle:NSLocalizedString(@"从相册中选择",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断是否可以打开相册
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:takePhoto];
    [alert addAction:chooseFromPhotos];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

//点击取消按钮所执行的方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他逻辑操作。就需要实现该代理方法，如果不做任何逻辑操作，就可以不实现
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - imagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    /*
     info是所选择照片的信息
     UIImagePickerControllerEditedImage//编辑过的图片
     UIImagePickerControllerOriginalImage//原图
     */
    
    //1、刚才已经看了info中的键值对，可以从info中取出一个UIImage对象
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    //2、在这里重新设置图片大小，并添加网络请求
    CGSize targetSize = CGSizeMake(200.0, 200.0);
    //3、图片转码
    UIImage *newImage = [resultImage imageByScalingToSize:targetSize];
    //4、image转data
    NSData *data = UIImageJPEGRepresentation(newImage, 0.7);
    
    //LYT_UserProfile *userProfile = [[LYT_APIManager sharedInstance] readProfile];
    
    //5、Base64 加密
    NSData *encodeData = [data base64EncodedDataWithOptions:0];
    //6、Data转字符串
    NSString *decodeStr = [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
    //7、网络请求
    //[self submitAvatar:avatarUrl];
    
    if (photoType == 0) {
        self.imageView.image = newImage;
        self.btnDelImage.hidden = NO;
        self.viewModel.currentImage = decodeStr;
        self.viewModel.myTarget = self.textPlanContent.text;
        self.viewModel.finsihDate = self.tfFinishDate.text;
    }else if(photoType == 1) {
        self.afterImageView.image = newImage;
        self.btnDelAfterImage.hidden = NO;
        self.viewModel.finsihImage = decodeStr;
        self.viewModel.myTarget = self.textPlanContent.text;
        self.viewModel.finsihDate = self.tfFinishDate.text;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 保存
- (void)saveEdit {
    
}

#pragma mark - 选择日期
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:selectedDate];
    self.tfFinishDate.text = dateString;
    self.viewModel.finsihDate = dateString;
    self.viewModel.myTarget = self.textPlanContent.text;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.datePicker removeFromSuperview];
    [self.view endEditing:YES];
}

-(void)resignActive
{
    [self.datePicker removeFromSuperview];
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //获取当前时间日期
    if (_isFirstChoose && [textField.text isEqualToString:@""]) {
        NSDate *date=[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateStr;
        dateStr=[formatter stringFromDate:date];
        NSLog(@"%@",dateStr);
        self.tfFinishDate.text = dateStr;
        self.viewModel.finsihDate = dateStr;
        _isFirstChoose = NO;
    }

    //UIDatePicker以及在当前视图上就不用再显示
    if (self.datePicker.superview == nil) {
        //close all keyboard or data picker visible currently
        [self.view endEditing:YES];
        //此处将Y坐标设在最底下，为了一会动画的展示
        self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 200);
        [self.view addSubview:self.datePicker];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.datePicker.frame = CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200);
        [UIView commitAnimations];
    }
    return NO;
}

#pragma - UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.datePicker removeFromSuperview];
}

- (void)textViewDidChange:(UITextView *)textView
{
    //统计字数
    NSInteger length = textView.text.length;
    if (length > 0) {
        self.labPlaceHolder.hidden = YES;
    }
    else
    {
        self.labPlaceHolder.hidden = NO;
    }
    
    //限制最大字数
    NSString *toBeString = textView.text;
    NSArray *current = [UITextInputMode activeInputModes];
    UITextInputMode *currentInputMode = [current firstObject];
    NSString *lang = [currentInputMode primaryLanguage]; // 键盘输入模式
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        //获取高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > MAX_STARWORDS_LENGTH)
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
                if (rangeIndex.length == 1)
                {
                    textView.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                    textView.text = [toBeString substringWithRange:rangeRange];
                }
            }
            
        }
        
    }
    else
    {   // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > MAX_STARWORDS_LENGTH){
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1){
                textView.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    NSNumber *lengthNum = [[NSNumber alloc] initWithInteger:textView.text.length];
    self.labTextCount.text = [lengthNum.stringValue stringByAppendingString:@"/50"];
    self.viewModel.myTarget = textView.text;
    self.viewModel.finsihDate = self.tfFinishDate.text;

}

#pragma mark - 处理手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"%@", touch.view);
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"]) {
        [self.datePicker removeFromSuperview];
        [self.view endEditing:YES];
        return NO;
    }

    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
