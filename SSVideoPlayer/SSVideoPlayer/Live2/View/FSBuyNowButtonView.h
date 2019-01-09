//
//  FSBuyNowButtonView.h
//  FSZX
//
//  Created by Liu Jie on 2018/8/14.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FSBuyNowButtonViewDelegate<NSObject>
- (void)fs_BuyNow;
@end

@interface FSBuyNowButtonView : UIView
@property (nonatomic, weak) id<FSBuyNowButtonViewDelegate> delegate;
@property (nonatomic, strong) NSNumber *price;
@end
