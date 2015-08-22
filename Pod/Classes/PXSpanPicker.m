//
//  PXSpanPicker.m
//
//  Created by Daniel Blakemore on 9/3/13.
//
//  Copyright (c) 2015 Pixio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PXSpanPicker.h"

#define PXSpacer2 [NSNumber numberWithInt:16]
#define PXSpacer [NSNumber numberWithInt:8]

@implementation PXSpanPicker
{
    UILabel * _oneLabel;
    UILabel * _fiveLabel;
    UILabel * _tenLabel;
    UILabel * _fifteenLabel;
    UILabel * _thirtyLabel;
    UILabel * _selectedDot;
    UILabel * _titleLabel;
    NSInteger _value;
    
    UILabel * _selectionLabel;
    NSInteger _selectedIndex;
    NSInteger _oldSelectedIndex;
    NSMutableArray * _selectionConstraits;
    NSMutableArray * _hideConstraits;
    
    NSString * _portraitTitle;
    NSString * _landscapeTitle;
    
    UIView * _contentView;
    
    PXSpanPickerOrientation _orientation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _hideConstraits = [[NSMutableArray alloc] init];
        _selectionConstraits = [[NSMutableArray alloc] init];
        [self setMultipleTouchEnabled:FALSE];
        
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor clearColor]];
        [_contentView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [self addSubview:_contentView];
        
        _oneLabel = [[UILabel alloc] init];
        [_oneLabel setText:@"1"];
        [_oneLabel setTextAlignment:NSTextAlignmentCenter];
        [_oneLabel setBackgroundColor:[UIColor clearColor]];
        [_oneLabel setTextColor:[UIColor whiteColor]];
        [_oneLabel setFont:[UIFont systemFontOfSize:38.0f]];
        [_oneLabel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_oneLabel];
        
        _fiveLabel = [[UILabel alloc] init];
        [_fiveLabel setText:@"5"];
        [_fiveLabel setTextAlignment:NSTextAlignmentCenter];
        [_fiveLabel setBackgroundColor:[UIColor clearColor]];
        [_fiveLabel setTextColor:[UIColor whiteColor]];
        [_fiveLabel setFont:[UIFont systemFontOfSize:38.0f]];
        [_fiveLabel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_fiveLabel];
        
        _tenLabel = [[UILabel alloc] init];
        [_tenLabel setText:@"10"];
        [_tenLabel setTextAlignment:NSTextAlignmentCenter];
        [_tenLabel setBackgroundColor:[UIColor clearColor]];
        [_tenLabel setTextColor:[UIColor whiteColor]];
        [_tenLabel setFont:[UIFont systemFontOfSize:38.0f]];
        [_tenLabel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_tenLabel];
        
        _fifteenLabel = [[UILabel alloc] init];
        [_fifteenLabel setText:@"15"];
        [_fifteenLabel setTextAlignment:NSTextAlignmentCenter];
        [_fifteenLabel setBackgroundColor:[UIColor clearColor]];
        [_fifteenLabel setTextColor:[UIColor whiteColor]];
        [_fifteenLabel setFont:[UIFont systemFontOfSize:38.0f]];
        [_fifteenLabel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_fifteenLabel];
        
        _thirtyLabel = [[UILabel alloc] init];
        [_thirtyLabel setText:@"30"];
        [_thirtyLabel setTextAlignment:NSTextAlignmentCenter];
        [_thirtyLabel setBackgroundColor:[UIColor clearColor]];
        [_thirtyLabel setTextColor:[UIColor whiteColor]];
        [_thirtyLabel setFont:[UIFont systemFontOfSize:38.0f]];
        [_thirtyLabel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_thirtyLabel];
        
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setFont:[UIFont systemFontOfSize:24.0f]];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_titleLabel];
        
        _selectedDot = [[UILabel alloc] init];
        [_selectedDot setText:@"•"];
        [_selectedDot setBackgroundColor:[UIColor clearColor]];
        [_selectedDot setTextColor:[UIColor whiteColor]];
        [_selectedDot setFont:[UIFont systemFontOfSize:38.0f]];
        [_selectedDot setTranslatesAutoresizingMaskIntoConstraints:FALSE];
        [_contentView addSubview:_selectedDot];
        
        _selectionLabel = _tenLabel;
        
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        [self hideAnimated:FALSE];
        
        _value = 10;
        _selectedIndex = 2;
        [self setValue:10 animated:FALSE];
        
        // hide initially
        [_contentView setAlpha:0.0f];
    }
    return self;
}

- (void)setOrientation:(PXSpanPickerOrientation)orientation
{
    _orientation = orientation;
    
    [_titleLabel setAttributedText:[self titleForOrientation:orientation]];
    
    [self setValue:[self value]];
    
    if (_hidden) {
        [self hideAnimated:FALSE];
    } else {
        [self showAnimated:FALSE];
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (NSArray*)individualViews
{
    return @[_oneLabel, _fiveLabel, _tenLabel, _fifteenLabel, _thirtyLabel, _titleLabel];
}

- (void)updateConstraints
{
    [self removeConstraints:[self constraints]];
    [_contentView removeConstraints:[_contentView constraints]];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(_oneLabel, _fiveLabel, _tenLabel, _fifteenLabel, _thirtyLabel, _titleLabel, _selectedDot);
    NSDictionary* metrics = @{@"s" : PXSpacer, @"sp" : PXSpacer2};
    
    if (_orientation == PXSpanPickerOrientationPortrait) {
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_oneLabel][_fiveLabel(==_oneLabel)][_tenLabel(==_oneLabel)][_fifteenLabel(==_oneLabel)][_thirtyLabel(==_oneLabel)]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sp-[_titleLabel]" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-s-[_titleLabel]" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_oneLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fiveLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tenLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fifteenLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_thirtyLabel]|" options:0 metrics:metrics views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    } else {
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_oneLabel][_fiveLabel(==_oneLabel)][_tenLabel(==_oneLabel)][_fifteenLabel(==_oneLabel)][_thirtyLabel(==_oneLabel)]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[_titleLabel]" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-s-[_titleLabel]" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_oneLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_fiveLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_tenLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_fifteenLabel]|" options:0 metrics:metrics views:views]];
        [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_thirtyLabel]|" options:0 metrics:metrics views:views]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }

    // delete old constraints
    [_contentView removeConstraints:_selectionConstraits];
    [_selectionConstraits removeAllObjects];
    
    CGFloat offset = (_orientation == PXSpanPickerOrientationPortrait) ? ((_selectedIndex < 2) ? 10.0f : ((_selectedIndex > 3) ? -2.0f : 0.0f)) : -10.0f;
    
    [_selectionConstraits addObject:[NSLayoutConstraint constraintWithItem:_selectedDot attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_selectionLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [_selectionConstraits addObject:[NSLayoutConstraint constraintWithItem:_selectedDot attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_selectionLabel attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [_selectionConstraits addObject:[NSLayoutConstraint constraintWithItem:_selectedDot attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_selectionLabel attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [_selectionConstraits addObject:[NSLayoutConstraint constraintWithItem:_selectedDot attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_selectionLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:offset]];
    
    [_contentView addConstraints:_selectionConstraits];
    
    // hide or show
    [self removeConstraints:_hideConstraits];
    [_hideConstraits removeAllObjects];
    
    NSLayoutAttribute edge = (_orientation == PXSpanPickerOrientationPortrait) ? NSLayoutAttributeTop : NSLayoutAttributeRight;
    NSLayoutAttribute target;
    if (_hidden) {
        target = (_orientation == PXSpanPickerOrientationPortrait) ? NSLayoutAttributeBottom : NSLayoutAttributeLeft;
    } else {
        target = (_orientation == PXSpanPickerOrientationPortrait) ? NSLayoutAttributeTop : NSLayoutAttributeRight;
    }
    
    [_hideConstraits addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:edge relatedBy:NSLayoutRelationEqual toItem:self attribute:target multiplier:1.0f constant:0.0f]];
    [self addConstraints:_hideConstraits];
    
    [super updateConstraints];
}

- (NSAttributedString*)titleForOrientation:(PXSpanPickerOrientation)orientation
{
    NSMutableParagraphStyle * pStyle = [[NSMutableParagraphStyle alloc] init];
    [pStyle setLineHeightMultiple:0.8];
    
    NSString * titleString;
    if (orientation == PXSpanPickerOrientationPortrait) {
        titleString = _portraitTitle;
    } else {
        titleString = _landscapeTitle;
    }
    
    NSMutableAttributedString * title = [[NSMutableAttributedString alloc] initWithString:titleString attributes:@{NSParagraphStyleAttributeName : pStyle}];
    
    return title;
}

- (void) setValue:(NSInteger)value
{
    [self setValue:value animated:FALSE];
}

- (void) setValue:(NSInteger)value animated:(BOOL)animated
{
    _value = value;
    
    switch (_value) {
        case 1:
            _selectedIndex = 0;
            _selectionLabel = _oneLabel;
            break;
            
        case 5:
            _selectedIndex = 1;
            _selectionLabel = _fiveLabel;
            break;
            
        case 10:
            _selectedIndex = 2;
            _selectionLabel = _tenLabel;
            break;
            
        case 15:
            _selectedIndex = 3;
            _selectionLabel = _fifteenLabel;
            break;
            
        case 30:
        default:
            _selectedIndex = 4;
            _selectionLabel = _thirtyLabel;
            break;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    if (animated) {
        [UIView animateWithDuration:0.15f animations:^{
            [self layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }
}

- (NSInteger)value
{
    return _value;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _oldSelectedIndex = _selectedIndex; // save in case of cancel
    
    //  Immediately animate change to the touched span.
    [self touchesMoved:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Follow finger into new touched span, changing value as appropriate
    NSInteger newBin = [self resolveBinFromPrimaryAxis:[[touches anyObject] locationInView:self]];
    if (_selectedIndex != newBin) {
        // deal with state and events
        _selectedIndex = newBin;
        [self setValue:[self valueForBin:newBin] animated:TRUE];
        if (_continuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // send final touch (or only if not coninuous)
    NSInteger newBin = [self resolveBinFromPrimaryAxis:[[touches anyObject] locationInView:self]];
    
    // deal with state and events
    _selectedIndex = newBin;
    [self setValue:[self valueForBin:newBin] animated:TRUE];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // reset back to original value and send no event (unless continuous, then reset)
    _selectedIndex = _oldSelectedIndex;
    [self setValue:[self valueForBin:_selectedIndex] animated:TRUE];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSInteger) resolveBinFromPrimaryAxis:(CGPoint)point
{
    CGFloat axisCoordinate;
    CGFloat totalAxisLength;
    
    if (_orientation == PXSpanPickerOrientationPortrait) {
        axisCoordinate = point.x;
        totalAxisLength = [self frame].size.width;
    } else {
        axisCoordinate = point.y;
        totalAxisLength = [self frame].size.height;
    }
    CGFloat binWidth = totalAxisLength / 5;
    
    return (NSInteger)(axisCoordinate / binWidth);
}

- (NSInteger) valueForBin:(NSInteger)bin
{
    switch (bin) {
        case 0:
            return 1;
            
        case 1:
            return 5;
            
        case 2:
            return 10;
            
        case 3:
            return 15;
            
        case 4:
        default:
            return 30;
    }
}

- (NSString *)title
{
    return _portraitTitle;
}

- (void)setTitle:(NSString *)title
{
    _portraitTitle = title;
    
    // http://stackoverflow.com/a/11060669/579405
    NSMutableArray * joinableArray = [NSMutableArray array];
    for (int i = 0; i < [title length]; i++) {
        [joinableArray addObject:[NSString stringWithFormat:@"%C", [title characterAtIndex:i]]];
    }
    
    _landscapeTitle = [joinableArray componentsJoinedByString:@"\n"];
    
    if (_orientation == PXSpanPickerOrientationPortrait) {
        [_titleLabel setText:_portraitTitle];
    } else {
        [_titleLabel setText:_landscapeTitle];
    }
}

- (void) hideAnimated:(BOOL)animated
{
    _hidden = TRUE;
    
    [self setUserInteractionEnabled:FALSE];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            // prevent flashing on rotation
            [_contentView setAlpha:0.0f];
        }];
    } else {
        [self layoutIfNeeded];
    }
}

- (void) showAnimated:(BOOL)animated
{
    _hidden = FALSE;
    [_contentView setAlpha:1.0f];
    
    [self setUserInteractionEnabled:TRUE];
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            [self layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }
}

- (void) setContentBackgroundColor:(UIColor*)color
{
    [_contentView setBackgroundColor:color];
}

- (UIColor*) contentBackgroundColor
{
    return [_contentView backgroundColor];
}

- (void) hideText
{
    // hide all the text
    [UIView animateWithDuration:0.1f animations:^{
        [_oneLabel setAlpha:0.0f];
        [_fiveLabel setAlpha:0.0f];
        [_tenLabel setAlpha:0.0f];
        [_fifteenLabel setAlpha:0.0f];
        [_thirtyLabel setAlpha:0.0f];
        [_titleLabel setAlpha:0.0f];
        [_selectedDot setAlpha:0.0f];
    }];
}

- (void) showText
{
    // show all the text
    [UIView animateWithDuration:0.1f animations:^{
        [_oneLabel setAlpha:1.0f];
        [_fiveLabel setAlpha:1.0f];
        [_tenLabel setAlpha:1.0f];
        [_fifteenLabel setAlpha:1.0f];
        [_thirtyLabel setAlpha:1.0f];
        [_titleLabel setAlpha:1.0f];
        [_selectedDot setAlpha:1.0f];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
