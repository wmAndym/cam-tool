//
//  SFAuthenticator.h
//  CAMTOOL
//
//  Created by jifu on 1/10/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const SFUserChangedNotification;

typedef NS_ENUM(NSUInteger, SFUserType) {
    SFUserTypeSuperAdministrator,
    SFUserTypeAdministrator,
    SFUserTypeOperator,
    SFUserTypeAnonymous,

};
@interface SFAuthenticator : NSObject

+(instancetype)sharedAutheticator;

@property(copy)NSString *user;
@property(assign)BOOL isAccessDenied;
@property(assign)SFUserType userLevel;
@property(copy)NSString *userpasscode;
-(void)logout;
-(void)loginForUser:(NSString *)user Level:(NSUInteger)level;
@end
