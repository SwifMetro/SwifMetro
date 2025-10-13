/**
 * SwifMetro Dashboard - UI Interactions
 * Button handlers, keyboard shortcuts, theme toggle, and UI state management
 */

let pauseCounterInterval = null;

/**
 * Initialize theme system
 */
function initTheme() {
    const darkBtn = document.getElementById('darkBtn');
    const lightBtn = document.getElementById('lightBtn');

    function setTheme(theme) {
        console.log('Setting theme to:', theme);

        if (theme === 'light') {
            document.body.classList.add('light-theme');
            if (lightBtn) lightBtn.classList.add('active');
            if (darkBtn) darkBtn.classList.remove('active');
            localStorage.setItem('swifmetro-theme', 'light');
            console.log('Light theme applied, body has light-theme class:', document.body.classList.contains('light-theme'));
        } else {
            document.body.classList.remove('light-theme');
            if (darkBtn) darkBtn.classList.add('active');
            if (lightBtn) lightBtn.classList.remove('active');
            localStorage.setItem('swifmetro-theme', 'dark');
            console.log('Dark theme applied');
        }
    }

    // Load saved theme
    const savedTheme = localStorage.getItem('swifmetro-theme') || 'dark';
    if (savedTheme === 'light') {
        setTheme('light');
    }

    // Add click listeners to theme buttons
    if (darkBtn) {
        darkBtn.addEventListener('click', function() {
            console.log('Dark button clicked');
            setTheme('dark');
        });
    }

    if (lightBtn) {
        lightBtn.addEventListener('click', function() {
            console.log('Light button clicked');
            setTheme('light');
        });
    }
}

/**
 * Initialize copy all logs button
 */
function initCopyAllButton() {
    const copyBtn = document.getElementById('copyAllBtn');

    if (copyBtn) {
        copyBtn.addEventListener('click', function(e) {
            const filteredLogs = allLogs.filter(log => {
                const matchesFilter = currentFilter === 'all' || log.type === currentFilter;
                const matchesSearch = searchQuery === '' || log.message.toLowerCase().includes(searchQuery.toLowerCase());
                return matchesFilter && matchesSearch;
            });

            const allText = filteredLogs.map(log => {
                let cleanMessage = log.message
                    .replace(/^\[\d+:\d+:\d+\]\s*📱\s*/, '')
                    .replace(/^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\]\s*/, '');
                return `[${log.timestamp}] ${cleanMessage}`;
            }).join('\n');

            const originalText = copyBtn.textContent;

            navigator.clipboard.writeText(allText).then(() => {
                copyBtn.textContent = '✓ Copied!';
                copyBtn.style.background = 'rgba(16, 185, 129, 0.3)';
                copyBtn.style.borderColor = '#10b981';

                setTimeout(() => {
                    copyBtn.textContent = originalText;
                    copyBtn.style.background = 'rgba(102, 126, 234, 0.08)';
                    copyBtn.style.borderColor = 'rgba(102, 126, 234, 0.3)';
                }, 1500);
            });
        });
    }
}

/**
 * Initialize export logs button
 */
function initExportButton() {
    const exportBtn = document.getElementById('exportBtn');

    if (exportBtn) {
        exportBtn.addEventListener('click', function() {
            const filteredLogs = allLogs.filter(log => {
                const matchesFilter = currentFilter === 'all' || log.type === currentFilter;
                const matchesSearch = searchQuery === '' || log.message.toLowerCase().includes(searchQuery.toLowerCase());
                return matchesFilter && matchesSearch;
            });

            const allText = filteredLogs.map(log => {
                let cleanMessage = log.message
                    .replace(/^\[\d+:\d+:\d+\]\s*📱\s*/, '')
                    .replace(/^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\]\s*/, '');
                return `[${log.timestamp}] ${cleanMessage}`;
            }).join('\n');

            const blob = new Blob([allText], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `swifmetro-logs-${new Date().toISOString().slice(0,10)}.txt`;
            a.click();
            URL.revokeObjectURL(url);

            const originalText = exportBtn.textContent;
            exportBtn.textContent = '✓ Exported!';
            exportBtn.style.background = 'rgba(16, 185, 129, 0.3)';
            exportBtn.style.borderColor = '#10b981';

            setTimeout(() => {
                exportBtn.textContent = originalText;
                exportBtn.style.background = 'rgba(102, 126, 234, 0.08)';
                exportBtn.style.borderColor = 'rgba(102, 126, 234, 0.3)';
            }, 1500);
        });
    }
}

/**
 * Initialize restart server button (Electron IPC)
 */
function initRestartButton() {
    const restartServerBtn = document.getElementById('restartServerBtn');

    if (restartServerBtn) {
        restartServerBtn.addEventListener('click', async function() {
            const originalText = restartServerBtn.textContent;
            restartServerBtn.textContent = '🔄 Restarting...';
            restartServerBtn.disabled = true;
            restartServerBtn.style.opacity = '0.6';

            // Close existing WebSocket
            if (ws) {
                try {
                    ws.close();
                } catch(e) {
                    console.log('WebSocket already closed');
                }
                ws = null;
            }

            // Use Electron IPC to restart server
            if (window.electronAPI && window.electronAPI.restartServer) {
                try {
                    restartServerBtn.textContent = '🔄 Stopping server...';
                    const result = await window.electronAPI.restartServer();

                    if (result.success) {
                        restartServerBtn.textContent = '🔄 Reconnecting...';

                        // Try reconnecting with retries
                        let retryCount = 0;
                        const maxRetries = 8;

                        function tryReconnect() {
                            retryCount++;
                            restartServerBtn.textContent = `🔄 Connecting (${retryCount}/${maxRetries})...`;

                            try {
                                reconnectAttempts = 0;
                                connectWebSocket();

                                setTimeout(() => {
                                    if (ws && ws.readyState === WebSocket.OPEN) {
                                        // SUCCESS!
                                        restartServerBtn.textContent = '✅ Connected!';
                                        restartServerBtn.style.background = 'rgba(16, 185, 129, 0.3)';
                                        restartServerBtn.style.borderColor = '#10b981';
                                        restartServerBtn.style.color = '#51cf66';

                                        allLogs = [];
                                        updateLogCount();
                                        renderLogs();

                                        setTimeout(() => {
                                            restartServerBtn.textContent = originalText;
                                            restartServerBtn.style.background = 'rgba(251, 191, 36, 0.08)';
                                            restartServerBtn.style.borderColor = 'rgba(251, 191, 36, 0.3)';
                                            restartServerBtn.style.color = '#fbbf24';
                                            restartServerBtn.disabled = false;
                                            restartServerBtn.style.opacity = '1';
                                        }, 2000);
                                    } else if (retryCount < maxRetries) {
                                        setTimeout(tryReconnect, 1000);
                                    } else {
                                        restartServerBtn.textContent = '❌ Failed';
                                        restartServerBtn.style.background = 'rgba(239, 68, 68, 0.3)';
                                        restartServerBtn.style.borderColor = '#ef4444';
                                        restartServerBtn.style.color = '#ff6b6b';

                                        setTimeout(() => {
                                            restartServerBtn.textContent = originalText;
                                            restartServerBtn.style.background = 'rgba(251, 191, 36, 0.08)';
                                            restartServerBtn.style.borderColor = 'rgba(251, 191, 36, 0.3)';
                                            restartServerBtn.style.color = '#fbbf24';
                                            restartServerBtn.disabled = false;
                                            restartServerBtn.style.opacity = '1';
                                        }, 2000);
                                    }
                                }, 1000);
                            } catch (e) {
                                console.error('Reconnect error:', e);
                                if (retryCount < maxRetries) {
                                    setTimeout(tryReconnect, 1000);
                                }
                            }
                        }

                        tryReconnect();
                    } else {
                        throw new Error(result.error || 'Restart failed');
                    }
                } catch (error) {
                    console.error('Restart error:', error);
                    restartServerBtn.textContent = '❌ Error';
                    restartServerBtn.style.background = 'rgba(239, 68, 68, 0.3)';
                    restartServerBtn.style.borderColor = '#ef4444';
                    restartServerBtn.style.color = '#ff6b6b';

                    setTimeout(() => {
                        restartServerBtn.textContent = originalText;
                        restartServerBtn.style.background = 'rgba(251, 191, 36, 0.08)';
                        restartServerBtn.style.borderColor = 'rgba(251, 191, 36, 0.3)';
                        restartServerBtn.style.color = '#fbbf24';
                        restartServerBtn.disabled = false;
                        restartServerBtn.style.opacity = '1';
                    }, 2000);
                }
            } else {
                // Fallback: just reconnect websocket
                restartServerBtn.textContent = '🔄 Reconnecting...';
                setTimeout(() => {
                    connectWebSocket();
                    restartServerBtn.textContent = originalText;
                    restartServerBtn.disabled = false;
                    restartServerBtn.style.opacity = '1';
                }, 2000);
            }
        });
    }
}

/**
 * Initialize clear logs button
 */
function initClearButton() {
    const clearBtn = document.getElementById('clearBtn');

    if (clearBtn) {
        clearBtn.addEventListener('click', function() {
            if (confirm('Are you sure you want to clear all logs?')) {
                allLogs = [];
                updateLogCount();
                renderLogs();

                const originalText = clearBtn.textContent;
                clearBtn.textContent = '✓ Cleared!';
                clearBtn.style.background = 'rgba(16, 185, 129, 0.3)';
                clearBtn.style.borderColor = '#10b981';
                clearBtn.style.color = '#51cf66';

                setTimeout(() => {
                    clearBtn.textContent = originalText;
                    clearBtn.style.background = 'rgba(239, 68, 68, 0.08)';
                    clearBtn.style.borderColor = 'rgba(239, 68, 68, 0.3)';
                    clearBtn.style.color = '#ff6b6b';
                }, 1500);
            }
        });
    }
}

/**
 * Initialize pause/resume button with smart buffer management
 */
function initPauseButton() {
    const pauseBtn = document.getElementById('pauseBtn');
    const jumpToLiveBtn = document.getElementById('jumpToLiveBtn');

    // "Jump to Live" button - Shows current logs while staying paused (Kibana pattern)
    if (jumpToLiveBtn) {
        jumpToLiveBtn.addEventListener('click', function() {
            // Render latest logs without resuming pause
            renderLogs();
            logsContainer.scrollTop = logsContainer.scrollHeight;

            // Visual feedback
            const originalText = jumpToLiveBtn.textContent;
            jumpToLiveBtn.textContent = '✓ Jumped to Live!';
            jumpToLiveBtn.style.background = 'rgba(16, 185, 129, 0.3)';

            setTimeout(() => {
                jumpToLiveBtn.textContent = originalText;
                jumpToLiveBtn.style.background = 'rgba(16, 185, 129, 0.15)';
            }, 1000);
        });
    }

    if (pauseBtn) {
        pauseBtn.addEventListener('click', function() {
            isPaused = !isPaused;

            if (isPaused) {
                // PAUSED: Track current log count
                pausedAtLogCount = allLogs.length;

                pauseBtn.textContent = '⏸️ Paused';
                pauseBtn.style.background = 'rgba(239, 68, 68, 0.08)';
                pauseBtn.style.borderColor = 'rgba(239, 68, 68, 0.3)';
                pauseBtn.style.color = '#ff6b6b';

                // Show "Jump to Live" button
                if (jumpToLiveBtn) {
                    jumpToLiveBtn.style.display = 'block';
                }

                // Start updating counter every 500ms while paused
                pauseCounterInterval = setInterval(() => {
                    const queuedCount = allLogs.length - pausedAtLogCount;
                    if (queuedCount > 0) {
                        pauseBtn.textContent = `⏸️ Paused (${queuedCount.toLocaleString()})`;
                    }
                }, 500);
            } else {
                // RESUME: Calculate queued logs
                clearInterval(pauseCounterInterval);

                // Hide "Jump to Live" button
                if (jumpToLiveBtn) {
                    jumpToLiveBtn.style.display = 'none';
                }

                const queuedCount = allLogs.length - pausedAtLogCount;

                // TIERED STRATEGY based on queued log count
                if (queuedCount < 1000) {
                    // TIER 1: Small buffer - render all queued logs (fast & responsive)
                    pauseBtn.textContent = '▶️ Live';
                    pauseBtn.style.background = 'rgba(139, 92, 246, 0.08)';
                    pauseBtn.style.borderColor = 'rgba(139, 92, 246, 0.3)';
                    pauseBtn.style.color = '#a78bfa';

                    renderLogs();
                    if (autoScroll) {
                        logsContainer.scrollTop = logsContainer.scrollHeight;
                    }
                } else if (queuedCount < 10000) {
                    // TIER 2: Medium buffer - give user choice
                    const jumpToLive = confirm(
                        `${queuedCount.toLocaleString()} logs queued while paused.\n\n` +
                        `• Click OK to "Jump to Live" (skip queued logs, show current stream)\n` +
                        `• Click Cancel to "Show All" (render all ${queuedCount.toLocaleString()} queued logs - may take a moment)`
                    );

                    pauseBtn.textContent = '▶️ Live';
                    pauseBtn.style.background = 'rgba(139, 92, 246, 0.08)';
                    pauseBtn.style.borderColor = 'rgba(139, 92, 246, 0.3)';
                    pauseBtn.style.color = '#a78bfa';

                    if (jumpToLive) {
                        // Jump to Live: Just re-render current filtered view
                        renderLogs();
                        if (autoScroll) {
                            logsContainer.scrollTop = logsContainer.scrollHeight;
                        }
                    } else {
                        // Show All: Render everything
                        pauseBtn.textContent = '⏳ Rendering...';
                        setTimeout(() => {
                            renderLogs();
                            if (autoScroll) {
                                logsContainer.scrollTop = logsContainer.scrollHeight;
                            }
                            pauseBtn.textContent = '▶️ Live';
                        }, 50);
                    }
                } else {
                    // TIER 3: Large buffer - auto-discard oldest logs (prevent UI freeze)
                    const discardedCount = queuedCount - MAX_BUFFER_SIZE;

                    // Keep only most recent MAX_BUFFER_SIZE logs
                    if (allLogs.length > MAX_BUFFER_SIZE) {
                        allLogs = allLogs.slice(-MAX_BUFFER_SIZE); // Keep last MAX_BUFFER_SIZE logs
                    }

                    alert(
                        `⚠️ Buffer limit reached!\n\n` +
                        `${discardedCount.toLocaleString()} older logs were discarded to prevent performance issues.\n` +
                        `Showing most recent ${MAX_BUFFER_SIZE.toLocaleString()} logs.\n\n` +
                        `💡 Tip: Use filters to reduce log volume, or export logs before resuming.`
                    );

                    pauseBtn.textContent = '▶️ Live';
                    pauseBtn.style.background = 'rgba(139, 92, 246, 0.08)';
                    pauseBtn.style.borderColor = 'rgba(139, 92, 246, 0.3)';
                    pauseBtn.style.color = '#a78bfa';

                    updateLogCount();
                    renderLogs();
                    if (autoScroll) {
                        logsContainer.scrollTop = logsContainer.scrollHeight;
                    }
                }

                // Reset pause counter
                pausedAtLogCount = 0;
            }
        });
    }
}

/**
 * Initialize auto-scroll toggle button
 */
function initAutoScrollButton() {
    const autoScrollBtn = document.getElementById('autoScrollBtn');

    if (autoScrollBtn) {
        autoScrollBtn.addEventListener('click', function() {
            autoScroll = !autoScroll;

            if (autoScroll) {
                autoScrollBtn.textContent = '⬇️ Auto-scroll';
                autoScrollBtn.style.background = 'rgba(16, 185, 129, 0.08)';
                autoScrollBtn.style.borderColor = 'rgba(16, 185, 129, 0.3)';
                autoScrollBtn.style.color = '#51cf66';
                logsContainer.scrollTop = logsContainer.scrollHeight;
            } else {
                autoScrollBtn.textContent = '⏸️ Paused';
                autoScrollBtn.style.background = 'rgba(245, 158, 11, 0.08)';
                autoScrollBtn.style.borderColor = 'rgba(245, 158, 11, 0.3)';
                autoScrollBtn.style.color = '#ffa94d';
            }
        });
    }
}

/**
 * Initialize scroll control button (scroll to top)
 */
function initScrollControlButton() {
    const scrollControlBtn = document.getElementById('scrollControlBtn');
    const scrollIcon = scrollControlBtn.querySelector('.scroll-icon');
    const scrollLabel = scrollControlBtn.querySelector('.scroll-label');

    function updateScrollButton() {
        const scrollTop = logsContainer.scrollTop;
        const scrollHeight = logsContainer.scrollHeight;
        const clientHeight = logsContainer.clientHeight;
        const isNearBottom = scrollTop + clientHeight >= scrollHeight - 100;

        if (isNearBottom) {
            // Near bottom - hide button
            scrollControlBtn.classList.remove('show');
            return;
        }

        // Show button when scrolled away from bottom
        scrollControlBtn.classList.add('show');

        if (autoScroll) {
            // Auto-scroll ON: Show GREEN button to go to TOP (opposite direction!)
            scrollControlBtn.classList.add('auto-mode');
            scrollIcon.textContent = '↑';
            scrollLabel.textContent = 'Top';
            scrollControlBtn.title = 'Scroll to top (auto-scroll will continue at bottom)';
        } else {
            // Auto-scroll OFF: Show PURPLE button to go to TOP
            scrollControlBtn.classList.remove('auto-mode');
            scrollIcon.textContent = '↑';
            scrollLabel.textContent = 'Top';
            scrollControlBtn.title = 'Scroll to top';
        }
    }

    // Update button state on scroll
    logsContainer.addEventListener('scroll', updateScrollButton);

    // Click handler - Scroll to top AND disable autoscroll
    if (scrollControlBtn) {
        scrollControlBtn.addEventListener('click', function() {
            // Disable autoscroll so user can examine top logs without being pulled to bottom
            if (autoScroll) {
                autoScroll = false;

                // Update auto-scroll button appearance
                const autoScrollBtn = document.getElementById('autoScrollBtn');
                if (autoScrollBtn) {
                    autoScrollBtn.textContent = '⏸️ Paused';
                    autoScrollBtn.style.background = 'rgba(245, 158, 11, 0.08)';
                    autoScrollBtn.style.borderColor = 'rgba(245, 158, 11, 0.3)';
                    autoScrollBtn.style.color = '#ffa94d';
                }
            }

            // Scroll to top
            logsContainer.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
}

/**
 * Initialize advanced dropdown menu
 */
function initAdvancedDropdown() {
    const advancedTrigger = document.getElementById('advancedTrigger');
    const advancedMenu = document.getElementById('advancedMenu');
    const activeBadge = document.getElementById('activeBadge');

    if (advancedTrigger) {
        advancedTrigger.addEventListener('click', function(e) {
            e.stopPropagation();
            advancedMenu.classList.toggle('show');
            advancedTrigger.classList.toggle('open');
        });
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        if (advancedMenu && !advancedMenu.contains(e.target) && e.target !== advancedTrigger) {
            advancedMenu.classList.remove('show');
            advancedTrigger.classList.remove('open');
        }
    });
}

/**
 * Initialize advanced filter toggles (checkboxes)
 */
function initToggleFilters() {
    const toggleCheckboxes = document.querySelectorAll('.menu-item input[type="checkbox"]');
    const activeBadge = document.getElementById('activeBadge');

    function updateBadge() {
        const activeCount = Object.values(filterToggles).filter(v => v === true).length;
        if (activeCount > 0) {
            activeBadge.textContent = activeCount;
            activeBadge.style.display = 'block';
        } else {
            activeBadge.style.display = 'none';
        }
    }

    toggleCheckboxes.forEach(checkbox => {
        const toggleType = checkbox.getAttribute('data-toggle');

        checkbox.addEventListener('change', function() {
            // Toggle the filter state
            filterToggles[toggleType] = checkbox.checked;

            // Re-render logs with new filter
            renderLogs();

            // Update badge count
            updateBadge();

            // Save preferences to localStorage
            localStorage.setItem('swifmetro-toggles', JSON.stringify(filterToggles));
        });
    });

    // Load saved preferences
    const savedToggles = localStorage.getItem('swifmetro-toggles');
    if (savedToggles) {
        try {
            const parsed = JSON.parse(savedToggles);
            Object.assign(filterToggles, parsed);

            // Update checkbox states
            toggleCheckboxes.forEach(checkbox => {
                const toggleType = checkbox.getAttribute('data-toggle');
                checkbox.checked = filterToggles[toggleType] || false;
            });

            updateBadge();
        } catch (e) {
            console.warn('Failed to load toggle preferences:', e);
        }
    }
}

/**
 * Initialize time range filter
 */
function initTimeRangeFilter() {
    const timePills = document.querySelectorAll('.time-pill');

    timePills.forEach(pill => {
        pill.addEventListener('click', function() {
            // Remove active class from all pills
            timePills.forEach(p => p.classList.remove('active'));

            // Add active class to clicked pill
            pill.classList.add('active');

            // Update time range
            timeRangeMinutes = pill.getAttribute('data-time');

            // Re-render logs
            renderLogs();

            // Save preference
            localStorage.setItem('swifmetro-time-range', timeRangeMinutes);
        });
    });

    // Load saved time range preference
    const savedTimeRange = localStorage.getItem('swifmetro-time-range');
    if (savedTimeRange) {
        timeRangeMinutes = savedTimeRange;
        timePills.forEach(pill => {
            if (pill.getAttribute('data-time') === savedTimeRange) {
                pill.classList.add('active');
            } else {
                pill.classList.remove('active');
            }
        });
    }
}

/**
 * Initialize keyboard shortcuts
 */
function initKeyboardShortcuts() {
    document.addEventListener('keydown', function(e) {
        // Cmd+K or Ctrl+K - Clear logs
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
            e.preventDefault();
            const clearBtn = document.getElementById('clearBtn');
            if (clearBtn) clearBtn.click();
        }

        // Cmd+E or Ctrl+E - Export logs
        if ((e.metaKey || e.ctrlKey) && e.key === 'e') {
            e.preventDefault();
            const exportBtn = document.getElementById('exportBtn');
            if (exportBtn) exportBtn.click();
        }

        // Cmd+F or Ctrl+F - Focus search
        if ((e.metaKey || e.ctrlKey) && e.key === 'f') {
            e.preventDefault();
            searchInput.focus();
        }

        // Cmd+C or Ctrl+C - Copy all (when not in input)
        if ((e.metaKey || e.ctrlKey) && e.key === 'c' && document.activeElement !== searchInput) {
            if (window.getSelection().toString() === '') {
                e.preventDefault();
                const copyBtn = document.getElementById('copyAllBtn');
                if (copyBtn) copyBtn.click();
            }
        }

        // Space - Toggle auto-scroll
        if (e.key === ' ' && document.activeElement !== searchInput) {
            e.preventDefault();
            const autoScrollBtn = document.getElementById('autoScrollBtn');
            if (autoScrollBtn) autoScrollBtn.click();
        }
    });
}

/**
 * Initialize all UI components
 */
function initUI() {
    initTheme();
    initCopyAllButton();
    initExportButton();
    initRestartButton();
    initClearButton();
    initPauseButton();
    initAutoScrollButton();
    initScrollControlButton();
    initAdvancedDropdown();
    initToggleFilters();
    initTimeRangeFilter();
    initKeyboardShortcuts();
}

// Initialize UI when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initUI);
} else {
    initUI();
}
