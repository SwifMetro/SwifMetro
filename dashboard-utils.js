/**
 * SwifMetro Dashboard - Utility Functions
 * Helper functions for log processing, categorization, and formatting
 */

/**
 * Categorizes a log message based on its content
 * @param {string} message - The log message to categorize
 * @returns {string} - Log type: 'error', 'warning', 'success', 'info', or 'default'
 */
function categorizeLog(message) {
    // Check for NSLog with error types
    if (message.includes('[NSLog]') && message.includes('type:"Error"')) {
        return 'error';
    }
    // Check for NSLog with fault types (critical errors)
    if (message.includes('[NSLog]') && message.includes('type:"Fault"')) {
        return 'error';
    }
    // Check for NSLog with info types
    if (message.includes('[NSLog]') && message.includes('type:"Info"')) {
        return 'info';
    }
    // Check for error symbols and keywords
    if (message.includes('❌') || message.includes('ERROR') || message.includes('error') || message.includes('💥')) {
        return 'error';
    }
    // Check for warning symbols and keywords
    if (message.includes('⚠️') || message.includes('WARNING') || message.includes('warning') || message.includes('[stderr]')) {
        return 'warning';
    }
    // Check for success symbols and keywords
    if (message.includes('✅') || message.includes('SUCCESS') || message.includes('success')) {
        return 'success';
    }
    // Check for info symbols and keywords
    if (message.includes('ℹ️') || message.includes('INFO') || message.includes('info') || message.includes('🐛')) {
        return 'info';
    }
    // NSLog and os_log are generally info unless categorized above
    if (message.includes('[NSLog]') || message.includes('[os_log]')) {
        return 'info';
    }
    return 'default';
}

/**
 * Extracts timestamp from a log message
 * @param {string} message - The log message
 * @returns {string} - Extracted timestamp or current time
 */
function extractTimestamp(message) {
    const match = message.match(/\[([\d:]+)\]/);
    return match ? match[1] : new Date().toLocaleTimeString();
}

/**
 * Gets an appropriate icon for a log type
 * @param {string} type - Log type
 * @param {string} message - Log message (for specific content checks)
 * @returns {string} - Emoji icon
 */
function getLogIcon(type, message) {
    switch(type) {
        case 'error': return '❌';
        case 'warning': return '⚠️';
        case 'success': return '✅';
        case 'info': return 'ℹ️';
        default:
            // Show specific icons based on log content
            if (message && message.includes('[NSLog]')) return '📝';
            if (message && message.includes('[print]')) return '🖨️';
            if (message && message.includes('[os_log]')) return '📋';
            if (message && message.includes('[stderr]')) return '⚠️';
            return '📱';
    }
}

/**
 * Gets a badge element for a log type
 * @param {string} type - Log type
 * @returns {string} - HTML string for badge
 */
function getLogBadge(type) {
    switch(type) {
        case 'error': return '<span class="log-badge error">ERROR</span>';
        case 'warning': return '<span class="log-badge warning">WARN</span>';
        case 'success': return '<span class="log-badge success">SUCCESS</span>';
        case 'info': return '<span class="log-badge info">INFO</span>';
        default: return '';
    }
}

/**
 * Escapes HTML special characters
 * @param {string} text - Text to escape
 * @returns {string} - Escaped HTML
 */
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

/**
 * Escapes text for use in HTML attributes
 * @param {string} text - Text to escape
 * @returns {string} - Escaped text
 */
function escapeForAttribute(text) {
    return text
        .replace(/'/g, '&apos;')
        .replace(/"/g, '&quot;')
        .replace(/\\/g, '\\\\');
}

/**
 * Gets the next color from the device color palette
 * @returns {Object} - Object with color and updated index
 */
const colorPalette = [
    '#3B82F6', // Blue
    '#10B981', // Green
    '#F59E0B', // Orange
    '#EF4444', // Red
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#14B8A6', // Teal
    '#F97316', // Dark Orange
];

let colorIndex = 0;

function getNextDeviceColor() {
    const color = colorPalette[colorIndex % colorPalette.length];
    colorIndex++;
    return color;
}

function resetColorIndex() {
    colorIndex = 0;
}
