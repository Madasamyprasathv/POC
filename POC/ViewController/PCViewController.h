//
//  PCViewController.h
//  POC
//
//  Created by MSP on 2/23/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCNewsRecord.h"

@interface PCViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) NSMutableArray *contentArray;
@property(nonatomic, retain) UITableView *newsTableView;

@end
