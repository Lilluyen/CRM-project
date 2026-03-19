<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Email</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 20px auto;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background-color: #4285f4;
            color: white;
            padding: 15px 20px;
            font-size: 18px;
            font-weight: bold;
        }
        .form-container {
            padding: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        input[type="text"], input[type="email"], textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }
        textarea {
            height: 200px;
            resize: vertical;
        }
        .file-input {
            margin-top: 5px;
        }
        .buttons {
            margin-top: 20px;
            text-align: right;
        }
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            margin-left: 10px;
        }
        .btn-primary {
            background-color: #4285f4;
            color: white;
        }
        .btn-secondary {
            background-color: #f1f3f4;
            color: #3c4043;
        }
        .btn:hover {
            opacity: 0.9;
        }
        .recipient-fields {
            display: flex;
            gap: 10px;
        }
        .recipient-fields > div {
            flex: 1;
        }
        .cc-bcc-toggle {
            margin-top: 10px;
        }
        .cc-bcc-toggle a {
            color: #4285f4;
            text-decoration: none;
            font-size: 14px;
        }
        .cc-bcc-fields {
            display: none;
            margin-top: 10px;
        }
        .attachment-list {
            margin-top: 10px;
        }
        .attachment-item {
            display: flex;
            align-items: center;
            padding: 5px 0;
        }
        .attachment-item span {
            margin-left: 10px;
        }
        .remove-attachment {
            color: #d93025;
            cursor: pointer;
            margin-left: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            New Message
        </div>
        <div class="form-container">
            <form action="${pageContext.request.contextPath}/email/send" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="to">To:</label>
                    <input type="email" id="to" name="to" required placeholder="recipient@example.com">
                </div>

                <div class="cc-bcc-toggle">
                    <a href="#" onclick="toggleCCBCC(); return false;">CC/BCC</a>
                </div>

                <div id="cc-bcc-fields" class="cc-bcc-fields">
                    <div class="recipient-fields">
                        <div class="form-group">
                            <label for="cc">CC:</label>
                            <input type="email" id="cc" name="cc" placeholder="cc@example.com">
                        </div>
                        <div class="form-group">
                            <label for="bcc">BCC:</label>
                            <input type="email" id="bcc" name="bcc" placeholder="bcc@example.com">
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="subject">Subject:</label>
                    <input type="text" id="subject" name="subject" required placeholder="Enter subject">
                </div>

                <div class="form-group">
                    <label for="body">Message:</label>
                    <textarea id="body" name="body" placeholder="Compose your message..."></textarea>
                </div>

                <div class="form-group">
                    <label for="attachments">Attachments:</label>
                    <input type="file" id="attachments" name="attachments" multiple class="file-input">
                    <div id="attachment-list" class="attachment-list"></div>
                </div>

                <div class="buttons">
                    <button type="button" class="btn btn-secondary" onclick="window.history.back()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Send</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function toggleCCBCC() {
            var fields = document.getElementById('cc-bcc-fields');
            if (fields.style.display === 'none' || fields.style.display === '') {
                fields.style.display = 'block';
            } else {
                fields.style.display = 'none';
            }
        }

        document.getElementById('attachments').addEventListener('change', function(e) {
            var list = document.getElementById('attachment-list');
            list.innerHTML = '';
            for (var i = 0; i < e.target.files.length; i++) {
                var file = e.target.files[i];
                var item = document.createElement('div');
                item.className = 'attachment-item';
                item.innerHTML = '<span>' + file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)</span>';
                list.appendChild(item);
            }
        });
    </script>
</body>
</html>