//
//  NormalTableViewCell.h
//  AsyncDisplayKitDemo
//
//  Created by teilt on 2019/1/22.
//  Copyright © 2019 teilt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoModel;
NS_ASSUME_NONNULL_BEGIN

@interface NormalTableViewCell : UITableViewCell

@property(nonatomic ,strong) PhotoModel *dataModel;

@end

NS_ASSUME_NONNULL_END
