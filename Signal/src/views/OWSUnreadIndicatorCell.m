//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "OWSUnreadIndicatorCell.h"
#import "NSBundle+JSQMessages.h"
#import "TSUnreadIndicatorInteraction.h"
#import "UIColor+OWS.h"
#import "UIFont+OWS.h"
#import "UIView+OWS.h"
#import <JSQMessagesViewController/UIView+JSQMessages.h>

@interface OWSUnreadIndicatorCell ()

@property (nonatomic) UIView *bannerView;
@property (nonatomic) UIView *bannerTopHighlightView;
@property (nonatomic) UIView *bannerBottomHighlightView1;
@property (nonatomic) UIView *bannerBottomHighlightView2;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subtitleLabel;

@end

#pragma mark -

@implementation OWSUnreadIndicatorCell

+ (NSString *)cellReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)configure
{
    self.backgroundColor = [UIColor whiteColor];

    if (!self.titleLabel) {
        self.bannerView = [UIView new];
        self.bannerView.backgroundColor = [UIColor colorWithRGBHex:0xf6eee3];
        [self.contentView addSubview:self.bannerView];

        self.bannerTopHighlightView = [UIView new];
        self.bannerTopHighlightView.backgroundColor = [UIColor colorWithRGBHex:0xf9f3eb];
        [self.bannerView addSubview:self.bannerTopHighlightView];

        self.bannerBottomHighlightView1 = [UIView new];
        self.bannerBottomHighlightView1.backgroundColor = [UIColor colorWithRGBHex:0xd1c6b8];
        [self.bannerView addSubview:self.bannerBottomHighlightView1];

        self.bannerBottomHighlightView2 = [UIView new];
        self.bannerBottomHighlightView2.backgroundColor = [UIColor colorWithRGBHex:0xdbcfc0];
        [self.bannerView addSubview:self.bannerBottomHighlightView2];

        self.titleLabel = [UILabel new];
        self.titleLabel.text = [OWSUnreadIndicatorCell titleForInteraction:self.interaction];
        self.titleLabel.textColor = [UIColor colorWithRGBHex:0x403e3b];
        self.titleLabel.font = [OWSUnreadIndicatorCell titleFont];
        [self.bannerView addSubview:self.titleLabel];

        self.subtitleLabel = [UILabel new];
        self.subtitleLabel.text = [OWSUnreadIndicatorCell subtitleForInteraction:self.interaction];
        self.subtitleLabel.textColor = [UIColor ows_infoMessageBorderColor];
        self.subtitleLabel.font = [OWSUnreadIndicatorCell subtitleFont];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.subtitleLabel];
    }
}

+ (UIFont *)titleFont
{
    return [UIFont ows_regularFontWithSize:16.f];
}

+ (UIFont *)subtitleFont
{
    return [UIFont ows_regularFontWithSize:12.f];
}

+ (NSString *)titleForInteraction:(TSUnreadIndicatorInteraction *)interaction
{
    return NSLocalizedString(@"MESSAGES_VIEW_UNREAD_INDICATOR", @"Indicator that separates read from unread messages.")
        .uppercaseString;
}

+ (NSString *)subtitleForInteraction:(TSUnreadIndicatorInteraction *)interaction
{
    if (!interaction.hasMoreUnseenMessages) {
        return nil;
    }
    NSString *subtitleFormat = (interaction.missingUnseenSafetyNumberChangeCount > 0
            ? NSLocalizedString(@"MESSAGES_VIEW_UNREAD_INDICATOR_HAS_MORE_UNSEEN_MESSAGES_FORMAT",
                  @"Messages that indicates that there are more unseen messages that be revealed by tapping the 'load "
                  @"earlier messages' button. Embeds {{the name of the 'load earlier messages' button}}")
            : NSLocalizedString(
                  @"MESSAGES_VIEW_UNREAD_INDICATOR_HAS_MORE_UNSEEN_MESSAGES_AND_SAFETY_NUMBER_CHANGES_FORMAT",
                  @"Messages that indicates that there are more unseen messages including safety number changes that "
                  @"be revealed by tapping the 'load earlier messages' button. Embeds {{the name of the 'load earlier "
                  @"messages' button}}."));
    NSString *loadMoreButtonName = [NSBundle jsq_localizedStringForKey:@"load_earlier_messages"];
    return [NSString stringWithFormat:subtitleFormat, loadMoreButtonName];
}

+ (CGFloat)subtitleHMargin
{
    return 20.f;
}

+ (CGFloat)subtitleVSpacing
{
    return 3.f;
}

+ (CGFloat)titleInnerHMargin
{
    return 10.f;
}

+ (CGFloat)titleVMargin
{
    return 5.5f;
}

+ (CGFloat)topVMargin
{
    return 5.f;
}

+ (CGFloat)bottomVMargin
{
    return 5.f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.titleLabel sizeToFit];

    // It's a bit of a hack, but we use a view that extends _outside_ the cell's bounds
    // to draw its background, since we want the background to extend to the edges of the
    // collection view.
    //
    // This layout logic assumes that the cell insets are symmetrical and can be deduced
    // from the cell frame.
    CGRect bannerViewFrame = CGRectMake(-self.left,
        round(OWSUnreadIndicatorCell.topVMargin),
        round(self.width + self.left * 2.f),
        round(self.titleLabel.height + OWSUnreadIndicatorCell.titleVMargin * 2.f));
    self.bannerView.frame = [self convertRect:bannerViewFrame toView:self.contentView];

    // The highlights should be 1px (not 1pt), so adapt their thickness to
    // the device resolution.
    CGFloat kHighlightThickness = 1.f / [UIScreen mainScreen].scale;
    self.bannerTopHighlightView.frame = CGRectMake(0, 0, self.bannerView.width, kHighlightThickness);
    self.bannerBottomHighlightView1.frame
        = CGRectMake(0, self.bannerView.height - kHighlightThickness * 2.f, self.bannerView.width, kHighlightThickness);
    self.bannerBottomHighlightView2.frame
        = CGRectMake(0, self.bannerView.height - kHighlightThickness * 1.f, self.bannerView.width, kHighlightThickness);

    [self.titleLabel centerOnSuperview];

    if (self.subtitleLabel.text.length > 0) {
        CGSize subtitleSize = [self.subtitleLabel
            sizeThatFits:CGSizeMake(
                             self.contentView.width - [OWSUnreadIndicatorCell subtitleHMargin] * 2.f, CGFLOAT_MAX)];
        self.subtitleLabel.frame = CGRectMake(round((self.contentView.width - subtitleSize.width) * 0.5f),
            round(self.bannerView.bottom + OWSUnreadIndicatorCell.subtitleVSpacing),
            ceil(subtitleSize.width),
            ceil(subtitleSize.height));
    }
}

+ (CGSize)cellSizeForInteraction:(TSUnreadIndicatorInteraction *)interaction
             collectionViewWidth:(CGFloat)collectionViewWidth
{
    CGSize result = CGSizeMake(collectionViewWidth, 0);
    result.height += self.titleVMargin * 2.f;
    result.height += self.topVMargin;
    result.height += self.bottomVMargin;

    NSString *title = [self titleForInteraction:interaction];
    NSString *subtitle = [self subtitleForInteraction:interaction];

    // Creating a UILabel to measure the layout is expensive, but it's the only
    // reliable way to do it.  Unread indicators should be rare, so this is acceptable.
    UILabel *label = [UILabel new];
    label.font = [self titleFont];
    label.text = title;
    result.height += ceil([label sizeThatFits:CGSizeZero].height);

    if (subtitle.length > 0) {
        result.height += self.subtitleVSpacing;

        label.font = [self subtitleFont];
        label.text = subtitle;
        // The subtitle may wrap to a second line.
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        result.height += ceil(
            [label sizeThatFits:CGSizeMake(collectionViewWidth - self.subtitleHMargin * 2.f, CGFLOAT_MAX)].height);
    }

    return result;
}

@end
