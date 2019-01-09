//
//  FSControlPanelView.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/9.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSControlPanelView.h"
#import "FSLiveNumView.h"
#import "FSLiveStreamChangeView.h"
#import "FSLiveStreamNavigationView.h"
#import "FSLiveDanmakuToolView.h"
#import "FSSharpnessChoseView.h"
#import "FSLiveManager.h"

@interface FSControlPanelView()<FSLiveStreamNavigationViewDelegate, FSSharpnessChoseViewDelegate>
@property (nonatomic, strong) FSLiveStreamNavigationView *navBar; /**<横屏导航栏*/
@property (nonatomic, strong) FSLiveVideoStatusView *stateView; /**<状态视图*/
@property (nonatomic, strong) FSLiveNumView *bottomBar; /**<在线人数 全屏、发消息按钮*/
@property (nonatomic, strong) FSSharpnessChoseView *sharpnessView;  /**<高\标清切换*/
@property (nonatomic, strong) FSLiveStreamChangeView *changeView; /**<音/视频切换按钮*/
@property (nonatomic, strong) FSLiveDanmakuToolView *inputBar;  /**<输入框*/

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) FSLiveStreamMediaType mediaType;
@property (nonatomic, assign) FSSharpnessState sharepnessState;
@end

@implementation FSControlPanelView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void) setupUI {
    __weak typeof(self) weakSelf = self;
    
    /// 导航
    self.navBar = [[NSBundle mainBundle] loadNibNamed:@"FSLiveStreamNavigationView" owner:nil options:nil].lastObject;
    self.navBar.delegate = self;
    [self addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.left.mas_equalTo(0);
        make.height.mas_equalTo(54);
    }];
    //    self.navBar.hidden = true;
    
    /// 未购买、未开始... 状态
    self.stateView = [FSLiveVideoStatusView statusView];
    [self addSubview:self.stateView];
    [self.stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.stateView.hidden = true;
    
    /// 高标清切换
    self.sharpnessView = [[NSBundle mainBundle] loadNibNamed:@"FSSharpnessChoseView" owner:nil options:nil].lastObject;
    self.sharpnessView.delegate = self;
    [self addSubview:self.sharpnessView];
    [self.sharpnessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15);
        make.top.equalTo(self.navBar.mas_top).offset(22);
        make.width.equalTo(@(70));
        make.height.equalTo(@(74));
    }];
    self.sharpnessView.hidden = YES;
    
    /// 音视频切换
    self.changeView = [[NSBundle mainBundle] loadNibNamed:@"FSLiveStreamChangeView" owner:nil options:nil].lastObject;
    [self addSubview:self.changeView];
    [self.changeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(8);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo([FSLiveStreamChangeView changeViewSize]);
    }];
    self.changeView.FSLiveStreamChangeViewAudioBLock = ^{
        [[Zhuge sharedInstance] track:@"直播-音频" properties:@{@"ID": weakSelf.model.ID ?:@"",@"标题": weakSelf.model.title ?:@""}];
        
        weakSelf.mediaType = FSLiveStreamMediaTypeAudio;
        
        [weakSelf fs_controlPanelView:weakSelf liveStreamChange:FSLiveStreamMediaTypeAudio];
        
        weakSelf.sharpnessView.hidden = YES;
        
        [weakSelf.bottomBar enableWave:true];
    };
    self.changeView.FSLiveStreamChangeViewVideoBLock = ^{
        [[Zhuge sharedInstance] track:@"直播-视频" properties:@{@"ID": weakSelf.model.ID ?:@"",@"标题": weakSelf.model.title?:@""}];
        
        weakSelf.mediaType = FSLiveStreamMediaTypeVideo;
        
        [weakSelf fs_controlPanelView:weakSelf liveStreamChange:FSLiveStreamMediaTypeVideo];
        
        weakSelf.sharpnessView.hidden = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? YES : NO;
        
        [weakSelf.bottomBar enableWave:false];
    };
    
    /// 在线人数
    self.bottomBar = [[NSBundle mainBundle] loadNibNamed:@"FSLiveNumView" owner:nil options:nil].lastObject;
    [self addSubview:self.bottomBar];
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo([FSLiveNumView numViewHeight]);
    }];
    
    self.bottomBar.FSLiveNumViewFullBlock = ^{
        [weakSelf fs_controlPanelView:weakSelf fullScreenClick:nil];
    };
    
    self.bottomBar.FSLiveNumViewMessageBlock = ^{
        [weakSelf fs_controlPanelView:weakSelf openInputBarClick:weakSelf.bottomBar];
    };
    
    /// 键盘
    self.inputBar = [FSLiveDanmakuToolView toolView];
    [self addSubview:self.inputBar];
    [self.inputBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self);
        make.height.mas_equalTo([FSLiveDanmakuToolView toolViewHeight]);
    }];
    
//    FSLiveDanmakuToolView *inputBar2 = [FSLiveDanmakuToolView toolView];
//    [self addSubview:inputBar2];
//    [inputBar2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        
//        make.centerY.equalTo(self);
//        make.right.left.equalTo(self);
//        make.height.mas_equalTo([FSLiveDanmakuToolView toolViewHeight]);
//    }];
    
    self.inputBar.actionHidden = ^{
        weakSelf.inputBar.hidden = true;
    };
    self.inputBar.actionSend = ^(NSString *msg) {
        if (weakSelf.model) {
            [[Zhuge sharedInstance] track:@"直播-评论" properties:@{@"ID": weakSelf.model.ID?:@"",@"标题": weakSelf.model.title?:@""}];
        }
        
        [[FSLiveManager sharedChatLive] sendTextMessage:msg result:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf animated:true];
                hud.offset = CGPointMake(0, -(kFSScreenWidth - 215)/2 - 20);
                hud.label.text = @"发送成功";
                hud.mode = MBProgressHUDModeText;
                [hud hideAnimated:true afterDelay:2];
            });
        }];
    };
    self.inputBar.hidden = YES;
    
    self.orientation = UIInterfaceOrientationPortrait;
}

#pragma mark - Setter
- (void)setModel:(FSLiveStreamViewModel *)model {
    _model = model;
}

#pragma mark - Delegate
- (void)fs_navigationView:(FSLiveStreamNavigationView *)nav backClick:(id)sender {
    
    if (self.orientation == UIInterfaceOrientationLandscapeRight) {
        [self updateStateWithOrientation:UIDeviceOrientationPortrait mediaType:FSLiveStreamMediaTypeVideo];
    }

    if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:backClick:)]) {
        [self.delegate fs_controlPanelView:self backClick:sender];
    }
}

- (void)fs_navigationView:(FSLiveStreamNavigationView *)nav danmakuClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:danmakuClick:)]) {
        [self.delegate fs_controlPanelView:self danmakuClick:sender];
    }
}

- (void)fs_navigationView:(FSLiveStreamNavigationView *)nav shareClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:shareClick:)]) {
        [self.delegate fs_controlPanelView:self shareClick:sender];
    }
}

- (void)fs_sharpnessChoseState:(FSSharpnessState)state {
    self.sharepnessState = state;
    
    if ([self.delegate respondsToSelector:@selector(fs_sharpnessChoseState:)]) {
        [self.delegate fs_controlPanelView:self sharpnessClick:@(state)];
    }
}

/// 音\视频
- (void)fs_controlPanelView:(FSControlPanelView *)cpv liveStreamChange:(FSLiveStreamMediaType)sender {
    if (sender == FSLiveStreamMediaTypeAudio) {
        if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:liveStreamChange:)]) {
            [self.delegate fs_controlPanelView:self liveStreamChange:FSLiveStreamMediaTypeAudio];
        }
    } else {
        /// 视频
        if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:liveStreamChange:)]) {
            [self.delegate fs_controlPanelView:self liveStreamChange:FSLiveStreamMediaTypeVideo];
        }
    }
}
/// 全屏按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv fullScreenClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:fullScreenClick:)]) {
        [self.delegate fs_controlPanelView:self fullScreenClick:nil];
    }
}
/// 横屏唤起输入框
- (void)fs_controlPanelView:(FSControlPanelView *)cpv openInputBarClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_controlPanelView:openInputBarClick:)]) {
        [self.delegate fs_controlPanelView:self openInputBarClick:nil];
    }
    
//    [weakSelf bringSubviewToFront:weakSelf.inputBar];
//    weakSelf.inputBar.hidden = NO;
    
    self.inputBar.hidden = false;
    [self bringSubviewToFront:self.inputBar];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.inputBar becomFirst];
    });
}

#pragma mark - Action
- (void)updateStateWithOrientation:(UIInterfaceOrientation)orientation mediaType:(FSLiveStreamMediaType)mediaType {

    self.orientation = orientation;
    
    [self.navBar updateStateWithOrientation:orientation mediaType:mediaType];
    
    self.sharpnessView.hidden = YES;
    if (mediaType == FSLiveStreamMediaTypeVideo) {
        self.sharpnessView.hidden = orientation == UIInterfaceOrientationPortrait ? YES : NO;
    }
    
    if (orientation == UIDeviceOrientationPortrait) {
        self.inputBar.hidden = YES;
    }
}

#pragma mark -
- (void)destoryObject {
    [self.navBar destoryObject];
    [self.stateView destoryObject];
}

@end
