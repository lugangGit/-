//
//  YJ_RegisterUserPlayViewController.m
//  YueJian
//
//  Created by Garry on 2018/4/19.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_RegisterUserPlayViewController.h"
#import "YJ_RegisterViewController.h"
#import "UIImage+UIImageExtras.h"
#import "YJ_RegisterViewModel.h"

#define MAX_STARWORDS_LENGTH 50

@interface YJ_RegisterUserPlayViewController ()<UITextViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UILabel *labPlaceHolder;
@property (nonatomic, strong) UITextView *textPlanContent;
@property (nonatomic, strong) UILabel *labTextCount;
@property (nonatomic, strong) UITextField *tfFinishDate;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL isFirstChoose;
@property (nonatomic, strong) YJ_RegisterViewModel *viewModel;
@end

@implementation YJ_RegisterUserPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewModel = [[YJ_RegisterViewModel alloc] init];
    self.viewModel.currentImage = @"";
    self.isFirstChoose = YES;

    [self drawUI];
}

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
    
    [self jumpClick:cell];
    
    return cell;
}

//然后在设置cell的高度(controller)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 700;
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
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    [self.imageView addGestureRecognizer:tapGesture];
    [cell addSubview:self.imageView];
    
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
        make.height.offset(120);
    }];
    
    [self.labPlaceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(4);
        make.top.offset(8);
        make.right.offset(-4);
    }];
    
    [self.labTextCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(-5);
        make.top.offset(100);
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
        make.width.offset(200);
        make.height.offset(15);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labSubPhone.mas_bottom).offset(15);
        make.left.offset(45);
        make.right.offset(-45);
        make.height.offset(130);
    }];
    
    // 下一步按钮
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [btnNext setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateHighlighted];
    btnNext.layer.cornerRadius = 20;
    btnNext.backgroundColor = ThemeColor;
    [cell addSubview:btnNext];
    
    //添加约束
    [btnNext mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).with.offset(30);
        make.height.offset(40);
        make.left.offset(100);
        make.right.offset(-100);
    }];
    
    __weak typeof(self) weakSelf = self;
    [[btnNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        weakSelf.viewModel.plan = self.textPlanContent.text;
        weakSelf.viewModel.finishDate = self.tfFinishDate.text;

        //发送请求
        [weakSelf.viewModel registerPlanWithSuccessBlock:^(id response) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KPopView];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } WithFailureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
        }];
    }];
}

- (void)jumpClick:(UITableViewCell *)cell {
    //跳过
    UIButton *jumpClick = [[UIButton alloc] init];
    [jumpClick setTitle:NSLocalizedString(@"跳过 >", nil) forState:UIControlStateNormal];
    jumpClick.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [jumpClick setTitleColor:ThemeColor forState:UIControlStateNormal];
    jumpClick.titleLabel.font = [UIFont systemFontOfSize:16];
    [cell addSubview:jumpClick];
    
    //添加约束
    [jumpClick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(30);
        make.right.offset(-30);
        make.width.offset(50);
        make.height.offset(30);
    }];
    
    [[jumpClick rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *sender) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KPopView];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)tapPhotoAction:(UITapGestureRecognizer *)tap {
    [self uploadImage];
}

//UpLoadImage
- (void)uploadImage {
    [self.view endEditing:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"TakePhoto",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    
    UIAlertAction *chooseFromPhotos = [UIAlertAction actionWithTitle:NSLocalizedString(@"ChooseFromPhotos",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    
    self.viewModel.currentImage = decodeStr;
    
    self.imageView = [[UIImageView alloc] initWithImage:newImage];

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

//选择日期
- (void)chooseDate:(UIDatePicker *)sender {
    NSDate *selectedDate = sender.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateString = [formatter stringFromDate:selectedDate];
    self.tfFinishDate.text = dateString;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.datePicker removeFromSuperview];
    [self.view endEditing:YES];
}

-(void)resignActive
{
    //[self.datePicker removeFromSuperview];
    //[self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //获取当前时间日期
    if (_isFirstChoose) {
        NSDate *date=[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateStr;
        dateStr=[formatter stringFromDate:date];
        NSLog(@"%@",dateStr);
        self.tfFinishDate.text = dateStr;
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
