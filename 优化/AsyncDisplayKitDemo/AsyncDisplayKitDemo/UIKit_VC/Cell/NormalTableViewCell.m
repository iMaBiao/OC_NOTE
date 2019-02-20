//
//  NormalTableViewCell.m
//  AsyncDisplayKitDemo
//
//  Created by teilt on 2019/1/22.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "NormalTableViewCell.h"
#import "PhotoModel.h"
#import <UIImageView+WebCache.h>
@interface NormalTableViewCell()

@property(nonatomic ,strong) UIView *bgView;
@property(nonatomic ,strong) UIImageView *imgView;
@property(nonatomic ,strong) UILabel *label;

@end

@implementation NormalTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *bgView = [[UIView alloc]init];
        bgView.frame = CGRectMake(0, 0, 375, 360);
        bgView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:bgView];
        self.bgView = bgView;
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(10, 10, 355, 340);
        imageView.backgroundColor = [UIColor greenColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:imageView];
        self.imgView = imageView;
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(20, 150, 260, 30);
        [bgView addSubview:label];
        self.label = label;
        
    }
    return self;
}
- (void)setDataModel:(PhotoModel *)dataModel
{
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:dataModel.imgUrl] placeholderImage:nil];
    
        self.label.attributedText = [[NSAttributedString alloc]initWithString:dataModel.text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName : [UIColor blackColor], NSBackgroundColorAttributeName : [UIColor clearColor]}];
}

@end
