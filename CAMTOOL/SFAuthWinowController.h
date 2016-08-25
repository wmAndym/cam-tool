//
//  SFAuthWinowController.h
//  CAMTOOL
//
//  Created by jifu on 1/10/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFAuthenticator.h"
@interface SFAuthWinowController : NSWindowController
{
    IBOutlet NSTextField *tf_username;
    IBOutlet NSTextField *tf_password;
    IBOutlet NSTextField *tf_login_prompt;

}

-(void)authenticate:(id)sender;

@end
