//
//  SFUserLoginVerificationWindowController.m
//  CAMTOOL
//
//  Created by Jifu on 2/1/16.
//  Copyright (c) 2016 sifo. All rights reserved.
//

#import "SFUserLoginVerificationWindowController.h"

@interface SFUserLoginVerificationWindowController ()
@property (weak) IBOutlet NSSecureTextField *textFieldForPassword;

@end

@implementation SFUserLoginVerificationWindowController
- (IBAction)verify:(id)sender {
    
}
- (IBAction)cancel:(id)sender {
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window setLevel:CGShieldingWindowLevel()];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
