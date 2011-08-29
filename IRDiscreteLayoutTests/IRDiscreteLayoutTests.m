//
//  IRDiscreteLayoutTests.m
//  IRDiscreteLayoutTests
//
//  Created by Evadne Wu on 8/29/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutTests.h"


@interface IRDiscreteLayoutTests () <IRDiscreteLayoutManagerDelegate, IRDiscreteLayoutManagerDataSource>

@property (nonatomic, readwrite, retain) IRDiscreteLayoutManager *layoutManager;
@property (nonatomic, readwrite, retain) NSArray *layoutGrids;
@property (nonatomic, readwrite, retain) NSArray *layoutItems;

@end


@implementation IRDiscreteLayoutTests

@synthesize layoutManager, layoutGrids, layoutItems;

- (void) setUp {

  [super setUp];
  
  self.layoutManager = [[[IRDiscreteLayoutManager alloc] init] autorelease];
  self.layoutManager.delegate = self;
  self.layoutManager.dataSource = self;
	
	IRDiscreteLayoutGrid *portraitGrid = [IRDiscreteLayoutGrid prototype];
	[portraitGrid registerLayoutAreaNamed:@"A" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(5, 3, 0, 0, 3, 1)];
	[portraitGrid registerLayoutAreaNamed:@"B" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(5, 3, 0, 1, 3, 1)];
	[portraitGrid registerLayoutAreaNamed:@"C" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(5, 3, 3, 0, 2, 2)];
	[portraitGrid registerLayoutAreaNamed:@"D" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(5, 3, 0, 2, 5, 1)];
	
	IRDiscreteLayoutGrid *landscapeGrid = [IRDiscreteLayoutGrid prototype];
	[landscapeGrid registerLayoutAreaNamed:@"A" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(3, 2, 0, 0, 1, 1)];
	[landscapeGrid registerLayoutAreaNamed:@"B" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(3, 2, 0, 1, 1, 1)];
	[landscapeGrid registerLayoutAreaNamed:@"C" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(3, 2, 1, 0, 1, 2)];
	[landscapeGrid registerLayoutAreaNamed:@"D" validatorBlock:nil layoutBlock:IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake(3, 2, 2, 0, 1, 2)];
	
	portraitGrid.contentSize = (CGSize){ 768, 1024 };
	landscapeGrid.contentSize = (CGSize){ 1024, 768 };
	
	[IRDiscreteLayoutGrid markAreaNamed:@"A" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"A" inGridPrototype:landscapeGrid];
	[IRDiscreteLayoutGrid markAreaNamed:@"B" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"B" inGridPrototype:landscapeGrid];
	[IRDiscreteLayoutGrid markAreaNamed:@"C" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"C" inGridPrototype:landscapeGrid];
	[IRDiscreteLayoutGrid markAreaNamed:@"D" inGridPrototype:portraitGrid asEquivalentToAreaNamed:@"D" inGridPrototype:landscapeGrid];
	
	//	Since we only want one of the landscape / portrait grids to be visible, don’t use both in the array
	
	self.layoutGrids = [NSArray arrayWithObjects:
		portraitGrid,
	nil];
	
	
	self.layoutItems = [NSArray arrayWithObjects:
	
		((^ {
			IRDiscreteLayoutItem *item = [[[IRDiscreteLayoutItem alloc] init] autorelease];
			return item;
		
		})()),
	
	nil];

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

- (NSUInteger) numberOfLayoutGridsForLayoutManager:(IRDiscreteLayoutManager *)manager {

  return [self.layoutGrids count];

}

- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager layoutGridAtIndex:(NSUInteger)index {

  return (id<IRDiscreteLayoutItem>)[self.layoutGrids objectAtIndex:index];

}

- (void) testFoo {

	NSLog(@"Calculated: %@", [self.layoutManager calculatedResult]);

} 

@end
