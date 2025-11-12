# AI Agent Rules: Stories Folder

*You are in the stories/ folder where humans write user stories*

## Your Role

**Help refine stories → Propose screens → Generate scenarios after approval**

- Analyze user stories to understand **functional requirements only**
- Check for existing reusable screens
- Propose semantic XML screen designs **based on user needs, not design constraints**
- Wait for approval before generating scenarios
- User may add specs later to refine "how" (you then update screens accordingly)

## Story Structure

Three sections: **Overview** (As a...I want...So that), **Sequence** (numbered steps), **Acceptance Criteria** (testable checkboxes)

**Important:** Stories describe **what users need**, not how screens should look. User will add specs later for design details.

See: [Story Template](../appgen/templates/stories/story-template.md)

## Workflow

When user creates/edits a story:

1. **Read thoroughly** - Understand goals, steps, edge cases, data needs
2. **Check context** - Review `../screens/` for reuse, `../specs/` for requirements, `../navigation/sitemap.md` for placement
3. **Propose screens** - Show XML implementations with semantic components
4. **Wait for approval** - User reviews wireframes via `../build.sh`
5. **Generate scenarios** - After approval, create detailed narratives in `../scenarios/`

## Commands

- `./regen` - Find stories modified since their scenarios were generated
  - User can say "run regen" and AI will execute and follow instructions
  - Or user can run manually and share output

## File Naming

Number stories for reading order: `01-first-story.md`, `02-next-story.md`

Scenarios will match: `../scenarios/01-first-story-scenarios.md`

## Common Mistakes

❌ Don't propose screens without reading full story  
❌ Don't ignore existing reusable screens  
❌ Don't use low-level SVG primitives - use semantic components  
❌ Don't generate scenarios before screens approved  
✅ Do explain component choices and design reasoning

## Need More Detail?

**📘 Detailed Workflow (START HERE):**
- [Stories Agent Workflow](../appgen/reference/stories-agent-workflow.md) - Comprehensive step-by-step guidance, examples, techniques, pitfalls

**Writing Stories:**
- [Story Writing Guide](../appgen/reference/story-writing.md) - For humans writing stories
- [Sample Story](../appgen/templates/stories/sample-story.md)

**Proposing Screens:**
- [Component System](../appgen/reference/component-system.md) - All available semantic components
- [Screen Examples](../appgen/examples/simple-todo-app/screens/)

**Complete Workflow:**
- [Full Workflow Guide](../appgen/reference/workflow.md)
- [AI Agent Guide](../appgen/reference/ai-agent-guide.md)

## Related Folders

- `../screens/` - Where you propose XML screens (check for reuse first)
- `../scenarios/` - Where you generate narratives (after approval)
- `../specs/` - Design specifications to follow
- `../navigation/` - App structure to respect

---

**Remember:** Stories describe *what* users need. Screens satisfy those needs. Focus on requirements, not UI preconceptions.
