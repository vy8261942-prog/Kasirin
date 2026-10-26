# Kasirin Mobile - Server Integration Parity Matrix

## Legend
- ✅ **Implemented** - Fully working
- ⚠️ **Partial** - Partially working, needs completion
- ❌ **Missing** - Not implemented
- 📝 **Todo** - Planned task

## Integration Status: Mobile App ↔ Billing Server

| Feature | Status | Notes | Server Reference |
|---------|--------|-------|-----------------|
| **Device Registration** | ⚠️ Partial | `_initializeBilling()` calls `registerDevice` on startup; requires valid server URL & credentials | `POST /api/pos/register` |
| **License Status Check** | ❌ Missing | No `GET /api/pos/license` calls from mobile | `GET /api/pos/license` (bearer token) |
| **Device Status/Subscription** | ❌ Missing | No `GET /api/pos/status` calls from mobile | `GET /api/pos/status` (bearer token) |
| **Checkout Creation (Server)** | ❌ Missing | Local checkout only; no server-side order creation | `POST /api/checkout/create` |
| **Midtrans Snap Payment** | ❌ Missing | Only cash supported; Snap integration not wired | `create_snap_transaction()` |
| **Payment Webhook Handling** | ❌ Missing | No webhook reception on mobile | `POST /webhooks/payment/midtrans` |
| **License Signing (Ed25519)** | ❌ Missing | Mobile doesn't sign license documents | `sign_payload()`, `activate_license()` |
| **Throttled Payment Verification** | ❌ Missing | No polling of pending orders via `_LAST_VERIFY` | `verify_pending_for_device()` |
| **Roadmap/Subscription Data** | ❌ Missing | No roadmap fetching from server | `load_roadmap()`, `plan_catalog()` |
| **Customer Auth (JWT)** | ❌ Missing | No session token management from server | `auth_service.py`, `customer_for_token()` |
| **Server Health Check** | ⚠️ Partial | `_initializeBilling()` checks `GET /health`; falls back to offline mode | `GET /health` |

## Desktop ↔ Mobile Feature Parity

| Desktop Feature | Mobile Status | Gap Analysis |
|----------------|---------------|--------------|
| Owner/store setup | ✅ Complete | Mobile has local setup; no server sync |
| User login/auth | ✅ Complete | Mobile uses PBKDF2; desktop uses Argon2 - not compatible |
| Product CRUD | ✅ Complete | Full local product management |
| Shift management | ✅ Complete | Local shift open/close |
| Cashier checkout (local) | ✅ Complete | Full transaction flow with audit |
| License/activation | ❌ Missing | Desktop has Ed25519 signing; mobile has no licensing |
| Midtrans payment | ⚠️ Partial | Desktop has Snap + simulated ATM; mobile has cash only |
| Reports/finance | ⚠️ Partial | Local journal/audit; no server aggregation |
| Multi-cabang sync | ❌ Missing | Not implemented on either platform |
| WhatsApp reports | ⚠️ Partial | Telegram service exists on server; not integrated in mobile |
| Role-based navigation | ✅ Complete | CASHIER vs OWNER/ADMIN/SUPERVISOR |

## Critical Integration Gaps (Priority Order)

### 1. Device Registration Flow (HIGH)
- **What**: Mobile must register device with server on startup/shift open
- **Why**: Server needs to track device tokens for license delivery, pending order verification
- **How**: 
  - Call `POST /api/pos/register` with posreq content from device
  - Store installation_id and device_id from local DB
  - On first run: create new device record
  - On subsequent runs: update existing device

### 2. License Status Checking (HIGH)  
- **What**: Mobile must check license status via server API
- **Why**: Determine if user has active license, pending payment, or needs to pay
- **How**:
  - Call `GET /api/pos/license` with bearer token after login
  - Parse response: status = "active", "pending", or "none"
  - If pending: show payment options (cash, Midtrans)
  - If active: allow full POS functionality

### 3. Midtrans Payment Integration (MEDIUM)
- **What**: Add Midtrans Snap payment support alongside cash
- **Why**: Enable digital payments (credit card, VA, e-wallet) as in desktop
- **How**:
  - configure `MIDTRANS_SERVER_KEY` in server .env
  - Call `POST /api/checkout/create` with payment method
  - Handle Midtrans redirect/notification
  - Update local license after successful payment

### 4. Server Session/Auth Management (MEDIUM)
- **What**: Manage JWT sessions from server
- **Why**: Secure user authentication, token expiration, logout
- **How**:
  - On login: receive token from `POST /api/auth/login`
  - Store token in secure storage (Android Keystore/iOS Keychain)
  - Use `Authorization: Bearer <token>` for API calls
  - Refresh token when expired
  - Logout: call `POST /api/auth/logout` or clear token

### 5. Roadmap/Subscription Data (LOW)
- **What**: Fetch roadmap and subscription info from server
- **Why**: Keep feature list updated without app update
- **How**:
  - Call `GET /api/pos/status` or `GET /api/pos/license`
  - Display roadmap in dashboard (currently hardcoded)
  - Show subscription status in user profile

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [x] Billing client module (created)
- [x] Device registration on startup
- [ ] Server health check and offline fallback
- [ ] Basic license status check UI

### Phase 2: Payment Integration (Weeks 3-4)
- [ ] Midtrans Snap configuration on server
- [ ] Payment flow: cash + Midtrans
- [ ] License activation after payment
- [ ] Payment method selection UI

### Phase 3: Authentication & Sync (Weeks 5-6)
- [ ] JWT token management
- [ ] Secure token storage
- [ ] Logout flow with server sync
- [ ] Basic data sync (products, customers)

### Phase 4: Advanced Features (Weeks 7-8)
- [ ] Roadmap fetching from server
- [ ] Multi-device support
- [ ] Audit log sync
- [ ] WhatsApp report integration

## Notes for Developers

1. **Server Requirements**: 
   - Ensure `BASE_URL` in server `.env` matches ngrok URL or production domain
   - Set `MIDTRANS_SERVER_KEY` for payment support
   - Keep ngrok tunnel running for development testing

2. **Mobile Requirements**:
   - Add `http` dependency (already in pubspec.yaml)
   - Add secure storage dependency for token persistence
   - Handle API errors gracefully (show offline mode when server unavailable)

3. **Security**:
   - Never hardcode server URLs in release APK
   - Use Flutter secure storage for token persistence
   - Validate all API responses
   - Fall back to local-only mode on API failures

4. **Testing**:
   - Test with server running via ngrok
   - Test offline mode (server unreachable)
   - Test both cash and Midtrans payment flows
   - Verify license status changes after payment
"