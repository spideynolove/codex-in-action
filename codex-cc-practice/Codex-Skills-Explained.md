Codex Skills Explained: Stop Repeating Prompts use SKILLS.md
============================================================

January 13, 2026

### 📹 Watch the Video Tutorial

If you are using the Codex CLI and find yourself writing the same instructions over and over again, you are not using the tool to its full potential.

[Watch Video](https://proflead.dev/videos/codex-skills-explained-101-d3Ydt6LyGeY/)

If you are using the Codex CLI and find yourself writing the same instructions over and over again, you are not using the tool to its full potential. Codex offers a powerful feature called Skills that allows you to package reusable workflows and give your AI agent new capabilities on demand. If you want to know more about it, then read this article until the end.

What Are Codex Skills?
----------------------

A Codex Skill is a reusable workflow packaged into a folder. Instead of rewriting the same instructions every time, you write them once inside the skill and let Codex handle the work.

Skills help you extend Codex with specific expertise and save time.

How Skills Work — Progressive Disclosure
----------------------------------------


Skills use a method called Progressive Disclosure:

*   Startup: Codex loads only the names and descriptions of all skills.
*   On Demand: When you request a skill, Codex loads the full SKILL.md file.
*   Efficient: Tokens are used only when needed.

This keeps performance fast and context clean.

Where Skills Live (Skill Scopes)
--------------------------------

Skills can be stored in different places:

*   **Global Level:**Across all projects
*   **User Level:**Available to your user
*   **Repository Level:**Inside a specific project
*   **System Level:**Default built-in skills

How to Install Existing Skills
------------------------------

Before using or creating skills, make sure your Codex CLI is updated to the latest version. The**Skill Creator**and**Skill Installer**options depend on the latest CLI features. If your version is outdated, these options may not appear in the terminal.

**To install an existing skill:**

*   Open Codex in the terminal
*   Type $
*   Choose Skill Installer
*   Enter a skill name or paste a GitHub URL
*   Codex installs it
*   Restart Codex

After a restart, type $ again, and you will see your installed skills.

How to Create Custom Skills
---------------------------

There are two ways:

### Method A: Using the CLI Creator

*   Start Codex and type $
*   Choose Skill Creator
*   Enter the name
*   Enter the instruction
*   Codex asks follow-up questions and builds the skill

If the skill ends up outside the .codex/skills folder, you must install it manually.

Simply follow the instructions above, “How to Install Existing Skills”.

### Method B: Manual Creation (Recommended)

A skill has a simple folder structure:

*   `skill.md`(Required): Main instruction file
*   `scripts/`(Optional): Code scripts for logic
*   `references/`(Optional): Docs or templates
*   `assets/`(Optional): Extra resources

The template of SKILL.md file:

```yaml
---  
name: skill-name  
description: Description that helps Codex select the skill  
metadata:  
  short-description: Optional user-facing description  
---  
  
Skill instructions for the Codex agent to follow when using this skill.
```

The example of SKILL.md file:

```yaml
---  
name: prompt-optimization  
description: Improve and rewrite user prompts to reduce ambiguity and improve LLM output quality. Use when a user asks to optimize, refine, clarify, or rewrite a prompt for better results, or when the request is about prompt optimization or prompt rewriting.  
---  
  
# Prompt Optimization  
  
## Goal  
  
Improve the user's prompt so Codex (or any LLM) produces better output while preserving intent.  
  
## Workflow  
  
1. Read the user's original prompt carefully.  
2. Identify ambiguity, missing context, or unclear intent.  
3. Rewrite the prompt to remove ambiguity and provide clear instructions.  
4. Retain the core intention of the user's request.  
5. Add relevant constraints (format, length, style) when helpful.  
  
## Output format  
  
Provide:  
- Improved prompt  
- Short explanation of what was improved  
  
## Constraints  
  
- Do not assume domain knowledge not in the original prompt.  
- Preserve user intent.  
  
## Example triggers  
- “Draft me an email asking for feedback.”  
- “Turn this into a daily to-do list.”  
- $automating-productivity
```

In order to create a new skill, follow these steps:

1.   Go to`.codex/skills/`
2.   Create a new folder
3.   Inside it, create`skill.md`
4.   Add:

*   Name
*   Short description
*   Full instructions
*   Trigger examples (optional)

Once the folder exists in`.codex/skills/`, Codex automatically recognizes it.

How Skills Are Detected and Triggered
-------------------------------------

You do not always have to invoke a skill manually. Inside skill.md, you can add trigger examples. When you type a prompt that matches one of those examples, Codex automatically runs the correct skill.

**For example:**

If a Writing Assistant skill has examples like:

*   “Help me write a blog post”
*   “Draft an introduction for a video script”

And you type:

*   Help me write an article about Codex skills

Codex understands the intent and triggers the Writing Assistant.

If it didn’t, then you can call the skill with the _$[skill-name] command_.

Best Practices for Creating Codex Skills
----------------------------------------


Follow these guidelines:

*   **One Skill, One Job.**Keep each skill focused on a single task.
*   **Zero Context Assumption.**Skills should not rely on previous messages — they must be self-contained.
*   **Refine Descriptions.**If a skill doesn’t trigger, adjust its description and examples.
*   **Prefer Instructions Over Scripts.**Use text instructions before complex code scripts.

GitHub Skills Library (Ready to Use)
------------------------------------

To help you get started quickly, I created a curated repository of ready-to-use Codex skills:

[https://github.com/proflead/codex-skills-library/](https://github.com/proflead/codex-skills-library/)

This library includes:

*   Developer-focused skills
*   Team-oriented workflows
*   Example skills you can install or adapt

Use these skills to improve your workflow or as templates for your own ideas.
