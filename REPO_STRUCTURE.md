# ✅ YOU ARE IN: SwifMetro-Public-NPM

# 📦 THIS IS THE PUBLIC iOS DISTRIBUTION REPO

**Connected to:**
- GitHub: `https://github.com/SwifMetro/SwifMetro` (PUBLIC!)
- Customers download from here via Swift Package Manager

---

# SWIFMETRO REPOSITORY STRUCTURE & WORKFLOW

**CRITICAL:** Read this before pushing to ANY GitHub repository!

Last Updated: October 16, 2025

---

## ✅ CURRENT FOLDER: SwifMetro-Public-NPM

**This folder:**
- ✅ **IS on GitHub** (PUBLIC repo)
- ⚠️ **Only push during releases**
- 📦 **Contains compiled binaries (NOT source code)**
- 🌍 **Public - anyone can see this**

**What you CAN do:**
- ✅ Build xcframework: `./build-xcframework.sh`
- ✅ Push during official releases only
- ✅ Create version tags
- ✅ Upload to GitHub releases

**What you MUST NOT commit:**
- ❌ Source code (that's in SwiftMetroTEST)
- ❌ Secrets or API keys
- ❌ Work-in-progress changes

**Release Workflow:**
1. Build xcframework here
2. Calculate checksum
3. Update Package.swift
4. Tag version (e.g., v1.0.11)
5. Push to GitHub
6. Create release with binary

---

## 📁 FOLDER OVERVIEW

### 1. **SwiftMetroTEST** - Private iOS Source Code
**Location:** `/Users/conlanainsworth/Desktop/SwiftMetroTEST/`

**Purpose:** Private iOS SDK development (source code)

**GitHub:** `https://github.com/SwifMetro/SwiftMetroTEST` (PRIVATE)

**Contains:**
- `Sources/SwifMetro/*.swift` - iOS SDK source code
- Raw Swift files
- Development and testing code

**Push To GitHub:** ✅ YES (after testing)
- This is YOUR private source code
- Only you can see it
- Push after completing features

**Command:**
```bash
cd /Users/conlanainsworth/Desktop/SwiftMetroTEST
git add .
git commit -m "Feature: description"
git push origin main
```

---

### 2. **SwifMetro-Public-NPM** - Public iOS Distribution
**Location:** `/Users/conlanainsworth/Desktop/SwifMetro-Public-NPM/`

**Purpose:** Public binary distribution for customers via Swift Package Manager

**GitHub:** `https://github.com/SwifMetro/SwifMetro` (PUBLIC)

**Contains:**
- `Package.swift` - SPM manifest
- `SwifMetro.xcframework/` - Compiled binary
- `SwifMetro.xcframework.zip` - Binary archive
- `build-xcframework.sh` - Build script

**Push To GitHub:** ✅ YES (only during releases)
- Push ONLY when releasing a new version
- Contains NO source code, only compiled binaries
- Customers download from here

**Release Process:**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM
./build-xcframework.sh
shasum -a 256 SwifMetro.xcframework.zip
# Update Package.swift with new checksum
git add Package.swift SwifMetro.xcframework.zip
git commit -m "Release: v1.0.11"
git tag -a v1.0.11 -m "Release v1.0.11"
git push origin main
git push origin v1.0.11
gh release create v1.0.11 SwifMetro.xcframework.zip
```

**Customers Use:**
```swift
// In Xcode: File → Add Package Dependencies
https://github.com/SwifMetro/SwifMetro
```

---

### 3. **SwifMetro-PerfectWorking** - Runtime Development (NOT ON GITHUB!)
**Location:** `/Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking/`

**Purpose:** Customer-facing macOS Electron app development

**GitHub:** ❌ **NEVER PUSH TO GITHUB** (contains secrets!)

**Contains:**
- `electron-main.js` - Main Electron process
- `swifmetro-server.js` - WebSocket server
- `swifmetro-dashboard.html` - Dashboard UI
- `package.json` - App configuration
- `.env` - **SECRETS** (Stripe keys, API keys)
- `licenses.json` - **SENSITIVE DATA**
- `payment-server.js` - Payment logic

**Push To GitHub:** ❌ **ABSOLUTELY NOT!**

**Why NOT:**
- Contains `.env` file with Stripe secret keys
- Contains `licenses.json` with customer data
- Contains payment server with sensitive logic
- These MUST stay private

**What To Do Instead:**
- Keep local only
- Backup locally or encrypted cloud
- Use for DMG builds only
- Release DMGs to GitHub (not the source)

**DMG Release Process:**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
export DEBUG=true
npm run build
# Upload DMGs to GitHub releases manually
```

---

### 4. **SwifMetro-EmployeeAdmin** - Internal Admin Dashboard
**Location:** `/Users/conlanainsworth/Desktop/SwifMetro-EmployeeAdmin/`

**Purpose:** Internal employee dashboard for monitoring signups, licenses, payments

**GitHub:** `https://github.com/SwifMetro/-swifmetro-admin` (PRIVATE)

**Railway:** ✅ Connected (auto-deploys from GitHub)

**Contains:**
- `payment-server.js` - Stripe integration
- `unified-admin-server.js` - Admin dashboard
- `licenses.json` - License database
- `.env.example` - Template (no real secrets)
- Railway configuration

**Push To GitHub:** ✅ YES
- This repo is private
- Deploys to Railway automatically
- Do NOT commit `.env` file (use .env.example)

**Command:**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-EmployeeAdmin
git add .
git commit -m "Update: description"
git push origin main
# Railway auto-deploys
```

**Railway Environment Variables:**
- Set sensitive values in Railway dashboard
- Never commit actual `.env` file

---

### 5. **SwifMetroNetlify** - Marketing Website
**Location:** `/Users/conlanainsworth/Desktop/SwifMetroNetlify/`

**Purpose:** Public marketing website (swifmetro.netlify.app)

**GitHub:** `https://github.com/SwifMetro/SwifMetroNetlify` (PRIVATE for now)

**Netlify:** ✅ Connected (auto-deploys from GitHub)

**Contains:**
- `swiftmetro.html` - Main product page
- `checkout-page.html` - Checkout form
- `download.html` - Download page
- `pricing.html` - Pricing page
- All HTML/CSS/JS website files

**Push To GitHub:** ✅ YES
- Netlify auto-deploys on push
- No secrets in this repo
- Public-facing content only

**Command:**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetroNetlify
git add .
git commit -m "Update: description"
git push origin main
# Netlify auto-deploys
```

**Live Site:** https://swifmetro.netlify.app

---

## 🔄 COMPLETE RELEASE WORKFLOW

### When You're Ready to Release a New Version:

**Step 1: Decide Version Number**
```
Current: 1.0.10
Next: 1.0.11 (bug fix) or 1.1.0 (new feature) or 2.0.0 (breaking change)
```

**Step 2: Build iOS Framework**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM
# Edit build-xcframework.sh (update version in 3 places)
./build-xcframework.sh
shasum -a 256 SwifMetro.xcframework.zip
# Update Package.swift with new checksum
```

**Step 3: Build macOS DMG**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
# Edit package.json (update version)
export DEBUG=true
npm run build
```

**Step 4: Push iOS Source**
```bash
cd /Users/conlanainsworth/Desktop/SwiftMetroTEST
git add .
git commit -m "Release: v1.0.11 improvements"
git push origin main
```

**Step 5: Push iOS Framework**
```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM
git add Package.swift SwifMetro.xcframework.zip build-xcframework.sh
git commit -m "Release: SwifMetro v1.0.11"
git tag -a v1.0.11 -m "Release v1.0.11"
git push origin main
git push origin v1.0.11
```

**Step 6: Create GitHub Releases**
```bash
# iOS Release
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM
gh release create v1.0.11 \
  --title "SwifMetro v1.0.11" \
  --notes "Release notes..." \
  SwifMetro.xcframework.zip

# macOS Release
cd /Users/conlanainsworth/Desktop/SwifMetro-PerfectWorking
gh release create v1.0.11-macos \
  --repo SwifMetro/SwifMetro \
  --title "SwifMetro macOS v1.0.11" \
  --notes "Release notes..." \
  dist/SwifMetro-1.0.11.dmg \
  dist/SwifMetro-1.0.11-arm64.dmg
```

---

## ⚠️ CRITICAL WARNINGS

### NEVER COMMIT THESE FILES:
```
.env
.env.local
.env.production
licenses.json
payment-server.js (from SwifMetro-PerfectWorking)
Any file with Stripe keys
Any file with API keys
Any file with customer data
```

### NEVER PUSH THESE FOLDERS TO GITHUB:
```
SwifMetro-PerfectWorking/     ❌ Contains secrets!
SwifMetro-PerfectWorking/.env ❌ Stripe keys!
```

### ALWAYS CHECK BEFORE PUSHING:
```bash
# Search for secrets
grep -r "sk_" . | grep -v node_modules
grep -r "pk_" . | grep -v node_modules
grep -r "STRIPE" . | grep -v node_modules

# Check what you're about to push
git diff HEAD
git status
```

---

## 🔐 SECRETS MANAGEMENT

### Railway (Backend)
**Set in Railway Dashboard → Variables:**
- `STRIPE_SECRET_KEY`
- `RESEND_API_KEY`
- `ALLOWED_ORIGINS`
- `FRONTEND_URL`
- `SUPPORT_EMAIL`
- `NODE_ENV=production`

**Never commit `.env` to GitHub!**

### Netlify (Website)
**No secrets needed** - just HTML/CSS/JS

### Local Development
**SwifMetro-PerfectWorking/.env:**
```bash
# Keep this file LOCAL only!
# Never commit to Git
STRIPE_SECRET_KEY=sk_test_...
RESEND_API_KEY=re_...
```

---

## 📊 REPOSITORY DIAGRAM

```
┌─────────────────────────────────────────────────┐
│  SwiftMetroTEST (PRIVATE)                      │
│  ├── Sources/SwifMetro/*.swift                 │
│  └── GitHub: SwifMetro/SwiftMetroTEST          │
│      ↓                                          │
│  [Build xcframework]                            │
│      ↓                                          │
│  SwifMetro-Public-NPM (PUBLIC)                 │
│  ├── SwifMetro.xcframework.zip                 │
│  ├── Package.swift                             │
│  └── GitHub: SwifMetro/SwifMetro               │
│      ↓                                          │
│  [Customers install via SPM]                    │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  SwifMetro-PerfectWorking (NOT ON GITHUB)      │
│  ├── electron-main.js                          │
│  ├── swifmetro-server.js                       │
│  ├── .env (SECRETS!)                           │
│  └── NOT on GitHub!                             │
│      ↓                                          │
│  [Build DMG]                                    │
│      ↓                                          │
│  [Upload DMGs to GitHub Releases manually]      │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  SwifMetro-EmployeeAdmin (PRIVATE)             │
│  ├── payment-server.js                         │
│  ├── unified-admin-server.js                   │
│  └── GitHub: SwifMetro/-swifmetro-admin        │
│      ↓                                          │
│  [Auto-deploy to Railway]                       │
│      ↓                                          │
│  Railway Backend (production)                   │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  SwifMetroNetlify (PRIVATE)                    │
│  ├── swiftmetro.html                           │
│  ├── checkout-page.html                        │
│  └── GitHub: SwifMetro/SwifMetroNetlify        │
│      ↓                                          │
│  [Auto-deploy to Netlify]                       │
│      ↓                                          │
│  https://swifmetro.netlify.app                  │
└─────────────────────────────────────────────────┘
```

---

## 🎯 QUICK REFERENCE

| Folder | GitHub? | Push? | Purpose |
|--------|---------|-------|---------|
| SwiftMetroTEST | ✅ Private | ✅ YES | iOS source code |
| SwifMetro-Public-NPM | ✅ Public | ✅ YES (releases) | iOS binary distribution |
| SwifMetro-PerfectWorking | ❌ NO | ❌ NEVER | macOS app (has secrets) |
| SwifMetro-EmployeeAdmin | ✅ Private | ✅ YES | Admin dashboard → Railway |
| SwifMetroNetlify | ✅ Private | ✅ YES | Website → Netlify |

---

## 📝 BEFORE EVERY PUSH CHECKLIST

- [ ] Am I in the correct folder?
- [ ] Is this folder supposed to be on GitHub?
- [ ] Did I check for secrets? (grep for sk_, pk_, API keys)
- [ ] Did I check git status?
- [ ] Did I read this document?
- [ ] Am I pushing to the correct repo?

---

**END OF DOCUMENT**

For questions, see: `CONFIDENTIAL/RELEASE_WORKFLOW.md`
