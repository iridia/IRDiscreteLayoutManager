//
//  IRDiscreteLayoutManager.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutItem.h"
#import "IRDiscreteLayoutGrid.h"

@class IRDiscreteLayoutManager;
@class IRDiscreteLayoutResult;


@protocol IRDiscreteLayoutManagerDataSource, IRDiscreteLayoutManagerDelegate;
@interface IRDiscreteLayoutManager : NSObject

@property (nonatomic, readwrite, assign) id<IRDiscreteLayoutManagerDataSource> dataSource;
@property (nonatomic, readwrite, assign) id<IRDiscreteLayoutManagerDelegate> delegate;
@property (nonatomic, readwrite, retain) IRDiscreteLayoutResult *result;

@end





@protocol IRDiscreteLayoutManagerDataSource <NSObject>

- (NSUInteger) numberOfItemsForLayoutManager:(IRDiscreteLayoutManager *)manager;
- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager itemAtIndex:(NSUInteger)index;

@end


@protocol IRDiscreteLayoutManagerDelegate <NSObject>

- (IRDiscreteLayoutGrid *) layoutManager:(IRDiscreteLayoutManager *)manager nextGridForContentsUsingGrid:(IRDiscreteLayoutGrid *)proposedGrid;

@end


//	Provides extra information for the layout manager’s current operation
//	so the delegate can make an informed decision about returning a better proposed grid

@protocol IRDiscreteLayoutManagerIntrospection <NSObject>

- (NSArray *) currentlyConsumedItems;

@end

@interface IRDiscreteLayoutManager (IRDiscreteLayoutManagerIntrospection) <IRDiscreteLayoutManagerIntrospection>
	
@end

