/**
 * 4NDR0666OS :: NEURAL_LINK_ENGINE v5.0.0-Ψ
 * Manages transition between CLI_TERMINAL and MATRIX_GUI environments.
 */

// OS Glyphs for Mode Toggle
const ICONS = {
  // GUI_GLYPH (Replaces Sun/Matrix Mode)
  gui: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16"><path d="M1 4a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1zm5 0a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1zm5 0a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1zM1 9a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1zm5 0a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1zm5 0a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v2a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1z"/></svg>',
  // CLI_GLYPH (Replaces Moon/Terminal Mode)
  cli: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 16 16"><path d="M0 4a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm2.5 1a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h2a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5zm0 3a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1zm0 2a.5.5 0 0 0 0 1h1a.5.5 0 0 0 0-1zm6-4a.5.5 0 0 1 .5-.5h5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1-.5-.5m0 2a.5.5 0 0 1 .5-.5h2a.5.5 0 0 1 0 1h-2a.5.5 0 0 1-.5-.5"/></svg>',
};

/**
 * Determine the current environment state.
 * Priority: LocalCache > DOM_Attribute > System_Hardware_Preference
 */
const getOSMode = () => {
  const savedMode = localStorage.getItem('4ndr0_mode');
  if (savedMode) return savedMode;
  
  const currentAttr = document.documentElement.getAttribute('data-bs-theme');
  if (currentAttr) return currentAttr;

  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
};

/**
 * Update the HUD toggle icon to reflect the transition-ready state.
 */
const updateModeIcon = () => {
  const button = document.querySelector('#theme-toggle');
  if (!button) return;
  const isDark = document.documentElement.getAttribute('data-bs-theme') === 'dark';
  // If we are dark (Matrix), show the CLI icon to switch back, and vice-versa
  button.innerHTML = isDark ? ICONS.cli : ICONS.gui;
};

/**
 * Sync the Utterances data-stream with the current CORTEX mode.
 */
const syncUtterancesMode = (mode) => {
  const frame = document.querySelector('.utterances-frame');
  if (!frame) return;
  frame.contentWindow.postMessage(
    { type: 'set-theme', theme: mode === 'dark' ? 'github-dark' : 'github-light' },
    'https://utteranc.es'
  );
};

/**
 * Execute Atomic Transition between CLI and GUI.
 */
window.toggleTheme = () => {
  const currentMode = document.documentElement.getAttribute('data-bs-theme') || getOSMode();
  const nextMode = currentMode === 'light' ? 'dark' : 'light';
  
  localStorage.setItem('4ndr0_mode', nextMode);
  document.documentElement.setAttribute('data-bs-theme', nextMode);
  
  console.log(`[CORTEX] Transitioning to operational_mode: ${nextMode.toUpperCase()}`);
  
  updateModeIcon();
  syncUtterancesMode(nextMode);
};

/**
 * IMMEDIATE_EXECUTION: Lock theme before asset render to prevent hardware flicker.
 */
(function() {
  document.documentElement.setAttribute('data-bs-theme', getOSMode());
})();

/**
 * POST_BOOT: Initialize observers and HUD elements.
 */
document.addEventListener('DOMContentLoaded', () => {
  const currentMode = getOSMode();
  document.documentElement.setAttribute('data-bs-theme', currentMode);
  updateModeIcon();

  // Observer for lazy-loaded Utterances frames
  const utterancesObserver = new MutationObserver(() => {
    const frame = document.querySelector('.utterances-frame');
    if (!frame) return;
    utterancesObserver.disconnect();
    
    frame.addEventListener('load', () => {
      console.log('[CORTEX] Utterances uplink synchronized.');
      syncUtterancesMode(getOSMode());
    }, { once: true });
  });

  const commentsNode = document.getElementById('comments');
  if (commentsNode) {
    utterancesObserver.observe(commentsNode, { childList: true, subtree: true });
  }
});
