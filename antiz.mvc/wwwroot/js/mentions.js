

var MentionContextPopup = function(el) {

    
    let $textarea = $(el);
    let fetchUsersUrl = bitMin.viewData.fetchUsersUrl;

    let mentionQuery = "";
    let mentionPosition = { top: 0, left: 0 };

    let $contextMenu = null;

    $textarea.on("input", function () {
        autoResizeTextarea(this);

        const text = $textarea.val();
        const cursorPos = this.selectionStart;

        // Detect `@` mention
        const textBeforeCursor = text.substring(0, cursorPos);
        const lastWord = textBeforeCursor.split(/\s+/).pop();

        if (lastWord.startsWith("@") && lastWord.length > 1) {
            mentionQuery = lastWord.substring(1); // Get text after `@`
            const textareaOffset = $textarea.offset();
            const caretPos = getCaretCoordinates(this, cursorPos);

            mentionPosition = {
                top: caretPos.top,
                left: caretPos.left,
            };

            fetchSuggestions(mentionQuery);
        } else {
            hideContextMenu();
        }
    });

    let autoResizeTextarea = function (textarea) {
        textarea.style.height = "auto"; // Reset height
        textarea.style.height = textarea.scrollHeight + "px"; // Adjust to fit content
    };

    let fetchSuggestions = function (id) {

        $.ajax({
            url: fetchUsersUrl,
            type: "GET",
            data: { id },
            success: function (response) {
                if (Array.isArray(response) && response.length > 0) {
                    showContextMenu(response, mentionPosition);
                } else {
                    hideContextMenu();
                }
            },
            error: function () {
                console.error("Failed to fetch suggestions.");
                hideContextMenu();
            },
        });
    };

    let showContextMenu = function (suggestions, position) {

        $contextMenu = $textarea.siblings(".mention-context-menu");

        // Create a unique context menu if it doesn't exist
        if ($contextMenu.length === 0) {
            $contextMenu = $('<div class="mention-context-menu"></div>').appendTo($textarea.parent());
        }

        const tmpl = (user) => `
                <div class="row border-bottom border-secondary" data-username=${user.username}>
                    <div class="col-auto">
                        <img class="avatar-thumb" src="/backend/Photo/${user.avatarId}">
                    </div>
                    <div class="col-auto">
                        <b>${user.name || ""}</b><br>
                        @${user.username}
                    </div>
                </div>`

        $contextMenu.empty()
            .append(suggestions.map((user) => tmpl(user)).join(""))
            .css({ top: position.top, left: position.left, display: "block" });

        $contextMenu.find("div.row").on("click", function () {
            insertMention($(this).data('username'));
            hideContextMenu();
        });
    };

    let hideContextMenu = function () {
        $contextMenu?.hide();
    };

    let insertMention = function (user) {
        const text = $textarea.val();
        const cursorPos = $textarea[0].selectionStart;
        const textBeforeCursor = text.substring(0, cursorPos);
        const textAfterCursor = text.substring(cursorPos);
        const lastWord = textBeforeCursor.split(/\s+/).pop();

        const updatedText = textBeforeCursor.replace(new RegExp(`${lastWord}$`), `@${user} `) + textAfterCursor;
        $textarea.val(updatedText);

        // Move cursor to the end of the inserted mention
        const newCursorPos = textBeforeCursor.length - lastWord.length + user.length + 2;
        $textarea[0].setSelectionRange(newCursorPos, newCursorPos);
        $textarea.focus();
    };

    let getCaretCoordinates = function (element, cursorPos) {
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


const mentions = {
    menus: [],
    init: function () {
        $(".add-post-textarea").each(function (ix, el) {

            if (mentions.menus.includes(el)) return;

            el.mentions = new MentionContextPopup(el);
            mentions.menus.push(el);
        });
    }
};