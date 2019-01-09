//
//  FSBuyNowButtonView.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/14.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSBuyNowButtonView.h"
#import "UIImage+Extension.h"

@interface FSBuyNowButtonView()
@property (weak, nonatomic) IBOutlet UIButton *btnBuyNow;
@end

@implementation FSBuyNowButtonView
- (IBAction)buy:(id)sender {
    if ([self.delegate respondsToSelector:@selector(fs_BuyNow)]) {
        [self.delegate fs_BuyNow];
    }
}

- (void)setPrice:(NSNumber *)price {
    _price = price;
    [self.btnBuyNow setTitle:[NSString stringWithFormat:@"立即购买￥%.2f", [price floatValue]] forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.btnBuyNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnBuyNow setTitleColor:RGB(199, 199, 199) forState:UIControlStateDisabled];
    [self.btnBuyNow setBackgroundImage:[UIImage imageWithColor:GGColor] forState:UIControlStateNormal];
    [self.btnBuyNow setBackgroundImage:[UIImage imageWithColor:RGB(233, 233, 233)] forState:UIControlStateDisabled];
    self.btnBuyNow.layer.cornerRadius = 4.0f;
    self.btnBuyNow.layer.masksToBounds = true;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
