# 🔥 HOW TO SEE SWIFMETRO LOGS

## Method 1: Same Terminal Window (Easiest)

**This is the standard way:**

1. Open Terminal
2. Run:
   ```bash
   cd /Users/conlanainsworth/Desktop/SwiftMetro
   node swifmetro-server.js
   ```
3. **KEEP THIS TERMINAL OPEN!**
4. Run your iOS app
5. **Logs appear in THIS terminal window**

---

## Method 2: Different Terminal Window (Background Server)

**If you want to use the terminal for other things:**

### Step 1: Start server in background
```bash
cd /Users/conlanainsworth/Desktop/SwiftMetro
node swifmetro-server.js > logs.txt 2>&1 &
```

This will:
- Start server in background
- Save ALL output to `logs.txt`
- Give you your terminal back

### Step 2: Watch logs in a DIFFERENT terminal

**Open a NEW terminal window and run:**
```bash
cd /Users/conlanainsworth/Desktop/SwiftMetro
tail -f logs.txt
```

Now you'll see logs streaming in real-time in this new window! 🔥

### Step 3: To stop the background server
```bash
killall node
```

Or find the process:
```bash
ps aux | grep "node swifmetro"
kill [PID]
```

---

## Method 3: Multiple Terminal Tabs

**Use Terminal tabs:**

1. **Tab 1:** Run server
   ```bash
   node swifmetro-server.js
   ```

2. **Tab 2:** Do your work (git, npm, etc.)

3. **Switch to Tab 1** to see logs

**Keyboard shortcut:** `Cmd+Shift+[` and `Cmd+Shift+]` to switch tabs

---

## Method 4: Split Terminal View (iTerm2)

**If you use iTerm2:**

1. Split window: `Cmd+D` (vertical) or `Cmd+Shift+D` (horizontal)
2. **Left pane:** Run server
3. **Right pane:** Do your work
4. See logs on left, work on right! 

---

## Quick Reference

**Start server (foreground):**
```bash
node swifmetro-server.js
```

**Start server (background, save to file):**
```bash
node swifmetro-server.js > logs.txt 2>&1 &
```

**Watch logs from file (in different terminal):**
```bash
tail -f logs.txt
```

**Stop background server:**
```bash
killall node
# or
lsof -ti:8081 | xargs kill -9
```

**Check if server is running:**
```bash
lsof -i :8081
```

---

## What You Should See

When iPhone connects:
```
🔥🔥🔥 iPHONE CONNECTED at 02:41:50!
📱 🚀 App launched: SwifMetro wireless logging ACTIVE!
📱 🔄 User tapped button
📱 ✅ API call successful
```

If you don't see logs:
1. Make sure server is running (`lsof -i :8081`)
2. Make sure iPhone and Mac are on same WiFi
3. Check that you added SwifMetroClient.start() to your app
4. Rebuild your iOS app

---

## Pro Tip: Use `screen` or `tmux`

**For advanced users:**

Start server in a `screen` session:
```bash
screen -S swifmetro
node swifmetro-server.js
```

Detach: Press `Ctrl+A` then `D`

Reattach later (from ANY terminal):
```bash
screen -r swifmetro
```

Server keeps running even if you close terminal! 🚀
