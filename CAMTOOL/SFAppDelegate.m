//
//  SFAppDelegate.m
//  CAMTOOL
//
//  Created by jifu on 11/12/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFAppDelegate.h"
#import "SFCommonFounction.h"
#import "SFRecordWriter.h"
@implementation SFAppDelegate

//TODO: -- others routines

-(BOOL)checkSiFoHashKey
{
    NSString *keyPath=[[[[SFDataCenter sharedDataCenter] applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"key.hash"] ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:keyPath]) {
       NSString *keyFromFile = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:nil];
        NSString *keyFromString=[SFCommonFounction stringToMD5Value:@"sifo:sifo"];
        keyFromFile =[keyFromFile stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
        if ([keyFromFile isEqualToString:keyFromString]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark setup routine
-(void)setupAuthController
{
    if (_authController == nil) {
        _authController = [[SFAuthWinowController alloc] initWithWindowNibName:@"SFAuthWinowController"];
        
    }
    [_loginToolbarItem setTarget:_authController];
    [_loginToolbarItem setAction:@selector(authenticate:)];
}

-(void)setupLayout
{
    if (statusViewController == nil) {
        statusViewController = [[SFStatusViewController alloc] initWithNibName:@"SFStatusViewController" bundle:nil];
        NSDictionary *info =[[NSBundle mainBundle] infoDictionary];
        NSString *version=[NSString stringWithFormat:@"%@.%@",[info objectForKey:@"CFBundleShortVersionString"],[info objectForKey:@"CFBundleVersion"]];
        [statusViewController setVersion:version];
        [statusViewController setUser:[[SFAuthenticator sharedAutheticator] user]];
    }
    
    CGFloat window_width=1200;
    CGFloat window_height=800;
    CGFloat navigationView_width=200;

    [_window setFrame:NSMakeRect(0, 0, window_width, window_height) display:YES animate:YES];
    CGFloat conentView_height=[_window.contentView bounds].size.height;
    CGFloat statusView_height=statusViewController.view.frame.size.height;
    CGFloat navigationView_height=conentView_height-statusView_height;
    CGFloat mainView_width=window_width - navigationView_width;
    CGFloat mainView_height=navigationView_height;

    NSRect statusViewFrame=NSMakeRect(0, 0, window_width, statusView_height);
    NSRect navigatonViewFrame=NSMakeRect(0, statusView_height, navigationView_width, navigationView_height);
    NSRect mainViewFrame=NSMakeRect(navigationView_width, statusView_height, mainView_width, mainView_height);

    [[_window contentView] addSubview:[statusViewController view]];
    [[_window contentView] addSubview:navigationView];
    [[_window contentView] addSubview:_mainView];

    [[statusViewController view] setFrame:statusViewFrame];
    [navigationView setFrame:navigatonViewFrame];
    [_mainView setFrame:mainViewFrame];

    
}

-(void)setupNavigationView;
{
    if (_navigationController == nil) {
        _navigationController=[NavigationController sharedController];
        [_navigationController setNavigationOutlineView:_outlineView];
        [_navigationController setDelegate:self];
    }
    
    //config navigationview
    [_outlineView sizeLastColumnToFit ];
    [_outlineView setFloatsGroupRows:NO];
    [_outlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    //update navigation view
    [_navigationController reloadNavigationView];
    
}


-(void)loadMainView
{
    [self setupNavigationView];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"SELECTED_NIB_NAME"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_outlineView expandItem:nil expandChildren:YES];
        [_navigationController reloadNavigationView];
        [_navigationController setDefautSelection];
    });
    
    
}

-(void)loadPlistFiles
{
    
    NSDictionary *settings =[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CAMPreferences" ofType:@"plist"]];
    NSNumber *version = [settings objectForKey:@"Version"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //set slots boot status to IDLE
    [[settings objectForKey:@"Slots"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [ userDefaults setValue:@"" forKey:[obj objectForKey:@"SlotID"]];
    }];
    float version_f = [[userDefaults valueForKeyPath:@"CAMSettings.Version"] floatValue] ;
    if (version_f < [version floatValue]) {
        [userDefaults setObject:[[NSMutableDictionary alloc] initWithDictionary:settings] forKey:@"CAMSettings"];
        
        //load default accounts.
        NSArray *accouts =[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Accounts" ofType:@"plist"]];
        
        [userDefaults setObject:[accouts copy] forKey:@"Accounts"];
        
        //setup default preferences.
        [userDefaults setObject:[settings objectForKey:@"wabisabi_ip"] forKey:@"wabisabi_ip"];
        [userDefaults setObject:[settings objectForKey:@"wabisabi_port"] forKey:@"wabisabi_port"];
        [userDefaults setObject:[settings objectForKey:@"PrefixOfUnitSN"] forKey:@"PrefixOfUnitSN"];
        [userDefaults setObject:[settings objectForKey:@"PrefixOfCAMID"] forKey:@"PrefixOfCAMID"];
        [userDefaults setObject:[settings objectForKey:@"PrefixOfCarrierID"] forKey:@"PrefixOfCarrierID"];
        [userDefaults setObject:[settings objectForKey:@"DelayForCarrierStateRefreshing"] forKey:@"DelayForCarrierStateRefreshing"];
        [userDefaults synchronize];
    }
    
    [_window setTitle:[NSString stringWithFormat:@"CAMTOOL(%@)",[userDefaults valueForKeyPath:@"CAMSettings.Version"]]];
    
}


#pragma mark application delegation

-(void)awakeFromNib{
    
    if ([self checkSiFoHashKey] == NO) {
        NSRunAlertPanel(@"Sorry!", @"FIXTURE ID NOT MATCH",@"OK", nil, nil);
        exit(0);
   }
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self loadPlistFiles];
    [self setupAuthController];
    [self setupLayout];

    [self loadMainView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangedNotification:) name:SFUserChangedNotification object:nil];
    
    [self preUUTLoop];
    
    [[SFRecordWriter sharedLogWriter] insertLog:@"applicationDidFinishLaunching" Type:SFLogTypeNormal];
  

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self postUUTLoop];
    [[SFRecordWriter sharedLogWriter] insertLog:@"applicationTerminate" Type:SFLogTypeNormal];
    [[SFDataCenter sharedDataCenter] saveContext];
    
    [mainViewController destroyController];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

//MARK:callbacks
-(void)preUUTLoop
{
    
    NSString *preUUTLoopPath=[[NSBundle mainBundle] pathForResource:@"pre_uut_loop" ofType:@"command" inDirectory:@"actionscripts"];
    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[preUUTLoopPath]];
    
}
-(void)postUUTLoop
{
    NSString *postUUTLoopPath=[[NSBundle mainBundle] pathForResource:@"post_uut_loop" ofType:@"command" inDirectory:@"actionscripts"];
    
    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[postUUTLoopPath]];
}

#pragma mark navigation view delegate.


-(void)updateMainView
{
    NSView *newView=[mainViewController view];
    
    //remove all subviews
    [[_mainView subviews] enumerateObjectsUsingBlock:^( NSView *  obj, NSUInteger idx, BOOL *  stop) {
        [obj removeFromSuperview];
    }];
    
    //FIXME:check if current user can access ?
    BOOL canBeAccess=[mainViewController canBeAccessForUserLevel:0];
    if (canBeAccess) {
        [_mainView addSubview:newView];
    }else{
        [_mainView addSubview:[[SFAccessDeniedView alloc] initWithFrame:newView.bounds]];
    }
    
    //FIXME:Resize the frame for new window when user changed page.
    
    NSRect newViewRect=newView.frame;
    CGFloat deltaHight=_mainView.frame.size.height - newViewRect.size.height;
    CGFloat deltaWidth=_mainView.frame.size.width - newViewRect.size.width;
    newViewRect.origin.y=deltaHight;
    [newView setFrame:newViewRect]; //adjust new view's position.
    NSRect oldwinRect=_window.frame;
    NSSize newWinSize = NSMakeSize(oldwinRect.size.width-deltaWidth,oldwinRect.size.height - deltaHight);
    NSRect newWinRect = NSMakeRect(oldwinRect.origin.x,oldwinRect.origin.y + deltaHight , newWinSize.width, newWinSize.height);
    
    [_window setFrame:newWinRect display:YES animate:YES];
}

-(void)navigationViewSelectionDidChange:(NSNotification *)notification;
{

    NSDictionary *userInfo=[notification userInfo];
    NSString *newItemName =[userInfo objectForKey:@"SELECTED_ITEM_NAME"];
    NSString *newNibName = [userInfo objectForKey:@"SELECTED_NIB_NAME"];
    NSString *owner =[userInfo objectForKey:@"OWNER_NAME"];
    NSNumber *userLevel =[userInfo objectForKey:@"USER_LEVEL"];

    NSString *currentNibName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_NIB_NAME"];
    
    if ([currentNibName isEqualToString:newItemName]) {
        return;
    }
    
    SFViewController *controller = [[NSClassFromString(owner) alloc] initWithNibName:newNibName bundle:nil];
    [controller setAccessLevel:[userLevel unsignedIntegerValue]];
    
    if (controller ==nil || ! [controller isKindOfClass:[SFViewController class]]) {
        controller = [[SFViewController alloc] initWithNibName:@"UnderContructionView" bundle:nil];
    }
    
    
    if (mainViewController !=nil) {
        [mainViewController destroyController];
        [[mainViewController view ] removeFromSuperview];
    }
    
    mainViewController = controller;
    [mainViewController setTitle:newItemName];
    [self updateMainView];
    
    [[NSUserDefaults standardUserDefaults] setObject:newNibName forKey:@"SELECTED_NIB_NAME"];
    [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"%@ go to the  page -> %@",[[SFAuthenticator sharedAutheticator] user],newItemName ] Type:SFLogTypeNormal];
    
    [[SFDataCenter sharedDataCenter] saveContext];

}

-(BOOL)navigationView:(id )navigationView shouldSelectNavigationItem:(NavigationItem *)navigatonItem;
{
    
    return YES;
}

//MARK:IBAction handling

-(void)resetPassword:(id)sender{
    
    if (resetPasswordController == nil) {
        resetPasswordController = [[SFChangePasswordWindowController alloc] initWithWindowNibName:@"SFChangePasswordWindowController"];
        [[resetPasswordController window] setTitle:@"Reset Password"];
    }
    
    [resetPasswordController showWindow:self];

}
-(void)showPreferences:(id)sender{
    
    if (preferenceController == nil) {
        preferenceController = [[SFPreferencesWindowController alloc] initWithWindowNibName:@"SFPreferencesWindowController"];
        [[preferenceController window] setTitle:@"Preferences"];
    }
    
    [preferenceController showWindow:self];

    
}


-(void)userManagement:(id)sender{
    if (userManagement == nil) {
        userManagement = [[SFUserManagement alloc] initWithWindowNibName:@"SFUserManagement"];
        [[userManagement window] setTitle:@"UserManagement"];
    }
    
    [userManagement showWindow:self];
}


-(BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    
    if (menuItem.action == @selector(resetPassword:)) {
        return ! [[SFAuthenticator sharedAutheticator] isAccessDenied];
    }
    else if (menuItem.action == @selector(showPreferences:)) {
        return  [[SFAuthenticator sharedAutheticator] userLevel] <=1;
    }
    else if (menuItem.action == @selector(userManagement:)) {
        return  [[SFAuthenticator sharedAutheticator] userLevel] == 0;
    }
    return [super validateMenuItem:menuItem];
}

//MARK:Notification handling

- (void)windowDidEnterFullScreen:(NSNotification *)notification
{
    [_mainView removeFromSuperview]; //remove from main view
    [navigationView removeFromSuperview];
    [[statusViewController view] removeFromSuperview];

    [[_window toolbar] setVisible:NO];
    
   [[_window contentView] addSubview:_mainView ]; //add  to full screen
    
    NSRect screenRect = [[NSScreen mainScreen] frame];
    [_mainView setFrame:screenRect];
    
    [[SFRecordWriter sharedLogWriter] insertLog:@"windowDidEnterFullScreen" Type:SFLogTypeNormal];

}

-(void)windowDidExitFullScreen:(NSNotification *)notification{
    [_mainView removeFromSuperview]; // remove from full screen.
    [[_window toolbar] setVisible:YES];

    [self setupLayout];
    [[SFRecordWriter sharedLogWriter] insertLog:@"windowDidExitFullScreen" Type:SFLogTypeNormal];

}

-(void)userChangedNotification:(NSNotification*)notification
{
    [_navigationController reloadNavigationView];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *user= [[SFAuthenticator sharedAutheticator] user];
        switch ([[SFAuthenticator sharedAutheticator] userLevel]) {
            case SFUserTypeAdministrator:
                user = [user stringByAppendingString:@"(Admin)"];
                break;
            case SFUserTypeSuperAdministrator:
                user = [user stringByAppendingString:@"(Super Admin)"];
                break;
            case SFUserTypeOperator:
                user = [user stringByAppendingString:@"(Operator)"];
                break;
                
            default:
                break;
        }
        [statusViewController setUser:user];
        [self updateMainView];

        if ([[SFAuthenticator sharedAutheticator] isAccessDenied]) {
            [_loginToolbarItem setImage:[NSImage imageNamed:@"icon_login.png"]];
            [_loginToolbarItem setLabel:@"Login"];
            
        }else{
            [_loginToolbarItem setImage:[NSImage imageNamed:@"icon_logout.png"]];
            [_loginToolbarItem setLabel:@"Logout"];
            [_outlineView expandItem:nil expandChildren:YES];
        }
    });
}

@end
