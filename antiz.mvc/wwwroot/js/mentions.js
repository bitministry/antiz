const MentionContextPopup = {
    init: function (options) {
        this.$textarea = $(options.textareaSelector);
        this.$contextMenu = $(options.contextMenuSelector);
        this.fetchUsersUrl = options.fetchUsersUrl;

        this.mentionQuery = "";
        this.mentionPosition = { top: 0, left: 0 };

        this.bindEvents();
    },

    bindEvents: function () {
        const self = this;

        this.$textarea.on("input", function () {
            self.autoResizeTextarea(this);  

            const text = self.$textarea.val();
            const cursorPos = this.selectionStart;

            // Detect `@` mention
            const textBeforeCursor = text.substring(0, cursorPos);
            const lastWord = textBeforeCursor.split(/\s+/).pop();

            if (lastWord.startsWith("@") && lastWord.length > 1 ) {
                self.mentionQuery = lastWord.substring(1); // Get text after `@`
                const textareaOffset = self.$textarea.offset();
                const caretPos = self.getCaretCoordinates(this, cursorPos);

                self.mentionPosition = {
                    top: caretPos.top,
                    left: caretPos.left,
                };

                self.fetchSuggestions(self.mentionQuery);
            } else {
                self.hideContextMenu();
            }
        });
    },

    autoResizeTextarea: function (textarea) {
        textarea.style.height = "auto"; // Reset height
        textarea.style.height = textarea.scrollHeight + "px"; // Adjust to fit content
    },

    fetchSuggestions: function (id) {
        const self = this;

        
        $.ajax({
            url: this.fetchUsersUrl,
            type: "GET",
            data: { id }, 
            success: function (response) {
                if (Array.isArray(response) && response.length > 0) {
                    self.showContextMenu(response, self.mentionPosition);
                } else {
                    self.hideContextMenu();
                }
            },
            error: function () {
                console.error("Failed to fetch suggestions.");
                self.hideContextMenu();
            },
        });
    },

    showContextMenu: function (suggestions, position) {
        const self = this;

        const tmpl = (user) => `
                <div class="row border-bottom border-secondary" data-username=${user.username}>
                    <div class="col-auto">
                        <img class="avatar-thumb" src="/backend/Photo/${user.avatarId}">
                    </div>
                    <div class="col-auto">
                        <b>${user.name||""}</b><br>
                        @${user.username}
                    </div>
                </div>`

        this.$contextMenu.empty()
            .append(suggestions.map((user) => tmpl(user)).join(""))
            .css({ top: position.top, left: position.left, display: "block" });

        this.$contextMenu.find("div.row").on("click", function () {
            self.insertMention($(this).data('username'));
            self.hideContextMenu();
        });
    },

    hideContextMenu: function () {
        this.$contextMenu.hide();
    },

    insertMention: function (user) {
        const text = this.$textarea.val();
        const cursorPos = this.$textarea[0].selectionStart;
        const textBeforeCursor = text.substring(0, cursorPos);
        const textAfterCursor = text.substring(cursorPos);
        const lastWord = textBeforeCursor.split(/\s+/).pop();

        const updatedText = textBeforeCursor.replace(new RegExp(`${lastWord}$`), `@${user} `) + textAfterCursor;
        this.$textarea.val(updatedText);

        // Move cursor to the end of the inserted mention
        const newCursorPos = textBeforeCursor.length - lastWord.length + user.length + 2;
        this.$textarea[0].setSelectionRange(newCursorPos, newCursorPos);
        this.$textarea.focus();
    },
    getCaretCoordinates: function (element, cursorPos) {
        const textBeforeCursor = element.value.substring(0, cursorPos);
        const lines = textBeforeCursor.split("\n"); // Split by newlines for multi-line support

        const lineHeight = parseInt(window.getComputedStyle(element).lineHeight) || 16; // Default line height fallback
        const charWidth = 8; // Average character width, adjust if needed

        // Calculate TOP using the line number and line height
        const top = lines.length * lineHeight - lineHeight; // Line number * line height

        // Create a temporary div for accurate LEFT calculation
        const div = document.createElement("div");
        const computed = window.getComputedStyle(element);

        // Copy styles to the div to mimic the textarea appearance
        for (let prop of computed) {
            div.style[prop] = computed[prop];
        }

        div.style.position = "absolute";
        div.style.visibility = "hidden";
        div.style.whiteSpace = "pre-wrap";
        div.style.wordWrap = "break-word";
        div.style.overflow = "hidden";

        // Set the div's content up to the caret position
        div.textContent = textBeforeCursor;

        // Add a marker for the caret
        const span = document.createElement("span");
        span.textContent = element.value[cursorPos] || "\u200b"; // Zero-width space for empty content
        div.appendChild(span);

        // Append the div to the body and calculate LEFT position
        document.body.appendChild(div);
        const spanOffset = span.getBoundingClientRect();
        const divOffset = div.getBoundingClientRect();
        const left = spanOffset.left - divOffset.left + element.scrollLeft;

        document.body.removeChild(div);

        return { top, left };
    }


};
