//
//  IRDiscreteLayoutResult.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IRDiscreteLayoutItem;
@class IRDiscreteLayoutGrid;

@interface IRDiscreteLayoutResult : NSObject

+ (IRDiscreteLayoutResult *) resultWithGrids:(NSArray *)grids;
- (IRDiscreteLayoutResult *) initWithGrids:(NSArray *)grids;

- (IRDiscreteLayoutGrid *) gridContainingItem:(id<IRDiscreteLayoutItem>)item;
- (IRDiscreteLayoutGrid *) bestGridMatchingItemsInInstance:(IRDiscreteLayoutGrid *)instance;

@property (nonatomic, readonly, strong) NSArray *grids;

@end
