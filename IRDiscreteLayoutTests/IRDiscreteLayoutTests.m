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

@end


@implementation IRDiscreteLayoutTests

@synthesize layoutManager;

- (void) setUp {

  [super setUp];
  
  self.layoutManager = [[[IRDiscreteLayoutManager alloc] init] autorelease];
  self.layoutManager.delegate = self;
  self.layoutManager.dataSource = self;

}

- (void) tearDown {
  
  [super tearDown];
  
  self.layoutManager = nil;
  
}

- (NSUInteger) numberOfItemsForLayoutManager:(IRDiscreteLayoutManager *)manager {

  return 0;

}

- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager itemAtIndex:(NSUInteger)index {

  return nil;

}

- (NSUInteger) numberOfLayoutGridsForLayoutManager:(IRDiscreteLayoutManager *)manager {

  return 0;

}

- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager layoutGridAtIndex:(NSUInteger)index {

  return nil;

}

- (void) testFoo {

  NSLog(@"Hello world.");

} 

@end
