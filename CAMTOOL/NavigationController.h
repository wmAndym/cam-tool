//
//  NavigationController.h
//  CAM
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NavigationItem.h"
@protocol NavigationDelegate <NSObject>

@required
- (void)navigationViewSelectionDidChange:(NSNotification *)notification;
-(BOOL)navigationView:(id )navigationView shouldSelectNavigationItem:(NavigationItem *)navigatonItem;
@end
@interface NavigationController : NSObject<NSOutlineViewDataSource,NSOutlineViewDelegate>
{
    NSOutlineView *_navigationView;
    NSArray *_rootItems;
    __weak id<NavigationDelegate> _delegate;
}
+ (NavigationController *)sharedController;
-(void)setNavigationOutlineView:(NSOutlineView *)view;
-(void)reloadNavigationView;
-(void)setDelegate:(id)delegate;
-(NSArray *)rootItems;
-(void)setDefautSelection;
@end
