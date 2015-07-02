module.exports = AtomInnerspace =
    timeout: null,
    re: /([^\s]*)(\s*)/g

    activate: (state) ->
        atom.workspace.observeTextEditors (editor) ->
            AtomInnerspace.showHiddenSpaces(editor, false)

            # Update on change.
            editor.onDidChange ->
                # Update the cursor line.
                AtomInnerspace.update(editor, 10, true)

            editor.onDidStopChanging ->
                # Update every line.
                AtomInnerspace.update(editor, 100, false)

            # Update on scroll.
            editor.onDidChangeScrollTop ->
                AtomInnerspace.update(editor, 100)

    update: (editor, delay, cursorLineOnly) ->
        callback = ->
            AtomInnerspace.showHiddenSpaces(editor, cursorLineOnly)

        clearTimeout(@timeout)
        @timeout = setTimeout(callback, delay)

    showHiddenSpaces: (editor, cursorLineOnly) ->
        v = atom.views.getView(editor);

        parent = null

        if cursorLineOnly == true
            parent = v.shadowRoot.querySelector('.line.cursor-line')

        if !parent
            parent = v.shadowRoot.querySelector('.lines')

        # Get all text nodes inside the editor.
        AtomInnerspace.convertSpaces(textNode) for textNode in @getTextNodes(parent)

    convertSpaces: (textNode) ->
        if textNode.parentNode.className.indexOf('indent-guide') >= 0 or textNode.parentNode.className.indexOf('line') >= 0
            # Ignore indent guide text nodes.
            return

        joinToNode = (res) ->
            # Non space character.
            if res[1].length > 0
                newTextNode = document.createTextNode(res[1])
                textNode.parentNode.insertBefore(newTextNode, textNode)

            # White space.
            if res[2].length > 0
                # Create a span with the invisible character 'dots'.
                spacer = document.createElement('span')
                spacer.innerHTML = '·'.repeat(res[2].length)
                textNode.parentNode.insertBefore(spacer, textNode)

                # Use the invisible-character class for styling.
                spacer.classList.add('invisible-character')


        @re.lastIndex = 0
        joinToNode(res) while (res = @re.exec(textNode.data)) and res and res[0].length > 0

        # Remove the original text node.
        textNode.parentNode.removeChild(textNode)

    getTextNodes: (parent) ->
        walk  = document.createTreeWalker(parent, NodeFilter.SHOW_TEXT)
        nodes = while node = walk.nextNode()
            node