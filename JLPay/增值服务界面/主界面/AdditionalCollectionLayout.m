//
//  AdditionalCollectionLayout.m
//  JLPay
//
//  Created by jielian on 15/11/24.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "AdditionalCollectionLayout.h"
#import "AdditionalServicesViewController.h"

@interface AdditionalCollectionLayout()
{
    CGSize cvSize; // collection view视图的尺寸
    CGSize supplementarySize;
    CGSize cellSize;
    CGSize supplementaryStaySize;
}

@end


@implementation AdditionalCollectionLayout


- (void)prepareLayout {
    [super prepareLayout];
    cvSize = self.collectionView.frame.size;
    UIImage* supplementaryImage = [UIImage imageNamed:@"01_03"];
    
    supplementarySize = CGSizeMake(cvSize.width, cvSize.width * supplementaryImage.size.height/supplementaryImage.size.width);
    supplementaryStaySize = CGSizeMake(cvSize.width, 0.3);
    cellSize = CGSizeMake(cvSize.width/3.0, cvSize.width/3.0);
    
}


- (CGSize)collectionViewContentSize {
    
    CGFloat height = [self rowsOfCells] * cellSize.height +
                        supplementarySize.height +
                        supplementaryStaySize.height;
    return CGSizeMake(self.collectionView.frame.size.width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = cellSize;
    attributes.center = CGPointMake((indexPath.row % 3) * cellSize.width + cellSize.width / 2.0,
                                    (indexPath.row / 3) * cellSize.height + cellSize.height / 2.0 + supplementarySize.height);
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes.size = supplementarySize;
        attributes.center = CGPointMake(supplementarySize.width/2.0, supplementarySize.height/2.0);
    }
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        attributes.size = supplementaryStaySize;
        CGFloat heightOfContentViews = [self rowsOfCells]*cellSize.height + supplementarySize.height;
        attributes.center = CGPointMake(supplementaryStaySize.width/2.0, supplementaryStaySize.height/2.0 + heightOfContentViews);
    }
    return attributes;
}



- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* attributes = [[NSMutableArray alloc] init];
    // cells
    for (int i = 0 ; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    // supplementary
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:SupplementaryIdentifier atIndexPath:indexPath]];
    [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:SupplementaryIdentifierStay atIndexPath:indexPath]];

    return attributes;
}


- (NSInteger) rowsOfCells {
    return ([self.collectionView numberOfItemsInSection:0]%3 == 0)?([self.collectionView numberOfItemsInSection:0]/3):([self.collectionView numberOfItemsInSection:0]/3 + 1);
}

@end
