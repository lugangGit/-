//
//  YJ_MyInfoViewController.m
//  YueJian
//
//  Created by Garry on 2018/8/2.
//  Copyright © 2018年 RHEA. All rights reserved.
//

#import "YJ_MyInfoViewController.h"
#import "YJ_ChangeNicknameViewController.h"
#import "YJ_ChangeBirthViewController.h"
#import "YJ_BodyManageViewController.h"
#import "YJ_UserProfile.h"
#import "YJ_APIManager.h"
#import "UIImage+UIImageExtras.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "YJ_MyInfoViewModel.h"

#define USER_AVATARG_HEIGHT 65.0


@interface YJ_MyInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *infoTableView;
@property (nonatomic, strong) NSArray *arrOfData;
@property (nonatomic, strong) YJ_UserProfile *userProfile;
@property (nonatomic, strong) UIImageView *imgAvatar;
@property (nonatomic, strong) YJ_MyInfoViewModel *viewModel;

@end

@implementation YJ_MyInfoViewController

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGColor;
    self.viewModel = [[YJ_MyInfoViewModel alloc] init];
    
    //导航栏返回按钮
    [self setNavigation];
    
    [self setUpTableView];
    
    //登录后读取数据
    [self isLoginIn];
}

#pragma mark - 设置导航栏
- (void)setNavigation {
    //导航栏
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"个人信息", nil);
    self.navigationController.navigationBar.tintColor = ThemeColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:ThemeColor, NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)isLoginIn{
    // 判断用户是否在登录状态，如果登录，读取用户信息
    if([[YJ_APIManager sharedInstance] isLoggedIn])
    {
        self.userProfile = [[YJ_APIManager sharedInstance] readProfile];
    }
}

#pragma mark - setUpView
- (void)setUpTableView
{
    [self.view addSubview:self.infoTableView];
   // self.infoTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
}

- (UITableView *)infoTableView
{
    if (!_infoTableView) {
        _infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -26, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _infoTableView.backgroundColor = BGColor;
        [_infoTableView setDelegate:self];
        [_infoTableView setDataSource:self];
        [_infoTableView setRowHeight:45.0];
    }
    return _infoTableView;
}

#pragma mark - initDataSource
- (NSArray *)arrOfData
{
    if (!_arrOfData) {
        _arrOfData =@[
                      @[@{@"iconImage":@"icon_home_steps",
                          @"description":NSLocalizedString(@"头像",nil),
                          @"info":NSLocalizedString(@"未设置",nil)},
                        @{@"iconImage":@"icon_info_num",
                          @"description":NSLocalizedString(@"登录账号",nil),
                          @"info":NSLocalizedString(@"未设置",nil)},
                        @{@"iconImage":@"icon_info_nick",
                          @"description":NSLocalizedString(@"昵称",nil),
                          @"info":NSLocalizedString(@"未设置",nil)},
                        @{@"iconImage":@"icon_info_sex",
                          @"description":NSLocalizedString(@"性别",nil),
                          @"info":NSLocalizedString(@"未设置",nil)},
                        @{@"iconImage":@"icon_info_birth",
                          @"description":NSLocalizedString(@"生日",nil),
                          @"info":NSLocalizedString(@"未设置",nil)},
                        @{@"iconImage":@"icon_info_body",
                          @"description":NSLocalizedString(@"身体档案",nil),
                          @"info":NSLocalizedString(@"",nil)},
                        ],
                      @[@{@"description":NSLocalizedString(@"退出登录",nil)}]
                      ];
    }
    return _arrOfData;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.arrOfData objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrOfData count];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //注册cell
    static NSString *cellIde = @"cellIde";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    switch (indexPath.section) {
        case 0:
        {
            //在第一个分组中，每个cell的公共部分，图标和描述信息
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIImageView *iconImageView = [[UIImageView alloc] init];
            [cell.contentView addSubview:iconImageView];
            
            [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.offset(20);
                make.left.offset(22);
                make.centerY.offset(0);
            }];
            
            UILabel *labDescription = [[UILabel alloc]init];
            labDescription.font = [UIFont systemFontOfSize:16.0];
            labDescription.textAlignment = NSTextAlignmentLeft;
            labDescription.textColor = MainTextColor;
            [cell.contentView addSubview:labDescription];
            
            [labDescription mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(iconImageView.mas_right).with.offset(15);
                make.centerY.offset(0);
                make.width.offset(90);
            }];
            
            iconImageView.image = [UIImage imageNamed:self.arrOfData[0][indexPath.row][@"iconImage"]];
            labDescription.text = self.arrOfData[0][indexPath.row][@"description"];
            
            UILabel *labInfo = [[UILabel alloc] init];
            labInfo.textAlignment = NSTextAlignmentRight;
            labInfo.textColor = [UIColor jk_colorWithWholeRed:150.0 green:150.0 blue:150.0];
            labInfo.font = [UIFont systemFontOfSize:14.0];
            [cell.contentView addSubview:labInfo];
            
            switch (indexPath.row) {
                //设置头像
                case 0:
                {
                    iconImageView.hidden = YES;
                    labDescription.hidden = YES;
                    
                    //cell.accessoryType = UITableViewCellAccessoryNone;
                    self.imgAvatar = [[UIImageView alloc] init];
                    
                    self.imgAvatar.layer.masksToBounds = YES;
                    self.imgAvatar.layer.cornerRadius = USER_AVATARG_HEIGHT/2;
                    self.imgAvatar.layer.borderWidth = 1.0;
                    self.imgAvatar.layer.borderColor = [UIColor jk_colorWithWholeRed:255.0 green:255.0 blue:255.0 alpha:0.3].CGColor;
                    [self.imgAvatar setImageWithURL:[NSURL URLWithString:self.userProfile.userAvatar] placeholderImage:[UIImage imageNamed:@"icon_register_header"]];
                    [cell addSubview:self.imgAvatar];
                    
                    [self.imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.height.offset(USER_AVATARG_HEIGHT);
                        make.centerY.offset(0);
                        make.left.offset(25);
                    }];
                    
                    [labInfo mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(labDescription.mas_right).with.offset(20);
                        make.centerY.offset(0);
                        make.right.offset(0);
                    }];
                    
                    labInfo.text = @"修改头像";

                    return cell;
                }
                    break;
                //用户
                case 1:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    [labInfo mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(labDescription.mas_right).with.offset(20);
                        make.centerY.offset(0);
                        make.right.offset(-20);
                    }];
                    //判断登录状态，显示信息
                    if (![[YJ_APIManager sharedInstance] isLoggedIn])
                    {
                        labInfo.text = self.arrOfData[0][indexPath.row][@"info"];
                    }
                    else
                    {
                        if([self.userProfile.phoneNum isEqualToString:@""]) {
                            labInfo.text = NSLocalizedString(@"NotSet",nil);
                        }else {
                            labInfo.text = self.userProfile.phoneNum;
                        }
                    }
                    return cell;
                }
                    break;
                //设置昵称
                case 2:
                {
                    [labInfo mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(labDescription.mas_right).with.offset(20);
                        make.centerY.offset(0);
                        make.right.offset(0);
                    }];
                    //判断登录状态，显示信息
                    if (![[YJ_APIManager sharedInstance] isLoggedIn])
                    {
                        labInfo.text = self.arrOfData[0][indexPath.row][@"info"];
                    }
                    else
                    {
                        if([self.userProfile.nickName isEqualToString:@""]) {
                            labInfo.text = NSLocalizedString(@"NotSet",nil);
                        }else {
                            labInfo.text = self.userProfile.nickName;
                        }
                    }
                    return cell;
                }
                    break;
                //设置性别
                case 3:
                {
                    [labInfo mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(labDescription.mas_right).with.offset(20);
                        make.centerY.offset(0);
                        make.right.offset(0);
                    }];
                    
                    //判断登录状态，显示信息
                    if (![[YJ_APIManager sharedInstance] isLoggedIn])
                    {
                        labInfo.text = self.arrOfData[0][indexPath.row][@"info"];
                    }
                    else
                    {
                        labInfo.text = self.userProfile.sex;
                    }
                }
                    break;
                //设置生日
                case 4:
                {
                    [labInfo mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(labDescription.mas_right).with.offset(20);
                        make.centerY.offset(0);
                        make.right.offset(0);
                    }];
                    
                    //判断登录状态，显示信息
                    if (![[YJ_APIManager sharedInstance] isLoggedIn])
                    {
                        labInfo.text = self.arrOfData[0][indexPath.row][@"info"];
                    }
                    else
                    {
                        if([self.userProfile.birth isEqualToString:@""]) {
                            labInfo.text = NSLocalizedString(@"NotSet",nil);
                        }else {
                            labInfo.text = self.userProfile.birth;
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UILabel *labDescription = [[UILabel alloc]init];
                    labDescription.font = [UIFont systemFontOfSize:16.0];
                    labDescription.textAlignment = NSTextAlignmentCenter;
                    labDescription.textColor = ThemeColor;
                    [cell addSubview:labDescription];
                    
                    [labDescription mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.offset(0);
                        make.right.offset(0);
                        make.height.offset(20);
                        make.width.offset(SCREEN_WIDTH);
                        make.centerY.offset(0);
                    }];
                    
                    labDescription.text = self.arrOfData[1][indexPath.row][@"description"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //处理不同cell的点击事件
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    //修改头像
                    [self uploadImage];
                }
                    break;
                case 2:
                {
                    //修改昵称
                    YJ_ChangeNicknameViewController *cnvc = [[YJ_ChangeNicknameViewController alloc] init];;
                    [self.navigationController pushViewController:cnvc animated:YES];
                    cnvc.callback =  ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                            [self isLoginIn];
                            [self.infoTableView reloadData];
                        });
                    };
                }
                    break;
                case 3:
                {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                    UIAlertAction *boy = [UIAlertAction actionWithTitle:NSLocalizedString(@"男",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        __weak typeof(self) weakSelf = self;
                        [SVProgressHUD show];
                        [weakSelf.viewModel submitChangeWithSex:@"男" withSuccessBlock:^(id response) {
                            [SVProgressHUD dismiss];
                            [self isLoginIn];
                            [self.infoTableView reloadData];
                        } withFailureBlock:^(NSError *error) {
                            [SVProgressHUD dismiss];
                            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
                        }];
                    }];
                    UIAlertAction *girl = [UIAlertAction actionWithTitle:NSLocalizedString(@"女",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        __weak typeof(self) weakSelf = self;
                        [SVProgressHUD show];
                        [weakSelf.viewModel submitChangeWithSex:@"女" withSuccessBlock:^(id response) {
                            [SVProgressHUD dismiss];
                            [self isLoginIn];
                            [self.infoTableView reloadData];
                        } withFailureBlock:^(NSError *error) {
                            [SVProgressHUD dismiss];
                            [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
                        }];
                    }];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",nil) style:UIAlertActionStyleCancel handler:nil];
                    
                    [alert addAction:boy];
                    [alert addAction:girl];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                    break;
                case 4:
                {
                    YJ_ChangeBirthViewController *cbvc = [[YJ_ChangeBirthViewController alloc] init];;
                    [self.navigationController pushViewController:cbvc animated:YES];
                    cbvc.callback =  ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                            [self isLoginIn];
                            [self.infoTableView reloadData];
                        });
                    };
                }
                    break;
                case 5:
                {
                    YJ_BodyManageViewController *bmvc = [[YJ_BodyManageViewController alloc] init];;
                    [self.navigationController pushViewController:bmvc animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    //退出登录
                    [self logout];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//针对不同cell，计算不同高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            return 80.0;
        }
    }
    
    return 49.0;
}

#pragma mark - setUpHeightForHeaderAndFooter
//设置tableview的section的头部和脚部高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
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

//选择照片完成之后的代理方法
#pragma mark - imagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"info:%@", info);
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
    NSLog(@"imageBase64:%@", decodeStr);
     //7、网络请求
     [self submitAvatar:decodeStr];
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

//点击取消按钮所执行的方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他逻辑操作。就需要实现该代理方法，如果不做任何逻辑操作，就可以不实现
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)submitAvatar:(NSString *)avatar
{
    NSLog(@"%@", avatar);
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [weakSelf.viewModel submitChangeWithAvatar:avatar
                              withSuccessBlock:^(id response) {
                                  [SVProgressHUD dismiss];
                                  [self isLoginIn];
                                  [self.infoTableView reloadData];
                                  /*请求新的数据，更新缓存信息
                                   [weakSelf.viewModel getUserInfoWithSuccessBlock:^(id response) {
                                   [SVProgressHUD dismiss];
                                   } withFailureBlock:^(NSError *error) {
                                   [SVProgressHUD dismiss];
                                   [self showStatusWithError:[self returnCurrentMessageWithErrorCode:[error.userInfo[@"errorNo"] integerValue]]];
                                   }];*/
                              } withFailureBlock:^(NSError *error) {
                                  [SVProgressHUD dismiss];
                                  [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"data"][@"code"] integerValue]]];
                              }];
}

//退出登录
- (void)logout {
    //请求成功，更新数据
    [[YJ_APIManager sharedInstance] logout];
    [self.navigationController popViewControllerAnimated:YES];
    
    /*__weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [weakSelf.viewModel logoutWithSuccessBlock:^(id response) {
        [self.navigationController popViewControllerAnimated:YES];
    } withFailureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf showStatusWithError:[weakSelf returnCurrentMessageWithErrorCode:[error.userInfo[@"errorNo"] integerValue]]];
    }];*/
}

#pragma mark - 返回
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}

//处理手势冲突（父类的手势）
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCell"] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] ) {
        return NO;
    }
    return YES;
}


@end
