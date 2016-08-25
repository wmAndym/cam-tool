//
//  SFUserManagement.m
//  CAMTOOL
//
//  Created by jifu on 1/15/16.
//  Copyright © 2016 sifo. All rights reserved.
//


#import "SFUserManagement.h"

@interface SFUserManagement ()
@property (weak) IBOutlet NSPopUpButton *userLevelPopupBtn;

@end

@implementation SFUserManagement

-(void)windowWillClose:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setObject:_accounts forKey:@"Accounts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)addUser:(id)sender {
    
    NSMutableDictionary *user=[NSMutableDictionary dictionary];
    [user setObject:@"NewAccount" forKey:@"User"];
    [user setObject:@"" forKey:@"Passcode"];
    [user setObject:@"Description" forKey:@"Description"];
    [user setObject:@2 forKey:@"User-Level"];
    [self willChangeValueForKey:@"accounts"];
    [[self accounts] addObject:user];
    [self didChangeValueForKey:@"accounts"];
    
    [myTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:_accounts.count-1] byExtendingSelection:NO];
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    _accounts =[NSMutableArray  array];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self willChangeValueForKey:@"accounts"];
    NSArray *accounts=[[NSUserDefaults standardUserDefaults] objectForKey:@"Accounts"];
    [accounts   enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        [_accounts addObject:[[NSMutableDictionary alloc] initWithDictionary:obj]];
    }];
    [self didChangeValueForKey:@"accounts"];
    
}



@end
