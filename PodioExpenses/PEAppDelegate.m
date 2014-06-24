//
//  PEAppDelegate.m
//  PodioExpenses
//
//  Created by Sebastian Rehnby on 13/05/14.
//  Copyright (c) 2014 Citrix Systems, Inc. All rights reserved.
//

#import "PEAppDelegate.h"

static NSString * const kTokenKey = @"PodioExpensesToken";

@interface PEAppDelegate ()

@property (nonatomic, weak) UINavigationController *loginNavController;

@end

@implementation PEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // In order to talk to the Podio API, PodioKit needs to know your API key and secret.
  // For more info, see https://developers.podio.com/api-key
  [PodioKit setupWithAPIKey:PODIO_KEY secret:PODIO_SECRET];
  
  // We want the user session to persist across application lauches so we will tell PodioKit
  // to store and manage the token in the keychain for us.
  [PodioKit automaticallyStoreTokenInKeychainForCurrentApp];
  
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

#pragma mark - Notifications

- (void)sessionDidChange:(NSNotification *)notification {
  // If the session changed we need to check if we need to show the login screen again.
  [self updateLoginScreen];
}

@end
