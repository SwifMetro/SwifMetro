/**
 * SwifMetro Dashboard - Core Logic
 * WebSocket connection, log storage, filtering, and rendering
 */

// DOM Elements
const logsContainer = document.getElementById('logsContainer');
const searchInput = document.getElementById('searchInput');
const statusIndicator = document.getElementById('statusIndicator');
const statusText = document.getElementById('statusText');
const deviceCountEl = document.getElementById('deviceCount');
const logCountEl = document.getElementById('logCount');
const filteredCountEl = document.getElementById('filteredCount');

// Application State
let allLogs = [];
let currentFilter = 'all';
let searchQuery = '';
let isRegexMode = false; // Regex search toggle
let connectedDevices = new Map();

// Advanced Filter Toggles (OFF by default - opt-in for noisy logs)
let filterToggles = {
    fps: false,        // FPS monitor logs
    memory: false,     // Memory stats logs
    userdefaults: false, // UserDefaults changes
    debug: false       // Debug level logs
};

let timeRangeMinutes = 'all'; // 'all' or number of minutes
let selectedDevices = new Set();
let deviceColors = new Map();
let autoScroll = true;
let ws = null;
let isPaused = false; // Pause log rendering
let pausedAtLogCount = 0; // Track log count when pause started
const MAX_BUFFER_SIZE = 10000; // Maximum queued logs before discarding oldest

// Performance optimization: Track last render state to enable incremental updates
let lastRenderState = {
    filter: 'all',
    search: '',
    devices: new Set(),
    toggles: {...filterToggles},
    timeRange: 'all',
    logCount: 0
};

// WebSocket reconnection parameters
let reconnectAttempts = 0;
let maxReconnectAttempts = 10;
let reconnectInterval = 2000;

/**
 * Initialize WebSocket connection to log server
 */
function connectWebSocket() {
    ws = new WebSocket('ws://localhost:8081');

    ws.onopen = () => {
        console.log('WebSocket connected');
        statusText.textContent = 'Connected';
        statusIndicator.style.background = 'rgba(16, 185, 129, 0.1)';
        reconnectAttempts = 0;
        reconnectInterval = 2000;

        // Identify as dashboard
        ws.send(JSON.stringify({
            type: 'identify',
            clientType: 'dashboard'
        }));
    };

    ws.onclose = () => {
        console.log('WebSocket disconnected');
        statusText.textContent = 'Disconnected';
        statusIndicator.style.background = 'rgba(239, 68, 68, 0.1)';

        // Attempt reconnection
        if (reconnectAttempts < maxReconnectAttempts) {
            reconnectAttempts++;
            statusText.textContent = `Reconnecting... (${reconnectAttempts}/${maxReconnectAttempts})`;
            setTimeout(() => {
                connectWebSocket();
            }, reconnectInterval);
            reconnectInterval = Math.min(reconnectInterval * 1.5, 30000);
        } else {
            statusText.textContent = 'Connection Failed';
        }
    };

    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
    };

    ws.onmessage = (event) => {
        const message = event.data;

        // Parse JSON messages from new server protocol
        try {
            const parsed = JSON.parse(message);

            // Handle different message types
            if (parsed.type === 'welcome' || parsed.type === 'heartbeat') {
                return;
            }

            if (parsed.type === 'device_list') {
                handleDeviceList(parsed.devices);
                return;
            }

            if (parsed.type === 'log') {
                handleLogMessage(parsed);
                return;
            }

            if (parsed.type === 'network') {
                handleNetworkMessage(parsed);
                return;
            }

        } catch (e) {
            // Fallback for non-JSON messages (backward compatibility)
            if (message.includes('Welcome to SwifMetro') || message.includes('💓 Heartbeat')) {
                return;
            }

            handleLegacyMessage(message);
        }
    };
}

/**
 * Handle device list update from server
 */
function handleDeviceList(devices) {
    connectedDevices.clear();
    devices.forEach(device => {
        connectedDevices.set(device.deviceId, device);
        // Assign color if not already assigned
        if (!deviceColors.has(device.deviceId)) {
            deviceColors.set(device.deviceId, getNextDeviceColor());
        }
    });
    deviceCountEl.textContent = connectedDevices.size;
    updateDeviceFilters();
}

/**
 * Handle log message from server
 */
function handleLogMessage(parsed) {
    const logType = categorizeLog(parsed.message);
    const logEntry = {
        message: parsed.message,
        deviceId: parsed.deviceId,
        deviceName: parsed.deviceName,
        type: logType,
        timestamp: parsed.timestamp,
        id: Date.now() + Math.random()
    };

    // FIXED: Changed from unshift (prepend) to push (append)
    // This makes newest logs appear at BOTTOM
    allLogs.push(logEntry);

    // Electron app can handle WAY more! 500,000 logs (~100MB memory)
    if (allLogs.length > 500000) {
        allLogs.shift(); // Remove oldest log from beginning
    }

    updateLogCount();

    // Only render if not paused
    if (!isPaused) {
        renderLogs();

        // Auto-scroll to bottom if enabled
        if (autoScroll) {
            logsContainer.scrollTop = logsContainer.scrollHeight;
        }
    }
}

/**
 * Handle network message from server
 */
function handleNetworkMessage(parsed) {
    const logEntry = {
        message: `${parsed.method} ${parsed.url} - ${parsed.statusCode} (${parsed.duration}ms)`,
        deviceId: parsed.deviceId,
        deviceName: parsed.deviceName,
        type: parsed.statusCode >= 400 ? 'error' : parsed.statusCode >= 300 ? 'warning' : 'info',
        timestamp: parsed.timestamp,
        id: Date.now() + Math.random(),
        isNetwork: true
    };

    // FIXED: Changed from unshift (prepend) to push (append)
    allLogs.push(logEntry);

    // Electron app can handle WAY more! 500,000 logs (~100MB memory)
    if (allLogs.length > 500000) {
        allLogs.shift(); // Remove oldest log from beginning
    }

    updateLogCount();

    // Only render if not paused
    if (!isPaused) {
        renderLogs();

        if (autoScroll) {
            logsContainer.scrollTop = logsContainer.scrollHeight;
        }
    }
}

/**
 * Handle legacy (non-JSON) messages
 */
function handleLegacyMessage(message) {
    const logType = categorizeLog(message);
    const timestamp = extractTimestamp(message);

    const logEntry = {
        message: message,
        deviceId: 'unknown',
        deviceName: 'Unknown Device',
        type: logType,
        timestamp: timestamp,
        id: Date.now() + Math.random()
    };

    // FIXED: Changed from unshift (prepend) to push (append)
    allLogs.push(logEntry);

    if (allLogs.length > 1000) {
        allLogs.shift(); // Remove oldest log from beginning
    }

    updateLogCount();

    // Only render if not paused
    if (!isPaused) {
        renderLogs();

        if (autoScroll) {
            logsContainer.scrollTop = logsContainer.scrollHeight;
        }
    }
}

/**
 * Render logs to the DOM based on current filters
 */
function renderLogs() {
    const now = Date.now();
    const timeRangeCutoff = timeRangeMinutes === 'all' ? 0 : now - (timeRangeMinutes * 60 * 1000);

    // Check if filters have changed (requires full rebuild)
    const devicesChanged = lastRenderState.devices.size !== selectedDevices.size ||
                           [...lastRenderState.devices].some(d => !selectedDevices.has(d));
    const togglesChanged = JSON.stringify(lastRenderState.toggles) !== JSON.stringify(filterToggles);
    const filtersChanged = lastRenderState.filter !== currentFilter ||
                          lastRenderState.search !== searchQuery ||
                          lastRenderState.timeRange !== timeRangeMinutes ||
                          devicesChanged ||
                          togglesChanged;

    // Helper function to check if log matches filters
    function matchesFilters(log) {
        const matchesFilter = currentFilter === 'all' || log.type === currentFilter;

        // Enhanced search with regex support
        let matchesSearch = true;
        if (searchQuery !== '') {
            if (isRegexMode) {
                try {
                    const regex = new RegExp(searchQuery, 'i'); // Case-insensitive regex
                    matchesSearch = regex.test(log.message);
                } catch (e) {
                    // Invalid regex - fall back to literal search
                    matchesSearch = log.message.toLowerCase().includes(searchQuery.toLowerCase());
                }
            } else {
                matchesSearch = log.message.toLowerCase().includes(searchQuery.toLowerCase());
            }
        }

        const matchesDevice = selectedDevices.size === 0 || selectedDevices.has(log.deviceId);
        const logTime = log.id;
        const matchesTimeRange = timeRangeMinutes === 'all' || logTime >= timeRangeCutoff;
        const message = log.message.toLowerCase();

        if (!filterToggles.fps && message.includes('[fps]')) return false;
        if (!filterToggles.memory && message.includes('[memory stats]')) return false;
        if (!filterToggles.userdefaults && message.includes('[userdefaults]')) return false;
        if (!filterToggles.debug && (message.includes('[console.debug]') || message.includes('🐛'))) return false;

        return matchesFilter && matchesSearch && matchesDevice && matchesTimeRange;
    }

    // Helper function to create log HTML
    function createLogHTML(log) {
        const icon = log.isNetwork ? '🌐' : getLogIcon(log.type, log.message);
        const badge = getLogBadge(log.type);
        const deviceColor = deviceColors.get(log.deviceId) || '#667eea';
        const deviceLabel = log.deviceName && log.deviceName !== 'Unknown Device'
            ? `<span class="device-label" style="color: ${deviceColor}; font-weight: 600;">[${log.deviceName}]</span> `
            : '';

        let cleanMessage = log.message
            .replace(/^\[\d+:\d+:\d+\]\s*📱\s*/, '')
            .replace(/^\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\]\s*/, '');

        return `
            <div class="log-entry ${log.type}" style="border-left: 3px solid ${deviceColor};" data-log-id="${log.id}">
                <span class="log-time">${log.timestamp}</span>
                <span class="log-icon">${icon}</span>
                <span class="log-message">${deviceLabel}${badge}${escapeHtml(cleanMessage)}</span>
                <button class="copy-btn" onclick="copyLog('${escapeForAttribute(cleanMessage)}', this)">📋</button>
            </div>
        `;
    }

    // OPTIMIZATION: If only new logs added and filters unchanged, do incremental update
    if (!filtersChanged && allLogs.length > lastRenderState.logCount) {
        const newLogs = allLogs.slice(lastRenderState.logCount); // Get logs from end (newest)
        const filteredNewLogs = newLogs.filter(matchesFilters);

        if (filteredNewLogs.length > 0) {
            const fragment = document.createDocumentFragment();
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = filteredNewLogs.map(createLogHTML).join('');

            while (tempDiv.firstChild) {
                fragment.appendChild(tempDiv.firstChild);
            }

            // FIXED: Changed from insertBefore to appendChild
            // This appends new logs to the bottom
            logsContainer.appendChild(fragment);

            // Update filtered count
            const currentFiltered = parseInt(filteredCountEl.textContent) || 0;
            filteredCountEl.textContent = currentFiltered + filteredNewLogs.length;
        }

        // Update last render state
        lastRenderState.logCount = allLogs.length;
        return;
    }

    // FULL REBUILD: Filters changed or first render
    const filteredLogs = allLogs.filter(matchesFilters);
    filteredCountEl.textContent = filteredLogs.length;

    if (filteredLogs.length === 0 && allLogs.length === 0) {
        logsContainer.innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">📱</div>
                <p>Waiting for logs from your iOS device...</p>
            </div>
        `;
        lastRenderState.logCount = 0;
        return;
    }

    if (filteredLogs.length === 0) {
        logsContainer.innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">🔍</div>
                <p>No logs match your filters</p>
            </div>
        `;
        lastRenderState.logCount = allLogs.length;
        return;
    }

    // Render all filtered logs
    logsContainer.innerHTML = filteredLogs.map(createLogHTML).join('');

    // Update last render state
    lastRenderState = {
        filter: currentFilter,
        search: searchQuery,
        devices: new Set(selectedDevices),
        toggles: {...filterToggles},
        timeRange: timeRangeMinutes,
        logCount: allLogs.length
    };
}

/**
 * Update device filter pills in the toolbar
 */
function updateDeviceFilters() {
    const deviceFilterPills = document.getElementById('deviceFilterPills');

    if (connectedDevices.size === 0) {
        deviceFilterPills.innerHTML = '';
        return;
    }

    deviceFilterPills.innerHTML = Array.from(connectedDevices.values()).map(device => {
        const isSelected = selectedDevices.has(device.deviceId);
        const activeClass = isSelected ? 'active' : '';
        const deviceColor = deviceColors.get(device.deviceId) || '#667eea';
        const borderStyle = isSelected ? `border: 2px solid ${deviceColor}; background: ${deviceColor}22;` : `border: 1px solid ${deviceColor}44;`;
        return `<button class="pill ${activeClass}" style="${borderStyle} color: ${isSelected ? '#fff' : deviceColor};" data-device-id="${device.deviceId}" onclick="toggleDeviceFilter('${device.deviceId}')">${device.deviceName}</button>`;
    }).join('');
}

/**
 * Toggle device filter selection
 */
function toggleDeviceFilter(deviceId) {
    if (selectedDevices.has(deviceId)) {
        selectedDevices.delete(deviceId);
    } else {
        selectedDevices.add(deviceId);
    }
    updateDeviceFilters();
    renderLogs();
}

/**
 * Update log count display
 */
function updateLogCount() {
    const count = allLogs.length;
    logCountEl.textContent = count.toLocaleString(); // Format with commas

    // Add warning if approaching limit (Electron can handle 500k!)
    if (count > 450000) {
        logCountEl.style.color = '#fbbf24'; // Yellow warning
        logCountEl.title = `Approaching 500,000 log limit (${count.toLocaleString()}/500,000)`;
    } else if (count > 490000) {
        logCountEl.style.color = '#ef4444'; // Red warning
        logCountEl.title = `Near maximum! Oldest logs will be removed soon (${count.toLocaleString()}/500,000)`;
    } else {
        logCountEl.style.color = ''; // Reset color
        logCountEl.title = `Total logs captured (limit: 500,000)`;
    }
}

/**
 * Copy a single log line to clipboard
 */
function copyLog(message, btn) {
    const decodedMessage = message
        .replace(/&apos;/g, "'")
        .replace(/&quot;/g, '"')
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>');

    navigator.clipboard.writeText(decodedMessage).then(() => {
        btn.classList.add('copied');
        btn.textContent = '✓';

        setTimeout(() => {
            btn.classList.remove('copied');
            btn.textContent = '📋';
        }, 1000);
    });
}

// Initialize WebSocket connection on load
connectWebSocket();

// Search input listener
searchInput.addEventListener('input', (e) => {
    searchQuery = e.target.value;
    renderLogs();
});

// Regex toggle listener
const regexToggle = document.getElementById('regexToggle');
if (regexToggle) {
    regexToggle.addEventListener('change', (e) => {
        isRegexMode = e.target.checked;
        renderLogs(); // Re-render with new search mode
    });
}

// Filter pills listener
document.querySelectorAll('.pill[data-filter]').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.pill[data-filter]').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentFilter = btn.dataset.filter;
        renderLogs();
    });
});
