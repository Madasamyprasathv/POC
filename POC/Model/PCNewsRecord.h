//
//  PCNewsRecord.h
//  POC
//
//  Created by MSP on 2/23/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCNewsRecord : NSObject

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) UIImage *iconImage;

@end
