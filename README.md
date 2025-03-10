# dotfiles

## Tampermonkey Overleaf

```js
// ==UserScript==
// @name         Overleaf Editor Custom VIM Keybindings (Code Mirror v6)
// @namespace    http://tampermonkey.net/
// @version      0.1.0
// @match        https://*.overleaf.com/project/*
// @grant        none
// @description  Configure a list of shortcuts for Vim-mode + user-defined :commands for toggling panels on Overleaf.
// @license MIT
// ==/UserScript==

/* globals jQuery, $, waitForKeyElements */

(function() {
    'use strict';
    // Interact with Writefull suggestion card.
    setTimeout(function(){
        var card;
        var editor = window.editor
        // Use ESC to dismiss the suggestion card
        $(document).keyup(function(event){
            switch(event.keyCode) {
                case 27:
                    esc()
                case 96:
                    esc()
            }
        });
        function esc(){
            card = $('.writefull-suggest-card');
            if(card.css("display")=='flex'){
                card.css("display",'none')
                // Restore the focus back to ACE editor
                editor.focus() // side-effect - a side box is drawn
            }
        };

        var KeycodeMap = {49:1, 50:2, 82:'r', 65:"a", 57:9, 48:0}; // scancode to literal keys
        $(document).keyup(function(event){
             card = $('.writefull-suggest-card');
                if(card.css("display")=='flex'){

                    // If 1 is pressed - accept the current suggestion
                    if (KeycodeMap[event.which] == 1){
                    console.log('1 is pressed -> accepting the current instance')
                    card.find('li.replacement').eq(0)[0].click();
                    editor.focus()
                    }

                    // If 2 is pressed - reject the current suggestion
                    if (KeycodeMap[event.which] == 2){
                    console.log('2 is pressed -> rejecting the current instance')
                    card.find('li.replacement').eq(1)[0].click();
                    editor.focus()
                    }

                    // If 9 is pressed - accept all
                    if (KeycodeMap[event.which] == 9){
                    console.log('9 is pressed -> accept all is pressed')
                    card.find('span.accept-all').click();
                    editor.focus()
                    }
                    // If 0 is pressed - reject all
                    if (KeycodeMap[event.which] == 0){
                    console.log('0 is pressed -> reject all is pressed')
                    card.find('span.reject-all').click();
                    editor.focus()
                    }

                    // TODO-1: use a and r to accept and reject.
                    // Note, refer to TDOD-2 as well - need to block a/r from CodeMirror's vim.
                }
        });
    },2000);

    window.addEventListener("UNSTABLE_editor:extensions", (event) => {
        const { CodeMirror, CodeMirrorVim, extensions } = event.detail;

        // Nullify keys used for choosing Writefull card (TODO-2)
        // Reference: https://stackoverflow.com/a/24490849
        // Task: condition the execution of key "a" and "r" based on whether the Writefull card is available.

        // Mappings in insert mode
        CodeMirrorVim.Vim.map("<c-]>", "<Esc>", "insert");
        CodeMirrorVim.Vim.map("jj", "<Esc>", "insert");
        CodeMirrorVim.Vim.map("jk", "<Esc>", "insert");
        CodeMirrorVim.Vim.map("kj", "<Esc>", "insert");

        // Remap in normal mode
        /// To navigate through wrapped long lines
        CodeMirrorVim.Vim.map("$", "g$", "normal");
        CodeMirrorVim.Vim.map("0", "g0", "normal");
        CodeMirrorVim.Vim.map("j", "gj", "normal");
        CodeMirrorVim.Vim.map("k", "gk", "normal");



        // User-defined commands
        CodeMirrorVim.Vim.defineEx("forward", undefined, buctton_click_forward_search); // ref: https://discuss.codemirror.net/t/vim-how-to-use-defineex/738/2
        CodeMirrorVim.Vim.defineEx("pdf", undefined, buctton_click_toggle_pdf_panel);
        CodeMirrorVim.Vim.defineEx("toc", undefined, buctton_click_toggle_TOC_left_panel);
        CodeMirrorVim.Vim.defineEx("only", undefined, buctton_click_toggle_editor_only);
        CodeMirrorVim.Vim.defineEx("o", undefined, buctton_click_toggle_editor_only); // :o as :o[nly]
        CodeMirrorVim.Vim.defineEx("re", undefined, writefull_rephrase); // :re[phrase]
        // Access the functions by defining them as actions first
        CodeMirrorVim.Vim.defineAction('jumpToPdf', buctton_click_forward_search);
        CodeMirrorVim.Vim.defineAction('only', buctton_click_toggle_editor_only);
        CodeMirrorVim.Vim.defineAction('toc', buctton_click_toggle_TOC_left_panel);
        CodeMirrorVim.Vim.defineAction('WritefullPrevious', writefull_previous_error);
        CodeMirrorVim.Vim.defineAction('WritefullNext', writefull_next_error);
        CodeMirrorVim.Vim.defineAction('WritefullRephrase', writefull_rephrase);

        // forward search: from VimTeX, <localleader>lv
        CodeMirrorVim.Vim.unmap(';');
        CodeMirrorVim.Vim.mapCommand(";lv", 'action', 'jumpToPdf');
        // Alternatively: use , as leader key
        CodeMirrorVim.Vim.unmap(',');
        CodeMirrorVim.Vim.mapCommand(",lv", 'action', 'jumpToPdf');
        // quick toggles
        CodeMirrorVim.Vim.mapCommand(",v", 'action', 'toc'); // <leader>v is from VimTeX
        CodeMirrorVim.Vim.mapCommand(",o", 'action', 'only'); // <leader>o for :o[nly]


        // Writefull shortcuts:
        // Jump to suggested typo using Writefull, with [s and ]s
        CodeMirrorVim.Vim.mapCommand("[s", 'action', 'WritefullPrevious');
        CodeMirrorVim.Vim.mapCommand("]s", 'action', 'WritefullNext');
        // Remap in visual mode - select a paragraph, press r to trigger the rephrase tool
        //CodeMirrorVim.Vim.mapCommand("r", "action", "WritefullRephrase", "visual");
        // Next step:
        // It would be nice to accept/reject the suggestion card using 1/a or 2/r, for example. Leave it for Writefull to build this for now (2023-03-02, 15:52)


        // 2. Restore Ctrl+C to copy into system clipboard - Currently, on Windows laptops, Ctrl+V in visual mode won't do anything. Overleaf should fix this ASAP, though.
        //CodeMirrorVim.Vim.defineAction('CopySelection', copy_in_visual_mode);
        //CodeMirrorVim.Vim.mapCommand("<c-c>", 'action', 'CopySelection');
    });
})();

// Collection of functions

// Clipboard access on Windows machines
function copy_in_visual_mode(cm) {
    document.execCommand('copy');
    alert("Triggered the copy function");
}

// Navigation releated functions
function buctton_click_forward_search(cm) {
    document.querySelector('.fa-arrow-right').click()
};
function buctton_click_toggle_pdf_panel(cm) {
    document.querySelector('a[class*="custom-toggler-east"]').click()
};
function buctton_click_toggle_TOC_left_panel(cm) {
    document.querySelector('a[tooltip*="the file-tree"]').click()
};
function buctton_click_toggle_editor_only(cm) {
    // This is just the sum of the two: toggle toc and toggle pdf
    document.querySelector('a[class*="custom-toggler-east"]').click()
    document.querySelector('a[tooltip*="the file-tree"]').click()
}

// Spell-checker specific functions
function writefull_next_error(cm) {
    document.querySelector('mwc-icon-button[id="writefull-next"]').click()
}
function writefull_previous_error(cm) {
    document.querySelector('mwc-icon-button[id="writefull-previous"]').click()
}
function writefull_rephrase(cm) {
    document.querySelector('mwc-icon-button[id="writefull-rephrase"]').click()
}
```
