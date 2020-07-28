//
//  YJ_RegisterUserInfoViewController.m
//  YueJian
//
//  Created by Garry on 2018/4/19.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_RegisterUserInfoViewController.h"
#import "YJ_RegisterUserPlayViewController.h"
#import "UIImage+UIImageExtras.h"
#import "YJ_RegisterViewModel.h"

@interface YJ_RegisterUserInfoViewController ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *tfBirthday;
@property (nonatomic, strong) UITextField *tfNickname;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) UIButton *btnHeader;
@property (nonatomic, strong) YJ_RegisterViewModel *viewModel;
@end

@implementation YJ_RegisterUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_RegisterViewModel alloc] init];
    
    //数据初始化
    self.viewModel.avater = @"";
    self.sex = @"男";
    
    //绘制视图
    [self drawUI];
    
    //添加跳过
    [self jumpClick];
}

#pragma mark - 绘制视图
- (void)drawUI {
    //UIDatePicker
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minuteInterval = 30;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];
    
    //背景
    /*UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_login_bgs"]];
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.left.right.offset(0);
    }];*/
    
    //头像👮‍♀️
    self.btnHeader = [[UIButton alloc] init];
    self.btnHeader.layer.cornerRadius = 50;
    self.btnHeader.layer.borderWidth = 1.0;
    self.btnHeader.layer.borderColor =[UIColor clearColor].CGColor;
    self.btnHeader.clipsToBounds = TRUE;//去除边界
    self.btnHeader.backgroundColor = [UIColor whiteColor];
    [self.btnHeader.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.btnHeader setBackgroundImage:[UIImage imageNamed:@"icon_register_header"] forState:UIControlStateNormal];
    [self.view addSubview:self.btnHeader];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"上传头像";
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];
    
    [self.btnHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(100);
        make.centerX.offset(0);
        make.width.height.offset(100);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.equalTo(self.btnHeader.mas_bottom).with.offset(10);
        make.width.offset(70);
        make.height.offset(16);
    }];
    
    [[self.btnHeader rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        //上传头像
        [self uploadImage];
    }];
    
    UIView *userView = [[UIView alloc] init];
    userView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:userView];
    
    //输入框
    self.tfNickname = [[UITextField alloc] init];
    self.tfNickname.textAlignment = NSTextAlignmentCenter;
    self.tfNickname.placeholder = NSLocalizedString(@"Nickname",nil);
    //修改占位文字的颜色
    [self.tfNickname setValue:ThemeColor forKeyPath:@"_placeholderLabel.textColor"];
    self.tfNickname.font = [UIFont systemFontOfSize:23];
    self.tfNickname.textColor = ThemeColor;
    self.tfNickname.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.tfNickname.returnKeyType = UIReturnKeyDone;
    [userView addSubview:self.tfNickname];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = ThemeColor;
    [userView addSubview:lineView];
    
    //验证码
    UIView *verificationView = [[UIView alloc] init];
    verificationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:verificationView];
    
    UIButton *btnBoy = [[UIButton alloc] init];
    btnBoy.backgroundColor = [UIColor whiteColor];
    [btnBoy.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [btnBoy  setBackgroundImage:[UIImage imageNamed:@"icon_sex_boy_selected"] forState:UIControlStateNormal];
    [verificationView addSubview:btnBoy];
    
    UIButton *btnGril = [[UIButton alloc] init];
    [btnGril setBackgroundImage:[UIImage imageNamed:@"icon_sex_girl_normal"] forState:UIControlStateNormal];
    [verificationView addSubview:btnGril];
    
    [[btnBoy rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [btnBoy  setBackgroundImage:[UIImage imageNamed:@"icon_sex_boy_selected"] forState:UIControlStateNormal];
        [btnGril setBackgroundImage:[UIImage imageNamed:@"icon_sex_girl_normal"] forState:UIControlStateNormal];
        self.sex = @"男";
    }];
    
    [[btnGril rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [btnBoy  setBackgroundImage:[UIImage imageNamed:@"icon_sex_boy_normal"] forState:UIControlStateNormal];
        [btnGril setBackgroundImage:[UIImage imageNamed:@"icon_sex_girl_selected"] forState:UIControlStateNormal];
        self.sex = @"女";
    }];
    
    //密码
    UIView *passwordView = [[UIView alloc] init];
    passwordView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordView];
    
    //输入框
    self.tfBirthday = [[UITextField alloc] init];
    self.tfBirthday.delegate = self;
    self.tfBirthday.tag = 1001;
    self.tfBirthday.textAlignment = NSTextAlignmentCenter;
    self.tfBirthday.placeholder = NSLocalizedString(@"Birthdate",nil);
    //通过KVC修改占位文字的颜色
    [self.tfBirthday setValue:ThemeColor forKeyPath:@"_placeholderLabel.textColor"];
    self.tfBirthday.font = [UIFont systemFontOfSize:23];
    self.tfBirthday.textColor = ThemeColor;
    self.tfBirthday.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordView addSubview:self.tfBirthday];
    
    UIView *linePasswordView = [[UIView alloc] init];
    linePasswordView.backgroundColor = ThemeColor;
    [passwordView addSubview:linePasswordView];
    
    //昵称约束
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(45);
        make.left.offset(90);
        make.right.offset(-90);
        make.height.offset(40);
    }];

    [self.tfNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(0);
        make.right.offset(0);
        make.height.offset(28);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfNickname.mas_bottom).offset(0);
        make.left.offset(0);
        make.right.offset(0);
        make.height.offset(2);
    }];
    
    //性别约束
    [verificationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(userView.mas_bottom).offset(50);
        make.left.offset(90);
        make.right.offset(-90);
        make.height.offset(40);
    }];
    
    [btnBoy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(-50);
        make.centerY.offset(0);
        make.width.height.offset(35);
    }];
    
    [btnGril mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.equalTo(btnBoy.mas_right).offset(70);
        make.height.width.offset(35);
    }];
    
    //出生日期约束
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(verificationView.mas_bottom).offset(30);
        make.left.offset(90);
        make.right.offset(-90);
        make.height.offset(40);
    }];
    
    [self.tfBirthday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(0);
        make.right.offset(0);
        make.height.offset(28);
    }];
    
    [linePasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tfBirthday.mas_bottom).offset(0);
        make.right.left.offset(0);
        make.height.offset(2);
    }];
    
    // 下一步按钮
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [btnNext setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateHighlighted];
    btnNext.layer.cornerRadius = 20;
    btnNext.backgroundColor = ThemeColor;
    [self.view addSubview:btnNext];
    
    //添加约束
    [btnNext mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(linePasswordView.mas_bottom).with.offset(60);
        make.height.offset(40);
        make.left.offset(100);
        make.right.offset(-100);
    }];
    
    __weak typeof(self) weakSelf = self;
    [[btnNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        self.viewModel.nickname = self.tfNickname.text;
        self.viewModel.sex = self.sex;
        self.viewModel.birthdate = self.tfBirthday.text;
        //发送请求
        [weakSelf.viewModel registerUserInfoWithSuccessBlock:^(id response) {
            YJ_RegisterUserPlayViewController *rpVC = [[YJ_RegisterUserPlayViewController alloc] init];
            [self.navigationController pushViewController:rpVC animated:YES];
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:selectedDate];
    self.tfBirthday.text = dateString;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    //如果当前要显示的键盘，那么把UIDatePicker（如果在视图中）隐藏
    if (textField.tag != 1001) {
        if (self.datePicker.superview) {
            [self.datePicker removeFromSuperview];
        }
        return YES;
    }
    
    //UIDatePicker以及在当前视图上就不用再显示了
    if (self.datePicker.superview == nil) {
        //close all keyboard or data picker visible currently
        [self.tfNickname resignFirstResponder];
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.datePicker.superview) {
        [self.datePicker removeFromSuperview];
    }
    [self.tfNickname resignFirstResponder];
}

- (void)jumpClick {
    //跳过
    UIButton *jumpClick = [[UIButton alloc] init];
    [jumpClick setTitle:NSLocalizedString(@"跳过 >", nil) forState:UIControlStateNormal];
    jumpClick.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [jumpClick setTitleColor:ThemeColor forState:UIControlStateNormal];
    jumpClick.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:jumpClick];
    
    //添加约束
    [jumpClick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(40);
        make.right.offset(-30);
        make.width.offset(50);
        make.height.offset(30);
    }];
    
    [[jumpClick rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        if (self.datePicker.superview) {
            [self.datePicker removeFromSuperview];
        }
        [self.view endEditing:YES];
        
        YJ_RegisterUserPlayViewController *rpVC = [[YJ_RegisterUserPlayViewController alloc] init];
        [self.navigationController pushViewController:rpVC animated:YES];
    }];
}

//UpLoadImage
- (void)uploadImage {
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
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Prompt", nil) message:NSLocalizedString(@"请在iphone的“设置-隐私-相机”选项中，允许访问你的相机。", nil) preferredStyle:UIAlertControllerStyleAlert];
                // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
                UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:takePhoto];
    [alert addAction:chooseFromPhotos];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

//选择照片完成之后的代理方法
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
    //5、Base64 加密
    NSData *encodeData = [data base64EncodedDataWithOptions:0];
    //6、Data转字符串
    NSString *decodeStr = [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
    self.viewModel.avater = decodeStr;
    
    self.btnHeader.layer.cornerRadius = 50;
    [self.btnHeader setBackgroundImage:newImage forState:UIControlStateNormal];

    /*
     //7、网络请求
     [self submitAvatar:avatarUrl];
     */
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

//点击取消按钮所执行的方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他逻辑操作。就需要实现该代理方法，如果不做任何逻辑操作，就可以不实现
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
