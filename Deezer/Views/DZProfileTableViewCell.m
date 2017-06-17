//
//  DZProfileTableViewCell.m
//  Deezer
//
//  Created by Vladimir Deriglazov on 18.06.17.
//  Copyright © 2017 Vladimir Deriglazov. All rights reserved.
//

#import "DZProfileTableViewCell.h"

@interface DZProfileTableViewCell ()
@property (nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation DZProfileTableViewCell

- (void)setText:(NSString *)text
{
    self.label.text = text;
}

- (NSString *)text
{
    return self.label.text;
}

@end
