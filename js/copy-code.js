document.addEventListener('DOMContentLoaded', () => {
    const codeBlocks = document.querySelectorAll('div.highlighter-rouge');

    codeBlocks.forEach(codeBlock => {
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-code-btn';
        copyButton.innerHTML = '<i class="far fa-copy"></i>';
        copyButton.setAttribute('aria-label', 'Copy code to clipboard');

        codeBlock.appendChild(copyButton);

        copyButton.addEventListener('click', async () => {
            const code = codeBlock.querySelector('code');
            if (!code) return;

            try {
                const textToCopy = code.textContent;

                if (navigator.clipboard && window.isSecureContext) {
                    await navigator.clipboard.writeText(textToCopy);
                } else {
                    // Fallback for HTTP (non-secure) contexts
                    const textArea = document.createElement("textarea");
                    textArea.value = textToCopy;
                    textArea.style.position = "fixed";
                    textArea.style.left = "-999999px";
                    textArea.style.top = "-999999px";
                    document.body.appendChild(textArea);
                    textArea.focus();
                    textArea.select();

                    try {
                        document.execCommand('copy');
                    } catch (err) {
                        console.error('Fallback copy failed', err);
                    }
                    textArea.remove();
                }

                // Visual feedback: White checkmark icon (background will be green in CSS)
                copyButton.innerHTML = '<i class="fas fa-check" style="color: white;"></i>';
                copyButton.classList.add('copied');

                setTimeout(() => {
                    copyButton.innerHTML = '<i class="far fa-copy"></i>';
                    copyButton.classList.remove('copied');
                }, 2000);
            } catch (err) {
                console.error('Failed to copy text: ', err);
            }
        });
    });
});
