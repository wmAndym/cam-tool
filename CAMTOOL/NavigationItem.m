//
//  NavigationItem.m
//  CAM
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "NavigationItem.h"
#import "SFAuthenticator.h"
@implementation NavigationItem
-(id)init
{
    self = [super init];
    if (self) {
        _children =[NSMutableArray array];
        _isLeaf = YES;
        _name=nil;
        _nibName=nil;
        _iconName=nil;
        _owner=@"NSViewController";//default owner;
        _itemType = OTHER_ITEM_TYPE;
        _minorUserLevel =@4; //any user can access under this level.
    }
    return self;
}

+(NSMutableArray *)rootItems;
{
        NSMutableArray *chds =[NSMutableArray array];
        NSString *plist = [[NSBundle mainBundle] pathForResource:@"navigation" ofType:@"plist"];
        NSArray *navigationArray = [NSArray arrayWithContentsOfFile:plist];
        for (NSDictionary *item in navigationArray) {
            
            //add level-1 items
            NSString *itemName=[item objectForKey:@"ItemName"];
            NSArray *childrenOfThisItem=[item objectForKey:@"Children"];
            
            if (itemName !=nil) { //check the item validation
                NavigationItem *itemOfLevel1=[NavigationItem new];
                [itemOfLevel1 setName:itemName];
                
                //add level-2 items
                if (childrenOfThisItem !=nil) {
                    [itemOfLevel1 setIsLeaf:NO];
                    [childrenOfThisItem enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                        NSNumber *minorUserLevel = [obj objectForKey:@"MinorUserLevel"];
                        BOOL skipItem = [[SFAuthenticator sharedAutheticator] userLevel] > [minorUserLevel unsignedIntegerValue];
                        
                        if (skipItem == NO) {
                            NSString *itemName=[obj objectForKey:@"Name"];
                            NSString *nibName=[obj objectForKey:@"NibName"];
                            NSString *iconName=[obj objectForKey:@"IconName"];
                            NSString *owner=[obj objectForKey:@"Owner"];
                            NSNumber *itemType= [obj objectForKey:@"ItemType"];
                            if (itemName !=nil && nibName !=nil) {
                                NavigationItem *itemOfLevel2=[NavigationItem new];
                                [itemOfLevel2 setName:itemName];
                                [itemOfLevel2 setIsLeaf:YES];
                                [itemOfLevel2 setChildren:nil];
                                [itemOfLevel2 setNibName:nibName];
                                [itemOfLevel2 setIconName:iconName];
                                [itemOfLevel2 setOwner:owner];
                                [itemOfLevel2 setMinorUserLevel:minorUserLevel];
                                [[itemOfLevel1 children] addObject:itemOfLevel2];
                                if (itemType!=nil) {
                                    [itemOfLevel2 setItemType:[itemType intValue]];
                                }
                            };
                        }

                    }];
                }
                [chds  addObject:itemOfLevel1];
            }
        }
    return chds;
}

@end
