//
//  SFViewController.m
//  CAMTOOL
//
//  Created by jifu on 11/25/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFViewController.h"
#import "SFAuthenticator.h"
@interface SFViewController ()

@end

@implementation SFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _accessLevel = 3;
    }
    return self;
}

//overried this method if do not want to be destroied.
-(BOOL)shouldDestroyController;
{
    return YES;
}
-(void)destroyController;
{
#ifdef DEBUG
    NSLog(@"Destroy:%@",self.nibName);
#endif
}

-(BOOL)canBeAccessForUserLevel:(NSUInteger)userLevel;
{
    SFAuthenticator *authenticator =[SFAuthenticator sharedAutheticator];
    return authenticator.userLevel <=_accessLevel;

}

@end
