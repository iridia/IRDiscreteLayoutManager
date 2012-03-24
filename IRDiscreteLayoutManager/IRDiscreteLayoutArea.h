//
//  IRDiscreteLayoutArea.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/24/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^IRDiscreteLayoutAreaValidatorBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef CGRect (^IRDiscreteLayoutAreaLayoutBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef id (^IRDiscreteLayoutAreaDisplayBlock) (IRDiscreteLayoutGrid *self, id anItem);

@interface IRDiscreteLayoutArea : NSObject <NSCopying>

+ (id) areaWithName:(NSString *)name validatorBlock:(IRDiscreteLayoutAreaValidatorBlock)validatorBlock layoutBlock:(IRDiscreteLayoutAreaLayoutBlock)layoutBlock displayBlock:(IRDiscreteLayoutAreaDisplayBlock)displayBlock;

- (id) initWithName:(NSString *)name validatorBlock:(IRDiscreteLayoutAreaValidatorBlock)validatorBlock layoutBlock:(IRDiscreteLayoutAreaLayoutBlock)layoutBlock displayBlock:(IRDiscreteLayoutAreaDisplayBlock)displayBlock;

@end
