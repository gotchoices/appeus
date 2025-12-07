# Agent Rules: Schema

You are working with shared data model in `design/specs/schema/`.

## Path

`design/specs/schema/*.md` — always shared across targets.

## Purpose

Define data entities that are used across the application:
- Field names and types
- Relationships between entities
- Validation rules

## When to Derive Schema

For multi-app projects:
1. Read stories from ALL targets
2. Identify entities mentioned
3. Propose schema specs
4. Human reviews and refines

## Schema Spec Format

```yaml
---
id: item
name: Item
---

## Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | yes | Unique identifier |
| name | string | yes | Display name |
| price | number | yes | Price in cents |

## Relationships

- Item belongs to Category
- Item has many Reviews

## Validation

- name: 1-100 characters
- price: >= 0
```

## Workflow

1. Analyze all stories for data requirements
2. Identify entities and relationships
3. Create schema specs in `design/specs/schema/`
4. Reference from screen specs (`needs: ["schema:Item"]`)
5. Use in API specs and mock data

## Rules

- Schema is shared across ALL targets
- Derive before per-target generation
- Keep consistent with API specs

## References

- [Spec Schema](../reference/spec-schema.md#schema-spec-format)
- [Generation](../reference/generation.md)

