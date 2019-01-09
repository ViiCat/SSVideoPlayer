//
//  FSSharpnessChoseView.h
//  FSZX
//
//  Created by Liu Jie on 2018/8/10.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FSSharpnessState) {
    FSSharpnessStateNormal, /**<标清*/
    FSSharpnessStateHigh,   /**<高清*/
};

@protocol FSSharpnessChoseViewDelegate<NSObject>
- (void)fs_sharpnessChoseState:(FSSharpnessState)state;
@end

/// 高/标清切换
@interface FSSharpnessChoseView : UIView
@property (nonatomic, weak) id<FSSharpnessChoseViewDelegate> delegate;
@property (nonatomic, assign, readonly) FSSharpnessState state;
- (void)reset;
@end
