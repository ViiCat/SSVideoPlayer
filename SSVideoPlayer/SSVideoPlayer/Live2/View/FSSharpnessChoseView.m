//
//  FSSharpnessChoseView.m
//  FSZX
//
//  Created by Liu Jie on 2018/8/10.
//  Copyright © 2018年 FO Software Information Technology (Shanghai) Co.,Ltd. All rights reserved.
//

#import "FSSharpnessChoseView.h"
@interface FSSharpnessChoseView()
@property (nonatomic, assign) FSSharpnessState state;

@property (weak, nonatomic) IBOutlet UIButton *btnFirst;
@property (weak, nonatomic) IBOutlet UIButton *btnSecond;
@end

@implementation FSSharpnessChoseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        UIView *containerView = [[NSBundle mainBundle] loadNibNamed:@"FSSharpnessChoseView" owner:self options:nil].lastObject;
//        [self addSubview:containerView];
//        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self);
//        }];
//    }
//    return self;
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI {
    [self.btnFirst setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.btnFirst setTitle:@"标清" forState:UIControlStateNormal];
    self.btnFirst.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.btnFirst.titleLabel setFont:[UIFont systemFontOfSize:12]];
    self.btnFirst.layer.cornerRadius = 16.5;
    self.btnFirst.layer.masksToBounds = true;
    
    [self.btnSecond setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.btnSecond setTitle:@"高清" forState:UIControlStateNormal];
    self.btnSecond.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.btnSecond.titleLabel setFont:[UIFont systemFontOfSize:12]];
    self.btnSecond.layer.cornerRadius = 16.5;
    self.btnSecond.layer.masksToBounds = true;
}

#pragma mark - Action
- (IBAction)buttonClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if (self.btnFirst.selected) {
        /// result
        self.btnFirst.selected = NO;
        self.btnSecond.hidden = YES;
        
        self.state = [btn.titleLabel.text isEqualToString:@"标清"] ? FSSharpnessStateNormal : FSSharpnessStateHigh;
        
        [self.btnFirst setTitle:btn.titleLabel.text forState:UIControlStateNormal];
        NSString *title = self.state == FSSharpnessStateNormal ? @"高清" : @"标清";
        [self.btnSecond setTitle:title forState:UIControlStateNormal];
        
        if ([self.delegate respondsToSelector:@selector(fs_sharpnessChoseState:)]) {
            [self.delegate fs_sharpnessChoseState:self.state];
        }
        
    } else {
        /// display
        self.btnFirst.selected = YES;
        self.btnSecond.hidden = NO;
    }
}

#pragma mark - Other
- (void)reset {
    self.btnFirst.selected = NO;
    self.btnSecond.hidden = YES;
    
    [self.btnFirst setTitle:@"标清" forState:UIControlStateNormal];
    [self.btnSecond setTitle:@"高清" forState:UIControlStateNormal];
    
    self.state = FSSharpnessStateNormal;
}
@end
