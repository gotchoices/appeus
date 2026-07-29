#!/usr/bin/env bash
# host-integration.sh
#
# Helpers for living alongside content Appeus does not own.
#
# Appeus may be the sole occupant of a project root (greenfield) or a guest in a
# repo that already has its own AGENTS.md, .gitignore, packages, and tooling
# (hosted mode). In hosted mode Appeus must never overwrite host content:
#   - root agent rules: append a marker-delimited section instead of symlinking
#   - .gitignore: add only Appeus-specific entries, one line at a time
#
# Sourced by init-project.sh, add-app.sh, detach-appeus.sh.

APPEUS_SECTION_MARKER='<!-- appeus -->'
APPEUS_GITIGNORE_HEADER='# Appeus symlinks (recreate with: path/to/appeus/scripts/init-project.sh)'

# Symlinks Appeus creates inside a project. Ignored by git because they point
# into the toolkit checkout, which is not part of the host repo.
appeus_ignore_entries() {
	cat <<'EOF'
/appeus
design/AGENTS.md
design/**/AGENTS.md
apps/*/AGENTS.md
design/stories/README.md
design/specs/README.md
design/specs/*/README.md
EOF
}

appeus_root_link_target() { # $1 = bootstrap | project
	case "$1" in
		project) echo "appeus/agent-rules/project.md" ;;
		*) echo "appeus/agent-rules/bootstrap.md" ;;
	esac
}

# True when $1 is a symlink pointing into the appeus toolkit.
appeus_is_toolkit_link() {
	local path="$1" target
	[ -L "$path" ] || return 1
	target="$(readlink "$path" 2>/dev/null || true)"
	case "$target" in
		appeus/*|*/appeus/*) return 0 ;;
	esac
	return 1
}

# Append agent-rules/root.md to an existing agent-rule file. Idempotent:
# returns 1 (no change) when the marker is already present.
appeus_append_section() {
	local file="$1" appeus_dir="$2"
	local section="${appeus_dir}/agent-rules/root.md"

	[ -f "$section" ] || return 1
	if grep -qF "$APPEUS_SECTION_MARKER" "$file" 2>/dev/null; then
		return 1
	fi

	if [ -s "$file" ]; then
		# Command substitution eats a trailing newline, so a non-empty result
		# means the file does not end in one.
		[ -n "$(tail -c 1 "$file")" ] && printf '\n' >>"$file"
		printf '\n' >>"$file"
	fi
	cat "$section" >>"$file"
	return 0
}

# Ensure the project root carries Appeus rules for the given phase.
# Echoes one of: linked | repointed | appended | present
appeus_ensure_root_rules() { # $1 = project dir, $2 = appeus dir, $3 = bootstrap|project
	local project_dir="$1" appeus_dir="$2" mode="$3"
	local file="${project_dir}/AGENTS.md"
	local link_target current
	link_target="$(appeus_root_link_target "$mode")"

	if appeus_is_toolkit_link "$file"; then
		current="$(readlink "$file" 2>/dev/null || true)"
		if [ "$current" = "$link_target" ]; then
			echo "present"
		else
			rm "$file"
			ln -s "$link_target" "$file"
			echo "repointed"
		fi
		return 0
	fi

	# Host-owned file (or a symlink to something else): append, never replace.
	if [ -e "$file" ]; then
		if appeus_append_section "$file" "$appeus_dir"; then
			echo "appended"
		else
			echo "present"
		fi
		return 0
	fi

	ln -s "$link_target" "$file"
	echo "linked"
}

# Some agents read CLAUDE.md rather than AGENTS.md. Mirror the rules there
# without disturbing a host-authored CLAUDE.md that already defers to AGENTS.md.
# Echoes: linked | repointed | appended | present | none
appeus_ensure_claude_pointer() { # $1 = project dir, $2 = appeus dir, $3 = bootstrap|project
	local project_dir="$1" appeus_dir="$2" mode="$3"
	local file="${project_dir}/CLAUDE.md"
	local link_target current
	link_target="$(appeus_root_link_target "$mode")"

	if appeus_is_toolkit_link "$file"; then
		current="$(readlink "$file" 2>/dev/null || true)"
		if [ "$current" = "$link_target" ]; then
			echo "present"
		else
			rm "$file"
			ln -s "$link_target" "$file"
			echo "repointed"
		fi
		return 0
	fi

	if [ -e "$file" ]; then
		# Already delegates to AGENTS.md (e.g. `@AGENTS.md`) — nothing to add.
		if grep -q 'AGENTS\.md' "$file" 2>/dev/null; then
			echo "defers"
		elif appeus_append_section "$file" "$appeus_dir"; then
			echo "appended"
		else
			echo "present"
		fi
		return 0
	fi

	# Only create CLAUDE.md when Appeus also owns AGENTS.md; in a host repo the
	# host decides which convention files exist.
	if appeus_is_toolkit_link "${project_dir}/AGENTS.md"; then
		ln -s "$link_target" "$file"
		echo "linked"
		return 0
	fi
	echo "none"
}

# Add one line to .gitignore if not already present verbatim.
appeus_add_gitignore_entry() { # $1 = gitignore path, $2 = entry
	local file="$1" entry="$2"

	if [ -f "$file" ] && grep -qxF "$entry" "$file"; then
		return 1
	fi
	if [ -s "$file" ]; then
		[ -n "$(tail -c 1 "$file")" ] && printf '\n' >>"$file"
	fi
	printf '%s\n' "$entry" >>"$file"
	return 0
}

# Nearest ancestor (including $1) whose package.json declares workspaces.
# Empty output + non-zero status when there is none.
appeus_find_workspace_root() { # $1 = start dir
	local d="$1"

	command -v node >/dev/null 2>&1 || return 1
	while [ "$d" != "/" ] && [ -n "$d" ]; do
		if [ -f "${d}/package.json" ] && node -e '
			const {readFileSync} = require("fs");
			const pkg = JSON.parse(readFileSync(process.argv[1], "utf8"));
			process.exit(pkg.workspaces ? 0 : 1);
		' "${d}/package.json" >/dev/null 2>&1; then
			echo "$d"
			return 0
		fi
		d="$(dirname "$d")"
	done
	return 1
}

# Package manager declared by the nearest package.json `packageManager` field
# (yarn | npm | pnpm), if any.
appeus_host_package_manager() { # $1 = start dir
	local root
	root="$(appeus_find_workspace_root "$1")" || return 1
	node -e '
		const {readFileSync} = require("fs");
		const pkg = JSON.parse(readFileSync(process.argv[1], "utf8"));
		const pm = (pkg.packageManager || "").split("@")[0];
		if (!pm) process.exit(1);
		console.log(pm);
	' "${root}/package.json" 2>/dev/null
}

# Warn when a new app path falls outside the host's workspace globs, so the user
# can decide whether to enroll it (or keep it deliberately standalone).
appeus_workspace_advice() { # $1 = project dir, $2 = app path (absolute)
	local project_dir="$1" app_path="$2" ws_root rel covered=0

	ws_root="$(appeus_find_workspace_root "${project_dir}")" || return 0
	rel="${app_path#"${ws_root}"/}"
	[ "$rel" = "$app_path" ] && return 0

	if node -e '
		const {readFileSync} = require("fs");
		const pkg = JSON.parse(readFileSync(process.argv[1], "utf8"));
		const globs = Array.isArray(pkg.workspaces) ? pkg.workspaces : (pkg.workspaces?.packages ?? []);
		const toRe = (g) => new RegExp("^" + g.split("/").map((seg) =>
			seg === "**" ? ".*" : seg.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replace(/\*/g, "[^/]*")
		).join("/") + "$");
		process.exit(globs.some((g) => toRe(g).test(process.argv[2])) ? 0 : 1);
	' "${ws_root}/package.json" "$rel" >/dev/null 2>&1; then
		covered=1
	fi

	if [ "$covered" = "0" ]; then
		echo "Note: ${ws_root}/package.json declares workspaces, but '${rel}' matches none of them."
		echo "  The app will install its own node_modules and stay outside the workspace graph."
		echo "  To enroll it instead, add \"${rel%/*}/*\" to that package.json's \"workspaces\" array"
		echo "  and re-run the framework install from the workspace root."
		echo ""
	fi
}

# True when this project root already holds content Appeus does not own.
appeus_is_hosted_project() { # $1 = project dir
	local project_dir="$1" f

	for f in package.json AGENTS.md CLAUDE.md tess tickets; do
		if [ -e "${project_dir}/${f}" ] && ! appeus_is_toolkit_link "${project_dir}/${f}"; then
			return 0
		fi
	done
	return 1
}
