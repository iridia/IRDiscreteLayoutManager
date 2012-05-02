//
//  IRDiscreteLayoutArea.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRDiscreteLayoutItem.h"

@class IRDiscreteLayoutArea;

#ifndef __IRDiscreteLayoutArea__
#define __IRDiscreteLayoutArea__

typedef BOOL (^IRDiscreteLayoutAreaValidatorBlock) (id item);
typedef CGRect (^IRDiscreteLayoutAreaLayoutBlock) (id item);
typedef id (^IRDiscreteLayoutAreaDisplayBlock) (id item);

#endif	/* __IRDiscreteLayoutArea__ */

@interface IRDiscreteLayoutArea : NSObject <NSCopying>

@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, strong) id<IRDiscreteLayoutItem> item;

- (BOOL) setItem:(id<IRDiscreteLayoutItem>)item error:(NSError **)outError;

@property (nonatomic, readwrite, copy) IRDiscreteLayoutAreaValidatorBlock validatorBlock;
@property (nonatomic, readwrite, copy) IRDiscreteLayoutAreaLayoutBlock layoutBlock;
@property (nonatomic, readwrite, copy) IRDiscreteLayoutAreaDisplayBlock displayBlock;

@end
