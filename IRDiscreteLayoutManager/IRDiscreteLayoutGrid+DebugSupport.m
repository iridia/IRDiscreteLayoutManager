//
//  IRDiscreteLayoutGrid+DebugSupport.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "IRDiscreteLayoutGrid+DebugSupport.h"
#import "IRDiscreteLayoutGrid+Private.h"


NSString * const kIdentifier = @"IRDiscreteLayoutGrid_DebugSupport_Identifier";


@implementation IRDiscreteLayoutGrid (DebugSupport)

- (NSString *) identifier {
	
	if (self.prototype)
		return [self.prototype identifier];

	return objc_getAssociatedObject(self, &kIdentifier);

}

- (void) setIdentifier:(NSString *)identifier {

	NSParameterAssert(!self.prototype);
	
	objc_setAssociatedObject(self, &kIdentifier, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (NSString *) description {

	return [NSString stringWithFormat:@"<%@: 0x%x> { Identifier: %@ } ", NSStringFromClass([self class]), (unsigned int)self, self.identifier];

}

- (NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level {

	return [[NSDictionary dictionaryWithObjectsAndKeys:
	
		[self description], @"Identity",
		self.prototype, @"Prototype",
		self.layoutAreaNames, @"Areas",
		self.layoutAreaNamesToLayoutItems, @"Items",
		
	nil] descriptionWithLocale:locale indent:level];

}

@end
