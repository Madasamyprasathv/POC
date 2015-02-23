//
//  PCImageDownloader.h
//  POC
//
//  Created by MSP on 2/23/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCNewsRecord.h"

@interface PCImageDownloader : NSObject
@property (nonatomic, strong) PCNewsRecord *newsRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)imageDownload;


@end
