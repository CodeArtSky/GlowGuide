import Foundation

// MARK: - GlowGuide Monetization Strategy
// Last Updated: January 2026

/*
 ╔══════════════════════════════════════════════════════════════════════════════╗
 ║                    GLOWGUIDE MONETIZATION STRATEGY                           ║
 ║                         Market Research & Pricing                            ║
 ╚══════════════════════════════════════════════════════════════════════════════╝

 MARKET OVERVIEW
 ===============
 The Beauty Camera Apps Market is valued at USD 4.47 billion in 2026, with
 projections to reach USD 9.58 billion by 2032 at a 13.57% CAGR.

 Key competitors: YouCam Makeup, FaceApp, Perfect365, BeautyPlus, Facetune

 INDUSTRY TRENDS
 ===============
 • Over 60% of top-grossing apps use hybrid monetization (IAA + IAP + Subscriptions)
 • Subscription fatigue is driving diversification strategies
 • AI-powered personalization commands premium pricing
 • Brand partnerships are a growing revenue stream
 • E-commerce integration creates affiliate opportunities
 */

// MARK: - Monetization Configuration

enum MonetizationConfig {

    // MARK: - Product Identifiers (App Store Connect)

    enum ProductID {
        // Subscriptions
        static let glowProMonthly = "com.glowguide.pro.monthly"
        static let glowProYearly = "com.glowguide.pro.yearly"
        static let glowProLifetime = "com.glowguide.pro.lifetime"

        // Consumables (Token Packs)
        static let tokenPack10 = "com.glowguide.tokens.10"
        static let tokenPack50 = "com.glowguide.tokens.50"
        static let tokenPack100 = "com.glowguide.tokens.100"

        // Non-Consumables
        static let premiumFiltersBundle = "com.glowguide.filters.premium"
        static let occasionPackWedding = "com.glowguide.pack.wedding"
        static let occasionPackFestival = "com.glowguide.pack.festival"
    }

    // MARK: - Pricing Strategy

    /*
     RECOMMENDED PRICING (USD)
     =========================

     SUBSCRIPTION TIERS:
     ┌────────────────────────────────────────────────────────────────┐
     │  Plan          │  Price   │  Annual Equivalent  │  Savings    │
     ├────────────────────────────────────────────────────────────────┤
     │  Monthly       │  $4.99   │  $59.88/year        │  —          │
     │  Yearly        │  $29.99  │  $29.99/year        │  50%        │
     │  Lifetime      │  $79.99  │  One-time           │  Best Value │
     └────────────────────────────────────────────────────────────────┘

     RATIONALE:
     • $4.99/month is below competitors (FaceApp Pro: $7.99, YouCam: $5.99)
     • 50% annual discount encourages long-term commitment
     • Lifetime option captures users reluctant to subscribe

     TOKEN PACKS (for AI look generation):
     ┌────────────────────────────────────────────────────────────────┐
     │  Pack          │  Price   │  Per Token          │  Savings    │
     ├────────────────────────────────────────────────────────────────┤
     │  10 Tokens     │  $1.99   │  $0.20              │  —          │
     │  50 Tokens     │  $6.99   │  $0.14              │  30%        │
     │  100 Tokens    │  $9.99   │  $0.10              │  50%        │
     └────────────────────────────────────────────────────────────────┘

     RATIONALE:
     • Tokens appeal to casual users who don't want subscriptions
     • Low entry price ($1.99) reduces friction
     • Volume discounts incentivize larger purchases
     */

    static let monthlyPrice: Decimal = 4.99
    static let yearlyPrice: Decimal = 29.99
    static let lifetimePrice: Decimal = 79.99

    static let tokens10Price: Decimal = 1.99
    static let tokens50Price: Decimal = 6.99
    static let tokens100Price: Decimal = 9.99
}

// MARK: - Feature Access Tiers

enum FeatureTier {
    case free
    case pro

    /*
     FREE TIER FEATURES
     ==================
     ✓ Profile creation (skin tone, face shape)
     ✓ 3 look generations per day
     ✓ Basic occasion categories (Work, Casual, Date)
     ✓ Basic mood options (Natural, Bold)
     ✓ Step-by-step tutorials
     ✓ Save up to 5 looks
     ✓ Standard social sharing
     ✓ Look history (7 days)

     PRO TIER FEATURES
     =================
     ✓ Unlimited look generations
     ✓ All 8 occasion categories
     ✓ All 8 mood options
     ✓ AI-generated reference images (DALL-E)
     ✓ Unlimited saved looks
     ✓ Premium social media templates
     ✓ Look history (unlimited)
     ✓ Advanced color matching algorithms
     ✓ Seasonal trend looks
     ✓ Celebrity-inspired looks
     ✓ No ads
     ✓ Priority AI processing
     */
}

enum FreeFeatureLimits {
    static let dailyLookGenerations = 3
    static let maxSavedLooks = 5
    static let historyDays = 7
    static let availableOccasions = ["work", "casual", "date"]
    static let availableMoods = ["natural", "bold"]
}

// MARK: - Revenue Streams

enum RevenueStream {
    /*
     REVENUE STREAM BREAKDOWN (Projected Year 1)
     ============================================

     PRIMARY STREAMS:
     ┌────────────────────────────────────────────────────────────────┐
     │  Stream                    │  Target %   │  Strategy           │
     ├────────────────────────────────────────────────────────────────┤
     │  Subscriptions             │  45%        │  Core revenue       │
     │  Token Purchases (IAP)     │  25%        │  Casual users       │
     │  In-App Advertising        │  15%        │  Free tier only     │
     │  Brand Partnerships        │  10%        │  Sponsored looks    │
     │  Affiliate Commissions     │  5%         │  Product links      │
     └────────────────────────────────────────────────────────────────┘

     ADVERTISING STRATEGY (Free Tier Only):
     • Interstitial ads: After every 5th look generation
     • Banner ads: Bottom of home screen
     • Rewarded video: Watch ad for +1 free look generation
     • Native ads: "Sponsored Look" in browse section

     BRAND PARTNERSHIP OPPORTUNITIES:
     • Sponsored "Looks": Makeup brands create signature looks
     • Virtual Try-On: AR integration with cosmetic products
     • Product Placement: Featured products in tutorials
     • Influencer Collaborations: Celebrity makeup looks

     AFFILIATE INTEGRATION:
     • Link to purchase recommended products
     • Partner with Sephora, Ulta, Amazon affiliates
     • Earn 5-15% commission on product purchases
     */
}

// MARK: - Conversion Funnel Strategy

enum ConversionStrategy {
    /*
     FREE-TO-PAID CONVERSION TACTICS
     ================================

     1. SOFT PAYWALL TRIGGERS
        • Show Pro badge on premium occasion categories
        • Blur AI-generated reference images for free users
        • "Save 6th look? Upgrade to Pro!"
        • "Your 7-day history is full. Go Pro for unlimited."

     2. TRIAL OFFERS
        • 7-day free trial (no credit card required)
        • First-time user: "Try Pro free for 7 days"
        • Re-engagement: "Come back! Here's 3 days Pro free"

     3. PROMOTIONAL PRICING
        • Launch week: 60% off yearly subscription
        • Seasonal sales: Valentine's Day, New Year, Festival
        • App Store feature tie-ins

     4. SOCIAL PROOF
        • "Join 50,000+ Pro members"
        • User testimonials in upgrade flow
        • Before/after transformations

     5. URGENCY TACTICS (Use Sparingly)
        • Limited-time offers with countdown
        • "Your trial ends in 24 hours"
        • Flash sales: "Today only: 70% off"

     TARGET METRICS
     ==============
     • Free-to-Paid Conversion: 3-5%
     • Trial-to-Paid Conversion: 25-40%
     • Monthly Churn Rate: <8%
     • Average Revenue Per User (ARPU): $0.50-1.00
     • Lifetime Value (LTV): $15-25
     */

    static let trialDays = 7
    static let targetConversionRate: Double = 0.04 // 4%
    static let targetTrialConversion: Double = 0.30 // 30%
    static let targetMonthlyChurn: Double = 0.08 // 8%
}

// MARK: - StoreKit Configuration

struct SubscriptionInfo {
    let productID: String
    let displayName: String
    let displayPrice: String
    let period: SubscriptionPeriod
    let features: [String]
}

enum SubscriptionPeriod {
    case monthly
    case yearly
    case lifetime
}

struct MonetizationManager {

    // MARK: - Subscription Options

    static let subscriptionOptions: [SubscriptionInfo] = [
        SubscriptionInfo(
            productID: MonetizationConfig.ProductID.glowProMonthly,
            displayName: "Monthly",
            displayPrice: "$4.99/month",
            period: .monthly,
            features: [
                "Unlimited AI look generations",
                "All occasions & moods",
                "AI reference images",
                "Unlimited saved looks",
                "Premium templates",
                "No ads"
            ]
        ),
        SubscriptionInfo(
            productID: MonetizationConfig.ProductID.glowProYearly,
            displayName: "Yearly",
            displayPrice: "$29.99/year",
            period: .yearly,
            features: [
                "Everything in Monthly",
                "Save 50%",
                "Priority support",
                "Early access to features"
            ]
        ),
        SubscriptionInfo(
            productID: MonetizationConfig.ProductID.glowProLifetime,
            displayName: "Lifetime",
            displayPrice: "$79.99 once",
            period: .lifetime,
            features: [
                "Everything in Yearly",
                "Pay once, own forever",
                "Best value"
            ]
        )
    ]

    // MARK: - Paywall Copy

    static let paywallHeadline = "Unlock Your Perfect Look"
    static let paywallSubheadline = "Get unlimited AI-powered beauty recommendations"

    static let paywallBullets = [
        ("sparkles", "Unlimited AI look generations"),
        ("paintpalette.fill", "All 8 occasions & moods"),
        ("photo.artframe", "AI-generated reference images"),
        ("heart.fill", "Save unlimited favorite looks"),
        ("square.and.arrow.up", "Premium social media templates"),
        ("xmark.circle", "No advertisements")
    ]

    static let socialProof = "Join 50,000+ beauty enthusiasts"
    static let moneyBackGuarantee = "7-day free trial • Cancel anytime"
}

// MARK: - A/B Testing Variants

enum PaywallVariant: String, CaseIterable {
    case controlPricing = "control"
    case discountedYearly = "discount_yearly"
    case highlightLifetime = "highlight_lifetime"
    case trialFirst = "trial_first"

    /*
     A/B TEST RECOMMENDATIONS
     ========================

     TEST 1: Pricing Display
     • Control: Show all 3 options equally
     • Variant A: Highlight yearly as "MOST POPULAR"
     • Variant B: Highlight lifetime as "BEST VALUE"

     TEST 2: Trial Prominence
     • Control: Trial button secondary
     • Variant: "Start Free Trial" as primary CTA

     TEST 3: Social Proof
     • Control: No social proof
     • Variant A: User count ("50,000+ members")
     • Variant B: Reviews ("4.8 stars from 10,000 reviews")

     TEST 4: Urgency
     • Control: No urgency
     • Variant: "Limited time: 50% off first year"
     */
}

// MARK: - Analytics Events

enum AnalyticsEvent: String {
    // Paywall Events
    case paywallViewed = "paywall_viewed"
    case paywallDismissed = "paywall_dismissed"
    case trialStarted = "trial_started"
    case subscriptionStarted = "subscription_started"
    case subscriptionCancelled = "subscription_cancelled"
    case subscriptionRenewed = "subscription_renewed"

    // Token Events
    case tokensPurchased = "tokens_purchased"
    case tokensUsed = "tokens_used"

    // Conversion Events
    case hitFreeLimitDaily = "hit_free_limit_daily"
    case hitFreeLimitSaved = "hit_free_limit_saved"
    case upgradePromptShown = "upgrade_prompt_shown"
    case upgradePromptConverted = "upgrade_prompt_converted"

    // Ad Events
    case adViewed = "ad_viewed"
    case adClicked = "ad_clicked"
    case rewardedAdWatched = "rewarded_ad_watched"
}

// MARK: - Competitive Analysis

enum CompetitorAnalysis {
    /*
     COMPETITOR PRICING (January 2026)
     ==================================

     ┌──────────────────────────────────────────────────────────────────────────┐
     │  App           │  Monthly   │  Yearly    │  Strategy                     │
     ├──────────────────────────────────────────────────────────────────────────┤
     │  FaceApp       │  $7.99     │  $39.99    │  Aggressive paywall           │
     │  YouCam Makeup │  $5.99     │  $35.99    │  Freemium + brand deals       │
     │  Perfect365    │  $4.99     │  $24.99    │  Free web, paid mobile        │
     │  BeautyPlus    │  $4.99     │  $29.99    │  Heavy ads, soft paywall      │
     │  Facetune      │  $7.99     │  $35.99    │  Photo editor focus           │
     │  ─────────────────────────────────────────────────────────────────────── │
     │  GlowGuide     │  $4.99     │  $29.99    │  Value leader + AI focus      │
     └──────────────────────────────────────────────────────────────────────────┘

     GLOWGUIDE COMPETITIVE ADVANTAGES:
     =================================
     1. AI-Powered Personalization: True AI recommendations, not just filters
     2. Occasion-Based: Unique positioning around events/occasions
     3. Mood Matching: Emotional intelligence in beauty
     4. Step-by-Step Guidance: Education, not just editing
     5. Local-First Privacy: User data stored on device

     MARKET POSITIONING:
     ===================
     "Your AI Beauty Advisor" - Focus on guidance over editing

     Target Audience:
     • Primary: Women 18-35, beauty enthusiasts
     • Secondary: Makeup beginners seeking guidance
     • Tertiary: Special occasion users (weddings, events)
     */
}

// MARK: - Launch Strategy

enum LaunchStrategy {
    /*
     PHASE 1: SOFT LAUNCH (Weeks 1-4)
     ================================
     • Release in 3 test markets (Australia, Canada, UK)
     • Gather user feedback and iterate
     • A/B test paywall variants
     • Establish baseline metrics
     • Fix critical bugs

     PHASE 2: GLOBAL LAUNCH (Week 5)
     ===============================
     • Full App Store release (all territories)
     • Launch promotion: 60% off first year
     • Press outreach to beauty/tech publications
     • Influencer partnerships (10 micro-influencers)
     • Social media campaign

     PHASE 3: GROWTH (Months 2-6)
     ============================
     • Apple Search Ads campaigns
     • Referral program ("Give $5, Get $5")
     • Feature expansions based on feedback
     • Brand partnership outreach
     • Seasonal content updates

     PHASE 4: SCALE (Months 6-12)
     ============================
     • International localization (5 languages)
     • Android version
     • Advanced AI features
     • E-commerce integrations
     • Premium brand collaborations

     SUCCESS METRICS (Year 1 Targets)
     ================================
     • Downloads: 500,000+
     • Monthly Active Users: 150,000
     • Paid Subscribers: 15,000
     • Annual Revenue: $300,000
     • App Store Rating: 4.5+
     */

    static let softLaunchMarkets = ["AU", "CA", "GB"]
    static let targetDownloadsYear1 = 500_000
    static let targetMAUYear1 = 150_000
    static let targetSubscribersYear1 = 15_000
    static let targetRevenueYear1: Decimal = 300_000
    static let targetAppStoreRating: Double = 4.5
}

// MARK: - Legal & Compliance

enum ComplianceNotes {
    /*
     APP STORE REQUIREMENTS
     ======================

     1. SUBSCRIPTIONS
        • Clearly display pricing before purchase
        • Explain subscription terms (auto-renewal)
        • Provide easy cancellation instructions
        • Honor "Manage Subscriptions" deep link

     2. IN-APP PURCHASES
        • Accurate product descriptions
        • No misleading pricing
        • Clear differentiation between tiers

     3. ADVERTISING
        • IDFA consent via ATT framework
        • GDPR/CCPA compliance
        • "Ad" label on native advertisements
        • Age-appropriate ad content

     4. CHILDREN'S PRIVACY
        • 4+ age rating maintained
        • No data collection from children
        • Parental controls respected

     5. RESTORE PURCHASES
        • Mandatory "Restore Purchases" button
        • Works without re-authentication

     6. TRIAL TERMS
        • Clear trial duration
        • Auto-conversion disclosure
        • Easy opt-out before billing
     */
}
