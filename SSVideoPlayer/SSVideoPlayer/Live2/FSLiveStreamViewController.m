//
//  FSLiveStreamViewController.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/9.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSLiveStreamViewController.h"
#import "UIImage+Extension.h"
#import "FSLiveChatContainerController.h"
#import "FSLivePlayerView.h"
#import "FSDanmakuView.h"
#import "FSControlPanelView.h"
#import "FSBuyNowButtonView.h"
#import "FSVODActionView.h"
#import "FSNewBuyView.h"
#import "FSMediaRequest.h"
#import "FSLiveManager.h"
#import "FSLiveAdView.h"
#import "FSLiveStreamAdWebView.h"
#import "XLLiveHome.h"

@interface FSLiveStreamViewController ()<FSControlPanelViewDelegate,FSBuyNowButtonViewDelegate>
@property (nonatomic, strong) FSLivePlayerView *player; /**<播放器*/
@property (nonatomic, strong) FSDanmakuView *danmakuView;   /**<弹幕*/
@property (nonatomic, strong) FSControlPanelView *controlPanleView; /**<工具栏*/
@property (nonatomic, strong) FSLiveChatContainerController *chatView;  /**<主讲互动部分*/
@property (nonatomic, strong) FSLiveAdView *adButton;   /**<悬浮广告按钮*/
@property (nonatomic, strong) FSLiveStreamAdWebView *adWebView; /**<广告View*/
@property (nonatomic, strong) FSBuyNowButtonView *buyButtonView;    /**<购买按钮*/
@property (nonatomic, assign) BOOL is_ad;   /**<是否有广告*/

@property (nonatomic, assign) NSTimeInterval entranceTime;
@property (nonatomic, assign) NSTimeInterval leaveTime;
@end


#define mpCustomVC_H kFSScreenWidth *(9.0 / 16.0)
@implementation FSLiveStreamViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[FSMediaBarManager sharedInstance] fs_mediaBarHideAndPlayerPause];
    [[FSMediaBarManager sharedInstance] hideAllAnimated:YES];
    
    [self.view endEditing:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self requestData:nil];
    [self.player play];
    
    self.entranceTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self.player pause];
    [self transformToNormal];
    
    self.leaveTime = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *zhugeDict = @{}.mutableCopy;
    zhugeDict[@"类别"] = @"直播";
    zhugeDict[@"类别ID"] = self.model.ID;
    zhugeDict[@"类别标题"] = self.model.title;
    zhugeDict[@"时长"] = [NSString stringWithFormat:@"%.0f", self.leaveTime - self.entranceTime];
    if (self.leaveTime - self.entranceTime > 15) {
        [[Zhuge sharedInstance] track:@"总播放时长" properties:zhugeDict];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    [self requestData:nil];
    [self setupUI];
    [self addNotification];
    [self setupLiveButtonUI];
    [self updateUI];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
            [MBProgressHUD fs_showMessage:@"网络不给力"];
        }
    }];
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable
        || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        [MBProgressHUD fs_showMessage:@"网络不给力"];
    }
    
    [[Zhuge sharedInstance] track:@"直播-详情" properties:@{@"ID": self.model.ID,@"标题": self.model.title}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)setupUI {
    
    if (!self.player) {
        self.player = [[FSLivePlayerView alloc] init];
        [self.view addSubview:self.player];
        [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([[UIDevice currentDevice] isX]) {
                make.top.mas_equalTo(iPhoneXPortraitTopPadding);
            }
            else {
                make.top.mas_equalTo(0);
            }
            
            make.right.left.mas_equalTo(0);
            make.height.mas_equalTo(mpCustomVC_H);
        }];
    }
    
    if (!self.danmakuView) {
        self.danmakuView = [[FSDanmakuView alloc] init];
        [self.view addSubview:self.danmakuView];
        [self.danmakuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(@(50));
        }];
    }
    self.danmakuView.hidden = YES;
    
    if (!self.controlPanleView) {
        self.controlPanleView = [[FSControlPanelView alloc] init];
        self.controlPanleView.delegate = self;
        [self.view addSubview:self.controlPanleView];
        [self.controlPanleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.player);
        }];
    }

    if (!self.buyButtonView) {
        self.buyButtonView = [[NSBundle mainBundle] loadNibNamed:@"FSBuyNowButtonView" owner:nil options:nil].lastObject;
        self.buyButtonView.delegate = self;
        [self.view addSubview:self.buyButtonView];
        [self.buyButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(0);
            make.height.mas_equalTo([FSVODActionView unbuyHeight]);
            if ([[UIDevice currentDevice] isX]) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                }
                else {
                    make.bottom.equalTo(self.view.mas_bottom);
                }
            }
            else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }];
    }
    self.buyButtonView.hidden = YES;
    
    if (!self.chatView) {
        BOOL isfree = [self.model isFree];
        self.chatView = [FSLiveChatContainerController new];
        [self addChildViewController:self.chatView];
        [self.view addSubview:self.chatView.view];
        [self.chatView.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.controlPanleView.mas_bottom);
            make.right.left.mas_equalTo(0);
            if (!isfree) {
                make.bottom.equalTo(self.buyButtonView.mas_top);
            }
            else {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                }
                else {
                    make.bottom.equalTo(self.view);
                }
            }
        }];
    }
    
    if (!self.adButton) {
        self.adButton = [[NSBundle mainBundle] loadNibNamed:@"FSLiveAdView" owner:nil options:nil].lastObject;
        
        self.adButton.liveAdClickBlock = ^(id data) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"k_Notification_Ad_Click" object:nil];
        };
        [self.view addSubview:self.adButton];
        [self adButtonLayoutWithOrientation:UIInterfaceOrientationPortrait];
    }
    self.adButton.hidden = YES;
    
    if (!self.adWebView) {
        self.adWebView = [[NSBundle mainBundle] loadNibNamed:@"FSLiveStreamAdWebView" owner:nil options:nil].lastObject;
        self.adWebView.target = self;
        [self.view addSubview:self.adWebView];
        [self.adWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.player.mas_bottom);
            make.right.left.mas_equalTo(0);
            
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }
            else {
                make.bottom.equalTo(self.view);
            }
        }];
    }
    self.adWebView.hidden = YES;
}


- (void)updateUI
{
    
    //    [self.view bringSubviewToFront:self.liveButton];
    
    self.buyButtonView.layer.masksToBounds = true;
    [self.buyButtonView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        if (1){//}([self.model isFree] || ![self.model enableBuyButton]) {
            make.height.mas_equalTo(CGFLOAT_MIN);
        }
        else {
            make.height.mas_equalTo([FSVODActionView unbuyHeight]);
        }
        if ([[UIDevice currentDevice] isX]) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }
            else {
                make.bottom.equalTo(self.view.mas_bottom);
            }
        }
        else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    self.player.liveModel = self.model;
    
    //    if (self.model.state.integerValue != FSLiveStartedState) {
    //        self.navigationController.navigationBar.alpha = 1.0f;
    //    }
}

#pragma mark 播主按钮
- (void)setupLiveButtonUI {
    if (![FSLoginTool isLogin]) {
        return;
    }
    if (self.model.state == FSLiveEndedState) {
        return;
    }
    if (self.model) {
        return;
    }
    
    FSUserInfoModel *user = [FSUserInfoManager sharedManager].user;
    for (NSDictionary *dic in self.model.members) {
        BOOL b = [@(user.userId) compare:dic[@"member_id"]];
        if (b) {
        }
        else {
            UIButton *liveButton = [UIButton new];
            [liveButton setBackgroundColor:[UIColor clearColor]];
            
            [liveButton setImage:[UIImage imageNamed:@"live_button_normal"] forState:UIControlStateNormal];
            [[liveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                XLLiveHome *VC = [[XLLiveHome alloc] init];
                VC.hidesBottomBarWhenPushed = YES;
                VC.model = self.model;
                VC.dicmodel = dic;
                [self.navigationController pushViewController:VC animated:YES];
            }];
            
            [self.view addSubview:liveButton];
            [liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view).offset(-20);
                if ([[UIDevice currentDevice] isX]) {
                    make.bottom.equalTo(self.view).offset(-130 - iPhoneXPortraitTopPadding);
                }
                else {
                    make.bottom.equalTo(self.view).offset(-130);
                }
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
            break;
        }
    }
}

#pragma mark - Notification
- (void)addNotification {
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    ///
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        [weakSelf requestData:nil];
    }];
    
    /// 退出
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"fs_notification_exit_live_detail" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        [[FSURLManager manager] sendRequest:[[FSVodIndexLeaveRequest alloc] initWithID:weakSelf.model.ID.integerValue] complete:nil];
        [weakSelf destoryObject];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    
#ifdef DEBUG
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        KKLog(@"%@", x.userInfo);
    }];
#endif
    
    /// 用户信息改变
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kUserInfoChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        if (![FSLoginTool isLogin]) {
            [weakSelf destoryObject];
        }
    }];

    /// 后台推送 直播状态更改
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:FSLiveDidRecvLiveStateChangeNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf requestData:nil];
        });
    }];
    
    /// 悬浮广告
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:FSLiveAdNotifcation object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        
        RCRichContentMessage *msg = (RCRichContentMessage *)x.object;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.adButton.imgIcon sd_setImageWithURL:[NSURL URLWithString:msg.imageURL]];
                self.adButton.strTitle = msg.title;
                self.adButton.adUrl = msg.url;

                if (msg.url.length > 0 && msg.imageURL.length > 0 && msg.title.length > 0) {
                    self.is_ad = YES;
                    BOOL hidden = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? YES : NO;
                    self.adButton.hidden = hidden;
                } else {
                    self.is_ad = NO;
                    self.adButton.hidden = YES;
                }

                [self.view bringSubviewToFront:self.adButton];
            });
        });
    }];
}

#pragma mark - Request
- (void)requestData:(dispatch_block_t)completion {
    FSVodIndexDetailRequest *detail = [[FSVodIndexDetailRequest alloc] initWithID:self.model.ID.integerValue];
    [[FSURLManager manager] sendRequest:detail complete:^(FSResponse * _Nullable response) {
        if (response.status == FSNewResponseStatusSuccess) {

            XLZBModel *model = [[XLZBModel alloc] initWithdic:response.content];
//            FSLiveStreamViewModel *model = [FSLiveStreamViewModel mj_objectWithKeyValues:response.content];
            self.model = model;
            [self.chatView updateModel:model];
            [self updateUI];
            if (completion) {
                completion();
            }
        }
        else {
            KKLog(@"获取直播详情失败");
            if (completion) {
                [MBProgressHUD fs_showMessage:@"获取直播详情失败"];
            }
        }
    }];
}

#pragma mark - Setter

#pragma mark - Delegate
/// 返回按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv backClick:(id)sender {
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self transformPlayer];
    }

}
/// 弹幕按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv danmakuClick:(id)sender {
    KKLog(@">>>>>>>>>>>>>>>>>:%@", sender);
}
/// 分享按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv shareClick:(id)sender {}
/// 高\标清
- (void)fs_controlPanelView:(FSControlPanelView *)cpv sharpnessClick:(id)sender {}
/// 音\视频
- (void)fs_controlPanelView:(FSControlPanelView *)cpv liveStreamChange:(FSLiveStreamMediaType)sender {
    [self.controlPanleView updateStateWithOrientation:self.controlPanleView.orientation mediaType:self.controlPanleView.mediaType];
}

/// 全屏按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv fullScreenClick:(id)sender {
    
    [self.controlPanleView updateStateWithOrientation:UIInterfaceOrientationLandscapeRight mediaType:self.controlPanleView.mediaType];
    
    [self transformPlayer];
}
/// 横屏唤起输入框
- (void)fs_controlPanelView:(FSControlPanelView *)cpv openInputBarClick:(id)sender {}

#pragma mark 购买
- (void)fs_BuyNow {
    __weak typeof(self) weakSelf = self;
    [[FSNewBuyView sharedFSNewBuyView] showBuyViewWithBuyInfoSetting:^(FSBuyModel *buyModel) {
        buyModel.target_type = FSBuyTargetTypeVod;
        buyModel.target_id =  weakSelf.model.ID;
        buyModel.num = 1;
    } Completion:^(FSNewPayResult result, NSString *message) {
        if (result == FSNewPayResultSuccess) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"购买成功！" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction *action) {
                                                        [weakSelf requestData:nil];
                                                        [[FSUserInfoManager sharedManager] fetchUserInfoFromServer];
                                                    }]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }else {
            [MBProgressHUD fs_showDetailMessage:message];
        }
    } inController:self];
}

#pragma mark - 旋转 转屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.controlPanleView.orientation == UIInterfaceOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)transformPlayer
{
    if (self.player.isFullScreen) {
        /// 竖屏
        self.chatView.view.hidden = NO;
        
        self.danmakuView.hidden = YES;
        [self.danmakuView stop];
        
        [self transformToNormal];
        [self adButtonLayoutWithOrientation:UIInterfaceOrientationPortrait];
        
    }
    else {
        /// 横屏
        NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:UIStatusBarAnimationFade];
        
        [self.danmakuView start];
        
        self.chatView.view.hidden = YES;
        
        self.danmakuView.hidden = NO;
        [self.danmakuView start];
        
        [self.player updateFullScreen:YES];
        
        [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        [self adButtonLayoutWithOrientation:UIInterfaceOrientationLandscapeRight];
        
    }
}

- (void)transformToNormal {
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
    
    [self.danmakuView stop];
    
    [self.player updateFullScreen:NO];
    
    [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([[UIDevice currentDevice] isX]) {
            make.top.mas_equalTo(iPhoneXPortraitTopPadding);
        }
        else {
            make.top.mas_equalTo(0);
        }
        make.right.left.mas_equalTo(0);
        make.height.mas_equalTo(mpCustomVC_H);
    }];
}


//- (void)transformScreen
//{
//    if (self.controlPanleView.orientation == UIInterfaceOrientationLandscapeRight) {
//
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationUnknown] forKey:@"orientation"];
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
//
//        [self.controlPanleView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
//        //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
//        [self statusBarHidden];
//        [self navBarHidden];
//
//    }
//    else {
//
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationUnknown] forKey:@"orientation"];
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
//
//        [self.controlPanleView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            if ([[UIDevice currentDevice] isX]) {
//                make.top.mas_equalTo(iPhoneXPortraitTopPadding);
//            }
//            else {
//                make.top.mas_equalTo(0);
//            }
//            make.right.left.mas_equalTo(0);
//            make.height.mas_equalTo(mpCustomVC_H);
//        }];
//
//        //        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
//        [self statusBarShow];
//    }
//}

- (void)adButtonLayoutWithOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        [self.adButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.player.mas_right).offset(-7);
            make.bottom.equalTo(self.player.mas_bottom).offset(-40);
            make.width.equalTo(@(66));
            make.height.equalTo(@(90));
        }];
        
        self.adButton.hidden = self.is_ad ? NO : YES;
        
    } else {
        self.adButton.hidden = YES;
        //        [self.adButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.right.equalTo(self.view.mas_right);
        //            make.bottom.equalTo(self.view.mas_bottom).offset(-100);
        //            make.width.equalTo(@(80));
        //            make.height.equalTo(@(100));
        //        }];
    }
    [self.view bringSubviewToFront:self.adButton];
}

- (void)statusBarHidden {
    [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:UIStatusBarAnimationFade];
}

- (void)statusBarShow {
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
}

- (void)navBarHidden {
    [self.navigationController setNavigationBarHidden:true animated:YES];
}

- (void)navBarShow {
    [self.navigationController setNavigationBarHidden:false animated:YES];
}

#pragma mark - Other
- (void)destoryObject
{
    [self.player stop];
    [self.player destoryObject];
    NSString *roomid = [FSLiveManager sharedChatLive].currentChatroom;
    [[FSLiveManager sharedChatLive] exitChatRoom:roomid success:nil error:nil];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
