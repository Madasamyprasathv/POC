//
//  PCNewsTableViewCell.m
//  POC
//
//  Created by MSP on 2/23/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import "PCNewsTableViewCell.h"

#define kFontString @"Times New Roman"

@implementation PCNewsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)] autorelease];
        self.titleLabel.textColor = [UIColor colorWithRed:39.0/255.0f green:64.0/255.0f blue:129.0/255.0f alpha:1.0f];
        self.titleLabel.numberOfLines =0;
        [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        self.titleLabel.font = [UIFont fontWithName:kFontString size:20.0f];
        [self addSubview:self.titleLabel];
        
        self.descriptionLabel = [[[UILabel alloc] init] autorelease];
        self.descriptionLabel.textColor = [UIColor blackColor];
        self.descriptionLabel.numberOfLines=0;
        self.descriptionLabel.font = [UIFont fontWithName:kFontString size:12.0f];
        [self.descriptionLabel sizeToFit];
        [self addSubview:self.descriptionLabel];
        
        self.newsImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(210, 40, 80, 70)] autorelease];
        [self addSubview:self.newsImageView];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
