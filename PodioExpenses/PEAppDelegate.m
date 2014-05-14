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
    // Authenticated but the login screen is still showing. Hide it.
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    self.loginNavController = nil;
  } else if (![PodioKit isAuthenticated] && !self.loginNavController) {
    // Not authenticated but we are not displaying a login screen. Show it.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.loginNavController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavController"];
    
    [self.window.rootViewController presentViewController:self.loginNavController animated:NO completion:nil];
  }
}

- (void)saveToken {
  // Save the token to the keychain. Since all PodioKit model objects automatically
  // supports NSCoding, we can use NSKeyedArchiver to save it as NSData.
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
  // If we were logged in a previous launch of the app, restore that token from the keychain
  if (![PodioKit isAuthenticated]) {
    [PKTClient sharedClient].oauthToken = [self savedToken];
  }
}

#pragma mark - Notifications

- (void)sessionDidChange:(NSNotification *)notification {
  // If the session changed we need to save the new token and see if we need to show the login screen again.
  [self saveToken];
  [self updateLoginScreen];
}

@end
