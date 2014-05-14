//
//  PEAppDelegate.m
//  PodioExpenses
//
//  Created by Sebastian Rehnby on 13/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import <FXKeychain/FXKeychain.h>
#import "PEAppDelegate.h"

static NSString * const kTokenKey = @"PodioExpensesToken";

@interface PEAppDelegate ()

@property (nonatomic, weak) UINavigationController *loginNavController;

@end

@implementation PEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [PodioKit setupWithAPIKey:PODIO_KEY secret:PODIO_SECRET];
  
  [self restoreTokenIfNeeded];
  [self setupNotifications];
  
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [self restoreTokenIfNeeded];
  [self updateLoginScreen];
}

#pragma mark - Private

- (void)setupNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(sessionDidChange:)
                                               name:PKTClientAuthenticationStateDidChangeNotification
                                             object:nil];
}

- (void)updateLoginScreen {
  if ([PodioKit isAuthenticated] && self.loginNavController) {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    self.loginNavController = nil;
  } else if (![PodioKit isAuthenticated] && !self.loginNavController) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.loginNavController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavController"];
    
    [self.window.rootViewController presentViewController:self.loginNavController animated:NO completion:nil];
  }
}

- (void)saveToken {
  PKTOAuth2Token *token = [PKTClient sharedClient].oauthToken;
  NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
  if (tokenData) {
    [[FXKeychain defaultKeychain] setObject:tokenData forKey:kTokenKey];
  }
}

- (PKTOAuth2Token *)savedToken {
  NSData *tokenData = [[FXKeychain defaultKeychain] objectForKey:kTokenKey];
  
  PKTOAuth2Token *token = nil;
  if (tokenData) {
    token = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
  }
  
  return token;
}

- (void)restoreTokenIfNeeded {
  if (![PodioKit isAuthenticated]) {
    [PKTClient sharedClient].oauthToken = [self savedToken];
  }
}

#pragma mark - Notifications

- (void)sessionDidChange:(NSNotification *)notification {
  [self saveToken];
  [self updateLoginScreen];
}

@end
