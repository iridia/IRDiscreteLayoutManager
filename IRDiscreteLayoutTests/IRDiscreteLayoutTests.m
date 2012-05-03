//
//  IRDiscreteLayoutTests.m
//  IRDiscreteLayoutTests
//
//  Created by Evadne Wu on 8/29/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutTests.h"
#import "NSArray+IRDiscreteLayoutAdditions.h"

@interface IRDiscreteLayoutTests () <IRDiscreteLayoutManagerDelegate, IRDiscreteLayoutManagerDataSource>

@property (nonatomic, readwrite, strong) IRDiscreteLayoutManager *layoutManager;
@property (nonatomic, readwrite, strong) NSArray *layoutGrids;
@property (nonatomic, readwrite, strong) NSArray *layoutItems;

- (id<IRDiscreteLayoutItem>) randomLayoutItem;

@end


@implementation IRDiscreteLayoutTests

@synthesize layoutManager, layoutGrids, layoutItems;

- (void) setUp {

  [super setUp];
  
  self.layoutManager = [[IRDiscreteLayoutManager alloc] init];
  self.layoutManager.delegate = self;
  self.layoutManager.dataSource = self;
	
	IRDiscreteLayoutArea * (^area)(NSString *, float_t, float_t, float_t, float_t, float_t, float_t) = ^ (NSString *identifier, float_t a, float_t b, float_t c, float_t d, float_t e, float_t f) {
	
		IRDiscreteLayoutArea *area = [[IRDiscreteLayoutArea alloc] initWithIdentifier:identifier];
		area.layoutBlock = IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(a, b, c, d, e, f);
		
		return area;
	
	};
	
	IRDiscreteLayoutGrid *portraitGrid = [[IRDiscreteLayoutGrid alloc] initWithIdentifier:@"portraitGrid" contentSize:(CGSize){ 768, 1024 } layoutAreas:[NSArray arrayWithObjects:
	
		area(@"A", 5, 3, 0, 0, 3, 1),
		area(@"B", 5, 3, 0, 1, 3, 1),
		area(@"C", 5, 3, 3, 0, 2, 2),
		area(@"D", 5, 3, 0, 2, 5, 1),
		
	nil]];
	
	IRDiscreteLayoutGrid *landscapeGrid = [[IRDiscreteLayoutGrid alloc] initWithIdentifier:@"landscapeGrid" contentSize:(CGSize){ 1024, 768 } layoutAreas:[NSArray arrayWithObjects:
	
		area(@"A", 3, 2, 0, 0, 1, 1),
		area(@"B", 3, 2, 0, 1, 1, 1),
		area(@"C", 3, 2, 1, 0, 1, 2),
		area(@"D", 3, 2, 2, 0, 1, 2),
	
	nil]];

	[IRDiscreteLayoutGrid markAreaNamed:@"A" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"A" inGridPrototype:landscapeGrid];
	[IRDiscreteLayoutGrid markAreaNamed:@"B" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"B" inGridPrototype:landscapeGrid];
	[IRDiscreteLayoutGrid markAreaNamed:@"C" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"C" inGridPrototype:landscapeGrid];
	[IRDiscreteLayoutGrid markAreaNamed:@"D" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"D" inGridPrototype:landscapeGrid];
	
	//	Since we only want one of the landscape / portrait grids to be visible, don’t use both in the array
	
	self.layoutGrids = [NSArray arrayWithObjects:
		portraitGrid,
	nil];
	
	NSUInteger numberOfItems = 100;
	NSMutableArray *enqueuedItems = [NSMutableArray arrayWithCapacity:numberOfItems];
	
	for (int i = 0; i < numberOfItems; i++)
		[enqueuedItems addObject:[self randomLayoutItem]];
	
	self.layoutItems = enqueuedItems;

}

- (void) tearDown {
  
  self.layoutManager = nil;
	self.layoutGrids = nil;
	self.layoutItems = nil;
  
  [super tearDown];
  
}

- (NSUInteger) numberOfItemsForLayoutManager:(IRDiscreteLayoutManager *)manager {

  return [self.layoutItems count];

}

- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager itemAtIndex:(NSUInteger)index {

  return (id<IRDiscreteLayoutItem>)[self.layoutItems objectAtIndex:index];

}


- (NSInteger) layoutManager:(IRDiscreteLayoutManager *)manager indexOfLayoutItem:(id<IRDiscreteLayoutItem>)item {

	return [self.layoutItems indexOfObject:item];

}

- (NSUInteger) numberOfLayoutGridsForLayoutManager:(IRDiscreteLayoutManager *)manager {

  return [self.layoutGrids count];

}

- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager layoutGridAtIndex:(NSUInteger)index {

  return (id<IRDiscreteLayoutItem>)[self.layoutGrids objectAtIndex:index];

}

- (NSInteger) layoutManager:(IRDiscreteLayoutManager *)manager indexOfLayoutGrid:(IRDiscreteLayoutGrid *)grid {

	return [self.layoutGrids indexOfObject:grid];

}

- (id<IRDiscreteLayoutItem>) randomLayoutItem {

	IRDiscreteLayoutItem *item = [[IRDiscreteLayoutItem alloc] init];
	item.title = [NSString stringWithFormat:@"Randomized item %i", rand()];
	
	return item;

}

- (void) testFoo {

	NSLog(@"Calculated: %@", [self.layoutManager calculatedResult]);

}

- (void) testPermutation {

	__block BOOL hasStopped = NO;

	[@[@"A", @"B", @"C"] irdlEnumeratePossibleCombinationsWithBlock:^(NSArray *combination, BOOL *stop) {
	
		STAssertFalse(hasStopped, @"Enumeration must stop when *stop is set to YES");
		
		NSLog(@"blo %@ %i", combination, *stop);
		
		if ([combination isEqualToArray:@[@"C", @"A", @"B"]]) {
			*stop = YES;
			hasStopped = YES;
		}
		
	}];

}

@end
