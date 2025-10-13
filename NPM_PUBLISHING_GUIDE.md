# 📦 npm Publishing Guide for SwifMetro

**Complete guide to publishing and managing SwifMetro on npm registry**

---

## 🎯 Quick Reference

| Action | Command |
|--------|---------|
| Test locally | `npm pack` |
| Login to npm | `npm login` |
| Publish package | `npm publish` |
| Check if published | `npm info swifmetro` |
| Update version | `npm version patch/minor/major` |
| Unpublish (emergency) | `npm unpublish swifmetro@version` |

---

## 🔑 Prerequisites

### 1. npm Account

**If you don't have an npm account:**

```bash
# Sign up at https://www.npmjs.com/signup
# Then login via terminal:
npm login
```

**If you already have an account:**

```bash
# Login
npm login

# Verify you're logged in
npm whoami
```

### 2. Package Name Availability

```bash
# Check if "swifmetro" is available
npm info swifmetro

# If it shows "npm ERR! code E404" → Name is available ✅
# If it shows package info → Name is taken ❌
```

**If name is taken:**
- Use scoped package: `@yourusername/swifmetro`
- Update package.json: `"name": "@yourusername/swifmetro"`
- Scoped packages are free and look professional

### 3. Verify package.json

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Check package.json has required fields
cat package.json | grep -E "name|version|description|main|repository"
```

**Required fields:**
```json
{
  "name": "swifmetro",
  "version": "1.0.0",
  "description": "Professional wireless iOS logging system...",
  "main": "electron-main.js",
  "repository": {
    "type": "git",
    "url": "https://github.com/SwifMetro/SwifMetro.git"
  }
}
```

---

## 🧪 Testing Before Publishing

**ALWAYS test locally before publishing to npm!**

### Step 1: Create Test Package

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Create tarball (what npm would distribute)
npm pack
```

**Output:** `swifmetro-1.0.0.tgz` (or current version)

### Step 2: Test Install

```bash
# Create test directory
mkdir -p ~/Desktop/npm-test
cd ~/Desktop/npm-test

# Install from local tarball
npm install ~/Desktop/SwifMetro-Public-NPM/swifmetro-1.0.0.tgz

# Verify installation
ls node_modules/swifmetro/
```

### Step 3: Test Functionality

```bash
cd ~/Desktop/npm-test

# Test server
node node_modules/swifmetro/swifmetro-server.js

# Test Electron (in new terminal)
npm start --prefix node_modules/swifmetro
```

**If tests pass** → Ready to publish ✅
**If tests fail** → Fix issues, then repeat from Step 1 ❌

---

## 🚀 Publishing to npm

### First-Time Publish

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Final check - verify .npmignore is correct
cat .npmignore

# Verify no secrets in code
grep -r "API_KEY\|SECRET\|PASSWORD" . --exclude-dir=node_modules

# Publish!
npm publish
```

**What happens:**
1. npm reads package.json
2. npm checks .npmignore and excludes files
3. npm uploads to registry
4. Package live at: https://www.npmjs.com/package/swifmetro
5. Anyone can install: `npm install -g swifmetro`

### If Publish Fails

**Error: "You must be logged in"**
```bash
npm login
# Enter username, password, email
# Re-run: npm publish
```

**Error: "Package name taken"**
```bash
# Option 1: Use scoped package
# Update package.json:
# "name": "@yourusername/swifmetro"
npm publish --access public
```

**Error: "402 Payment Required"**
- You're trying to publish scoped package as private
- Solution: Add `--access public` flag
```bash
npm publish --access public
```

**Error: "403 Forbidden"**
- You don't own this package name
- Someone else published it first
- Solution: Choose different name

---

## 📊 Verify Publication

### Check npm Registry

```bash
# View package info
npm info swifmetro

# Should show:
# - Version: 1.0.0
# - Description: Your description
# - Repository: GitHub link
# - Dependencies
```

### Test Fresh Install

```bash
# On any machine (or clean directory)
npm install -g swifmetro

# Should download from npm registry
# Verify installation
which swifmetro
npm list -g swifmetro
```

### Check npm Website

Visit: https://www.npmjs.com/package/swifmetro

**Verify:**
- [x] Package name correct
- [x] Version shows 1.0.0
- [x] Description displays
- [x] README renders correctly
- [x] GitHub link works (after making repo public)
- [x] Weekly downloads counter starts at 0

---

## 🔄 Publishing Updates

### Version Numbering (Semantic Versioning)

```
MAJOR.MINOR.PATCH
1.0.0 → Initial release

Examples:
1.0.0 → 1.0.1  (Bug fix, backwards compatible)
1.0.1 → 1.1.0  (New feature, backwards compatible)
1.1.0 → 2.0.0  (Breaking change, not backwards compatible)
```

### Patch Update (Bug Fixes)

```bash
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Update version: 1.0.0 → 1.0.1
npm version patch

# This automatically:
# 1. Updates package.json version
# 2. Creates git commit
# 3. Creates git tag

# Push to GitHub
git push && git push --tags

# Publish to npm
npm publish
```

### Minor Update (New Features)

```bash
# Update version: 1.0.0 → 1.1.0
npm version minor

# Push and publish
git push && git push --tags
npm publish
```

### Major Update (Breaking Changes)

```bash
# Update version: 1.0.0 → 2.0.0
npm version major

# Push and publish
git push && git push --tags
npm publish
```

### Manual Version Update

If you prefer manual control:

```bash
# Edit package.json manually
# Change: "version": "1.0.0" → "version": "1.0.1"

# Commit
git add package.json
git commit -m "Bump version to 1.0.1"
git tag v1.0.1
git push && git push --tags

# Publish
npm publish
```

---

## 📈 Monitoring Your Package

### View Download Stats

```bash
# View download counts
npm info swifmetro --json | grep downloads

# Or visit:
# https://www.npmjs.com/package/swifmetro
```

### Check Dependents

```bash
# See who's using your package
npm info swifmetro --json | grep dependents
```

### View Issues

Users will report issues at:
- GitHub: https://github.com/SwifMetro/SwifMetro/issues
- npm also has feedback system

---

## 🛡️ Security & Best Practices

### What Gets Published

**Included** (users can see):
```
✅ electron-main.js
✅ dashboard files (.js, .html, .css)
✅ swifmetro-server.js (public version)
✅ package.json
✅ README.md
✅ All code in src/ folder
```

**Excluded** (via .npmignore):
```
❌ CONFIDENTIAL/ folder
❌ .env files
❌ .git/ folder
❌ *.pem, *.key files
❌ node_modules/
❌ Test files (if specified)
```

### Verify Before Each Publish

```bash
# Check what will be published
npm pack --dry-run

# Or create tarball and inspect
npm pack
tar -tzf swifmetro-1.0.0.tgz
```

### Security Scan

```bash
# Before publishing, scan for secrets
cd /Users/conlanainsworth/Desktop/SwifMetro-Public-NPM

# Check for common secret patterns
grep -r "API_KEY\|SECRET\|PASSWORD\|sk_live\|pk_live" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git

# Should return nothing (or only comments/documentation)
```

---

## 🚨 Emergency Unpublish

**Use only if you accidentally published secrets!**

```bash
# Unpublish specific version (within 72 hours)
npm unpublish swifmetro@1.0.0

# Unpublish all versions (DANGEROUS - use cautiously)
npm unpublish swifmetro --force
```

**Important:**
- Can only unpublish within 72 hours of publishing
- After 72 hours, use `npm deprecate` instead
- Unpublishing is discouraged (breaks dependents)

### Deprecate Instead

If >72 hours, deprecate the version:

```bash
# Mark version as deprecated
npm deprecate swifmetro@1.0.0 "Security issue - please upgrade to 1.0.1"

# Users will see warning when installing
```

---

## 🔧 Advanced: Publishing Scoped Packages

**If "swifmetro" name is taken:**

### Update package.json

```json
{
  "name": "@yourusername/swifmetro",
  "version": "1.0.0"
}
```

### Publish as Public

```bash
npm publish --access public
```

### Users Install With:

```bash
npm install -g @yourusername/swifmetro
```

**Benefits:**
- Unique namespace (never conflicts)
- Professional appearance
- Free on npm

---

## 📋 Pre-Publish Checklist

Before running `npm publish`, verify:

- [ ] Tested with `npm pack` + local install
- [ ] Version number updated (if not first publish)
- [ ] README.md up to date
- [ ] CHANGELOG.md updated (if you maintain one)
- [ ] No secrets in code (ran security scan)
- [ ] .npmignore excludes sensitive files
- [ ] package.json has correct info
- [ ] GitHub repository URL correct
- [ ] Logged in to npm (`npm whoami`)
- [ ] Git changes committed and pushed

**If all checked** → `npm publish` ✅

---

## 🎯 Post-Publish Checklist

After running `npm publish`:

- [ ] Verify package live: `npm info swifmetro`
- [ ] Check npm website: https://www.npmjs.com/package/swifmetro
- [ ] Test fresh install: `npm install -g swifmetro` (from clean directory)
- [ ] Verify README renders correctly on npm
- [ ] Make GitHub repo public (if not already)
- [ ] Test GitHub link from npm page (should work, not 404)
- [ ] Announce on social media / to users (optional)

---

## 💡 Tips & Tricks

### Automated Publishing

Create `.github/workflows/publish.yml` for automatic npm publishing on git tag:

```yaml
name: Publish to npm

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      - run: npm install
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}}
```

### npm Badges for README

Add download badges to README.md:

```markdown
![npm](https://img.shields.io/npm/v/swifmetro)
![npm](https://img.shields.io/npm/dt/swifmetro)
![npm](https://img.shields.io/npm/l/swifmetro)
```

### Keywords for Discoverability

Add to package.json:

```json
{
  "keywords": [
    "ios",
    "logging",
    "debugging",
    "websocket",
    "electron",
    "swift",
    "xcode",
    "developer-tools"
  ]
}
```

Helps users find your package when searching npm.

---

## 📞 Getting Help

### npm Support
- Documentation: https://docs.npmjs.com/
- Support: https://www.npmjs.com/support

### Common Issues
- Package name conflicts: Use scoped package
- Publishing errors: Check npm status (https://status.npmjs.com/)
- Login issues: Reset password, verify email

---

## 📅 Maintenance Schedule

**Recommended:**
- Check for security vulnerabilities: Weekly (`npm audit`)
- Update dependencies: Monthly (`npm update`)
- Publish patches: As needed (bug fixes)
- Publish minor versions: Quarterly (new features)
- Publish major versions: Yearly (breaking changes)

---

## 🎉 You're Ready!

**Current Status:**
- ✅ Package ready at: `/Users/conlanainsworth/Desktop/SwifMetro-Public-NPM`
- ✅ Testing guide available: `TESTING_CHECKLIST.md`
- ✅ Launch guide available: `LAUNCH_INSTRUCTIONS.md`
- ⏳ Awaiting: Local testing → npm publish

**Next Steps:**
1. Complete `TESTING_CHECKLIST.md`
2. Run `npm publish`
3. Make GitHub public
4. Celebrate! 🎉

---

*Last Updated: 2025-10-13*
*Package Name: swifmetro*
*Current Version: 1.0.0*
*npm Registry: https://www.npmjs.com/package/swifmetro (pending)*
