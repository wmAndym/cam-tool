//
//  SFChangePasswordWindowController.m
//  CAMTOOL
//
//  Created by jifu on 1/10/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFChangePasswordWindowController.h"
#import "SFCommonFounction.h"
#import "SFAuthenticator.h"
#import "SFRecordWriter.h"
@interface SFChangePasswordWindowController ()
@property (weak) IBOutlet NSSecureTextField *oldPassword;
@property (weak) IBOutlet NSSecureTextField *verifiedPassword;
@property (weak) IBOutlet NSSecureTextField *theNewPassword;
@property (weak) IBOutlet NSTextField *promptText;

@end

@implementation SFChangePasswordWindowController

- (IBAction)changePasswordAction:(id)sender {
    
    
    if ([[_theNewPassword stringValue] isNotEqualTo:_verifiedPassword.stringValue]) {
        [_promptText setStringValue:@"Passwords do not match"];
        [_promptText setTextColor:[NSColor redColor]];
        return;
    }
    
    NSString *passcode =[SFCommonFounction stringToMD5Value:[_oldPassword.stringValue description]];
    NSString *newpasscode =[SFCommonFounction stringToMD5Value:[_theNewPassword.stringValue description]];

    if ([passcode isEqualToString:[[SFAuthenticator sharedAutheticator] userpasscode]]) {
        NSArray *accounts=[[NSUserDefaults standardUserDefaults] valueForKey:@"Accounts"];
        NSMutableArray *newAccounts =[[NSMutableArray alloc] initWithArray:[accounts copy]];
        if (accounts) {
            [accounts enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
                NSString *_user = [obj objectForKey:@"User"];
                if ([ _user isEqualToString: [[SFAuthenticator sharedAutheticator] user]]) {
                    *stop = YES;
                    NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:obj];
                    [dict setObject:newpasscode forKey:@"Passcode"];
                    newAccounts[idx] = dict;
                }

            }];
        }
        [[SFAuthenticator sharedAutheticator] setUserpasscode:newpasscode];
        [[NSUserDefaults standardUserDefaults] setValue:newAccounts forKey:@"Accounts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_promptText setStringValue:@"password changed!"];
        
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"User:%@ Changed password !",[[SFAuthenticator sharedAutheticator] user]] Type:SFLogTypeNormal];

        
    }else{
        [_promptText setStringValue:@"The password is incorrect"];
        [_promptText setTextColor:[NSColor redColor]];
        return;
    }
    [self.window close];

    [self resetUI];

}
- (IBAction)cancelAction:(id)sender {
    [self.window close];
    
    [self resetUI];

}

-(void)resetUI
{
    [_oldPassword setStringValue:@""];
    [_theNewPassword setStringValue:@""];
    [_verifiedPassword setStringValue:@""];
    [_promptText setStringValue:@""];
    [_promptText setTextColor:[NSColor blackColor]];
    [_oldPassword becomeFirstResponder];
}
- (void)windowDidLoad {
    [super windowDidLoad];

    [self resetUI];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


@end
