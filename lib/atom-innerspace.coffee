module.exports = AtomInnerspace =
    activate: (state) ->
        atom.workspace.observeTextEditors (editor) ->
            AtomInnerspace.showHiddenSpaces(editor)
            timeout = null
            editor.onDidChange ->
                callback = ->
                    AtomInnerspace.showHiddenSpaces(editor)

                clearTimeout(timeout)
                timeout = setTimeout(callback, 10)

    showHiddenSpaces: (editor) ->
        v = atom.views.getView(editor);

        # Find all span tags inside each line.
        lines = v.shadowRoot.querySelectorAll('.lines .line span')
        AtomInnerspace.showHiddenSpace(span) for span in lines

    showHiddenSpace: (elem) ->
        # Need to convert the space after the element.
        if (elem.nextSibling and elem.nextSibling.nodeType == 3)
            textNode = elem.nextSibling
            r = ///^\s+$///
            m = textNode.data.match(r)

            if m != null
                # Create a span with the invisible character 'dots'.
                spacer = document.createElement('span')
                spacer.innerHTML = '·'.repeat(m[0].length)

                # Use the invisible-character class for styling.
                spacer.classList.add('invisible-character')

                # Insert the span before the text node and then remove the text node.
                textNode.parentNode.insertBefore(spacer, textNode)
                textNode.parentNode.removeChild(textNode)
