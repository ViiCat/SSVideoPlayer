//
//  FSLiveStreamNavigationView.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/10.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSLiveStreamNavigationView.h"
#import "FSAudioTimerPanelView.h"

@interface FSLiveStreamNavigationView()
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnDanmaku;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (nonatomic, strong) FSAudioTimerPanelView *timerPanelView;    /**<音频时长*/

@property (nonatomic, assign) FSLiveStreamDanmakuState danmakuState;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintsShareLeft;
@end

@implementation FSLiveStreamNavigationView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    self.timerPanelView = [[NSBundle mainBundle] loadNibNamed:@"FSAudioTimerPanelView" owner:nil options:nil].lastObject;
    [self addSubview:self.timerPanelView];
    [self.timerPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
//        make.bottom.equalTo(self.mas_bottom);
    }];
    self.timerPanelView.hidden = YES;
}

#pragma mark - Setter
- (void)setModel:(FSLiveStreamViewModel *)model {
    _model = model;
    
    self.timerPanelView.model = model;
    self.btnDanmaku.hidden = model.state.integerValue == FSLiveStartedState ? NO : YES;
}

#pragma mark - Aciton
- (IBAction)danmakuClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    self.danmakuState = btn.selected ? FSLiveStreamDanmakuStateClose : FSLiveStreamDanmakuStateClose;
    
    if ([self.delegate respondsToSelector:@selector(fs_navigationView:danmakuClick:)]) {
        [self.delegate fs_navigationView:self danmakuClick:self.btnDanmaku];
    }
}

- (IBAction)shareClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_navigationView:shareClick:)]) {
        [self.delegate fs_navigationView:self shareClick:self.btnShare];
    }
}

- (IBAction)backClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_navigationView:backClick:)]) {
        [self.delegate fs_navigationView:self backClick:self.btnBack];
    }
}

- (void)updateStateWithOrientation:(UIInterfaceOrientation)orientation mediaType:(FSLiveStreamMediaType)mediaType {
    
    ///布局
    if (mediaType == FSLiveStreamMediaTypeVideo) {
        self.constraintsShareLeft.constant = orientation == UIInterfaceOrientationPortrait ? 15.0 : 110.0;
    } else {
        self.constraintsShareLeft.constant = 15.0;
    }
    
    ///弹幕
    self.btnDanmaku.hidden = orientation == UIInterfaceOrientationPortrait ? YES : NO;
    
    ///计时器
    self.timerPanelView.hidden = mediaType == FSLiveStreamMediaTypeVideo ? YES : NO;
}

#pragma mark - Other
- (void)destoryObject {
    if (self.timerPanelView) {
        [self.timerPanelView destoryObject];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
