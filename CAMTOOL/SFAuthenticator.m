//
//  SFAuthenticator.m
//  CAMTOOL
//
//  Created by jifu on 1/10/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFAuthenticator.h"
NSString * const SFUserChangedNotification=@"SFUserChangedNotification";

@implementation SFAuthenticator
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
#ifdef DEBUG
        _user=@"User_For_Debug";
        _userLevel = SFUserTypeSuperAdministrator;
#else
        _user=@"Anonymous";
        _userLevel = SFUserTypeAnonymous;
#endif
        _isAccessDenied = YES;
        _userpasscode =[[NSUUID UUID] UUIDString];

    }
    return self;
}

static SFAuthenticator *_singleton;

+(instancetype)sharedAutheticator;
{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton= [[self alloc] init];
    });
    
    return _singleton;
}
-(void)loginForUser:(NSString *)user Level:(NSUInteger)level;
{
    _user = user;
    _userLevel = level;
    _isAccessDenied = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SFUserChangedNotification object:nil];
}
-(void)logout;
{
    _userLevel =3;
    _user =@"Anonymous";
    _isAccessDenied = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SFUserChangedNotification object:nil];
}
@end
