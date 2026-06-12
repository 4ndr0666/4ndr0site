// 4NDR0-Editor — Tri-Mode HTML/Markdown Workspace (v7)
// Fully cohesive with 4NDR0 branding and Electric-Glassmorphism

(function () {
  'use strict';

  const container = document.getElementById('mainContainer');
  if (!container) {
    console.error('4NDR0-Editor: #mainContainer not found');
    return;
  }

  // Build the three-pane layout
  container.innerHTML = `
    <div class="toolbar">
      <button id="prettyBtn">PRETTY</button>
      <button id="importHtml">IMPORT HTML</button>
      <button id="importDocx">IMPORT DOCX</button>
      <button id="exportHtml">EXPORT HTML</button>
      <button id="exportMarkdown">EXPORT MD</button>
      <button id="exportDocx">EXPORT DOCX</button>
      <button id="plainText">PLAIN TEXT</button>
      <button id="clearStorage">CLEAR AUTOSAVE</button>

      <div style="margin-left: auto; display: flex; gap: 8px; align-items: center;">
        <select id="headingStyle">
          <option value="atx">ATX Headings</option>
          <option value="setext">Setext Headings</option>
        </select>
        <select id="codeStyle">
          <option value="fenced">Fenced Code</option>
          <option value="indented">Indented Code</option>
        </select>
        <label><input type="checkbox" id="mdBreaks" checked> Hard Breaks</label>
        <label><input type="checkbox" id="linkify" checked> Auto Links</label>
      </div>
    </div>

    <div id="editorPanes" style="flex: 1; display: flex; min-height: 0;">
      <div id="paneWysiwyg" class="pane" style="flex: 1; min-width: 200px;">
        <div id="wysiwyg" style="height: 100%;"></div>
      </div>
      <div id="paneHtml" class="pane" style="flex: 1; min-width: 200px;">
        <textarea id="htmlEditor" style="display: none;"></textarea>
      </div>
      <div id="paneMarkdown" class="pane" style="flex: 1; min-width: 200px;">
        <textarea id="markdownEditor" style="display: none;"></textarea>
      </div>
    </div>
  `;

  // === State ===
  let state = {
    html: '<p><strong>Hello!</strong> Start editing…</p>',
    markdown: '**Hello!** Start editing…',
    mode: 'wysiwyg-html'
  };

  const saved = localStorage.getItem('4ndr0-editor');
  if (saved) {
    try {
      const parsed = JSON.parse(saved);
      state.html = parsed.html || state.html;
      state.markdown = parsed.markdown || state.markdown;
    } catch (e) {}
  }

  let syncLock = false;
  let cmHtml, cmMarkdown;
  let tinyReady = false;

  // === Helpers ===
  function saveState() {
    localStorage.setItem('4ndr0-editor', JSON.stringify({
      html: state.html,
      markdown: state.markdown
    }));
  }

  function sanitize(html) {
    return DOMPurify.sanitize(html, { ADD_ATTR: ['style'] });
  }

  function setStatus(msg) {
    // You can expand this later with a status bar if desired
    console.log('[4NDR0-Editor]', msg);
  }

  // === Turndown + Markdown-it Setup ===
  let turndownService = new TurndownService({
    headingStyle: 'atx',
    codeBlockStyle: 'fenced',
    emDelimiter: '*',
    strongDelimiter: '**'
  });
  turndownService.use(turndownPluginGfm.gfm);

  let md = window.markdownit({
    html: true,
    linkify: true,
    breaks: true
  });

  function updateConversionOptions() {
    turndownService.options.headingStyle = document.getElementById('headingStyle').value;
    turndownService.options.codeBlockStyle = document.getElementById('codeStyle').value;

    md = window.markdownit({
      html: true,
      linkify: document.getElementById('linkify').checked,
      breaks: document.getElementById('mdBreaks').checked
    });
  }

  // === Sync Functions ===
  function pushHtml(html) {
    if (syncLock) return;
    syncLock = true;

    const clean = sanitize(html);
    state.html = clean;
    state.markdown = turndownService.turndown(clean);

    if (cmHtml) cmHtml.setValue(clean);
    if (cmMarkdown) cmMarkdown.setValue(state.markdown);
    if (tinyReady) tinymce.get('wysiwyg')?.setContent(clean);

    saveState();
    syncLock = false;
  }

  function pushMarkdown(markdown) {
    if (syncLock) return;
    syncLock = true;

    state.markdown = markdown;
    state.html = sanitize(md.render(markdown));

    if (cmHtml) cmHtml.setValue(state.html);
    if (cmMarkdown) cmMarkdown.setValue(markdown);
    if (tinyReady) tinymce.get('wysiwyg')?.setContent(state.html);

    saveState();
    syncLock = false;
  }

  // === Initialize Editors ===
  function initTinyMCE() {
    tinymce.init({
      selector: '#wysiwyg',
      menubar: true,
      height: '100%',
      branding: false,
      plugins: 'lists table link image code paste wordcount',
      toolbar: 'undo redo | styles | bold italic underline forecolor | bullist numlist | alignleft aligncenter alignright | table link | removeformat | code',
      setup(editor) {
        editor.on('init', () => {
          tinyReady = true;
          editor.setContent(state.html);
        });
        editor.on('change input undo redo', () => {
          if (syncLock) return;
          pushHtml(editor.getContent());
        });
      }
    });
  }

  function initCodeMirror() {
    cmHtml = CodeMirror.fromTextArea(document.getElementById('htmlEditor'), {
      mode: 'text/html',
      lineNumbers: true,
      autoCloseTags: true,
      autoCloseBrackets: true,
      lineWrapping: true
    });

    cmMarkdown = CodeMirror.fromTextArea(document.getElementById('markdownEditor'), {
      mode: 'markdown',
      lineNumbers: true,
      lineWrapping: true
    });

    cmHtml.setValue(state.html);
    cmMarkdown.setValue(state.markdown);

    cmHtml.on('change', () => {
      if (syncLock) return;
      pushHtml(cmHtml.getValue());
    });

    cmMarkdown.on('change', () => {
      if (syncLock) return;
      pushMarkdown(cmMarkdown.getValue());
    });
  }

  function initSplit() {
    Split(['#paneWysiwyg', '#paneHtml', '#paneMarkdown'], {
      sizes: [33, 33, 34],
      gutterSize: 6,
      minSize: 180,
      snapOffset: 0
    });
  }

  // === Toolbar Actions ===
  function bindToolbar() {
    document.getElementById('prettyBtn').addEventListener('click', () => {
      const cleaned = sanitize(state.html);
      pushHtml(cleaned);
      setStatus('Pretty pass complete');
    });

    // Import
    document.getElementById('importHtml').addEventListener('click', () => {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = '.html,.htm,.txt';
      input.onchange = e => {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = ev => pushHtml(ev.target.result);
        reader.readAsText(file);
      };
      input.click();
    });

    document.getElementById('importDocx').addEventListener('click', () => {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = '.docx';
      input.onchange = e => {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = async ev => {
          const result = await window.mammoth.convertToHtml({ arrayBuffer: ev.target.result });
          pushHtml(result.value);
        };
        reader.readAsArrayBuffer(file);
      };
      input.click();
    });

    // Export
    document.getElementById('exportHtml').addEventListener('click', () => {
      const blob = new Blob([state.html], { type: 'text/html' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'document.html';
      a.click();
    });

    document.getElementById('exportMarkdown').addEventListener('click', () => {
      const blob = new Blob([state.markdown], { type: 'text/markdown' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'document.md';
      a.click();
    });

    document.getElementById('exportDocx').addEventListener('click', () => {
      const blob = window.htmlDocx.asBlob(state.html);
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'document.docx';
      a.click();
    });

    document.getElementById('plainText').addEventListener('click', () => {
      const text = DOMPurify.sanitize(state.html, { ALLOWED_TAGS: [] });
      const blob = new Blob([text], { type: 'text/plain' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = 'document.txt';
      a.click();
    });

    document.getElementById('clearStorage').addEventListener('click', () => {
      localStorage.removeItem('4ndr0-editor');
      setStatus('Autosave cleared');
    });

    // Conversion option listeners
    ['headingStyle', 'codeStyle', 'mdBreaks', 'linkify'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.addEventListener('change', updateConversionOptions);
    });
  }

  // === Initialization ===
  function init() {
    initTinyMCE();
    initCodeMirror();
    initSplit();
    bindToolbar();
    updateConversionOptions();

    // Initial sync
    setTimeout(() => {
      if (cmHtml) cmHtml.setValue(state.html);
      if (cmMarkdown) cmMarkdown.setValue(state.markdown);
    }, 300);

    setStatus('4NDR0-Editor ready');
  }

  init();
})();
