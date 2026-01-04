/**
 * Compact one-line status formatter for Claude Code sessions
 * Hides empty values, shows only relevant metrics
 */

interface SessionMetrics {
  context?: {
    used: number;
    total: number;
    percentage: number;
  };
  model?: string;
  tools?: Record<string, number>;
  agents?: Record<string, { elapsed: number; description: string }>;
  tasks?: {
    pending: number;
    inProgress: number;
    completed: number;
    total: number;
  };
  duration?: string;
  systemPrompts?: string[];
}

interface FormattedStatus {
  line: string;
  parts: string[];
}

function formatContext(metrics: SessionMetrics): string | null {
  if (!metrics.context) return null;
  const { percentage, used, total } = metrics.context;

  let color = "🟢";
  if (percentage > 85) color = "🔴";
  else if (percentage > 60) color = "🟡";

  return `${color} ${percentage}%`;
}

function formatTools(metrics: SessionMetrics): string | null {
  if (!metrics.tools || Object.keys(metrics.tools).length === 0) return null;

  const toolsStr = Object.entries(metrics.tools)
    .map(([name, count]) => `${name}×${count}`)
    .join(" ");

  return `Tools: ${toolsStr}`;
}

function formatAgents(metrics: SessionMetrics): string | null {
  if (!metrics.agents || Object.keys(metrics.agents).length === 0) return null;

  const agentsStr = Object.entries(metrics.agents)
    .map(([name, { elapsed }]) => `${name}(${elapsed}s)`)
    .join(" ");

  return `Agents: ${agentsStr}`;
}

function formatTasks(metrics: SessionMetrics): string | null {
  if (!metrics.tasks || metrics.tasks.total === 0) return null;

  const { pending, inProgress, completed, total } = metrics.tasks;
  const parts = [];

  if (inProgress > 0) parts.push(`🔄 ${inProgress}`);
  if (pending > 0) parts.push(`⏳ ${pending}`);
  if (completed > 0) parts.push(`✓ ${completed}`);

  return parts.length > 0 ? `Tasks: ${parts.join(" ")}` : null;
}

function formatContextDetails(systemPrompts?: string[]): string | null {
  if (!systemPrompts || systemPrompts.length === 0) return null;

  // Show count of included system prompts
  return `Context: ${systemPrompts.length} prompts`;
}

function formatModel(model?: string): string | null {
  if (!model) return null;
  // Don't show Claude Code version, just the model
  return `Model: ${model}`;
}

function formatDuration(duration?: string): string | null {
  if (!duration) return null;
  return `${duration}`;
}

export function formatStatus(metrics: SessionMetrics): FormattedStatus {
  const parts: string[] = [];

  // Add context health first (most important)
  const contextStr = formatContext(metrics);
  if (contextStr) parts.push(contextStr);

  // Add model (optional)
  const modelStr = formatModel(metrics.model);
  if (modelStr) parts.push(modelStr);

  // Add duration
  const durationStr = formatDuration(metrics.duration);
  if (durationStr) parts.push(durationStr);

  // Add tools
  const toolsStr = formatTools(metrics);
  if (toolsStr) parts.push(toolsStr);

  // Add agents
  const agentsStr = formatAgents(metrics);
  if (agentsStr) parts.push(agentsStr);

  // Add tasks
  const tasksStr = formatTasks(metrics);
  if (tasksStr) parts.push(tasksStr);

  // Add context details (system prompts + tools)
  const contextDetailsStr = formatContextDetails(metrics.systemPrompts);
  if (contextDetailsStr) parts.push(contextDetailsStr);

  const line = `📊 ${parts.join(" | ")}`;

  return { line, parts };
}

export function isShouldDisplay(metrics: SessionMetrics): boolean {
  // Only display if we have meaningful metrics
  return !!(
    metrics.context ||
    (metrics.tools && Object.keys(metrics.tools).length > 0) ||
    (metrics.agents && Object.keys(metrics.agents).length > 0) ||
    (metrics.tasks && metrics.tasks.total > 0)
  );
}
