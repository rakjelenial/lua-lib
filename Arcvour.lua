<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap');
        body { font-family: 'Poppins', sans-serif; background-color: #1a092a; color: #e0e0e0; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; padding: 20px; box-sizing: border-box; }
        .container { display: flex; flex-direction: column; align-items: flex-start; padding: 24px; background: rgba(45, 24, 69, 0.7); border-radius: 12px; box-shadow: 0 4px 30px rgba(0, 0, 0, 0.2); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.1); max-width: 100%; width: 450px; }
        h1 { font-size: 1.5em; color: #f0e6ff; font-weight: 600; margin: 0 0 8px 0; display: flex; align-items: center; gap: 10px; }
        h1 span { font-size: 1.2em; color: #ff5577; }
        p { font-size: 0.9em; color: #c3b4d4; text-align: left; margin: 0 0 16px 0; }
        .code-container { width: 100%; background: #1e0a33; border-radius: 8px; padding: 12px; display: flex; align-items: center; justify-content: space-between; gap: 12px; box-sizing: border-box; }
        pre { margin: 0; flex-grow: 1; overflow-x: auto; }
        code { font-family: 'Courier New', Courier, monospace; font-size: 0.85em; color: #e0e0e0; white-space: pre-wrap; word-break: break-all; }
        #copy-button { background-color: #8b5cf6; color: white; border: none; padding: 8px 12px; border-radius: 6px; cursor: pointer; transition: background-color 0.2s ease; font-weight: 600; font-size: 0.9em; flex-shrink: 0; }
        #copy-button:hover { background-color: #7c3aed; }
    </style>
</head>
<body>
    <div class="container">
        <h1><span>🚫</span> Access Denied</h1>
        <p>Copy the code below to run it.</p>
        <div class="code-container">
            <pre><code id="copy-text-content">Loading...</code></pre>
            <button id="copy-button">Copy</button>
        </div>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const codeElement = document.getElementById('copy-text-content');
            const copyButton = document.getElementById('copy-button');
            const fullUrl = `https://${window.location.host}${window.location.pathname}`;
            const command = `loadstring(game:HttpGet("${fullUrl}"))()`;
            codeElement.textContent = command;
            copyButton.addEventListener('click', () => {
                navigator.clipboard.writeText(command).then(() => {
                    const originalText = copyButton.textContent;
                    copyButton.textContent = 'Copied!';
                    setTimeout(() => { copyButton.textContent = originalText; }, 2000);
                }).catch(err => console.error(err));
            });
        });
    </script>
</body>
</html>