# BHAGWA MARKETING & ANALYTICS EVENT TAXONOMY

This document outlines the event architecture and provider routing rules for the Bhagwa application.

---

## 1. Meta App Events (Strict 6 Business Signals)

The Meta SDK receives **ONLY** the following six business events. All product-level analytics events are blocked at the provider level.

| Internal Bhagwa Trigger | Meta Event Name | Parameters | Description |
| :--- | :--- | :--- | :--- |
| `trackInstall()` | **`install`** | None | Initial app installation (fired once per installation identity) |
| `trackRegistration()` | **`registration`** | `method` (`google`, `phone`, `skip`) | Successful account/profile creation |
| `trackRecharge()` | **`recharges`** | `value`, `currency`, `transaction_id`, `product_id` | Confirmed successful payment/recharge |
| `trackFirstPay()` | **`fp`** | `value`, `currency`, `transaction_id`, `product_id` | 1st confirmed successful recharge for user |
| `trackSecondPay()` | **`sp`** | `value`, `currency`, `transaction_id`, `product_id` | 2nd confirmed successful recharge for user |
| `trackThirdPay()` | **`tp`** | `value`, `currency`, `transaction_id`, `product_id` | 3rd confirmed successful recharge for user |

> [!IMPORTANT]
> The following events are **STRICTLY EXCLUDED** from Meta and will be dropped by `MetaAppEventsProvider`:
> `content_view`, `content_action`, `search`, `share`, `save`, `like`, `comment`, `notification_open`, `wallet_view`, `begin_checkout`, `payment_initiated`, `payment_failed`, `refund`, `referral_click`, `referral_registration`, `referral_firstpay`, `app_open`, `onboarding_complete`.

---

## 2. Firebase Analytics (Full Product Taxonomy)

Firebase Analytics receives the comprehensive product and engagement analytics taxonomy:

| Category | Firebase Event Name | Description |
| :--- | :--- | :--- |
| Lifecycle | `install`, `app_open`, `onboarding_complete` | User lifecycle & session tracking |
| Authentication | `registration`, `login` | Auth method tracking |
| Content | `content_view`, `content_action`, `search`, `share`, `save`, `like`, `comment` | User devotional engagement |
| Monetization | `begin_checkout`, `payment_initiated`, `payment_success`, `payment_failed`, `refund` | Funnel & payment metrics |
| Referrals | `referral_click`, `referral_registration`, `referral_firstpay` | Growth and referral attribution |

---

## 3. Supabase Internal Analytics

Supabase stores full persistent business records in PostgreSQL tables:
- `public.profiles`: User registration identity & auth history
- `public.subscription_transactions`: Confirmed payment records, status, transaction IDs, and milestone sequence
- `public.posts` / `public.post_likes` / `public.post_saves`: Real-time engagement counters
