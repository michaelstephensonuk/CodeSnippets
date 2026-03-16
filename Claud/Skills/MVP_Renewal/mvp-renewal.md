
---
name: mvp-renewal
description: >
  Helps Michael Stephenson compile his Microsoft MVP renewal report by researching
  activities across YouTube (personal and Turbo360 channels), blog, LinkedIn, user-provided
  speaking events, and web search. Produces a grouped, date-ordered HTML report of all
  qualifying MVP activities with names, links, and dates. Use this skill whenever the user
  mentions "MVP renewal", "MVP report", "MVP activities", "MVP submission", "Microsoft MVP",
  or asks to compile speaking or community activity history. Always trigger this skill even if
  the user only asks to "check my activities" or "what have I done this year" in a
  community/technical context.
---
 
# MVP Renewal Skill
 
This skill compiles Michael Stephenson's Microsoft MVP renewal activity report by
researching all known community profiles and producing a clean HTML report grouped
by MVP activity category, ordered by date descending within each group.
 
---
 
## Michael's Profile URLs (stored permanently)
 
| Source | URL |
|---|---|
| YouTube (Personal) | https://www.youtube.com/@mikestephensonazure |
| YouTube (Turbo360) | https://www.youtube.com/channel/UCXg6w8scUqf107iQMWeC_5g |
| Blog | https://mikestephenson.me/ |
| LinkedIn | https://www.linkedin.com/in/michaelstephensonuk1/ |
| MVP Profile | https://mvp.microsoft.com/en-US/mvp/profile/735880b4-3c9a-e411-93f2-9cb65495d3c4 |
 
**Name for web searches:** Michael Stephenson Azure
 
---
 
## Step 1: Establish Date Range
 
- Default: last 12 months from today's date
- If the user specifies a different range, use that instead
- Note the start and end dates clearly — every activity must fall within this window
 
---
 
## Step 1b: Ask for Speaking Events
 
Before researching, ask Michael:
 
> "Do you have a list of events you've spoken at during this period? If so, please share them — name, location, and date where you have them. I'll use these to find confirmation links and check for any recorded sessions online."
 
Wait for his response. Store the events list as **User-Provided Events** — these will be researched in Step 2e.
 
If Michael has nothing to add, continue to Step 2.
 
---
 
## Step 2: Research All Sources
 
Work through each source systematically. For each activity found, capture:
- **Title** (name of the talk, post, video, event)
- **URL** (direct link to the resource)
- **Date** (as precise as possible — YYYY-MM-DD preferred)
- **Category** (see categories below)
- **Source** (where you found it)
 
### 2a. YouTube (Personal Channel)
- Visit https://www.youtube.com/@mikestephensonazure/videos
- List all videos published within the date range
- For each video, attempt to fetch the view count from the video page. If unavailable, record as "Not available"
- Category: **Video**
 
### 2b. YouTube (Turbo360 Channel — Podcasts)
- Visit https://www.youtube.com/channel/UCXg6w8scUqf107iQMWeC_5g/videos
- Look specifically for episodes of the two podcasts Michael hosts:
  - **FinOps on Azure**
  - **Azure on Air**
- List all episodes published within the date range where Michael appears as host
- For each episode, attempt to fetch the view count. If unavailable, record as "Not available"
- Category: **Podcast**
 
### 2d. Blog
- Visit https://mikestephenson.me/
- Check the blog/posts section and paginate as needed
- List all posts published within the date range
- Category: **Blog Post**
 
### 2e. LinkedIn
- Visit https://www.linkedin.com/in/michaelstephensonuk1/
- Look for posts, articles, and activity within the date range
- Articles: Category **Article**
- Posts/shares with original content: **Social Media Post** (only include substantive ones)
- Also scan posts for any indication Michael attended or spoke at an event — look for phrases like "great to speak at", "just presented at", "thanks for having me", event hashtags, conference names, or photos from events. Add these to the **User-Provided Events** list for follow-up research in Step 2f if not already captured
- In the final report, include a section **"LinkedIn Posts Suggesting Event Attendance"** listing each such post with its date, a brief description of why it suggests an event, and a link to the post
 
### 2f. User-Provided Events
For each event Michael provided in Step 1b:
- Search the web for the event name to confirm the date, location, and whether Michael is listed as a speaker
- Check whether a recording exists on YouTube (search `"[event name]" "Michael Stephenson"` and also check both YouTube channels above)
- If a recording is found within the date range, add it as a separate **Video** entry in addition to the speaking entry
- Category: **Conference/Summit Speaking** or **User Group/Meetup Speaking** depending on event type
- If the event cannot be confirmed online, still include it and mark Source as "User-provided (unverified)"
 
### 2g. Web Search
Run the following searches and review results for any activities not already found:
- `"Michael Stephenson" Azure speaking 2024 OR 2025`
- `"Michael Stephenson" Azure podcast 2024 OR 2025`
- `"Michael Stephenson" Azure webinar 2024 OR 2025`
- `"Michael Stephenson" Azure community 2024 OR 2025`
- `site:mikestephenson.me`
- Adjust years to match the actual date range in use
 
---
 
## Step 3: De-duplicate
 
The same event may appear in multiple sources (e.g. a talk found via web search that also has a recording on YouTube). Keep one entry per unique activity, preferring the most specific/direct URL. If a speaking event also has a recording, these count as two separate entries.
 
---
 
## Step 4: Categorise Using MVP Activity Types
 
Use these official Microsoft MVP activity categories:
 
| Category | Examples |
|---|---|
| **Video** | YouTube videos, recorded webinars |
| **Blog Post** | Posts on personal or community blogs |
| **Article** | Long-form LinkedIn articles, guest posts |
| **Conference/Summit Speaking** | Talks at named conferences (e.g. Microsoft Build, Integrate) |
| **User Group/Meetup Speaking** | Talks at local or virtual meetups/user groups |
| **Organising a Community Event** | Organising meetups, events, hackathons |
| **Podcast** | Guest or host appearances on podcasts |
| **Webinar** | Live online sessions / virtual workshops |
| **Open Source Project** | GitHub contributions, OSS project activity |
| **Social Media / Other** | Substantive posts, threads, other content |
 
---
 
## Step 5: Generate HTML Report
 
Produce a self-contained HTML file using the structure in the template below.
 
### Report Rules
- Group activities by **Category** (use the categories above as section headings)
- Within each group, order by **date descending** (most recent first)
- Each row: Date | Activity Name (hyperlinked) | Source
- For **Video** entries, show the view count in brackets next to the title, e.g. `My Video Title (12,345 views)` or `My Video Title (views: Not available)`
- Show a **summary count** at the top: total activities and breakdown by category
- The date range covered should appear prominently at the top
- Style: clean, professional, Microsoft-themed (blues and whites), printable
 
### HTML Template Structure
 
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>MVP Activity Report – Michael Stephenson</title>
  <style>
    body { font-family: Segoe UI, sans-serif; max-width: 1000px; margin: 40px auto; color: #1a1a1a; }
    h1 { color: #0078d4; }
    h2 { color: #0078d4; border-bottom: 2px solid #0078d4; padding-bottom: 4px; margin-top: 40px; }
    .meta { color: #666; margin-bottom: 30px; }
    .summary { background: #f0f6ff; border: 1px solid #c7e0f4; border-radius: 6px; padding: 16px; margin-bottom: 30px; }
    .summary h3 { margin: 0 0 10px; color: #0078d4; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
    th { background: #0078d4; color: white; padding: 10px 12px; text-align: left; }
    td { padding: 9px 12px; border-bottom: 1px solid #e0e0e0; vertical-align: top; }
    tr:hover { background: #f5f9ff; }
    a { color: #0078d4; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .source { color: #666; font-size: 0.85em; }
    .count-badge { display: inline-block; background: #0078d4; color: white; border-radius: 12px; padding: 2px 10px; font-size: 0.85em; margin-left: 8px; }
  </style>
</head>
<body>
  <h1>🏆 Microsoft MVP Activity Report</h1>
  <div class="meta">
    <strong>Name:</strong> Michael Stephenson &nbsp;|&nbsp;
    <strong>Period:</strong> [START DATE] to [END DATE] &nbsp;|&nbsp;
    <strong>Generated:</strong> [TODAY'S DATE]
  </div>
 
  <div class="summary">
    <h3>Summary</h3>
    <p><strong>Total Activities:</strong> [N]</p>
    <!-- List each category with count -->
  </div>
 
  <!-- Repeat per category -->
  <h2>[Category Name] <span class="count-badge">[N]</span></h2>
  <table>
    <thead><tr><th>Date</th><th>Activity</th><th>Source</th></tr></thead>
    <tbody>
      <!-- One row per activity -->
      <tr>
        <td>[YYYY-MM-DD]</td>
        <td><a href="[URL]" target="_blank">[Activity Title]</a></td>
        <td class="source">[Source]</td>
      </tr>
    </tbody>
  </table>
 
  <!-- LinkedIn Posts Suggesting Event Attendance -->
  <h2>📋 LinkedIn Posts Suggesting Event Attendance</h2>
  <table>
    <thead><tr><th>Date</th><th>Post</th><th>Why flagged</th></tr></thead>
    <tbody>
      <tr>
        <td>[YYYY-MM-DD]</td>
        <td><a href="[URL]" target="_blank">[Post snippet or title]</a></td>
        <td class="source">[e.g. mentions "great to speak at Integrate 2024"]</td>
      </tr>
    </tbody>
  </table>
 
</body>
</html>
```
 
---
 
## Step 6: Save and Present
 
- Save the HTML file as `mvp-report-[YYYY-MM-DD].html` (using today's date)
- Copy to `/mnt/user-data/outputs/`
- Use `present_files` to deliver it to Michael
- Summarise: total count, date range covered, any sources where access was limited or blocked
 
---
 
## Notes & Edge Cases
 
- **YouTube** — if the channel page doesn't show dates directly, check individual video pages; view counts should also be fetched from individual video pages if not shown in listings
- **LinkedIn** may require login in some environments — if blocked, note it in the report and skip
- If a date cannot be determined, mark as `Unknown` and place at the bottom of the category group
- If a source is inaccessible, note it clearly in the report under a "⚠️ Sources Not Accessed" section
 
---
 
## Running in Cowork
 
This skill is designed to be run in **Cowork** where browser access is available.
Use the browser tool to visit each URL directly rather than relying on web search alone.
Web search is a supplement for finding activities not captured on the profile pages.
