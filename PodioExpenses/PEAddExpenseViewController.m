//
//  PEAddExpenseTableViewController.m
//  PodioExpenses
//
//  Created by Sebastian Rehnby on 14/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "PEAddExpenseViewController.h"

static NSString * const kPhotoImageName = @"Receipt.jpg";

@interface PEAddExpenseViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (nonatomic, strong) UIImage *photoImage;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;

@end

@implementation PEAddExpenseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self updatePhotoLabel];
}

#pragma mark Actions

- (IBAction)saveExpense {
  NSString *title = self.titleTextField.text;
  NSNumber *amountValue = @([self.amountTextField.text floatValue]);
  PKTMoney *amount = [[PKTMoney alloc] initWithAmount:amountValue currency:@"USD"];
  
  [SVProgressHUD showWithStatus:@"Saving expense..."];
  
  PEAddExpenseViewController __weak *weakSelf = self;
  
  // First, upload the image file
  NSData *imageData = UIImageJPEGRepresentation(self.photoImage, 0.8f);
  [[[PKTFile uploadWithData:imageData fileName:kPhotoImageName] pipe:^PKTAsyncTask *(PKTFile *file) {
    [SVProgressHUD dismiss];
    
    PKTItem *item = [PKTItem itemForAppWithID:PODIO_APP_ID];
    item[@"title"] = title;
    item[@"amount"] = amount;
    item[@"receipt"] = file;
    
    return [item save];
  }] onSuccess:^(PKTItem *item) {
    [weakSelf didAddExpense:item];
    
    [SVProgressHUD dismiss];
  } onError:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:@"Failed to save expense."];
  }];
}

- (IBAction)addPhoto:(id)sender {
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  controller.delegate = self;
  
  [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Private

- (void)updatePhotoLabel {
  self.photoLabel.text = self.photoImage ? kPhotoImageName : @"Add photo of receipt...";
}

- (void)didAddExpense:(PKTItem *)item {
  if ([self.delegate respondsToSelector:@selector(addExpenseController:didAddExpense:)]) {
    [self.delegate addExpenseController:self didAddExpense:item];
  }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  self.photoImage = info[UIImagePickerControllerOriginalImage];
  [self updatePhotoLabel];
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
