# Agent Rules: Domain — Schema Topic

You are in `design/specs/domain/`. This area holds the **shared domain contract** (as needed).

## Path

`specs/domain/*.md` — always shared across targets (create only what you need).

## Purpose

Define entities, fields, relationships, validation rules.

## When to Derive

For multi-app projects: read ALL target stories, identify entities, propose schema specs.

## Workflow

1. Analyze all stories for data requirements
2. Identify entities and relationships
3. Create schema specs
4. Reference from screen specs (`needs: ["schema:Item"]`) as a conceptual tag; the human docs live under `specs/domain/`

## Reference

- [Spec Schema](appeus/reference/spec-schema.md#schema-spec-format)
