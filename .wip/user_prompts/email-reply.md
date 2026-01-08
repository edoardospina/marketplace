---
model: claude-sonnet-4-5-20250929
description: Generates a professional reply-all email based on email thread history and user instructions
argument-hint: [my reply content] [email thread files] [new attachments (optional)]
---

# Purpose

Generate a professional reply-all email by analyzing email thread history from PDFs and related files, incorporating user instructions and attachment references, then save it as a formatted markdown file ready for sending.

## Variables

MY_REPLY: $1
EMAIL_THREAD: $2
NEW_ATTACHMENTS: $3

## Instructions

- CRITICAL: If MY_REPLY is not provided (empty $1), report error "Error: Missing required argument 'my_reply'. Please provide what you want to include in the email reply." and STOP
- CRITICAL: If EMAIL_THREAD is not provided (empty $2), report error "Error: Missing required argument 'email_thread'. Please provide the email thread files/folders." and STOP
- Parse EMAIL_THREAD as a list of file/folder paths separated by ANY combination of:
  - Commas (,)
  - Whitespace (spaces, tabs)
  - Newline characters (\n)
  - Examples: "file1.pdf file2.pdf", "file1.pdf, file2.pdf", "file1.pdf\nfile2.pdf", "file1.pdf,  file2.pdf  file3.pdf"
  - Can use @ relative format or absolute paths
- CRITICAL: Must find an `emails.pdf` file in EMAIL_THREAD - if not found, report error "Error: Could not find required 'emails.pdf' file in the email thread. Please ensure the email history PDF is included." and STOP
- Read and analyze `emails.pdf` to understand:
  - Number of email threads and their structure
  - Chronological order of emails
  - All participants and their email addresses
  - Subject lines and conversation flow
  - Most importantly: identify the LATEST email that needs a reply
- Read all other files/folders in EMAIL_THREAD recursively to understand context and previous attachments
- Parse NEW_ATTACHMENTS (if provided) as a list separated by commas, whitespace, or newlines (same flexible parsing as EMAIL_THREAD)
- Identify emails from Edoardo Spina which may appear as:
  - edoardospina@gmail.com
  - edoardo.spina@gmail.com
  - edo@picoclinics.com
  - edoardo.spina@hotmail.com
  - edoardo.spina@hotmail.it
- Generate reply email that:
  - Uses appropriate tone based on previous emails (formal/casual)
  - Includes proper salutation matching thread style
  - Incorporates MY_REPLY content naturally
  - References previous attachments when relevant (avoid if obvious)
  - Lists new attachments with brief explanations (inline style for 1-2 simple attachments, list for more)
  - Includes clear next steps when relevant
  - Uses closing: "Sincerely,\nEdo"
  - Sounds natural and human, not robotic
  - Is concise but not curt, informative but not verbose
- Extract the primary recipient's email address from the latest email for filename
- Replace special characters in email address with underscores for safe filename

## Workflow

1. **Validate Required Arguments**
   - Check if MY_REPLY ($1) exists - if not, display error and stop
   - Check if EMAIL_THREAD ($2) exists - if not, display error and stop
   - Parse EMAIL_THREAD by splitting on commas, whitespace, and/or newlines to get list of file/folder paths
     - Split by any combination of: comma (,), spaces/tabs, newline (\n)
     - Filter out any empty strings from the result

2. **Locate and Read Email History**
   - Search for `emails.pdf` in the EMAIL_THREAD paths
   - If not found directly, check inside any folders provided
   - If still not found, display error about missing emails.pdf and stop
   - Read the emails.pdf file to understand the email thread

3. **Analyze Email Thread**
   - Identify all email threads present
   - Determine chronological order of emails
   - Extract participant information (names, email addresses)
   - Identify the LATEST email that requires a reply
   - Note the primary recipient (who sent the latest email)
   - Understand the subject matter and context

4. **Process Additional Context**
   - Read all other files provided in EMAIL_THREAD
   - For folders, read files recursively
   - Identify which files were previous attachments
   - Build understanding of the full conversation context

5. **Process New Attachments (if provided)**
   - If NEW_ATTACHMENTS ($3) is provided, parse paths separated by commas, whitespace, and/or newlines
     - Use same flexible parsing as EMAIL_THREAD: split by comma, spaces/tabs, or newlines
   - Read each file/folder to understand content and purpose
   - Note filenames and key information for reference in email

6. **Generate Reply Email**
   - Determine appropriate salutation based on previous emails
   - Parse MY_REPLY to understand user's intended message
   - Craft natural, professional email body that:
     - Responds to points from the latest email
     - Incorporates user's instructions from MY_REPLY
     - References context appropriately
     - Mentions new attachments if present
     - Suggests next steps if relevant
   - Add signature: "Sincerely,\nEdo"

7. **Save Email to File**
   - Extract primary recipient's email address
   - Clean email address for filename (replace @ with _at_, dots with _, etc.)
   - Create filename: `replyall_<cleaned_email>.md`
   - Write the complete email text to the file using Write tool

8. Now follow the `Report` section to report the completed work

## Report

Present the result in this format:

## ✅ Reply Email Generated

**File Created**: `replyall_[recipient_email].md`
**Replying To**: [Name] <[email]>
**Subject Context**: [Brief subject description]

### Email Summary
- **Tone**: [Formal/Casual/Professional]
- **Main Points Addressed**:
  - [Key point 1]
  - [Key point 2]
  - [Additional points as needed]
- **New Attachments Referenced**: [Count and brief description, or "None"]
- **Previous Context Incorporated**: [Yes/No - brief description]

### Next Steps Mentioned
[List any next steps included in the email, or "No specific next steps outlined"]

The email is ready to copy and send from your email client.