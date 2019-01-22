//
//  TableCellNode.m
//  AsyncDisplayKitDemo
//
//  Created by teilt on 2019/1/21.
//  Copyright © 2019 teilt. All rights reserved.
//

#import "TableCellNode.h"
#import "PhotoModel.h"

@interface TableCellNode ()<ASNetworkImageNodeDelegate>

@end

@implementation TableCellNode

- (instancetype)initWithData:(id)dataModel;
{
    if (self = [super init]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        PhotoModel *model = (PhotoModel *)dataModel;
        
        ASDisplayNode *bgViewNode = [[ASDisplayNode alloc]init];
        bgViewNode.frame = CGRectMake(0, 0, 375, 360);
        bgViewNode.backgroundColor = [UIColor redColor];
        [self addSubnode:bgViewNode];
        
        
        ASNetworkImageNode *imageViewNode = [[ASNetworkImageNode alloc]init];
        imageViewNode.frame = CGRectMake(10, 10, 355, 340);
        imageViewNode.backgroundColor = [UIColor greenColor];
        imageViewNode.URL = [NSURL URLWithString:model.imgUrl];
        imageViewNode.delegate = self;
        imageViewNode.contentMode = UIViewContentModeScaleAspectFill;
        [bgViewNode addSubnode:imageViewNode];
        
        ASTextNode *labelNode = [[ASTextNode alloc]init];
        labelNode.frame = CGRectMake(20, 150, 260, 30);
        labelNode.attributedText = [[NSAttributedString alloc]initWithString:model.text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                        NSForegroundColorAttributeName : [UIColor blackColor], NSBackgroundColorAttributeName : [UIColor clearColor]}];
        [bgViewNode addSubnode:labelNode];
        
    }
    return self;
}

#pragma mark - ASNetworkImageNodeDelegate

//Notification that the image node finished downloading an image.
- (void)imageNode:(ASNetworkImageNode *)imageNode didLoadImage:(UIImage *)image
{
    
}

//Notification that the image node started to load
- (void)imageNodeDidStartFetchingData:(ASNetworkImageNode *)imageNode
{
    
}

//Notification that the image node failed to download the image.
- (void)imageNode:(ASNetworkImageNode *)imageNode didFailWithError:(NSError *)error
{
    
}

//Notification that the image node finished decoding an image.
- (void)imageNodeDidFinishDecoding:(ASNetworkImageNode *)imageNode
{
    
}
@end
