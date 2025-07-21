# GitHub Copilot Instructions

## 🎯 Primary Objective
Guide spec-driven development for ansible-pi-cluster using systematic requirements gathering, design, and implementation planning.

## 📚 Reference Documentation
- **Project Context**: `/README.md` - provides project overview, features, and user workflow
- **Steering Documentation**: `.github/steering/*.md` - context-specific development guidance
- **Project Structure**: Current file shows complete project organization

## 🔄 Spec-Driven Development Workflow

### Phase 1: Requirements Gathering
- [ ] Create `REQUIREMENTS.md` (temporary, never commit)
- [ ] Define user stories and acceptance criteria
- [ ] Identify affected components from project structure
- [ ] Reference steering docs for context-specific requirements
- [ ] Include compatibility requirements (existing workflow, task runner integration)

### Phase 2: Design & Architecture
- [ ] Create `DESIGN.md` (temporary, never commit)
- [ ] Reference project architecture principles from steering docs
- [ ] Design must preserve existing workflow patterns
- [ ] Consider impact on: playbooks, scripts, task runner, inventory
- [ ] Validate against intelligent automation principles

### Phase 3: Implementation Planning
- [ ] Create `IMPLEMENTATION.md` (temporary, never commit)
- [ ] Break down into discrete, testable tasks
- [ ] Reference relevant steering documentation for guidance
- [ ] Plan file modifications using project structure knowledge
- [ ] Include testing and validation steps

### Phase 4: Implementation
- [ ] Use steering documentation as context-specific guidance
- [ ] Follow existing patterns and conventions
- [ ] Maintain separation of concerns (playbooks vs scripts vs task runner)
- [ ] Preserve intelligent automation features
- [ ] Test incrementally

### Phase 5: Cleanup & Documentation
- [ ] Delete temporary files (REQUIREMENTS.md, DESIGN.md, IMPLEMENTATION.md)
- [ ] Update steering docs if new patterns emerge
- [ ] Update README.md if user-facing changes
- [ ] Follow existing documentation standards

## 📋 Steering Documentation System

### Purpose
Steering docs are committed, reusable guidance that extend these instructions with context-specific knowledge.

### Usage Rules
- **Auto-Selection**: Use frontmatter to match steering docs to current context
- **Extension Principle**: Treat steering docs as additional instruction content
- **Priority**: Steering doc guidance overrides general patterns when conflicts arise
- **Context Awareness**: Always check relevant steering docs before implementation

### Frontmatter Schema
```yaml
---
title: "Brief descriptive title"
triggers: ["keyword1", "keyword2"]  # Match against: file paths, task descriptions, technologies
applies_to: ["file-pattern", "directory/*"]  # Specific file/directory applicability
context: ["ansible", "script", "playbook", "task-runner"]  # Technical context
priority: high|medium|low  # Override priority when multiple docs match
---
```

### Selection Logic
1. **File Context**: Match `applies_to` patterns against current file path
2. **Keyword Matching**: Match `triggers` against task description or user input
3. **Technical Context**: Match `context` against identified technologies
4. **Priority Resolution**: Use `priority` to resolve conflicts

### Integration Workflow
- [ ] Scan `.github/steering/` for applicable docs
- [ ] Preview frontmatter headers to identify relevant docs
- [ ] Load matching docs based on frontmatter criteria
- [ ] Apply guidance as extension of these instructions
- [ ] Follow steering doc patterns over general conventions
- [ ] Reference steering docs in commit messages when used

### Steering Document Discovery

#### Preview Frontmatter Headers
```bash
# Extract frontmatter from all steering docs to see triggers and context
for file in .github/steering/*.md; do
    echo "=== $(basename "$file") ==="
    sed -n '/^---$/,/^---$/p' "$file" | head -n -1 | tail -n +2
    echo
done
```

## 🏗️ Architecture Preservation

### Core Principles (from README.md)
- **Smart Authentication**: Maintain SSH key vs password detection
- **Clean Output**: Preserve silent testing with color-coded summaries
- **TTY Handling**: Ensure all prompts remain visible and interactive
- **Efficient Workflow**: Keep cached connectivity results
- **Separation of Concerns**: Maintain playbook/script/task-runner boundaries

### Project Structure Rules
- **Numbered Playbooks**: Maintain execution order with number prefixes
- **Task Scripts**: Follow `task-*.sh` naming convention
- **Intelligent Runner**: Preserve `run-playbook.sh` as workflow heart
- **Task Integration**: All new functionality must integrate with `Taskfile.yml`

### Code Quality Standards
- **Error Handling**: Follow existing robust error handling patterns
- **User Experience**: Maintain clean, color-coded output standards
- **Documentation**: Update relevant docs for user-facing changes
- **Testing**: Include connectivity and functionality testing

## 🔍 Context Discovery Process

### Before Any Implementation
1. **Read README.md** for project overview and user workflow
2. **Preview steering doc headers** using frontmatter command
3. **Select relevant docs** based on task context and triggers
4. **Review project structure** to understand component relationships
5. **Identify integration points** with existing task runner workflow

### During Implementation
1. **Use frontmatter preview** to identify relevant steering docs
2. **Load selected docs** for context-specific guidance
3. **Follow existing patterns** from similar components
4. **Maintain architecture principles** from project documentation
5. **Test integration** with existing workflow

### File Management Rules
- **Temporary Files**: REQUIREMENTS.md, DESIGN.md, IMPLEMENTATION.md (never commit)
- **Steering Updates**: Only commit when patterns emerge that benefit future development
- **Documentation Updates**: Update README.md for user-facing changes
- **Version Control**: Follow existing git patterns and commit message conventions

## 🎯 Quality Assurance

### Pre-Implementation Checklist
- [ ] Requirements clearly defined with acceptance criteria
- [ ] Design aligns with project architecture principles
- [ ] Implementation plan references applicable steering docs
- [ ] Integration with existing task runner verified

### Post-Implementation Checklist  
- [ ] Functionality tested with existing workflow
- [ ] Documentation updated appropriately
- [ ] Temporary files cleaned up
- [ ] Steering docs updated if new patterns emerged
- [ ] Commit messages reference used steering docs

### Integration Testing
- [ ] Test with `task` command interface
- [ ] Verify intelligent authentication workflow preserved
- [ ] Confirm clean output and TTY handling maintained
- [ ] Validate error handling and user experience

## 💡 Development Guidelines

### Pattern Recognition
- **Study existing code** before implementing new features
- **Identify reusable patterns** that should become steering docs
- **Maintain consistency** with established conventions
- **Preserve user experience** standards

### Problem-Solving Approach
- **Start with requirements** - understand the user need
- **Design for maintainability** - consider future developers
- **Implement incrementally** - test each component
- **Document discoveries** - update steering docs with learnings

### Communication Standards
- **Clear commit messages** referencing used steering docs
- **Comprehensive documentation** for user-facing changes
- **Self-documenting code** following project conventions
- **Helpful error messages** maintaining user experience standards
