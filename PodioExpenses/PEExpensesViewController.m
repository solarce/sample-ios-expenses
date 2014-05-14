//
//  PEExpensesViewController.m
//  PodioExpenses
//
//  Created by Sebastian Rehnby on 14/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "PEExpensesViewController.h"
#import "PEAddExpenseViewController.h"

static NSNumberFormatter *moneyFormatter = nil;

@interface PEExpensesViewController () <PEAddExpenseViewControllerDelegate>

@property (nonatomic, copy) NSArray *expenses;

@end

@implementation PEExpensesViewController

+ (void)initialize {
  if (self == [PEExpensesViewController class]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      moneyFormatter = [[NSNumberFormatter alloc] init];
      moneyFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
  }
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self refreshExpenses];
}

#pragma mark - Private

- (IBAction)refreshExpenses {
  if (![PodioKit isAuthenticated]) {
    // Not authenticated, don't even try refreshing
    return;
  };
  
  [SVProgressHUD showWithStatus:@"Loading expenses..."];
  
  PEExpensesViewController __weak *weakSelf = self;
  [PKTItem fetchItemsInAppWithID:PODIO_APP_ID offset:0 limit:20 completion:^(NSArray *items, NSUInteger filteredCount, NSUInteger totalCount, NSError *error) {
    PEExpensesViewController __strong *strongSelf = weakSelf;
    
    [SVProgressHUD dismiss];
    
    strongSelf.expenses = items;
    [strongSelf.tableView reloadData];
  }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.expenses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString * const identifier = @"ExpenseCell";
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
  
  PKTItem *expense = self.expenses[indexPath.row];
  PKTMoney *money = expense[@"amount-2"];
  NSString *amountString = [moneyFormatter stringFromNumber:money.amount];
  
  cell.textLabel.text = expense.title;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", amountString, money.currency];
  
  return cell;
}

#pragma mark - PEAddExpenseViewControllerDelegate

- (void)addExpenseController:(PEAddExpenseViewController *)controller didAddExpense:(PKTItem *)expense {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Make sure this VC is the delegate to be notified when a new expense is created in order
  // to dismiss the presented VC.
  if ([segue.identifier isEqualToString:@"AddExpense"]) {
    UINavigationController *navController = segue.destinationViewController;
    PEAddExpenseViewController *controller = (PEAddExpenseViewController *)navController.topViewController;
    controller.delegate = self;
  }
}

// This empty method is needed for the segue to be able to be unwinded. Don't ask me why.
- (IBAction)closeAddExpense:(UIStoryboardSegue *)segue {}

@end
