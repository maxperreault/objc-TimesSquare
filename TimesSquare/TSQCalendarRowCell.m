//
//  TSQCalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowCell.h"
#import "TSQCalendarView.h"
#import "UIButton+Subtitle.h"
#import "UIButton+OutsetLayers.h"
#import <QuartzCore/QuartzCore.h>


@interface TSQCalendarRowCell ()
{
    NSUInteger buttonStates[7];
    NSUInteger buttonEveness[7];
}

@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, assign) NSInteger indexOfSelectedButton;

@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *monthFormatter;

@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic) NSInteger monthOfBeginningDate;

@property (nonatomic, strong, readwrite) NSArray *dayButtons;

@end

static const NSInteger maxValueForRange = 14;

@implementation TSQCalendarRowCell

+ (CGFloat)cellHeight;
{
    CGFloat twoPixel = 2.0f / [UIScreen mainScreen].scale;
    return 40.0f + twoPixel;
}

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)configureButton:(UIButton *)button;
{
    button.subTitle.font = self.smallTextFont;
    button.mainTitle.font = self.textFont;
    button.subTitle.shadowOffset = self.shadowOffset;
    button.mainTitle.shadowOffset = self.shadowOffset;
    
    button.adjustsImageWhenDisabled = NO;
    
    button.subTitle.textColor = self.textColor;
    button.mainTitle.textColor = self.textColor;
    button.subTitle.shadowColor = self.textColorShadow;
    button.mainTitle.shadowColor = self.textColorShadow;

    //[button setTitleColor:self.textColorDisabled forState:UIControlStateDisabled];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
}

- (void)configureEvenButton:(UIButton *)button;
{
    if(button.outsetLayers){
        for(int i=0; i<button.outsetLayers.count; i++){
            CALayer *layer = (CALayer*)button.outsetLayers[i];
            [layer removeFromSuperlayer];
        }
    }
    button.outsetLayers = [NSMutableArray arrayWithArray:@[]];
    
    CALayer *mainLayer = button.layer;
    [mainLayer setBackgroundColor:[UIColor clearColor].CGColor];
    
    CGFloat twoPixel = 2.0f / [UIScreen mainScreen].scale;
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:[UIColor clearColor].CGColor];
    [layer setBorderWidth:twoPixel/2.0f];
    [layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:0.06f].CGColor];
    layer.frame = CGRectInset(mainLayer.bounds, -twoPixel/2.0f, -twoPixel/2.0f);
    
    //[mainLayer addSublayer:layer];
    [mainLayer insertSublayer:layer atIndex:0];
    [button.outsetLayers addObject:layer];
    
}

- (void)configureOddButton:(UIButton *)button;
{
    if(button.outsetLayers){
        for(int i=0; i<button.outsetLayers.count; i++){
            CALayer *layer = (CALayer*)button.outsetLayers[i];
            [layer removeFromSuperlayer];
        }
    }
    button.outsetLayers = [NSMutableArray arrayWithArray:@[]];
    
    CALayer *mainLayer = button.layer;
    [mainLayer setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.05f].CGColor];
    
    CGFloat twoPixel = 2.0f / [UIScreen mainScreen].scale;
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:[UIColor clearColor].CGColor];
    [layer setBorderWidth:twoPixel/2.0f];
    [layer setBorderColor:[UIColor clearColor].CGColor];
    layer.frame = CGRectInset(mainLayer.bounds, -twoPixel/2.0f, -twoPixel/2.0f);
    
    //[mainLayer addSublayer:layer];
    [mainLayer insertSublayer:layer atIndex:0];
    [button.outsetLayers addObject:layer];
}

- (void)configureSelectedButton:(UIButton *)button;
{
    button.subTitle.textColor = [UIColor whiteColor];
    button.mainTitle.textColor = [UIColor whiteColor];
    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    if (self.calendarView.selectionMode == TSQCalendarSelectionModeDateRange) {
        if ((self.calendarView.selectedStartDate) && (!self.calendarView.selectedEndDate)) {
            [button setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
        } else if ((self.calendarView.selectedStartDate) && (self.calendarView.selectedEndDate)){
            [button setBackgroundImage:[self selectedMiddleDaysOfRangeBackgroundImage] forState:UIControlStateNormal];
            
            button.subTitle.textColor = self.textColorMiddleRangeDays;
            button.mainTitle.textColor = self.textColorMiddleRangeDays;
            //[button setTitleColor:self.textColorMiddleRangeDays forState:UIControlStateDisabled];
        }
    }
    
    button.subTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    button.mainTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    button.subTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    button.mainTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    
    CGFloat twoPixel = 2.0f / [UIScreen mainScreen].scale;
    CALayer *layer = button.layer;
    CALayer *greenHighlightLayer = [CALayer layer];
    [greenHighlightLayer setBorderWidth:twoPixel];
    [greenHighlightLayer setBorderColor:[UIColor colorWithRed:203.0f/255.0f green:226.0f/255.0f blue:74.0f/255.0f alpha:1.0f].CGColor];
    [greenHighlightLayer setBackgroundColor:[UIColor colorWithRed:203.0f/255.0f green:226.0f/255.0f blue:74.0f/255.0f alpha:0.5f].CGColor];
    greenHighlightLayer.frame = CGRectInset(layer.bounds, -twoPixel/2.0f, -twoPixel/2.0f);
    //[layer addSublayer:greenHighlightLayer];
    [layer insertSublayer:greenHighlightLayer atIndex:0];
    [button.outsetLayers addObject:greenHighlightLayer];
}

- (void)configureTodayButton:(UIButton *)button;
{
    button.subTitle.textColor = self.todayTextColor;
    button.mainTitle.textColor = self.todayTextColor;
    button.subTitle.shadowColor = self.todayShadowColor;
    button.mainTitle.shadowColor = self.todayShadowColor;
    button.subTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    button.mainTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    
    [button setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
}

- (void)configureFirstButton:(UIButton *)button
{
    button.subTitle.textColor = self.textColorFirstAndlastRangeDay;
    button.mainTitle.textColor = self.textColorFirstAndlastRangeDay;
    button.subTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    button.mainTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    button.subTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    button.mainTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    
    //[button setTitleColor: self.textColorFirstAndlastRangeDay forState:UIControlStateDisabled];
    [button setBackgroundImage:[self selectedFirstDayOfRangeBackgroundImage] forState:UIControlStateNormal];
}

- (void)configureLastButton:(UIButton *)button
{
    button.subTitle.textColor = self.textColorFirstAndlastRangeDay;
    button.mainTitle.textColor = self.textColorFirstAndlastRangeDay;
    button.subTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    button.mainTitle.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    button.subTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    button.mainTitle.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    
    //[button setTitleColor: self.textColorFirstAndlastRangeDay forState:UIControlStateDisabled];
    [button setBackgroundImage:[self selectedLastDayOfRangeBackgroundImage] forState:UIControlStateNormal];
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button setSubTitle:[[UILabel alloc] init]];
        [button setMainTitle:[[UILabel alloc] init]];
        [button addSubview:button.subTitle];
        [button addSubview:button.mainTitle];
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
    }
    self.dayButtons = dayButtons;
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    if (!self.dayButtons) {
        [self createDayButtons];
        //[self createNotThisMonthButtons];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.indexOfTodayButton = -1;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *subTitle = [[self.monthFormatter stringFromDate:date] uppercaseString];
        
        UILabel *l1=[self.dayButtons[index] subTitle];
        UILabel *l2=[self.dayButtons[index] mainTitle];
        
        UIFont *f1 = [UIFont systemFontOfSize:8.0f];
        UIFont *f2 = [UIFont systemFontOfSize:14.0f];
        
        l1.textAlignment =  NSTextAlignmentCenter;
        l2.textAlignment = NSTextAlignmentCenter;
        l1.font = f1;
        l2.font = f2;
         
        l1.text = subTitle;
        l2.text = title;
        

        //[self.notThisMonthButtons[index] setHidden:YES];
        [self.dayButtons[index] setHidden:NO];
        
        NSDateComponents *thisDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];

            if ([self.todayDateComponents isEqual:thisDateComponents]) {
                self.indexOfTodayButton = index;
            }
            UIButton *button = self.dayButtons[index];
            button.enabled = ![self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] || [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
            
            if (self.disablesDatesEarlierThanToday && ((self.todayDateComponents.year == thisDateComponents.year && self.todayDateComponents.month == thisDateComponents.month && thisDateComponents.day < self.todayDateComponents.day)|| (thisDateComponents.year == self.todayDateComponents.year && thisDateComponents.month < self.todayDateComponents.month) || (thisDateComponents.year < self.todayDateComponents.year))) {
                button.enabled = NO;
            }

        date = [self.calendar dateByAddingComponents:offset toDate:date options:0];
        buttonStates[index] = 0;
        buttonEveness[index] = thisDateComponents.month % 2;
    }
    
    [self setNeedsLayout];
}

- (void)setBottomRow:(BOOL)bottomRow;
{
    UIImageView *backgroundImageView = (UIImageView *)self.backgroundView;
    if ([backgroundImageView isKindOfClass:[UIImageView class]] && _bottomRow == bottomRow) {
        return;
    }

    _bottomRow = bottomRow;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    
    [self setNeedsLayout];
}

//TODO
- (void)selectDate:(NSDate *)selectedDate
{
    self.calendarView.selectionError = nil;
    
    if (self.calendarView.isScrolling) {
        return;
    }

    if (self.calendarView.selectionMode == TSQCalendarSelectionModeDay) {
        self.calendarView.selectedDate = ([self.calendarView.selectedDate isEqual:selectedDate]) ? nil : selectedDate;
    } else {
        if (self.calendarView.selectedEndDate) {
            self.calendarView.selectedEndDate = nil;
            self.calendarView.selectedStartDate = selectedDate;
        } else if (self.calendarView.selectedStartDate && ([selectedDate compare:self.calendarView.selectedStartDate] == NSOrderedDescending)) {
            if ([self differenceInDaysBetweenStartDate:self.calendarView.selectedStartDate andEndDate:selectedDate] <= maxValueForRange) {
                self.calendarView.selectedEndDate = selectedDate;
            }
        } else if ([self.calendarView.selectedStartDate isEqual:selectedDate]) {
            self.calendarView.selectedStartDate = nil;
        } else {
            if ([self differenceInDaysBetweenStartDate:[NSDate date] andEndDate:selectedDate] >= 0) {
                self.calendarView.selectedStartDate = selectedDate;
            }
        }
    }
    
    if (self.calendarView.selectedStartDate && selectedDate && [self differenceInDaysBetweenStartDate:self.calendarView.selectedStartDate andEndDate:selectedDate] > maxValueForRange) {
        self.calendarView.selectionError = TSQCalendarErrorSelectionMaxRange;
    }
}

- (IBAction)dateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.dayButtons indexOfObject:sender];
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    
    [self selectDate:selectedDate];
}

- (NSInteger)differenceInDaysBetweenStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate
{
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:startDate toDate:endDate options: 0];
    return [components day];
}

- (void)layoutSubviews;
{
    if (!self.backgroundView) {
        [self setBottomRow:NO];
    }
    
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UIButton *dayButton = self.dayButtons[index];
    //UIButton *notThisMonthButton = self.notThisMonthButtons[index];
    
    CGFloat twoPixel = 2.0f / [UIScreen mainScreen].scale;
    rect = CGRectInset(rect, 0, twoPixel/2.0f);
    
    dayButton.frame = rect;
    //notThisMonthButton.frame = rect;
    
    
    NSString *fakeTitle = @"15";
    NSString *fakeSubTitle = @"WWW";
    
    UILabel *l1=[dayButton subTitle];
    UILabel *l2=[dayButton mainTitle];
    
    UIFont *f1 = [UIFont systemFontOfSize:8.0f];
    UIFont *f2 = [UIFont systemFontOfSize:14.0f];
    
    CGRect label1Frame;
    CGRect label2Frame;
    
    CGFloat titleHeight = [fakeTitle sizeWithFont:f2].height;
    CGFloat subTitleHeight = [fakeSubTitle sizeWithFont:f1].height;
    CGRect smallerBounds = CGRectInset(dayButton.bounds, 0, (dayButton.bounds.size.height-titleHeight-subTitleHeight)/2.0);
    
    
    CGRectDivide(smallerBounds, &label1Frame, &label2Frame, subTitleHeight, CGRectMinYEdge);
    label2Frame.size.height = titleHeight;
    
    l1.frame = label1Frame;
    l2.frame = label2Frame;

    if(buttonEveness[index] == 0){
        [self configureEvenButton:dayButton];
    } else if (buttonEveness[index] == 1){
        [self configureOddButton:dayButton];
    }
    
    if (buttonStates[index] == 1) {
        [self configureSelectedButton:dayButton];
    }  else  if (buttonStates[index] == 2) {
        [self configureFirstButton:dayButton];
    } else  if (buttonStates[index] == 3) {
        [self configureLastButton:dayButton];
//    } else if (self.indexOfTodayButton == (NSInteger)index) {
//        [self configureTodayButton:dayButton];
    } else {
        [self configureButton:dayButton];
        if (!dayButton.enabled) {
            [dayButton setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateNormal];
        }
        
    }
}

- (void)deselectColumnForDate:(NSDate *)date;
{
    if (!date) return;
    
    NSInteger indexOfButtonForDate = [self indexOfColumnForDate:date];
    if (indexOfButtonForDate >= 0) {
        buttonStates[indexOfButtonForDate] = 0;
    }
    
    [self setNeedsLayout];
}

- (void)selectColumnForDate:(NSDate *)date;
{
    if (!date) return;
    
    NSInteger indexOfButtonForDate = [self indexOfColumnForDate:date];
    if (indexOfButtonForDate >= 0) {
        buttonStates[indexOfButtonForDate] = 1;
        if (self.calendarView.selectedStartDate && self.calendarView.selectedEndDate) {
            if ([self.calendarView.selectedStartDate isEqual:date]) {
                buttonStates[indexOfButtonForDate] = 2;
            } else if ([self.calendarView.selectedEndDate isEqual:date]) {
                buttonStates[indexOfButtonForDate] = 3;
            }
        }
    }
    
    [self setNeedsLayout];
}


- (NSDateFormatter *)dayFormatter;
{
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.calendar = self.calendar;
        _dayFormatter.dateFormat = @"dd";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)monthFormatter;
{
    if (!_monthFormatter) {
        _monthFormatter = [NSDateFormatter new];
        _monthFormatter.calendar = self.calendar;
        _monthFormatter.dateFormat = @"MMM";
    }
    return _monthFormatter;
}

- (NSDateFormatter *)accessibilityFormatter;
{
    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [NSDateFormatter new];
        _accessibilityFormatter.calendar = self.calendar;
        _accessibilityFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    return _accessibilityFormatter;
}

- (NSInteger)monthOfBeginningDate;
{
    if (!_monthOfBeginningDate) {
        _monthOfBeginningDate = [self.calendar components:NSMonthCalendarUnit fromDate:self.firstOfMonth].month;
    }
    return _monthOfBeginningDate;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.monthOfBeginningDate = 0;
}

- (NSDateComponents *)todayDateComponents;
{
    if (!_todayDateComponents) {
        self.todayDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    }
    return _todayDateComponents;
}


#pragma mark - Columns

- (NSInteger *)indexOfColumnForDate:(NSDate *)date;
{
    NSInteger indexOfButtonForDate = -1;
    if (date) {
       // NSInteger thisDayMonth = [self.calendar components:NSMonthCalendarUnit fromDate:date].month;
       // if (self.monthOfBeginningDate == thisDayMonth) {
            indexOfButtonForDate = [self.calendar components:NSDayCalendarUnit fromDate:self.beginningDate toDate:date options:0].day;
            if (indexOfButtonForDate >= (NSInteger)self.daysInWeek) {
                indexOfButtonForDate = -1;
            }
       // }
    }
    return indexOfButtonForDate;
}

@end
