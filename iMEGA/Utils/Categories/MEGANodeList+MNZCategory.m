#import "MEGANodeList+MNZCategory.h"
#import "NSString+MNZCategory.h"

#ifdef MNZ_SHARE_EXTENSION
#import "MEGAShare-Swift.h"
#else
#import "MEGA-Swift.h"
#endif

@implementation MEGANodeList (MNZCategory)

- (NSArray *)mnz_numberOfFilesAndFolders {
    NSUInteger numberOfFiles = 0;
    NSUInteger numberOfFolders = 0;
    for (NSUInteger i = 0; i < self.size; i++) {
        MEGANode *node = [self nodeAtIndex:i];
        if (node.isFile) {
            numberOfFiles++;
        } else if (node.isFolder) {
            numberOfFolders++;
        }
    }
    
    return @[[NSNumber numberWithUnsignedInteger:numberOfFiles], [NSNumber numberWithUnsignedInteger:numberOfFolders]];
}

- (NSArray<MEGANode*> *)mnz_nodesArrayFromNodeList {
    NSUInteger nodeListCount = self.size;
    NSMutableArray *nodesMutableArray = [[NSMutableArray alloc] initWithCapacity:nodeListCount];
    for (NSUInteger i = 0; i < nodeListCount; i++) {
        MEGANode *node = [self nodeAtIndex:i];
        [nodesMutableArray addObject:node];
    }
    
    return nodesMutableArray;
}

- (NSMutableArray *)mnz_mediaNodesMutableArrayFromNodeList {
    NSUInteger nodeListCount = self.size;
    NSMutableArray *mediaNodesMutableArray = [[NSMutableArray alloc] initWithCapacity:nodeListCount];
    for (NSUInteger i = 0; i < nodeListCount; i++) {
        MEGANode *node = [self nodeAtIndex:i];
        if ([FileExtensionGroupOCWrapper verifyIsVisualMedia:node.name]) {
            [mediaNodesMutableArray addObject:node];
        }
    }
    
    return mediaNodesMutableArray;
}

- (NSMutableArray<MEGANode *> *)mnz_mediaAuthorizeNodesMutableArrayFromNodeListWithSdk:(MEGASdk *)sdk {
    NSUInteger nodeListCount = self.size;
    NSMutableArray *mediaNodesMutableArray = [[NSMutableArray alloc] initWithCapacity:nodeListCount];
    for (NSUInteger i = 0; i < nodeListCount; i++) {
        MEGANode *node = [self nodeAtIndex:i];
        if ([FileExtensionGroupOCWrapper verifyIsVisualMedia:node.name]) {
            [mediaNodesMutableArray addObject:[sdk authorizeNode:node]];
        }
    }
    
    return mediaNodesMutableArray;
}

#pragma mark - onNodesUpdate filtering

- (BOOL)mnz_shouldProcessOnNodesUpdateInSharedForNodes:(NSArray<MEGANode *> *)nodesArray itemSelected:(NSInteger)itemSelected {
    BOOL shouldProcessOnNodesUpdate = NO;
    
    NSMutableDictionary *sharedNodesMutableDictionary = NSMutableDictionary.new;
    for (MEGANode *sharedNode in nodesArray) {
        [sharedNodesMutableDictionary setObject:sharedNode.base64Handle forKey:sharedNode.base64Handle];
    }
    
    NSArray *nodesUpdateArray = self.mnz_nodesArrayFromNodeList;
    for (MEGANode *nodeUpdate in nodesUpdateArray) {
        switch (itemSelected) {
            case 0: {
                if (nodeUpdate.isInShare) {
                    return YES;
                }
                break;
            }
            case 1: {
                if (nodeUpdate.isOutShare) {
                    return YES;
                }
                break;
            }
            case 2: {
                if ([nodeUpdate hasChangedType:MEGANodeChangeTypePublicLink]) {
                    return YES;
                }
                
                break;
            }
        }
        
        if ([sharedNodesMutableDictionary objectForKey:nodeUpdate.base64Handle]) {
            shouldProcessOnNodesUpdate = YES;
            break;
        }
    }
    
    
    return shouldProcessOnNodesUpdate;
}

@end
