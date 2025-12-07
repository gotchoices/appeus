# Schema: <EntityName>

---
id: <entity-id>
name: <EntityName>
description: <brief description>
---

## Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | yes | Unique identifier |
| name | string | yes | Display name |
| createdAt | ISO8601 | yes | Creation timestamp |
| updatedAt | ISO8601 | yes | Last update timestamp |

## Relationships

- <EntityName> belongs to <OtherEntity>
- <EntityName> has many <OtherEntity>

## Validation

- name: 1-100 characters
- <other validation rules>

## Examples

```json
{
  "id": "abc123",
  "name": "Example Item",
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z"
}
```

## Notes

<additional context about this entity>

