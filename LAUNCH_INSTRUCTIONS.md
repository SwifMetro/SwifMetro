# 🚀 SwifMetro Launch Instructions

**CURRENT STATUS**: Repository ready, awaiting final testing and public launch

This document provides step-by-step instructions for testing and launching SwifMetro to the public.

---

## 📋 Pre-Launch Checklist

Before making anything public, verify:

- [x] All code copied to SwifMetro-Public-NPM folder
- [x] Security scan passed (no secrets in repository)
- [x] .npmignore configured (excludes CONFIDENTIAL/, .env*, *.pem, *.key)
- [x] package.json updated with correct entry point (electron-main.js)
- [x] All dependencies listed correctly
- [x] GitHub repository exists at https://github.com/SwifMetro/SwifMetro
- [ ] Local testing completed (see Testing Phase below)
- [ ] npm publishing completed
- [ ] GitHub repository made public

---

## 🧪 PHASE 1: Private Testing (DO THIS FIRST)

Test the npm package locally WITHOUT publishing publicly:

### Step 1: Create Local Test Package

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Create a tarball (this is what npm would distribute)
npm pack
```

**Result**: Creates `swifmetro-1.0.0.tgz` (or similar version number)

### Step 2: Test Installation in Fresh Location

```bash
# Create a test directory
mkdir -p ~/Desktop/SwifMetro-TEST-INSTALL
cd ~/Desktop/SwifMetro-TEST-INSTALL

# Install from the local tarball (simulates real user experience)
npm install ~/Desktop/SwifMetro-Public-NPM/swifmetro-1.0.0.tgz

# Verify installation
ls -la node_modules/swifmetro/
```

### Step 3: Test Running SwifMetro

```bash
cd ~/Desktop/SwifMetro-TEST-INSTALL/node_modules/swifmetro

# Test server mode
npm run server

# Test Electron dashboard mode (in new terminal)
npm start
```

### Step 4: Test with iOS Client

1. Open Xcode with SwiftMetroTEST
2. Update connection to point to localhost:8081
3. Run iOS simulator
4. Verify logs appear in dashboard
5. Test all features:
   - Log filtering
   - Pause/Resume
   - Export (CSV, JSON, TXT)
   - Theme toggle (dark/light)
   - Multiple device connections

### Step 5: Verify License System

```bash
# Remove any existing trial data
rm -rf ~/Library/Application\ Support/SwifMetro/trial.json

# Start SwifMetro
npm start

# Should see license prompt with 7-day trial option
# Test:
# - Demo key: SWIF-DEMO-DEMO-DEMO (should work)
# - Invalid key: TEST-TEST-TEST-TEST (should fail)
# - Trial activation (should create trial.json)
```

---

## 🌍 PHASE 2: Public Launch

**IMPORTANT**: Only proceed after completing ALL testing above!

### Step 1: Publish to npm Registry

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Login to npm (if not already logged in)
npm login
# Enter your npm credentials

# Publish the package
npm publish

# Verify it's live
npm info swifmetro
```

**What happens:**
- Package uploaded to https://www.npmjs.com/package/swifmetro
- Anyone in the world can now run: `npm install -g swifmetro`
- Your code becomes publicly visible (but this is expected/normal)

### Step 2: Make GitHub Repository Public

```bash
# Option A: Via GitHub Web Interface (RECOMMENDED)
# 1. Go to https://github.com/SwifMetro/SwifMetro/settings
# 2. Scroll to "Danger Zone"
# 3. Click "Change visibility"
# 4. Click "Make public"
# 5. Type repository name to confirm
# 6. Click "I understand, make this repository public"
```

**What happens:**
- Repository visible at https://github.com/SwifMetro/SwifMetro
- Users can browse code, see README, file issues
- npm package links now work (no more 404s)

### Step 3: Verify Public Access

```bash
# Test as if you're a new user
cd ~/Desktop/TEST-PUBLIC-INSTALL
npm install -g swifmetro

# Verify it works
swifmetro --version
npm start
```

### Step 4: Verify GitHub Links Work

1. Visit https://www.npmjs.com/package/swifmetro
2. Click "Repository" link
3. Should land on https://github.com/SwifMetro/SwifMetro (not 404)
4. Verify README displays correctly
5. Check all files are visible

---

## 📦 What Users Will See After Launch

### When they run `npm install -g swifmetro`:

```
They get these files:
├── electron-main.js          (Electron launcher with license system)
├── preload.js                (Electron security bridge)
├── swifmetro-server.js       (WebSocket server - public version, no secrets)
├── swifmetro-dashboard.html  (Dashboard UI structure)
├── dashboard-main.js         (Core log management)
├── dashboard-ui.js           (UI interactions)
├── dashboard-styles.css      (Styling)
├── dashboard-utils.js        (Helper utilities)
├── package.json              (Dependencies and scripts)
└── README.md                 (Documentation)
```

### Code Visibility

**YES - Code is visible** (this is normal for npm packages):
- Users can view all .js, .html, .css files after installation
- This is industry standard (VS Code, Sentry, Stripe SDK all work this way)

**NO - Business is still protected**:
- License validation happens on YOUR backend server (not included in npm)
- PostgreSQL database credentials (not included)
- Payment processing via Stripe (your webhook server)
- Hardware ID fingerprinting prevents license sharing

**Remember**: They can READ your code, but they can't:
- Generate valid license keys (only your backend can)
- Access your PostgreSQL database (connection string excluded)
- Process payments (Stripe keys excluded)
- Deploy your backend (payment-server.js excluded)

---

## 🛡️ Security Reminders

### Files NEVER Published (verified by .npmignore):

```
CONFIDENTIAL/            (entire folder excluded)
.env                     (environment variables)
.env.local              (local secrets)
.env.production         (production secrets)
*.pem                   (SSL certificates)
*.key                   (private keys)
payment-server.js       (not in this repo - stays private)
DATABASE_URL            (PostgreSQL connection - stays private)
STRIPE_SECRET_KEY       (payment processing - stays private)
```

### What Stays Private Forever:

1. **SwifMetro-PerfectWorking/** folder (your private dev environment)
2. **payment-server.js** (license validation backend)
3. **PostgreSQL database** (Railway/Supabase)
4. **Stripe webhook server** (payment processing)
5. **Email API keys** (Resend.com)

---

## 🔄 Post-Launch Updates

### To publish updates to npm:

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Update version number
npm version patch    # 1.0.0 → 1.0.1 (bug fixes)
npm version minor    # 1.0.0 → 1.1.0 (new features)
npm version major    # 1.0.0 → 2.0.0 (breaking changes)

# Commit version bump
git add package.json
git commit -m "Bump version to X.X.X"
git push

# Publish to npm
npm publish
```

### To update GitHub:

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Make changes to code
# ...

# Commit and push
git add .
git commit -m "Description of changes"
git push origin main
```

---

## 📞 Support & Issues

After launch, users will:
- Report issues at: https://github.com/SwifMetro/SwifMetro/issues
- Ask questions in GitHub Discussions (if enabled)
- Contact you via email (add to README.md)

---

## ⏱️ Estimated Timeline

| Task | Time Required |
|------|---------------|
| Local testing (Phase 1) | 30-60 minutes |
| npm publish (Phase 2, Step 1) | 2 minutes |
| Make GitHub public (Phase 2, Step 2) | 30 seconds |
| Verification (Phase 2, Steps 3-4) | 5 minutes |
| **TOTAL** | **~45-70 minutes** |

---

## 🎯 Success Criteria

You'll know launch is successful when:

✅ `npm install -g swifmetro` works from any machine
✅ GitHub repository visible at https://github.com/SwifMetro/SwifMetro
✅ npm package page shows correct info at https://www.npmjs.com/package/swifmetro
✅ Users can run `swifmetro` or `npm start` after installation
✅ License system prompts correctly
✅ Dashboard connects to iOS devices
✅ All features working (logs, filters, export, themes)

---

## 🆘 Troubleshooting

### "npm publish" fails with 403 error
```bash
# Re-login to npm
npm logout
npm login
npm publish
```

### "Package name already taken"
- Someone else registered `swifmetro` on npm
- Solution: Use scoped package `@yourusername/swifmetro`
- Update package.json: `"name": "@yourusername/swifmetro"`

### GitHub won't make repo public
- Check if you have admin permissions
- Verify repository settings allow visibility changes
- Ensure no security policies blocking public repos

### Users report installation errors
```bash
# Check npm package integrity
npm info swifmetro

# Test fresh install yourself
npm install -g swifmetro
```

---

## 📝 Final Notes

- **GitHub private → npm public**: Not recommended (users see 404 on GitHub link)
- **Both private**: Good for testing, but delays launch
- **Both public**: Recommended approach (professional, no broken links)

**CURRENT RECOMMENDATION**:
1. Complete private testing (Phase 1)
2. Publish to npm (Phase 2, Step 1)
3. Make GitHub public immediately after (Phase 2, Step 2)
4. Total time: ~2 minutes to go fully public

---

*Last Updated: 2025-10-13*
*Repository: https://github.com/SwifMetro/SwifMetro*
*npm Package: https://www.npmjs.com/package/swifmetro (pending publish)*
