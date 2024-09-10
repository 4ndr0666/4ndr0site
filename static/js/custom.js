function applyStylesheet() {
    var stylesheets = document.styleSheets;

    Array.from(stylesheets).forEach(function(sheet, index) {
        try {
            // Check for null href or same-origin stylesheet
            if (sheet.href === null || sheet.href.startsWith(window.location.origin)) {
                // Ensure cssRules exist and is not null
                if (typeof sheet.cssRules !== 'undefined' && sheet.cssRules !== null) {
                    for (var j = 0; j < sheet.cssRules.length; j++) {
                        var rule = sheet.cssRules[j];
                        console.log(rule.cssText);  // Debugging purposes
                    }
                } else {
                    console.warn(`Stylesheet at index ${index} does not have cssRules.`);
                }
            } else {
                console.warn(`Skipping cross-origin stylesheet at ${sheet.href}`);
            }
        } catch (e) {
            if (e.name === 'SecurityError') {
                console.warn(`Security error: Cannot access cssRules for stylesheet at index ${index} due to cross-origin restrictions.`);
            } else {
                console.error(`Error accessing cssRules for stylesheet at index ${index}:`, e);
            }
        }
    });
}

// Ensure this function runs after the DOM is fully loaded
document.addEventListener('DOMContentLoaded', applyStylesheet);
