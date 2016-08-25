 //
//  SFAuthWinowController.m
//  CAMTOOL
//
//  Created by jifu on 1/10/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFAuthWinowController.h"
#import "SFCommonFounction.h"
#import "SFRecordWriter.h"
@interface SFAuthWinowController ()

@end

@implementation SFAuthWinowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [tf_login_prompt setStringValue:@""];
}


-(void)orderOutWindow
{
    
    [self.window orderOut:self];
    
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)theItem{
    
    return YES;
}

-(void)authenticate:(id)sender;
{
    //TODO:loginForUser
    //MARK:loginForUser
    //FIXME:loginForUser
    //OTHERS:loginForUser
    
    if ([sender isKindOfClass:[NSToolbarItem class]]) {
        if ([[SFAuthenticator sharedAutheticator] isAccessDenied] ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSApp beginSheet:self.window modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(orderOutWindow) contextInfo:NULL];
                
                [tf_username becomeFirstResponder];
                [tf_username setStringValue:@""];
                [tf_password setStringValue:@""];
                [tf_login_prompt setStringValue:@"To sign in please enter username and password and click OK"];
                [tf_login_prompt setTextColor:[NSColor blackColor]];

            });
            
        }else{
            
            [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"User:%@ Logout !",[[SFAuthenticator sharedAutheticator] user]] Type:SFLogTypeNormal];

            [[SFAuthenticator sharedAutheticator] logout];
            
        }
    }

}


-(BOOL)checkUser:(NSString *)user Password:(NSString *)pwd
{
    NSString *passcode =[SFCommonFounction stringToMD5Value:pwd];
    NSArray *allUsers =[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"Accounts"];
    __block BOOL rst= NO;
    SFAuthenticator *autheticator =[SFAuthenticator sharedAutheticator];
    [allUsers enumerateObjectsUsingBlock:^(NSDictionary *  obj, NSUInteger idx, BOOL *  stop) {
        NSString *_passcode =[obj objectForKey:@"Passcode"];
        NSString *_user = [obj objectForKey:@"User"];
        NSNumber *_userLevel = [obj objectForKey:@"User-Level"];

        if ([ _user isEqualToString:user] && [_passcode isEqualToString:passcode]) {
            *stop = YES;
            rst = YES;
            [autheticator loginForUser:_user Level:[_userLevel unsignedIntegerValue]];
            [autheticator setUserpasscode:_passcode];

        }
        
    }];

    return rst;
}

- (IBAction)login_ok:(id)sender;
{
    
    if ([self checkUser:[tf_username stringValue] Password:[tf_password stringValue]] == NO) {
        [tf_login_prompt setStringValue:@"Wrong username or password"];
        [tf_login_prompt setTextColor:[NSColor redColor]];
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"User:%@ Login failed!",[tf_username stringValue]] Type:SFLogTypeWarning];

    }else{
        
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"User:%@ Login !",[[SFAuthenticator sharedAutheticator] user]] Type:SFLogTypeNormal];

        [NSApp endSheet:self.window];

    }
    
}

- (IBAction)login_cancel:(id)sender;
{
    [NSApp endSheet:self.window];
}

@end
