//
//  PEAddExpenseTableViewController.h
//  PodioExpenses
//
//  Created by Sebastian Rehnby on 14/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PEAddExpenseViewController;

@protocol PEAddExpenseViewControllerDelegate <NSObject>

- (void)addExpenseController:(PEAddExpenseViewController *)controller didAddExpense:(PKTItem *)expense;

@end

@interface PEAddExpenseViewController : UITableViewController

@property (nonatomic, weak) id<PEAddExpenseViewControllerDelegate> delegate;

@end
