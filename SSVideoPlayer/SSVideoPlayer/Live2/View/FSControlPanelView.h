//
//  FSControlPanelView.h
//  FSZX
//
//  Created by Liu Jie on 2018/8/9.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSLiveStreamViewModel.h"
#import "FSLiveVideoStatusView.h"
#import "FSSharpnessChoseView.h"

@class FSControlPanelView;
@protocol FSControlPanelViewDelegate<NSObject>
/// 返回按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv backClick:(id)sender;
/// 弹幕按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv danmakuClick:(id)sender;
/// 分享按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv shareClick:(id)sender;
/// 高\标清
- (void)fs_controlPanelView:(FSControlPanelView *)cpv sharpnessClick:(id)sender;
/// 音\视频
- (void)fs_controlPanelView:(FSControlPanelView *)cpv liveStreamChange:(FSLiveStreamMediaType)sender;
/// 全屏按钮
- (void)fs_controlPanelView:(FSControlPanelView *)cpv fullScreenClick:(id)sender;
/// 横屏唤起输入框
- (void)fs_controlPanelView:(FSControlPanelView *)cpv openInputBarClick:(id)sender;
@end

/// 控制面板
@interface FSControlPanelView : UIView
@property (nonatomic, weak) id<FSControlPanelViewDelegate> delegate;
@property (nonatomic, strong) FSLiveStreamViewModel *model;

@property (nonatomic, assign, readonly) UIInterfaceOrientation orientation;
@property (nonatomic, assign, readonly) FSLiveStreamMediaType mediaType;
@property (nonatomic, assign, readonly) FSSharpnessState sharepnessState;

- (void)updateStateWithOrientation:(UIInterfaceOrientation)orientation mediaType:(FSLiveStreamMediaType)mediaType;

- (void)destoryObject;  /**<销毁*/
@end
