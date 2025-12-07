# Agent Rules: Schema

You are in `design/specs/schema/`. Shared data model.

## Path

`specs/schema/*.md` — always shared across targets.

## Purpose

Define entities, fields, relationships, validation rules.

## When to Derive

For multi-app projects: read ALL target stories, identify entities, propose schema specs.

## Workflow

1. Analyze all stories for data requirements
2. Identify entities and relationships
3. Create schema specs
4. Reference from screen specs (`needs: ["schema:Item"]`)

## Reference

- [Spec Schema](appeus/reference/spec-schema.md#schema-spec-format)
