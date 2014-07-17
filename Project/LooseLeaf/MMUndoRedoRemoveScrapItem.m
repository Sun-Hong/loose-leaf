//
//  MMUndoRedoRemoveScrapItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoRemoveScrapItem.h"
#import "MMUndoablePaperView.h"

@implementation MMUndoRedoRemoveScrapItem{
    NSDictionary* propertiesWhenRemoved;
    MMScrapView* scrap;
}

+(id) itemForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)scrap andProperties:(NSDictionary*)scrapProperties{
    return [[MMUndoRedoRemoveScrapItem alloc] initForPage:_page andScrap:scrap andProperties:scrapProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrap:(MMScrapView*)_scrap andProperties:(NSDictionary*)scrapProperties{
    __weak MMUndoablePaperView* weakPage = _page;
    scrap = _scrap;
    propertiesWhenRemoved = scrapProperties;
    if(self = [super initWithUndoBlock:^{
        [weakPage.scrapsOnPaperState showScrap:scrap];
        [scrap setPropertiesDictionary:propertiesWhenRemoved];
        NSUInteger subviewIndex = [[propertiesWhenRemoved objectForKey:@"subviewIndex"] unsignedIntegerValue];
        [scrap.superview insertSubview:scrap atIndex:subviewIndex];
    } andRedoBlock:^{
        [weakPage.scrapsOnPaperState hideScrap:scrap];
    } forPage:_page]){
        // noop
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:propertiesWhenRemoved forKey:@"propertiesWhenRemoved"];
    [propertiesDictionary setObject:scrap.uuid forKey:@"scrap.uuid"];
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSDictionary* _properties = [dict objectForKey:@"propertiesWhenRemoved"];
    NSString* scrapUUID = [dict objectForKey:@"scrap.uuid"];
    MMScrapView* _scrap = [_page.scrapsOnPaperState scrapForUUID:scrapUUID];
    
    if(self = [self initForPage:_page andScrap:_scrap andProperties:_properties]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrap.uuid];
}

@end
