//
//  IRDiscreteLayoutManager.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutItem.h"
#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutResult.h"

@class IRDiscreteLayoutManager;


@protocol IRDiscreteLayoutManagerDataSource, IRDiscreteLayoutManagerDelegate;
@interface IRDiscreteLayoutManager : NSObject

@property (nonatomic, readwrite, assign) id<IRDiscreteLayoutManagerDataSource> dataSource;
@property (nonatomic, readwrite, assign) id<IRDiscreteLayoutManagerDelegate> delegate;
@property (nonatomic, readwrite, retain) IRDiscreteLayoutResult *result;

- (IRDiscreteLayoutResult *) calculatedResult;

@end





@protocol IRDiscreteLayoutManagerDataSource <NSObject>

- (NSUInteger) numberOfItemsForLayoutManager:(IRDiscreteLayoutManager *)manager;
- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager itemAtIndex:(NSUInteger)index;

@end


@protocol IRDiscreteLayoutManagerDelegate <NSObject>

@optional

- (IRDiscreteLayoutGrid *) layoutManager:(IRDiscreteLayoutManager *)manager nextGridForContentsUsingGrid:(IRDiscreteLayoutGrid *)proposedGrid;

//	Not implemented: manager uses its own determination
//	Returns nil: manager stops layout immediately
//	Returns anything: manager uses returned grid

@end


//	Provides extra information for the layout manager’s current operation
//	so the delegate can make an informed decision about returning a better proposed grid

@protocol IRDiscreteLayoutManagerIntrospection <NSObject>

- (NSArray *) currentlyConsumedItems;

@end

@interface IRDiscreteLayoutManager (IRDiscreteLayoutManagerIntrospection) <IRDiscreteLayoutManagerIntrospection>
	
@end

