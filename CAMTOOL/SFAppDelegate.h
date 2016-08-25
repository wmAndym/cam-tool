//
//  SFAppDelegate.h
//  CAMTOOL
//
//  Created by jifu on 11/12/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"
#import "NavigationController.h"
#import "SFMainView.h"
#import "SFAuthWinowController.h"
#import "SFChangePasswordWindowController.h"
#import "SFPreferencesWindowController.h"
#import "SFUserManagement.h"
#import "SFStatusViewController.h"
@interface SFAppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>
{
    
    
    NavigationController   *_navigationController;
    SFViewController * mainViewController;
    SFAuthWinowController *_authController;
    SFChangePasswordWindowController * resetPasswordController;
    SFPreferencesWindowController *preferenceController;
    SFUserManagement *userManagement;
    SFStatusViewController *statusViewController;
    
    IBOutlet NSScrollView *navigationView;

}
@property (weak) IBOutlet NSToolbarItem *loginToolbarItem;
@property (weak) IBOutlet SFMainView *mainView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSWindow *window;
@end
